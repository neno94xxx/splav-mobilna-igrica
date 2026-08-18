extends Node2D

const LOOP_TIME := 7.0
const BREATH_LOOP := &"occasional_breath"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	build_breath_animation()
	restart_animation()


func build_breath_animation() -> void:
	var animation := Animation.new()
	animation.resource_name = "Occasional relaxed breathing"
	animation.length = LOOP_TIME
	animation.loop_mode = Animation.LOOP_LINEAR

	add_value_track(animation, NodePath("Breath:scale"), Animation.INTERPOLATION_CUBIC, [
		[0.0, Vector2.ONE],
		[1.2, Vector2.ONE],
		[1.85, Vector2(1.008, 1.005)],
		[2.55, Vector2.ONE],
		[4.1, Vector2.ONE],
		[4.80, Vector2(1.008, 1.005)],
		[5.55, Vector2.ONE],
		[7.0, Vector2.ONE],
	])
	add_value_track(animation, NodePath("Breath:position"), Animation.INTERPOLATION_CUBIC, [
		[0.0, Vector2.ZERO],
		[1.2, Vector2.ZERO],
		[1.85, Vector2(0.0, -1.8)],
		[2.55, Vector2.ZERO],
		[4.1, Vector2.ZERO],
		[4.80, Vector2(0.0, -1.8)],
		[5.55, Vector2.ZERO],
		[7.0, Vector2.ZERO],
	])

	var library := AnimationLibrary.new()
	library.add_animation(BREATH_LOOP, animation)
	animation_player.add_animation_library(&"", library)


func add_value_track(animation: Animation, path: NodePath, interpolation: int, keys: Array) -> void:
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, path)
	animation.track_set_interpolation_type(track_index, interpolation)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_CONTINUOUS)
	for key: Array in keys:
		animation.track_insert_key(track_index, float(key[0]), key[1])


func restart_animation() -> void:
	animation_player.play(BREATH_LOOP)
	animation_player.seek(0.0, true)


func seek_preview(time_seconds: float) -> void:
	animation_player.play(BREATH_LOOP)
	animation_player.seek(fposmod(time_seconds, LOOP_TIME), true)
	animation_player.pause()
