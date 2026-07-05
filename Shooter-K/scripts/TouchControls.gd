extends CanvasLayer

# Right half of screen = aim/look drag. Movement comes from the
# VirtualJoystick node; firing is handled by the FireButton node directly.
# This script also keeps the ammo counter label in sync with the player.

var aim_touch_index: int = -1
var aim_last_pos: Vector2 = Vector2.ZERO

var player: CharacterBody3D
@onready var joystick: Control = $VirtualJoystick
@onready var ammo_label: Label = $AmmoLabel

func _ready() -> void:
	player = get_parent().get_node("Player")
	player.ammo_changed.connect(_on_ammo_changed)
	player.reload_started.connect(_on_reload_started)
	player.reload_finished.connect(_on_reload_finished)
	_on_ammo_changed(player.ammo, player.max_ammo)

func _input(event: InputEvent) -> void:
	var screen_width := get_viewport().get_visible_rect().size.x

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x >= screen_width / 2.0 and aim_touch_index == -1:
				aim_touch_index = event.index
				aim_last_pos = event.position
		else:
			if event.index == aim_touch_index:
				aim_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == aim_touch_index:
			var drag_delta: Vector2 = event.position - aim_last_pos
			aim_last_pos = event.position
			player.apply_look_delta(drag_delta)

func _process(_delta: float) -> void:
	if joystick:
		player.set_move_input(joystick.output)

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	ammo_label.text = "%d / %d" % [current, max_ammo]

func _on_reload_started(_duration: float) -> void:
	ammo_label.text = "Reloading..."

func _on_reload_finished() -> void:
	_on_ammo_changed(player.ammo, player.max_ammo)
