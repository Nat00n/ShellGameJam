extends Node2D

@onready var start_point: Marker2D = $StartPoint
@onready var snail: Snail = $Snail
@onready var time_label: Label = $HUD/TimeLabel
@onready var transition_rect: Sprite2D = $HUD/TransitionRect
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var hud: CanvasLayer = $HUD
@onready var win_menu: CanvasLayer = $WinMenu
@onready var home: Area2D = $Home

var elapsed_time: float = 0.0
var timer_running: bool = false

@export var restart_hold_time: float = 2.0
var restart_held_time: float = 0.0
var is_restarting: bool = false

@export var transition_duration: float = 0.5
@export var transition_spin: float = TAU
const WORLD_MUSIC = preload("uid://cvokiqkp26d8r")

func _ready() -> void:
	AudioManager.play_music(WORLD_MUSIC)
	hud.visible = true
	home.reached_home.connect(_on_home)
	_start_level()

func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		time_label.text = "%.2f" % elapsed_time

	if not get_tree().paused:
		if Input.is_action_pressed("restart"):
			restart_held_time += delta
			if restart_held_time >= restart_hold_time:
				restart_held_time = 0.0
				_do_restart()
		else:
			restart_held_time = 0.0

func _on_home() -> void:
	if timer_running:
		timer_running = false
		pause_menu.is_locked = true
		win_menu.show_win(elapsed_time)

func _start_level() -> void:
	pause_menu.is_locked = true
	snail.global_position = start_point.global_position
	get_tree().paused = true
	elapsed_time = 0.0
	timer_running = false

	transition_rect.scale = Vector2(38,38)
	transition_rect.rotation = 0.0

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(transition_rect, "scale", Vector2.ZERO, transition_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(transition_rect, "rotation", transition_spin, transition_duration)
	tween.finished.connect(_on_intro_finished)

func _on_intro_finished() -> void:
	pause_menu.is_locked = false
	get_tree().paused = false
	timer_running = true

func _do_restart() -> void:
	pause_menu.is_locked = true
	get_tree().paused = true
	timer_running = false

	transition_rect.scale = Vector2.ZERO
	transition_rect.rotation = 0.0

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(transition_rect, "scale", Vector2(38,38), transition_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(transition_rect, "rotation", transition_spin, transition_duration)
	tween.finished.connect(_reset_and_reopen)

func _reset_and_reopen() -> void:
	get_tree().reload_current_scene()

func trigger_death_restart() -> void:
	if is_restarting:
		return
	is_restarting = true
	restart_held_time = 0.0
	_do_restart()
