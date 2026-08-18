extends SceneTree

const FOCUSED_SOURCE := "res://concept_art/character_sprites/nerd_hammer_v1/nerd_hammer_06.png"
const TONGUE_SOURCE := "res://concept_art/character_sprites/nerd_hammer_v1/nerd_hammer_07.png"
const OUTPUT_BODY := "res://unused_assets/images/sprites/nerd_hammer_body_v2.png"
const OUTPUT_ARM := "res://unused_assets/images/sprites/nerd_hammer_arm_v2.png"
const OUTPUT_COMPOSITE := "res://concept_art/character_sprites/nerd_hammer_rig_v2_composite.png"
const OUTPUT_BODY_PREVIEW := "res://artifacts/nerd_hammer_body_preview.png"
const OUTPUT_ARM_PREVIEW := "res://artifacts/nerd_hammer_arm_preview.png"


func _init() -> void:
	var focused := Image.load_from_file(ProjectSettings.globalize_path(FOCUSED_SOURCE))
	var tongue := Image.load_from_file(ProjectSettings.globalize_path(TONGUE_SOURCE))
	if focused == null or focused.is_empty() or tongue == null or tongue.is_empty():
		push_error("Could not load nerd source frames")
		quit(1)
		return
	if focused.get_size() != tongue.get_size():
		push_error("Nerd source frame sizes do not match")
		quit(1)
		return

	focused.convert(Image.FORMAT_RGBA8)
	tongue.convert(Image.FORMAT_RGBA8)
	var composite := focused.duplicate()
	merge_tongue_expression(composite, tongue)

	var body := composite.duplicate()
	var arm := Image.create(composite.get_width(), composite.get_height(), false, Image.FORMAT_RGBA8)
	arm.fill(Color(0.0, 0.0, 0.0, 0.0))
	separate_hammer_arm(composite, body, arm)

	var body_result: int = body.save_png(ProjectSettings.globalize_path(OUTPUT_BODY))
	var arm_result: int = arm.save_png(ProjectSettings.globalize_path(OUTPUT_ARM))
	var composite_result: int = composite.save_png(ProjectSettings.globalize_path(OUTPUT_COMPOSITE))
	var body_preview_result: int = save_preview(body, OUTPUT_BODY_PREVIEW)
	var arm_preview_result: int = save_preview(arm, OUTPUT_ARM_PREVIEW)
	if body_result != OK or arm_result != OK or composite_result != OK or body_preview_result != OK or arm_preview_result != OK:
		push_error("Could not save rig assets: %s, %s, %s" % [body_result, arm_result, composite_result])
		quit(1)
		return

	print("NERD_RIG_ASSETS_BUILT")
	quit(0)


func save_preview(source: Image, output_path: String) -> int:
	var preview := Image.create(source.get_width(), source.get_height(), false, Image.FORMAT_RGBA8)
	preview.fill(Color("#efd7a9"))
	preview.blend_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), Vector2i.ZERO)
	return preview.save_png(ProjectSettings.globalize_path(output_path))


func merge_tongue_expression(target: Image, tongue: Image) -> void:
	var center := Vector2(177.0, 182.0)
	var radius := Vector2(42.0, 27.0)
	for y in range(150, 212):
		for x in range(128, 222):
			var normalized := (Vector2(x, y) - center) / radius
			var distance := normalized.length()
			if distance >= 1.0:
				continue
			var weight := 1.0 - smoothstep(0.72, 1.0, distance)
			var focused_color := target.get_pixel(x, y)
			var tongue_color := tongue.get_pixel(x, y)
			target.set_pixel(x, y, focused_color.lerp(tongue_color, weight))


func separate_hammer_arm(source: Image, body: Image, arm: Image) -> void:
	for y in source.get_height():
		for x in source.get_width():
			var point := Vector2(x, y)
			var source_color := source.get_pixel(x, y)
			if source_color.a <= 0.001:
				continue

			var include_forearm := distance_to_segment(point, Vector2(216.0, 258.0), Vector2(278.0, 243.0)) <= 16.0
			var include_bridge_offset := (point - Vector2(257.0, 246.0)) / Vector2(27.0, 17.0)
			var include_bridge := include_bridge_offset.length_squared() <= 1.0
			var include_wrist_offset := (point - Vector2(256.0, 264.0)) / Vector2(29.0, 15.0)
			var include_wrist := include_wrist_offset.length_squared() <= 1.0
			var include_hand := point.distance_to(Vector2(278.0, 244.0)) <= 31.0
			var include_handle := distance_to_segment(point, Vector2(282.0, 175.0), Vector2(282.0, 312.0)) <= 16.0
			var include_head := distance_to_segment(point, Vector2(257.0, 193.0), Vector2(312.0, 193.0)) <= 25.0
			var include_arm := include_forearm or include_bridge or include_wrist or include_hand or include_handle or include_head
			if include_arm:
				arm.set_pixel(x, y, source_color)

			var erase_forearm := distance_to_segment(point, Vector2(224.0, 256.0), Vector2(278.0, 243.0)) <= 17.0
			var erase_bridge_offset := (point - Vector2(257.0, 246.0)) / Vector2(29.0, 19.0)
			var erase_bridge := erase_bridge_offset.length_squared() <= 1.0
			var erase_wrist_offset := (point - Vector2(256.0, 264.0)) / Vector2(31.0, 17.0)
			var erase_wrist := erase_wrist_offset.length_squared() <= 1.0
			var erase_residue_offset := (point - Vector2(250.0, 232.0)) / Vector2(19.0, 16.0)
			var erase_residue := erase_residue_offset.length_squared() <= 1.0
			var erase_speck_offset := (point - Vector2(244.0, 216.0)) / Vector2(20.0, 15.0)
			var erase_speck := erase_speck_offset.length_squared() <= 1.0
			var erase_hand := point.distance_to(Vector2(278.0, 244.0)) <= 32.0
			var erase_handle := distance_to_segment(point, Vector2(282.0, 172.0), Vector2(282.0, 315.0)) <= 18.0
			var erase_head := distance_to_segment(point, Vector2(257.0, 193.0), Vector2(312.0, 193.0)) <= 24.0
			if erase_forearm or erase_bridge or erase_wrist or erase_residue or erase_speck or erase_hand or erase_handle or erase_head:
				body.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))


func distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var ratio := clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0)
	return point.distance_to(start + segment * ratio)
