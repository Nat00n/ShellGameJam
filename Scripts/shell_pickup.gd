@tool
# shell_pickup.gd
extends Area2D
@export var upgrade: ShellUpgrade

@onready var visual_root: Node2D = $VisualRoot
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_upgrade_visual()

func _apply_upgrade_visual() -> void:
	if not upgrade or not upgrade.model_scene:
		return
	var instance := upgrade.model_scene.instantiate()
	visual_root.add_child(instance)

	var shape_ref: CollisionShape2D = instance.get_node_or_null("ShapeRef")
	if shape_ref:
		collision.shape = shape_ref.shape
		collision.position = shape_ref.position

func _on_body_entered(body: Node) -> void:
	if body.has_method("equip_shell_upgrade"):
		body.equip_shell_upgrade(upgrade)
		queue_free()
