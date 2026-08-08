extends State
@onready var player: Snail = owner
@export var move_state: State
@export var shell_state: State

func physics_update(delta: float) -> void:
	player.velocity.y += player.get_effective_gravity() * delta
	player.move_and_slide()

	var dir := Input.get_axis("move_back", "move_forward")
	if Input.is_action_just_pressed("enter_shell"):
		switch_state.emit(shell_state)
	elif dir != 0.0:
		switch_state.emit(move_state)
