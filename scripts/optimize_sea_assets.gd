extends SceneTree

const QUALITY := 0.94
const ACTIVE_PARTS := [
	{
		"source": "res://unused_assets/images/sea/ocean.png",
		"output": "res://assets/sea/ocean_optimized_v1.webp",
		"max_size": Vector2i(512, 512),
		"force_size": true,
	},
	{
		"source": "res://unused_assets/images/sea/splash1.png",
		"output": "res://assets/sea/splash1_optimized_v1.webp",
		"max_size": Vector2i(512, 512),
		"force_size": false,
	},
	{
		"source": "res://unused_assets/images/sea/splash7.png",
		"output": "res://assets/sea/splash7_optimized_v1.webp",
		"max_size": Vector2i(512, 512),
		"force_size": false,
	},
]
const OPTIONAL_NAMES := [
	"drops1.png",
	"drops2.png",
	"splash2.png",
	"splash3.png",
	"splash4.png",
	"splash5.png",
	"splash6.png",
]


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://unused_assets/images/sea_optimized_optional"))
	for part: Dictionary in ACTIVE_PARTS:
		if not optimize_image(part["source"], part["output"], part["max_size"], part["force_size"]):
			quit(1)
			return
	for file_name: String in OPTIONAL_NAMES:
		var output_name := file_name.get_basename() + "_optimized_v1.webp"
		if not optimize_image(
			"res://unused_assets/images/sea/%s" % file_name,
			"res://unused_assets/images/sea_optimized_optional/%s" % output_name,
			Vector2i(384, 384),
			false
		):
			quit(1)
			return
	quit(0)


func optimize_image(source_path: String, output_path: String, max_size: Vector2i, force_size: bool) -> bool:
	var image := Image.load_from_file(ProjectSettings.globalize_path(source_path))
	if image == null or image.is_empty():
		push_error("Could not load %s" % source_path)
		return false
	var source_size := image.get_size()
	var target_size := max_size
	if not force_size:
		var scale_factor := minf(
			float(max_size.x) / float(source_size.x),
			float(max_size.y) / float(source_size.y)
		)
		scale_factor = minf(scale_factor, 1.0)
		target_size = Vector2i(
			maxi(1, roundi(float(source_size.x) * scale_factor)),
			maxi(1, roundi(float(source_size.y) * scale_factor))
		)
	image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	var result := image.save_webp(ProjectSettings.globalize_path(output_path), true, QUALITY)
	if result != OK:
		push_error("Could not save %s" % output_path)
		return false
	print("SAVED ", output_path, " source=", source_size, " target=", target_size, " quality=", QUALITY)
	return true
