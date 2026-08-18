shader_type canvas_item;

uniform float animation_time = 0.0;


float ellipse_mask(vec2 point, vec2 center, vec2 radius, float feather) {
	float distance_from_center = length((point - center) / radius);
	return 1.0 - smoothstep(1.0 - feather, 1.0, distance_from_center);
}


float timed_motion(float time_value, float start_time, float peak_time, float end_time) {
	return smoothstep(start_time, peak_time, time_value) * (1.0 - smoothstep(peak_time, end_time, time_value));
}


vec2 rotate_around(vec2 point, vec2 center, float angle) {
	float sine = sin(angle);
	float cosine = cos(angle);
	vec2 local = point - center;
	return center + vec2(
		local.x * cosine - local.y * sine,
		local.x * sine + local.y * cosine
	);
}


void fragment() {
	vec2 original_uv = UV;
	vec4 original_color = texture(TEXTURE, original_uv);
	vec2 sample_uv = original_uv;
	float cycle = mod(animation_time, 6.4);

	// Water moves continuously, but the color test protects the raft and beach.
	float shoreline = 0.18 + original_uv.y * 0.80;
	float water_position = smoothstep(shoreline, shoreline + 0.11, original_uv.x);
	float turquoise = smoothstep(0.035, 0.19, min(
		original_color.b - original_color.r,
		original_color.g - original_color.r
	));
	float water_mask = water_position * turquoise;
	vec2 water_shift = vec2(
		sin(original_uv.y * 92.0 + animation_time * 1.65) * 0.0028,
		cos(original_uv.x * 76.0 - animation_time * 1.25) * 0.00165
	);
	sample_uv += water_shift * water_mask;

	// Palm leaves sway gently while their trunk stays steady.
	float leaf_area = (1.0 - smoothstep(0.20, 0.285, original_uv.y)) * (1.0 - smoothstep(0.52, 0.64, original_uv.x));
	float leaf_green = smoothstep(0.015, 0.13, original_color.g - original_color.b) * smoothstep(-0.08, 0.09, original_color.g - original_color.r);
	float leaf_mask = leaf_area * leaf_green;
	float leaf_sway = sin(animation_time * 1.10) * 0.0072 + sin(animation_time * 0.57 + 1.2) * 0.0024;
	sample_uv.x += leaf_sway * leaf_mask * smoothstep(0.05, 0.54, original_uv.x);
	sample_uv.y += cos(animation_time * 0.92) * 0.0020 * leaf_mask;

	// The resting castaway slowly turns his head to the sea, holds, then returns.
	float resting_turn = timed_motion(cycle, 0.55, 1.45, 2.55);
	vec2 resting_head_center = vec2(0.220, 0.226);
	float resting_head_mask = ellipse_mask(original_uv, resting_head_center, vec2(0.083, 0.068), 0.28);
	vec2 resting_head_uv = rotate_around(sample_uv, resting_head_center, -0.065 * resting_turn);
	resting_head_uv.x = resting_head_center.x + (resting_head_uv.x - resting_head_center.x) * (1.0 + 0.115 * resting_turn);
	resting_head_uv += vec2(0.0080 * resting_turn, 0.0020 * resting_turn);
	sample_uv = mix(sample_uv, resting_head_uv, resting_head_mask);

	// A quick hammer stroke follows the head turn.
	float hammer_strike = timed_motion(cycle, 2.62, 2.88, 3.38);
	vec2 hammer_region_center = vec2(0.555, 0.525);
	float hammer_mask = ellipse_mask(original_uv, hammer_region_center, vec2(0.102, 0.125), 0.30);
	vec2 hammer_uv = rotate_around(sample_uv, vec2(0.495, 0.565), -0.165 * hammer_strike);
	hammer_uv -= vec2(-0.0080, 0.0300) * hammer_strike;
	sample_uv = mix(sample_uv, hammer_uv, hammer_mask);

	// After the strike, the repairer briefly turns his head toward the rope.
	float rope_look = timed_motion(cycle, 3.45, 4.25, 5.48);
	vec2 nerd_head_center = vec2(0.410, 0.535);
	float nerd_head_mask = ellipse_mask(original_uv, nerd_head_center, vec2(0.090, 0.073), 0.30);
	vec2 nerd_head_uv = rotate_around(sample_uv, nerd_head_center, 0.085 * rope_look);
	nerd_head_uv -= vec2(0.0115, -0.0025) * rope_look;
	sample_uv = mix(sample_uv, nerd_head_uv, nerd_head_mask);

	vec4 animated_color = texture(TEXTURE, clamp(sample_uv, vec2(0.001), vec2(0.999)));
	float moving_shimmer = (sin(original_uv.y * 125.0 - animation_time * 2.2) * 0.5 + 0.5) * water_mask;
	animated_color.rgb += vec3(0.034, 0.052, 0.045) * moving_shimmer;

	// A tiny warm flash makes the instant of the hammer impact readable.
	float impact = timed_motion(cycle, 2.82, 2.91, 3.08);
	float impact_mask = ellipse_mask(original_uv, vec2(0.535, 0.607), vec2(0.046, 0.030), 0.55);
	animated_color.rgb += vec3(0.24, 0.16, 0.035) * impact * impact_mask;

	COLOR = animated_color;
}
