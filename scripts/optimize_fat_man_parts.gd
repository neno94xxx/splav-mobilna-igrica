extends SceneTree

const QUALITY := 0.95
const PARTS := [
	{
		"source": "res://unused_assets/images/fat man parts/fat-body.png",
		"output": "res://assets/fat man parts/fat-body_optimized_v1.webp",
		"size": Vector2i(512, 512),
	},
	{
		"source": "res://unused_assets/images/fat man parts/fat-head.png",
		"output": "res://assets/fat man parts/fat-head_optimized_v1.webp",
		"size": Vector2i(320, 292),
	},
]


func _init() -> void:
	for part: Dictionary in PARTS:
		var image := Image.load_from_file(ProjectSettings.globalize_path(part["source"]))
		if image == null or image.is_empty():
			push_error("Could not load %s" % part["source"])
			quit(1)
			return
		var target_size: Vector2i = part["size"]
		image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
		var result := image.save_webp(
			ProjectSettings.globalize_path(part["output"]),
			true,
			QUALITY
		)
		if result != OK:
			push_error("Could not save %s" % part["output"])
			quit(1)
			return
		print("SAVED ", part["output"], " ", target_size, " quality=", QUALITY)
	quit(0)
