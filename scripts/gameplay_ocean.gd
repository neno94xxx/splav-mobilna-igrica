extends Node2D

@onready var ocean_material: ShaderMaterial = $Ocean.material as ShaderMaterial


func set_travel(scroll: float, horizontal_scroll: float = 0.0, tile_size: float = 322.0) -> void:
	if is_instance_valid(ocean_material):
		ocean_material.set_shader_parameter("travel_pixels", scroll)
		ocean_material.set_shader_parameter("horizontal_travel_pixels", horizontal_scroll)
		ocean_material.set_shader_parameter("tile_size_pixels", tile_size)
