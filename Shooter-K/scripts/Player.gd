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
@onready var muzzle: Node3D = $CameraPivot/Camera3D/Muzzle
@onready var muzzle_light: OmniLight3D = $CameraPivot/Camera3D/Muzzle/MuzzleLight

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

	var end_point: Vector3 = to
	if result:
		end_point = result.position
		print("Hit: ", result.collider.name, " at ", result.position)
	else:
		print("Shot missed")

	_flash_muzzle()
	_spawn_tracer(muzzle.global_transform.origin, end_point)

func _start_reload() -> void:
	is_reloading = true
	reload_started.emit(reload_time)
	await get_tree().create_timer(reload_time).timeout
	ammo = max_ammo
	is_reloading = false
	ammo_changed.emit(ammo, max_ammo)
	reload_finished.emit()

func _flash_muzzle() -> void:
	muzzle_light.light_energy = 3.5
	var tween := create_tween()
	tween.tween_property(muzzle_light, "light_energy", 0.0, 0.08)

func _spawn_tracer(from_pos: Vector3, to_pos: Vector3) -> void:
	var direction: Vector3 = (to_pos - from_pos)
	var length: float = direction.length()
	if length < 0.01:
		return
	direction = direction.normalized()

	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.015
	cyl.bottom_radius = 0.015
	cyl.height = length
	cyl.radial_segments = 6

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.9, 0.4)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.85, 0.3)
	mat.emission_energy_multiplier = 3.0

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = cyl
	mesh_instance.material_override = mat

	get_tree().current_scene.add_child(mesh_instance)

	var mid_point: Vector3 = (from_pos + to_pos) * 0.5
	var reference: Vector3 = Vector3.RIGHT if absf(direction.dot(Vector3.RIGHT)) < 0.9 else Vector3.FORWARD
	var right: Vector3 = direction.cross(reference).normalized()
	var forward_axis: Vector3 = right.cross(direction).normalized()
	mesh_instance.global_transform = Transform3D(Basis(right, direction, forward_axis), mid_point)

	get_tree().create_timer(0.06).timeout.connect(mesh_instance.queue_free)
