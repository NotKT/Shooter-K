extends Control

# Circular fire button. Tap to shoot. Size/position driven by HUDSettings.
# When HUDSettings.edit_mode is on, dragging it repositions it instead.

var base_radius: float = 70.0
var player: CharacterBody3D
var pressed_touch_index: int = -1
var drag_touch_index: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	player = get_tree().get_root().find_child("Player", true, false)
	_apply_settings()
	HUDSettings.settings_changed.connect(_apply_settings)
	get_viewport().size_changed.connect(_update_position)

func _apply_settings() -> void:
	var scale_factor: float = HUDSettings.fire_button_scale
	base_radius = 70.0 * scale_factor
	custom_minimum_size = Vector2(base_radius, base_radius) * 2.0
	size = custom_minimum_size
	_update_position()
	queue_redraw()

func _update_position() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	position = HUDSettings.fire_button_pos * viewport_size - size / 2.0

func _draw() -> void:
	var col: Color = Color(1, 0.3, 0.3, 0.45) if HUDSettings.edit_mode else Color(1, 0.3, 0.3, 0.75)
	draw_circle(size / 2.0, base_radius, col)
	draw_string(ThemeDB.fallback_font, size / 2.0 + Vector2(-22, 8), "FIRE", HORIZONTAL_ALIGNMENT_CENTER, -1, 22)

func _gui_input(event: InputEvent) -> void:
	if HUDSettings.edit_mode:
		_handle_reposition_input(event)
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			pressed_touch_index = event.index
			if player:
				player.fire()
		elif event.index == pressed_touch_index:
			pressed_touch_index = -1

func _handle_reposition_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and drag_touch_index == -1:
			drag_touch_index = event.index
		elif not event.pressed and event.index == drag_touch_index:
			drag_touch_index = -1
			var viewport_size: Vector2 = get_viewport().get_visible_rect().size
			HUDSettings.fire_button_pos = (position + size / 2.0) / viewport_size
			HUDSettings.save_settings()
	elif event is InputEventScreenDrag:
		if event.index == drag_touch_index:
			position += event.relative
			queue_redraw()
