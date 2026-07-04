extends CanvasLayer

# Right half of screen = aim/look drag. Left side movement now comes from
# the visible VirtualJoystick node instead of a raw touch zone.

var aim_touch_index: int = -1
var aim_last_pos: Vector2 = Vector2.ZERO

var player: CharacterBody3D
@onready var joystick: Control = $VirtualJoystick

func _ready() -> void:
	player = get_parent().get_node("Player")

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

func _on_fire_button_pressed() -> void:
	player.fire()
