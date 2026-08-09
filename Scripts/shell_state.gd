extends State
@onready var player: Snail = owner
@export var idle_state: State

const HOP_VELOCITY := -180.0
const HOP_FORWARD_BOOST := 1.4

var just_hopped: bool = false

func enter_state() -> void:
	player.is_in_shell_state = true
	player.apply_shell_collision()
	player.play_retract_animation()

	player.roll_speed = absf(player.velocity.x)
	if player.velocity.x != 0.0:
		player.facing_dir = signf(player.velocity.x)
		player.update_facing_visual()

	just_hopped = false
	if player.is_on_floor():
		player.velocity.y = HOP_VELOCITY
		player.roll_speed *= HOP_FORWARD_BOOST
		player.velocity.x = player.roll_speed * player.facing_dir
		just_hopped = true

func exit_state() -> void:
	player.is_in_shell_state = false
	player.velocity.x = player.roll_speed * player.facing_dir
	player.revert_to_base_collision()
	player.play_emerge_animation()
	player.reset_shell_rotation()

func physics_update(delta: float) -> void:
	if just_hopped:
		just_hopped = false
	elif player.is_on_floor():
		var floor_normal := player.get_floor_normal()
		var tangent := Vector2(-floor_normal.y, floor_normal.x) * player.facing_dir
		var alignment := tangent.dot(Vector2.DOWN)

		if player.is_speed_boosted:
			player.velocity = tangent * player.speed_boost_roll_speed
		else:
			player.velocity += tangent * (player.gravity * alignment) * delta
	else:
		player.velocity.y += player.get_effective_gravity() * delta

	player.move_and_slide()

	if player.is_on_floor():
		player.roll_speed = player.velocity.length()
	else:
		player.roll_speed = absf(player.velocity.x)
		player.roll_speed = move_toward(player.roll_speed, 0.0, player.air_control * delta)

	player.spin_shell(delta)

	if not Input.is_action_pressed("enter_shell"):
		switch_state.emit(idle_state)
