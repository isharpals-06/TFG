extends CharacterBody2D
class_name Traveler

const TRAVELER_SPRITE: Texture2D = preload("res://design/assets/traveler_sprite.png")
const TRAVELER_WALK_SPRITE: Texture2D = preload("res://design/assets/traveler_walk_cycle.png")
const WALK_FRAME_SOURCE_RECTS := [
	Rect2(107, 67, 330, 590),
	Rect2(650, 67, 330, 590),
	Rect2(1193, 67, 330, 590),
	Rect2(1736, 67, 330, 590),
]

signal moved(direction: Vector2)

@export var walk_speed: float = 48.0
@export var run_speed: float = 74.0
@export var movement_bounds := Rect2(20, 36, 600, 300)

var facing := Vector2.DOWN
var movement_enabled := true
var camera_reference: Camera2D
var _anim_time := 0.0
var _traversal_active := false

func _physics_process(delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		if _traversal_active and not RunState.settings.get("reduced_motion", false):
			_anim_time += delta * 8.0
			queue_redraw()
		move_and_slide()
		return
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var iso_direction := Vector2(input_direction.x - input_direction.y, (input_direction.x + input_direction.y) * 0.5)
	if is_instance_valid(camera_reference):
		iso_direction = iso_direction.rotated(camera_reference.rotation)
	if iso_direction.length() > 1.0:
		iso_direction = iso_direction.normalized()
	if input_direction.length() > 0.01:
		facing = iso_direction
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

func hop_to(destination: Vector2, duration: float) -> void:
	set_movement_enabled(false)
	if duration <= 0.0:
		global_position = destination
		set_movement_enabled(true)
		return
	_traversal_active = true
	var takeoff := global_position
	var midair := takeoff.lerp(destination, 0.5) + Vector2(0, -8)
	var tween := create_tween()
	tween.tween_property(self, "global_position", midair, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", destination, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	global_position = destination
	_traversal_active = false
	set_movement_enabled(true)

func _draw() -> void:
	var reduced_motion := bool(RunState.settings.get("reduced_motion", false))
	var walking := velocity.length() > 2.0 or _traversal_active
	var tint := Color.WHITE if RunState.presentation == 0 else Color("#c7d4ed")
	draw_rect(Rect2(-8, -2, 16, 4), Color(0.04, 0.07, 0.075, 0.42))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0 if facing.x < -0.05 else 1.0, 1.0))
	if walking and not reduced_motion:
		var frame := int(_anim_time / 3.0) % WALK_FRAME_SOURCE_RECTS.size()
		draw_texture_rect_region(TRAVELER_WALK_SPRITE, Rect2(-9, -29, 18, 32), WALK_FRAME_SOURCE_RECTS[frame], tint)
	else:
		draw_texture_rect_region(TRAVELER_SPRITE, Rect2(-9, -29, 18, 32), Rect2(235, 245, 555, 1120), tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
