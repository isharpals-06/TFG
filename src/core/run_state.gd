extends Node

signal inventory_changed(items: Array[String])
signal clue_recorded(clue_id: String)
signal hint_echo_changed(value: int)
signal setting_changed(setting_name: String, value: Variant)

const SAVE_PATH := "user://forgotten_world_save.json"
const SAVE_VERSION := 1
const INVENTORY_LIMIT := 4

var presentation: int = 0
var inventory: Array[String] = []
var journal_entries: Array[String] = []
var puzzle_progress: Dictionary = {}
var story_flags: Dictionary = {}
var hint_echo: int = 0
var total_hint_points: int = 0
var local_hint_points: int = 0
var journey_started: bool = false
var settings: Dictionary = {
	"ambient_audio": true,
	"reduced_motion": false,
	"large_text": false,
	"snap_camera": false
}

func _ready() -> void:
	_install_default_input_actions()

func _install_default_input_actions() -> void:
	_add_action("move_left", [KEY_A, KEY_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_add_action("move_right", [KEY_D, KEY_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	_add_action("move_up", [KEY_W, KEY_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_add_action("move_down", [KEY_S, KEY_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	_add_action("run", [KEY_SHIFT], [], [JOY_BUTTON_LEFT_STICK])
	_add_action("examine", [KEY_E], [], [JOY_BUTTON_A])
	_add_action("pick_up", [KEY_F], [], [JOY_BUTTON_Y])
	_add_action("activate", [KEY_SPACE], [], [JOY_BUTTON_X])
	_add_action("journal", [KEY_J], [], [JOY_BUTTON_BACK])
	_add_action("hints", [KEY_H], [], [JOY_BUTTON_B])
	_add_action("hint_1", [KEY_1])
	_add_action("hint_2", [KEY_2])
	_add_action("hint_3", [KEY_3])
	_add_action("pause", [KEY_ESCAPE], [], [JOY_BUTTON_START])
	_add_action("camera_left", [KEY_Z])
	_add_action("camera_right", [KEY_C])
	_add_action("camera_snap_toggle", [KEY_V])
	_add_action("zoom_in", [KEY_EQUAL, KEY_KP_ADD])
	_add_action("zoom_out", [KEY_MINUS, KEY_KP_SUBTRACT])

func _add_action(action_name: String, key_codes: Array, axes: Array = [], buttons: Array = []) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.2)
	for key_code in key_codes:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = key_code
		InputMap.action_add_event(action_name, key_event)
	for axis_setting in axes:
		var motion := InputEventJoypadMotion.new()
		motion.axis = axis_setting[0]
		motion.axis_value = axis_setting[1]
		InputMap.action_add_event(action_name, motion)
	for button_index in buttons:
		var button := InputEventJoypadButton.new()
		button.button_index = button_index
		InputMap.action_add_event(action_name, button)

func start_new_journey(selected_presentation: int = 0) -> void:
	presentation = selected_presentation
	journey_started = true
	inventory.clear()
	journal_entries.clear()
	puzzle_progress.clear()
	story_flags = {
		"medallion_found": false,
		"crossed_into_world": false,
		"beth_awake": false,
		"inscription_seen": false,
		"first_gate_open": false
	}
	hint_echo = 0
	total_hint_points = 0
	local_hint_points = 0
	save_game()

func has_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed is Dictionary and bool(parsed.get("journey_started", false))

func add_item(item_id: String) -> bool:
	if inventory.has(item_id):
		return true
	if inventory.size() >= INVENTORY_LIMIT:
		return false
	inventory.append(item_id)
	inventory_changed.emit(inventory)
	save_game()
	return true

func remove_item(item_id: String) -> void:
	if inventory.has(item_id):
		inventory.erase(item_id)
		inventory_changed.emit(inventory)
		save_game()

func record_clue(clue_id: String) -> bool:
	if journal_entries.has(clue_id):
		return false
	journal_entries.append(clue_id)
	clue_recorded.emit(clue_id)
	save_game()
	return true

func add_hint(level: int) -> void:
	var points := clampi(level, 1, 3)
	hint_echo += points
	total_hint_points += points
	local_hint_points += points
	hint_echo_changed.emit(hint_echo)
	save_game()

func reset_local_hint_echo() -> void:
	local_hint_points = 0
	save_game()

func set_story_flag(flag_name: String, value: Variant = true) -> void:
	story_flags[flag_name] = value
	save_game()

func set_setting(setting_name: String, value: Variant) -> void:
	settings[setting_name] = value
	setting_changed.emit(setting_name, value)
	save_game()

func save_game() -> void:
	var data := {
		"version": SAVE_VERSION,
		"presentation": presentation,
		"inventory": inventory,
		"journal_entries": journal_entries,
		"puzzle_progress": puzzle_progress,
		"story_flags": story_flags,
		"hint_echo": hint_echo,
		"total_hint_points": total_hint_points,
		"local_hint_points": local_hint_points,
		"journey_started": journey_started,
		"settings": settings
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open the local save file.")
		return
	file.store_string(JSON.stringify(data))
	file.close()

func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or int(parsed.get("version", 0)) != SAVE_VERSION:
		return false
	presentation = int(parsed.get("presentation", 0))
	inventory.assign(parsed.get("inventory", []))
	journal_entries.assign(parsed.get("journal_entries", []))
	puzzle_progress = parsed.get("puzzle_progress", {})
	story_flags = parsed.get("story_flags", {})
	hint_echo = int(parsed.get("hint_echo", 0))
	total_hint_points = int(parsed.get("total_hint_points", 0))
	local_hint_points = int(parsed.get("local_hint_points", 0))
	journey_started = bool(parsed.get("journey_started", false))
	settings = parsed.get("settings", settings)
	inventory_changed.emit(inventory)
	hint_echo_changed.emit(hint_echo)
	return true
