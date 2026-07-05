extends Control

# Circular fire button styled like a bullet icon: gold ring + bullet shape.
# Tap to shoot. Size/position driven by HUDSettings.
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
	var c: Vector2 = size / 2.0
	var edit_dim: float = 0.55 if HUDSettings.edit_mode else 1.0

	# Dark background disc
	draw_circle(c, base_radius, Color(0.08, 0.08, 0.08, 0.85 * edit_dim))

	# Gold outer ring
	var gold: Color = Color(0.85, 0.7, 0.15, edit_dim)
	draw_arc(c, base_radius - 3.0, 0, TAU, 64, gold, 5.0, true)

	# Bullet shape: rounded tip (circle) + body (rounded rect) pointing up-right,
	# drawn simply as a capsule-like shape using a rect + circle.
	var bullet_len: float = base_radius * 1.1
	var bullet_width: float = base_radius * 0.55
	var casing_color: Color = Color(0.75, 0.76, 0.78, edit_dim)
	var tip_color: Color = Color(0.92, 0.75, 0.35, edit_dim)

	# Casing (body) - a rectangle centered, slightly below center
	var body_rect := Rect2(
		c.x - bullet_width / 2.0,
		c.y - bullet_len * 0.15,
		bullet_width,
		bullet_len * 0.75
	)
	draw_rect(body_rect, casing_color)

	# Tip (rounded) - a circle at the top of the casing
	var tip_center := Vector2(c.x, body_rect.position.y)
	draw_circle(tip_center, bullet_width / 2.0, tip_color)

	# Small highlight line on the casing for a metallic look
	draw_line(
		Vector2(c.x - bullet_width * 0.15, body_rect.position.y + 4.0),
		Vector2(c.x - bullet_width * 0.15, body_rect.position.y + body_rect.size.y - 4.0),
		Color(1, 1, 1, 0.3 * edit_dim),
		2.0
	)

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
