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

func _process(delta: float) -> void:
	_time += delta
	_reaction_time = maxf(0.0, _reaction_time - delta)
	_investigation_time = maxf(0.0, _investigation_time - delta)
	if awake and is_instance_valid(follow_target):
		var bob_amount := 1.0 if RunState.settings.get("reduced_motion", false) else 3.0
		var reaction_bob := 0.0
		if _reaction_time > 0.0 and not RunState.settings.get("reduced_motion", false):
			reaction_bob = -4.0 * sin((1.0 - _reaction_time / 0.7) * PI)
		var drift := Vector2(-13.0 + sin(_time * 1.4) * 2.0, -19.0 + sin(_time * 2.4) * bob_amount + reaction_bob)
		var destination := follow_target.global_position + drift
		if _investigation_time > 0.0 and not RunState.settings.get("reduced_motion", false):
			destination = _investigation_target + Vector2(12.0, -5.0 + sin(_time * 3.0) * 2.0)
		global_position = global_position.lerp(destination, 1.0 - exp(-delta * 4.5))
	queue_redraw()

func wake() -> void:
	awake = true

func react_to_hint(points: int) -> void:
	hint_mood = clampi(hint_mood + points, 0, 12)
	_expression = 3
	_reaction_time = 0.7

func react_to_discovery() -> void:
	_expression = 2
	_reaction_time = 0.7

func investigate(world_position: Vector2) -> void:
	if not awake or RunState.settings.get("reduced_motion", false):
		return
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
