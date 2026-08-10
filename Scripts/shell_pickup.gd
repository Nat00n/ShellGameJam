@tool
# shell_pickup.gd
extends Area2D

@export var upgrade: ShellUpgrade
@export var respawn_time: float = 10.0

@onready var visual_root: Node2D = $VisualRoot
@onready var collision: CollisionShape2D = $CollisionShape2D
const POWER_UP = preload("uid://degj4kct7xsur")

var is_available: bool = true
var respawn_tween: Tween

func _ready() -> void:
	if Engine.is_editor_hint():
		_apply_upgrade_visual()
		return

	body_entered.connect(_on_body_entered)
	_apply_upgrade_visual()

func _apply_upgrade_visual() -> void:
	if not upgrade or not upgrade.model_scene:
		return
	for child in visual_root.get_children():
		child.queue_free()

	var instance := upgrade.model_scene.instantiate()
	visual_root.add_child(instance)

	var shape_ref: CollisionShape2D = instance.get_node_or_null("ShapeRef")
	if shape_ref:
		collision.shape = shape_ref.shape
		collision.position = shape_ref.position

func _on_body_entered(body: Node) -> void:
	if not is_available:
		return
	if body.has_method("equip_shell_upgrade"):
		body.equip_shell_upgrade(upgrade)
		_collect()

func _collect() -> void:
	AudioManager.play_sfx(POWER_UP)
	is_available = false
	collision.set_deferred("disabled", true)
	visual_root.scale = Vector2.ZERO

	var timer := get_tree().create_timer(respawn_time)
	timer.timeout.connect(_respawn)

func _respawn() -> void:
	if respawn_tween:
		respawn_tween.kill()
	respawn_tween = create_tween()
	respawn_tween.tween_property(visual_root, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	respawn_tween.finished.connect(_on_respawn_finished)

func _on_respawn_finished() -> void:
	collision.set_deferred("disabled", false)
	await get_tree().physics_frame
	is_available = true

	for body in get_overlapping_bodies():
		if body.has_method("equip_shell_upgrade"):
			is_available = false
			if not body_exited.is_connected(_on_body_exited_while_blocked):
				body_exited.connect(_on_body_exited_while_blocked)
			break

func _on_body_exited_while_blocked(body: Node) -> void:
	if body.has_method("equip_shell_upgrade"):
		is_available = true
		body_exited.disconnect(_on_body_exited_while_blocked)
