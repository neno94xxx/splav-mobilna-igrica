extends Node2D

const LOOP_TIME := 5.80
const WORK_LOOP := &"work_loop"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	build_work_loop()
	restart_animation()


func build_work_loop() -> void:
	var animation := Animation.new()
	animation.resource_name = "Nerd hammer work loop"
	animation.length = LOOP_TIME
	animation.loop_mode = Animation.LOOP_LINEAR

	add_value_track(animation, NodePath("Breath:position"), Animation.INTERPOLATION_CUBIC, [
		[0.00, Vector2.ZERO],
		[0.55, Vector2(0.0, -2.0)],
		[1.10, Vector2.ZERO],
		[1.65, Vector2(0.0, -2.0)],
		[2.20, Vector2.ZERO],
		[3.60, Vector2.ZERO],
		[4.15, Vector2(0.0, -2.0)],
		[4.70, Vector2.ZERO],
		[5.25, Vector2(0.0, -2.0)],
		[5.80, Vector2.ZERO],
	])
	add_value_track(animation, NodePath("Breath:scale"), Animation.INTERPOLATION_CUBIC, [
		[0.00, Vector2.ONE],
		[0.55, Vector2(1.002, 1.008)],
		[1.10, Vector2.ONE],
		[1.65, Vector2(1.002, 1.008)],
		[2.20, Vector2.ONE],
		[3.60, Vector2.ONE],
		[4.15, Vector2(1.002, 1.008)],
		[4.70, Vector2.ONE],
		[5.25, Vector2(1.002, 1.008)],
		[5.80, Vector2.ONE],
	])

	# Tijelo samo blago reagira u trenutku dodira cekica.
	add_value_track(animation, NodePath("Breath/Impact:position"), Animation.INTERPOLATION_LINEAR, [
		[0.00, Vector2.ZERO],
		[2.62, Vector2.ZERO],
		[2.675, Vector2(0.0, 1.4)],
		[2.82, Vector2.ZERO],
		[3.32, Vector2.ZERO],
		[3.375, Vector2(0.0, 1.4)],
		[3.52, Vector2.ZERO],
		[5.80, Vector2.ZERO],
	])

	# Cijela savinuta ruka i cekic jedan su kruti element s pivotom u ramenu.
	add_value_track(animation, NodePath("Breath/Impact/HammerArmPivot:rotation"), Animation.INTERPOLATION_LINEAR, [
		[0.00, 0.0],
		[2.20, 0.0],
		[2.46, deg_to_rad(-10.0)],
		[2.675, deg_to_rad(32.0)],
		[2.78, deg_to_rad(24.0)],
		[2.90, 0.0],
		[3.16, deg_to_rad(-10.0)],
		[3.375, deg_to_rad(32.0)],
		[3.48, deg_to_rad(24.0)],
		[3.60, 0.0],
		[5.80, 0.0],
	])

	var library := AnimationLibrary.new()
	library.add_animation(WORK_LOOP, animation)
	animation_player.add_animation_library(&"", library)


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


func seek_preview(time_seconds: float) -> void:
	animation_player.play(WORK_LOOP)
	animation_player.seek(fposmod(time_seconds, LOOP_TIME), true)
	animation_player.pause()
