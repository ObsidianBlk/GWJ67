shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;


void fragment() {
	
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	
	COLOR.rgb = mix(tex_color.rgb, screen_color, 0.5);
	COLOR.a = tex_color.a;
}

