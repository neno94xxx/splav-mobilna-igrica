extends SceneTree

const PARTS := [
	{
		"source": "res://unused_assets/images/sprites/raft-lvl1.png",
		"output": "res://assets/sprites/raft-lvl1_optimized_v1.webp",
		"size": Vector2i(384, 384),
		"quality": 0.88,
	},
	{
		"source": "res://unused_assets/images/sprites/sail-lvl1.png",
		"output": "res://assets/sprites/sail-lvl1_optimized_v1.webp",
		"size": Vector2i(512, 512),
		"quality": 0.90,
	},
	{
		"source": "res://unused_assets/images/sprites/fat-boy-on-raft.png",
		"output": "res://assets/sprites/fat-boy-on-raft_optimized_v1.webp",
		"size": Vector2i(256, 256),
		"quality": 0.90,
	},
	{
		"source": "res://unused_assets/images/sprites/skinny-boy-on-raft.png",
		"output": "res://assets/sprites/skinny-boy-on-raft_optimized_v1.webp",
		"size": Vector2i(256, 256),
		"quality": 0.90,
	},
	{
		"source": "res://unused_assets/images/sprites/launch_push_atlas_v2_source.png",
		"output": "res://assets/sprites/launch_push_atlas_v2.webp",
		"size": Vector2i(768, 768),
		"quality": 0.92,
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
		if image.get_size() != target_size:
			image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
		var output_quality: float = part["quality"]
		var result := image.save_webp(ProjectSettings.globalize_path(part["output"]), true, output_quality)
		if result != OK:
			push_error("Could not save %s" % part["output"])
			quit(1)
			return
		print("SAVED ", part["output"], " ", target_size, " quality=", output_quality)
	quit(0)
