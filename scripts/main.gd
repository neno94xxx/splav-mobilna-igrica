extends Node2D

enum State { HOME, CHARGING, INTRO, PLAYING, RETURNING, RESULTS, UPGRADES, VICTORY }

const VIEW_SIZE := Vector2(720.0, 1280.0)
const RAFT_Y := 1035.0
const SAVE_PATH := "user://save.cfg"
const SPRITE_ATLAS: Texture2D = preload("res://assets/sprites/raft_escape_atlas_v1.png")
const ISLAND_SPRITE: Texture2D = preload("res://assets/sprites/deserted_island_v1.png")
const LAUNCH_PUSH_ATLAS: Texture2D = preload("res://assets/sprites/launch_push_atlas_v1.png")
const GAMEPLAY_OCEAN_SCENE: PackedScene = preload("res://scenes/gameplay_ocean.tscn")
const RAFT_WAKE_TEXTURE: Texture2D = preload("res://assets/sea/splash1_optimized_v1.webp")
const RAFT_TURN_SPLASH_TEXTURE: Texture2D = preload("res://assets/sea/splash7_optimized_v1.webp")
const WORKSHOP_BACKGROUND_SCENE: PackedScene = preload("res://scenes/workshop_animated_background.tscn")
const WORKSHOP_BRANCHES_SCENE: PackedScene = preload("res://scenes/workshop_branches.tscn")
const WORKSHOP_RAFT_SCENE: PackedScene = preload("res://scenes/workshop_raft.tscn")
const NERD_PARTS_CUTOUT_SCENE: PackedScene = preload("res://scenes/nerd_parts_cutout.tscn")
const FAT_MAN_PARTS_CUTOUT_SCENE: PackedScene = preload("res://scenes/fat_man_parts_cutout.tscn")
const NERD_PARTS_SCALE := 1.03275
const NERD_PARTS_BASE_POSITION := Vector2(292.0, 690.0)
const FAT_MAN_PARTS_BASE_POSITION := Vector2(182.0, 410.0)
const WORKSHOP_RAFT_BASE_POSITION := Vector2(358.0, 960.0)
const SAIL_UPGRADE_ICON: Texture2D = preload("res://assets/sprites/sail_upgrade_triangle_v1.png")
const SHIELD_UPGRADE_ICON: Texture2D = preload("res://assets/sprites/shield_upgrade_v1.png")
const ROPE_SPRITE: Texture2D = preload("res://assets/sprites/rope_collectible_v1.png")
const BASE_RAFT_RANGE := 75.0
const SAIL_RANGE_BONUS := 28.0
const SAIL_MAX_LEVEL := 5
const PROTECTION_MAX_LEVEL := 4
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
const RESULT_TRANSFER_DELAY := 0.55
const RESULT_TRANSFER_MIN_INTERVAL := 0.055
const RESULT_TRANSFER_MAX_INTERVAL := 0.13
const RESULT_FLY_TIME := 0.62
const RESULT_BUTTON_REVEAL_TIME := 0.42
const RESULT_ROPE_SOURCE := Vector2(190.0, 395.0)
const RESULT_PLANK_SOURCE := Vector2(530.0, 395.0)
const RESULT_ROPE_TARGET := Vector2(285.0, 585.0)
const RESULT_PLANK_TARGET := Vector2(505.0, 585.0)

const COLOR_DEEP := Color("#083c5a")
const COLOR_WATER := Color("#087e9b")
const COLOR_WATER_LIGHT := Color("#23b5c7")
const COLOR_SAND := Color("#f2cc8f")
const COLOR_GRASS := Color("#67a357")
const COLOR_INK := Color("#17324d")
const COLOR_PANEL := Color("#f7f1df")
const COLOR_ROPE := Color("#ead8b4")
const COLOR_WOOD := Color("#a96942")
const COLOR_CORAL := Color("#ef6f6c")

var state: int = State.HOME
var state_time := 0.0
var intro_time := 0.0
var world_scroll := 0.0
var distance_m := 0.0
var run_rope := 0
var run_planks := 0
var total_rope := 0
var total_planks := 0
var raft_level := 1
var sail_level := 0
var protection_level := 0
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
var raft_steer_visual := 0.0
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
var upgrade_feedback := ""
var upgrade_feedback_time := 0.0
var upgrade_info_open := -1
var result_rope_to_launch := 0
var result_planks_to_launch := 0
var result_display_rope := 0
var result_display_planks := 0
var result_launch_cooldown := 0.0
var result_launch_interval := RESULT_TRANSFER_MAX_INTERVAL
var result_next_is_rope := true
var result_sequence_complete := true
var result_button_reveal := 1.0
var result_rope_flash := 0.0
var result_plank_flash := 0.0
var gameplay_ocean: Node2D
var workshop_preview_background: Node2D
var workshop_branches_rig: Node2D
var workshop_raft_preview: Node2D
var workshop_character_rig: Node2D
var workshop_fat_man_rig: Node2D
var workshop_animation_time_override := -1.0

var obstacles: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var result_flyers: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

var launch_button := Rect2(110, 555, 500, 102)
var again_button := Rect2(100, 895, 520, 88)
var upgrade_button := Rect2(100, 1010, 520, 88)
var sail_upgrade_button := Rect2(450, 271, 234, 34)
var protection_upgrade_button := Rect2(450, 417, 234, 34)
var sail_info_button := Rect2(648, 187, 38, 38)
var protection_info_button := Rect2(648, 333, 38, 38)
var upgrade_back_button := Rect2(370, 930, 300, 66)
var victory_button := Rect2(120, 1100, 480, 88)


func _ready() -> void:
	rng.randomize()
	load_progress()
	setup_gameplay_ocean()
	setup_workshop_background()
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
	elif "--capture-results-animation" in user_args:
		prepare_results_animation_capture()
		capture_filename = "results_animation.png"
		capture_requested = true
	elif "--capture-upgrades" in user_args:
		state = State.UPGRADES
		total_rope = maxi(total_rope, 25)
		total_planks = maxi(total_planks, 8)
		capture_filename = "upgrades.png"
		capture_requested = true
	elif "--capture-upgrades-info" in user_args:
		state = State.UPGRADES
		total_rope = maxi(total_rope, 25)
		total_planks = maxi(total_planks, 8)
		upgrade_info_open = 0
		capture_filename = "upgrades_info.png"
		capture_requested = true
	elif "--capture-upgrades-water-late" in user_args:
		state = State.UPGRADES
		total_rope = maxi(total_rope, 25)
		total_planks = maxi(total_planks, 8)
		capture_frames = -112
		capture_filename = "upgrades_water_late.png"
		capture_requested = true
	elif "--capture-upgrades-animation" in user_args:
		state = State.UPGRADES
		state_time = 1.85
		workshop_animation_time_override = 1.85
		capture_frames = 5
		total_rope = maxi(total_rope, 25)
		total_planks = maxi(total_planks, 8)
		capture_filename = "upgrades_animation.png"
		capture_requested = true
	elif "--capture-upgrades-head" in user_args:
		state = State.UPGRADES
		state_time = 3.50
		workshop_animation_time_override = 3.50
		total_rope = maxi(total_rope, 25)
		total_planks = maxi(total_planks, 8)
		capture_filename = "upgrades_head_turn.png"
		capture_requested = true
	elif "--capture-upgrades-hit" in user_args:
		state = State.UPGRADES
		state_time = 2.675
		workshop_animation_time_override = 2.675
		capture_frames = 5
		total_rope = maxi(total_rope, 25)
		total_planks = maxi(total_planks, 8)
		capture_filename = "upgrades_hammer_hit.png"
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
	update_workshop_background()
	queue_redraw()


func _process(delta: float) -> void:
	state_time += delta
	update_workshop_background()
	hit_flash = maxf(0.0, hit_flash - delta)
	upgrade_feedback_time = maxf(0.0, upgrade_feedback_time - delta)
	var joystick_goal := joystick_target_axis if touch_steering_active and state == State.PLAYING else 0.0
	joystick_visual_axis = move_toward(joystick_visual_axis, joystick_goal, delta * 7.5)
	if state != State.PLAYING:
		raft_steer_visual = move_toward(raft_steer_visual, 0.0, delta * 5.0)
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
		State.RESULTS:
			update_results(delta)
		State.VICTORY:
			world_scroll += 150.0 * delta
	update_gameplay_ocean()

	if capture_requested:
		capture_frames += 1
		if capture_frames == 8:
			DirAccess.make_dir_absolute(ProjectSettings.globalize_path("res://artifacts"))
			var image := get_viewport().get_texture().get_image()
			var result := image.save_png("res://artifacts/%s" % capture_filename)
			print("CAPTURE_RESULT=", result)
			get_tree().quit()

	queue_redraw()


func setup_gameplay_ocean() -> void:
	gameplay_ocean = GAMEPLAY_OCEAN_SCENE.instantiate() as Node2D
	gameplay_ocean.name = "GameplayOcean"
	gameplay_ocean.show_behind_parent = true
	gameplay_ocean.z_index = -200
	add_child(gameplay_ocean)


func update_gameplay_ocean() -> void:
	if not is_instance_valid(gameplay_ocean):
		return
	var ocean_scroll := 0.0 if state == State.HOME or state == State.CHARGING else world_scroll
	gameplay_ocean.call("set_travel", ocean_scroll)


func setup_workshop_background() -> void:
	workshop_preview_background = WORKSHOP_BACKGROUND_SCENE.instantiate() as Node2D
	workshop_preview_background.name = "WorkshopPreviewBackground"
	workshop_preview_background.show_behind_parent = true
	workshop_preview_background.z_index = -100
	add_child(workshop_preview_background)

	workshop_branches_rig = WORKSHOP_BRANCHES_SCENE.instantiate() as Node2D
	workshop_branches_rig.name = "WorkshopBranchesPreview"
	workshop_branches_rig.show_behind_parent = true
	workshop_branches_rig.z_index = -94
	add_child(workshop_branches_rig)

	workshop_character_rig = NERD_PARTS_CUTOUT_SCENE.instantiate() as Node2D
	workshop_character_rig.name = "NerdPartsCutoutPreview"
	workshop_character_rig.position = NERD_PARTS_BASE_POSITION
	workshop_character_rig.scale = Vector2.ONE * NERD_PARTS_SCALE
	workshop_character_rig.show_behind_parent = true
	workshop_character_rig.z_index = -90
	add_child(workshop_character_rig)

	workshop_fat_man_rig = FAT_MAN_PARTS_CUTOUT_SCENE.instantiate() as Node2D
	workshop_fat_man_rig.name = "FatManPartsCutoutPreview"
	workshop_fat_man_rig.position = FAT_MAN_PARTS_BASE_POSITION
	workshop_fat_man_rig.show_behind_parent = true
	workshop_fat_man_rig.z_index = -95
	add_child(workshop_fat_man_rig)

	workshop_raft_preview = WORKSHOP_RAFT_SCENE.instantiate() as Node2D
	workshop_raft_preview.name = "WorkshopRaftPreview"
	workshop_raft_preview.position = WORKSHOP_RAFT_BASE_POSITION
	workshop_raft_preview.show_behind_parent = true
	workshop_raft_preview.z_index = -89
	add_child(workshop_raft_preview)


func update_workshop_background() -> void:
	if not is_instance_valid(workshop_preview_background) or not is_instance_valid(workshop_branches_rig) or not is_instance_valid(workshop_raft_preview) or not is_instance_valid(workshop_character_rig) or not is_instance_valid(workshop_fat_man_rig):
		return
	var is_visible := state == State.UPGRADES
	workshop_preview_background.visible = is_visible
	workshop_branches_rig.visible = is_visible
	workshop_raft_preview.visible = is_visible
	workshop_character_rig.visible = is_visible
	workshop_fat_man_rig.visible = is_visible
	if is_visible and workshop_animation_time_override >= 0.0:
		workshop_branches_rig.call("seek_preview", workshop_animation_time_override)
		workshop_character_rig.call("seek_preview", workshop_animation_time_override)
		workshop_fat_man_rig.call("seek_preview", workshop_animation_time_override)


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

	var steer_goal := keyboard_axis
	if touch_steering_active:
		steer_goal = joystick_target_axis
	elif is_zero_approx(steer_goal):
		steer_goal = clampf((target_x - raft_x) / 105.0, -1.0, 1.0)
	raft_steer_visual = move_toward(raft_steer_visual, steer_goal, delta * 6.5)

	raft_x = move_toward(raft_x, target_x, 540.0 * delta)
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
		if sail_level >= SAIL_MAX_LEVEL and launch_is_perfect:
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
		var kind := "plank" if rng.randf() < 0.38 else "rope"
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
	if pickup["kind"] == "rope":
		run_rope += 1
		burst(pickup["position"], COLOR_ROPE, 9)
	else:
		run_planks += 1
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
	run_rope = 0
	run_planks = 0
	banked_this_run = false
	raft_health = maximum_raft_health()
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
	var raft_maximum := current_max_distance()
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
	return lerpf(145.0, 820.0, pow(safe_power, 0.68))


func launch_speed_for_hold(hold_ratio: float) -> float:
	return lerpf(145.0, 820.0, pow(clampf(hold_ratio, 0.0, 1.0), 1.35))


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
		run_rope = 0
		run_planks = 0
		banked_this_run = false
		raft_health = maximum_raft_health()
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
	state = State.RESULTS
	state_time = 0.0
	prepare_result_sequence()


func prepare_result_sequence() -> void:
	result_display_rope = total_rope
	result_display_planks = total_planks
	result_rope_to_launch = run_rope
	result_planks_to_launch = run_planks
	var resource_count := result_rope_to_launch + result_planks_to_launch
	result_launch_interval = clampf(2.7 / maxf(float(resource_count), 1.0), RESULT_TRANSFER_MIN_INTERVAL, RESULT_TRANSFER_MAX_INTERVAL)
	result_launch_cooldown = 0.0
	result_next_is_rope = true
	result_sequence_complete = false
	result_button_reveal = 0.0
	result_rope_flash = 0.0
	result_plank_flash = 0.0
	result_flyers.clear()
	# Bank immediately so closing the game during the animation never loses loot.
	bank_run()


func update_results(delta: float) -> void:
	result_rope_flash = maxf(0.0, result_rope_flash - delta * 3.8)
	result_plank_flash = maxf(0.0, result_plank_flash - delta * 3.8)

	for index in range(result_flyers.size() - 1, -1, -1):
		var flyer := result_flyers[index]
		flyer["time"] += delta
		if flyer["time"] >= flyer["duration"]:
			if flyer["kind"] == "rope":
				result_display_rope += 1
				result_rope_flash = 1.0
				burst(RESULT_ROPE_TARGET, Color("#fff1c9"), 5)
			else:
				result_display_planks += 1
				result_plank_flash = 1.0
				burst(RESULT_PLANK_TARGET, COLOR_WOOD.lightened(0.28), 5)
			result_flyers.remove_at(index)
		else:
			result_flyers[index] = flyer

	if not result_sequence_complete and state_time >= RESULT_TRANSFER_DELAY:
		result_launch_cooldown -= delta
		while result_launch_cooldown <= 0.0 and (result_rope_to_launch > 0 or result_planks_to_launch > 0):
			launch_next_result_resource()
			result_launch_cooldown += result_launch_interval

		if result_rope_to_launch == 0 and result_planks_to_launch == 0 and result_flyers.is_empty():
			result_display_rope = total_rope
			result_display_planks = total_planks
			result_sequence_complete = true
			result_button_reveal = 0.0

	if result_sequence_complete:
		result_button_reveal = minf(1.0, result_button_reveal + delta / RESULT_BUTTON_REVEAL_TIME)


func launch_next_result_resource() -> void:
	var kind := "rope"
	if result_next_is_rope and result_rope_to_launch > 0:
		result_rope_to_launch -= 1
		kind = "rope"
	elif result_planks_to_launch > 0:
		result_planks_to_launch -= 1
		kind = "plank"
	else:
		result_rope_to_launch -= 1
		kind = "rope"
	result_next_is_rope = not result_next_is_rope

	var start := RESULT_ROPE_SOURCE if kind == "rope" else RESULT_PLANK_SOURCE
	var target := RESULT_ROPE_TARGET if kind == "rope" else RESULT_PLANK_TARGET
	result_flyers.append({
		"kind": kind,
		"time": 0.0,
		"duration": RESULT_FLY_TIME,
		"start": start,
		"target": target,
		"spin": rng.randf_range(-1.15, 1.15),
		"arc": rng.randf_range(105.0, 155.0),
	})


func results_actions_ready() -> bool:
	return result_sequence_complete and result_button_reveal >= 0.86


func bank_run() -> void:
	if banked_this_run:
		return
	total_rope += run_rope
	total_planks += run_planks
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
	burst(Vector2(raft_x, RAFT_Y), COLOR_ROPE, 30)


func reset_touch_joystick() -> void:
	touch_steering_active = false
	active_touch_index = -1
	joystick_target_axis = 0.0


func open_upgrade_screen() -> void:
	state = State.UPGRADES
	state_time = 0.0
	pointer_active = false
	upgrade_info_open = -1
	upgrade_feedback = ""
	upgrade_feedback_time = 0.0
	workshop_branches_rig.call("restart_animation")
	workshop_character_rig.call("restart_animation")
	workshop_fat_man_rig.call("restart_animation")


func close_upgrade_screen() -> void:
	state = State.RESULTS
	state_time = 0.0
	pointer_active = false
	upgrade_info_open = -1
	result_display_rope = total_rope
	result_display_planks = total_planks
	result_sequence_complete = true
	result_button_reveal = 1.0


func try_purchase_sail() -> void:
	if sail_level >= SAIL_MAX_LEVEL:
		show_upgrade_feedback("SAIL IS ALREADY MAXED", false)
		return
	var cost := sail_upgrade_cost(sail_level)
	if not can_pay(cost):
		show_upgrade_feedback("NOT ENOUGH MATERIALS", false)
		return
	total_rope -= cost.x
	total_planks -= cost.y
	sail_level += 1
	sync_visual_raft_level()
	save_progress()
	burst(sail_upgrade_button.get_center(), COLOR_ROPE, 24)
	show_upgrade_feedback("SAIL UPGRADED  +%d m" % int(SAIL_RANGE_BONUS), true)


func try_purchase_protection() -> void:
	if protection_level >= PROTECTION_MAX_LEVEL:
		show_upgrade_feedback("PROTECTION IS ALREADY MAXED", false)
		return
	var cost := protection_upgrade_cost(protection_level)
	if not can_pay(cost):
		show_upgrade_feedback("NOT ENOUGH MATERIALS", false)
		return
	total_rope -= cost.x
	total_planks -= cost.y
	protection_level += 1
	raft_health = maximum_raft_health()
	sync_visual_raft_level()
	save_progress()
	burst(protection_upgrade_button.get_center(), COLOR_ROPE, 24)
	show_upgrade_feedback("PROTECTION UPGRADED  +1 SAFE HIT", true)


func show_upgrade_feedback(message: String, success: bool) -> void:
	upgrade_feedback = message
	upgrade_feedback_time = 2.0 if success else 1.4


func current_max_distance() -> float:
	return max_distance_for_sail(sail_level)


func max_distance_for_sail(level: int) -> float:
	return BASE_RAFT_RANGE + float(clampi(level, 0, SAIL_MAX_LEVEL)) * SAIL_RANGE_BONUS


func maximum_raft_health() -> int:
	return 1 + protection_level


func sync_visual_raft_level() -> void:
	var strongest_upgrade := maxi(sail_level, protection_level)
	raft_level = clampi(1 + int(strongest_upgrade / 2), 1, 3)


func sail_upgrade_cost(level: int) -> Vector2i:
	match level:
		0: return Vector2i(6, 2)
		1: return Vector2i(12, 4)
		2: return Vector2i(22, 7)
		3: return Vector2i(36, 11)
		4: return Vector2i(55, 16)
		_: return Vector2i.ZERO


func protection_upgrade_cost(level: int) -> Vector2i:
	match level:
		0: return Vector2i(8, 3)
		1: return Vector2i(16, 5)
		2: return Vector2i(28, 9)
		3: return Vector2i(44, 14)
		_: return Vector2i.ZERO


func can_pay(cost: Vector2i) -> bool:
	return total_rope >= cost.x and total_planks >= cost.y


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
				elif state == State.RESULTS and results_actions_ready():
					return_to_launch_screen()
				elif state == State.UPGRADES:
					close_upgrade_screen()
				elif state == State.VICTORY:
					return_to_launch_screen()
			elif state == State.CHARGING:
				release_launch()
		elif event.pressed and event.keycode == KEY_U and state == State.RESULTS and results_actions_ready():
			open_upgrade_screen()
		elif event.pressed and event.keycode == KEY_ESCAPE and state == State.UPGRADES:
			close_upgrade_screen()


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
			if not results_actions_ready():
				return
			if again_button.has_point(position):
				return_to_launch_screen()
			elif upgrade_button.has_point(position):
				open_upgrade_screen()
		State.UPGRADES:
			if sail_info_button.has_point(position):
				upgrade_info_open = -1 if upgrade_info_open == 0 else 0
			elif protection_info_button.has_point(position):
				upgrade_info_open = -1 if upgrade_info_open == 1 else 1
			elif sail_upgrade_button.has_point(position):
				try_purchase_sail()
			elif protection_upgrade_button.has_point(position):
				try_purchase_protection()
			elif upgrade_back_button.has_point(position):
				close_upgrade_screen()
			else:
				upgrade_info_open = -1
		State.VICTORY:
			if victory_button.has_point(position):
				return_to_launch_screen()


func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "rope", total_rope)
	config.set_value("progress", "planks", total_planks)
	config.set_value("progress", "raft_level", raft_level)
	config.set_value("progress", "sail_level", sail_level)
	config.set_value("progress", "protection_level", protection_level)
	config.save(SAVE_PATH)


func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	# Existing players keep everything they collected before the resource rename.
	total_rope = maxi(0, int(config.get_value("progress", "rope", config.get_value("progress", "coins", 0))))
	total_planks = maxi(0, int(config.get_value("progress", "planks", config.get_value("progress", "parts", 0))))
	if config.has_section_key("progress", "sail_level"):
		sail_level = clampi(int(config.get_value("progress", "sail_level", 0)), 0, SAIL_MAX_LEVEL)
		protection_level = clampi(int(config.get_value("progress", "protection_level", 0)), 0, PROTECTION_MAX_LEVEL)
	else:
		var legacy_level := clampi(int(config.get_value("progress", "raft_level", 1)), 1, 3)
		match legacy_level:
			2:
				sail_level = 2
				protection_level = 2
			3:
				sail_level = SAIL_MAX_LEVEL
				protection_level = PROTECTION_MAX_LEVEL
	sync_visual_raft_level()
	raft_health = maximum_raft_health()


func run_smoke_test() -> void:
	assert(max_distance_for_sail(0) == 75.0)
	assert(max_distance_for_sail(SAIL_MAX_LEVEL) == 215.0)
	assert(sail_upgrade_cost(0) == Vector2i(6, 2))
	assert(protection_upgrade_cost(0) == Vector2i(8, 3))
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
	assert(is_equal_approx(run_target_distance, current_max_distance()))
	intro_time = intro_action_end
	advance_world(0.10)
	var distance_after_launch := distance_m
	assert(distance_after_launch > 0.0)
	begin_run(true)
	assert(state == State.PLAYING)
	assert(is_equal_approx(distance_m, distance_after_launch))
	spawn_object()
	assert(obstacles.size() + pickups.size() == 1)
	run_rope = 3
	run_planks = 1
	begin_return("TEST")
	assert(state == State.RETURNING)
	state = State.RESULTS
	state_time = RESULT_TRANSFER_DELAY
	result_display_rope = 10
	result_display_planks = 5
	total_rope = 13
	total_planks = 7
	result_rope_to_launch = 3
	result_planks_to_launch = 2
	result_launch_interval = RESULT_TRANSFER_MIN_INTERVAL
	result_launch_cooldown = 0.0
	result_next_is_rope = true
	result_sequence_complete = false
	result_button_reveal = 0.0
	result_flyers.clear()
	for test_step in 30:
		update_results(0.1)
	assert(result_sequence_complete)
	assert(result_display_rope == total_rope)
	assert(result_display_planks == total_planks)
	assert(results_actions_ready())
	print("SMOKE_TEST_OK")
	get_tree().quit()


func prepare_gameplay_capture() -> void:
	run_target_distance = current_max_distance()
	begin_run()
	distance_m = 29.5
	run_rope = 7
	run_planks = 2
	raft_health = maximum_raft_health()
	obstacles.append({
		"position": Vector2(185, 455), "rotation": 0.25, "spin": 0.0, "size": 1.1,
	})
	obstacles.append({
		"position": Vector2(555, 690), "rotation": -0.15, "spin": 0.0, "size": 0.9,
	})
	pickups.append({"position": Vector2(315, 585), "kind": "rope", "rotation": 0.0})
	pickups.append({"position": Vector2(475, 350), "kind": "plank", "rotation": 0.25})
	spawn_timer = 99.0


func prepare_results_capture() -> void:
	state = State.RESULTS
	state_time = 2.0
	distance_m = 71.75
	run_rope = 9
	run_planks = 3
	total_rope = maxi(total_rope, 12)
	total_planks = maxi(total_planks, 4)
	result_display_rope = total_rope
	result_display_planks = total_planks
	result_rope_to_launch = 0
	result_planks_to_launch = 0
	result_flyers.clear()
	result_sequence_complete = true
	result_button_reveal = 1.0
	return_reason = "THE CURRENT IS TOO STRONG"


func prepare_results_animation_capture() -> void:
	state = State.RESULTS
	state_time = 1.15
	distance_m = 71.75
	run_rope = 9
	run_planks = 3
	total_rope = maxi(total_rope, 21)
	total_planks = maxi(total_planks, 8)
	result_display_rope = total_rope - 4
	result_display_planks = total_planks - 2
	result_rope_to_launch = 2
	result_planks_to_launch = 1
	result_launch_interval = 0.13
	result_launch_cooldown = 0.08
	result_next_is_rope = true
	result_sequence_complete = false
	result_button_reveal = 0.0
	result_flyers = [
		{"kind": "rope", "time": 0.22, "duration": RESULT_FLY_TIME, "start": RESULT_ROPE_SOURCE, "target": RESULT_ROPE_TARGET, "spin": 0.7, "arc": 140.0},
		{"kind": "plank", "time": 0.08, "duration": RESULT_FLY_TIME, "start": RESULT_PLANK_SOURCE, "target": RESULT_PLANK_TARGET, "spin": -0.55, "arc": 125.0},
	]
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
		State.UPGRADES:
			draw_upgrades()
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
	draw_text_center("SAIL %d / %d    PROTECTION %d / %d" % [sail_level, SAIL_MAX_LEVEL, protection_level, PROTECTION_MAX_LEVEL], 255, 25, COLOR_INK)
	draw_text_center("Maximum range: %d m" % int(current_max_distance()), 308, 24, COLOR_INK.lightened(0.12))
	draw_text_center("ROPE  %d     |     PLANKS  %d" % [total_rope, total_planks], 358, 23, COLOR_INK)
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
		var feedback_color := Color("#101316") if launch_overcharged else COLOR_ROPE
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


func draw_ocean_background(_scroll: float) -> void:
	# The repeated, animated ocean is rendered by GameplayOcean behind this canvas.
	pass


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


func draw_upgrade_icon(index: int, position: Vector2, size: Vector2) -> void:
	var texture := SAIL_UPGRADE_ICON if index == 0 else SHIELD_UPGRADE_ICON
	var texture_size := texture.get_size()
	var fit_scale := minf(size.x / texture_size.x, size.y / texture_size.y)
	var fitted_size := texture_size * fit_scale
	draw_texture_rect(texture, Rect2(position - fitted_size * 0.5, fitted_size), false)


func draw_launch_splash(position: Vector2, scale_value: float) -> void:
	draw_atlas_sprite(Vector2i(3, 3), position, Vector2(116.0, 116.0) * scale_value, sin(state_time * 11.0) * 0.08)


func draw_raft_wake(position: Vector2, strength: float) -> void:
	if state == State.RETURNING:
		return

	var turn_amount := absf(raft_steer_visual)
	if turn_amount > 0.06:
		var turn_scale := strength * lerpf(0.72, 1.0, turn_amount)
		var side_position := position + Vector2(-raft_steer_visual * 96.0, 104.0)
		draw_foam_texture(
			RAFT_TURN_SPLASH_TEXTURE,
			side_position,
			Vector2(260.0, 173.0) * turn_scale,
			0.0,
			raft_steer_visual > 0.0,
			Color(1.0, 1.0, 1.0, lerpf(0.55, 0.92, turn_amount))
		)
		return

	var wake_pulse := 1.0 + sin(state_time * 4.2) * 0.018
	draw_foam_texture(
		RAFT_WAKE_TEXTURE,
		position + Vector2(0.0, 188.0 * strength),
		Vector2(198.0 * wake_pulse, 352.0) * strength,
		PI,
		false,
		Color(1.0, 1.0, 1.0, 0.88)
	)


func draw_foam_texture(texture: Texture2D, position: Vector2, size: Vector2, rotation: float, flip_x: bool, modulate: Color) -> void:
	var transform_scale := Vector2(-1.0, 1.0) if flip_x else Vector2.ONE
	draw_set_transform(position, rotation, transform_scale)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_game_hud() -> void:
	draw_panel(Rect2(18, 18, 240, 112), Color(0.96, 0.97, 0.91, 0.93))
	draw_text("ROPE %d" % run_rope, Vector2(36, 60), 20, COLOR_INK)
	draw_text("PLANKS %d" % run_planks, Vector2(36, 104), 20, COLOR_INK)
	draw_text("SAIL %d" % sail_level, Vector2(170, 60), 17, COLOR_INK.lightened(0.12))
	draw_text("HULL %d/%d" % [raft_health, maximum_raft_health()], Vector2(170, 104), 15, COLOR_CORAL)

	var bar := Rect2(280, 32, 420, 34)
	draw_rect(bar, Color(0.02, 0.19, 0.29, 0.72))
	var progress := clampf(distance_m / run_target_distance, 0.0, 1.0)
	draw_rect(Rect2(bar.position + Vector2(5, 5), Vector2((bar.size.x - 10) * progress, bar.size.y - 10)), COLOR_ROPE)
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
	var entrance := smoothstep(0.0, 1.0, clampf(state_time / 0.44, 0.0, 1.0))
	var title_y := lerpf(205.0, 145.0, entrance)
	draw_text_center("BACK ON THE ISLAND", title_y, 42, COLOR_INK)
	draw_text_center(return_reason, lerpf(235.0, 190.0, entrance), 21, COLOR_CORAL)
	draw_text_center("You traveled  %d m" % int(distance_m), 255, 28, COLOR_INK)
	draw_text_center("RUN HAUL", 308, 20, Color("#45647a"))

	var source_pulse := 1.0 + sin(state_time * 3.2) * 0.035
	draw_resource_glow(RESULT_ROPE_SOURCE, "rope", 48.0 * source_pulse, state_time)
	draw_resource_icon("rope", RESULT_ROPE_SOURCE, Vector2(82.0, 82.0) * source_pulse, sin(state_time * 2.1) * 0.035)
	draw_string(ThemeDB.fallback_font, Vector2(75, 466), "+%d  ROPE" % run_rope, HORIZONTAL_ALIGNMENT_CENTER, 230, 23, COLOR_INK)

	draw_resource_glow(RESULT_PLANK_SOURCE, "plank", 53.0 * source_pulse, state_time + 0.8)
	draw_resource_icon("plank", RESULT_PLANK_SOURCE, Vector2(98.0, 98.0) * source_pulse, -0.28 + sin(state_time * 1.8) * 0.035)
	draw_string(ThemeDB.fallback_font, Vector2(415, 466), "+%d  PLANKS" % run_planks, HORIZONTAL_ALIGNMENT_CENTER, 230, 23, COLOR_INK)

	draw_panel(Rect2(92, 493, 536, 137), Color(0.91, 0.95, 0.89, 0.96))
	draw_text_center("TOTAL SUPPLIES", 528, 18, Color("#45647a"))
	draw_result_total("rope", RESULT_ROPE_TARGET, result_display_rope, result_rope_flash)
	draw_result_total("plank", RESULT_PLANK_TARGET, result_display_planks, result_plank_flash)

	if result_sequence_complete:
		var stored_alpha := 0.72 + sin(state_time * 4.0) * 0.18
		draw_text_center("SUPPLIES STORED!", 665, 19, Color(0.14, 0.55, 0.42, stored_alpha))
	else:
		draw_text_center("STORING SALVAGE...", 665, 19, Color("#45647a"))
	draw_text_center("Range %d m    |    Safe rock hits %d" % [int(current_max_distance()), protection_level], 704, 19, Color("#45647a"))
	draw_top_raft(Vector2(360, 800 + sin(state_time * 2.4) * 4.0), raft_level, maximum_raft_health())
	draw_result_flyers()

	if result_sequence_complete:
		var button_progress := smoothstep(0.0, 1.0, result_button_reveal)
		var button_offset := Vector2(0.0, (1.0 - button_progress) * 65.0)
		draw_button(Rect2(again_button.position + button_offset, again_button.size), "NEW LAUNCH", true, COLOR_WATER, button_progress)
		draw_button(Rect2(upgrade_button.position + button_offset, upgrade_button.size), "OPEN UPGRADES", true, COLOR_CORAL, button_progress)


func draw_result_total(kind: String, count_position: Vector2, count: int, flash: float) -> void:
	var pulse := 1.0 + flash * 0.18
	var glow_color := Color("#fff0bd") if kind == "rope" else Color("#d9f2e9")
	glow_color.a = flash * 0.22
	draw_circle(count_position, 47.0 * pulse, glow_color)
	var icon_position := count_position + Vector2(-68.0, -5.0)
	var icon_size := Vector2(49.0, 49.0) if kind == "rope" else Vector2(58.0, 58.0)
	draw_resource_icon(kind, icon_position, icon_size * pulse, -0.22 if kind == "plank" else 0.0)
	var label := "ROPE" if kind == "rope" else "PLANKS"
	draw_string(ThemeDB.fallback_font, count_position + Vector2(-31, -17), label, HORIZONTAL_ALIGNMENT_CENTER, 92, 14, Color("#45647a"))
	draw_string(ThemeDB.fallback_font, count_position + Vector2(-31, 18 + flash * 3.0), str(count), HORIZONTAL_ALIGNMENT_CENTER, 92, 29 + int(flash * 8.0), COLOR_INK)


func draw_result_flyers() -> void:
	for flyer in result_flyers:
		var ratio: float = clampf(flyer["time"] / flyer["duration"], 0.0, 1.0)
		var travel := smoothstep(0.0, 1.0, ratio)
		var position: Vector2 = flyer["start"].lerp(flyer["target"], travel)
		position.y -= sin(ratio * PI) * float(flyer["arc"])
		var kind: String = flyer["kind"]
		var base_size := 61.0 if kind == "rope" else 72.0
		var size := lerpf(base_size, base_size * 0.64, ratio)
		var rotation := float(flyer["spin"]) * ratio * TAU
		var trail_color := Color("#fff0c7") if kind == "rope" else Color("#d9f0df")
		trail_color.a = sin(ratio * PI) * 0.14
		draw_circle(position, size * 0.53, trail_color)
		draw_resource_icon(kind, position, Vector2(size, size), rotation)


func draw_upgrades() -> void:
	draw_rect(Rect2(315, 165, 405, 865), Color(0.02, 0.12, 0.18, 0.42))
	draw_rect(Rect2(0, 0, VIEW_SIZE.x, 165), Color(0.02, 0.12, 0.18, 0.90))
	draw_text_center("RAFT WORKSHOP", 62, 42, Color.WHITE)
	draw_text_center("Choose what to improve", 99, 19, Color("#c8f4f7"))
	draw_text_center("ROPE  %d     |     PLANKS  %d" % [total_rope, total_planks], 140, 22, COLOR_ROPE)

	draw_upgrade_card(Rect2(330, 175, 370, 136), 0, "SAIL", sail_level, SAIL_MAX_LEVEL)
	draw_upgrade_card(Rect2(330, 321, 370, 136), 1, "PROTECTION", protection_level, PROTECTION_MAX_LEVEL)
	draw_upgrade_placeholder(Rect2(330, 467, 370, 136))
	draw_upgrade_placeholder(Rect2(330, 613, 370, 136))
	draw_upgrade_placeholder(Rect2(330, 759, 370, 136))
	draw_upgrade_info_panel()

	if upgrade_feedback_time > 0.0 and not upgrade_feedback.is_empty():
		var feedback_color := COLOR_ROPE if upgrade_feedback.contains("UPGRADED") else Color("#ff9a91")
		draw_string(ThemeDB.fallback_font, Vector2(330, 1035), upgrade_feedback, HORIZONTAL_ALIGNMENT_CENTER, 370, 18, feedback_color)
	draw_button(upgrade_back_button, "BACK", true, COLOR_WATER)


func draw_upgrade_card(rect: Rect2, icon_index: int, title: String, level: int, max_level: int) -> void:
	draw_panel(rect, Color(0.97, 0.94, 0.84, 0.96))
	draw_upgrade_icon(icon_index, rect.position + Vector2(60.0, 68.0), Vector2(98.0, 98.0))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(116, 31), title, HORIZONTAL_ALIGNMENT_CENTER, 172, 20, COLOR_INK)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(116, 53), "LEVEL %d / %d" % [level, max_level], HORIZONTAL_ALIGNMENT_CENTER, 172, 14, Color("#45647a"))
	var info_rect := sail_info_button if icon_index == 0 else protection_info_button
	draw_upgrade_info_badge(info_rect, upgrade_info_open == icon_index)
	var button_rect := sail_upgrade_button if icon_index == 0 else protection_upgrade_button
	if level >= max_level:
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(116, 82), "NO MORE MATERIALS NEEDED", HORIZONTAL_ALIGNMENT_CENTER, 228, 12, Color("#45647a"))
		draw_compact_button(button_rect, "MAX LEVEL", false, COLOR_CORAL)
	else:
		var cost := sail_upgrade_cost(level) if icon_index == 0 else protection_upgrade_cost(level)
		draw_upgrade_cost(rect.position + Vector2(128, 77), cost)
		draw_compact_button(button_rect, "UPGRADE", can_pay(cost), COLOR_CORAL)


func draw_upgrade_cost(origin: Vector2, cost: Vector2i) -> void:
	draw_resource_icon("rope", origin, Vector2(31, 31))
	draw_string(ThemeDB.fallback_font, origin + Vector2(20, 6), "x%d" % cost.x, HORIZONTAL_ALIGNMENT_LEFT, 48, 17, COLOR_INK)
	var plank_position := origin + Vector2(88, 0)
	draw_resource_icon("plank", plank_position, Vector2(36, 36), -0.18)
	draw_string(ThemeDB.fallback_font, plank_position + Vector2(22, 6), "x%d" % cost.y, HORIZONTAL_ALIGNMENT_LEFT, 48, 17, COLOR_INK)


func draw_upgrade_info_badge(rect: Rect2, selected: bool) -> void:
	var color := COLOR_CORAL if selected else COLOR_WATER
	draw_circle(rect.get_center(), 17.0, color)
	draw_arc(rect.get_center(), 17.0, 0.0, TAU, 24, Color.WHITE, 2.0, true)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 28), "!", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Color.WHITE)


func draw_upgrade_info_panel() -> void:
	if upgrade_info_open < 0:
		return
	var card_y := 175.0 if upgrade_info_open == 0 else 321.0
	var panel_rect := Rect2(20, card_y, 286, 136)
	var panel_color := Color(0.97, 0.94, 0.84, 0.97)
	draw_panel(panel_rect, panel_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(panel_rect.end.x, card_y + 22),
		Vector2(330, card_y + 31),
		Vector2(panel_rect.end.x, card_y + 42),
	]), panel_color)
	if upgrade_info_open == 0:
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(16, 31), "SAIL UPGRADE", HORIZONTAL_ALIGNMENT_LEFT, 250, 20, COLOR_INK)
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(16, 64), "Each level adds %d m" % int(SAIL_RANGE_BONUS), HORIZONTAL_ALIGNMENT_LEFT, 250, 16, Color("#45647a"))
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(16, 87), "to your maximum travel range.", HORIZONTAL_ALIGNMENT_LEFT, 250, 16, Color("#45647a"))
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(16, 116), "Current maximum: %d m" % int(current_max_distance()), HORIZONTAL_ALIGNMENT_LEFT, 250, 16, COLOR_WATER)
	else:
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(16, 31), "PROTECTION UPGRADE", HORIZONTAL_ALIGNMENT_LEFT, 250, 20, COLOR_INK)
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(16, 64), "Each level absorbs one more", HORIZONTAL_ALIGNMENT_LEFT, 250, 16, Color("#45647a"))
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(16, 87), "rock collision before breaking.", HORIZONTAL_ALIGNMENT_LEFT, 250, 16, Color("#45647a"))
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(16, 116), "Current safe hits: %d" % protection_level, HORIZONTAL_ALIGNMENT_LEFT, 250, 16, COLOR_WATER)


func draw_compact_button(rect: Rect2, label: String, enabled: bool, color: Color) -> void:
	var button_color := color if enabled else Color("#8fa3ad")
	draw_rect(Rect2(rect.position + Vector2(0, 4), rect.size), button_color.darkened(0.42))
	draw_rect(rect, button_color)
	draw_rect(rect, Color.WHITE if enabled else Color("#cbd3d6"), false, 2)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.67), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 16, Color.WHITE)


func draw_upgrade_placeholder(rect: Rect2) -> void:
	draw_panel(rect, Color(0.88, 0.89, 0.84, 0.40))
	draw_rect(Rect2(rect.position + Vector2(14, 14), rect.size - Vector2(28, 28)), Color(0.22, 0.34, 0.37, 0.22), false, 2)


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


func draw_button(rect: Rect2, label: String, enabled: bool, color: Color, alpha: float = 1.0) -> void:
	var button_color := color if enabled else Color("#8fa3ad")
	button_color.a *= clampf(alpha, 0.0, 1.0)
	var shadow_color := button_color.darkened(0.42)
	shadow_color.a *= alpha
	var border_color := Color.WHITE if enabled else Color("#cbd3d6")
	border_color.a *= alpha
	var text_color := Color.WHITE
	text_color.a *= alpha
	draw_rect(Rect2(rect.position + Vector2(0, 7), rect.size), shadow_color)
	draw_rect(rect, button_color)
	draw_rect(rect, border_color, false, 3)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.64), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 25, text_color)


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
		draw_line(pos + Vector2(-80, -17), pos + Vector2(78, -17), COLOR_ROPE, 5)


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
	var kind: String = pickup["kind"]
	var phase := state_time + position.x * 0.011 + position.y * 0.004
	var pulse := 1.0 + sin(phase * 2.7) * 0.035
	var glow_radius := 43.0 if kind == "rope" else 50.0
	var icon_size := Vector2(78.0, 78.0) if kind == "rope" else Vector2(94.0, 94.0)
	draw_resource_glow(position, kind, glow_radius * pulse, phase)
	draw_resource_icon(kind, position, icon_size * pulse, pickup["rotation"])


func draw_resource_glow(position: Vector2, kind: String, radius: float, phase: float) -> void:
	var pulse := 1.0 + sin(phase * 2.5) * 0.045
	var glow_color := Color("#fff4cf") if kind == "rope" else Color("#dff8ed")
	var outer := glow_color
	outer.a = 0.025
	var middle := glow_color
	middle.a = 0.045
	var ring := glow_color
	ring.a = 0.15 + sin(phase * 2.5) * 0.025
	draw_circle(position, radius * 1.34 * pulse, outer)
	draw_circle(position, radius * 1.13 * pulse, middle)
	draw_arc(position, radius * pulse, 0.0, TAU, 32, ring, 2.2, true)


func draw_resource_icon(kind: String, position: Vector2, size: Vector2, rotation: float = 0.0, alpha: float = 1.0) -> void:
	draw_set_transform(position, rotation, Vector2.ONE)
	if kind == "rope":
		var rope_tint := Color(1.03, 1.18, 1.38, alpha)
		draw_texture_rect(ROPE_SPRITE, Rect2(-size * 0.5, size), false, rope_tint)
	else:
		var cell_size := SPRITE_ATLAS.get_size() / 4.0
		var source_rect := Rect2(Vector2(2, 2) * cell_size, cell_size)
		var plank_tint := Color(1.04, 1.04, 1.02, alpha)
		draw_texture_rect_region(SPRITE_ATLAS, Rect2(-size * 0.5, size), source_rect, plank_tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
