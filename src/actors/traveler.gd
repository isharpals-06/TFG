extends CharacterBody2D
class_name Traveler

signal moved(direction: Vector2)

@export var walk_speed: float = 48.0
@export var run_speed: float = 74.0
@export var movement_bounds := Rect2(20, 36, 600, 300)

var facing := Vector2.DOWN
var movement_enabled := true
var camera_reference: Camera2D
var _anim_time := 0.0

func _physics_process(delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var iso_direction := Vector2(input_direction.x - input_direction.y, (input_direction.x + input_direction.y) * 0.5)
	if is_instance_valid(camera_reference):
		iso_direction = iso_direction.rotated(-camera_reference.rotation)
	if iso_direction.length() > 1.0:
		iso_direction = iso_direction.normalized()
	if input_direction.length() > 0.01:
		facing = input_direction
		var speed := run_speed if Input.is_action_pressed("run") else walk_speed
		velocity = iso_direction * speed
		_anim_time += delta * (12.0 if speed == run_speed else 8.0)
		moved.emit(iso_direction)
	else:
		velocity = Vector2.ZERO
		_anim_time += delta * 2.0
	move_and_slide()
	global_position.x = clampf(global_position.x, movement_bounds.position.x, movement_bounds.end.x)
	global_position.y = clampf(global_position.y, movement_bounds.position.y, movement_bounds.end.y)
	queue_redraw()

func set_movement_enabled(value: bool) -> void:
	movement_enabled = value

func _draw() -> void:
	var bob := 1 if velocity.length() > 2.0 and int(_anim_time) % 2 == 0 else 0
	var cloak := Color("#5a6a5b") if RunState.presentation == 0 else Color("#52637b")
	var cloak_light := Color("#829079") if RunState.presentation == 0 else Color("#7c91b4")
	var shadow := Color(0.04, 0.07, 0.075, 0.52)
	draw_rect(Rect2(-7, -2, 14, 4), shadow)
	draw_rect(Rect2(-5, -15 + bob, 10, 7), Color("#202b32"))
	draw_rect(Rect2(-4, -14 + bob, 8, 6), Color("#d4b38d"))
	draw_rect(Rect2(-5, -15 + bob, 10, 3), Color("#303c46"))
	draw_rect(Rect2(-6, -9 + bob, 12, 9), cloak)
	draw_rect(Rect2(-5, -8 + bob, 3, 7), cloak_light)
	draw_rect(Rect2(-4, -1, 3, 4), Color("#292e35"))
	draw_rect(Rect2(1, -1, 3, 4), Color("#292e35"))
	draw_rect(Rect2(-3, -13 + bob, 1, 1), Color("#3a302c"))
	draw_rect(Rect2(2, -13 + bob, 1, 1), Color("#3a302c"))
	if velocity.length() > 2.0 and int(_anim_time) % 2 == 0:
		draw_rect(Rect2(-5, 2, 3, 2), Color("#292e35"))
		draw_rect(Rect2(2, 1, 3, 2), Color("#292e35"))

