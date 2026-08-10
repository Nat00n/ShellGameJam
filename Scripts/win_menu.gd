# win_menu.gd
extends CanvasLayer

@export var start_menu_scene_path: String = "res://Scenes/start_menu.tscn"

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var menu_button: Button = $VBoxContainer/MenuButton
const VICTORY = preload("uid://dag41y0sfnkq6")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	menu_button.pressed.connect(_on_menu_pressed)

func show_win(final_time: float) -> void:
	time_label.text = "%.2f" % final_time
	visible = true
	get_tree().paused = true
	AudioManager.play_music(VICTORY)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(start_menu_scene_path)
