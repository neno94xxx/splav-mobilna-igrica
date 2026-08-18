shader_type canvas_item;

uniform int part_mode = 0;
uniform float arm_angle = 0.0;

const vec2 TEXTURE_SIZE_PX = vec2(384.0, 512.0);
const vec2 ELBOW_PIVOT_PX = vec2(276.0, 258.0);


float distance_to_segment(vec2 point, vec2 start, vec2 end) {
	vec2 segment = end - start;
	float ratio = clamp(dot(point - start, segment) / dot(segment, segment), 0.0, 1.0);
	return length(point - (start + segment * ratio));
}


float arm_mask(vec2 point) {
	float forearm = 1.0 - smoothstep(15.0, 17.0, distance_to_segment(point, vec2(274.0, 258.0), vec2(333.0, 239.0)));
	float hand = 1.0 - smoothstep(23.0, 26.0, length(point - vec2(334.0, 241.0)));
	float handle = 1.0 - smoothstep(8.0, 10.0, distance_to_segment(point, vec2(337.0, 188.0), vec2(337.0, 285.0)));
	float hammer_head = 1.0 - smoothstep(20.0, 23.0, distance_to_segment(point, vec2(315.0, 193.0), vec2(368.0, 193.0)));
	return max(max(forearm, hand), max(handle, hammer_head));
}


vec2 inverse_rotate_arm(vec2 output_pixel) {
	vec2 offset = output_pixel - ELBOW_PIVOT_PX;
	float cosine = cos(-arm_angle);
	float sine = sin(-arm_angle);
	vec2 rotated = vec2(
		cosine * offset.x - sine * offset.y,
		sine * offset.x + cosine * offset.y
	);
	return ELBOW_PIVOT_PX + rotated;
}


void fragment() {
	vec2 output_pixel = UV * TEXTURE_SIZE_PX;
	vec2 sample_pixel = output_pixel;
	if (part_mode == 1) {
		sample_pixel = inverse_rotate_arm(output_pixel);
	}

	vec2 sample_uv = sample_pixel / TEXTURE_SIZE_PX;
	if (sample_uv.x < 0.0 || sample_uv.y < 0.0 || sample_uv.x > 1.0 || sample_uv.y > 1.0) {
		COLOR = vec4(0.0);
	} else {
		vec4 source = texture(TEXTURE, sample_uv);
		float mask = arm_mask(sample_pixel);
		source.a *= part_mode == 1 ? mask : (1.0 - mask);
		COLOR = source;
	}
}
