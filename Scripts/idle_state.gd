# idle_state.gd
extends State
@onready var player: Snail = owner
@export var move_state: State
@export var shell_state: State

@export var idle_friction: float = 100.0

func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0.0, idle_friction * delta)
	player.velocity.y += player.get_effective_gravity() * delta
	player.move_and_slide()
	player.align_body_to_floor(delta)

	if Input.is_action_pressed("enter_shell"):
		switch_state.emit(shell_state)
	elif Input.get_axis("move_left", "move_right") != 0.0:
		switch_state.emit(move_state)
