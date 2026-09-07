extends Node2D

enum State { HOME, CHARGING, INTRO, PLAYING, RETURNING, RESULTS, UPGRADES, VICTORY, OPENING, RAFT_PREVIEW, FAT_RAFT_PREVIEW, SKINNY_RAFT_PREVIEW, FAT_RAFT2_PREVIEW, CAPTAIN_PREVIEW, ISLAND_ARRIVAL_PREVIEW, BEACH_PREVIEW }

const VIEW_SIZE := Vector2(720.0, 1280.0)
const RAFT_Y := 1035.0
const SAVE_PATH := "user://save.cfg"
const SPRITE_ATLAS: Texture2D = preload("res://assets/sprites/raft_escape_atlas_v1.png")
const GAMEPLAY_RAFT_LVL1: Texture2D = preload("res://assets/sprites/raft-lvl1_optimized_v1.webp")
const GAMEPLAY_SAIL_LVL1: Texture2D = preload("res://assets/sprites/sail-lvl1_optimized_v1.webp")
const GAMEPLAY_FAT_BOY: Texture2D = preload("res://assets/sprites/fat-boy-on-raft_optimized_v1.webp")
const GAMEPLAY_SKINNY_BOY: Texture2D = preload("res://assets/sprites/skinny-boy-on-raft_optimized_v1.webp")
const ISLAND_SPRITE: Texture2D = preload("res://assets/sprites/deserted_island_v1.png")
const LAUNCH_PUSH_ATLAS: Texture2D = preload("res://assets/sprites/launch_push_atlas_v2.webp")
const GAMEPLAY_OCEAN_SCENE: PackedScene = preload("res://scenes/gameplay_ocean.tscn")
const RAFT_WAKE_TEXTURE: Texture2D = preload("res://assets/sea/splash1_optimized_v1.webp")
const RAFT_TURN_SPLASH_TEXTURE: Texture2D = preload("res://assets/sea/splash7_optimized_v1.webp")
const OPENING_EXTERIOR_SHIP: Texture2D = preload("res://assets/sea/ship-on-a-sea_optimized_v1.webp")
const OPENING_CAPTION_FONT: Font = preload("res://assets/fonts/BreeSerif-Regular.ttf")
const UPGRADE_UI_FONT: Font = preload("res://assets/fonts/OldStandard-Regular.ttf")
const UPGRADE_UI_BOLD_FONT: Font = preload("res://assets/fonts/OldStandard-Bold.ttf")
const OPENING_PARTY_TEXTURE: Texture2D = preload("res://assets/intro-scene/boat-party_optimized_v1.webp")
const OPENING_SHIP_BACKGROUND: Texture2D = preload("res://assets/intro-scene/ship-background_optimized_v1.webp")
const OPENING_FAT_BODY: Texture2D = preload("res://assets/intro-scene/fatguy-body_optimized_v1.webp")
const OPENING_FAT_HEAD: Texture2D = preload("res://assets/intro-scene/fatguy-head_optimized_v1.webp")
const OPENING_FAT_SCARED_HEAD: Texture2D = preload("res://assets/intro-scene/fat-scared-head_optimized_v1.webp")
const OPENING_NERD_BODY: Texture2D = preload("res://assets/intro-scene/nerd-body_optimized_v1.webp")
const OPENING_NERD_HEAD: Texture2D = preload("res://assets/intro-scene/nerd-head_optimized_v1.webp")
const OPENING_NERD_SCARED_HEAD: Texture2D = preload("res://assets/intro-scene/nerd-scared-head_optimized_v1.webp")
const OPENING_RAIL: Texture2D = preload("res://assets/intro-scene/rail_optimized_v1.webp")
const OPENING_DAMAGED_SHIP: Texture2D = preload("res://assets/intro-scene/ship-damaged_optimized_v1.webp")
const OPENING_GLACIER: Texture2D = preload("res://assets/intro-scene/glacier_optimized_v1.webp")
const OPENING_CAPTAIN: Texture2D = preload("res://assets/intro-scene/captain_optimized_v1.webp")
const OPENING_PLANKS: Texture2D = preload("res://assets/intro-scene/planks_optimized_v1.webp")
const OPENING_PASSENGER_BACKGROUND: Texture2D = preload("res://assets/intro-scene/background-sea-sky_optimized_v1.webp")
const OPENING_PASSENGER_SHIP: Texture2D = preload("res://assets/intro-scene/ship_optimized_v1.webp")
const OPENING_PASSENGER_MAN: Texture2D = preload("res://assets/intro-scene/man1_optimized_v1.webp")
const OPENING_WOMAN_1: Texture2D = preload("res://assets/intro-scene/woman1_optimized_v1.webp")
const OPENING_WOMAN_1_LEFT_ARM: Texture2D = preload("res://assets/intro-scene/woman1-left-arm_optimized_v1.webp")
const OPENING_WOMAN_1_RIGHT_ARM: Texture2D = preload("res://assets/intro-scene/woman1-right-arm_optimized_v1.webp")
const OPENING_WOMAN_2: Texture2D = preload("res://assets/intro-scene/woman2_optimized_v1.webp")
const OPENING_WOMAN_2_LEFT_ARM: Texture2D = preload("res://assets/intro-scene/woman2-left-arm_optimized_v1.webp")
const OPENING_WOMAN_2_RIGHT_ARM: Texture2D = preload("res://assets/intro-scene/woman2-right-arm_optimized_v1.webp")
const OPENING_RAFT_BACKGROUND: Texture2D = preload("res://assets/intro-scene/background-sea-sky2_optimized_v1.webp")
const OPENING_BOYS_AND_RAFT: Texture2D = preload("res://assets/intro-scene/boys-and-raft_optimized_v1.webp")
const OPENING_FAT_BOY_RAFT: Texture2D = preload("res://assets/intro-scene/fat-boy-raft_optimized_v1.webp")
const OPENING_SKINNY_BOY_RAFT: Texture2D = preload("res://assets/intro-scene/skinny-boy-raft_optimized_v1.webp")
const OPENING_FAT_BOY_RAFT2: Texture2D = preload("res://assets/intro-scene/fat-boy-raft2_optimized_v1.webp")
const OPENING_ARRIVAL_ISLAND: Texture2D = preload("res://assets/intro-scene/island_optimized_v1.webp")
const OPENING_ARRIVAL_RAFT: Texture2D = preload("res://assets/intro-scene/raft-and-boys-birds-view_optimized_v1.webp")
const OPENING_BEACH: Texture2D = preload("res://assets/intro-scene/beach_optimized_v1.webp")
const OPENING_FAT_BOY_BEACH: Texture2D = preload("res://assets/intro-scene/fat-boy-beach_optimized_v1.webp")
const WORKSHOP_BACKGROUND_SCENE: PackedScene = preload("res://scenes/workshop_animated_background.tscn")
const WORKSHOP_BRANCHES_SCENE: PackedScene = preload("res://scenes/workshop_branches.tscn")
const WORKSHOP_RAFT_SCENE: PackedScene = preload("res://scenes/workshop_raft.tscn")
const NERD_PARTS_CUTOUT_SCENE: PackedScene = preload("res://scenes/nerd_parts_cutout.tscn")
const FAT_MAN_PARTS_CUTOUT_SCENE: PackedScene = preload("res://scenes/fat_man_parts_cutout.tscn")
const NERD_PARTS_SCALE := 1.03275
const NERD_PARTS_BASE_POSITION := Vector2(292.0, 690.0)
const FAT_MAN_PARTS_BASE_POSITION := Vector2(182.0, 410.0)
const WORKSHOP_RAFT_BASE_POSITION := Vector2(358.0, 960.0)
const SAIL_UPGRADE_ICON: Texture2D = preload("res://assets/upgrade-scene/sail-sketch-upgrade_optimized_v1.webp")
const SHIELD_UPGRADE_ICON: Texture2D = preload("res://assets/upgrade-scene/guard-sketch-upgrade_optimized_v1.webp")
const OAR_UPGRADE_ICON: Texture2D = preload("res://assets/upgrade-scene/oar-sketch-upgrade.svg")
const UPGRADE_ROPE_ICON: Texture2D = preload("res://assets/sprites/rope_coil_optimized_v2.webp")
const UPGRADE_PLANK_ICON: Texture2D = preload("res://assets/sprites/plank_collectible_optimized_v2.webp")
const ROPE_SPRITE: Texture2D = preload("res://assets/sprites/rope_coil_optimized_v2.webp")
const PLANK_SPRITE: Texture2D = preload("res://assets/sprites/plank_collectible_optimized_v2.webp")
const BASE_RAFT_RANGE := 75.0
const SAIL_RANGE_BONUS := 28.0
const SAIL_MAX_LEVEL := 5
const PROTECTION_MAX_LEVEL := 4
const OAR_MAX_LEVEL := 4
const BASE_STEERING_SPEED := 540.0
const OAR_STEERING_BONUS := 45.0
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
const OPENING_EXTERIOR_DURATION := 3.5
const OPENING_EXTERIOR_TRANSITION_DURATION := 0.65
const OPENING_EXTERIOR_OCEAN_SPEED := 145.0
const OPENING_EXTERIOR_OCEAN_TILE_SIZE := 270.0
const OPENING_PAN_DURATION := 5.5
const OPENING_TRANSITION_DURATION := 0.65
const OPENING_DIALOGUE_START := 0.45 / 1.10
const OPENING_DIALOGUE_SECOND := 3.80 / 1.10
const OPENING_DIALOGUE_THIRD := 7.20 / 1.10
const OPENING_DIALOGUE_FOURTH := 10.10 / 1.10
const OPENING_DIALOGUE_FIFTH := 13.20 / 1.10
const OPENING_IMPACT_TIME := OPENING_DIALOGUE_FIFTH + ((15.85 - 13.20) / 1.10) * 0.60
const OPENING_IMPACT_DURATION := 0.72
const OPENING_DAMAGED_TRANSITION_DURATION := 0.55
const OPENING_DAMAGED_TURN_DURATION := 2.8
const OPENING_CAPTAIN_TRANSITION_DURATION := 0.55
const OPENING_CAPTAIN_HOLD_DURATION := 3.0
const OPENING_BREAKUP_TRANSITION_DURATION := 0.55
const OPENING_BREAKUP_SMOKE_START := 1.60
const OPENING_BREAKUP_SWAP_TIME := 2.75
const OPENING_BREAKUP_DURATION := 4.60
const OPENING_PLANKS_HOLD_DURATION := 1.5
const OPENING_PASSENGERS_TRANSITION_DURATION := 0.65
const OPENING_PASSENGERS_HOLD_DURATION := 4.5 * 0.65
const OPENING_RAFT_TRANSITION_DURATION := 0.65
const OPENING_RAFT_HOLD_DURATION := 4.5
const OPENING_FAT_RAFT_TRANSITION_DURATION := 0.55
const OPENING_FAT_RAFT_HOLD_DURATION := 6.5
const OPENING_SKINNY_RAFT_TRANSITION_DURATION := 0.55
const OPENING_SKINNY_RAFT_HOLD_DURATION := 5.0
const OPENING_FAT_RAFT2_TRANSITION_DURATION := 0.55
const OPENING_FAT_RAFT2_HOLD_DURATION := 4.0
const OPENING_ISLAND_TRANSITION_DURATION := 0.65
const OPENING_ISLAND_ARRIVAL_DURATION := 7.0
const OPENING_BEACH_TRANSITION_DURATION := 0.65
const OPENING_BEACH_HOLD_DURATION := 3.6
const OPENING_END_FADE_DURATION := 0.65
const UPGRADE_DIALOGUE_FIRST_DELAY := 5.0
const UPGRADE_DIALOGUE_PAUSE := 20.0
const LAUNCH_DIALOGUE_FIRST_DELAY := 0.8
const LAUNCH_DIALOGUE_PAUSE := 8.0
const LAUNCH_DIALOGUES := [
	[
		{"speaker": "fat", "text": "Do I really have to push this thing again?"},
		{"speaker": "nerd", "text": "Come on. One more push. This time we'll make it."},
	],
	[
		{"speaker": "fat", "text": "This raft gets heavier every time."},
		{"speaker": "nerd", "text": "It doesn't. Just push it already."},
	],
	[
		{"speaker": "fat", "text": "My back still hurts from the last launch."},
		{"speaker": "nerd", "text": "Then push with your legs."},
		{"speaker": "fat", "text": "My legs hurt too."},
	],
	[
		{"speaker": "fat", "text": "What if the current sends us back again?"},
		{"speaker": "nerd", "text": "Then we'll fix it again. Now push!"},
	],
	[
		{"speaker": "fat", "text": "Couldn't you push while I sit on the raft?"},
		{"speaker": "nerd", "text": "That is exactly what we're doing."},
	],
]
const UPGRADE_DIALOGUES := [
	[
		{"speaker": "fat", "text": "Is the raft almost finished?"},
		{"speaker": "nerd", "text": "Yes. It's only missing the part that floats."},
	],
	[
		{"speaker": "fat", "text": "I could really go for a baked potato right now."},
	],
	[
		{"speaker": "fat", "text": "Maybe food will appear on its own if I wait long enough."},
	],
	[
		{"speaker": "nerd", "text": "It's amazing how much faster I work when nobody helps me."},
	],
	[
		{"speaker": "nerd", "text": "A plank, some rope, a nail... and one completely useless assistant."},
	],
	[
		{"speaker": "fat", "text": "I don't like the way that bird is looking at me."},
	],
	[
		{"speaker": "nerd", "text": "If this falls apart, we'll say it was a prototype."},
	],
	[
		{"speaker": "nerd", "text": "Just a few more repairs."},
		{"speaker": "fat", "text": "How many?"},
		{"speaker": "nerd", "text": "I don't want to ruin your day."},
	],
	[
		{"speaker": "fat", "text": "Maybe we could tame an animal."},
		{"speaker": "nerd", "text": "Why?"},
		{"speaker": "fat", "text": "So we can eat it later."},
	],
	[
		{"speaker": "fat", "text": "Is it possible nobody saw us sink?"},
		{"speaker": "nerd", "text": "The ship sank. I think they were busy."},
	],
	[
		{"speaker": "fat", "text": "I'm not sure I want to go back to sea."},
		{"speaker": "nerd", "text": "Then you can stay."},
		{"speaker": "fat", "text": "...When do we leave?"},
	],
	[
		{"speaker": "nerd", "text": "This will hold."},
		{"speaker": "fat", "text": "Are you sure?"},
		{"speaker": "nerd", "text": "Don't ruin the moment."},
	],
	[
		{"speaker": "nerd", "text": "We need more wood."},
		{"speaker": "fat", "text": "And food."},
		{"speaker": "nerd", "text": "Wood."},
		{"speaker": "fat", "text": "Wood and food."},
	],
	[
		{"speaker": "fat", "text": "I'm not a very good swimmer."},
		{"speaker": "nerd", "text": "I noticed during the shipwreck."},
	],
	[
		{"speaker": "fat", "text": "Maybe someone's looking for us."},
		{"speaker": "nerd", "text": "Definitely."},
		{"speaker": "fat", "text": "Really?"},
		{"speaker": "nerd", "text": "No."},
	],
	[
		{"speaker": "fat", "text": "Is a coconut a fruit or a nut?"},
		{"speaker": "nerd", "text": "Right now, it's lunch."},
	],
	[
		{"speaker": "fat", "text": "I don't think this will float."},
		{"speaker": "nerd", "text": "Excellent. You're finally thinking."},
	],
	[
		{"speaker": "fat", "text": "I'm hungry."},
		{"speaker": "nerd", "text": "You said that two minutes ago."},
		{"speaker": "fat", "text": "I'm hungrier now."},
	],
]
const OPENING_BEACH_PREVIEW_ONLY := false
const OPENING_ISLAND_ARRIVAL_PREVIEW_ONLY := false
const OPENING_CAPTAIN_PREVIEW_ONLY := false
const OPENING_PASSENGERS_PREVIEW_ONLY := false
const OPENING_RAFT_PREVIEW_ONLY := false
const OPENING_FAT_RAFT_PREVIEW_ONLY := false
const OPENING_SKINNY_RAFT_PREVIEW_ONLY := false
const OPENING_FAT_RAFT2_PREVIEW_ONLY := false
const UPGRADE_SCREEN_TEST_MODE := true
const GAMEPLAY_ZERO_PROGRESS_TEST_MODE := false
const OPENING_PLANK_LAYOUT := [
	{"position": Vector2(78.0, 338.0), "size": 154.0, "rotation": -0.22},
	{"position": Vector2(168.0, 365.0), "size": 166.0, "rotation": 0.15},
	{"position": Vector2(258.0, 350.0), "size": 148.0, "rotation": -0.08},
	{"position": Vector2(348.0, 380.0), "size": 172.0, "rotation": 0.24},
	{"position": Vector2(442.0, 355.0), "size": 158.0, "rotation": -0.18},
	{"position": Vector2(538.0, 390.0), "size": 170.0, "rotation": 0.10},
	{"position": Vector2(632.0, 365.0), "size": 150.0, "rotation": -0.28},
	{"position": Vector2(116.0, 500.0), "size": 168.0, "rotation": 0.27},
	{"position": Vector2(220.0, 520.0), "size": 156.0, "rotation": -0.16},
	{"position": Vector2(326.0, 495.0), "size": 178.0, "rotation": 0.08},
	{"position": Vector2(438.0, 530.0), "size": 162.0, "rotation": -0.25},
	{"position": Vector2(548.0, 505.0), "size": 174.0, "rotation": 0.19},
	{"position": Vector2(640.0, 535.0), "size": 152.0, "rotation": -0.06},
]
const RETURN_SCROLL_SPEED := 260.0
const RETURN_RESULTS_DELAY := 2.75
const RETURN_RAFT_DRIFT_TIME := 0.65
const RETURN_RAFT_DRIFT_OFFSET := 70.0
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
const COLOR_UPGRADE_INK := Color("#0a141b")
const COLOR_UPGRADE_MUTED_INK := Color("#26333c")
const COLOR_UPGRADE_ACCENT_INK := Color("#633126")
const COLOR_UPGRADE_STATUS_INK := Color("#075066")

var state: int = State.OPENING
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
var oar_level := 0
var raft_health := 1
var return_reason := ""
var return_scene_visible := false
var return_landed := false
var return_elapsed := 0.0
var return_impact_time := 0.0
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
var upgrade_returns_to_home := false
var upgrade_dialogue_index := 0
var upgrade_dialogue_line_index := 0
var upgrade_dialogue_line_time := 0.0
var upgrade_dialogue_wait_remaining := UPGRADE_DIALOGUE_FIRST_DELAY
var upgrade_dialogue_active := false
var launch_dialogue_index := 0
var launch_dialogue_line_index := 0
var launch_dialogue_line_time := 0.0
var launch_dialogue_wait_remaining := LAUNCH_DIALOGUE_FIRST_DELAY
var launch_dialogue_active := false
var opening_seen := false
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
var opening_skip_button := Rect2(535, 1180, 155, 58)
var again_button := Rect2(100, 895, 520, 88)
var upgrade_button := Rect2(100, 1010, 520, 88)
var sail_upgrade_button := Rect2(563, 219, 129, 34)
var protection_upgrade_button := Rect2(563, 320, 129, 34)
var oar_upgrade_button := Rect2(563, 421, 129, 34)
var sail_info_button := Rect2(654, 180, 38, 38)
var protection_info_button := Rect2(654, 281, 38, 38)
var oar_info_button := Rect2(654, 382, 38, 38)
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
	if UPGRADE_SCREEN_TEST_MODE:
		state = State.UPGRADES
		state_time = 0.0
	elif GAMEPLAY_ZERO_PROGRESS_TEST_MODE:
		start_zero_progress_gameplay_test()
	elif OPENING_BEACH_PREVIEW_ONLY:
		state = State.BEACH_PREVIEW
		state_time = 0.0
	elif OPENING_ISLAND_ARRIVAL_PREVIEW_ONLY:
		state = State.ISLAND_ARRIVAL_PREVIEW
		state_time = 0.0
	elif OPENING_CAPTAIN_PREVIEW_ONLY:
		state = State.CAPTAIN_PREVIEW
		state_time = 0.0
	elif OPENING_PASSENGERS_PREVIEW_ONLY:
		state = State.OPENING
		state_time = opening_deck_start_time() + opening_passengers_deck_time() + OPENING_PASSENGERS_TRANSITION_DURATION + 0.8
	elif OPENING_RAFT_PREVIEW_ONLY:
		state = State.RAFT_PREVIEW
		state_time = 0.0
	elif OPENING_FAT_RAFT_PREVIEW_ONLY:
		state = State.FAT_RAFT_PREVIEW
		state_time = 0.0
	elif OPENING_SKINNY_RAFT_PREVIEW_ONLY:
		state = State.SKINNY_RAFT_PREVIEW
		state_time = 0.0
	elif OPENING_FAT_RAFT2_PREVIEW_ONLY:
		state = State.FAT_RAFT2_PREVIEW
		state_time = 0.0
	if "--smoke-test" in user_args:
		call_deferred("run_smoke_test")
	if "--capture-opening-island-arrival" in user_args:
		state = State.ISLAND_ARRIVAL_PREVIEW
		state_time = 5.10
		capture_filename = "opening_island_arrival.png"
		capture_requested = true
	elif "--capture-opening-beach" in user_args:
		state = State.BEACH_PREVIEW
		state_time = 0.0
		capture_filename = "opening_beach.png"
		capture_requested = true
	elif "--capture-opening-party" in user_args:
		state = State.OPENING
		state_time = OPENING_EXTERIOR_DURATION + OPENING_PAN_DURATION * 0.5
		capture_filename = "opening_party.png"
		capture_requested = true
	elif "--capture-opening-final" in user_args:
		state = State.OPENING
		state_time = OPENING_EXTERIOR_DURATION + OPENING_PAN_DURATION + OPENING_TRANSITION_DURATION + 1.0
		capture_filename = "opening_final.png"
		capture_requested = true
	elif "--capture-opening-reply" in user_args:
		state = State.OPENING
		state_time = opening_deck_start_time() + OPENING_DIALOGUE_SECOND + 0.6
		capture_filename = "opening_reply.png"
		capture_requested = true
	elif "--capture-opening-impact" in user_args:
		state = State.OPENING
		state_time = opening_deck_start_time() + OPENING_IMPACT_TIME + OPENING_IMPACT_DURATION * 0.58
		capture_filename = "opening_impact.png"
		capture_requested = true
	elif "--capture-opening-damaged" in user_args:
		state = State.OPENING
		state_time = opening_deck_start_time() + OPENING_IMPACT_TIME + OPENING_IMPACT_DURATION + OPENING_DAMAGED_TRANSITION_DURATION + 2.0
		capture_filename = "opening_damaged.png"
		capture_requested = true
	elif "--capture-opening-captain" in user_args:
		state = State.OPENING
		state_time = opening_deck_start_time() + OPENING_IMPACT_TIME + OPENING_IMPACT_DURATION + OPENING_DAMAGED_TRANSITION_DURATION + OPENING_DAMAGED_TURN_DURATION + OPENING_CAPTAIN_TRANSITION_DURATION + 0.5
		capture_filename = "opening_captain.png"
		capture_requested = true
	elif "--capture-opening-planks" in user_args:
		state = State.OPENING
		state_time = opening_deck_start_time() + opening_planks_deck_time() + 1.0
		capture_filename = "opening_planks.png"
		capture_requested = true
	elif "--capture-opening-smoke" in user_args:
		state = State.OPENING
		state_time = opening_deck_start_time() + opening_breakup_deck_time() + OPENING_BREAKUP_TRANSITION_DURATION + OPENING_BREAKUP_SWAP_TIME
		capture_filename = "opening_smoke.png"
		capture_requested = true
	elif "--capture-opening-breakup" in user_args:
		state = State.OPENING
		state_time = opening_deck_start_time() + opening_breakup_deck_time() + OPENING_BREAKUP_TRANSITION_DURATION + 0.8
		capture_filename = "opening_breakup.png"
		capture_requested = true
	elif "--capture-opening-passengers" in user_args:
		state = State.OPENING
		state_time = opening_deck_start_time() + opening_passengers_deck_time() + OPENING_PASSENGERS_TRANSITION_DURATION + 0.8
		capture_filename = "opening_passengers.png"
		capture_requested = true
	elif "--capture-opening-raft" in user_args:
		state = State.RAFT_PREVIEW
		state_time = 1.4
		capture_filename = "opening_raft.png"
		capture_requested = true
	elif "--capture-opening-fat-raft" in user_args:
		state = State.FAT_RAFT_PREVIEW
		state_time = 0.0
		capture_filename = "opening_fat_raft.png"
		capture_requested = true
	elif "--capture-opening-skinny-raft" in user_args:
		state = State.SKINNY_RAFT_PREVIEW
		state_time = 0.0
		capture_filename = "opening_skinny_raft.png"
		capture_requested = true
	elif "--capture-opening-fat-raft2" in user_args:
		state = State.FAT_RAFT2_PREVIEW
		state_time = 0.0
		capture_filename = "opening_fat_raft2.png"
		capture_requested = true
	elif "--capture" in user_args:
		capture_requested = true
	elif "--capture-launch-dialogue" in user_args:
		return_to_launch_screen()
		launch_dialogue_active = true
		launch_dialogue_index = 0
		launch_dialogue_line_index = 1 if "--capture-launch-dialogue-reply" in user_args else 0
		launch_dialogue_line_time = 0.7
		capture_filename = "launch_dialogue.png"
		capture_requested = true
	elif "--capture-play" in user_args:
		prepare_gameplay_capture()
		capture_filename = "gameplay.png"
		capture_requested = true
	elif "--capture-play-sail" in user_args:
		sail_level = 1
		sync_visual_raft_level()
		prepare_gameplay_capture()
		capture_filename = "gameplay_sail.png"
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
	elif "--capture-upgrades-dialogue" in user_args:
		state = State.UPGRADES
		total_rope = maxi(total_rope, 25)
		total_planks = maxi(total_planks, 8)
		upgrade_dialogue_active = true
		upgrade_dialogue_index = 0
		upgrade_dialogue_line_index = 0
		upgrade_dialogue_line_time = 0.7
		capture_filename = "upgrades_dialogue.png"
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
		State.HOME:
			update_launch_dialogues(delta)
		State.OPENING:
			if state_time >= opening_total_duration() and not capture_requested:
				finish_opening_to_upgrades()
		State.CHARGING:
			var time_ratio := clampf(state_time / LAUNCH_FULL_TIME, 0.0, 1.0)
			launch_charge = (exp(LAUNCH_EXPONENT * time_ratio) - 1.0) / (exp(LAUNCH_EXPONENT) - 1.0)
		State.INTRO:
			update_intro(delta)
		State.PLAYING:
			update_playing(delta)
		State.RETURNING:
			update_returning(delta)
		State.RESULTS:
			if return_scene_visible:
				update_returning(delta)
			update_results(delta)
		State.UPGRADES:
			update_upgrade_dialogues(delta)
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
	if state == State.OPENING:
		gameplay_ocean.call(
			"set_travel",
			0.0,
			state_time * OPENING_EXTERIOR_OCEAN_SPEED,
			OPENING_EXTERIOR_OCEAN_TILE_SIZE
		)
		return
	var ocean_scroll := 0.0 if state == State.HOME or state == State.CHARGING else world_scroll
	gameplay_ocean.call("set_travel", ocean_scroll, 0.0, 322.0)


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

	raft_x = move_toward(raft_x, target_x, current_steering_speed() * delta)
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


func update_returning(delta: float) -> void:
	return_elapsed += delta
	if return_landed:
		return_impact_time += delta
	else:
		var previous_scroll := world_scroll
		world_scroll = maxf(0.0, world_scroll - RETURN_SCROLL_SPEED * delta)
		var scroll_delta := world_scroll - previous_scroll
		shift_returning_world_objects(scroll_delta, delta)
		if is_zero_approx(world_scroll):
			return_landed = true
			return_impact_time = 0.0

	if state == State.RETURNING and return_elapsed >= RETURN_RESULTS_DELAY:
		finish_run()


func shift_returning_world_objects(scroll_delta: float, delta: float) -> void:
	for index in range(obstacles.size() - 1, -1, -1):
		var obstacle := obstacles[index]
		obstacle["position"].y += scroll_delta
		obstacle["rotation"] += obstacle["spin"] * delta
		if obstacle["position"].y < -100.0:
			obstacles.remove_at(index)

	for index in range(pickups.size() - 1, -1, -1):
		var pickup := pickups[index]
		pickup["position"].y += scroll_delta
		pickup["rotation"] += delta * 1.8
		if pickup["position"].y < -80.0:
			pickups.remove_at(index)


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
	reset_launch_dialogues()
	upgrade_returns_to_home = false
	reset_touch_joystick()
	launch_charge = 0.0
	launch_feedback = ""
	launch_overcharged = false
	launch_is_perfect = false
	launch_hold_ratio = 0.55
	return_scene_visible = false
	return_landed = false
	return_elapsed = 0.0
	return_impact_time = 0.0


func start_zero_progress_gameplay_test() -> void:
	total_rope = 0
	total_planks = 0
	run_rope = 0
	run_planks = 0
	sail_level = 0
	protection_level = 0
	oar_level = 0
	sync_visual_raft_level()
	raft_health = maximum_raft_health()
	launch_hold_ratio = 0.78
	launch_power = 0.78
	launch_overcharged = false
	launch_is_perfect = false
	launch_cruise_speed = launch_speed_for_hold(launch_hold_ratio)
	raft_forward_speed = launch_cruise_speed
	run_target_distance = current_max_distance()
	begin_run()


func begin_run(continue_from_intro: bool = false) -> void:
	state = State.PLAYING
	state_time = 0.0
	return_scene_visible = false
	return_landed = false
	return_elapsed = 0.0
	return_impact_time = 0.0
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
	return_scene_visible = true
	return_landed = is_zero_approx(world_scroll)
	return_elapsed = 0.0
	return_impact_time = 0.0
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


func finish_opening_to_upgrades() -> void:
	opening_seen = true
	save_progress()
	open_upgrade_screen(true)


func open_upgrade_screen(return_home_after: bool = false) -> void:
	state = State.UPGRADES
	state_time = 0.0
	upgrade_returns_to_home = return_home_after
	reset_upgrade_dialogues()
	pointer_active = false
	upgrade_info_open = -1
	upgrade_feedback = ""
	upgrade_feedback_time = 0.0
	workshop_branches_rig.call("restart_animation")
	workshop_character_rig.call("restart_animation")
	workshop_fat_man_rig.call("restart_animation")


func reset_upgrade_dialogues() -> void:
	upgrade_dialogue_index = rng.randi_range(0, UPGRADE_DIALOGUES.size() - 1)
	upgrade_dialogue_line_index = 0
	upgrade_dialogue_line_time = 0.0
	upgrade_dialogue_wait_remaining = UPGRADE_DIALOGUE_FIRST_DELAY
	upgrade_dialogue_active = false


func update_upgrade_dialogues(delta: float) -> void:
	if not upgrade_dialogue_active:
		upgrade_dialogue_wait_remaining -= delta
		if upgrade_dialogue_wait_remaining <= 0.0:
			upgrade_dialogue_active = true
			upgrade_dialogue_line_index = 0
			upgrade_dialogue_line_time = 0.0
		return

	upgrade_dialogue_line_time += delta
	var current_line := current_upgrade_dialogue_line()
	if current_line.is_empty():
		finish_upgrade_dialogue()
		return
	if upgrade_dialogue_line_time < upgrade_dialogue_line_duration(str(current_line["text"])):
		return

	upgrade_dialogue_line_index += 1
	upgrade_dialogue_line_time = 0.0
	var current_dialogue: Array = UPGRADE_DIALOGUES[upgrade_dialogue_index]
	if upgrade_dialogue_line_index >= current_dialogue.size():
		finish_upgrade_dialogue()


func finish_upgrade_dialogue() -> void:
	upgrade_dialogue_active = false
	if UPGRADE_DIALOGUES.size() > 1:
		var dialogue_offset := rng.randi_range(1, UPGRADE_DIALOGUES.size() - 1)
		upgrade_dialogue_index = (upgrade_dialogue_index + dialogue_offset) % UPGRADE_DIALOGUES.size()
	upgrade_dialogue_line_index = 0
	upgrade_dialogue_line_time = 0.0
	upgrade_dialogue_wait_remaining = UPGRADE_DIALOGUE_PAUSE


func current_upgrade_dialogue_line() -> Dictionary:
	if not upgrade_dialogue_active or UPGRADE_DIALOGUES.is_empty():
		return {}
	var current_dialogue: Array = UPGRADE_DIALOGUES[upgrade_dialogue_index]
	if upgrade_dialogue_line_index < 0 or upgrade_dialogue_line_index >= current_dialogue.size():
		return {}
	return current_dialogue[upgrade_dialogue_line_index]


func upgrade_dialogue_line_duration(text: String) -> float:
	return clampf(2.5 + float(text.length()) * 0.025, 2.8, 4.2)


func reset_launch_dialogues() -> void:
	launch_dialogue_index = rng.randi_range(0, LAUNCH_DIALOGUES.size() - 1)
	launch_dialogue_line_index = 0
	launch_dialogue_line_time = 0.0
	launch_dialogue_wait_remaining = LAUNCH_DIALOGUE_FIRST_DELAY
	launch_dialogue_active = false


func update_launch_dialogues(delta: float) -> void:
	if not launch_dialogue_active:
		launch_dialogue_wait_remaining -= delta
		if launch_dialogue_wait_remaining <= 0.0:
			launch_dialogue_active = true
			launch_dialogue_line_index = 0
			launch_dialogue_line_time = 0.0
		return

	launch_dialogue_line_time += delta
	var current_line := current_launch_dialogue_line()
	if current_line.is_empty():
		finish_launch_dialogue()
		return
	if launch_dialogue_line_time < launch_dialogue_line_duration(str(current_line["text"])):
		return

	launch_dialogue_line_index += 1
	launch_dialogue_line_time = 0.0
	var current_dialogue: Array = LAUNCH_DIALOGUES[launch_dialogue_index]
	if launch_dialogue_line_index >= current_dialogue.size():
		finish_launch_dialogue()


func finish_launch_dialogue() -> void:
	launch_dialogue_active = false
	if LAUNCH_DIALOGUES.size() > 1:
		var dialogue_offset := rng.randi_range(1, LAUNCH_DIALOGUES.size() - 1)
		launch_dialogue_index = (launch_dialogue_index + dialogue_offset) % LAUNCH_DIALOGUES.size()
	launch_dialogue_line_index = 0
	launch_dialogue_line_time = 0.0
	launch_dialogue_wait_remaining = LAUNCH_DIALOGUE_PAUSE


func current_launch_dialogue_line() -> Dictionary:
	if not launch_dialogue_active or LAUNCH_DIALOGUES.is_empty():
		return {}
	var current_dialogue: Array = LAUNCH_DIALOGUES[launch_dialogue_index]
	if launch_dialogue_line_index < 0 or launch_dialogue_line_index >= current_dialogue.size():
		return {}
	return current_dialogue[launch_dialogue_line_index]


func launch_dialogue_line_duration(text: String) -> float:
	return clampf(2.3 + float(text.length()) * 0.022, 2.6, 3.6)


func close_upgrade_screen() -> void:
	return_to_launch_screen()
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
		show_upgrade_feedback("GUARD IS ALREADY MAXED", false)
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
	show_upgrade_feedback("GUARD UPGRADED  +1 SAFE HIT", true)


func try_purchase_oar() -> void:
	if oar_level >= OAR_MAX_LEVEL:
		show_upgrade_feedback("OAR IS ALREADY MAXED", false)
		return
	var cost := oar_upgrade_cost(oar_level)
	if not can_pay(cost):
		show_upgrade_feedback("NOT ENOUGH MATERIALS", false)
		return
	total_rope -= cost.x
	total_planks -= cost.y
	oar_level += 1
	sync_visual_raft_level()
	save_progress()
	burst(oar_upgrade_button.get_center(), COLOR_ROPE, 24)
	show_upgrade_feedback("OAR UPGRADED  +8% STEERING", true)


func show_upgrade_feedback(message: String, success: bool) -> void:
	upgrade_feedback = message
	upgrade_feedback_time = 2.0 if success else 1.4


func current_max_distance() -> float:
	return max_distance_for_sail(sail_level)


func max_distance_for_sail(level: int) -> float:
	return BASE_RAFT_RANGE + float(clampi(level, 0, SAIL_MAX_LEVEL)) * SAIL_RANGE_BONUS


func maximum_raft_health() -> int:
	return 1 + protection_level


func current_steering_speed() -> float:
	return BASE_STEERING_SPEED + float(oar_level) * OAR_STEERING_BONUS


func sync_visual_raft_level() -> void:
	var strongest_upgrade := maxi(maxi(sail_level, protection_level), oar_level)
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


func oar_upgrade_cost(level: int) -> Vector2i:
	match level:
		0: return Vector2i(5, 2)
		1: return Vector2i(10, 4)
		2: return Vector2i(18, 7)
		3: return Vector2i(30, 11)
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
		State.OPENING, State.CAPTAIN_PREVIEW, State.ISLAND_ARRIVAL_PREVIEW, State.BEACH_PREVIEW:
			if opening_skip_button.has_point(position):
				finish_opening_to_upgrades()
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
			elif oar_info_button.has_point(position):
				upgrade_info_open = -1 if upgrade_info_open == 2 else 2
			elif sail_upgrade_button.has_point(position):
				try_purchase_sail()
			elif protection_upgrade_button.has_point(position):
				try_purchase_protection()
			elif oar_upgrade_button.has_point(position):
				try_purchase_oar()
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
	config.set_value("progress", "oar_level", oar_level)
	config.set_value("progress", "opening_seen", opening_seen)
	config.save(SAVE_PATH)


func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	# Existing players keep everything they collected before the resource rename.
	total_rope = maxi(0, int(config.get_value("progress", "rope", config.get_value("progress", "coins", 0))))
	total_planks = maxi(0, int(config.get_value("progress", "planks", config.get_value("progress", "parts", 0))))
	opening_seen = bool(config.get_value("progress", "opening_seen", false))
	if config.has_section_key("progress", "sail_level"):
		sail_level = clampi(int(config.get_value("progress", "sail_level", 0)), 0, SAIL_MAX_LEVEL)
		protection_level = clampi(int(config.get_value("progress", "protection_level", 0)), 0, PROTECTION_MAX_LEVEL)
		oar_level = clampi(int(config.get_value("progress", "oar_level", 0)), 0, OAR_MAX_LEVEL)
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
	assert(oar_upgrade_cost(0) == Vector2i(5, 2))
	oar_level = 0
	assert(current_steering_speed() == BASE_STEERING_SPEED)
	oar_level = OAR_MAX_LEVEL
	assert(current_steering_speed() == BASE_STEERING_SPEED + OAR_STEERING_BONUS * OAR_MAX_LEVEL)
	oar_level = 0
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
	open_upgrade_screen(true)
	assert(state == State.UPGRADES)
	assert(upgrade_returns_to_home)
	close_upgrade_screen()
	assert(state == State.HOME)
	reset_upgrade_dialogues()
	var first_random_dialogue := upgrade_dialogue_index
	update_upgrade_dialogues(4.9)
	assert(not upgrade_dialogue_active)
	update_upgrade_dialogues(0.2)
	assert(upgrade_dialogue_active)
	var tested_dialogue_lines := 0
	while upgrade_dialogue_active and tested_dialogue_lines < 8:
		update_upgrade_dialogues(upgrade_dialogue_line_duration(str(current_upgrade_dialogue_line()["text"])))
		tested_dialogue_lines += 1
	assert(not upgrade_dialogue_active)
	assert(tested_dialogue_lines > 0)
	assert(upgrade_dialogue_index != first_random_dialogue)
	update_upgrade_dialogues(19.9)
	assert(not upgrade_dialogue_active)
	update_upgrade_dialogues(0.2)
	assert(upgrade_dialogue_active)
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
		State.BEACH_PREVIEW:
			draw_opening_beach_preview()
			draw_button(opening_skip_button, "SKIP", true, Color("#d16b48"), 0.94, 33)
		State.ISLAND_ARRIVAL_PREVIEW:
			draw_opening_island_arrival(state_time)
			draw_button(opening_skip_button, "SKIP", true, Color("#d16b48"), 0.94, 33)
		State.CAPTAIN_PREVIEW:
			draw_opening_captain_scene(1.0)
			draw_button(opening_skip_button, "SKIP", true, Color("#d16b48"), 0.94, 33)
		State.FAT_RAFT2_PREVIEW:
			draw_opening_fat_raft2_preview()
		State.SKINNY_RAFT_PREVIEW:
			draw_opening_skinny_raft_preview()
		State.FAT_RAFT_PREVIEW:
			draw_opening_fat_raft_preview()
		State.RAFT_PREVIEW:
			draw_opening_raft_preview()
		State.OPENING:
			draw_opening()
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


func draw_opening_island_arrival(scene_time: float) -> void:
	draw_texture_cover(OPENING_ARRIVAL_ISLAND, Rect2(Vector2.ZERO, VIEW_SIZE))

	var travel_duration := 5.0
	var impact_duration := 0.55
	var start_position := Vector2(610.0, -105.0)
	var shore_position := Vector2(360.0, 558.0)
	var raft_position := shore_position
	var raft_rotation := deg_to_rad(-4.0)
	var raft_scale := Vector2.ONE

	if scene_time < travel_duration:
		var travel_progress := clampf(scene_time / travel_duration, 0.0, 1.0)
		raft_position = start_position.lerp(shore_position, travel_progress)
		raft_position.x += sin(travel_progress * PI) * 35.0
		raft_rotation += sin(travel_progress * TAU) * deg_to_rad(6.0)
		var wake_pulse := 1.0 + sin(scene_time * 4.2) * 0.05
		var wake_size := Vector2(74.0, 160.0) * wake_pulse
		var travel_direction := (shore_position - start_position).normalized()
		var wake_center := raft_position - travel_direction * 92.0
		var wake_rotation := travel_direction.angle() - PI * 0.5
		draw_set_transform(wake_center, wake_rotation, Vector2.ONE)
		draw_texture_rect(
			RAFT_WAKE_TEXTURE,
			Rect2(-wake_size * 0.5, wake_size),
			false,
			Color(1.0, 1.0, 1.0, 0.48)
		)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		var impact_time := scene_time - travel_duration
		if impact_time < 0.12:
			var hit_progress := impact_time / 0.12
			raft_position.y += lerpf(0.0, 18.0, hit_progress)
			raft_scale = Vector2(1.04, 0.94)
			raft_rotation += deg_to_rad(2.5) * hit_progress
		elif impact_time < 0.30:
			var recoil_progress := smoothstep(0.0, 1.0, (impact_time - 0.12) / 0.18)
			raft_position.y += lerpf(18.0, -7.0, recoil_progress)
			raft_scale = Vector2(0.98, 1.03)
			raft_rotation += deg_to_rad(2.5) * (1.0 - recoil_progress)
		elif impact_time < impact_duration:
			var settle_progress := smoothstep(0.0, 1.0, (impact_time - 0.30) / (impact_duration - 0.30))
			raft_position.y += lerpf(-7.0, 0.0, settle_progress)

		if impact_time < 0.72:
			var splash_progress := clampf(impact_time / 0.72, 0.0, 1.0)
			var splash_alpha := sin(splash_progress * PI) * 0.72
			var contact_point := shore_position + Vector2(0.0, 70.0)
			draw_arc(
				contact_point,
				lerpf(24.0, 86.0, splash_progress),
				PI + 0.20,
				TAU - 0.20,
				28,
				Color(0.88, 1.0, 1.0, splash_alpha),
				4.0,
				true
			)

	var raft_size := Vector2(152.0, 152.0)
	draw_set_transform(raft_position, raft_rotation, raft_scale)
	draw_texture_rect(OPENING_ARRIVAL_RAFT, Rect2(-raft_size * 0.5, raft_size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var caption_rect := Rect2(24.0, 72.0, 672.0, 86.0)
	draw_rect(
		Rect2(caption_rect.position + Vector2(0.0, 6.0), caption_rect.size),
		Color(0.01, 0.05, 0.08, 0.30)
	)
	draw_rect(caption_rect, Color(0.02, 0.12, 0.18, 0.76))
	var trim_color := Color(0.94, 0.79, 0.54, 0.82)
	draw_line(caption_rect.position + Vector2(14.0, 5.0), Vector2(caption_rect.end.x - 14.0, caption_rect.position.y + 5.0), trim_color, 2.0)
	draw_line(Vector2(caption_rect.position.x + 14.0, caption_rect.end.y - 5.0), caption_rect.end - Vector2(14.0, 5.0), trim_color, 2.0)
	var caption_position := Vector2(caption_rect.position.x + 16.0, caption_rect.position.y + 56.0)
	var caption_width := caption_rect.size.x - 32.0
	draw_string(
		OPENING_CAPTION_FONT,
		caption_position + Vector2(2.0, 3.0),
		"Finally, they reach a land.",
		HORIZONTAL_ALIGNMENT_CENTER,
		caption_width,
		32,
		Color(0.0, 0.0, 0.0, 0.68)
	)
	draw_string(
		OPENING_CAPTION_FONT,
		caption_position,
		"Finally, they reach a land.",
		HORIZONTAL_ALIGNMENT_CENTER,
		caption_width,
		32,
		Color(1.0, 0.95, 0.84)
	)


func draw_opening_beach_preview() -> void:
	draw_texture_cover(OPENING_BEACH, Rect2(Vector2.ZERO, VIEW_SIZE))

	var boy_rect := Rect2(98.0, 650.0, 540.0, 585.0)
	draw_texture_rect(OPENING_FAT_BOY_BEACH, boy_rect, false)

	var bubble_rect := Rect2(26.0, 465.0, 668.0, 145.0)
	var bubble_color := Color(0.92, 0.97, 1.0, 0.97)
	var ink_color := Color(0.055, 0.11, 0.14)
	var speaker_point := Vector2(282.0, 710.0)
	var tail_anchor_x := 282.0
	var tail_points := PackedVector2Array([
		Vector2(tail_anchor_x - 11.0, bubble_rect.end.y - 3.0),
		Vector2(tail_anchor_x + 11.0, bubble_rect.end.y - 3.0),
		speaker_point,
	])
	draw_colored_polygon(tail_points, bubble_color)
	draw_polyline(PackedVector2Array([
		Vector2(tail_anchor_x - 11.0, bubble_rect.end.y - 1.0),
		speaker_point,
		Vector2(tail_anchor_x + 11.0, bubble_rect.end.y - 1.0),
	]), ink_color, 3.0, true)

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = bubble_color
	bubble_style.border_color = ink_color
	bubble_style.set_border_width_all(3)
	bubble_style.set_corner_radius_all(22)
	bubble_style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	bubble_style.shadow_size = 7
	bubble_style.shadow_offset = Vector2(0.0, 5.0)
	draw_style_box(bubble_style, bubble_rect)

	var dialogue_lines := [
		"I wanna go home.",
		"There is no food here.",
	]
	for line_index in dialogue_lines.size():
		draw_string(
			OPENING_CAPTION_FONT,
			Vector2(bubble_rect.position.x + 20.0, bubble_rect.position.y + 54.0 + float(line_index) * 43.0),
			dialogue_lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			bubble_rect.size.x - 40.0,
			32,
			ink_color
		)


func draw_opening_fat_raft2_preview() -> void:
	draw_texture_cover(OPENING_FAT_BOY_RAFT2, Rect2(Vector2.ZERO, VIEW_SIZE))

	var bubble_rect := Rect2(32.0, 290.0, 656.0, 132.0)
	var bubble_color := Color(0.96, 0.985, 1.0, 0.97)
	var ink_color := Color(0.055, 0.11, 0.14)
	var speaker_point := Vector2(365.0, 535.0)
	var tail_anchor_x := 365.0
	var tail_points := PackedVector2Array([
		Vector2(tail_anchor_x - 13.0, bubble_rect.end.y - 3.0),
		Vector2(tail_anchor_x + 13.0, bubble_rect.end.y - 3.0),
		speaker_point,
	])
	draw_colored_polygon(tail_points, bubble_color)
	draw_polyline(PackedVector2Array([
		Vector2(tail_anchor_x - 13.0, bubble_rect.end.y - 1.0),
		speaker_point,
		Vector2(tail_anchor_x + 13.0, bubble_rect.end.y - 1.0),
	]), ink_color, 3.0, true)

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = bubble_color
	bubble_style.border_color = ink_color
	bubble_style.set_border_width_all(3)
	bubble_style.set_corner_radius_all(22)
	bubble_style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	bubble_style.shadow_size = 7
	bubble_style.shadow_offset = Vector2(0.0, 5.0)
	draw_style_box(bubble_style, bubble_rect)

	var lines := [
		"Oh... You are right. I don't know",
		"why I even said that.",
	]
	for line_index in lines.size():
		draw_string(
			OPENING_CAPTION_FONT,
			Vector2(bubble_rect.position.x + 20.0, bubble_rect.position.y + 48.0 + float(line_index) * 43.0),
			lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			bubble_rect.size.x - 40.0,
			29,
			ink_color
		)


func draw_opening_skinny_raft_preview() -> void:
	draw_texture_cover(OPENING_SKINNY_BOY_RAFT, Rect2(Vector2.ZERO, VIEW_SIZE))

	var bubble_rect := Rect2(24.0, 48.0, 672.0, 176.0)
	var bubble_color := Color(1.0, 0.975, 0.90, 0.97)
	var ink_color := Color(0.055, 0.11, 0.14)
	var speaker_point := Vector2(300.0, 310.0)
	var tail_anchor_x := 300.0
	var tail_points := PackedVector2Array([
		Vector2(tail_anchor_x - 13.0, bubble_rect.end.y - 3.0),
		Vector2(tail_anchor_x + 13.0, bubble_rect.end.y - 3.0),
		speaker_point,
	])
	draw_colored_polygon(tail_points, bubble_color)
	draw_polyline(PackedVector2Array([
		Vector2(tail_anchor_x - 13.0, bubble_rect.end.y - 1.0),
		speaker_point,
		Vector2(tail_anchor_x + 13.0, bubble_rect.end.y - 1.0),
	]), ink_color, 3.0, true)

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = bubble_color
	bubble_style.border_color = ink_color
	bubble_style.set_border_width_all(3)
	bubble_style.set_corner_radius_all(22)
	bubble_style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	bubble_style.shadow_size = 7
	bubble_style.shadow_offset = Vector2(0.0, 5.0)
	draw_style_box(bubble_style, bubble_rect)

	var lines := [
		"Rob... There is perfectly enough space",
		"for both of us to survive.",
		"Nobody needs to let go.",
	]
	for line_index in lines.size():
		draw_string(
			OPENING_CAPTION_FONT,
			Vector2(bubble_rect.position.x + 20.0, bubble_rect.position.y + 48.0 + float(line_index) * 43.0),
			lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			bubble_rect.size.x - 40.0,
			29,
			ink_color
		)


func draw_opening_fat_raft_preview() -> void:
	draw_texture_cover(OPENING_FAT_BOY_RAFT, Rect2(Vector2.ZERO, VIEW_SIZE))

	var bubble_rect := Rect2(28.0, 350.0, 664.0, 176.0)
	var bubble_color := Color(0.96, 0.985, 1.0, 0.97)
	var ink_color := Color(0.055, 0.11, 0.14)
	var speaker_point := Vector2(405.0, 650.0)
	var tail_anchor_x := 410.0
	var tail_points := PackedVector2Array([
		Vector2(tail_anchor_x - 13.0, bubble_rect.end.y - 3.0),
		Vector2(tail_anchor_x + 13.0, bubble_rect.end.y - 3.0),
		speaker_point,
	])
	draw_colored_polygon(tail_points, bubble_color)
	draw_polyline(PackedVector2Array([
		Vector2(tail_anchor_x - 13.0, bubble_rect.end.y - 1.0),
		speaker_point,
		Vector2(tail_anchor_x + 13.0, bubble_rect.end.y - 1.0),
	]), ink_color, 3.0, true)

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = bubble_color
	bubble_style.border_color = ink_color
	bubble_style.set_border_width_all(3)
	bubble_style.set_corner_radius_all(22)
	bubble_style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	bubble_style.shadow_size = 7
	bubble_style.shadow_offset = Vector2(0.0, 5.0)
	draw_style_box(bubble_style, bubble_rect)

	var lines := [
		"You will survive, Jack! Promise me that.",
		"I am letting go of this raft so at least",
		"one of us can live.",
	]
	for line_index in lines.size():
		draw_string(
			OPENING_CAPTION_FONT,
			Vector2(bubble_rect.position.x + 20.0, bubble_rect.position.y + 48.0 + float(line_index) * 43.0),
			lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			bubble_rect.size.x - 40.0,
			29,
			ink_color
		)


func draw_opening_raft_preview() -> void:
	draw_texture_cover(OPENING_RAFT_BACKGROUND, Rect2(Vector2.ZERO, VIEW_SIZE))

	var bob := sin(state_time * 2.457) * 4.2
	var roll := deg_to_rad(1.8) * sin(state_time * 1.638)
	var texture_size := OPENING_BOYS_AND_RAFT.get_size()
	var raft_width := VIEW_SIZE.x * 0.94
	var raft_size := Vector2(raft_width, raft_width * texture_size.y / texture_size.x)
	var raft_center := Vector2(VIEW_SIZE.x * 0.5, VIEW_SIZE.y * 0.68 + bob)
	draw_set_transform(raft_center, roll, Vector2.ONE)
	draw_texture_rect(OPENING_BOYS_AND_RAFT, Rect2(-raft_size * 0.5, raft_size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_opening_raft_caption()


func draw_opening_raft_caption() -> void:
	var panel_rect := Rect2(24.0, 72.0, 672.0, 112.0)
	draw_rect(
		Rect2(panel_rect.position + Vector2(0.0, 6.0), panel_rect.size),
		Color(0.01, 0.05, 0.08, 0.30)
	)
	draw_rect(panel_rect, Color(0.02, 0.12, 0.18, 0.76))
	var trim_color := Color(0.94, 0.79, 0.54, 0.82)
	draw_line(panel_rect.position + Vector2(14.0, 5.0), Vector2(panel_rect.end.x - 14.0, panel_rect.position.y + 5.0), trim_color, 2.0)
	draw_line(Vector2(panel_rect.position.x + 14.0, panel_rect.end.y - 5.0), panel_rect.end - Vector2(14.0, 5.0), trim_color, 2.0)
	var caption_lines := [
		"As the boys hold onto the raft,",
		"the current carries them in an unknown direction...",
	]
	for line_index in caption_lines.size():
		var text_position := Vector2(panel_rect.position.x + 16.0, panel_rect.position.y + 45.0 + float(line_index) * 38.0)
		var text_width := panel_rect.size.x - 32.0
		draw_string(
			OPENING_CAPTION_FONT,
			text_position + Vector2(2.0, 3.0),
			caption_lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			text_width,
			27,
			Color(0.0, 0.0, 0.0, 0.68)
		)
		draw_string(
			OPENING_CAPTION_FONT,
			text_position,
			caption_lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			text_width,
			27,
			Color(1.0, 0.95, 0.84)
		)


func draw_opening() -> void:
	var party_start := OPENING_EXTERIOR_DURATION
	var exterior_transition_start := party_start - OPENING_EXTERIOR_TRANSITION_DURATION
	var transition_start := party_start + OPENING_PAN_DURATION
	var static_start := transition_start + OPENING_TRANSITION_DURATION

	if state_time < exterior_transition_start:
		draw_opening_exterior_ship(1.0)
	elif state_time < party_start:
		var exterior_transition := smoothstep(
			0.0,
			1.0,
			clampf(
				(state_time - exterior_transition_start) / OPENING_EXTERIOR_TRANSITION_DURATION,
				0.0,
				1.0
			)
		)
		draw_opening_exterior_ship(1.0)
		draw_opening_party_pan(0.0, exterior_transition)
	elif state_time < transition_start:
		var pan_progress := smoothstep(0.0, 1.0, clampf((state_time - party_start) / OPENING_PAN_DURATION, 0.0, 1.0))
		draw_opening_party_pan(pan_progress)
	elif state_time < static_start:
		var transition_progress := smoothstep(
			0.0,
			1.0,
			clampf((state_time - transition_start) / OPENING_TRANSITION_DURATION, 0.0, 1.0)
		)
		draw_opening_party_pan(1.0)
		draw_opening_ship_scene(transition_progress)
	else:
		var deck_time := state_time - static_start
		var damaged_start := OPENING_IMPACT_TIME + OPENING_IMPACT_DURATION
		var captain_start := damaged_start + OPENING_DAMAGED_TRANSITION_DURATION + OPENING_DAMAGED_TURN_DURATION
		var passengers_start := captain_start + OPENING_CAPTAIN_TRANSITION_DURATION + OPENING_CAPTAIN_HOLD_DURATION
		var passengers_active_start := passengers_start + OPENING_PASSENGERS_TRANSITION_DURATION
		var breakup_start := passengers_active_start + OPENING_PASSENGERS_HOLD_DURATION
		var breakup_active_start := breakup_start + OPENING_BREAKUP_TRANSITION_DURATION
		var planks_start := breakup_active_start + OPENING_BREAKUP_DURATION
		var raft_transition_start := planks_start + OPENING_PLANKS_HOLD_DURATION
		var raft_start := raft_transition_start + OPENING_RAFT_TRANSITION_DURATION
		var fat_raft_transition_start := raft_start + OPENING_RAFT_HOLD_DURATION
		var fat_raft_start := fat_raft_transition_start + OPENING_FAT_RAFT_TRANSITION_DURATION
		var skinny_raft_transition_start := fat_raft_start + OPENING_FAT_RAFT_HOLD_DURATION
		var skinny_raft_start := skinny_raft_transition_start + OPENING_SKINNY_RAFT_TRANSITION_DURATION
		var fat_raft2_transition_start := skinny_raft_start + OPENING_SKINNY_RAFT_HOLD_DURATION
		var fat_raft2_start := fat_raft2_transition_start + OPENING_FAT_RAFT2_TRANSITION_DURATION
		var island_transition_start := fat_raft2_start + OPENING_FAT_RAFT2_HOLD_DURATION
		var island_start := island_transition_start + OPENING_ISLAND_TRANSITION_DURATION
		var beach_transition_start := island_start + OPENING_ISLAND_ARRIVAL_DURATION
		var beach_start := beach_transition_start + OPENING_BEACH_TRANSITION_DURATION
		var end_fade_start := beach_start + OPENING_BEACH_HOLD_DURATION
		if deck_time < damaged_start:
			draw_opening_ship_scene(1.0)
		elif deck_time < damaged_start + OPENING_DAMAGED_TRANSITION_DURATION:
			var damaged_transition := smoothstep(
				0.0,
				1.0,
				clampf(
					(deck_time - damaged_start) / OPENING_DAMAGED_TRANSITION_DURATION,
					0.0,
					1.0
				)
			)
			draw_opening_ship_scene(1.0 - damaged_transition)
			draw_opening_damaged_scene(damaged_transition, deck_time - damaged_start)
		elif deck_time < captain_start:
			draw_opening_damaged_scene(1.0, deck_time - damaged_start)
		elif deck_time < captain_start + OPENING_CAPTAIN_TRANSITION_DURATION:
			var captain_transition := smoothstep(
				0.0,
				1.0,
				clampf(
					(deck_time - captain_start) / OPENING_CAPTAIN_TRANSITION_DURATION,
					0.0,
					1.0
				)
			)
			draw_opening_damaged_scene(1.0 - captain_transition, deck_time - damaged_start)
			draw_opening_captain_scene(captain_transition)
		elif deck_time < passengers_start:
			draw_opening_captain_scene(1.0)
		elif deck_time < passengers_active_start:
			var passengers_transition := smoothstep(
				0.0,
				1.0,
				clampf(
					(deck_time - passengers_start) / OPENING_PASSENGERS_TRANSITION_DURATION,
					0.0,
					1.0
				)
			)
			draw_opening_captain_scene(1.0 - passengers_transition)
			draw_opening_passengers_scene(passengers_transition, deck_time - passengers_start)
		elif deck_time < breakup_start:
			draw_opening_passengers_scene(1.0, deck_time - passengers_start)
		elif deck_time < breakup_active_start:
			var breakup_transition := smoothstep(
				0.0,
				1.0,
				clampf(
					(deck_time - breakup_start) / OPENING_BREAKUP_TRANSITION_DURATION,
					0.0,
					1.0
				)
			)
			draw_opening_passengers_scene(1.0 - breakup_transition, deck_time - passengers_start)
			draw_opening_breakup_scene(breakup_transition, 0.0)
		elif deck_time < planks_start:
			draw_opening_breakup_scene(1.0, deck_time - breakup_active_start)
		elif deck_time < raft_transition_start:
			draw_opening_planks_scene(
				1.0,
				deck_time - breakup_active_start - OPENING_BREAKUP_SWAP_TIME
			)
		elif deck_time < raft_start:
			var transition_time := deck_time - raft_transition_start
			if transition_time < OPENING_RAFT_TRANSITION_DURATION * 0.5:
				draw_opening_planks_scene(1.0, deck_time - breakup_active_start - OPENING_BREAKUP_SWAP_TIME)
			else:
				draw_opening_raft_preview()
			draw_opening_black_transition(transition_time, OPENING_RAFT_TRANSITION_DURATION)
		elif deck_time < fat_raft_transition_start:
			draw_opening_raft_preview()
		elif deck_time < fat_raft_start:
			var transition_time := deck_time - fat_raft_transition_start
			if transition_time < OPENING_FAT_RAFT_TRANSITION_DURATION * 0.5:
				draw_opening_raft_preview()
			else:
				draw_opening_fat_raft_preview()
			draw_opening_black_transition(transition_time, OPENING_FAT_RAFT_TRANSITION_DURATION)
		elif deck_time < skinny_raft_transition_start:
			draw_opening_fat_raft_preview()
		elif deck_time < skinny_raft_start:
			var transition_time := deck_time - skinny_raft_transition_start
			if transition_time < OPENING_SKINNY_RAFT_TRANSITION_DURATION * 0.5:
				draw_opening_fat_raft_preview()
			else:
				draw_opening_skinny_raft_preview()
			draw_opening_black_transition(transition_time, OPENING_SKINNY_RAFT_TRANSITION_DURATION)
		elif deck_time < fat_raft2_transition_start:
			draw_opening_skinny_raft_preview()
		elif deck_time < fat_raft2_start:
			var transition_time := deck_time - fat_raft2_transition_start
			if transition_time < OPENING_FAT_RAFT2_TRANSITION_DURATION * 0.5:
				draw_opening_skinny_raft_preview()
			else:
				draw_opening_fat_raft2_preview()
			draw_opening_black_transition(transition_time, OPENING_FAT_RAFT2_TRANSITION_DURATION)
		elif deck_time < island_transition_start:
			draw_opening_fat_raft2_preview()
		elif deck_time < island_start:
			var transition_time := deck_time - island_transition_start
			if transition_time < OPENING_ISLAND_TRANSITION_DURATION * 0.5:
				draw_opening_fat_raft2_preview()
			else:
				draw_opening_island_arrival(0.0)
			draw_opening_black_transition(transition_time, OPENING_ISLAND_TRANSITION_DURATION)
		elif deck_time < beach_transition_start:
			draw_opening_island_arrival(deck_time - island_start)
		elif deck_time < beach_start:
			var transition_time := deck_time - beach_transition_start
			if transition_time < OPENING_BEACH_TRANSITION_DURATION * 0.5:
				draw_opening_island_arrival(OPENING_ISLAND_ARRIVAL_DURATION)
			else:
				draw_opening_beach_preview()
			draw_opening_black_transition(transition_time, OPENING_BEACH_TRANSITION_DURATION)
		else:
			draw_opening_beach_preview()
			if deck_time >= end_fade_start:
				var fade_progress := smoothstep(
					0.0,
					1.0,
					clampf((deck_time - end_fade_start) / OPENING_END_FADE_DURATION, 0.0, 1.0)
				)
				draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.0, 0.0, 0.0, fade_progress))

	if state_time < static_start:
		draw_opening_exterior_caption(1.0)
	draw_button(opening_skip_button, "SKIP", true, Color("#d16b48"), 0.94, 33)


func draw_opening_black_transition(transition_time: float, duration: float) -> void:
	var ratio := clampf(transition_time / duration, 0.0, 1.0)
	var black_alpha := 0.0
	if ratio < 0.5:
		black_alpha = smoothstep(0.0, 1.0, ratio * 2.0)
	else:
		black_alpha = 1.0 - smoothstep(0.0, 1.0, (ratio - 0.5) * 2.0)
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.0, 0.0, 0.0, black_alpha))


func draw_opening_exterior_ship(alpha: float) -> void:
	var tint := Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0))
	var ship_width := VIEW_SIZE.x * 0.75
	var ship_size := Vector2(ship_width, ship_width * OPENING_EXTERIOR_SHIP.get_height() / OPENING_EXTERIOR_SHIP.get_width())
	var ship_center := Vector2(VIEW_SIZE.x * 0.5, VIEW_SIZE.y * 0.50 + sin(state_time * 1.35) * 3.0)
	var wake_pulse := 1.0 + sin(state_time * 2.4) * 0.035
	var wake_size := Vector2(112.0, 280.0) * wake_pulse
	var wake_center := Vector2(13.0, ship_center.y + 15.0)
	var wake_tint := Color(1.0, 1.0, 1.0, tint.a * 0.58)
	draw_set_transform(wake_center, PI * 0.5, Vector2.ONE)
	draw_texture_rect(RAFT_WAKE_TEXTURE, Rect2(-wake_size * 0.5, wake_size), false, wake_tint)
	draw_set_transform(ship_center, sin(state_time * 1.05) * 0.006, Vector2.ONE)
	draw_texture_rect(OPENING_EXTERIOR_SHIP, Rect2(-ship_size * 0.5, ship_size), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_opening_exterior_caption(alpha: float) -> void:
	var fade_in := smoothstep(0.0, 1.0, clampf(state_time / 0.55, 0.0, 1.0))
	var fade_out_start := OPENING_EXTERIOR_DURATION + OPENING_PAN_DURATION
	var fade_out := 1.0 - smoothstep(
		0.0,
		1.0,
		clampf(
			(state_time - fade_out_start) / OPENING_TRANSITION_DURATION,
			0.0,
			1.0
		)
	)
	var caption_alpha := clampf(alpha * fade_in * fade_out, 0.0, 1.0)
	var panel_rect := Rect2(26.0, 96.0, 668.0, 108.0)
	draw_rect(
		Rect2(panel_rect.position + Vector2(0.0, 6.0), panel_rect.size),
		Color(0.01, 0.05, 0.08, 0.30 * caption_alpha)
	)
	draw_rect(panel_rect, Color(0.02, 0.12, 0.18, 0.76 * caption_alpha))
	var trim_color := Color(0.94, 0.79, 0.54, 0.82 * caption_alpha)
	draw_line(panel_rect.position + Vector2(14.0, 5.0), Vector2(panel_rect.end.x - 14.0, panel_rect.position.y + 5.0), trim_color, 2.0)
	draw_line(Vector2(panel_rect.position.x + 14.0, panel_rect.end.y - 5.0), panel_rect.end - Vector2(14.0, 5.0), trim_color, 2.0)
	var text_width := panel_rect.size.x - 32.0
	var caption_lines := [
		"Passengers traveling on a luxury cruise",
		"towards Bermudas...",
	]
	for line_index in caption_lines.size():
		var text_position := Vector2(panel_rect.position.x + 16.0, panel_rect.position.y + 44.0 + float(line_index) * 38.0)
		draw_string(
			OPENING_CAPTION_FONT,
			text_position + Vector2(2.0, 3.0),
			caption_lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			text_width,
			27,
			Color(0.0, 0.0, 0.0, 0.68 * caption_alpha)
		)
		draw_string(
			OPENING_CAPTION_FONT,
			text_position,
			caption_lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			text_width,
			27,
			Color(1.0, 0.95, 0.84, caption_alpha)
		)


func draw_opening_damaged_scene(alpha: float, damaged_time: float) -> void:
	var tint := Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0))
	var turn_progress := smoothstep(
		0.0,
		1.0,
		clampf(damaged_time / OPENING_DAMAGED_TURN_DURATION, 0.0, 1.0)
	)
	var ship_width := VIEW_SIZE.x * 0.76
	var ship_size := Vector2(
		ship_width,
		ship_width * OPENING_DAMAGED_SHIP.get_height() / OPENING_DAMAGED_SHIP.get_width()
	)
	var ship_center := Vector2(400.0, 585.0).lerp(Vector2(430.0, 555.0), turn_progress)
	ship_center.y += sin(state_time * 1.25) * 2.5
	var ship_rotation := lerpf(0.0, -0.115, turn_progress)
	draw_set_transform(ship_center, ship_rotation, Vector2.ONE)
	draw_texture_rect(OPENING_DAMAGED_SHIP, Rect2(-ship_size * 0.5, ship_size), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var glacier_size := Vector2(310.0, 310.0)
	var glacier_center := Vector2(278.0, 790.0 + sin(state_time * 0.85) * 2.0)
	draw_texture_rect(OPENING_GLACIER, Rect2(glacier_center - glacier_size * 0.5, glacier_size), false, tint)


func draw_opening_captain_scene(alpha: float) -> void:
	var tint := Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0))
	draw_texture_cover(OPENING_CAPTAIN, Rect2(Vector2.ZERO, VIEW_SIZE), tint)
	draw_opening_captain_dialogue(tint.a)


func draw_opening_captain_dialogue(alpha: float) -> void:
	var bubble_alpha := clampf(alpha, 0.0, 1.0)
	var bubble_rect := Rect2(14.0, 20.0, 314.0, 245.0)
	var bubble_color := Color(1.0, 0.975, 0.90, 0.97 * bubble_alpha)
	var ink_color := Color(0.055, 0.11, 0.14, bubble_alpha)
	var speaker_point := Vector2(367.0, 330.0)
	var tail_points := PackedVector2Array([
		speaker_point,
		Vector2(bubble_rect.end.x - 62.0, bubble_rect.end.y - 3.0),
		Vector2(bubble_rect.end.x - 28.0, bubble_rect.end.y - 3.0),
	])
	draw_colored_polygon(tail_points, bubble_color)
	draw_polyline(PackedVector2Array([
		Vector2(bubble_rect.end.x - 62.0, bubble_rect.end.y - 1.0),
		speaker_point,
		Vector2(bubble_rect.end.x - 28.0, bubble_rect.end.y - 1.0),
	]), ink_color, 3.0, true)

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = bubble_color
	bubble_style.border_color = ink_color
	bubble_style.set_border_width_all(3)
	bubble_style.set_corner_radius_all(22)
	bubble_style.shadow_color = Color(0.0, 0.0, 0.0, 0.25 * bubble_alpha)
	bubble_style.shadow_size = 7
	bubble_style.shadow_offset = Vector2(0.0, 5.0)
	draw_style_box(bubble_style, bubble_rect)

	var lines := [
		"An iceberg in the",
		"tropical seas?! It...",
		"it cannot be. Hark!",
		"Run for ye lives!!",
	]
	for line_index in lines.size():
		draw_string(
			OPENING_CAPTION_FONT,
			Vector2(bubble_rect.position.x + 16.0, bubble_rect.position.y + 51.0 + float(line_index) * 47.0),
			lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			bubble_rect.size.x - 32.0,
			29,
			ink_color
		)


func draw_opening_breakup_scene(alpha: float, breakup_time: float) -> void:
	var scene_alpha := clampf(alpha, 0.0, 1.0)
	var ship_visible := breakup_time < OPENING_BREAKUP_SWAP_TIME
	if ship_visible:
		var shake_ramp := smoothstep(
			0.0,
			1.0,
			clampf(breakup_time / OPENING_BREAKUP_SMOKE_START, 0.0, 1.0)
		)
		var shake_strength := lerpf(1.8, 6.0, shake_ramp)
		var ship_center := Vector2(360.0, 445.0) + Vector2(
			sin(breakup_time * 21.0) * shake_strength,
			cos(breakup_time * 25.0) * shake_strength * 0.55
		)
		var ship_rotation := sin(breakup_time * 18.0) * lerpf(0.004, 0.014, shake_ramp)
		var ship_width := VIEW_SIZE.x * 0.76
		var ship_size := Vector2(
			ship_width,
			ship_width * OPENING_DAMAGED_SHIP.get_height() / OPENING_DAMAGED_SHIP.get_width()
		)
		draw_set_transform(ship_center, ship_rotation, Vector2.ONE)
		draw_texture_rect(
			OPENING_DAMAGED_SHIP,
			Rect2(-ship_size * 0.5, ship_size),
			false,
			Color(1.0, 1.0, 1.0, scene_alpha)
		)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_opening_planks_scene(
			scene_alpha,
			breakup_time - OPENING_BREAKUP_SWAP_TIME
		)

	if breakup_time >= OPENING_BREAKUP_SMOKE_START:
		draw_opening_breakup_smoke(breakup_time, scene_alpha)


func draw_opening_breakup_smoke(breakup_time: float, scene_alpha: float) -> void:
	var build_progress := smoothstep(
		0.0,
		1.0,
		clampf(
			(breakup_time - OPENING_BREAKUP_SMOKE_START) /
			(OPENING_BREAKUP_SWAP_TIME - OPENING_BREAKUP_SMOKE_START),
			0.0,
			1.0
		)
	)
	var clear_progress := smoothstep(
		0.0,
		1.0,
		clampf(
			(breakup_time - OPENING_BREAKUP_SWAP_TIME) /
			(OPENING_BREAKUP_DURATION - OPENING_BREAKUP_SWAP_TIME),
			0.0,
			1.0
		)
	)
	var smoke_alpha := build_progress * (1.0 - clear_progress) * scene_alpha
	var smoke_origin := Vector2(245.0, 500.0)
	for smoke_index in 42:
		var index_value := float(smoke_index)
		var horizontal_seed := fposmod(sin((index_value + 1.0) * 12.9898) * 43758.5453, 1.0) * 2.0 - 1.0
		var vertical_seed := fposmod(sin((index_value + 7.0) * 78.233) * 12515.873, 1.0) * 2.0 - 1.0
		var cloud_target := Vector2(360.0, 445.0) + Vector2(horizontal_seed * 270.0, vertical_seed * 145.0)
		var cloud_position := smoke_origin.lerp(cloud_target, build_progress)
		cloud_position += Vector2(
			horizontal_seed * clear_progress * 115.0,
			-clear_progress * (75.0 + absf(vertical_seed) * 55.0)
		)
		cloud_position += Vector2(
			sin(breakup_time * 1.4 + index_value) * 5.0,
			cos(breakup_time * 1.1 + index_value * 1.7) * 4.0
		)
		var radius_seed := fposmod(sin((index_value + 3.0) * 39.3467) * 24634.6345, 1.0)
		var radius := lerpf(38.0, 72.0, radius_seed) * lerpf(0.45, 1.0, build_progress)
		var dark_smoke := Color(0.20, 0.25, 0.27, smoke_alpha * 0.68)
		var light_smoke := Color(0.62, 0.66, 0.66, smoke_alpha * 0.80)
		draw_circle(cloud_position + Vector2(3.0, 6.0), radius * 1.05, dark_smoke)
		draw_circle(cloud_position, radius, light_smoke)
		draw_circle(
			cloud_position - Vector2(radius * 0.20, radius * 0.24),
			radius * 0.55,
			Color(0.82, 0.84, 0.82, smoke_alpha * 0.42)
		)


func draw_opening_planks_scene(alpha: float, debris_time: float) -> void:
	var tint := Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0))
	for plank_index in OPENING_PLANK_LAYOUT.size():
		var plank: Dictionary = OPENING_PLANK_LAYOUT[plank_index]
		var phase := float(plank_index) * 1.37
		var bob_offset := Vector2(
			sin(debris_time * 0.72 + phase) * 2.2,
			sin(debris_time * 1.08 + phase) * 4.0
		)
		var rotation: float = plank["rotation"] + sin(debris_time * 0.62 + phase) * 0.025
		var plank_size := Vector2.ONE * float(plank["size"])
		draw_set_transform(plank["position"] + bob_offset, rotation, Vector2.ONE)
		draw_texture_rect(OPENING_PLANKS, Rect2(-plank_size * 0.5, plank_size), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_opening_passengers_scene(alpha: float, scene_time: float) -> void:
	var scene_alpha := clampf(alpha, 0.0, 1.0)
	var tint := Color(1.0, 1.0, 1.0, scene_alpha)
	var ship_pivot := Vector2(360.0, 900.0)
	var ship_roll := deg_to_rad(4.0) * sin(scene_time * 0.90)
	draw_texture_cover(OPENING_PASSENGER_BACKGROUND, Rect2(Vector2.ZERO, VIEW_SIZE), tint)
	var ship_target := Rect2(-60.0, VIEW_SIZE.y * 0.30 + 30.0, VIEW_SIZE.x + 120.0, VIEW_SIZE.y * 0.70)
	var ship_texture_size := OPENING_PASSENGER_SHIP.get_size()
	var usable_ship_height := ship_texture_size.y * 0.75
	var ship_source_width := usable_ship_height * ship_target.size.x / ship_target.size.y
	var ship_source := Rect2(
		(ship_texture_size.x - ship_source_width) * 0.5,
		0.0,
		ship_source_width,
		usable_ship_height
	)
	var ship_transform_origin := ship_pivot - ship_pivot.rotated(ship_roll)
	draw_set_transform(ship_transform_origin, ship_roll, Vector2.ONE)
	draw_texture_rect_region(
		OPENING_PASSENGER_SHIP,
		ship_target,
		ship_source,
		tint
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var man_rect := Rect2(120.0, 580.0, 280.0, 420.0)
	var man_center := ship_pivot + (man_rect.get_center() - ship_pivot).rotated(ship_roll)
	var breath_scale := 1.0 + sin(scene_time * 1.8) * 0.03
	draw_set_transform(man_center, ship_roll, Vector2.ONE * breath_scale)
	draw_texture_rect(
		OPENING_PASSENGER_MAN,
		Rect2(-man_rect.size * 0.5, man_rect.size),
		false,
		tint
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var woman2_move_offset := Vector2(
		36.0 - fposmod(scene_time * 50.0, 940.0),
		sin(scene_time * 2.90 + 2.8) * 2.2
	)
	draw_opening_layered_woman(
		OPENING_WOMAN_2,
		OPENING_WOMAN_2_RIGHT_ARM,
		OPENING_WOMAN_2_LEFT_ARM,
		Rect2(410.0, 580.0, 270.0, 405.0),
		Vector2(0.330, 0.285),
		Vector2(0.550, 0.300),
		Vector2(0.880, 0.100),
		Vector2(0.150, 0.095),
		Vector2(-6.0, 5.0),
		Vector2(-9.0, -5.0),
		0.35,
		0.35,
		0.0,
		0.0,
		woman2_move_offset,
		false,
		false,
		true,
		ship_pivot,
		ship_roll,
		tint
	)
	var woman1_run_phase := scene_time * 27.04
	var woman1_run_offset := Vector2(
		fposmod(scene_time * 141.96, 940.0) - 103.0,
		sin(woman1_run_phase) * 5.0
	)
	draw_opening_layered_woman(
		OPENING_WOMAN_1,
		OPENING_WOMAN_1_RIGHT_ARM,
		OPENING_WOMAN_1_LEFT_ARM,
		Rect2(-53.0, 701.0, 459.0, 686.0),
		Vector2(0.475, 0.280),
		Vector2(0.665, 0.285),
		Vector2(0.820, 0.830),
		Vector2(0.400, 0.180),
		Vector2(2.0, -9.0),
		Vector2(33.0, 14.0),
		0.34125,
		0.4275,
		sin(woman1_run_phase) * 0.16,
		-sin(woman1_run_phase) * 0.16,
		woman1_run_offset,
		false,
		true,
		false,
		ship_pivot,
		ship_roll,
		tint
	)

	# A separate, oversized rail sits in the foreground. Its bottom edge is just
	# outside the viewport, so it feels close to the camera and covers the feet.
	var rail_center_base := Vector2(360.0, 1095.0)
	var rail_center := ship_pivot + (rail_center_base - ship_pivot).rotated(ship_roll)
	draw_set_transform(rail_center, deg_to_rad(-10.0) + ship_roll, Vector2.ONE)
	draw_texture_rect(OPENING_RAIL, Rect2(-750.0, -250.0, 1500.0, 500.0), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_opening_layered_woman(
	body_texture: Texture2D,
	left_arm_texture: Texture2D,
	right_arm_texture: Texture2D,
	character_rect: Rect2,
	left_shoulder: Vector2,
	right_shoulder: Vector2,
	left_arm_socket: Vector2,
	right_arm_socket: Vector2,
	left_arm_seam_offset: Vector2,
	right_arm_seam_offset: Vector2,
	left_arm_scale: float,
	right_arm_scale: float,
	left_arm_rotation: float,
	right_arm_rotation: float,
	offset: Vector2,
	draw_shoulder_patches: bool,
	left_arm_in_front: bool,
	right_arm_in_front: bool,
	world_pivot: Vector2,
	world_rotation: float,
	tint: Color
) -> void:
	var base_center := character_rect.get_center() + offset
	var character_center := world_pivot + (base_center - world_pivot).rotated(world_rotation)
	if not left_arm_in_front:
		draw_opening_aligned_arm(
			left_arm_texture,
			character_center,
			character_rect.size,
			world_rotation,
			left_shoulder,
			left_arm_socket,
			left_arm_seam_offset,
			left_arm_scale,
			left_arm_rotation,
			tint
		)
	if not right_arm_in_front:
		draw_opening_aligned_arm(
			right_arm_texture,
			character_center,
			character_rect.size,
			world_rotation,
			right_shoulder,
			right_arm_socket,
			right_arm_seam_offset,
			right_arm_scale,
			right_arm_rotation,
			tint
		)
	draw_set_transform(character_center, world_rotation, Vector2.ONE)
	draw_texture_rect(body_texture, Rect2(-character_rect.size * 0.5, character_rect.size), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if draw_shoulder_patches:
		draw_opening_shoulder_patch(character_center, character_rect.size, world_rotation, left_shoulder, -0.18, tint.a)
		draw_opening_shoulder_patch(character_center, character_rect.size, world_rotation, right_shoulder, 0.18, tint.a)
	if left_arm_in_front:
		draw_opening_aligned_arm(
			left_arm_texture,
			character_center,
			character_rect.size,
			world_rotation,
			left_shoulder,
			left_arm_socket,
			left_arm_seam_offset,
			left_arm_scale,
			left_arm_rotation,
			tint
		)
	if right_arm_in_front:
		draw_opening_aligned_arm(
			right_arm_texture,
			character_center,
			character_rect.size,
			world_rotation,
			right_shoulder,
			right_arm_socket,
			right_arm_seam_offset,
			right_arm_scale,
			right_arm_rotation,
			tint
		)


func draw_opening_aligned_arm(
	arm_texture: Texture2D,
	character_center: Vector2,
	character_size: Vector2,
	character_rotation: float,
	shoulder: Vector2,
	arm_socket: Vector2,
	seam_offset: Vector2,
	arm_scale: float,
	arm_rotation: float,
	tint: Color
) -> void:
	var arm_height := character_size.y * arm_scale
	var arm_size := Vector2(
		arm_height * arm_texture.get_width() / arm_texture.get_height(),
		arm_height
	)
	var shoulder_local := character_size * (shoulder - Vector2(0.5, 0.5)) + seam_offset
	var shoulder_position := character_center + shoulder_local.rotated(character_rotation)
	var arm_rect := Rect2(-arm_size * arm_socket, arm_size)
	draw_set_transform(shoulder_position, character_rotation + arm_rotation, Vector2.ONE)
	draw_texture_rect(arm_texture, arm_rect, false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_opening_shoulder_patch(character_center: Vector2, character_size: Vector2, character_rotation: float, shoulder: Vector2, rotation: float, alpha: float) -> void:
	var shoulder_local := character_size * (shoulder - Vector2(0.5, 0.5))
	var center := character_center + shoulder_local.rotated(character_rotation)
	var patch_scale := character_size.y / 620.0
	draw_set_transform(center, character_rotation + rotation, Vector2(0.86, 1.18) * patch_scale)
	draw_circle(Vector2.ZERO, 25.0, Color(0.48, 0.38, 0.26, alpha * 0.82))
	draw_circle(Vector2.ZERO, 22.5, Color(0.94, 0.87, 0.70, alpha))
	var fold_color := Color(0.67, 0.56, 0.42, alpha * 0.64)
	for fold_index in range(-2, 3):
		var fold_x := float(fold_index) * 7.0
		draw_polyline(
			PackedVector2Array([
				Vector2(fold_x, -18.0),
				Vector2(fold_x * 0.62, 0.0),
				Vector2(fold_x * 0.34, 18.0),
			]),
			fold_color,
			1.35,
			true
		)
	draw_arc(Vector2.ZERO, 18.2, 0.25, 2.90, 20, Color(0.48, 0.61, 0.68, alpha * 0.50), 1.7, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_opening_party_pan(progress: float, alpha: float = 1.0) -> void:
	var texture_size := OPENING_PARTY_TEXTURE.get_size()
	var source_height := texture_size.y * 0.80
	var source_width := source_height * VIEW_SIZE.x / VIEW_SIZE.y
	var source_y := texture_size.y * 0.10
	var source_x := lerpf(0.0, texture_size.x - source_width, clampf(progress, 0.0, 1.0))
	var source_rect := Rect2(Vector2(source_x, source_y), Vector2(source_width, source_height))
	draw_texture_rect_region(OPENING_PARTY_TEXTURE, Rect2(Vector2.ZERO, VIEW_SIZE), source_rect, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))


func draw_opening_ship_scene(alpha: float) -> void:
	var tint := Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0))
	var deck_time := state_time - opening_deck_start_time()
	var shake_offset := Vector2.ZERO
	var shake_rotation := 0.0
	if deck_time >= OPENING_IMPACT_TIME and deck_time < OPENING_IMPACT_TIME + OPENING_IMPACT_DURATION:
		var impact_elapsed := deck_time - OPENING_IMPACT_TIME
		var shake_strength := 1.0 - impact_elapsed / OPENING_IMPACT_DURATION
		shake_offset = Vector2(
			sin(impact_elapsed * 78.0) * 13.0,
			cos(impact_elapsed * 91.0) * 9.0
		) * shake_strength
		shake_rotation = sin(impact_elapsed * 67.0) * 0.012 * shake_strength
	draw_set_transform(shake_offset, shake_rotation, Vector2.ONE)
	draw_texture_cover(OPENING_SHIP_BACKGROUND, Rect2(-18.0, -18.0, VIEW_SIZE.x + 36.0, VIEW_SIZE.y + 36.0), tint, 1.14)

	var nerd_breath := sin(state_time * 1.62 + 0.45)
	var fat_breath := sin(state_time * 1.48)
	var character_scale := 0.90
	var nerd_offset := Vector2(0.0, 200.0)
	var fat_offset := Vector2(0.0, 200.0)
	var nerd_body_rect := transform_character_rect(Rect2(15.0, 390.0, 350.0, 466.0), Vector2(190.0, 856.0), character_scale, nerd_offset)
	var nerd_head_rect := transform_character_rect(Rect2(70.0, 185.0, 260.0, 260.0), Vector2(190.0, 856.0), character_scale, nerd_offset)
	nerd_head_rect.position.y += 20.0
	var fat_body_rect := transform_character_rect(Rect2(330.0, 390.0, 390.0, 520.0), Vector2(525.0, 910.0), character_scale, fat_offset)
	var fat_head_rect := transform_character_rect(Rect2(375.0, 175.0, 300.0, 300.0), Vector2(525.0, 910.0), character_scale, fat_offset)
	var scared_faces_visible := deck_time >= OPENING_IMPACT_TIME + OPENING_IMPACT_DURATION * 0.25
	var nerd_head_texture := OPENING_NERD_SCARED_HEAD if scared_faces_visible else OPENING_NERD_HEAD
	var fat_head_texture := OPENING_FAT_SCARED_HEAD if scared_faces_visible else OPENING_FAT_HEAD
	draw_opening_character(
		OPENING_NERD_BODY,
		nerd_head_texture,
		nerd_body_rect,
		nerd_head_rect,
		nerd_breath,
		tint
	)
	draw_opening_character(
		OPENING_FAT_BODY,
		fat_head_texture,
		fat_body_rect,
		fat_head_rect,
		fat_breath,
		tint
	)
	draw_texture_rect(OPENING_RAIL, Rect2(-390.0, 890.0, 1500.0, 500.0), false, tint)
	draw_opening_dialogue(deck_time, tint.a)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func opening_deck_start_time() -> float:
	return OPENING_EXTERIOR_DURATION + OPENING_PAN_DURATION + OPENING_TRANSITION_DURATION


func opening_passengers_deck_time() -> float:
	return (
		OPENING_IMPACT_TIME + OPENING_IMPACT_DURATION +
		OPENING_DAMAGED_TRANSITION_DURATION + OPENING_DAMAGED_TURN_DURATION +
		OPENING_CAPTAIN_TRANSITION_DURATION + OPENING_CAPTAIN_HOLD_DURATION
	)


func opening_breakup_deck_time() -> float:
	return opening_passengers_deck_time() + OPENING_PASSENGERS_TRANSITION_DURATION + OPENING_PASSENGERS_HOLD_DURATION


func opening_planks_deck_time() -> float:
	return opening_breakup_deck_time() + OPENING_BREAKUP_TRANSITION_DURATION + OPENING_BREAKUP_DURATION


func opening_total_duration() -> float:
	return (
		opening_deck_start_time() + opening_planks_deck_time() +
		OPENING_PLANKS_HOLD_DURATION +
		OPENING_RAFT_TRANSITION_DURATION + OPENING_RAFT_HOLD_DURATION +
		OPENING_FAT_RAFT_TRANSITION_DURATION + OPENING_FAT_RAFT_HOLD_DURATION +
		OPENING_SKINNY_RAFT_TRANSITION_DURATION + OPENING_SKINNY_RAFT_HOLD_DURATION +
		OPENING_FAT_RAFT2_TRANSITION_DURATION + OPENING_FAT_RAFT2_HOLD_DURATION +
		OPENING_ISLAND_TRANSITION_DURATION + OPENING_ISLAND_ARRIVAL_DURATION +
		OPENING_BEACH_TRANSITION_DURATION + OPENING_BEACH_HOLD_DURATION +
		OPENING_END_FADE_DURATION
	)


func draw_opening_dialogue(deck_time: float, scene_alpha: float) -> void:
	if deck_time < OPENING_DIALOGUE_START:
		return

	var dialogue_index := 0
	var dialogue_started_at := OPENING_DIALOGUE_START
	if deck_time >= OPENING_DIALOGUE_FIFTH:
		dialogue_index = 4
		dialogue_started_at = OPENING_DIALOGUE_FIFTH
	elif deck_time >= OPENING_DIALOGUE_FOURTH:
		dialogue_index = 3
		dialogue_started_at = OPENING_DIALOGUE_FOURTH
	elif deck_time >= OPENING_DIALOGUE_THIRD:
		dialogue_index = 2
		dialogue_started_at = OPENING_DIALOGUE_THIRD
	elif deck_time >= OPENING_DIALOGUE_SECOND:
		dialogue_index = 1
		dialogue_started_at = OPENING_DIALOGUE_SECOND

	var lines: Array[String] = []
	var nerd_is_speaking := true
	match dialogue_index:
		0:
			lines = [
				"I told you! We just need to put on",
				"nice clothes and we are in!",
			]
		1:
			nerd_is_speaking = false
			lines = [
				"But what if the captain finds out",
				"we didn't pay?",
			]
		2:
			lines = [
				"He won't. Relax, Robinson.",
				"Let's enjoy...",
			]
		3:
			lines = [
				"...Let's eat. Let's drink and have fun",
				"with these aristocrats!",
			]
		4:
			lines = [
				"Let's grab a drink so you can",
				"rela---",
			]

	var entrance := smoothstep(0.0, 1.0, clampf((deck_time - dialogue_started_at) / 0.20, 0.0, 1.0))
	var bubble_alpha := scene_alpha * entrance
	var dialogue_font_size := 29
	var widest_line := 0.0
	for line in lines:
		widest_line = maxf(
			widest_line,
			OPENING_CAPTION_FONT.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, dialogue_font_size).x
		)
	var bubble_width := clampf(widest_line + 68.0, 280.0, VIEW_SIZE.x - 48.0)
	var bubble_height := 48.0 + float(lines.size()) * 37.0
	var speaker_point := Vector2(200.0, 472.0) if nerd_is_speaking else Vector2(525.0, 448.0)
	var bubble_x := clampf(
		speaker_point.x - bubble_width * 0.5,
		24.0,
		VIEW_SIZE.x - 24.0 - bubble_width
	)
	var bubble_bottom := speaker_point.y - 12.0
	var bubble_rect := Rect2(
		bubble_x,
		bubble_bottom - bubble_height + (1.0 - entrance) * 7.0,
		bubble_width,
		bubble_height
	)
	var bubble_color := Color(1.0, 0.975, 0.90, bubble_alpha) if nerd_is_speaking else Color(0.92, 0.97, 1.0, bubble_alpha)
	var ink_color := Color(0.055, 0.11, 0.14, bubble_alpha)
	var tail_anchor_x := clampf(speaker_point.x, bubble_rect.position.x + 24.0, bubble_rect.end.x - 24.0)
	var tail_points := PackedVector2Array([
		Vector2(tail_anchor_x - 9.0, bubble_rect.end.y - 3.0),
		Vector2(tail_anchor_x + 9.0, bubble_rect.end.y - 3.0),
		speaker_point,
	])
	draw_colored_polygon(tail_points, bubble_color)
	draw_polyline(PackedVector2Array([
		Vector2(tail_anchor_x - 9.0, bubble_rect.end.y - 1.0),
		speaker_point,
		Vector2(tail_anchor_x + 9.0, bubble_rect.end.y - 1.0),
	]), ink_color, 3.0, true)

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = bubble_color
	bubble_style.border_color = ink_color
	bubble_style.set_border_width_all(3)
	bubble_style.set_corner_radius_all(22)
	bubble_style.shadow_color = Color(0.0, 0.0, 0.0, 0.25 * bubble_alpha)
	bubble_style.shadow_size = 7
	bubble_style.shadow_offset = Vector2(0.0, 5.0)
	draw_style_box(bubble_style, bubble_rect)

	var first_baseline := bubble_rect.position.y + 41.0
	for line_index in lines.size():
		draw_string(
			OPENING_CAPTION_FONT,
			Vector2(bubble_rect.position.x + 20.0, first_baseline + float(line_index) * 38.0),
			lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			bubble_rect.size.x - 40.0,
			dialogue_font_size,
			ink_color
		)


func transform_character_rect(rect: Rect2, pivot: Vector2, scale_value: float, offset: Vector2) -> Rect2:
	return Rect2(
		pivot + (rect.position - pivot) * scale_value + offset,
		rect.size * scale_value
	)


func draw_opening_character(body_texture: Texture2D, head_texture: Texture2D, body_rect: Rect2, head_rect: Rect2, breath: float, tint: Color) -> void:
	var body_scale := Vector2(1.0 + breath * 0.006, 1.0 + breath * 0.010)
	var breathing_size := body_rect.size * body_scale
	var breathing_rect := Rect2(body_rect.get_center() - breathing_size * 0.5, breathing_size)
	var head_follow := Vector2(0.0, -breath * body_rect.size.y * 0.005)
	draw_texture_rect(body_texture, breathing_rect, false, tint)
	draw_texture_rect(head_texture, Rect2(head_rect.position + head_follow, head_rect.size), false, tint)


func draw_texture_cover(texture: Texture2D, target_rect: Rect2, tint: Color = Color.WHITE, horizontal_zoom_out: float = 1.0) -> void:
	var source_rect := texture_cover_source_rect(texture, target_rect, horizontal_zoom_out)
	draw_texture_rect_region(texture, target_rect, source_rect, tint)


func texture_cover_source_rect(texture: Texture2D, target_rect: Rect2, horizontal_zoom_out: float = 1.0) -> Rect2:
	var texture_size := texture.get_size()
	var target_aspect := target_rect.size.x / target_rect.size.y
	var texture_aspect := texture_size.x / texture_size.y
	var source_rect := Rect2(Vector2.ZERO, texture_size)
	if texture_aspect > target_aspect:
		var source_width := minf(texture_size.x, texture_size.y * target_aspect * maxf(horizontal_zoom_out, 1.0))
		source_rect.position.x = (texture_size.x - source_width) * 0.5
		source_rect.size.x = source_width
	else:
		var source_height := texture_size.x / target_aspect
		source_rect.position.y = (texture_size.y - source_height) * 0.5
		source_rect.size.y = source_height
	return source_rect


func draw_home() -> void:
	draw_ocean_background(0.0)
	draw_departing_island(0.0)
	var brace_offset := sin(state_time * 8.0) * 1.5 if state == State.CHARGING else 0.0
	draw_push_sprite(Vector2i(0, 0), Vector2(VIEW_SIZE.x * 0.5, 1190.0 + brace_offset), Vector2(153.0, 153.0))
	draw_top_raft(Vector2(VIEW_SIZE.x * 0.5, RAFT_Y), raft_level, raft_level, 1)

	draw_text_center("RAFT ESCAPE", 108, 56, Color.WHITE)
	draw_text_center("Simple playable prototype", 148, 24, Color("#c8f4f7"))
	draw_panel(Rect2(55, 190, 610, 490))
	draw_text_center("SAIL %d/%d    GUARD %d/%d    OAR %d/%d" % [sail_level, SAIL_MAX_LEVEL, protection_level, PROTECTION_MAX_LEVEL, oar_level, OAR_MAX_LEVEL], 255, 21, COLOR_INK)
	draw_text_center("Maximum range: %d m" % int(current_max_distance()), 308, 24, COLOR_INK.lightened(0.12))
	draw_text_center("ROPE  %d     |     PLANKS  %d" % [total_rope, total_planks], 358, 23, COLOR_INK)
	if state == State.CHARGING:
		draw_text_center("Release as close to perfect green as you can!", 416, 19, COLOR_CORAL)
	else:
		draw_text_center("Hold the button or SPACE / ENTER to charge", 416, 19, Color("#45647a"))
	draw_launch_meter()
	var button_label := "RELEASE TO LAUNCH" if state == State.CHARGING else "HOLD TO LAUNCH"
	draw_button(launch_button, button_label, true, COLOR_CORAL)
	if state == State.HOME:
		draw_launch_dialogue()


func draw_launch_dialogue() -> void:
	var dialogue_line := current_launch_dialogue_line()
	if dialogue_line.is_empty():
		return

	var speaker := str(dialogue_line["speaker"])
	var dialogue_text := str(dialogue_line["text"])
	var font_size := 25
	var maximum_bubble_width := 400.0
	var horizontal_padding := 40.0
	var text_lines := wrap_upgrade_dialogue_text(dialogue_text, maximum_bubble_width - horizontal_padding, font_size)
	var widest_line := 0.0
	for text_line in text_lines:
		widest_line = maxf(
			widest_line,
			UPGRADE_UI_FONT.get_string_size(str(text_line), HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		)
	var bubble_width := clampf(ceilf(widest_line + horizontal_padding), 220.0, maximum_bubble_width)
	var line_step := 30.0
	var font_height := UPGRADE_UI_FONT.get_height(font_size)
	var text_block_height := font_height + maxf(0.0, float(text_lines.size() - 1) * line_step)
	var bubble_height := text_block_height + 26.0
	var speaker_point := Vector2(334.0, 1138.0) if speaker == "fat" else Vector2(392.0, 1004.0)
	var bubble_x := 18.0 if speaker == "fat" else VIEW_SIZE.x - 18.0 - bubble_width
	var bubble_bottom := 1085.0 if speaker == "fat" else 965.0
	var line_duration := launch_dialogue_line_duration(dialogue_text)
	var entrance_alpha := smoothstep(0.0, 1.0, clampf(launch_dialogue_line_time / 0.20, 0.0, 1.0))
	var exit_alpha := smoothstep(0.0, 1.0, clampf((line_duration - launch_dialogue_line_time) / 0.25, 0.0, 1.0))
	var dialogue_alpha := minf(entrance_alpha, exit_alpha)
	var bubble_rect := Rect2(
		bubble_x,
		bubble_bottom - bubble_height + (1.0 - entrance_alpha) * 6.0,
		bubble_width,
		bubble_height
	)
	var base_bubble_color := Color(0.92, 0.97, 1.0) if speaker == "fat" else Color(1.0, 0.975, 0.90)
	var bubble_color := Color(base_bubble_color, 0.97 * dialogue_alpha)
	var ink_color := Color(0.025, 0.055, 0.070, dialogue_alpha)
	var tail_anchor_x := clampf(speaker_point.x, bubble_rect.position.x + 25.0, bubble_rect.end.x - 25.0)
	var tail_points := PackedVector2Array([
		Vector2(tail_anchor_x - 10.0, bubble_rect.end.y - 3.0),
		Vector2(tail_anchor_x + 10.0, bubble_rect.end.y - 3.0),
		speaker_point,
	])
	draw_colored_polygon(tail_points, bubble_color)
	draw_polyline(PackedVector2Array([
		Vector2(tail_anchor_x - 10.0, bubble_rect.end.y - 1.0),
		speaker_point,
		Vector2(tail_anchor_x + 10.0, bubble_rect.end.y - 1.0),
	]), ink_color, 3.0, true)

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = bubble_color
	bubble_style.border_color = ink_color
	bubble_style.set_border_width_all(3)
	bubble_style.set_corner_radius_all(19)
	bubble_style.shadow_color = Color(0.0, 0.0, 0.0, 0.23 * dialogue_alpha)
	bubble_style.shadow_size = 6
	bubble_style.shadow_offset = Vector2(0.0, 4.0)
	draw_style_box(bubble_style, bubble_rect)

	var first_text_baseline := bubble_rect.position.y + (bubble_rect.size.y - text_block_height) * 0.5 + UPGRADE_UI_FONT.get_ascent(font_size)
	for line_index in text_lines.size():
		draw_string(
			UPGRADE_UI_FONT,
			Vector2(bubble_rect.position.x + horizontal_padding * 0.5, first_text_baseline + float(line_index) * line_step),
			text_lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			bubble_rect.size.x - horizontal_padding,
			font_size,
			ink_color
		)


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
		draw_push_sprite(stride_cell, Vector2(raft_x, 1190.0), Vector2(153.0, 153.0))
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
		return_offset = returning_raft_offset()
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


func returning_raft_offset() -> float:
	var drift_progress := smoothstep(0.0, 1.0, clampf(return_elapsed / RETURN_RAFT_DRIFT_TIME, 0.0, 1.0))
	var offset := RETURN_RAFT_DRIFT_OFFSET * drift_progress
	if not return_landed:
		return offset
	if return_impact_time < 0.10:
		return offset + lerpf(0.0, 22.0, return_impact_time / 0.10)
	if return_impact_time < 0.24:
		return offset + lerpf(22.0, -7.0, (return_impact_time - 0.10) / 0.14)
	if return_impact_time < 0.42:
		return offset + lerpf(-7.0, 0.0, (return_impact_time - 0.24) / 0.18)
	return offset


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
	var island_y := 1420.0 + scroll
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
	var texture := SAIL_UPGRADE_ICON
	match index:
		1: texture = SHIELD_UPGRADE_ICON
		2: texture = OAR_UPGRADE_ICON
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
	if return_scene_visible:
		draw_return_scene_background()
	else:
		draw_ocean_background(world_scroll)
	var results_panel_color := Color(0.97, 0.95, 0.88, 0.86) if return_scene_visible else COLOR_PANEL
	draw_panel(Rect2(35, 70, 650, 1095), results_panel_color)
	var entrance := smoothstep(0.0, 1.0, clampf(state_time / 0.44, 0.0, 1.0))
	var title_y := lerpf(205.0, 145.0, entrance)
	var results_title := "BACK ON THE ISLAND" if return_landed else "RETURNING TO THE ISLAND"
	draw_text_center(results_title, title_y, 42, COLOR_INK)
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
	if not return_scene_visible:
		draw_top_raft(Vector2(360, 800 + sin(state_time * 2.4) * 4.0), raft_level, maximum_raft_health())
	draw_result_flyers()

	if result_sequence_complete:
		var button_progress := smoothstep(0.0, 1.0, result_button_reveal)
		var button_offset := Vector2(0.0, (1.0 - button_progress) * 65.0)
		draw_button(Rect2(again_button.position + button_offset, again_button.size), "NEW LAUNCH", true, COLOR_WATER, button_progress)
		draw_button(Rect2(upgrade_button.position + button_offset, upgrade_button.size), "OPEN UPGRADES", true, COLOR_CORAL, button_progress)


func draw_return_scene_background() -> void:
	draw_ocean_background(world_scroll)
	draw_departing_island(world_scroll)
	for pickup in pickups:
		draw_pickup(pickup)
	for obstacle in obstacles:
		draw_rock(obstacle)
	var raft_position := Vector2(raft_x, RAFT_Y + returning_raft_offset())
	draw_top_raft(raft_position, raft_level, raft_health)


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
	draw_string(UPGRADE_UI_BOLD_FONT, Vector2(0, 62), "RAFT BLUEPRINTS", HORIZONTAL_ALIGNMENT_CENTER, VIEW_SIZE.x, 42, Color.WHITE)
	draw_string(UPGRADE_UI_FONT, Vector2(0, 99), "Choose what to improve", HORIZONTAL_ALIGNMENT_CENTER, VIEW_SIZE.x, 20, Color("#c8f4f7"))
	draw_string(UPGRADE_UI_BOLD_FONT, Vector2(0, 140), "ROPE  %d     |     PLANKS  %d" % [total_rope, total_planks], HORIZONTAL_ALIGNMENT_CENTER, VIEW_SIZE.x, 22, COLOR_ROPE)

	draw_upgrade_card(Rect2(293, 175, 407, 96), 0, "SAIL", sail_level, SAIL_MAX_LEVEL)
	draw_upgrade_card(Rect2(293, 276, 407, 96), 1, "GUARD", protection_level, PROTECTION_MAX_LEVEL)
	draw_upgrade_card(Rect2(293, 377, 407, 96), 2, "OAR", oar_level, OAR_MAX_LEVEL)
	draw_upgrade_placeholder(Rect2(293, 478, 407, 96))
	draw_upgrade_placeholder(Rect2(293, 579, 407, 96))
	draw_upgrade_info_panel()

	if upgrade_feedback_time > 0.0 and not upgrade_feedback.is_empty():
		var feedback_color := COLOR_ROPE if upgrade_feedback.contains("UPGRADED") else Color("#ff9a91")
		draw_string(UPGRADE_UI_BOLD_FONT, Vector2(330, 1035), upgrade_feedback, HORIZONTAL_ALIGNMENT_CENTER, 370, 18, feedback_color)
	draw_button(upgrade_back_button, "LAUNCH RAFT", true, COLOR_WATER, 1.0, 25, UPGRADE_UI_BOLD_FONT)
	draw_upgrade_dialogue()


func draw_upgrade_dialogue() -> void:
	var dialogue_line := current_upgrade_dialogue_line()
	if dialogue_line.is_empty():
		return

	var speaker := str(dialogue_line["speaker"])
	var dialogue_text := str(dialogue_line["text"])
	var font_size := 24
	var maximum_bubble_width := 296.0
	var text_lines := wrap_upgrade_dialogue_text(dialogue_text, maximum_bubble_width - 34.0, font_size)
	var widest_line := 0.0
	for text_line in text_lines:
		widest_line = maxf(widest_line, UPGRADE_UI_FONT.get_string_size(str(text_line), HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x)
	var bubble_width := clampf(ceilf(widest_line + 34.0), 180.0, maximum_bubble_width)
	var line_step := 28.0
	var font_height := UPGRADE_UI_FONT.get_height(font_size)
	var text_block_height := font_height + maxf(0.0, float(text_lines.size() - 1) * line_step)
	var bubble_height := text_block_height + 24.0
	var bubble_x := 10.0 if speaker == "fat" else 306.0 - bubble_width
	var bubble_position := Vector2(bubble_x, 382.0) if speaker == "fat" else Vector2(bubble_x, 695.0)
	var bubble_rect := Rect2(bubble_position, Vector2(bubble_width, bubble_height))
	var speaker_point := Vector2(164.0, 326.0) if speaker == "fat" else Vector2(298.0, 625.0)
	var tail_anchor_x := 164.0 if speaker == "fat" else 282.0
	var line_duration := upgrade_dialogue_line_duration(dialogue_text)
	var entrance_alpha := smoothstep(0.0, 1.0, clampf(upgrade_dialogue_line_time / 0.22, 0.0, 1.0))
	var exit_alpha := smoothstep(0.0, 1.0, clampf((line_duration - upgrade_dialogue_line_time) / 0.28, 0.0, 1.0))
	var dialogue_alpha := minf(entrance_alpha, exit_alpha)
	var base_bubble_color := Color(0.92, 0.97, 1.0) if speaker == "fat" else Color(1.0, 0.975, 0.90)
	var bubble_color := Color(base_bubble_color, 0.97 * dialogue_alpha)
	var ink_color := Color(0.025, 0.055, 0.070, dialogue_alpha)
	var tail_points := PackedVector2Array([
		Vector2(tail_anchor_x - 10.0, bubble_rect.position.y + 3.0),
		Vector2(tail_anchor_x + 10.0, bubble_rect.position.y + 3.0),
		speaker_point,
	])
	draw_colored_polygon(tail_points, bubble_color)
	draw_polyline(PackedVector2Array([
		Vector2(tail_anchor_x - 10.0, bubble_rect.position.y + 1.0),
		speaker_point,
		Vector2(tail_anchor_x + 10.0, bubble_rect.position.y + 1.0),
	]), ink_color, 3.0, true)

	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = bubble_color
	bubble_style.border_color = ink_color
	bubble_style.set_border_width_all(3)
	bubble_style.set_corner_radius_all(18)
	bubble_style.shadow_color = Color(0.0, 0.0, 0.0, 0.23 * dialogue_alpha)
	bubble_style.shadow_size = 6
	bubble_style.shadow_offset = Vector2(0.0, 4.0)
	draw_style_box(bubble_style, bubble_rect)

	var first_text_baseline := bubble_rect.position.y + (bubble_rect.size.y - text_block_height) * 0.5 + UPGRADE_UI_FONT.get_ascent(font_size)
	for line_index in text_lines.size():
		draw_string(
			UPGRADE_UI_FONT,
			Vector2(bubble_rect.position.x + 17.0, first_text_baseline + float(line_index) * line_step),
			text_lines[line_index],
			HORIZONTAL_ALIGNMENT_CENTER,
			bubble_rect.size.x - 34.0,
			font_size,
			ink_color
		)


func wrap_upgrade_dialogue_text(text: String, max_width: float, font_size: int) -> Array[String]:
	var wrapped_lines: Array[String] = []
	var current_line := ""
	for word_value in text.split(" ", false):
		var word := str(word_value)
		var candidate := word if current_line.is_empty() else current_line + " " + word
		var candidate_width := UPGRADE_UI_FONT.get_string_size(
			candidate,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			font_size
		).x
		if candidate_width <= max_width or current_line.is_empty():
			current_line = candidate
		else:
			wrapped_lines.append(current_line)
			current_line = word
	if not current_line.is_empty():
		wrapped_lines.append(current_line)
	return wrapped_lines


func draw_upgrade_card(rect: Rect2, icon_index: int, title: String, level: int, max_level: int) -> void:
	draw_panel(rect, Color(0.97, 0.94, 0.84, 0.96))
	draw_upgrade_icon(icon_index, rect.position + Vector2(50.0, 51.0), Vector2(84.0, 84.0))
	draw_string(UPGRADE_UI_BOLD_FONT, rect.position + Vector2(92, 28), title, HORIZONTAL_ALIGNMENT_CENTER, 140, 20, COLOR_UPGRADE_INK)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(232, 27), "LEVEL %d / %d" % [level, max_level], HORIZONTAL_ALIGNMENT_CENTER, 115, 14, COLOR_UPGRADE_MUTED_INK)
	var info_rect := sail_info_button
	var button_rect := sail_upgrade_button
	var cost := sail_upgrade_cost(level)
	match icon_index:
		1:
			info_rect = protection_info_button
			button_rect = protection_upgrade_button
			cost = protection_upgrade_cost(level)
		2:
			info_rect = oar_info_button
			button_rect = oar_upgrade_button
			cost = oar_upgrade_cost(level)
	draw_upgrade_info_badge(info_rect, upgrade_info_open == icon_index)
	if level >= max_level:
		draw_string(UPGRADE_UI_FONT, rect.position + Vector2(101, 67), "NO MORE MATERIALS NEEDED", HORIZONTAL_ALIGNMENT_CENTER, 165, 12, COLOR_UPGRADE_MUTED_INK)
		draw_compact_button(button_rect, "MAX LEVEL", false, COLOR_CORAL)
	else:
		draw_upgrade_cost(rect.position + Vector2(112, 61), cost)
		draw_compact_button(button_rect, "UPGRADE", can_pay(cost), COLOR_CORAL)


func draw_upgrade_cost(origin: Vector2, cost: Vector2i) -> void:
	draw_upgrade_cost_icon(UPGRADE_ROPE_ICON, origin, Vector2(39.0, 34.0))
	draw_string(ThemeDB.fallback_font, origin + Vector2(20, 6), "x%d" % cost.x, HORIZONTAL_ALIGNMENT_LEFT, 48, 17, COLOR_UPGRADE_INK)
	var plank_position := origin + Vector2(88, 0)
	draw_upgrade_cost_icon(UPGRADE_PLANK_ICON, plank_position, Vector2(41.0, 41.0))
	draw_string(ThemeDB.fallback_font, plank_position + Vector2(22, 6), "x%d" % cost.y, HORIZONTAL_ALIGNMENT_LEFT, 48, 17, COLOR_UPGRADE_INK)


func draw_upgrade_cost_icon(texture: Texture2D, position: Vector2, bounds: Vector2) -> void:
	var texture_size := texture.get_size()
	var fit_scale := minf(bounds.x / texture_size.x, bounds.y / texture_size.y)
	var fitted_size := texture_size * fit_scale
	draw_texture_rect(texture, Rect2(position - fitted_size * 0.5, fitted_size), false)


func draw_upgrade_info_badge(rect: Rect2, selected: bool) -> void:
	var color := COLOR_CORAL if selected else COLOR_WATER
	draw_circle(rect.get_center(), 17.0, color)
	draw_arc(rect.get_center(), 17.0, 0.0, TAU, 24, Color.WHITE, 2.0, true)
	draw_string(UPGRADE_UI_BOLD_FONT, rect.position + Vector2(0, 28), "!", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Color.WHITE)


func draw_upgrade_info_panel() -> void:
	if upgrade_info_open < 0:
		return
	var card_y := 175.0
	match upgrade_info_open:
		1: card_y = 276.0
		2: card_y = 377.0
	var panel_rect := Rect2(10, card_y, 268, 136)
	var panel_color := Color(0.97, 0.94, 0.84, 0.97)
	draw_panel(panel_rect, panel_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(panel_rect.end.x, card_y + 22),
		Vector2(293, card_y + 31),
		Vector2(panel_rect.end.x, card_y + 42),
	]), panel_color)
	if upgrade_info_open == 0:
		draw_string(UPGRADE_UI_BOLD_FONT, panel_rect.position + Vector2(16, 31), "SAIL UPGRADE", HORIZONTAL_ALIGNMENT_LEFT, 236, 20, COLOR_UPGRADE_INK)
		draw_string(UPGRADE_UI_FONT, panel_rect.position + Vector2(16, 64), "Each level adds %d m" % int(SAIL_RANGE_BONUS), HORIZONTAL_ALIGNMENT_LEFT, 236, 17, COLOR_UPGRADE_MUTED_INK)
		draw_string(UPGRADE_UI_FONT, panel_rect.position + Vector2(16, 87), "to your maximum travel range.", HORIZONTAL_ALIGNMENT_LEFT, 236, 17, COLOR_UPGRADE_MUTED_INK)
		draw_string(UPGRADE_UI_BOLD_FONT, panel_rect.position + Vector2(16, 116), "Current maximum: %d m" % int(current_max_distance()), HORIZONTAL_ALIGNMENT_LEFT, 236, 16, COLOR_UPGRADE_STATUS_INK)
	elif upgrade_info_open == 1:
		draw_string(UPGRADE_UI_BOLD_FONT, panel_rect.position + Vector2(16, 31), "GUARD UPGRADE", HORIZONTAL_ALIGNMENT_LEFT, 236, 20, COLOR_UPGRADE_INK)
		draw_string(UPGRADE_UI_FONT, panel_rect.position + Vector2(16, 64), "Each level absorbs one more", HORIZONTAL_ALIGNMENT_LEFT, 236, 17, COLOR_UPGRADE_MUTED_INK)
		draw_string(UPGRADE_UI_FONT, panel_rect.position + Vector2(16, 87), "rock collision before breaking.", HORIZONTAL_ALIGNMENT_LEFT, 236, 17, COLOR_UPGRADE_MUTED_INK)
		draw_string(UPGRADE_UI_BOLD_FONT, panel_rect.position + Vector2(16, 116), "Current safe hits: %d" % protection_level, HORIZONTAL_ALIGNMENT_LEFT, 236, 16, COLOR_UPGRADE_STATUS_INK)
	else:
		draw_string(UPGRADE_UI_BOLD_FONT, panel_rect.position + Vector2(16, 31), "OAR UPGRADE", HORIZONTAL_ALIGNMENT_LEFT, 236, 20, COLOR_UPGRADE_INK)
		draw_string(UPGRADE_UI_FONT, panel_rect.position + Vector2(16, 64), "Each level makes the raft", HORIZONTAL_ALIGNMENT_LEFT, 236, 17, COLOR_UPGRADE_MUTED_INK)
		draw_string(UPGRADE_UI_FONT, panel_rect.position + Vector2(16, 87), "respond faster while steering.", HORIZONTAL_ALIGNMENT_LEFT, 236, 17, COLOR_UPGRADE_MUTED_INK)
		var steering_bonus := int(round((current_steering_speed() / BASE_STEERING_SPEED - 1.0) * 100.0))
		draw_string(UPGRADE_UI_BOLD_FONT, panel_rect.position + Vector2(16, 116), "Current steering bonus: %d%%" % steering_bonus, HORIZONTAL_ALIGNMENT_LEFT, 236, 16, COLOR_UPGRADE_STATUS_INK)


func draw_compact_button(rect: Rect2, label: String, enabled: bool, color: Color) -> void:
	var paper_color := Color("#eadcb7") if enabled else Color("#c8c2ae")
	var graphite_color := Color("#34291f") if enabled else Color("#625d53")
	var accent_color := COLOR_UPGRADE_ACCENT_INK if enabled else Color("#6d665c")
	var shadow_rect := Rect2(rect.position + Vector2(1.5, 3.0), rect.size)
	var shadow_points := PackedVector2Array([
		shadow_rect.position + Vector2(3.0, 0.0),
		Vector2(shadow_rect.end.x - 3.0, shadow_rect.position.y),
		shadow_rect.end - Vector2(0.0, 3.0),
		shadow_rect.end - Vector2(3.0, 0.0),
		Vector2(shadow_rect.position.x, shadow_rect.end.y - 3.0),
		shadow_rect.position + Vector2(0.0, 3.0),
	])
	draw_colored_polygon(shadow_points, Color(0.12, 0.09, 0.06, 0.42))

	var plaque_points := PackedVector2Array([
		rect.position + Vector2(3.0, 0.0),
		Vector2(rect.end.x - 3.0, rect.position.y),
		Vector2(rect.end.x, rect.position.y + 3.0),
		rect.end - Vector2(0.0, 3.0),
		rect.end - Vector2(3.0, 0.0),
		Vector2(rect.position.x + 3.0, rect.end.y),
		Vector2(rect.position.x, rect.end.y - 3.0),
		rect.position + Vector2(0.0, 3.0),
	])
	draw_colored_polygon(plaque_points, paper_color)

	var hatch_color := Color(graphite_color, 0.10 if enabled else 0.06)
	for hatch_index in 5:
		var hatch_x := rect.position.x + 22.0 + float(hatch_index) * 23.0
		draw_line(Vector2(hatch_x, rect.position.y + 4.0), Vector2(hatch_x - 9.0, rect.end.y - 4.0), hatch_color, 1.0, true)

	var outline := PackedVector2Array([
		rect.position + Vector2(3.0, 1.0),
		Vector2(rect.end.x - 4.0, rect.position.y + 0.5),
		Vector2(rect.end.x - 1.0, rect.position.y + 3.5),
		Vector2(rect.end.x - 0.5, rect.end.y - 3.0),
		Vector2(rect.end.x - 3.5, rect.end.y - 0.5),
		Vector2(rect.position.x + 3.0, rect.end.y - 1.0),
		Vector2(rect.position.x + 0.5, rect.end.y - 3.5),
		rect.position + Vector2(1.0, 3.0),
		rect.position + Vector2(3.0, 1.0),
	])
	draw_polyline(outline, graphite_color, 2.0, true)
	draw_rect(Rect2(rect.position + Vector2(4.5, 4.0), rect.size - Vector2(9.0, 8.0)), Color(accent_color, 0.72), false, 1.0)

	for screw_position in [
		rect.position + Vector2(6.5, 6.5),
		Vector2(rect.end.x - 6.5, rect.position.y + 6.5),
		rect.end - Vector2(6.5, 6.5),
		Vector2(rect.position.x + 6.5, rect.end.y - 6.5),
	]:
		draw_circle(screw_position, 1.8, graphite_color)
		draw_line(screw_position - Vector2(1.2, 0.0), screw_position + Vector2(1.2, 0.0), paper_color.darkened(0.28), 0.8, true)

	draw_string(UPGRADE_UI_BOLD_FONT, rect.position + Vector2(0.0, 23.0), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 17, accent_color)


func draw_upgrade_placeholder(rect: Rect2) -> void:
	draw_panel(rect, Color(0.88, 0.89, 0.84, 0.40))
	draw_rect(Rect2(rect.position + Vector2(10, 10), rect.size - Vector2(20, 20)), Color(0.22, 0.34, 0.37, 0.22), false, 2)


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


func draw_button(rect: Rect2, label: String, enabled: bool, color: Color, alpha: float = 1.0, font_size: int = 25, font: Font = null) -> void:
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
	var button_font := ThemeDB.fallback_font if font == null else font
	draw_string(button_font, rect.position + Vector2(0, rect.size.y * 0.64), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, text_color)


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
	if airborne:
		draw_push_sprite(Vector2i(1, 1), position, Vector2(170.0, 170.0))
		return
	var cell := Vector2i(0, 0)
	if run_phase > 0.01:
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
	var sprite_size := 214.0
	var raft_rotation := -raft_steer_visual * 0.075 if state in [State.PLAYING, State.RETURNING] else 0.0
	var is_damaged := health < maximum_raft_health()
	var raft_tint := Color(0.82, 0.76, 0.72) if is_damaged else Color.WHITE
	draw_set_transform(position, raft_rotation, Vector2.ONE)
	draw_texture_rect(
		GAMEPLAY_RAFT_LVL1,
		Rect2(Vector2.ONE * -sprite_size * 0.5, Vector2.ONE * sprite_size),
		false,
		raft_tint
	)

	if sail_level >= 1:
		var sail_size := sprite_size * 0.98
		draw_texture_rect(
			GAMEPLAY_SAIL_LVL1,
			Rect2(Vector2(-sail_size * 0.5, -sail_size * 0.5 - 5.0), Vector2.ONE * sail_size),
			false,
			raft_tint
		)

	if is_damaged:
		draw_polyline(PackedVector2Array([
			Vector2(-31.0, -15.0),
			Vector2(-9.0, 1.0),
			Vector2(-23.0, 20.0),
			Vector2(4.0, 39.0),
		]), Color(0.20, 0.10, 0.06, 0.78), 3.0, true)

	if occupants >= 1:
		var skinny_position := Vector2(31.0, 4.0)
		var skinny_size := 92.4
		draw_texture_rect(
			GAMEPLAY_SKINNY_BOY,
			Rect2(skinny_position - Vector2.ONE * skinny_size * 0.5, Vector2.ONE * skinny_size),
			false,
			raft_tint
		)
	if occupants >= 2:
		var fat_position := Vector2(-31.0, 23.0)
		var fat_size := 99.0
		draw_texture_rect(
			GAMEPLAY_FAT_BOY,
			Rect2(fat_position - Vector2.ONE * fat_size * 0.5, Vector2.ONE * fat_size),
			false,
			raft_tint
		)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
	var resource_texture := ROPE_SPRITE if kind == "rope" else PLANK_SPRITE
	var texture_size := resource_texture.get_size()
	var fit_scale := minf(size.x / texture_size.x, size.y / texture_size.y)
	var fitted_size := texture_size * fit_scale
	draw_texture_rect(resource_texture, Rect2(-fitted_size * 0.5, fitted_size), false, Color(1.0, 1.0, 1.0, alpha))
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
