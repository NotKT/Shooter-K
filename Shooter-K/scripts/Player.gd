extends CharacterBody3D

# Movement
@export var speed: float = 6.0
@export var jump_velocity: float = 8.0
@export var gravity: float = 20.0

# Look/Aim
@export var aim_sensitivity: float = 0.15
@export var aim_assist_enabled: bool = true
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var move_input: Vector2 = Vector2.ZERO
var look_input: Vector2 = Vector2.ZERO
var pitch: float = 0.0

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Movement relative to facing direction
	var direction := (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	if direction.length() > 0.01:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

# Called by the on-screen move joystick UI
func set_move_input(input_vec: Vector2) -> void:
	move_input = input_vec

# Called once per aim drag event with the raw pixel delta of finger movement
func apply_look_delta(delta_vec: Vector2) -> void:
	rotate_y(-delta_vec.x * aim_sensitivity * 0.01)
	pitch = clamp(pitch - delta_vec.y * aim_sensitivity * 0.01, min_pitch, max_pitch)
	camera_pivot.rotation_degrees.x = pitch

func fire() -> void:
	# Placeholder: weapon system will hook in here (step 2)
	print("Fired!")
