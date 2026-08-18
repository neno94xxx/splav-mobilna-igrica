shader_type canvas_item;
render_mode unshaded;

uniform float wave_strength : hint_range(0.0, 0.012, 0.0001) = 0.0053;
uniform float wave_speed : hint_range(0.0, 2.0, 0.01) = 0.78;
uniform float wave_scale : hint_range(5.0, 100.0, 1.0) = 34.0;
uniform float shimmer_strength : hint_range(0.0, 0.12, 0.001) = 0.052;
uniform float overlay_opacity : hint_range(0.0, 1.0, 0.01) = 1.0;


void fragment() {
	vec4 original = texture(TEXTURE, UV);

	// Water is cyan/blue in this illustration. Using the original, undistorted
	// pixel as the mask keeps sand, rocks, wood and plants completely static.
	float cyan_amount = min(original.g, original.b) - original.r;
	float blue_bias = original.b - original.r;
	float water_mask = smoothstep(0.075, 0.22, cyan_amount)
		* smoothstep(0.07, 0.18, blue_bias);

	float time = TIME * wave_speed;
	float horizontal = sin(UV.y * wave_scale + time)
		+ 0.45 * sin(UV.y * wave_scale * 0.47 - time * 1.31);
	float vertical = sin(UV.x * wave_scale * 0.72 - time * 0.83)
		+ 0.35 * sin((UV.x + UV.y) * wave_scale * 0.31 + time * 1.17);
	vec2 offset = vec2(horizontal, vertical) * wave_strength;
	vec4 moving_water = texture(TEXTURE, clamp(UV + offset, vec2(0.0), vec2(1.0)));
	float shimmer = sin((UV.x * 0.8 + UV.y) * wave_scale * 0.82 - time * 1.7)
		* sin((UV.x - UV.y * 0.6) * wave_scale * 0.58 + time * 1.13);
	moving_water.rgb *= 1.0 + shimmer * shimmer_strength * water_mask;

	COLOR = vec4(moving_water.rgb, moving_water.a * water_mask * overlay_opacity);
}
