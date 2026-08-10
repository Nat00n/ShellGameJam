extends State
@onready var player: Snail = owner
@export var idle_state: State

const HOP_VELOCITY := -250.0
const HOP_FORWARD_BOOST := 1.4
const JUMP = preload("uid://biy2i48ikjxn5")

var just_hopped: bool = false

func enter_state() -> void:
	player.is_in_shell_state = true
	player.apply_shell_collision()
	player.play_retract_animation()

	player.roll_speed = absf(player.velocity.x)
	if absf(player.velocity.x) > 1.0:
		player.facing_dir = signf(player.velocity.x)
		player.update_facing_visual()

	just_hopped = false
	if player.is_on_floor():
		AudioManager.play_sfx(JUMP)
		player.velocity.y = HOP_VELOCITY
		player.roll_speed *= HOP_FORWARD_BOOST
		just_hopped = true

func exit_state() -> void:
	player.is_in_shell_state = false
	player.revert_to_base_collision()
	player.play_emerge_animation()
	player.reset_shell_rotation()

func physics_update(delta: float) -> void:
	if player.just_boosted:
		player.just_boosted = false
		player.move_and_slide()
		player.spin_shell(delta)
		if not Input.is_action_pressed("enter_shell"):
			switch_state.emit(idle_state)
		return
	
	if just_hopped:
		just_hopped = false
	elif player.is_on_floor():
		var floor_normal := player.get_floor_normal()
		var raw_tangent := Vector2(-floor_normal.y, floor_normal.x)

		var dir := player.facing_dir
		if player.velocity.length() > 5.0:
			dir = 1.0 if raw_tangent.dot(player.velocity) >= 0.0 else -1.0
			if dir != player.facing_dir:
				player.facing_dir = dir
				player.update_facing_visual()

		var tangent := raw_tangent * dir
		var alignment := tangent.dot(Vector2.DOWN)

		var accel_mult := 1.0
		if player.is_speed_boosted:
			accel_mult = player.speed_boost_accel_mult

		player.roll_speed += player.gravity * alignment * accel_mult * delta

		if player.is_speed_boosted:
			player.roll_speed = maxf(player.roll_speed, player.speed_boost_roll_speed)

		if player.roll_speed < 0.0:
			dir *= -1.0
			player.facing_dir = dir
			player.roll_speed = absf(player.roll_speed)
			player.update_facing_visual()

		var final_tangent := raw_tangent * player.facing_dir
		player.velocity = final_tangent * player.roll_speed
	else:
		if not just_hopped:
			player.velocity.y += player.get_effective_gravity() * delta

	player.move_and_slide()
	player.spin_shell(delta)

	if not Input.is_action_pressed("enter_shell"):
		switch_state.emit(idle_state)
