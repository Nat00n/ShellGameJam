# pause_menu.gd
extends CanvasLayer

@export var start_menu_scene_path: String = "res://Scenes/start_menu.tscn"

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: VBoxContainer = $Options
@onready var audio_slider: HSlider = $Options/HBoxContainer/AudioSlider
@onready var resume_button: Button = $MainButtons/ResumeButton
@onready var options_button: Button = $MainButtons/OptionsButton
@onready var return_button: Button = $MainButtons/ReturnButton
@onready var back_button: Button = $Options/BackButton

var is_open: bool = false
var is_locked: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	options.visible = false

	resume_button.pressed.connect(close_menu)
	options_button.pressed.connect(_on_options_pressed)
	return_button.pressed.connect(_on_return_pressed)
	back_button.pressed.connect(_on_back_pressed)

	audio_slider.value_changed.connect(_on_audio_changed)
	audio_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))

func _unhandled_input(event: InputEvent) -> void:
	if is_locked:
		return
	if event.is_action_pressed("pause"):
		if is_open:
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()

func open_menu() -> void:
	if is_locked:
		return
	is_open = true
	visible = true
	main_buttons.visible = true
	options.visible = false
	get_tree().paused = true

func close_menu() -> void:
	is_open = false
	visible = false
	get_tree().paused = false

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_back_pressed() -> void:
	options.visible = false
	main_buttons.visible = true

func _on_return_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(start_menu_scene_path)

func _on_audio_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
