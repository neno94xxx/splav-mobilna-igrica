extends SceneTree

const QUALITY := 0.94
const PARTS := [
	{"source": "res://unused_assets/images/intro-scene/boat-party.png", "output": "res://assets/intro-scene/boat-party_optimized_v1.webp", "size": Vector2i(1672, 941)},
	{"source": "res://unused_assets/images/intro-scene/ship-background.png", "output": "res://assets/intro-scene/ship-background_optimized_v1.webp", "size": Vector2i(1672, 941)},
	{"source": "res://unused_assets/images/intro-scene/fatguy-body.png", "output": "res://assets/intro-scene/fatguy-body_optimized_v1.webp", "size": Vector2i(576, 768)},
	{"source": "res://unused_assets/images/intro-scene/fatguy-head.png", "output": "res://assets/intro-scene/fatguy-head_optimized_v1.webp", "size": Vector2i(384, 384)},
	{"source": "res://unused_assets/images/intro-scene/nerd-body.png", "output": "res://assets/intro-scene/nerd-body_optimized_v1.webp", "size": Vector2i(576, 768)},
	{"source": "res://unused_assets/images/intro-scene/nerd-head.png", "output": "res://assets/intro-scene/nerd-head_optimized_v1.webp", "size": Vector2i(384, 384)},
	{"source": "res://unused_assets/images/intro-scene/nerd-scared-head.png", "output": "res://assets/intro-scene/nerd-scared-head_optimized_v1.webp", "size": Vector2i(384, 384)},
	{"source": "res://unused_assets/images/intro-scene/fat-scared-head.png", "output": "res://assets/intro-scene/fat-scared-head_optimized_v1.webp", "size": Vector2i(384, 384), "remove_edge_white": true},
	{"source": "res://unused_assets/images/intro-scene/ship-damaged.png", "output": "res://assets/intro-scene/ship-damaged_optimized_v1.webp", "max_size": Vector2i(1024, 1024)},
	{"source": "res://unused_assets/images/intro-scene/glacier.png", "output": "res://assets/intro-scene/glacier_optimized_v1.webp", "max_size": Vector2i(640, 640), "clean_glacier_artifact": true},
	{"source": "res://unused_assets/images/intro-scene/rail.png", "output": "res://assets/intro-scene/rail_optimized_v1.webp", "size": Vector2i(1024, 341)},
]


func _init() -> void:
	for part: Dictionary in PARTS:
		var image := Image.load_from_file(ProjectSettings.globalize_path(part["source"]))
		if image == null or image.is_empty():
			push_error("Could not load %s" % part["source"])
			quit(1)
			return
		var target_size: Vector2i = part.get("size", image.get_size())
		if part.has("max_size"):
			var max_size: Vector2i = part["max_size"]
			var source_size := image.get_size()
			var scale_factor := minf(
				float(max_size.x) / float(source_size.x),
				float(max_size.y) / float(source_size.y)
			)
			scale_factor = minf(scale_factor, 1.0)
			target_size = Vector2i(
				maxi(1, roundi(float(source_size.x) * scale_factor)),
				maxi(1, roundi(float(source_size.y) * scale_factor))
			)
		if image.get_size() != target_size:
			image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
		if part.get("remove_edge_white", false):
			remove_connected_white_background(image)
		if part.get("clean_glacier_artifact", false):
			remove_glacier_artifact(image)
		var result := image.save_webp(ProjectSettings.globalize_path(part["output"]), true, QUALITY)
		if result != OK:
			push_error("Could not save %s" % part["output"])
			quit(1)
			return
		print("SAVED ", part["output"], " ", target_size, " quality=", QUALITY)
	quit(0)


func remove_connected_white_background(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var queue: Array[Vector2i] = []

	for x in width:
		queue_white_pixel(image, Vector2i(x, 0), width, visited, queue)
		queue_white_pixel(image, Vector2i(x, height - 1), width, visited, queue)
	for y in height:
		queue_white_pixel(image, Vector2i(0, y), width, visited, queue)
		queue_white_pixel(image, Vector2i(width - 1, y), width, visited, queue)

	var queue_index := 0
	while queue_index < queue.size():
		var point := queue[queue_index]
		queue_index += 1
		image.set_pixelv(point, Color(0.0, 0.0, 0.0, 0.0))
		queue_white_pixel(image, point + Vector2i.LEFT, width, visited, queue)
		queue_white_pixel(image, point + Vector2i.RIGHT, width, visited, queue)
		queue_white_pixel(image, point + Vector2i.UP, width, visited, queue)
		queue_white_pixel(image, point + Vector2i.DOWN, width, visited, queue)


func remove_glacier_artifact(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	var clear_from_x := roundi(float(image.get_width()) * 0.65)
	var clear_from_y := roundi(float(image.get_height()) * 0.88)
	for y in range(clear_from_y, image.get_height()):
		for x in range(clear_from_x, image.get_width()):
			image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))


func queue_white_pixel(image: Image, point: Vector2i, width: int, visited: PackedByteArray, queue: Array[Vector2i]) -> void:
	if point.x < 0 or point.y < 0 or point.x >= width or point.y >= image.get_height():
		return
	var pixel_index := point.y * width + point.x
	if visited[pixel_index] != 0:
		return
	visited[pixel_index] = 1
	var color := image.get_pixelv(point)
	var lightest_channel := maxf(color.r, maxf(color.g, color.b))
	var darkest_channel := minf(color.r, minf(color.g, color.b))
	var channel_spread := lightest_channel - darkest_channel
	if lightest_channel >= 0.18 and channel_spread <= 0.16:
		queue.append(point)
