extends SceneTree

const SOURCE_PATH := "res://concept_art/character_sprites/nerd_hammer_sprite_sheet_v1_chroma.png"
const OUTPUT_DIR := "res://concept_art/character_sprites/nerd_hammer_v1"
const FRAME_SIZE := Vector2i(384, 512)
const COLUMNS := 4
const ROWS := 2
const TRANSPARENT_MAGENTA := 0.62
const OPAQUE_MAGENTA := 0.24


func _init() -> void:
	var source_absolute := ProjectSettings.globalize_path(SOURCE_PATH)
	var source := Image.load_from_file(source_absolute)
	if source == null or source.is_empty():
		push_error("Could not load sprite sheet: %s" % source_absolute)
		quit(1)
		return
	if source.get_size() != FRAME_SIZE * Vector2i(COLUMNS, ROWS):
		push_error("Unexpected sprite sheet size: %s" % source.get_size())
		quit(1)
		return

	source.convert(Image.FORMAT_RGBA8)
	var key_color := (
		source.get_pixel(0, 0)
		+ source.get_pixel(source.get_width() - 1, 0)
		+ source.get_pixel(0, source.get_height() - 1)
		+ source.get_pixel(source.get_width() - 1, source.get_height() - 1)
	) / 4.0
	remove_chroma_key(source, key_color)

	var output_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_absolute)
	var sheet_result := source.save_png(output_absolute.path_join("nerd_hammer_sprite_sheet_v1.png"))
	if sheet_result != OK:
		push_error("Could not save transparent sprite sheet: %s" % sheet_result)
		quit(1)
		return

	for row in ROWS:
		for column in COLUMNS:
			var frame_index := row * COLUMNS + column
			var frame_rect := Rect2i(Vector2i(column, row) * FRAME_SIZE, FRAME_SIZE)
			var frame := source.get_region(frame_rect)
			var frame_path := output_absolute.path_join("nerd_hammer_%02d.png" % frame_index)
			var frame_result := frame.save_png(frame_path)
			if frame_result != OK:
				push_error("Could not save frame %d: %s" % [frame_index, frame_result])
				quit(1)
				return

	print("NERD_SPRITES_EXTRACTED=8")
	print("CHROMA_KEY=", key_color)
	quit(0)


func remove_chroma_key(image: Image, key_color: Color) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			var magenta_similarity := minf(color.r, color.b) - color.g - absf(color.r - color.b) * 0.35
			if magenta_similarity >= TRANSPARENT_MAGENTA:
				image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			if magenta_similarity <= OPAQUE_MAGENTA:
				color.a = 1.0
				image.set_pixel(x, y, color)
				continue

			var alpha := 1.0 - smoothstep(OPAQUE_MAGENTA, TRANSPARENT_MAGENTA, magenta_similarity)
			var safe_alpha := maxf(alpha, 0.001)
			color.r = clampf((color.r - key_color.r * (1.0 - alpha)) / safe_alpha, 0.0, 1.0)
			color.g = clampf((color.g - key_color.g * (1.0 - alpha)) / safe_alpha, 0.0, 1.0)
			color.b = clampf((color.b - key_color.b * (1.0 - alpha)) / safe_alpha, 0.0, 1.0)
			color.a = alpha
			image.set_pixel(x, y, color)
