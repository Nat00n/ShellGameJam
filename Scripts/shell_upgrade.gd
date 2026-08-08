# shell_upgrade.gd
class_name ShellUpgrade
extends Resource

enum Ability { NONE, BOOST, FLOAT, SPEED_UP }

@export var upgrade_name: String = "Shell"
@export var model_scene: PackedScene
@export var ability: Ability = Ability.NONE

@export_group("Ability Params")
@export var boost_force: Vector2 = Vector2.ZERO       # shotgun
@export var boost_launch_angle_deg: float = 20.0       # shotgun, angled fling

@export var float_duration: float = 5.0                # bag
@export var float_y_velocity_kick: float = -40.0        # bag, small upward pop on activate

@export var speed_up_duration: float = 10.0              # spiral
@export var speed_up_accel_mult: float = 1.8            # spiral, extra roll acceleration
@export var speed_up_friction_mult: float = 0.3          # spiral, less speed lost
@export var speed_up_instant_roll_speed: float = 150.0    # spiral, immediate kick
