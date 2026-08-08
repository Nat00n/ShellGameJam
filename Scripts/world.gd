# level.gd
extends Node2D

@onready var start_point: Marker2D = $StartPoint
@onready var snail: Snail = $Snail

var elapsed_time: float = 0.0
var timer_running: bool = true

@onready var time_label: Label = $HUD/TimeLabel

func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		time_label.text = "%.2f" % elapsed_time

func _on_home_goal_reached_home() -> void:
	timer_running = false
	# show end screen / final time

func _ready() -> void:
	snail.global_position = start_point.global_position
