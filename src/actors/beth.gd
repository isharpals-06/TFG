extends Node2D
class_name Beth

var follow_target: Node2D
var awake := false
var hint_mood := 0
var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	if awake and is_instance_valid(follow_target):
		var bob_amount := 1.0 if RunState.settings.get("reduced_motion", false) else 3.0
		var drift := Vector2(-13.0, -19.0 + sin(_time * 2.4) * bob_amount)
		global_position = global_position.lerp(follow_target.global_position + drift, 1.0 - exp(-delta * 4.5))
	queue_redraw()

func wake() -> void:
	awake = true

func react_to_hint(points: int) -> void:
	hint_mood = clampi(hint_mood + points, 0, 12)

func _draw() -> void:
	var hover_amount := 0.0 if RunState.settings.get("reduced_motion", false) else 1.0
	var hover := roundi(sin(_time * 2.7) * hover_amount)
	var pale := Color("#ecfbff")
	var glow := Color("#91d7e9")
	var echo := Color("#b9a8dc").lerp(Color("#d78caa"), clampf(float(hint_mood) / 12.0, 0.0, 0.8))
	var glow_wash := Color(glow.r, glow.g, glow.b, 0.13)
	draw_rect(Rect2(-7, -1 + hover, 14, 8), glow_wash)
	draw_rect(Rect2(-5, -5 + hover, 10, 12), echo)
	draw_rect(Rect2(-4, -6 + hover, 8, 10), pale)
	draw_rect(Rect2(-3, -7 + hover, 6, 1), pale)
	draw_rect(Rect2(-3, 5 + hover, 6, 1), glow)
	if awake:
		draw_rect(Rect2(-3, -2 + hover, 2, 2), Color("#28323f"))
		draw_rect(Rect2(2, -2 + hover, 2, 2), Color("#28323f"))
		if hint_mood < 5:
			draw_rect(Rect2(-1, 2 + hover, 2, 1), Color("#8299a8"))
		else:
			draw_rect(Rect2(-1, 2 + hover, 2, 1), Color("#b56e8d"))

