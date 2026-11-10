extends CharacterBody2D
class_name Traveler

const TRAVELER_SPRITE: Texture2D = preload("res://design/assets/traveler_sprite.png")
const TRAVELER_WALK_SPRITE: Texture2D = preload("res://design/assets/traveler_walk.png")

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
	var reduced_motion := bool(RunState.settings.get("reduced_motion", false))
	var walking := velocity.length() > 2.0
	var step_pose := walking and int(_anim_time * 0.5) % 2 == 0 and not reduced_motion
	var bob := 1.0 if step_pose else 0.0
	var tint := Color.WHITE if RunState.presentation == 0 else Color("#c7d4ed")
	draw_rect(Rect2(-8, -2, 16, 4), Color(0.04, 0.07, 0.075, 0.42))
	if step_pose:
		draw_texture_rect_region(TRAVELER_WALK_SPRITE, Rect2(-9, -29 + bob, 18, 32), Rect2(205, 305, 535, 1000), tint)
	else:
		draw_texture_rect_region(TRAVELER_SPRITE, Rect2(-9, -29, 18, 32), Rect2(235, 245, 555, 1120), tint)
