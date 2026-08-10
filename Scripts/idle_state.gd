# idle_state.gd
extends State
@onready var player: Snail = owner
@export var move_state: State
@export var shell_state: State

func physics_update(delta: float) -> void:
	if player.just_boosted:
		player.just_boosted = false
		player.move_and_slide()
		return
	
	player.velocity.y += player.get_effective_gravity() * delta

	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)

		if Input.get_axis("move_left", "move_right") != 0.0:
			switch_state.emit(move_state)

	if Input.is_action_pressed("enter_shell"):
		switch_state.emit(shell_state)
		
	player.move_and_slide()
