extends State
@onready var player: Snail = owner
@export var idle_state: State

const HOP_VELOCITY := -180.0

func enter_state() -> void:
	player.is_in_shell_state = true
	player.apply_shell_collision()

	player.roll_speed = player.velocity.x if absf(player.velocity.x) > 20.0 \
		else player.base_roll_speed * player.facing_dir

	if player.is_on_floor():
		player.velocity.y = HOP_VELOCITY

func exit_state() -> void:
	player.is_in_shell_state = false
	player.revert_to_base_collision()

func physics_update(delta: float) -> void:
	player.velocity.y += player.get_effective_gravity() * delta

	if player.is_on_floor():
		var floor_normal := player.get_floor_normal()
		var slope_dir := floor_normal.orthogonal().normalized()
		var slope_accel := slope_dir * player.gravity * delta

		player.roll_speed += slope_accel.x
		player.roll_speed = move_toward(player.roll_speed, 0.0, player.roll_friction * delta)
		player.velocity.x = player.roll_speed
		if player.roll_speed != 0.0:
			player.facing_dir = signf(player.roll_speed)
	else:
		player.velocity.x = move_toward(player.velocity.x, player.roll_speed, player.air_control)

	player.move_and_slide()

	if not Input.is_action_pressed("enter_shell"):
		switch_state.emit(idle_state)
