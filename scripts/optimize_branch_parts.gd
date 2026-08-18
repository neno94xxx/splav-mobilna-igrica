extends SceneTree

const QUALITY := 0.95
const PARTS := [
	{
		"source": "res://unused_assets/images/branches/grana-dolje.png",
		"output": "res://assets/branches/grana-dolje_optimized_v1.webp",
	},
	{
		"source": "res://unused_assets/images/branches/grana-desno.png",
		"output": "res://assets/branches/grana-desno_optimized_v1.webp",
	},
]


func _init() -> void:
	for part: Dictionary in PARTS:
		var image := Image.load_from_file(ProjectSettings.globalize_path(part["source"]))
		if image == null or image.is_empty():
			push_error("Could not load %s" % part["source"])
			quit(1)
			return
		image.resize(384, 512, Image.INTERPOLATE_LANCZOS)
		var result := image.save_webp(
			ProjectSettings.globalize_path(part["output"]),
			true,
			QUALITY
		)
		if result != OK:
			push_error("Could not save %s" % part["output"])
			quit(1)
			return
		print("SAVED ", part["output"], " 384x512 quality=", QUALITY)
	quit(0)
