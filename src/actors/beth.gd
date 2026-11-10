extends Node2D
class_name Beth

const BETH_SPRITE: Texture2D = preload("res://design/assets/beth_sprite.png")

var follow_target: Node2D
var awake := false
var hint_mood := 0
var _time := 0.0
var _reaction_time := 0.0
var _investigation_time := 0.0
var _investigation_target := Vector2.ZERO

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
	_reaction_time = 0.7

func react_to_discovery() -> void:
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
	draw_texture_rect_region(
		BETH_SPRITE,
		Rect2(-10.0 * bloom, -10.0 + hover, 20.0 * bloom, 20.0 * bloom),
		Rect2(510, 250, 520, 520),
		hint_tint
	)
	if not awake:
		var sleeping_eye := Color("#badfe9")
		draw_rect(Rect2(-4, -1 + hover, 3, 1), sleeping_eye)
		draw_rect(Rect2(2, -1 + hover, 3, 1), sleeping_eye)
