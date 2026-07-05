extends Node

# Autoload singleton. Persists joystick + fire button position/scale
# to user://hud_settings.cfg so preferences survive between sessions.

const SAVE_PATH := "user://hud_settings.cfg"

var joystick_pos: Vector2 = Vector2(0.14, 0.82)   # normalized screen fraction
var joystick_scale: float = 1.0                    # 0.6 - 1.6
var fire_button_pos: Vector2 = Vector2(0.88, 0.82)
var fire_button_scale: float = 1.0

var edit_mode: bool = false

signal settings_changed

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("hud", "joystick_pos_x", joystick_pos.x)
	cfg.set_value("hud", "joystick_pos_y", joystick_pos.y)
	cfg.set_value("hud", "joystick_scale", joystick_scale)
	cfg.set_value("hud", "fire_button_pos_x", fire_button_pos.x)
	cfg.set_value("hud", "fire_button_pos_y", fire_button_pos.y)
	cfg.set_value("hud", "fire_button_scale", fire_button_scale)
	cfg.save(SAVE_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		joystick_pos.x = cfg.get_value("hud", "joystick_pos_x", joystick_pos.x)
		joystick_pos.y = cfg.get_value("hud", "joystick_pos_y", joystick_pos.y)
		joystick_scale = cfg.get_value("hud", "joystick_scale", joystick_scale)
		fire_button_pos.x = cfg.get_value("hud", "fire_button_pos_x", fire_button_pos.x)
		fire_button_pos.y = cfg.get_value("hud", "fire_button_pos_y", fire_button_pos.y)
		fire_button_scale = cfg.get_value("hud", "fire_button_scale", fire_button_scale)

func reset_defaults() -> void:
	joystick_pos = Vector2(0.14, 0.82)
	joystick_scale = 1.0
	fire_button_pos = Vector2(0.88, 0.82)
	fire_button_scale = 1.0
	save_settings()
	settings_changed.emit()

func set_joystick_scale(value: float) -> void:
	joystick_scale = value
	save_settings()
	settings_changed.emit()

func set_fire_button_scale(value: float) -> void:
	fire_button_scale = value
	save_settings()
	settings_changed.emit()

func set_edit_mode(value: bool) -> void:
	edit_mode = value
	settings_changed.emit()
