extends State
@onready var player: Snail = owner
@export var idle_state: State
@export var shell_state: State

func physics_update(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		player.facing_dir = signf(dir)
		player.update_facing_visual()

	player.velocity.x = dir * player.move_speed
	player.velocity.y += player.get_effective_gravity() * delta
	player.move_and_slide()
	player.align_body_to_floor(delta)

	if Input.is_action_just_pressed("enter_shell"):
		switch_state.emit(shell_state)
	elif dir == 0.0:
		switch_state.emit(idle_state)
