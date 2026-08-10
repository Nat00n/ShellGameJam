extends State
@onready var player: Snail = owner
@export var idle_state: State
@export var shell_state: State
@export var max_walk_angle_deg: float = 95.0

func physics_update(delta: float) -> void:
	if player.just_boosted:
		player.just_boosted = false
		player.move_and_slide()
		return
	
	if player.is_on_floor():
		var dir := Input.get_axis("move_left", "move_right")
		if dir != 0.0:
			player.facing_dir = signf(dir)
			player.update_facing_visual()

		var floor_normal := player.get_floor_normal()
		var slope_angle := rad_to_deg(floor_normal.angle_to(Vector2.UP))

		if absf(slope_angle) <= max_walk_angle_deg:
			var tangent := Vector2(-floor_normal.y, floor_normal.x)
			player.velocity = tangent * dir * player.move_speed
		else:
			player.velocity.y += player.get_effective_gravity() * delta
			player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)

		if Input.is_action_pressed("enter_shell"):
			switch_state.emit(shell_state)
		elif dir == 0.0 and absf(slope_angle) <= max_walk_angle_deg:
			switch_state.emit(idle_state)
	else:
		player.velocity.y += player.get_effective_gravity() * delta

		if player.is_floating:
			var dir := Input.get_axis("move_left", "move_right")
			player.velocity.x = move_toward(player.velocity.x, dir * player.move_speed, player.float_air_control * delta)

	player.move_and_slide()
