extends PanelContainer

@onready var joystick_slider: HSlider = $VBox/JoystickRow/JoystickSlider
@onready var fire_slider: HSlider = $VBox/FireRow/FireSlider
@onready var reposition_toggle: CheckButton = $VBox/RepositionToggle

func _ready() -> void:
	visible = false
	joystick_slider.value = HUDSettings.joystick_scale
	fire_slider.value = HUDSettings.fire_button_scale
	reposition_toggle.button_pressed = HUDSettings.edit_mode

func toggle_visible() -> void:
	visible = not visible

func _on_joystick_slider_value_changed(value: float) -> void:
	HUDSettings.set_joystick_scale(value)

func _on_fire_slider_value_changed(value: float) -> void:
	HUDSettings.set_fire_button_scale(value)

func _on_reposition_toggle_toggled(toggled_on: bool) -> void:
	HUDSettings.set_edit_mode(toggled_on)

func _on_reset_pressed() -> void:
	HUDSettings.reset_defaults()
	joystick_slider.value = HUDSettings.joystick_scale
	fire_slider.value = HUDSettings.fire_button_scale
	reposition_toggle.button_pressed = false

func _on_close_pressed() -> void:
	visible = false
