extends Node2D

const BACKGROUND_TEXTURE: Texture2D = preload("res://assets/backgrounds/workshop_background_optimized_v1.webp")


func _ready() -> void:
	# Use an imported Godot resource so the background is available inside Android
	# APK/AAB packages as well as from the desktop editor filesystem.
	$Background.texture = BACKGROUND_TEXTURE
	$WaterOverlay.texture = BACKGROUND_TEXTURE
