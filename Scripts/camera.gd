# follow_camera.gd
extends Camera2D

@export var target: Node2D

@export_group("Smoothing")
@export var follow_speed: float = 5.0

@export_group("Deadzone")
@export var deadzone_size: Vector2 = Vector2(40, 30)

@export_group("Bounds")
@export var use_limits: bool = false
@export var limit_rect: Rect2 = Rect2(0, 0, 0, 0)

var _tracked_position: Vector2

func _ready() -> void:
	if target:
		_tracked_position = target.global_position
		global_position = _tracked_position

	if use_limits:
		limit_left = int(limit_rect.position.x)
		limit_top = int(limit_rect.position.y)
		limit_right = int(limit_rect.end.x)
		limit_bottom = int(limit_rect.end.y)

func _physics_process(delta: float) -> void:
	if not target:
		return

	var target_pos := target.global_position
	var offset := target_pos - _tracked_position

	# Only move the tracked point if target has left the deadzone box
	var move := Vector2.ZERO
	if absf(offset.x) > deadzone_size.x:
		move.x = offset.x - sign(offset.x) * deadzone_size.x
	if absf(offset.y) > deadzone_size.y:
		move.y = offset.y - sign(offset.y) * deadzone_size.y

	_tracked_position += move

	global_position = global_position.lerp(_tracked_position, 1.0 - exp(-follow_speed * delta))
