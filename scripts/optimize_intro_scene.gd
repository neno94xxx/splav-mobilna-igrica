extends SceneTree

const QUALITY := 0.94
const PARTS := [
	{"source": "res://unused_assets/images/intro-scene/boat-party.png", "output": "res://assets/intro-scene/boat-party_optimized_v1.webp", "size": Vector2i(1672, 941)},
	{"source": "res://unused_assets/images/intro-scene/ship-background.png", "output": "res://assets/intro-scene/ship-background_optimized_v1.webp", "size": Vector2i(1672, 941)},
	{"source": "res://unused_assets/images/intro-scene/fatguy-body.png", "output": "res://assets/intro-scene/fatguy-body_optimized_v1.webp", "size": Vector2i(576, 768)},
	{"source": "res://unused_assets/images/intro-scene/fatguy-head.png", "output": "res://assets/intro-scene/fatguy-head_optimized_v1.webp", "size": Vector2i(384, 384)},
	{"source": "res://unused_assets/images/intro-scene/nerd-body.png", "output": "res://assets/intro-scene/nerd-body_optimized_v1.webp", "size": Vector2i(576, 768)},
	{"source": "res://unused_assets/images/intro-scene/nerd-head.png", "output": "res://assets/intro-scene/nerd-head_optimized_v1.webp", "size": Vector2i(384, 384)},
	{"source": "res://unused_assets/images/intro-scene/rail.png", "output": "res://assets/intro-scene/rail_optimized_v1.webp", "size": Vector2i(1024, 341)},
]


func _init() -> void:
	for part: Dictionary in PARTS:
		var image := Image.load_from_file(ProjectSettings.globalize_path(part["source"]))
		if image == null or image.is_empty():
			push_error("Could not load %s" % part["source"])
			quit(1)
			return
		var target_size: Vector2i = part["size"]
		if image.get_size() != target_size:
			image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
		var result := image.save_webp(ProjectSettings.globalize_path(part["output"]), true, QUALITY)
		if result != OK:
			push_error("Could not save %s" % part["output"])
			quit(1)
			return
		print("SAVED ", part["output"], " ", target_size, " quality=", QUALITY)
	quit(0)
