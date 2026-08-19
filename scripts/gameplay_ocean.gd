extends Node2D

@onready var ocean_material: ShaderMaterial = $Ocean.material as ShaderMaterial


func set_travel(scroll: float) -> void:
	if is_instance_valid(ocean_material):
		ocean_material.set_shader_parameter("travel_pixels", scroll)
