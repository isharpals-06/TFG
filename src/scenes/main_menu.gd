extends Control

var _view_root: Control
var _has_focus_target := false
var waiting_for_action := ""

func _input(event: InputEvent) -> void:
	if waiting_for_action.is_empty():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			waiting_for_action = ""
			_show_controls()
		else:
			_finish_rebind(event)
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed:
		_finish_rebind(event)
		get_viewport().set_input_as_handled()

func _finish_rebind(event: InputEvent) -> void:
	var action_name := waiting_for_action
	waiting_for_action = ""
	if not RunState.rebind_action(action_name, event):
		_set_rebind_status("That control is already assigned or cannot be used here.")
		return
	_show_controls()

func _ready() -> void:
	Soundscape.leave_journey()
	var backdrop := TextureRect.new()
	backdrop.texture = load("res://design/assets/title_background.png")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(backdrop)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025, 0.045, 0.06, 0.36)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_show_main_menu()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(320, 180)), Color("#101b22"))
	draw_rect(Rect2(0, 128, 320, 52), Color("#17262a"))
	draw_rect(Rect2(0, 140, 320, 40), Color("#1e302e"))
	_draw_distant_ruin(40, 128, Color("#26373a"))
	_draw_distant_ruin(225, 132, Color("#233437"))
	for index in range(18):
		var x := (index * 47 + 13) % 320
		var y := (index * 23 + 8) % 105
		var star := Color("#899fa0")
		star.a = 0.45
		draw_rect(Rect2(x, y, 1, 1), star)
	var horizon_glint := Color("#85bbbf")
	horizon_glint.a = 0.4
	draw_rect(Rect2(151, 111, 18, 1), horizon_glint)

func _draw_distant_ruin(x: int, baseline: int, color: Color) -> void:
	draw_rect(Rect2(x, baseline - 32, 8, 32), color)
	draw_rect(Rect2(x + 8, baseline - 39, 5, 39), color)
	draw_rect(Rect2(x + 13, baseline - 30, 9, 30), color)
	draw_rect(Rect2(x - 3, baseline - 33, 29, 4), color)
	draw_rect(Rect2(x + 2, baseline - 37, 3, 4), color.lightened(0.08))

func _clear_view() -> void:
	if is_instance_valid(_view_root):
		remove_child(_view_root)
		_view_root.queue_free()
	_view_root = Control.new()
	_view_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_view_root)
	_has_focus_target = false

func _show_main_menu() -> void:
	_clear_view()
	var title := _label("THE FORGOTTEN WORLD", 13, Color("#e3e0d1"))
	title.position = Vector2(20, 25)
	title.size = Vector2(280, 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_view_root.add_child(title)
	var subtitle := _label("A quiet journey through a vanished place", 7, Color("#aab7b1"))
	subtitle.position = Vector2(28, 46)
	subtitle.size = Vector2(264, 14)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_view_root.add_child(subtitle)
	var button_y := 64.0
	_add_button("Begin journey", Vector2(98, button_y), _show_identity_choice)
	button_y += 18.0
	if RunState.has_save():
		_add_button("Continue", Vector2(98, button_y), _continue_journey)
		button_y += 18.0
	_add_button("Controls", Vector2(98, button_y), _show_controls)
	button_y += 18.0
	_add_button("Settings", Vector2(98, button_y), _show_settings)
	button_y += 18.0
	_add_button("About & credits", Vector2(98, button_y), _show_credits)
	button_y += 18.0
	_add_button("Quit", Vector2(98, button_y), _quit_game)

func _show_credits() -> void:
	_clear_view()
	_add_centered_title("About & credits", 22)
	var version: Dictionary = Engine.get_version_info()
	var version_text := "%s.%s.%s" % [version.get("major", 0), version.get("minor", 0), version.get("patch", 0)]
	var credits := _label(
		"The Forgotten World\n\nArt, characters, writing, and code: original project work. Full asset provenance is in design/assets/ASSET_CREDITS.md.\n\nAudio: original procedural synthesis in the project.\n\nEngine: Godot %s (MIT; godotengine.org/license).\n\nGame license: not selected. Rights remain with the creator until release terms are chosen." % version_text,
		7,
		Color("#d2d7cb")
	)
	credits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credits.add_theme_constant_override("line_spacing", 1)
	credits.custom_minimum_size.x = 268.0
	credits.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(22, 43)
	scroll.size = Vector2(276, 96)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	_view_root.add_child(scroll)
	scroll.add_child(credits)
	_add_button("Back", Vector2(98, 151), _show_main_menu)

func _show_identity_choice() -> void:
	_clear_view()
	_add_centered_title("Choose your traveler", 26)
	var note := _label("A small appearance choice; the story stays the same.", 7, Color("#b2c1bd"))
	note.position = Vector2(24, 52)
	note.size = Vector2(272, 18)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_view_root.add_child(note)
	_add_button("Moss mantle", Vector2(72, 82), _select_identity.bind(0))
	_add_button("Mist mantle", Vector2(72, 105), _select_identity.bind(1))
	_add_button("Back", Vector2(72, 132), _show_main_menu)

func _select_identity(choice: int) -> void:
	if RunState.has_save():
		_show_new_journey_confirmation(choice)
	else:
		_begin_journey(choice)

func _show_new_journey_confirmation(choice: int) -> void:
	_clear_view()
	_add_centered_title("Begin again?", 30)
	var warning := _label("This will replace the saved journey on this device.", 7, Color("#d5bd97"))
	warning.position = Vector2(27, 54)
	warning.size = Vector2(266, 24)
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_view_root.add_child(warning)
	_add_button("Replace save and begin", Vector2(84, 91), _begin_journey.bind(choice))
	_add_button("Keep saved journey", Vector2(84, 116), _show_identity_choice)

func _show_controls() -> void:
	_clear_view()
	_add_centered_title("Controls", 26)
	var movement := _label("Left stick works by default. Select a row to remap keys or buttons.", 6, Color("#bdc9c0"))
	movement.position = Vector2(19, 41)
	movement.size = Vector2(282, 12)
	_view_root.add_child(movement)
	var remappable := [
		["move_left", "Move left"], ["move_right", "Move right"],
		["move_up", "Move up"], ["move_down", "Move down"], ["run", "Run"],
		["examine", "Examine"], ["pick_up", "Take"], ["activate", "Activate"],
		["use_item", "Use keepsake"], ["inventory", "Keepsakes"],
		["journal", "Journal"], ["hints", "Beth's hints"], ["pause", "Pause"],
		["camera_left", "Turn camera left"], ["camera_right", "Turn camera right"],
		["zoom_in", "Zoom in"], ["zoom_out", "Zoom out"],
		["camera_snap_toggle", "Snap camera turns"]
	]
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(18, 55)
	scroll.size = Vector2(284, 95)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	_view_root.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 1)
	scroll.add_child(rows)
	for index in range(remappable.size()):
		var action_name: String = remappable[index][0]
		var display_name: String = remappable[index][1]
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(260, 13 + (2 if RunState.settings.get("large_text", false) else 0))
		row.add_theme_constant_override("separation", 3)
		rows.add_child(row)
		var label := _label("%s   %s" % [display_name, RunState.get_binding_text(action_name)], 7, Color("#d4d7cc"))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(label)
		var change := Button.new()
		change.text = "Change"
		change.custom_minimum_size = Vector2(68, 13 + (2 if RunState.settings.get("large_text", false) else 0))
		change.focus_mode = Control.FOCUS_ALL
		change.add_theme_font_size_override("font_size", 7 if not RunState.settings.get("large_text", false) else 9)
		change.pressed.connect(_begin_rebind.bind(action_name))
		row.add_child(change)
	_add_button("Back", Vector2(116, 153), _show_main_menu)

func _begin_rebind(action_name: String) -> void:
	waiting_for_action = action_name
	_set_rebind_status("Press a key or controller button. Esc cancels.")

func _set_rebind_status(message: String) -> void:
	var old_message := _view_root.get_node_or_null("RebindStatus")
	if is_instance_valid(old_message):
		old_message.queue_free()
	var label := _label(message, 6, Color("#d5c59a"))
	label.name = "RebindStatus"
	label.position = Vector2(18, 41)
	label.size = Vector2(284, 12 + (2 if RunState.settings.get("large_text", false) else 0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_view_root.add_child(label)

func _show_settings() -> void:
	_clear_view()
	_add_centered_title("Settings", 18)
	_add_button(_setting_label("ambient_audio", "Ambient sound"), Vector2(70, 49), _toggle_setting.bind("ambient_audio"))
	_add_button(_setting_label("reduced_motion", "Reduced motion"), Vector2(70, 70), _toggle_setting.bind("reduced_motion"))
	_add_button(_setting_label("large_text", "Larger text"), Vector2(70, 91), _toggle_setting.bind("large_text"))
	_add_button(_setting_label("snap_camera", "Snap camera turns"), Vector2(70, 112), _toggle_setting.bind("snap_camera"))
	var note := _label("Changes are saved on this device.", 6, Color("#aab7b1"))
	note.position = Vector2(36, 135)
	note.size = Vector2(248, 11)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_view_root.add_child(note)
	_add_button("Back", Vector2(116, 151), _show_main_menu)

func _setting_label(setting_name: String, display_name: String) -> String:
	var enabled := bool(RunState.settings.get(setting_name, false))
	return "%s: %s" % [display_name, "On" if enabled else "Off"]

func _toggle_setting(setting_name: String) -> void:
	var value := not bool(RunState.settings.get(setting_name, false))
	RunState.set_setting(setting_name, value)
	if setting_name == "ambient_audio":
		Soundscape.set_ambience_enabled(value)
	_show_settings()

func _add_centered_title(text: String, y: float) -> void:
	var title := _label(text, 11, Color("#e3e0d1"))
	title.position = Vector2(20, y)
	title.size = Vector2(280, 18)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_view_root.add_child(title)

func _add_button(text: String, pos: Vector2, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	var large_text := bool(RunState.settings.get("large_text", false))
	var button_width := maxf(124.0, minf(230.0, float(text.length()) * (10.0 if large_text else 8.0) * 0.62 + 14.0))
	button.position.x -= (button_width - 124.0) * 0.5
	button.size = Vector2(button_width, 18.0 + (2.0 if large_text else 0.0))
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 10 if large_text else 8)
	button.add_theme_color_override("font_color", Color("#d9e0d9"))
	button.add_theme_color_override("font_hover_color", Color("#f1edda"))
	button.add_theme_color_override("font_pressed_color", Color("#b8dbd8"))
	button.add_theme_stylebox_override("normal", _button_style(Color("#26373b")))
	button.add_theme_stylebox_override("hover", _button_style(Color("#3b5557")))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#49666a")))
	button.pressed.connect(callback)
	_view_root.add_child(button)
	if not _has_focus_target:
		_has_focus_target = true
		button.grab_focus()

func _button_style(fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color("#667873")
	style.set_border_width_all(1)
	style.set_corner_radius_all(0)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	return style

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size + (2 if RunState.settings.get("large_text", false) else 0))
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("#0b1115"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label

func _begin_journey(choice: int) -> void:
	RunState.start_new_journey(choice)
	get_tree().change_scene_to_file("res://src/scenes/prologue.tscn")

func _continue_journey() -> void:
	if RunState.load_game():
		var destination := "res://src/scenes/ending.tscn" if RunState.story_flags.get("ending_revealed", false) else "res://src/scenes/prologue.tscn"
		get_tree().change_scene_to_file(destination)

func _quit_game() -> void:
	get_tree().quit()
