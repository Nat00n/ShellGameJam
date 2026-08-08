class_name StateMachine
extends Node

@export var initial_state : State

var active_state: State:
	set(new_value):
		active_state = new_value
		print("Changed to ", active_state)

func _ready() -> void:
	for child_state: State in get_children():
		child_state.switch_state.connect(change_state)
	
	change_state(initial_state)

func _process(delta: float) -> void:
	if active_state:
		active_state.update(delta)

func _physics_process(delta: float) -> void:
	if active_state:
		active_state.physics_update(delta)

func change_state(new_state: State) -> void:
	if new_state == active_state:
		return
	
	if active_state:
		active_state.exit_state()
	
	if get_parent().has_method("update_previous_state"):
		get_parent().update_previous_state(active_state)
	active_state = new_state
	
	if active_state:
		active_state.enter_state()
