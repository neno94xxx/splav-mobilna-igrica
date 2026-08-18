extends SceneTree

const SOURCE_PATH := "res://concept_art/character_sprites/nerd_hammer_v1/nerd_hammer_01.png"
const OUTPUT_DIR := "res://unused_assets/images/sprites/nerd_simple_cutout_v1"
const BODY_PREVIEW := "res://artifacts/nerd_simple_body_preview.png"
const ARM_PREVIEW := "res://artifacts/nerd_simple_arm_preview.png"
const NEUTRAL_PREVIEW := "res://artifacts/nerd_simple_cutout_preview.png"


func _init() -> void:
	var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE_PATH))
	if source == null or source.is_empty():
		push_error("Could not load simple cutout source")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)

	var body := source.duplicate()
	var arm := Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	arm.fill(Color(0.0, 0.0, 0.0, 0.0))

	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x, y)
			if color.a <= 0.001:
				continue
			var point := Vector2(x, y)
			if arm_include_mask(point):
				arm.set_pixel(x, y, color)
			if arm_erase_mask(point):
				body.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))

	var output_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_absolute)
	var body_result: int = body.save_png(output_absolute.path_join("body.png"))
	var arm_result: int = arm.save_png(output_absolute.path_join("hammer_arm.png"))
	var body_preview_result: int = save_preview([body], BODY_PREVIEW)
	var arm_preview_result: int = save_preview([arm], ARM_PREVIEW)
	var neutral_preview_result: int = save_preview([body, arm], NEUTRAL_PREVIEW)
	if body_result != OK or arm_result != OK or body_preview_result != OK or arm_preview_result != OK or neutral_preview_result != OK:
		push_error("Could not save simple cutout assets")
		quit(1)
		return

	print("NERD_SIMPLE_CUTOUT_BUILT=2")
	quit(0)


func arm_include_mask(point: Vector2) -> bool:
	# The face overlaps the broad shoulder capsule in the source image. Keep the
	# shoulder seam on the body and start the moving arm just below it.
	var upper_arm := distance_to_segment(point, Vector2(226.0, 221.0), Vector2(258.0, 269.0)) <= 21.0 \
		and not (point.x < 235.0 and point.y < 222.0)
	var forearm := distance_to_segment(point, Vector2(247.0, 274.0), Vector2(311.0, 249.0)) <= 28.0
	var hand := ellipse_contains(point, Vector2(323.0, 246.0), Vector2(45.0, 50.0))
	var handle := distance_to_segment(point, Vector2(334.0, 175.0), Vector2(334.0, 303.0)) <= 16.0
	var hammer_head := distance_to_segment(point, Vector2(315.0, 193.0), Vector2(373.0, 193.0)) <= 26.0
	return upper_arm or forearm or hand or handle or hammer_head


func arm_erase_mask(point: Vector2) -> bool:
	var upper_arm := distance_to_segment(point, Vector2(233.0, 228.0), Vector2(258.0, 269.0)) <= 23.0
	var forearm := distance_to_segment(point, Vector2(244.0, 274.0), Vector2(313.0, 248.0)) <= 31.0
	var hand := ellipse_contains(point, Vector2(323.0, 246.0), Vector2(48.0, 53.0))
	var handle := distance_to_segment(point, Vector2(334.0, 171.0), Vector2(334.0, 307.0)) <= 19.0
	var hammer_head := distance_to_segment(point, Vector2(312.0, 193.0), Vector2(376.0, 193.0)) <= 29.0
	return upper_arm or forearm or hand or handle or hammer_head


func save_preview(parts: Array, output_path: String) -> int:
	var preview := Image.create(384, 512, false, Image.FORMAT_RGBA8)
	preview.fill(Color("#efd7a9"))
	for part: Image in parts:
		preview.blend_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), Vector2i.ZERO)
	return preview.save_png(ProjectSettings.globalize_path(output_path))


func ellipse_contains(point: Vector2, center: Vector2, radius: Vector2) -> bool:
	var offset := (point - center) / radius
	return offset.length_squared() <= 1.0


func distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var ratio := clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0)
	return point.distance_to(start + segment * ratio)
