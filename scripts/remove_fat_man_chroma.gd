extends SceneTree

const INPUT_PATH := "res://tmp/imagegen/fat_man_chroma_v1.png"
const OUTPUT_PATH := "res://unused_assets/images/sprites/fat_man_breath_v1.png"
const TRANSPARENT_DISTANCE := 0.18
const OPAQUE_DISTANCE := 0.42


func _init() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(INPUT_PATH))
	if image == null or image.is_empty():
		push_error("Could not load fat man chroma source")
		quit(1)
		return
	image.convert(Image.FORMAT_RGBA8)

	var key := sample_corner_key(image)
	print("CHROMA_KEY=", key, " samples=", image.get_pixel(100, 100), ",", image.get_pixel(image.get_width() - 100, 100), ",", image.get_pixel(100, image.get_height() - 100))
	var visible_pixels := 0
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			var distance := Vector3(color.r - key.r, color.g - key.g, color.b - key.b).length()
			var matte := smoothstep(TRANSPARENT_DISTANCE, OPAQUE_DISTANCE, distance)
			color.a *= matte
			if color.a <= 0.002:
				color = Color(0.0, 0.0, 0.0, 0.0)
			elif matte < 0.995:
				# Remove the green fringe only on antialiased edge pixels.
				color.g = minf(color.g, maxf(color.r, color.b) * 1.04)
				visible_pixels += 1
			else:
				visible_pixels += 1
			image.set_pixel(x, y, color)

	var result := image.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if result != OK:
		push_error("Could not save transparent fat man sprite")
		quit(1)
		return
	print("FAT_MAN_ALPHA_OK pixels=", visible_pixels, " corner_alpha=", image.get_pixel(0, 0).a)
	quit(0)


func sample_corner_key(image: Image) -> Color:
	var last_x := image.get_width() - 1
	var last_y := image.get_height() - 1
	return (image.get_pixel(0, 0) + image.get_pixel(last_x, 0) + image.get_pixel(0, last_y) + image.get_pixel(last_x, last_y)) / 4.0
