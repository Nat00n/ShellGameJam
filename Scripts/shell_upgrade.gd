# shell_upgrade.gd
class_name ShellUpgrade
extends Resource

enum Ability { NONE, BOOST, FLOAT, SPEED_UP }

@export var upgrade_name: String = "Shell"
@export var model_scene: PackedScene
@export var ability: Ability = Ability.NONE

@export_group("Ability Params")
@export var boost_force: Vector2 = Vector2.ZERO
@export var float_duration: float = 0.0
@export var roll_speed_multiplier: float = 1.0
