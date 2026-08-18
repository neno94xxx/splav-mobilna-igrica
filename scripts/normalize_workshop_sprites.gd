extends SceneTree


func _initialize() -> void:
	var source_path := ProjectSettings.globalize_path("res://concept_art/ChatGPT Image Aug 16, 2026, 06_31_40 PM.png")
	var target_path := ProjectSettings.globalize_path("res://unused_assets/images/sprites/workshop_character_frames_v1.png")
	var image := Image.new()
	var load_result := image.load(source_path)
	if load_result != OK:
		printerr("SPRITE_LOAD_ERROR=", load_result)
		quit(load_result)
		return
	print("SPRITE_SIZE=", image.get_width(), "x", image.get_height())
	print("SPRITE_FORMAT=", image.get_format())
	print("SPRITE_HAS_ALPHA=", image.detect_alpha() != Image.ALPHA_NONE)
	print("WHITE_COLUMN_RANGES=", find_white_columns(image))
	print("WHITE_ROW_RANGES=", find_white_rows(image))
	var frame_columns := [Rect2i(0, 0, 294, 468), Rect2i(296, 0, 264, 468), Rect2i(562, 0, 263, 468), Rect2i(826, 0, 296, 468)]
	var frame_rows := [Vector2i(0, 468), Vector2i(469, 465), Vector2i(936, 466)]
	var frame_folder := ProjectSettings.globalize_path("res://artifacts/workshop_sprite_frames")
	DirAccess.make_dir_recursive_absolute(frame_folder)
	var frame_index := 0
	for row in frame_rows:
		for column in frame_columns:
			var region := Rect2i(column.position.x, row.x, column.size.x, row.y)
			var frame := image.get_region(region)
			frame.save_png("%s/frame_%02d.png" % [frame_folder, frame_index])
			frame_index += 1
	var save_result := image.save_png(target_path)
	print("SPRITE_SAVE_RESULT=", save_result)
	quit(save_result)


func find_white_columns(image: Image) -> Array[Vector2i]:
	var white_indices: Array[int] = []
	for x in image.get_width():
		var white_samples := 0
		var sample_count := 0
		for y in range(0, image.get_height(), 4):
			var color := image.get_pixel(x, y)
			if color.r > 0.94 and color.g > 0.94 and color.b > 0.94:
				white_samples += 1
			sample_count += 1
		if float(white_samples) / float(sample_count) > 0.94:
			white_indices.append(x)
	return collapse_indices(white_indices)


func find_white_rows(image: Image) -> Array[Vector2i]:
	var white_indices: Array[int] = []
	for y in image.get_height():
		var white_samples := 0
		var sample_count := 0
		for x in range(0, image.get_width(), 4):
			var color := image.get_pixel(x, y)
			if color.r > 0.94 and color.g > 0.94 and color.b > 0.94:
				white_samples += 1
			sample_count += 1
		if float(white_samples) / float(sample_count) > 0.94:
			white_indices.append(y)
	return collapse_indices(white_indices)


func collapse_indices(indices: Array[int]) -> Array[Vector2i]:
	var ranges: Array[Vector2i] = []
	if indices.is_empty():
		return ranges
	var range_start := indices[0]
	var previous := indices[0]
	for index in indices.slice(1):
		if index > previous + 1:
			ranges.append(Vector2i(range_start, previous))
			range_start = index
		previous = index
	ranges.append(Vector2i(range_start, previous))
	return ranges
