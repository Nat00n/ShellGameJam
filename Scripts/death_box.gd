# death_box.gd
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Snail:
		var world := get_tree().current_scene
		if world.has_method("trigger_death_restart"):
			world.trigger_death_restart()
