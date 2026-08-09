# start_menu.gd
extends CanvasLayer

@export var level_scene_path: String = "res://Scenes/world.tscn"
@export var transition_duration: float = 0.5
@export var transition_spin: float = TAU

@onready var title: Control = $Title
@onready var main_buttons: HBoxContainer = $MainButtons
@onready var extras: Control = $Extras
@onready var start_button: Button = $MainButtons/StartButton
@onready var extras_button: Button = $MainButtons/ExtrasButton
@onready var exit_button: Button = $MainButtons/ExitButton
@onready var back_button: Button = $Extras/BackButton

@onready var transition_rect: ColorRect = $TransitionRect

func _ready() -> void:
	transition_rect.pivot_offset = transition_rect.size / 2.0
	transition_rect.scale = Vector2.ZERO
	transition_rect.rotation = 0.0
	
	start_button.pressed.connect(_on_start_pressed)
	extras_button.pressed.connect(_on_extras_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_start_pressed() -> void:
	main_buttons.hide()

	var tween := create_tween()
	tween.tween_property(transition_rect, "scale", Vector2.ONE, transition_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(transition_rect, "rotation", transition_spin, transition_duration)
	tween.finished.connect(_on_transition_covered)

func _on_transition_covered() -> void:
	get_tree().change_scene_to_file(level_scene_path)

func _on_extras_pressed() -> void:
	main_buttons.visible = false
	title.visible = false
	extras.visible = true

func _on_back_pressed() -> void:
	extras.visible = false
	main_buttons.visible = true
	title.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()
