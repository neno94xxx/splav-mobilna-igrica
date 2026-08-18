extends SceneTree

const SOURCE_PATH := "res://unused_assets/images/backgrounds/workshop_background_clean_v1.png"
const OUTPUTS := {
	"res://tmp/workshop_background_q95.webp": 0.95,
	"res://tmp/workshop_background_q90.webp": 0.90,
	"res://tmp/workshop_background_q82.webp": 0.82,
	"res://tmp/workshop_background_q76.webp": 0.76,
	"res://tmp/workshop_background_q70.webp": 0.70,
}


func _init() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(SOURCE_PATH))
	if image == null or image.is_empty():
		push_error("Could not load workshop background for optimization")
		quit(1)
		return
	image.resize(720, 1280, Image.INTERPOLATE_LANCZOS)
	for output_path: String in OUTPUTS:
		var result := image.save_webp(
			ProjectSettings.globalize_path(output_path),
			true,
			float(OUTPUTS[output_path])
		)
		if result != OK:
			push_error("Could not save %s" % output_path)
			quit(1)
			return
		print("SAVED ", output_path, " quality=", OUTPUTS[output_path])
	quit(0)
