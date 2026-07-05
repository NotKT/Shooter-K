extends Control

# Fire button styled as a reticle: dark disc, gray ring, corner tick marks,
# and a bullet+impact icon in the center. Tap to shoot.
# Size/position driven by HUDSettings. Drag to reposition when edit_mode is on.

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
	var dim: float = 0.55 if HUDSettings.edit_mode else 1.0
	var r: float = base_radius

	# Dark disc background
	draw_circle(c, r, Color(0.05, 0.05, 0.05, 0.88 * dim))

	# Gray outer ring
	var ring_color := Color(0.62, 0.62, 0.62, dim)
	draw_arc(c, r - 3.0, 0, TAU, 64, ring_color, 5.0, true)

	# Corner tick marks (N/E/S/W), reticle-style
	var tick_len := r * 0.28
	var tick_gap := r + 6.0
	var dirs := [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	for d in dirs:
		var perp: Vector2 = Vector2(-d.y, d.x)
		var base_pt: Vector2 = c + d * tick_gap
		draw_line(base_pt - perp * tick_len * 0.5, base_pt + perp * tick_len * 0.5, ring_color, 4.0)

	# Bullet icon: casing (white rect) + rounded tip, tilted diagonally
	var icon_scale: float = r / 70.0
	var bullet_len := 34.0 * icon_scale
	var bullet_width := 13.0 * icon_scale
	var white := Color(0.95, 0.95, 0.95, dim)

	var xform := Transform2D(deg_to_rad(-35.0), c)

	# Casing body (rect centered slightly below bullet tip)
	var body_rect := Rect2(-bullet_width / 2.0, -bullet_len * 0.15, bullet_width, bullet_len * 0.7)
	draw_set_transform_matrix(xform)
	draw_rect(body_rect, white)
	draw_circle(Vector2(0, body_rect.position.y), bullet_width / 2.0, white)
	draw_set_transform_matrix(Transform2D())

	# Impact spark (small 4-point star) to the upper-left of the bullet
	var spark_center: Vector2 = c + Vector2(-r * 0.32, -r * 0.30)
	var spark_size: float = r * 0.22
	var spark_points := PackedVector2Array([
		spark_center + Vector2(0, -spark_size),
		spark_center + Vector2(spark_size * 0.28, -spark_size * 0.28),
		spark_center + Vector2(spark_size, 0),
		spark_center + Vector2(spark_size * 0.28, spark_size * 0.28),
		spark_center + Vector2(0, spark_size),
		spark_center + Vector2(-spark_size * 0.28, spark_size * 0.28),
		spark_center + Vector2(-spark_size, 0),
		spark_center + Vector2(-spark_size * 0.28, -spark_size * 0.28),
	])
	draw_colored_polygon(spark_points, white)

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
