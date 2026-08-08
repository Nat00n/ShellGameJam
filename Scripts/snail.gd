# snail.gd
class_name Snail
extends CharacterBody2D

@export var move_speed: float = 60.0
@export var gravity: float = 900.0
@export var air_control: float = 8.0
@export var base_roll_speed: float = 120.0
@export var roll_friction: float = 15.0

@export var base_shell: ShellUpgrade

@onready var shell_root: Node2D = $ShellRoot
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var default_collision_shape: Shape2D
var default_collision_position: Vector2

var current_upgrade: ShellUpgrade
var facing_dir: float = 1.0
var roll_speed: float = 0.0
var is_in_shell_state: bool = false

var is_floating: bool = false
var float_timer: float = 0.0
var float_gravity_scale: float = 0.2

func _ready() -> void:
	default_collision_shape = collision_shape.shape
	default_collision_position = collision_shape.position

	current_upgrade = base_shell
	_apply_model(current_upgrade)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("use_shell"):
		activate_shell_ability()

	if is_floating:
		float_timer -= delta
		if float_timer <= 0.0:
			is_floating = false

func get_effective_gravity() -> float:
	return gravity * (float_gravity_scale if is_floating else 1.0)

func equip_shell_upgrade(upgrade: ShellUpgrade) -> void:
	current_upgrade = upgrade
	_apply_model(upgrade)
	if is_in_shell_state:
		apply_shell_collision()

func consume_upgrade() -> void:
	is_floating = false
	equip_shell_upgrade(base_shell)

func _apply_model(upgrade: ShellUpgrade) -> void:
	for child in shell_root.get_children():
		child.queue_free()
	if upgrade and upgrade.model_scene:
		var instance := upgrade.model_scene.instantiate()
		shell_root.add_child(instance)

		var shape_ref: CollisionShape2D = instance.get_node_or_null("ShapeRef")
		if shape_ref:
			shape_ref.disabled = true

func apply_shell_collision() -> void:
	var shape_ref: CollisionShape2D = null
	if shell_root.get_child_count() > 0:
		shape_ref = shell_root.get_child(0).get_node_or_null("ShapeRef")

	if shape_ref:
		collision_shape.shape = shape_ref.shape
		collision_shape.position = shape_ref.position
	else:
		revert_to_base_collision()

func revert_to_base_collision() -> void:
	collision_shape.shape = default_collision_shape
	collision_shape.position = default_collision_position

func activate_shell_ability() -> void:
	if not current_upgrade or current_upgrade.ability == ShellUpgrade.Ability.NONE:
		return

	match current_upgrade.ability:
		ShellUpgrade.Ability.BOOST:
			velocity += current_upgrade.boost_force * facing_dir
		ShellUpgrade.Ability.FLOAT:
			is_floating = true
			float_timer = current_upgrade.float_duration
		ShellUpgrade.Ability.SPEED_UP:
			roll_speed *= current_upgrade.roll_speed_multiplier
			velocity.x = roll_speed

	consume_upgrade()
