extends Control

# Draws a base ring + draggable knob, and exposes `output` (Vector2, -1 to 1)
# for movement input. Fixed position, bottom-left of the screen.

@export var base_radius: float = 100.0
@export var knob_radius: float = 45.0

var touch_index: int = -1
var center: Vector2
var knob_pos: Vector2
var output: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	center = size / 2.0
	knob_pos = center

func _draw() -> void:
	draw_circle(center, base_radius, Color(1, 1, 1, 0.18))
	draw_arc(center, base_radius, 0, TAU, 48, Color(1, 1, 1, 0.55), 4.0, true)
	draw_circle(knob_pos, knob_radius, Color(1, 1, 1, 0.85))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			knob_pos = center
			output = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_knob(event.position)

func _update_knob(pos: Vector2) -> void:
	var delta_vec: Vector2 = pos - center
	var clamped: Vector2 = delta_vec.limit_length(base_radius)
	knob_pos = center + clamped
	output = clamped / base_radius
	queue_redraw()
