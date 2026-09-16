shader_type canvas_item;
render_mode unshaded;

uniform sampler2D ocean_texture : source_color, repeat_enable, filter_linear;
uniform float travel_pixels = 0.0;
uniform float horizontal_travel_pixels = 0.0;
uniform float distortion_strength : hint_range(0.0, 0.06, 0.001) = 0.032;
uniform float animation_speed : hint_range(0.0, 2.0, 0.01) = 0.42;
uniform float tile_size_pixels : hint_range(192.0, 720.0, 1.0) = 322.0;
uniform float distance_m : hint_range(0.0, 400.0, 1.0) = 0.0;


void fragment() {
	vec2 tiled_uv = UV * (vec2(720.0, 1280.0) / tile_size_pixels);
	tiled_uv.x += horizontal_travel_pixels / tile_size_pixels;
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
	vec3 water_color = ocean.rgb + light_shift;
	float shallow_water = 1.0 - smoothstep(0.0, 10.0, distance_m);
	float deep_water = smoothstep(10.0, 100.0, distance_m);
	vec3 shallow_color = water_color * 1.12 + vec3(0.015, 0.035, 0.025);
	vec3 deep_color = water_color * vec3(0.42, 0.56, 0.68) + vec3(0.0, 0.012, 0.045);
	water_color = mix(water_color, shallow_color, shallow_water * 0.78);
	water_color = mix(water_color, deep_color, deep_water * 0.84);
	COLOR = vec4(water_color, ocean.a);
}
