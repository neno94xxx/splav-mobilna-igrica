shader_type canvas_item;
render_mode unshaded;

uniform sampler2D ocean_texture : source_color, repeat_enable, filter_linear;
uniform float travel_pixels = 0.0;
uniform float distortion_strength : hint_range(0.0, 0.06, 0.001) = 0.032;
uniform float animation_speed : hint_range(0.0, 2.0, 0.01) = 0.42;
uniform float tile_size_pixels : hint_range(192.0, 720.0, 1.0) = 322.0;


void fragment() {
	vec2 tiled_uv = UV * (vec2(720.0, 1280.0) / tile_size_pixels);
	tiled_uv.y -= travel_pixels / tile_size_pixels;

	float time = TIME * animation_speed;
	float horizontal_wave = sin(tiled_uv.y * 6.28318 * 0.72 + time * 1.10);
	float diagonal_wave = sin((tiled_uv.x * 0.82 + tiled_uv.y * 0.48) * 6.28318 - time * 0.76);
	float cross_wave = cos((tiled_uv.x * 0.35 - tiled_uv.y * 0.91) * 6.28318 + time * 0.53);
	vec2 distortion = vec2(
		horizontal_wave * 0.58 + diagonal_wave * 0.42,
		diagonal_wave * 0.34 + cross_wave * 0.31
	) * distortion_strength;

	vec4 ocean = texture(ocean_texture, tiled_uv + distortion);
	float light_shift = (horizontal_wave + diagonal_wave) * 0.012;
	COLOR = vec4(ocean.rgb + light_shift, ocean.a);
}
