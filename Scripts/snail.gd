# snail.gd
class_name Snail
extends CharacterBody2D

@export var move_speed: float = 100.0
@export var gravity: float = 900.0
@export var air_control: float = 8.0
@export var roll_friction: float = 15.0

@export var base_shell: ShellUpgrade

@onready var shell_root: Node2D = $ShellRoot
@onready var body_root: Node2D = $BodyRoot
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var default_collision_shape: Shape2D
var default_collision_position: Vector2

var current_upgrade: ShellUpgrade
var facing_dir: float = 1.0
var roll_speed: float = 0.0
var roll_dir: float = 1.0
var is_in_shell_state: bool = false

var is_floating: bool = false
var float_timer: float = 0.0
var float_gravity_scale: float = 0.2

var shell_radius: float = 25.0

var body_tween: Tween

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

func play_retract_animation() -> void:
	if body_tween:
		body_tween.kill()

	body_root.scale = Vector2.ONE
	body_root.rotation = 0.0

	body_tween = create_tween()
	body_tween.set_parallel(true)
	body_tween.tween_property(body_root, "scale", Vector2(0.2, 0.2), 0.35)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	body_tween.tween_property(body_root, "rotation", deg_to_rad(120), 0.35)
	body_tween.tween_property(body_root, "visible", false, 0.7)

func play_emerge_animation() -> void:
	if body_tween:
		body_tween.kill()
	
	body_root.visible = true

	body_root.rotation = 0.0

	body_tween = create_tween()
	body_tween.tween_property(body_root, "scale", Vector2.ONE, 0.35)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func align_body_to_floor(delta: float) -> void:
	if is_on_floor():
		var floor_normal := get_floor_normal()
		var target_rotation := floor_normal.angle() + PI / 2.0
		self.rotation = lerp_angle(self.rotation, target_rotation, 10.0 * delta)
	else:
		self.rotation = lerp_angle(self.rotation, 0.0, 5.0 * delta)

func spin_shell(delta: float) -> void:
	shell_root.rotation += (roll_speed / shell_radius) * delta

func reset_shell_rotation() -> void:
	var tween := create_tween()
	tween.tween_property(shell_root, "rotation", 0.0, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func update_facing_visual() -> void:
	body_root.scale.x = absf(body_root.scale.x) * facing_dir
