extends Node2D

enum State { HOME, CHARGING, INTRO, PLAYING, RETURNING, RESULTS, VICTORY }

const VIEW_SIZE := Vector2(720.0, 1280.0)
const RAFT_Y := 1035.0
const SAVE_PATH := "user://save.cfg"
const SPRITE_ATLAS: Texture2D = preload("res://assets/sprites/raft_escape_atlas_v1.png")
const ISLAND_SPRITE: Texture2D = preload("res://assets/sprites/deserted_island_v1.png")
const LAUNCH_PUSH_ATLAS: Texture2D = preload("res://assets/sprites/launch_push_atlas_v1.png")
const LAUNCH_FULL_TIME := 2.60
const LAUNCH_EXPONENT := 3.0
const LAUNCH_YELLOW_POINT := 0.45
const LAUNCH_GREEN_START := 0.70
const LAUNCH_IDEAL_CENTER := 0.80
const LAUNCH_IDEAL_HALF_WIDTH := 0.025
const LAUNCH_BLACK_START := 0.88
const INTRO_PUSH_MIN_TIME := 0.32
const INTRO_PUSH_MAX_TIME := 1.65
const INTRO_JUMP_TIME := 0.58
const INTRO_FAILED_JUMP_TIME := 0.28
const INTRO_SETTLE_TIME := 0.72

const COLOR_DEEP := Color("#083c5a")
const COLOR_WATER := Color("#087e9b")
const COLOR_WATER_LIGHT := Color("#23b5c7")
const COLOR_SAND := Color("#f2cc8f")
const COLOR_GRASS := Color("#67a357")
const COLOR_INK := Color("#17324d")
const COLOR_PANEL := Color("#f7f1df")
const COLOR_COIN := Color("#ffd166")
const COLOR_WOOD := Color("#a96942")
const COLOR_CORAL := Color("#ef6f6c")

var state: int = State.HOME
var state_time := 0.0
var intro_time := 0.0
var world_scroll := 0.0
var distance_m := 0.0
var run_coins := 0
var run_parts := 0
var total_coins := 0
var total_parts := 0
var raft_level := 1
var raft_health := 1
var return_reason := ""
var banked_this_run := false
var hit_flash := 0.0
var spawn_timer := 0.0
var raft_x := VIEW_SIZE.x * 0.5
var target_x := VIEW_SIZE.x * 0.5
var pointer_active := false
var touch_joystick_enabled := false
var touch_steering_active := false
var active_touch_index := -1
var joystick_target_axis := 0.0
var joystick_visual_axis := 0.0
var capture_requested := false
var capture_frames := 0
var capture_filename := "prototype.png"
var launch_charge := 0.0
var launch_power := 0.55
var launch_hold_ratio := 0.55
var launch_overcharged := false
var launch_is_perfect := false
var run_target_distance := 75.0
var launch_cruise_speed := 500.0
var raft_forward_speed := 500.0
var intro_raft_speed := 0.0
var intro_push_peak_speed := 500.0
var launch_feedback := ""
var intro_push_duration := 0.90
var intro_action_end := 1.48
var intro_duration := 2.20

var obstacles: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

var launch_button := Rect2(110, 555, 500, 102)
var again_button := Rect2(100, 895, 520, 88)
var upgrade_button := Rect2(100, 1010, 520, 88)
var victory_button := Rect2(120, 1100, 480, 88)


func _ready() -> void:
	rng.randomize()
	load_progress()
	set_process(true)
	set_process_unhandled_input(true)
	var user_args := OS.get_cmdline_user_args()
	touch_joystick_enabled = OS.get_name() == "Android" or "--touch-preview" in user_args
	if "--smoke-test" in user_args:
		call_deferred("run_smoke_test")
	if "--capture" in user_args:
		capture_requested = true
	elif "--capture-play" in user_args:
		prepare_gameplay_capture()
		capture_filename = "gameplay.png"
		capture_requested = true
	elif "--capture-results" in user_args:
		prepare_results_capture()
		capture_filename = "results.png"
		capture_requested = true
	elif "--capture-intro" in user_args:
		launch_charge = 0.78
		launch_power = launch_quality_for_charge(launch_charge)
		launch_hold_ratio = log(1.0 + launch_charge * (exp(LAUNCH_EXPONENT) - 1.0)) / LAUNCH_EXPONENT
		launch_overcharged = false
		configure_intro_animation()
		start_intro()
		intro_time = intro_push_duration + INTRO_JUMP_TIME * 0.42
		capture_filename = "intro.png"
		capture_requested = true
	elif "--capture-push" in user_args:
		launch_charge = 0.52
		launch_power = launch_quality_for_charge(launch_charge)
		launch_hold_ratio = log(1.0 + launch_charge * (exp(LAUNCH_EXPONENT) - 1.0)) / LAUNCH_EXPONENT
		launch_overcharged = false
		configure_intro_animation()
		start_intro()
		intro_time = intro_push_duration * 0.58
		capture_filename = "launch_push.png"
		capture_requested = true
	elif "--capture-overcharge" in user_args:
		launch_charge = 0.96
		launch_power = launch_quality_for_charge(launch_charge)
		launch_hold_ratio = log(1.0 + launch_charge * (exp(LAUNCH_EXPONENT) - 1.0)) / LAUNCH_EXPONENT
		launch_overcharged = true
		configure_intro_animation()
		start_intro()
		intro_time = intro_action_end + 0.40
		capture_filename = "launch_overcharge.png"
		capture_requested = true
	elif "--capture-victory" in user_args:
		state = State.VICTORY
		state_time = 1.5
		capture_filename = "victory.png"
		capture_requested = true
	if "--touch-preview" in user_args and state == State.PLAYING:
		touch_steering_active = true
		joystick_target_axis = 0.82
		joystick_visual_axis = 0.82
	queue_redraw()


func _process(delta: float) -> void:
	state_time += delta
	hit_flash = maxf(0.0, hit_flash - delta)
	var joystick_goal := joystick_target_axis if touch_steering_active and state == State.PLAYING else 0.0
	joystick_visual_axis = move_toward(joystick_visual_axis, joystick_goal, delta * 7.5)
	update_particles(delta)

	match state:
		State.CHARGING:
			var time_ratio := clampf(state_time / LAUNCH_FULL_TIME, 0.0, 1.0)
			launch_charge = (exp(LAUNCH_EXPONENT * time_ratio) - 1.0) / (exp(LAUNCH_EXPONENT) - 1.0)
		State.INTRO:
			update_intro(delta)
		State.PLAYING:
			update_playing(delta)
		State.RETURNING:
			world_scroll -= 360.0 * delta
			if state_time >= 2.25:
				finish_run()
		State.VICTORY:
			world_scroll += 150.0 * delta

	if capture_requested:
		capture_frames += 1
		if capture_frames == 8:
			DirAccess.make_dir_absolute(ProjectSettings.globalize_path("res://artifacts"))
			var image := get_viewport().get_texture().get_image()
			var result := image.save_png("res://artifacts/%s" % capture_filename)
			print("CAPTURE_RESULT=", result)
			get_tree().quit()

	queue_redraw()


func update_intro(delta: float) -> void:
	intro_time += delta
	if intro_time <= intro_push_duration:
		var push_ratio := clampf(intro_time / intro_push_duration, 0.0, 1.0)
		var acceleration := pow(push_ratio, 1.35)
		intro_raft_speed = lerpf(42.0, intro_push_peak_speed, acceleration)
	elif launch_overcharged and intro_time <= intro_action_end:
		var miss_ratio := inverse_lerp(intro_push_duration, intro_action_end, intro_time)
		intro_raft_speed = lerpf(intro_push_peak_speed, launch_cruise_speed, smoothstep(0.0, 1.0, miss_ratio))
	else:
		intro_raft_speed = launch_cruise_speed
	world_scroll += intro_raft_speed * delta

	if intro_time >= intro_duration:
		raft_forward_speed = launch_cruise_speed
		begin_run(true)


func update_playing(delta: float) -> void:
	var speed := advance_world(delta)

	var keyboard_axis := 0.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		keyboard_axis -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		keyboard_axis += 1.0
	if keyboard_axis != 0.0:
		target_x = raft_x + keyboard_axis * 390.0 * delta

	raft_x = move_toward(raft_x, target_x, (540.0 + raft_level * 35.0) * delta)
	raft_x = clampf(raft_x, 88.0, VIEW_SIZE.x - 88.0)
	target_x = clampf(target_x, 88.0, VIEW_SIZE.x - 88.0)

	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_object()
		spawn_timer = rng.randf_range(0.42, 0.66)

	for index in range(obstacles.size() - 1, -1, -1):
		var obstacle := obstacles[index]
		obstacle["position"].y += speed * delta
		obstacle["rotation"] += obstacle["spin"] * delta
		if obstacle["position"].y > VIEW_SIZE.y + 80.0:
			obstacles.remove_at(index)
			continue
		if obstacle["position"].distance_to(Vector2(raft_x, RAFT_Y)) < 82.0:
			obstacles.remove_at(index)
			hit_obstacle()

	for index in range(pickups.size() - 1, -1, -1):
		var pickup := pickups[index]
		pickup["position"].y += speed * delta
		pickup["rotation"] += delta * 1.8
		if pickup["position"].y > VIEW_SIZE.y + 60.0:
			pickups.remove_at(index)
			continue
		if pickup["position"].distance_to(Vector2(raft_x, RAFT_Y)) < 74.0:
			collect_pickup(pickup)
			pickups.remove_at(index)

	if distance_m >= run_target_distance:
		distance_m = run_target_distance
		if raft_level >= 3 and launch_is_perfect:
			begin_victory()
		else:
			begin_return("THE CURRENT IS TOO STRONG")


func advance_world(delta: float) -> float:
	var progress := clampf(distance_m / maxf(run_target_distance, 1.0), 0.0, 1.0)
	var limit_slowdown := smoothstep(0.78, 1.0, progress)
	var limit_speed := launch_cruise_speed * lerpf(1.0, 0.22, limit_slowdown)
	raft_forward_speed = minf(raft_forward_speed, limit_speed)
	var speed := raft_forward_speed
	world_scroll += speed * delta
	var distance_rate := lerpf(6.2, 15.5, pow(clampf(launch_power, 0.0, 1.0), 0.72))
	distance_rate += float(raft_level - 1) * 0.55
	distance_m += distance_rate * lerpf(1.0, 0.34, limit_slowdown) * delta
	return speed


func spawn_object() -> void:
	var position := Vector2(rng.randf_range(100.0, VIEW_SIZE.x - 100.0), -70.0)
	var difficulty := clampf(distance_m / run_target_distance, 0.0, 1.0)
	var obstacle_chance := 0.24 + difficulty * 0.18
	if rng.randf() < obstacle_chance:
		obstacles.append({
			"position": position,
			"rotation": rng.randf_range(0.0, TAU),
			"spin": rng.randf_range(-0.8, 0.8),
			"size": rng.randf_range(0.85, 1.2),
		})
	else:
		var kind := "part" if rng.randf() < 0.38 else "coin"
		pickups.append({
			"position": position,
			"kind": kind,
			"rotation": rng.randf_range(-0.2, 0.2),
		})


func hit_obstacle() -> void:
	raft_health -= 1
	hit_flash = 0.32
	burst(Vector2(raft_x, RAFT_Y), COLOR_CORAL, 18)
	if raft_health <= 0:
		begin_return("THE RAFT BROKE")


func collect_pickup(pickup: Dictionary) -> void:
	if pickup["kind"] == "coin":
		run_coins += 1
		burst(pickup["position"], COLOR_COIN, 9)
	else:
		run_parts += 1
		burst(pickup["position"], COLOR_WOOD.lightened(0.2), 9)


func burst(position: Vector2, color: Color, amount: int) -> void:
	for index in amount:
		var angle := rng.randf_range(0.0, TAU)
		var force := rng.randf_range(45.0, 145.0)
		particles.append({
			"position": position,
			"velocity": Vector2.from_angle(angle) * force,
			"life": rng.randf_range(0.3, 0.75),
			"max_life": 0.75,
			"color": color,
		})


func update_particles(delta: float) -> void:
	for index in range(particles.size() - 1, -1, -1):
		var particle := particles[index]
		particle["life"] -= delta
		if particle["life"] <= 0.0:
			particles.remove_at(index)
			continue
		particle["position"] += particle["velocity"] * delta
		particle["velocity"] *= 0.94
		particles[index] = particle


func start_intro() -> void:
	state = State.INTRO
	state_time = 0.0
	intro_time = 0.0
	distance_m = 0.0
	world_scroll = 0.0
	run_coins = 0
	run_parts = 0
	banked_this_run = false
	raft_health = raft_level
	raft_x = VIEW_SIZE.x * 0.5
	target_x = raft_x
	spawn_timer = 0.35
	intro_raft_speed = 0.0
	raft_forward_speed = launch_cruise_speed
	obstacles.clear()
	pickups.clear()
	particles.clear()


func start_charging() -> void:
	if state != State.HOME:
		return
	state = State.CHARGING
	state_time = 0.0
	launch_charge = 0.0
	launch_feedback = ""
	launch_overcharged = false


func release_launch() -> void:
	if state != State.CHARGING:
		return
	launch_hold_ratio = log(1.0 + clampf(launch_charge, 0.0, 1.0) * (exp(LAUNCH_EXPONENT) - 1.0)) / LAUNCH_EXPONENT
	launch_overcharged = launch_charge >= LAUNCH_BLACK_START
	launch_is_perfect = absf(launch_charge - LAUNCH_IDEAL_CENTER) <= LAUNCH_IDEAL_HALF_WIDTH
	launch_power = launch_quality_for_charge(launch_charge)
	if launch_overcharged:
		launch_feedback = "OVERCHARGED! WEAK PUSH"
	elif launch_is_perfect:
		launch_feedback = "PERFECT LAUNCH!"
	elif launch_charge >= LAUNCH_GREEN_START:
		launch_feedback = "GOOD LAUNCH"
	elif launch_charge >= 0.30:
		launch_feedback = "DECENT PUSH"
	else:
		launch_feedback = "WEAK PUSH"
	var raft_maximum := max_distance_for_level(raft_level)
	run_target_distance = roundf(lerpf(minf(12.0, raft_maximum), raft_maximum, launch_power))
	configure_intro_animation()
	pointer_active = false
	start_intro()


func configure_intro_animation() -> void:
	var push_factor := pow(clampf(launch_hold_ratio, 0.0, 1.0), 1.18)
	intro_push_duration = lerpf(INTRO_PUSH_MIN_TIME, INTRO_PUSH_MAX_TIME, push_factor)
	intro_push_peak_speed = launch_speed_for_hold(launch_hold_ratio)
	launch_cruise_speed = launch_speed_for_power(launch_power, true) if launch_overcharged else intro_push_peak_speed
	if launch_overcharged:
		intro_action_end = intro_push_duration + INTRO_FAILED_JUMP_TIME
		intro_duration = intro_action_end + 1.05
	else:
		intro_action_end = intro_push_duration + INTRO_JUMP_TIME
		intro_duration = intro_action_end + INTRO_SETTLE_TIME


func launch_speed_for_power(power: float, failed_jump: bool) -> float:
	var safe_power := clampf(power, 0.0, 1.0)
	if failed_jump:
		return lerpf(120.0, 175.0, clampf(safe_power / 0.10, 0.0, 1.0))
	return lerpf(145.0, 820.0, pow(safe_power, 0.68)) + float(raft_level - 1) * 28.0


func launch_speed_for_hold(hold_ratio: float) -> float:
	return lerpf(145.0, 820.0, pow(clampf(hold_ratio, 0.0, 1.0), 1.35)) + float(raft_level - 1) * 28.0


func launch_quality_for_charge(charge: float) -> float:
	var safe_charge := clampf(charge, 0.0, 1.0)
	if safe_charge >= LAUNCH_BLACK_START:
		var black_progress := inverse_lerp(LAUNCH_BLACK_START, 1.0, safe_charge)
		return lerpf(0.10, 0.0, smoothstep(0.0, 1.0, black_progress))

	var normal_progress := clampf(safe_charge / LAUNCH_GREEN_START, 0.0, 1.0)
	var normal_quality := pow(normal_progress, 1.25) * 0.68
	var distance_from_ideal := absf(safe_charge - LAUNCH_IDEAL_CENTER)
	var sweet_spot := 1.0 - clampf(distance_from_ideal / 0.10, 0.0, 1.0)
	var perfect_boost := pow(sweet_spot, 4.0) * 0.32
	return clampf(normal_quality + perfect_boost, 0.0, 1.0)


func return_to_launch_screen() -> void:
	state = State.HOME
	state_time = 0.0
	reset_touch_joystick()
	launch_charge = 0.0
	launch_feedback = ""
	launch_overcharged = false
	launch_is_perfect = false
	launch_hold_ratio = 0.55


func begin_run(continue_from_intro: bool = false) -> void:
	state = State.PLAYING
	state_time = 0.0
	if not continue_from_intro:
		distance_m = 0.0
		world_scroll = 0.0
		run_coins = 0
		run_parts = 0
		banked_this_run = false
		raft_health = raft_level
		raft_x = VIEW_SIZE.x * 0.5
		target_x = raft_x
		intro_push_peak_speed = launch_speed_for_hold(launch_hold_ratio)
		launch_cruise_speed = launch_speed_for_power(launch_power, true) if launch_overcharged else intro_push_peak_speed
		raft_forward_speed = launch_cruise_speed
		obstacles.clear()
		pickups.clear()
	spawn_timer = 0.20


func begin_return(reason: String) -> void:
	if state != State.PLAYING:
		return
	state = State.RETURNING
	state_time = 0.0
	return_reason = reason
	pointer_active = false
	reset_touch_joystick()


func finish_run() -> void:
	bank_run()
	state = State.RESULTS
	state_time = 0.0


func bank_run() -> void:
	if banked_this_run:
		return
	total_coins += run_coins
	total_parts += run_parts
	banked_this_run = true
	save_progress()


func begin_victory() -> void:
	bank_run()
	state = State.VICTORY
	state_time = 0.0
	pointer_active = false
	reset_touch_joystick()
	obstacles.clear()
	pickups.clear()
	burst(Vector2(raft_x, RAFT_Y), COLOR_COIN, 30)


func reset_touch_joystick() -> void:
	touch_steering_active = false
	active_touch_index = -1
	joystick_target_axis = 0.0


func try_upgrade() -> void:
	if raft_level >= 3:
		return
	var cost := upgrade_cost(raft_level)
	if total_coins < cost.x or total_parts < cost.y:
		return
	total_coins -= int(cost.x)
	total_parts -= int(cost.y)
	raft_level += 1
	raft_health = raft_level
	save_progress()
	burst(upgrade_button.get_center(), COLOR_COIN, 24)


func max_distance_for_level(level: int) -> float:
	match level:
		1: return 75.0
		2: return 140.0
		_: return 215.0


func upgrade_cost(level: int) -> Vector2i:
	match level:
		1: return Vector2i(8, 2)
		2: return Vector2i(18, 5)
		_: return Vector2i.ZERO


func can_upgrade() -> bool:
	if raft_level >= 3:
		return false
	var cost := upgrade_cost(raft_level)
	return total_coins >= cost.x and total_parts >= cost.y


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			pointer_active = true
			handle_press(event.position)
			if state == State.PLAYING:
				touch_steering_active = true
				active_touch_index = event.index
				joystick_target_axis = steering_axis_for_touch(event.position.x)
		else:
			if state == State.CHARGING and pointer_active:
				release_launch()
			if event.index == active_touch_index:
				touch_steering_active = false
				active_touch_index = -1
				joystick_target_axis = 0.0
			pointer_active = false
	elif event is InputEventScreenDrag:
		if state == State.PLAYING:
			target_x = event.position.x
			if active_touch_index == -1 or event.index == active_touch_index:
				touch_steering_active = true
				active_touch_index = event.index
				joystick_target_axis = steering_axis_for_touch(event.position.x)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pointer_active = true
			handle_press(event.position)
		else:
			if state == State.CHARGING and pointer_active:
				release_launch()
			pointer_active = false
	elif event is InputEventMouseMotion and pointer_active and state == State.PLAYING:
		target_x = event.position.x
	elif event is InputEventKey and not event.echo:
		if event.keycode in [KEY_ENTER, KEY_SPACE]:
			if event.pressed:
				if state == State.HOME:
					start_charging()
				elif state == State.RESULTS:
					return_to_launch_screen()
				elif state == State.VICTORY:
					return_to_launch_screen()
			elif state == State.CHARGING:
				release_launch()
		elif event.pressed and event.keycode == KEY_U and state == State.RESULTS:
			try_upgrade()


func steering_axis_for_touch(touch_x: float) -> float:
	return clampf((touch_x - raft_x) / 165.0, -1.0, 1.0)


func handle_press(position: Vector2) -> void:
	match state:
		State.HOME:
			if launch_button.has_point(position):
				start_charging()
		State.PLAYING:
			target_x = position.x
		State.RESULTS:
			if again_button.has_point(position):
				return_to_launch_screen()
			elif upgrade_button.has_point(position):
				try_upgrade()
		State.VICTORY:
			if victory_button.has_point(position):
				return_to_launch_screen()


func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "coins", total_coins)
	config.set_value("progress", "parts", total_parts)
	config.set_value("progress", "raft_level", raft_level)
	config.save(SAVE_PATH)


func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	total_coins = maxi(0, int(config.get_value("progress", "coins", 0)))
	total_parts = maxi(0, int(config.get_value("progress", "parts", 0)))
	raft_level = clampi(int(config.get_value("progress", "raft_level", 1)), 1, 3)


func run_smoke_test() -> void:
	assert(max_distance_for_level(1) == 75.0)
	assert(upgrade_cost(1) == Vector2i(8, 2))
	raft_x = VIEW_SIZE.x * 0.5
	assert(steering_axis_for_touch(raft_x - 165.0) == -1.0)
	assert(steering_axis_for_touch(raft_x + 165.0) == 1.0)
	assert(launch_quality_for_charge(0.02) < 0.02)
	assert(launch_quality_for_charge(LAUNCH_IDEAL_CENTER) > 0.99)
	assert(launch_quality_for_charge(0.96) < 0.05)
	launch_hold_ratio = 0.15
	launch_power = 0.05
	launch_overcharged = false
	configure_intro_animation()
	var short_push_duration := intro_push_duration
	var weak_launch_speed := launch_cruise_speed
	launch_hold_ratio = 0.82
	launch_power = 0.95
	configure_intro_animation()
	assert(intro_push_duration > short_push_duration)
	assert(launch_cruise_speed > weak_launch_speed * 2.5)
	launch_power = 0.03
	launch_overcharged = true
	configure_intro_animation()
	assert(launch_cruise_speed < weak_launch_speed)
	assert(intro_push_peak_speed > launch_cruise_speed * 4.0)
	assert(intro_duration - intro_action_end >= 1.0)
	return_to_launch_screen()
	start_charging()
	assert(state == State.CHARGING)
	launch_charge = LAUNCH_IDEAL_CENTER
	release_launch()
	assert(state == State.INTRO)
	assert(launch_is_perfect)
	assert(is_equal_approx(run_target_distance, max_distance_for_level(raft_level)))
	intro_time = intro_action_end
	advance_world(0.10)
	var distance_after_launch := distance_m
	assert(distance_after_launch > 0.0)
	begin_run(true)
	assert(state == State.PLAYING)
	assert(is_equal_approx(distance_m, distance_after_launch))
	spawn_object()
	assert(obstacles.size() + pickups.size() == 1)
	run_coins = 3
	run_parts = 1
	begin_return("TEST")
	assert(state == State.RETURNING)
	print("SMOKE_TEST_OK")
	get_tree().quit()


func prepare_gameplay_capture() -> void:
	run_target_distance = max_distance_for_level(raft_level)
	begin_run()
	distance_m = 29.5
	run_coins = 7
	run_parts = 2
	raft_health = raft_level
	obstacles.append({
		"position": Vector2(185, 455), "rotation": 0.25, "spin": 0.0, "size": 1.1,
	})
	obstacles.append({
		"position": Vector2(555, 690), "rotation": -0.15, "spin": 0.0, "size": 0.9,
	})
	pickups.append({"position": Vector2(315, 585), "kind": "coin", "rotation": 0.0})
	pickups.append({"position": Vector2(475, 350), "kind": "part", "rotation": 0.25})
	spawn_timer = 99.0


func prepare_results_capture() -> void:
	state = State.RESULTS
	state_time = 0.0
	distance_m = 71.75
	run_coins = 9
	run_parts = 3
	total_coins = maxi(total_coins, 12)
	total_parts = maxi(total_parts, 4)
	return_reason = "THE CURRENT IS TOO STRONG"


func _draw() -> void:
	match state:
		State.HOME, State.CHARGING:
			draw_home()
		State.INTRO:
			draw_intro()
		State.PLAYING, State.RETURNING:
			draw_game()
		State.RESULTS:
			draw_results()
		State.VICTORY:
			draw_victory()
	draw_particles()


func draw_home() -> void:
	draw_ocean_background(0.0)
	draw_departing_island(0.0)
	var brace_offset := sin(state_time * 8.0) * 1.5 if state == State.CHARGING else 0.0
	draw_push_sprite(Vector2i(0, 0), Vector2(VIEW_SIZE.x * 0.5, 1190.0 + brace_offset), Vector2(170.0, 170.0))
	draw_top_raft(Vector2(VIEW_SIZE.x * 0.5, RAFT_Y), raft_level, raft_level, 1)

	draw_text_center("RAFT ESCAPE", 108, 56, Color.WHITE)
	draw_text_center("Simple playable prototype", 148, 24, Color("#c8f4f7"))
	draw_panel(Rect2(55, 190, 610, 490))
	draw_text_center("RAFT — LEVEL %d / 3" % raft_level, 255, 31, COLOR_INK)
	draw_text_center("Maximum range: %d m" % int(max_distance_for_level(raft_level)), 308, 24, COLOR_INK.lightened(0.12))
	draw_text_center("COINS  %d     |     PARTS  %d" % [total_coins, total_parts], 358, 23, COLOR_INK)
	if state == State.CHARGING:
		draw_text_center("Release as close to perfect green as you can!", 416, 19, COLOR_CORAL)
	else:
		draw_text_center("Hold the button or SPACE / ENTER to charge", 416, 19, Color("#45647a"))
	draw_launch_meter()
	var button_label := "RELEASE TO LAUNCH" if state == State.CHARGING else "HOLD TO LAUNCH"
	draw_button(launch_button, button_label, true, COLOR_CORAL)


func draw_launch_meter() -> void:
	var meter := Rect2(85, 460, 550, 50)
	var inner := Rect2(meter.position + Vector2(5, 5), meter.size - Vector2(10, 10))
	draw_rect(meter, COLOR_INK)
	var segment_count := 120
	var segment_width := inner.size.x / float(segment_count)
	for index in segment_count:
		var ratio := (float(index) + 0.5) / float(segment_count)
		var segment_rect := Rect2(inner.position + Vector2(float(index) * segment_width, 0), Vector2(segment_width + 1.0, inner.size.y))
		draw_rect(segment_rect, launch_meter_color(ratio))

	var unfilled_x := inner.position.x + inner.size.x * launch_charge
	if launch_charge < 1.0:
		draw_rect(Rect2(Vector2(unfilled_x, inner.position.y), Vector2(inner.end.x - unfilled_x, inner.size.y)), Color(0.02, 0.12, 0.18, 0.72))
	draw_line(Vector2(unfilled_x, meter.position.y - 5), Vector2(unfilled_x, meter.end.y + 5), Color.WHITE, 5)


func launch_meter_color(ratio: float) -> Color:
	var red := Color("#e63946")
	var yellow := Color("#ffd166")
	var green := Color("#43c86f")
	var black := Color("#050709")
	if ratio < LAUNCH_YELLOW_POINT:
		return red.lerp(yellow, smoothstep(0.0, LAUNCH_YELLOW_POINT, ratio))
	if ratio < LAUNCH_GREEN_START:
		return yellow.lerp(green, smoothstep(LAUNCH_YELLOW_POINT, LAUNCH_GREEN_START, ratio))
	if ratio < LAUNCH_BLACK_START:
		var ideal_glow := 1.0 - clampf(absf(ratio - LAUNCH_IDEAL_CENTER) / 0.10, 0.0, 1.0)
		return green.lightened(ideal_glow * 0.16)
	return green.lerp(black, smoothstep(LAUNCH_BLACK_START, 1.0, ratio))


func draw_intro() -> void:
	var t := intro_time
	draw_ocean_background(world_scroll)
	draw_departing_island(world_scroll)
	var wake_strength := lerpf(0.30, 1.04, clampf(inverse_lerp(120.0, 820.0, intro_raft_speed), 0.0, 1.0))

	if t < intro_push_duration:
		var push_ratio := clampf(t / intro_push_duration, 0.0, 1.0)
		var stride_rate := lerpf(9.0, 22.0, launch_hold_ratio)
		var stride_cell := Vector2i(0, 0)
		if t > 0.10:
			stride_cell = Vector2i(1, 0) if sin(t * stride_rate) >= 0.0 else Vector2i(0, 1)
		draw_raft_wake(Vector2(raft_x, RAFT_Y), wake_strength)
		draw_launch_splash(Vector2(raft_x, 1215.0), 0.58 + push_ratio * 0.28 + sin(t * stride_rate) * 0.06)
		draw_push_sprite(stride_cell, Vector2(raft_x, 1190.0), Vector2(170.0, 170.0))
		draw_top_raft(Vector2(raft_x, RAFT_Y), raft_level, raft_health, 1)
	elif launch_overcharged:
		draw_raft_wake(Vector2(raft_x, RAFT_Y), wake_strength)
		if t < intro_action_end:
			var miss_ratio := inverse_lerp(intro_push_duration, intro_action_end, t)
			draw_top_raft(Vector2(raft_x, RAFT_Y), raft_level, raft_health, 1)
			var miss_position := Vector2(
				raft_x + sin(miss_ratio * PI) * 28.0,
				lerpf(1182.0, 1118.0, sin(miss_ratio * PI * 0.72))
			)
			draw_top_person(miss_position, Color("#d99559"), Color("#f4a261"), miss_ratio, true)
		else:
			draw_launch_splash(Vector2(raft_x, 1204.0), 0.88)
			draw_push_sprite(Vector2i(1, 1), Vector2(raft_x, 1185.0), Vector2(174.0, 174.0))
			draw_top_raft(Vector2(raft_x, RAFT_Y), raft_level, raft_health, 1)
	else:
		draw_raft_wake(Vector2(raft_x, RAFT_Y), wake_strength)
		if t < intro_action_end:
			draw_top_raft(Vector2(raft_x, RAFT_Y), raft_level, raft_health, 1)
			var jump_ratio := inverse_lerp(intro_push_duration, intro_action_end, t)
			var jump_position := Vector2(
				raft_x + sin(jump_ratio * PI) * 30.0,
				lerpf(1182.0, 1042.0, smoothstep(0.0, 1.0, jump_ratio)) - sin(jump_ratio * PI) * 24.0
			)
			draw_top_person(jump_position, Color("#d99559"), Color("#f4a261"), jump_ratio, true)
		else:
			draw_top_raft(Vector2(raft_x, RAFT_Y), raft_level, raft_health, 2)

	if t < 0.90 and not launch_feedback.is_empty():
		var feedback_color := Color("#101316") if launch_overcharged else COLOR_COIN
		draw_text_center(launch_feedback, 120, 36, feedback_color)


func draw_game() -> void:
	draw_ocean_background(world_scroll)
	draw_departing_island(world_scroll)

	for pickup in pickups:
		draw_pickup(pickup)
	for obstacle in obstacles:
		draw_rock(obstacle)

	var return_offset := 0.0
	if state == State.RETURNING:
		return_offset = ease(clampf(state_time / 2.25, 0.0, 1.0), -1.8) * 105.0
	var wake_strength := lerpf(0.28, 1.05, clampf(inverse_lerp(90.0, 850.0, raft_forward_speed), 0.0, 1.0))
	draw_raft_wake(Vector2(raft_x, RAFT_Y + return_offset), wake_strength)
	if launch_overcharged:
		draw_launch_splash(Vector2(raft_x, RAFT_Y + return_offset + 166.0), 0.88)
		draw_push_sprite(Vector2i(1, 1), Vector2(raft_x, RAFT_Y + return_offset + 150.0), Vector2(174.0, 174.0))
		draw_top_raft(Vector2(raft_x, RAFT_Y + return_offset), raft_level, raft_health, 1)
	else:
		draw_top_raft(Vector2(raft_x, RAFT_Y + return_offset), raft_level, raft_health)

	if hit_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(1.0, 0.18, 0.15, hit_flash * 0.85))

	draw_game_hud()
	if touch_joystick_enabled and state == State.PLAYING:
		draw_touch_joystick()
	if state == State.RETURNING:
		draw_return_overlay()


func draw_touch_joystick() -> void:
	var center := Vector2(raft_x, RAFT_Y + 170.0)
	var tilt := clampf(joystick_visual_axis, -1.0, 1.0)
	var cap_center := center + Vector2(tilt * 36.0, -18.0 - absf(tilt) * 3.0)

	draw_circle(center + Vector2(0.0, 8.0), 61.0, Color(0.01, 0.08, 0.13, 0.34))
	draw_circle(center, 56.0, Color(0.04, 0.24, 0.33, 0.76))
	draw_circle(center, 43.0, Color(0.03, 0.14, 0.22, 0.76))
	draw_arc(center, 55.0, 0.0, TAU, 36, Color(0.44, 0.91, 0.92, 0.72), 4.0, true)
	draw_arc(center, 38.0, 0.0, TAU, 32, Color(0.02, 0.08, 0.12, 0.64), 3.0, true)

	draw_line(center + Vector2(0.0, 13.0), cap_center + Vector2(0.0, 8.0), Color(0.03, 0.08, 0.10, 0.68), 20.0, true)
	draw_line(center + Vector2(0.0, 10.0), cap_center + Vector2(0.0, 6.0), Color(0.53, 0.31, 0.18, 0.94), 12.0, true)

	draw_set_transform(cap_center, tilt * 0.30, Vector2(1.20, 0.78))
	draw_circle(Vector2(0.0, 5.0), 31.0, Color(0.03, 0.08, 0.10, 0.60))
	draw_circle(Vector2.ZERO, 29.0, Color(0.94, 0.35, 0.30, 0.96))
	draw_arc(Vector2.ZERO, 28.0, PI, TAU, 22, Color(1.0, 0.79, 0.56, 0.92), 4.0, true)
	draw_circle(Vector2(-8.0, -9.0), 5.0, Color(1.0, 0.93, 0.77, 0.82))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_ocean_background(scroll: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), COLOR_WATER)
	for row in 19:
		var y := fposmod(row * 78.0 + scroll * 0.42, VIEW_SIZE.y + 90.0) - 45.0
		var shift := 74.0 if row % 2 else 0.0
		for column in 6:
			var x := column * 148.0 + shift
			draw_arc(Vector2(x, y), 48, 0.18, PI - 0.18, 14, Color(0.35, 0.87, 0.91, 0.30), 3.5)
	for index in 36:
		var seed_value := float(index * 193 % 997)
		var x := fposmod(seed_value * 2.17, VIEW_SIZE.x)
		var y := fposmod(seed_value * 3.41 + scroll * 0.7, VIEW_SIZE.y + 60.0) - 30.0
		draw_circle(Vector2(x, y), 2.5, Color(0.8, 1.0, 1.0, 0.42))


func draw_departing_island(scroll: float) -> void:
	var island_y := 1420.0 + scroll * 0.88
	if island_y - 470.0 > VIEW_SIZE.y:
		return
	draw_texture_rect(ISLAND_SPRITE, Rect2(Vector2(360.0, island_y) - Vector2(470.0, 470.0), Vector2(940.0, 940.0)), false)


func draw_atlas_sprite(cell: Vector2i, position: Vector2, size: Vector2, rotation: float = 0.0) -> void:
	var cell_size := SPRITE_ATLAS.get_size() / 4.0
	var source_rect := Rect2(Vector2(cell.x, cell.y) * cell_size, cell_size)
	draw_set_transform(position, rotation, Vector2.ONE)
	draw_texture_rect_region(SPRITE_ATLAS, Rect2(-size * 0.5, size), source_rect)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_push_sprite(cell: Vector2i, position: Vector2, size: Vector2) -> void:
	var cell_size := LAUNCH_PUSH_ATLAS.get_size() / 2.0
	var source_rect := Rect2(Vector2(cell.x, cell.y) * cell_size, cell_size)
	draw_texture_rect_region(LAUNCH_PUSH_ATLAS, Rect2(position - size * 0.5, size), source_rect)


func draw_launch_splash(position: Vector2, scale_value: float) -> void:
	draw_atlas_sprite(Vector2i(3, 3), position, Vector2(116.0, 116.0) * scale_value, sin(state_time * 11.0) * 0.08)


func draw_raft_wake(position: Vector2, strength: float) -> void:
	draw_atlas_sprite(Vector2i(3, 2), position + Vector2(0, 112.0), Vector2(205.0, 225.0) * strength)


func draw_game_hud() -> void:
	draw_panel(Rect2(18, 18, 240, 112), Color(0.96, 0.97, 0.91, 0.93))
	draw_text("COINS %d" % run_coins, Vector2(36, 60), 20, COLOR_INK)
	draw_text("PARTS %d" % run_parts, Vector2(36, 104), 20, COLOR_INK)
	draw_text("RAFT %d" % raft_level, Vector2(170, 60), 17, COLOR_INK.lightened(0.12))
	draw_text("LIVES %d" % raft_health, Vector2(170, 104), 17, COLOR_CORAL)

	var bar := Rect2(280, 32, 420, 34)
	draw_rect(bar, Color(0.02, 0.19, 0.29, 0.72))
	var progress := clampf(distance_m / run_target_distance, 0.0, 1.0)
	draw_rect(Rect2(bar.position + Vector2(5, 5), Vector2((bar.size.x - 10) * progress, bar.size.y - 10)), COLOR_COIN)
	draw_string(ThemeDB.fallback_font, Vector2(bar.position.x, 104), "%d / %d m" % [int(distance_m), int(run_target_distance)], HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, 22, Color.WHITE)
	draw_text_center("SWIPE LEFT / RIGHT", 158, 18, Color.WHITE)
	if state == State.PLAYING and state_time < 2.2:
		var launch_alpha := clampf((2.2 - state_time) / 0.6, 0.0, 1.0)
		draw_text_center("LAUNCH RANGE: %d m" % int(run_target_distance), 198, 23, Color(1.0, 0.91, 0.45, launch_alpha))


func draw_return_overlay() -> void:
	for index in 7:
		var x := 54.0 + index * 102.0
		var y := fposmod(state_time * 470.0 + index * 135.0, 1050.0) + 150.0
		draw_line(Vector2(x, y - 42), Vector2(x, y + 35), Color(0.72, 0.96, 1.0, 0.65), 6)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 13, y + 18), Vector2(x + 13, y + 18), Vector2(x, y + 42)
		]), Color(0.72, 0.96, 1.0, 0.65))
	draw_rect(Rect2(45, 520, 630, 140), Color(0.02, 0.12, 0.2, 0.86))
	draw_text_center(return_reason, 580, 34, Color.WHITE)
	draw_text_center("The current is taking you back to the island...", 625, 20, Color("#bfe9ef"))


func draw_results() -> void:
	draw_ocean_background(world_scroll)
	draw_panel(Rect2(35, 70, 650, 1095))
	draw_text_center("BACK ON THE ISLAND", 145, 42, COLOR_INK)
	draw_text_center(return_reason, 190, 21, COLOR_CORAL)
	draw_text_center("You traveled  %d m" % int(distance_m), 265, 28, COLOR_INK)
	draw_text_center("Collected:   %d coins     %d parts" % [run_coins, run_parts], 322, 23, COLOR_INK.lightened(0.08))
	draw_text_center("Total:   %d coins     %d parts" % [total_coins, total_parts], 370, 21, Color("#45647a"))
	draw_top_raft(Vector2(360, 625), raft_level, raft_level)
	draw_button(again_button, "NEW LAUNCH", true, COLOR_WATER)

	if raft_level < 3:
		var cost := upgrade_cost(raft_level)
		var label := "UPGRADE  %d C / %d P" % [cost.x, cost.y]
		draw_button(upgrade_button, label, can_upgrade(), COLOR_CORAL)
	else:
		draw_button(upgrade_button, "MAX LEVEL RAFT", false, COLOR_CORAL)


func draw_victory() -> void:
	var sky_top := Color("#f6bd60")
	draw_rect(Rect2(0, 0, VIEW_SIZE.x, 650), sky_top)
	draw_circle(Vector2(580, 355), 74, Color("#fff1a8"))
	draw_rect(Rect2(0, 650, VIEW_SIZE.x, 630), COLOR_DEEP)
	for index in 15:
		var y := 680.0 + index * 40.0
		draw_line(Vector2(0, y), Vector2(VIEW_SIZE.x, y + sin(state_time + index) * 9.0), Color(0.35, 0.72, 0.78, 0.35), 3)
	var sail_y := lerpf(980.0, 720.0, clampf(state_time / 5.0, 0.0, 1.0))
	draw_raft_wake(Vector2(360, sail_y), 0.95)
	draw_top_raft(Vector2(360, sail_y + sin(state_time * 2.0) * 4.0), 3, 3, 2)
	draw_text_center("YOU ESCAPED!", 135, 54, Color.WHITE)
	draw_text_center("The raft beat the current and sailed to safety.", 190, 22, Color("#fff4d6"))
	draw_text_center("This is the end of the simple prototype.", 232, 19, COLOR_INK)
	draw_button(victory_button, "BACK TO THE ISLAND", true, COLOR_CORAL)


func draw_panel(rect: Rect2, color: Color = COLOR_PANEL) -> void:
	draw_rect(Rect2(rect.position + Vector2(8, 10), rect.size), Color(0.01, 0.12, 0.18, 0.28))
	draw_rect(rect, color)
	draw_rect(rect, COLOR_INK, false, 4)


func draw_button(rect: Rect2, label: String, enabled: bool, color: Color) -> void:
	var button_color := color if enabled else Color("#8fa3ad")
	draw_rect(Rect2(rect.position + Vector2(0, 7), rect.size), button_color.darkened(0.42))
	draw_rect(rect, button_color)
	draw_rect(rect, Color.WHITE if enabled else Color("#cbd3d6"), false, 3)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.64), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 25, Color.WHITE)


func draw_text(value: String, position: Vector2, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, position, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func draw_text_center(value: String, baseline_y: float, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(0, baseline_y), value, HORIZONTAL_ALIGNMENT_CENTER, VIEW_SIZE.x, font_size, color)


func draw_palm(position: Vector2, scale_value: float) -> void:
	draw_line(position, position + Vector2(15, -145) * scale_value, Color("#7f5539"), 18 * scale_value)
	var crown := position + Vector2(15, -145) * scale_value
	for angle in [-2.8, -2.25, -1.7, -1.15, -0.6, -0.05]:
		var end := crown + Vector2.from_angle(angle) * 82.0 * scale_value
		draw_line(crown, end, Color("#397b4a"), 15 * scale_value)


func draw_person(position: Vector2, skin: Color, shirt: Color, pose: String, flip: bool) -> void:
	var direction := -1.0 if flip else 1.0
	var head := position + Vector2(0, -56)
	var hip := position + Vector2(0, -17)
	var shoulder := position + Vector2(0, -40)
	if pose == "push":
		shoulder += Vector2(10 * direction, 2)
		head += Vector2(9 * direction, 2)
	draw_line(shoulder, hip, shirt, 18)
	draw_circle(head, 13, skin)
	draw_circle(head + Vector2(5 * direction, -2), 2.2, COLOR_INK)

	var left_hand := shoulder + Vector2(-21 * direction, 22)
	var right_hand := shoulder + Vector2(23 * direction, 20)
	var left_foot := hip + Vector2(-17, 36)
	var right_foot := hip + Vector2(18, 36)
	match pose:
		"push":
			left_hand = shoulder + Vector2(38 * direction, 2)
			right_hand = shoulder + Vector2(42 * direction, 15)
			left_foot = hip + Vector2(-25 * direction, 34)
			right_foot = hip + Vector2(18 * direction, 34)
		"jump":
			left_hand = shoulder + Vector2(-26 * direction, -28)
			right_hand = shoulder + Vector2(26 * direction, -31)
			left_foot = hip + Vector2(-24, 22)
			right_foot = hip + Vector2(24, 19)
		"sit":
			left_hand = shoulder + Vector2(-18, 18)
			right_hand = shoulder + Vector2(18, 18)
			left_foot = hip + Vector2(-23, 13)
			right_foot = hip + Vector2(23, 13)
		"wave":
			left_hand = shoulder + Vector2(-20 * direction, 18)
			right_hand = shoulder + Vector2(25 * direction, -32)

	draw_line(shoulder, left_hand, skin, 7)
	draw_line(shoulder, right_hand, skin, 7)
	draw_line(hip, left_foot, Color("#264653"), 8)
	draw_line(hip, right_foot, Color("#264653"), 8)
	draw_circle(left_hand, 4, skin)
	draw_circle(right_hand, 4, skin)


func draw_top_person(position: Vector2, _skin: Color, _shirt: Color, run_phase: float, airborne: bool = false) -> void:
	var cell := Vector2i(0, 0)
	if airborne:
		cell = Vector2i(3, 0)
	elif run_phase > 0.01:
		cell = Vector2i(1, 0) if sin(run_phase * TAU) >= 0.0 else Vector2i(2, 0)
	draw_atlas_sprite(cell, position, Vector2(116.0, 116.0))


func draw_side_raft(position: Vector2, bob: float, level: int) -> void:
	var pos := position + Vector2(0, bob)
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-92, -10), pos + Vector2(92, -10), pos + Vector2(68, 26), pos + Vector2(-72, 26)
	]), COLOR_WOOD.darkened(0.14))
	for plank in 5 + level:
		var x := -75.0 + plank * (150.0 / (4.0 + level))
		draw_line(pos + Vector2(x, -14), pos + Vector2(x + 5, 20), COLOR_WOOD.lightened(0.15), 10)
	if level >= 2:
		draw_line(pos + Vector2(7, -12), pos + Vector2(7, -130), Color("#68452d"), 8)
		draw_colored_polygon(PackedVector2Array([
			pos + Vector2(12, -125), pos + Vector2(12, -35), pos + Vector2(82, -48)
		]), Color("#f4f1de") if level == 2 else COLOR_CORAL.lightened(0.16))
	if level >= 3:
		draw_line(pos + Vector2(-80, -17), pos + Vector2(78, -17), COLOR_COIN, 5)


func draw_top_raft(position: Vector2, level: int, health: int, occupants: int = 2) -> void:
	var cell := Vector2i(0, 1)
	if health < level:
		cell = Vector2i(3, 1)
	elif occupants >= 2:
		cell = Vector2i(2, 1)
	elif occupants == 1:
		cell = Vector2i(1, 1)
	var sprite_size := 188.0 + float(level - 1) * 10.0
	draw_atlas_sprite(cell, position, Vector2(sprite_size, sprite_size))


func draw_pickup(pickup: Dictionary) -> void:
	var position: Vector2 = pickup["position"]
	if pickup["kind"] == "coin":
		draw_atlas_sprite(Vector2i(1, 2), position, Vector2(66.0, 66.0), pickup["rotation"])
	else:
		draw_atlas_sprite(Vector2i(2, 2), position, Vector2(92.0, 92.0), pickup["rotation"])


func draw_rock(obstacle: Dictionary) -> void:
	var position: Vector2 = obstacle["position"]
	var size: float = obstacle["size"]
	var rotation: float = obstacle["rotation"]
	draw_atlas_sprite(Vector2i(0, 2), position, Vector2(105.0, 105.0) * size, rotation)


func draw_particles() -> void:
	for particle in particles:
		var alpha: float = clampf(particle["life"] / particle["max_life"], 0.0, 1.0)
		var color: Color = particle["color"]
		color.a = alpha
		draw_circle(particle["position"], 4.5 * alpha + 1.5, color)
