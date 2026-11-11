extends Node2D
class_name Beth

const BETH_EXPRESSIONS: Texture2D = preload("res://design/assets/beth_expressions.png")
const EXPRESSION_SOURCE_RECTS := [
	Rect2(75, 167, 390, 390),
	Rect2(619, 167, 390, 390),
	Rect2(1163, 167, 390, 390),
	Rect2(1707, 167, 390, 390),
]

var follow_target: Node2D
var awake := false
var hint_mood := 0
var _time := 0.0
var _reaction_time := 0.0
var _investigation_time := 0.0
var _investigation_target := Vector2.ZERO
var _expression := 0
var _still_time := 0.0
var _playful_cooldown := 0.0
var _playful_elapsed := 0.0
var _playful_active := false
var _last_follow_position := Vector2.ZERO
var _has_last_follow_position := false

func _process(delta: float) -> void:
	_time += delta
	_reaction_time = maxf(0.0, _reaction_time - delta)
	_investigation_time = maxf(0.0, _investigation_time - delta)
	if awake and is_instance_valid(follow_target):
		var reduced_motion := bool(RunState.settings.get("reduced_motion", false))
		_update_playful_state(delta, reduced_motion)
		var bob_amount := 1.0 if reduced_motion else 3.0
		var reaction_bob := 0.0
		if _reaction_time > 0.0 and not reduced_motion:
			reaction_bob = -4.0 * sin((1.0 - _reaction_time / 0.7) * PI)
		var drift := Vector2(-13.0 + sin(_time * 1.4) * 2.0, -19.0 + sin(_time * 2.4) * bob_amount + reaction_bob)
		if _playful_active and not reduced_motion:
			var orbit_angle := _playful_elapsed * TAU / 1.7
			drift = Vector2(-13.0 + cos(orbit_angle) * 12.0, -19.0 + sin(orbit_angle) * 7.0)
		var destination := follow_target.global_position + drift
		if _investigation_time > 0.0 and not reduced_motion:
			destination = _investigation_target + Vector2(12.0, -5.0 + sin(_time * 3.0) * 2.0)
		global_position = global_position.lerp(destination, 1.0 - exp(-delta * 4.5))
	queue_redraw()

func _update_playful_state(delta: float, reduced_motion: bool) -> void:
	if reduced_motion:
		_playful_active = false
		_still_time = 0.0
		_last_follow_position = follow_target.global_position
		_has_last_follow_position = true
		return
	var follow_position := follow_target.global_position
	if not _has_last_follow_position or follow_position.distance_to(_last_follow_position) > 1.5:
		_still_time = 0.0
		_playful_active = false
	else:
		_still_time += delta
	_last_follow_position = follow_position
	_has_last_follow_position = true
	_playful_cooldown = maxf(0.0, _playful_cooldown - delta)
	if _playful_active:
		_playful_elapsed += delta
		if _playful_elapsed >= 1.7:
			_playful_active = false
			_playful_cooldown = 12.0
			_still_time = 0.0
	elif _still_time >= 7.0 and _playful_cooldown <= 0.0 and _reaction_time <= 0.0 and _investigation_time <= 0.0:
		_playful_active = true
		_playful_elapsed = 0.0

func wake() -> void:
	awake = true

func react_to_hint(points: int) -> void:
	hint_mood = clampi(hint_mood + points, 0, 12)
	_playful_active = false
	_still_time = 0.0
	_expression = 3
	_reaction_time = 0.7

func react_to_discovery() -> void:
	_playful_active = false
	_still_time = 0.0
	_expression = 2
	_reaction_time = 0.7

func investigate(world_position: Vector2) -> void:
	if not awake or RunState.settings.get("reduced_motion", false):
		return
	_playful_active = false
	_still_time = 0.0
	_investigation_target = world_position
	_investigation_time = 1.35

func _draw() -> void:
	var hover_amount := 0.0 if RunState.settings.get("reduced_motion", false) else 1.0
	var hover := roundi(sin(_time * 2.7) * hover_amount)
	var breath := 0.0 if RunState.settings.get("reduced_motion", false) else sin(_time * 2.7) * 0.035
	var reaction_bloom := 0.08 if _reaction_time > 0.0 and not RunState.settings.get("reduced_motion", false) else 0.0
	var bloom := 1.0 + breath + reaction_bloom
	var hint_tint := Color.WHITE.lerp(Color("#dfb6cb"), clampf(float(hint_mood) / 12.0, 0.0, 0.55))
	var frame := 0
	if not awake:
		frame = 1
	elif _reaction_time > 0.0:
		frame = _expression
	elif _investigation_time > 0.0:
		frame = 3
	elif not RunState.settings.get("reduced_motion", false) and fposmod(_time, 4.7) > 4.56:
		frame = 1
	draw_texture_rect_region(
		BETH_EXPRESSIONS,
		Rect2(-10.0 * bloom, -10.0 + hover, 20.0 * bloom, 20.0 * bloom),
		EXPRESSION_SOURCE_RECTS[frame],
		hint_tint
	)
