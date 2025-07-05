# Capture.gd
# Sahnenin root Node3D’sine (örneğin “Main”) bağlayın.

extends Node3D

@export_node_path var camera_path: NodePath       # Inspector’dan Camera3D yolunu seçin
@export_node_path var interactive_path: NodePath  # Inspector’dan InteractiveObjects node’unu seçin
@export var shot_action: String = "take_screenshot"

const SCREENSHOT_DIR := "res://screenshots/"

var cam: Camera3D
var interactive: Node3D

func _ready():
	cam = get_node(camera_path)
	interactive = get_node(interactive_path)
	# user://screenshots klasörünü oluştur (yoksa)
	if not DirAccess.dir_exists_absolute(SCREENSHOT_DIR):
		var err = DirAccess.make_dir_absolute(SCREENSHOT_DIR)
		if err != OK:
			push_error("Could not create directory: %s (err %d)" % [SCREENSHOT_DIR, err])
	print("📷 Ready – screenshots will go to:", SCREENSHOT_DIR)

func _process(delta):
	if Input.is_action_just_pressed(shot_action):
		capture_pair()

func capture_pair():
	_save_screenshot("full_scene.png")
	interactive.visible = false
	await get_tree().process_frame
	_save_screenshot("background_only.png")
	interactive.visible = true
	print("✅ Saved full_scene.png & background_only.png in", SCREENSHOT_DIR)

func _save_screenshot(filename: String) -> void:
	var img = cam.get_viewport().get_texture().get_image()
	# Çekilen resmi olduğu gibi kaydedince ters geliyorsa,
	# önce dikey sonra yatay çevirerek (180° rotasyon) düzeltiyoruz:
	img.flip_y()
	img.flip_x()
	var path = "%s/%s" % [SCREENSHOT_DIR, filename]
	var err = img.save_png(path)
	if err == OK:
		print("   →", path)
	else:
		push_error("Could not save screenshot: %s" % path)
