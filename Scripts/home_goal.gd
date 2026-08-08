# home_goal.gd
extends Area2D

signal reached_home

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Snail:
		reached_home.emit()
