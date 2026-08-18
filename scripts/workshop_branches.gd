extends Node2D

const LOOP_TIME := 6.40
const SWAY_LOOP := &"branch_sway_loop"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	build_animation()
	restart_animation()


func build_animation() -> void:
	var animation := Animation.new()
	animation.resource_name = "Workshop branches wind loop"
	animation.length = LOOP_TIME
	animation.loop_mode = Animation.LOOP_LINEAR

	add_rotation_track(animation, NodePath("LeftPivot:rotation"), [
		[0.00, deg_to_rad(-1.0)],
		[1.55, deg_to_rad(1.5)],
		[3.15, deg_to_rad(-0.7)],
		[4.80, deg_to_rad(1.1)],
		[6.40, deg_to_rad(-1.0)],
	])
	add_rotation_track(animation, NodePath("RightPivot:rotation"), [
		[0.00, deg_to_rad(1.2)],
		[1.20, deg_to_rad(-0.8)],
		[2.90, deg_to_rad(1.4)],
		[4.45, deg_to_rad(-1.3)],
		[6.40, deg_to_rad(1.2)],
	])

	var library := AnimationLibrary.new()
	library.add_animation(SWAY_LOOP, animation)
	animation_player.add_animation_library(&"", library)


func add_rotation_track(animation: Animation, path: NodePath, keys: Array) -> void:
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, path)
	animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_CUBIC)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_CONTINUOUS)
	for key: Array in keys:
		animation.track_insert_key(track_index, float(key[0]), key[1])


func restart_animation() -> void:
	animation_player.play(SWAY_LOOP)
	animation_player.seek(0.0, true)


func seek_preview(time_seconds: float) -> void:
	animation_player.play(SWAY_LOOP)
	animation_player.seek(fposmod(time_seconds, LOOP_TIME), true)
	animation_player.pause()
