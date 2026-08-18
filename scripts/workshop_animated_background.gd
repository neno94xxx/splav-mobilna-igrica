extends Node2D

const BACKGROUND_PATH := "res://assets/backgrounds/workshop_background_optimized_v1.webp"


func _ready() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(BACKGROUND_PATH))
	if image == null or image.is_empty():
		push_error("Could not load workshop background: %s" % BACKGROUND_PATH)
		return
	var texture := ImageTexture.create_from_image(image)
	$Background.texture = texture
	$WaterOverlay.texture = texture
