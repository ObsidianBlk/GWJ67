shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float percent : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	
	COLOR = (1.0 - UV.y <= percent) ? tex_color : screen_color;
}

