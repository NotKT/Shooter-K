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

# Weapon (pistol stats for now)
@export var max_ammo: int = 12
@export var fire_rate: float = 0.35     # seconds between shots
@export var reload_time: float = 1.2
@export var damage: int = 25
@export var fire_range: float = 100.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var move_input: Vector2 = Vector2.ZERO
var pitch: float = 0.0

var ammo: int
var can_fire: bool = true
var is_reloading: bool = false

signal ammo_changed(current: int, max_ammo: int)
signal reload_started(duration: float)
signal reload_finished

func _ready() -> void:
	ammo = max_ammo
	ammo_changed.emit(ammo, max_ammo)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction := (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	if direction.length() > 0.01:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func set_move_input(input_vec: Vector2) -> void:
	move_input = input_vec

func apply_look_delta(delta_vec: Vector2) -> void:
	rotate_y(-delta_vec.x * aim_sensitivity * 0.01)
	pitch = clamp(pitch - delta_vec.y * aim_sensitivity * 0.01, min_pitch, max_pitch)
	camera_pivot.rotation_degrees.x = pitch

func fire() -> void:
	if is_reloading or not can_fire:
		return
	if ammo <= 0:
		_start_reload()
		return

	ammo -= 1
	ammo_changed.emit(ammo, max_ammo)

	can_fire = false
	get_tree().create_timer(fire_rate).timeout.connect(func() -> void:
		can_fire = true
	)

	_raycast_shot()

	if ammo == 0:
		_start_reload()

func _raycast_shot() -> void:
	var space_state := get_world_3d().direct_space_state
	var origin: Vector3 = camera.global_transform.origin
	var forward: Vector3 = -camera.global_transform.basis.z
	var to: Vector3 = origin + forward * fire_range

	var query := PhysicsRayQueryParameters3D.create(origin, to)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)

	if result:
		print("Hit: ", result.collider.name, " at ", result.position)
		# Placeholder: apply damage here once other players/enemies exist
	else:
		print("Shot missed")

func _start_reload() -> void:
	is_reloading = true
	reload_started.emit(reload_time)
	await get_tree().create_timer(reload_time).timeout
	ammo = max_ammo
	is_reloading = false
	ammo_changed.emit(ammo, max_ammo)
	reload_finished.emit()
