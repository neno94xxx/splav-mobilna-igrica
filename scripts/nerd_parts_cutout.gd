extends Node2D

const LOOP_TIME := 5.80
const WORK_LOOP := &"parts_work_loop"
const UPGRADE_BUILD := &"upgrade_build"
const UPGRADE_BUILD_DURATION := 3.0
const UPGRADE_BUILD_HIT_COUNT := 7

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	build_animation()
	restart_animation()


func build_animation() -> void:
	var animation := Animation.new()
	animation.resource_name = "Nerd parts work loop"
	animation.length = LOOP_TIME
	animation.loop_mode = Animation.LOOP_LINEAR

	# The feet stay approximately planted because the body scales from a low pivot.
	add_value_track(animation, NodePath("BodyBreathPivot:scale"), Animation.INTERPOLATION_CUBIC, [
		[0.00, Vector2.ONE],
		[0.55, Vector2(1.008, 1.018)],
		[1.10, Vector2.ONE],
		[1.65, Vector2(1.008, 1.018)],
		[2.20, Vector2.ONE],
		[3.60, Vector2.ONE],
		[4.15, Vector2(1.008, 1.018)],
		[4.70, Vector2.ONE],
		[5.25, Vector2(1.008, 1.018)],
		[5.80, Vector2.ONE],
	])

	# The complete arm-and-hammer image only rotates around the shoulder.
	add_value_track(animation, NodePath("HammerPivot:rotation"), Animation.INTERPOLATION_LINEAR, [
		[0.00, 0.0],
		[2.20, 0.0],
		[2.44, deg_to_rad(-8.0)],
		[2.66, deg_to_rad(91.0)],
		[2.78, deg_to_rad(85.0)],
		[2.92, 0.0],
		[3.13, deg_to_rad(-8.0)],
		[3.35, deg_to_rad(91.0)],
		[3.47, deg_to_rad(85.0)],
		[3.60, 0.0],
		[5.80, 0.0],
	])

	# A tiny head movement keeps the otherwise separate cutout from feeling rigid.
	add_value_track(animation, NodePath("HeadPivot:position"), Animation.INTERPOLATION_CUBIC, [
		[0.00, Vector2(80.192, -58.762)],
		[0.55, Vector2(80.192, -60.762)],
		[1.10, Vector2(80.192, -58.762)],
		[1.65, Vector2(80.192, -60.762)],
		[2.20, Vector2(80.192, -58.762)],
		[2.66, Vector2(80.692, -57.262)],
		[2.92, Vector2(80.192, -58.762)],
		[3.35, Vector2(80.692, -57.262)],
		[3.60, Vector2(80.192, -58.762)],
		[4.15, Vector2(80.192, -60.762)],
		[4.70, Vector2(80.192, -58.762)],
		[5.25, Vector2(80.192, -60.762)],
		[5.80, Vector2(80.192, -58.762)],
	])
	add_value_track(animation, NodePath("HeadPivot:rotation"), Animation.INTERPOLATION_CUBIC, [
		[0.00, 0.0],
		[2.20, 0.0],
		[2.66, deg_to_rad(1.2)],
		[2.92, 0.0],
		[3.35, deg_to_rad(1.2)],
		[3.60, 0.0],
		[5.80, 0.0],
	])

	var library := AnimationLibrary.new()
	library.add_animation(WORK_LOOP, animation)
	library.add_animation(UPGRADE_BUILD, build_upgrade_animation())
	animation_player.add_animation_library(&"", library)


func build_upgrade_animation() -> Animation:
	var animation := Animation.new()
	animation.resource_name = "Rapid upgrade build"
	animation.length = UPGRADE_BUILD_DURATION
	animation.loop_mode = Animation.LOOP_NONE

	var hammer_keys: Array = [[0.0, 0.0]]
	var body_keys: Array = [[0.0, Vector2.ONE]]
	var head_position_keys: Array = [[0.0, Vector2(80.192, -58.762)]]
	var head_rotation_keys: Array = [[0.0, 0.0]]
	for hit_index in UPGRADE_BUILD_HIT_COUNT:
		var impact_time := 0.30 + float(hit_index) * 0.40
		hammer_keys.append([impact_time - 0.13, deg_to_rad(-12.0)])
		hammer_keys.append([impact_time, deg_to_rad(96.0)])
		hammer_keys.append([impact_time + 0.07, deg_to_rad(82.0)])
		hammer_keys.append([impact_time + 0.16, 0.0])

		body_keys.append([impact_time - 0.13, Vector2(0.997, 1.012)])
		body_keys.append([impact_time, Vector2(1.012, 0.992)])
		body_keys.append([impact_time + 0.16, Vector2.ONE])

		head_position_keys.append([impact_time - 0.13, Vector2(80.192, -60.262)])
		head_position_keys.append([impact_time, Vector2(80.892, -57.262)])
		head_position_keys.append([impact_time + 0.16, Vector2(80.192, -58.762)])
		head_rotation_keys.append([impact_time - 0.13, deg_to_rad(-0.8)])
		head_rotation_keys.append([impact_time, deg_to_rad(1.8)])
		head_rotation_keys.append([impact_time + 0.16, 0.0])

	hammer_keys.append([UPGRADE_BUILD_DURATION, 0.0])
	body_keys.append([UPGRADE_BUILD_DURATION, Vector2.ONE])
	head_position_keys.append([UPGRADE_BUILD_DURATION, Vector2(80.192, -58.762)])
	head_rotation_keys.append([UPGRADE_BUILD_DURATION, 0.0])

	add_value_track(animation, NodePath("HammerPivot:rotation"), Animation.INTERPOLATION_LINEAR, hammer_keys)
	add_value_track(animation, NodePath("BodyBreathPivot:scale"), Animation.INTERPOLATION_CUBIC, body_keys)
	add_value_track(animation, NodePath("HeadPivot:position"), Animation.INTERPOLATION_CUBIC, head_position_keys)
	add_value_track(animation, NodePath("HeadPivot:rotation"), Animation.INTERPOLATION_CUBIC, head_rotation_keys)
	return animation


func add_value_track(animation: Animation, path: NodePath, interpolation: int, keys: Array) -> void:
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, path)
	animation.track_set_interpolation_type(track_index, interpolation)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_CONTINUOUS)
	for key: Array in keys:
		animation.track_insert_key(track_index, float(key[0]), key[1])


func restart_animation() -> void:
	animation_player.play(WORK_LOOP)
	animation_player.seek(0.0, true)


func play_upgrade_build() -> void:
	animation_player.play(UPGRADE_BUILD)
	animation_player.seek(0.0, true)


func seek_upgrade_build(time_seconds: float) -> void:
	animation_player.play(UPGRADE_BUILD)
	animation_player.seek(clampf(time_seconds, 0.0, UPGRADE_BUILD_DURATION), true)


func seek_preview(time_seconds: float) -> void:
	animation_player.play(WORK_LOOP)
	animation_player.seek(fposmod(time_seconds, LOOP_TIME), true)
	animation_player.pause()
