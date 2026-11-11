extends Node

signal inventory_changed(items: Array[String])
signal clue_recorded(clue_id: String)
signal hint_echo_changed(value: int)
signal setting_changed(setting_name: String, value: Variant)

const SAVE_PATH := "user://forgotten_world_save.json"
const SAVE_VERSION := 3
const INVENTORY_LIMIT := 4
const SAVE_COUNTER_LIMIT := 1000000
const HINT_USE_LIMIT := 100000
const PLAYTIME_LIMIT_SECONDS := 315360000.0
const ITEM_IDS := ["medallion", "moss_button", "stone_chip", "old_bead", "seed_pod", "river_glass", "mirror_shard"]
const PUZZLE_SLOT_KEYS := {
	"orchard_valves": ["west", "north", "east"],
	"quarter_slots": ["west", "north", "east", "south"],
	"archive_lenses": ["west", "center", "east"],
	"gallery_mirrors": ["west", "center", "east"],
	"high_steps_vanes": ["west", "center", "east"],
	"observatory_arms": ["west", "center", "east"],
	"reading_tiles": ["west", "center", "east"]
}
const PUZZLE_ORIENTATION_LIMITS := {"reading_tiles": 2}
const PUZZLE_COUNTER_LIMITS := {"first_gate": 3, "bell_sequence": 5, "quiet_garden_sequence": 3, "causeway_sequence": 7, "waterworks_sequence": 4, "map_route_sequence": 3, "cistern_sequence": 4, "village_gathering_sequence": 3}
const SAVE_PHASES := ["crossing", "ruins", "orchard", "reed_causeway", "waterworks", "cistern_vault", "empty_quarter", "reading_room", "archive", "map_chamber", "gallery", "bell_court", "highland_refuge", "quiet_garden", "high_steps", "observatory"]
const REBINDABLE_ACTIONS := [
	"move_left", "move_right", "move_up", "move_down", "run",
	"examine", "pick_up", "activate", "use_item", "inventory",
	"journal", "hints", "pause", "camera_left", "camera_right",
	"zoom_in", "zoom_out", "camera_snap_toggle"
]

var presentation: int = 0
var inventory: Array[String] = []
var selected_item_id := ""
var journal_entries: Array[String] = []
var puzzle_progress: Dictionary = {}
var story_flags: Dictionary = {}
var hint_echo: int = 0
var total_hint_points: int = 0
var local_hint_points: int = 0
var hint_uses: int = 0
var journey_started: bool = false
var journey_active: bool = false
var checkpoint_valid: bool = false
var checkpoint_phase := "crossing"
var checkpoint_position := Vector2(205, 226)
var seconds_played: float = 0.0
var seconds_since_autosave: float = 0.0
var settings: Dictionary = {
	"ambient_audio": true,
	"reduced_motion": false,
	"large_text": false,
	"snap_camera": false
}
var input_bindings: Dictionary = {}

func _ready() -> void:
	_install_default_input_actions()
	_load_saved_preferences()
	# Keep the current save in memory so changing settings or bindings from the
	# title screen cannot accidentally overwrite journey progress.
	if has_save():
		load_game()
	set_process(true)

func _process(delta: float) -> void:
	if not journey_started or not journey_active:
		return
	seconds_played += delta
	seconds_since_autosave += delta
	if seconds_since_autosave >= 30.0:
		seconds_since_autosave = 0.0
		save_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and journey_started:
		save_game()

func _install_default_input_actions() -> void:
	_add_action("move_left", [KEY_A, KEY_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_add_action("move_right", [KEY_D, KEY_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	_add_action("move_up", [KEY_W, KEY_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_add_action("move_down", [KEY_S, KEY_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	_add_action("run", [KEY_SHIFT], [], [JOY_BUTTON_LEFT_STICK])
	_add_action("examine", [KEY_E], [], [JOY_BUTTON_A])
	_add_action("pick_up", [KEY_F], [], [JOY_BUTTON_Y])
	_add_action("activate", [KEY_SPACE], [], [JOY_BUTTON_X])
	_add_action("use_item", [KEY_U], [], [JOY_BUTTON_RIGHT_SHOULDER])
	_add_action("inventory", [KEY_I], [], [JOY_BUTTON_DPAD_RIGHT])
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

func _load_saved_preferences() -> void:
	var parsed := _read_save_data(false)
	if parsed.is_empty():
		return
	var saved_settings: Variant = parsed.get("settings", {})
	if saved_settings is Dictionary:
		for setting_name in settings:
			if saved_settings.has(setting_name) and typeof(saved_settings[setting_name]) == TYPE_BOOL:
				settings[setting_name] = saved_settings[setting_name]
	var saved_bindings: Variant = parsed.get("input_bindings", {})
	if saved_bindings is Dictionary:
		input_bindings = _sanitize_bindings(saved_bindings)
		_apply_saved_bindings()
	if not settings.get("ambient_audio", true):
		Soundscape.set_ambience_enabled(false)

func _apply_saved_bindings() -> void:
	for action_name in input_bindings:
		if not InputMap.has_action(action_name):
			continue
		var binding: Variant = input_bindings[action_name]
		if not binding is Dictionary:
			continue
		# Read the early single-binding format as well as the current per-device format.
		if binding.has("kind"):
			_apply_one_saved_binding(action_name, str(binding.get("kind", "")), int(binding.get("code", -1)))
		else:
			if binding.has("key"):
				_apply_one_saved_binding(action_name, "key", int(binding.get("key", -1)))
			if binding.has("joy_button"):
				_apply_one_saved_binding(action_name, "joy_button", int(binding.get("joy_button", -1)))

func _apply_one_saved_binding(action_name: String, kind: String, code: int) -> void:
	var event := _event_from_binding({"kind": kind, "code": code})
	if event == null:
		return
	for existing in InputMap.action_get_events(action_name):
		if (existing is InputEventKey and event is InputEventKey) or (existing is InputEventJoypadButton and event is InputEventJoypadButton):
			InputMap.action_erase_event(action_name, existing)
	InputMap.action_add_event(action_name, event)

func _event_from_binding(binding: Dictionary) -> InputEvent:
	match str(binding.get("kind", "")):
		"key":
			var key_event := InputEventKey.new()
			key_event.physical_keycode = int(binding.get("code", 0))
			return key_event if key_event.physical_keycode != 0 else null
		"joy_button":
			var button_event := InputEventJoypadButton.new()
			button_event.button_index = int(binding.get("code", -1))
			return button_event if button_event.button_index >= 0 else null
		_:
			return null

func rebind_action(action_name: String, event: InputEvent) -> bool:
	if not InputMap.has_action(action_name) or not REBINDABLE_ACTIONS.has(action_name):
		return false
	var binding: Dictionary = {}
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.physical_keycode == 0:
			return false
		binding = {"kind": "key", "code": int(key_event.physical_keycode)}
		if _binding_is_in_use(action_name, binding):
			return false
		for existing in InputMap.action_get_events(action_name):
			if existing is InputEventKey:
				InputMap.action_erase_event(action_name, existing)
	elif event is InputEventJoypadButton:
		var button_event := event as InputEventJoypadButton
		binding = {"kind": "joy_button", "code": int(button_event.button_index)}
		if _binding_is_in_use(action_name, binding):
			return false
		for existing in InputMap.action_get_events(action_name):
			if existing is InputEventJoypadButton:
				InputMap.action_erase_event(action_name, existing)
	else:
		return false
	InputMap.action_add_event(action_name, _event_from_binding(binding))
	var stored: Dictionary = input_bindings.get(action_name, {})
	if stored.has("kind"):
		var previous_kind := str(stored.get("kind", ""))
		stored = {previous_kind: int(stored.get("code", -1))}
	stored[str(binding.get("kind", ""))] = int(binding.get("code", -1))
	input_bindings[action_name] = stored
	save_game()
	return true

func _binding_is_in_use(action_name: String, candidate: Dictionary) -> bool:
	for other_action in InputMap.get_actions():
		var other_name := str(other_action)
		if other_name == action_name or other_name.begins_with("ui_"):
			continue
		for event in InputMap.action_get_events(other_name):
			if candidate.get("kind") == "key" and event is InputEventKey and int(candidate.get("code", -1)) == int((event as InputEventKey).physical_keycode):
				return true
			if candidate.get("kind") == "joy_button" and event is InputEventJoypadButton and int(candidate.get("code", -1)) == int((event as InputEventJoypadButton).button_index):
				return true
	return false

func get_binding_text(action_name: String) -> String:
	var key_text := ""
	var pad_text := ""
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and key_text.is_empty():
			key_text = OS.get_keycode_string((event as InputEventKey).physical_keycode)
		elif event is InputEventJoypadButton and pad_text.is_empty():
			pad_text = "Pad %d" % int((event as InputEventJoypadButton).button_index)
	var labels: Array[String] = []
	if not key_text.is_empty():
		labels.append(key_text)
	if not pad_text.is_empty():
		labels.append(pad_text)
	return " / ".join(labels) if not labels.is_empty() else "Unbound"

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
	journey_active = false
	checkpoint_valid = true
	checkpoint_phase = "crossing"
	checkpoint_position = Vector2(205, 226)
	inventory.clear()
	selected_item_id = ""
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
	hint_uses = 0
	seconds_played = 0.0
	seconds_since_autosave = 0.0
	save_game()

func _read_file_as_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}

func _read_save_data(require_journey: bool = true) -> Dictionary:
	for path in [SAVE_PATH, SAVE_PATH + ".bak"]:
		var data := _read_file_as_dictionary(path)
		if data.is_empty():
			continue
		if require_journey and not bool(data.get("journey_started", false)):
			continue
		return data
	return {}

func has_save() -> bool:
	return not _read_save_data(true).is_empty()

func add_item(item_id: String) -> bool:
	if inventory.has(item_id):
		return true
	if inventory.size() >= INVENTORY_LIMIT:
		return false
	inventory.append(item_id)
	if selected_item_id.is_empty():
		selected_item_id = item_id
	inventory_changed.emit(inventory)
	save_game()
	return true

func replace_item(old_item_id: String, new_item_id: String) -> bool:
	if old_item_id == "medallion" or not inventory.has(old_item_id) or inventory.has(new_item_id):
		return false
	var old_index := inventory.find(old_item_id)
	inventory[old_index] = new_item_id
	if selected_item_id == old_item_id:
		selected_item_id = new_item_id
	inventory_changed.emit(inventory)
	save_game()
	return true

func select_item(item_id: String) -> bool:
	if not inventory.has(item_id):
		return false
	selected_item_id = item_id
	save_game()
	return true

func remove_item(item_id: String) -> void:
	if inventory.has(item_id) and item_id != "medallion":
		inventory.erase(item_id)
		if selected_item_id == item_id:
			selected_item_id = inventory[0] if not inventory.is_empty() else ""
		inventory_changed.emit(inventory)
		save_game()

func record_clue(clue_id: String) -> bool:
	if journal_entries.has(clue_id):
		return false
	journal_entries.append(clue_id)
	clue_recorded.emit(clue_id)
	save_game()
	return true

func add_hint(level: int) -> int:
	var base_points := clampi(level, 1, 3)
	# Every second request makes the old stones carry a stronger echo.
	var points := mini(base_points + int(hint_uses / 2), SAVE_COUNTER_LIMIT)
	hint_uses = mini(hint_uses + 1, HINT_USE_LIMIT)
	hint_echo = mini(hint_echo + points, SAVE_COUNTER_LIMIT)
	total_hint_points = mini(total_hint_points + points, SAVE_COUNTER_LIMIT)
	local_hint_points = mini(local_hint_points + points, SAVE_COUNTER_LIMIT)
	hint_echo_changed.emit(hint_echo)
	save_game()
	return points

func set_journey_active(active: bool) -> void:
	journey_active = active

func update_checkpoint(phase_name: String, position: Vector2) -> void:
	if not SAVE_PHASES.has(phase_name):
		return
	checkpoint_phase = phase_name
	checkpoint_position = Vector2(
		clampf(position.x, 22.0, 618.0),
		clampf(position.y, 40.0, 340.0)
	)
	checkpoint_valid = true

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
	var checkpoint_data: Dictionary = {}
	if checkpoint_valid and SAVE_PHASES.has(checkpoint_phase):
		checkpoint_data = {
			"phase": checkpoint_phase,
			"position": [checkpoint_position.x, checkpoint_position.y]
		}
	var data := {
		"version": SAVE_VERSION,
		"presentation": presentation,
		"inventory": inventory,
		"selected_item_id": selected_item_id,
		"journal_entries": journal_entries,
		"puzzle_progress": puzzle_progress,
		"story_flags": story_flags,
		"hint_echo": hint_echo,
		"total_hint_points": total_hint_points,
		"local_hint_points": local_hint_points,
		"hint_uses": hint_uses,
		"journey_started": journey_started,
		"seconds_played": seconds_played,
		"checkpoint": checkpoint_data,
		"settings": settings,
		"input_bindings": input_bindings
	}
	var temporary_path := SAVE_PATH + ".tmp"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open the temporary save file.")
		return
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	var absolute_save := ProjectSettings.globalize_path(SAVE_PATH)
	var absolute_backup := ProjectSettings.globalize_path(SAVE_PATH + ".bak")
	var absolute_temporary := ProjectSettings.globalize_path(temporary_path)
	if FileAccess.file_exists(SAVE_PATH):
		var existing_data := _read_file_as_dictionary(SAVE_PATH)
		if not existing_data.is_empty():
			if FileAccess.file_exists(SAVE_PATH + ".bak"):
				DirAccess.remove_absolute(absolute_backup)
			var backup_error := DirAccess.rename_absolute(absolute_save, absolute_backup)
			if backup_error != OK:
				DirAccess.remove_absolute(absolute_temporary)
				push_warning("Could not rotate the previous save to its backup.")
				return
		else:
			DirAccess.remove_absolute(absolute_save)
	var save_error := DirAccess.rename_absolute(absolute_temporary, absolute_save)
	if save_error != OK:
		if not FileAccess.file_exists(SAVE_PATH) and FileAccess.file_exists(SAVE_PATH + ".bak"):
			DirAccess.rename_absolute(absolute_backup, absolute_save)
		push_warning("Could not replace the local save file.")

func load_game() -> bool:
	var parsed := _read_save_data(true)
	if parsed.is_empty():
		return false
	var version := int(parsed.get("version", 0))
	if version < 1 or version > SAVE_VERSION:
		return false
	presentation = clampi(int(parsed.get("presentation", 0)), 0, 1)
	inventory.clear()
	var loaded_inventory: Variant = parsed.get("inventory", [])
	if loaded_inventory is Array:
		for item_id in loaded_inventory:
			if item_id is String and ITEM_IDS.has(item_id) and inventory.size() < INVENTORY_LIMIT and not inventory.has(item_id):
				inventory.append(item_id)
	selected_item_id = str(parsed.get("selected_item_id", inventory[0] if not inventory.is_empty() else ""))
	if not inventory.has(selected_item_id):
		selected_item_id = inventory[0] if not inventory.is_empty() else ""
	journal_entries.clear()
	var loaded_clues: Variant = parsed.get("journal_entries", [])
	if loaded_clues is Array:
		for clue_id in loaded_clues:
			if clue_id is String and clue_id.length() <= 64 and clue_id.is_valid_identifier() and journal_entries.size() < 128 and not journal_entries.has(clue_id):
				journal_entries.append(clue_id)
	var loaded_puzzles: Variant = parsed.get("puzzle_progress", {})
	puzzle_progress = _sanitize_puzzle_progress(loaded_puzzles)
	var loaded_flags: Variant = parsed.get("story_flags", {})
	story_flags = _sanitize_story_flags(loaded_flags)
	hint_echo = clampi(int(parsed.get("hint_echo", 0)), 0, SAVE_COUNTER_LIMIT)
	total_hint_points = clampi(int(parsed.get("total_hint_points", hint_echo)), 0, SAVE_COUNTER_LIMIT)
	local_hint_points = clampi(int(parsed.get("local_hint_points", 0)), 0, SAVE_COUNTER_LIMIT)
	hint_uses = clampi(int(parsed.get("hint_uses", 0)), 0, HINT_USE_LIMIT)
	journey_started = bool(parsed.get("journey_started", false))
	journey_active = false
	seconds_played = clampf(float(parsed.get("seconds_played", 0.0)), 0.0, PLAYTIME_LIMIT_SECONDS)
	checkpoint_valid = false
	var loaded_checkpoint: Variant = parsed.get("checkpoint", {})
	if loaded_checkpoint is Dictionary:
		var loaded_phase := str(loaded_checkpoint.get("phase", ""))
		var loaded_position: Variant = loaded_checkpoint.get("position", [])
		if SAVE_PHASES.has(loaded_phase) and loaded_position is Array and loaded_position.size() >= 2:
			var x_value: Variant = loaded_position[0]
			var y_value: Variant = loaded_position[1]
			if (x_value is int or x_value is float) and (y_value is int or y_value is float):
				var candidate := Vector2(float(x_value), float(y_value))
				if candidate.x >= 22.0 and candidate.x <= 618.0 and candidate.y >= 40.0 and candidate.y <= 340.0:
					checkpoint_phase = loaded_phase
					checkpoint_position = candidate
					checkpoint_valid = true
	var loaded_settings: Variant = parsed.get("settings", {})
	if loaded_settings is Dictionary:
		for setting_name in settings:
			if loaded_settings.has(setting_name) and typeof(loaded_settings[setting_name]) == TYPE_BOOL:
				settings[setting_name] = loaded_settings[setting_name]
	var loaded_bindings: Variant = parsed.get("input_bindings", {})
	if loaded_bindings is Dictionary:
		input_bindings = _sanitize_bindings(loaded_bindings)
		_apply_saved_bindings()
	# Older saves predate the explicit request count. Preserve the existing echo
	# and estimate enough uses that later hints do not reset its consequence.
	if version == 1:
		hint_uses = maxi(hint_uses, ceili(float(total_hint_points) / 2.0))
	seconds_since_autosave = 0.0
	inventory_changed.emit(inventory)
	hint_echo_changed.emit(hint_echo)
	if not settings.get("ambient_audio", true):
		Soundscape.set_ambience_enabled(false)
	return true

func _sanitize_story_flags(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not value is Dictionary:
		return result
	for flag_name in value:
		if flag_name is String and flag_name.length() <= 48 and flag_name.is_valid_identifier() and typeof(value[flag_name]) == TYPE_BOOL:
			result[flag_name] = value[flag_name]
	return result

func _sanitize_puzzle_progress(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not value is Dictionary:
		return result
	for puzzle_name in PUZZLE_SLOT_KEYS:
		var saved_slots: Variant = value.get(puzzle_name, {})
		if not saved_slots is Dictionary:
			continue
		var slots: Dictionary = {}
		for slot_name in PUZZLE_SLOT_KEYS[puzzle_name]:
			var orientation: Variant = saved_slots.get(slot_name, 0)
			if orientation is int or orientation is float:
				slots[slot_name] = clampi(int(orientation), 0, int(PUZZLE_ORIENTATION_LIMITS.get(puzzle_name, 3)))
		result[puzzle_name] = slots
	for puzzle_name in PUZZLE_COUNTER_LIMITS:
		var counter: Variant = value.get(puzzle_name, 0)
		if counter is int or counter is float:
			result[puzzle_name] = clampi(int(counter), 0, int(PUZZLE_COUNTER_LIMITS[puzzle_name]))
	return result

func _sanitize_bindings(value: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for action_name in REBINDABLE_ACTIONS:
		var binding: Variant = value.get(action_name, {})
		if not binding is Dictionary:
			continue
		var sanitized: Dictionary = {}
		if binding.has("kind") and binding.get("code", null) is int:
			var legacy_kind := str(binding.get("kind", ""))
			var legacy_code := int(binding["code"])
			if legacy_kind == "key" and legacy_code > 0 and legacy_code <= KEY_CODE_MASK:
				sanitized["key"] = legacy_code
			elif legacy_kind == "joy_button" and legacy_code >= 0 and legacy_code < JOY_BUTTON_MAX:
				sanitized["joy_button"] = legacy_code
		for kind in ["key", "joy_button"]:
			var code: Variant = binding.get(kind, null)
			if code is int or code is float:
				var numeric_code := int(code)
				if kind == "key" and numeric_code > 0 and numeric_code <= KEY_CODE_MASK:
					sanitized[kind] = numeric_code
				elif kind == "joy_button" and numeric_code >= 0 and numeric_code < JOY_BUTTON_MAX:
					sanitized[kind] = numeric_code
		if not sanitized.is_empty():
			result[action_name] = sanitized
	return result
