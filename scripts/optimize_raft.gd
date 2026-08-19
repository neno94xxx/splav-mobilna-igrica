extends SceneTree

const SOURCE_PATH := "res://unused_assets/images/raft/raft.png"
const OUTPUT_PATH := "res://assets/raft/raft_optimized_v1.webp"
const TARGET_SIZE := Vector2i(512, 341)
const QUALITY := 0.95


func _init() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(SOURCE_PATH))
	if image == null or image.is_empty():
		push_error("Could not load raft image")
		quit(1)
		return
	image.resize(TARGET_SIZE.x, TARGET_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var result := image.save_webp(ProjectSettings.globalize_path(OUTPUT_PATH), true, QUALITY)
	if result != OK:
		push_error("Could not save optimized raft image")
		quit(1)
		return
	print("SAVED ", OUTPUT_PATH, " ", TARGET_SIZE, " quality=", QUALITY)
	quit(0)
