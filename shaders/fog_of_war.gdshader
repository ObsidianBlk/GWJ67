shader_type canvas_item;

uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D noise : repeat_enable;
uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform sampler2D screen_texture : hint_screen_texture;

uniform float width : hint_range(0, 40) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square


float hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == true) {
				return distance(uv, xy) / (width * texture_pixel_size.x);
			}
		}
	}
	
	return 0.0;
}

float calculate_noise_alpha(vec2 uv, float time){
	float nr = texture(noise, vec2(sin(uv.x + time), uv.y)).r;
	float ng = texture(noise, vec2(cos(uv.x - time), sin(uv.y + time))).g;
	float nb = texture(noise, vec2(uv.x, cos(uv.y - time))).b;
	return nr * ng * nb;
}

void fragment() {
	float time = TIME * speed;
	vec2 uv = UV;
	vec4 screen_color = texture(screen_texture, UV);
	
	vec4 mask_color = texture(TEXTURE, UV);
	COLOR = background_color;
	
	if (mask_color.a > 0.01){
		COLOR = screen_color;
		float ndist = hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE);
		if (ndist > 0.0) {
			float noise_alpha = clamp(calculate_noise_alpha(UV, time) * 10.0, 0.0, 1.0);
			COLOR.rgb = mix(background_color.rgb, screen_color.rgb, noise_alpha * ndist);
			//COLOR.rgb = mix(vec3(0.0, 1.0, 0.0), screen_color.rgb, noise_alpha);
		}
	}
}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
