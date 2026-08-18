extends Node2D

const LOOP_TIME := 7.20
const REST_LOOP := &"fat_man_rest_loop"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	build_animation()
	restart_animation()


func build_animation() -> void:
	var animation := Animation.new()
	animation.resource_name = "Fat man resting loop"
	animation.length = LOOP_TIME
	animation.loop_mode = Animation.LOOP_LINEAR

	# Very small breaths, scaled from the bottom so his feet stay planted.
	add_value_track(animation, NodePath("BodyBreathPivot:scale"), Animation.INTERPOLATION_CUBIC, [
		[0.00, Vector2.ONE],
		[0.90, Vector2(1.0056, 1.0112)],
		[1.80, Vector2.ONE],
		[3.80, Vector2.ONE],
		[4.70, Vector2(1.0056, 1.0112)],
		[5.60, Vector2.ONE],
		[7.20, Vector2.ONE],
	])
	add_value_track(animation, NodePath("HeadPivot:position"), Animation.INTERPOLATION_CUBIC, [
		[0.00, Vector2(-8.0, -74.2)],
		[0.90, Vector2(-8.0, -76.7)],
		[1.80, Vector2(-8.0, -74.2)],
		[3.80, Vector2(-8.0, -74.2)],
		[4.70, Vector2(-8.0, -76.7)],
		[5.60, Vector2(-8.0, -74.2)],
		[7.20, Vector2(-8.0, -74.2)],
	])

	# He occasionally glances aside, then settles back into the same pose.
	add_value_track(animation, NodePath("HeadPivot:rotation"), Animation.INTERPOLATION_CUBIC, [
		[0.00, 0.0],
		[2.70, 0.0],
		[3.25, deg_to_rad(-4.0)],
		[3.80, deg_to_rad(-4.0)],
		[4.35, 0.0],
		[7.20, 0.0],
	])

	var library := AnimationLibrary.new()
	library.add_animation(REST_LOOP, animation)
	animation_player.add_animation_library(&"", library)


func add_value_track(animation: Animation, path: NodePath, interpolation: int, keys: Array) -> void:
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, path)
	animation.track_set_interpolation_type(track_index, interpolation)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_CONTINUOUS)
	for key: Array in keys:
		animation.track_insert_key(track_index, float(key[0]), key[1])


func restart_animation() -> void:
	animation_player.play(REST_LOOP)
	animation_player.seek(0.0, true)


func seek_preview(time_seconds: float) -> void:
	animation_player.play(REST_LOOP)
	animation_player.seek(fposmod(time_seconds, LOOP_TIME), true)
	animation_player.pause()
