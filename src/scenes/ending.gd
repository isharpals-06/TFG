extends Control

func _ready() -> void:
	var title := Label.new()
	title.text = "YOUR HAND HAS BEEN HERE BEFORE."
	title.position = Vector2(24, 48)
	title.size = Vector2(272, 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11 if RunState.settings.get("large_text", false) else 9)
	title.add_theme_color_override("font_color", Color("#e7e2cf"))
	add_child(title)
	var note := Label.new()
	note.text = "Beth leans close to the medallion. The old stone gives one quiet pulse."
	note.position = Vector2(34, 78)
	note.size = Vector2(252, 35)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 9 if RunState.settings.get("large_text", false) else 7)
	note.add_theme_color_override("font_color", Color("#b9c6bd"))
	add_child(note)
	var final_line := Label.new()
	final_line.text = "Beyond the arch, a second light answers."
	final_line.position = Vector2(32, 118)
	final_line.size = Vector2(256, 18)
	final_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_line.add_theme_font_size_override("font_size", 8 if RunState.settings.get("large_text", false) else 7)
	final_line.add_theme_color_override("font_color", Color("#d0c9a9"))
	add_child(final_line)
	var button := Button.new()
	button.text = "Return to title"
	button.position = Vector2(98, 147)
	button.size = Vector2(124, 19)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 10 if RunState.settings.get("large_text", false) else 8)
	button.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn"))
	add_child(button)
	button.call_deferred("grab_focus")
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(320, 180)), Color("#101c26"))
	for index in range(44):
		var x := (index * 71 + 19) % 320
		var y := (index * 29 + 7) % 130
		draw_rect(Rect2(x, y, 1, 1), Color("#9bb0b1"))
	draw_rect(Rect2(0, 133, 320, 47), Color("#1c2a30"))
	draw_rect(Rect2(72, 131, 8, 39), Color("#364544"))
	draw_rect(Rect2(240, 127, 9, 43), Color("#3b4946"))
	draw_rect(Rect2(64, 127, 25, 5), Color("#59665b"))
	draw_rect(Rect2(232, 123, 25, 5), Color("#5a675c"))
	var medallion := Color("#c6b77f")
	draw_rect(Rect2(155, 20, 10, 2), medallion)
	draw_rect(Rect2(153, 22, 14, 12), medallion)
	draw_rect(Rect2(155, 34, 10, 2), medallion)
	draw_rect(Rect2(158, 25, 4, 6), Color("#24343a"))
	var echo := clampf(float(RunState.total_hint_points) / 16.0, 0.0, 1.0)
	var beth_light := Color("#a8e1ec").lerp(Color("#d08faa"), echo)
	var glow := Color(beth_light.r, beth_light.g, beth_light.b, 0.22)
	draw_rect(Rect2(170, 37, 12, 6), glow)
	draw_rect(Rect2(172, 35, 8, 10), beth_light)
	draw_rect(Rect2(174, 37, 4, 5), Color("#eef8ec"))
	draw_rect(Rect2(174, 38, 1, 1), Color("#34414a"))
	draw_rect(Rect2(177, 38, 1, 1), Color("#34414a"))
	if RunState.hint_uses >= 3:
		for index in range(mini(RunState.hint_uses - 2, 6)):
			var mote_x := 185 + (index * 13) % 25
			var mote_y := 39 + (index * 7) % 12
			draw_rect(Rect2(mote_x, mote_y, 1, 1), glow)

