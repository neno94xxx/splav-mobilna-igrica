extends SceneTree


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("Usage: -- <input PNG> <output PNG>")
		quit(1)
		return

	var input_path := ProjectSettings.globalize_path(args[0])
	var output_path := ProjectSettings.globalize_path(args[1])
	var image := Image.load_from_file(input_path)
	if image.is_empty():
		push_error("Could not load chroma-key image: %s" % input_path)
		quit(2)
		return

	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			# For a magenta-key blend C = alpha * foreground + (1-alpha) * key,
			# the largest channel deviation is a stable estimate of alpha.
			var raw_matte := maxf(maxf(1.0 - color.r, color.g), 1.0 - color.b)
			if raw_matte <= 0.055:
				image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			var matte := clampf(raw_matte / 0.92, 0.0, 1.0)
			if matte < 0.999:
				color.r = clampf((color.r - (1.0 - matte)) / matte, 0.0, 1.0)
				color.g = clampf(color.g / matte, 0.0, 1.0)
				color.b = clampf((color.b - (1.0 - matte)) / matte, 0.0, 1.0)
			color.a *= matte
			image.set_pixel(x, y, color)

	var result := image.save_png(output_path)
	if result != OK:
		push_error("Could not save transparent PNG: %s" % output_path)
		quit(3)
		return
	print("CHROMA_KEY_OK=", output_path)
	quit()
