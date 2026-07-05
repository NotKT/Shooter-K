extends Control

# Draws a base ring + draggable knob for movement input.
# Size/position are driven by HUDSettings so the player can customize them.

var base_radius: float = 100.0
var knob_radius: float = 45.0

var touch_index: int = -1
var center: Vector2
var knob_pos: Vector2
var output: Vector2 = Vector2.ZERO

var drag_touch_index: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_settings()
	HUDSettings.settings_changed.connect(_apply_settings)
	get_viewport().size_changed.connect(_update_position)

func _apply_settings() -> void:
	var scale_factor: float = HUDSettings.joystick_scale
	base_radius = 100.0 * scale_factor
	knob_radius = 45.0 * scale_factor
	custom_minimum_size = Vector2(base_radius, base_radius) * 2.0
	size = custom_minimum_size
	center = size / 2.0
	knob_pos = center
	_update_position()
	queue_redraw()

func _update_position() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	position = HUDSettings.joystick_pos * viewport_size - size / 2.0

func _draw() -> void:
	var ring_color: Color = Color(1, 1, 1, 0.45) if HUDSettings.edit_mode else Color(1, 1, 1, 0.18)
	draw_circle(center, base_radius, ring_color)
	draw_arc(center, base_radius, 0, TAU, 48, Color(1, 1, 1, 0.55), 4.0, true)
	draw_circle(knob_pos, knob_radius, Color(1, 1, 1, 0.85))

func _gui_input(event: InputEvent) -> void:
	if HUDSettings.edit_mode:
		_handle_reposition_input(event)
		return

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

func _handle_reposition_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and drag_touch_index == -1:
			drag_touch_index = event.index
		elif not event.pressed and event.index == drag_touch_index:
			drag_touch_index = -1
			var viewport_size: Vector2 = get_viewport().get_visible_rect().size
			HUDSettings.joystick_pos = (position + size / 2.0) / viewport_size
			HUDSettings.save_settings()
	elif event is InputEventScreenDrag:
		if event.index == drag_touch_index:
			position += event.relative
			queue_redraw()

func _update_knob(pos: Vector2) -> void:
	var delta_vec: Vector2 = pos - center
	var clamped: Vector2 = delta_vec.limit_length(base_radius)
	knob_pos = center + clamped
	output = clamped / base_radius
	queue_redraw()
