# Player.gd
# Attach to your Player (CharacterBody3D) node:
# - Child Node3D named "Head"
#   - Camera3D under Head, positioned at (0, 1.6, 0)

extends CharacterBody3D

# ————— Exports —————
@export var speed: float = 5.0
@export var jump_speed: float = 5.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var mouse_sensitivity: float = 0.002
@export var camera_fov: float = 70.0     # Görüş açısı

# ————— Internal State —————
var pitch: float = 0.0

@onready var head: Node3D     = $Head
@onready var camera: Camera3D = head.get_node("Camera3D")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = camera_fov

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# 1) Local yaw: Player'ın kendi Y-ekseni etrafında dön
		rotate_y(-event.relative.x * mouse_sensitivity)
		# 2) Local pitch: Head'in kendi X-ekseni etrafında dön
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		# 3) Pitch'i sınırla
		pitch = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		head.rotation.x = pitch
		# 4) Roll'u sıfırla
		head.rotation.z = 0

func _physics_process(delta):
	# ——— Yön vektörünü hesapla ———
	var dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += transform.basis.x
	dir = dir.normalized()

	# ——— Yatay hızı ata ———
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	# ——— Zıplama / Yerçekimi ———
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
		elif Input.is_action_pressed("crouch"):
			velocity.y = -jump_speed * 0.5
		else:
			velocity.y = 0
	else:
		velocity.y -= gravity * delta

	# ——— Hareketi uygula ———
	move_and_slide()
