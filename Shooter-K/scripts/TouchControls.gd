extends CanvasLayer

# Simple touch controls: left half of screen = move joystick,
# right half = aim/look drag, plus a fire button.

@export var joystick_radius: float = 150.0

var move_touch_index: int = -1
var aim_touch_index: int = -1
var move_origin: Vector2 = Vector2.ZERO
var move_current: Vector2 = Vector2.ZERO
var aim_last_pos: Vector2 = Vector2.ZERO

var player: CharacterBody3D

func _ready() -> void:
	player = get_parent().get_node("Player")

func _input(event: InputEvent) -> void:
	var screen_width := get_viewport().get_visible_rect().size.x

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < screen_width / 2.0 and move_touch_index == -1:
				move_touch_index = event.index
				move_origin = event.position
				move_current = event.position
			elif event.position.x >= screen_width / 2.0 and aim_touch_index == -1:
				aim_touch_index = event.index
				aim_last_pos = event.position
		else:
			if event.index == move_touch_index:
				move_touch_index = -1
				move_current = move_origin
				player.set_move_input(Vector2.ZERO)
			elif event.index == aim_touch_index:
				aim_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == move_touch_index:
			move_current = event.position
			var delta_vec := (move_current - move_origin).limit_length(joystick_radius)
			var normalized := delta_vec / joystick_radius
			player.set_move_input(Vector2(normalized.x, normalized.y))
		elif event.index == aim_touch_index:
			var drag_delta: Vector2 = event.position - aim_last_pos
			aim_last_pos = event.position
			player.apply_look_delta(drag_delta)

func _on_fire_button_pressed() -> void:
	player.fire()
