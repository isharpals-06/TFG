extends Node2D

const TRAVELER_SCENE := preload("res://src/scenes/traveler.tscn")
const BETH_SCENE := preload("res://src/scenes/beth.tscn")
const JOURNAL_CATALOG := preload("res://src/core/journal_catalog.gd")
const HINT_CATALOG := preload("res://src/core/hint_catalog.gd")
const CROSSING_BACKGROUND: Texture2D = preload("res://design/assets/crossing_clearing_pixel.png")
const RUINS_BACKGROUND: Texture2D = preload("res://design/assets/first_ruins.png")
const ORCHARD_BACKGROUND: Texture2D = preload("res://design/assets/quiet_orchard_dry.png")
const WATERWORKS_BACKGROUND: Texture2D = preload("res://design/assets/old_waterworks.png")
const CISTERN_BACKGROUND: Texture2D = preload("res://design/assets/lower_cistern.png")
const REED_CAUSEWAY_BACKGROUND: Texture2D = preload("res://design/assets/reed_causeway.png")
const EMPTY_QUARTER_BACKGROUND: Texture2D = preload("res://design/assets/empty_quarter.png")
const READING_ROOM_BACKGROUND: Texture2D = preload("res://design/assets/west_house_reading_room.png")
const ARCHIVE_BACKGROUND: Texture2D = preload("res://design/assets/under_archive.png")
const MAP_CHAMBER_BACKGROUND: Texture2D = preload("res://design/assets/archive_map_chamber.png")
const GALLERY_BACKGROUND: Texture2D = preload("res://design/assets/gallery_reflection_hall.png")
const BELL_COURT_BACKGROUND: Texture2D = preload("res://design/assets/bell_garden.png")
const HIGHLAND_REFUGE_BACKGROUND: Texture2D = preload("res://design/assets/highland_refuge.png")
const QUIET_GARDEN_BACKGROUND: Texture2D = preload("res://design/assets/quiet_garden.png")
const HIGHLAND_STEPS_BACKGROUND: Texture2D = preload("res://design/assets/highland_steps.png")
const OBSERVATORY_BACKGROUND: Texture2D = preload("res://design/assets/roofless_observatory.png")
const WORLD_SIZE := Vector2(640, 360)
const PUZZLE_ORDER := ["moon", "water", "seed"]
const ARCHIVE_SOLUTION := {"west": 1, "center": 2, "east": 3}
const ARCHIVE_FOURTH_PATH_SOLUTION := {"west": 0, "center": 1, "east": 2}
const ORCHARD_SOLUTION := {"west": 1, "north": 2, "east": 3}
const GALLERY_SOLUTION := {"west": 0, "center": 2, "east": 3}
const HIGH_STEPS_SOLUTION := {"west": 3, "center": 0, "east": 1}
const OBSERVATORY_SOLUTION := {"west": 3, "center": 0, "east": 1}
const BELL_SEQUENCE := ["moon", "water", "seed", "moon"]
const QUIET_GARDEN_SEQUENCE := ["water", "seed", "moon"]
const CAUSEWAY_STEP_PATTERN := [0, 1, 2, 3, 2, 1, 0]
const CAUSEWAY_STONE_POSITIONS := [Vector2(320, 258), Vector2(320, 218), Vector2(320, 178), Vector2(320, 140)]
const WATERWORKS_WHEEL_SEQUENCE := ["west", "center", "east", "center"]
const CISTERN_VALVE_SEQUENCE := ["east", "west", "center", "west"]
const CISTERN_VALVE_POSITIONS := {"west": Vector2(188, 168), "center": Vector2(320, 168), "east": Vector2(452, 168)}
const CAUSEWAY_STEP_MARKS := ["moon", "water", "seed", "water"]
const QUARTER_OBJECTS := ["book", "bowl", "seed", "lamp"]
const QUARTER_START := {"west": 2, "north": 0, "east": 3, "south": 1}
const QUARTER_SOLUTION := {"west": 0, "north": 1, "east": 2, "south": 3}
const READING_START := {"west": 2, "center": 2, "east": 0}
const READING_SOLUTION := {"west": 0, "center": 1, "east": 2}
const MAP_ROUTE_SEQUENCE := ["spring", "bridge", "village"]
const MAP_ROUTE_POSITIONS := {"spring": Vector2(240, 144), "bridge": Vector2(320, 165), "village": Vector2(402, 144)}
const VILLAGE_GATHERING_SEQUENCE := ["bowl", "lamp", "bell"]

var traveler: Traveler
var beth: Beth
var camera: Camera2D
var phase := "crossing"
var status_text := "A medallion rests beside the buried arch."
var hud: CanvasLayer
var objective_label: Label
var status_label: Label
var prompt_label: Label
var inventory_label: Label
var target_icon: ColorRect
var transition_cover: ColorRect
var journal_panel: PanelContainer
var hint_panel: PanelContainer
var pause_panel: PanelContainer
var inventory_panel: PanelContainer
var inventory_description_label: Label
var pending_pickup_id := ""
var inscription_panel: PanelContainer
var inscription_label: Label
const FINAL_INSCRIPTION := "YOUR HAND HAS BEEN HERE BEFORE."
var camera_target_rotation := 0.0
var camera_snap := false
var camera_zoom := 1.0
var transitioning := false
var _cistern_water_time := 0.0

func _ready() -> void:
	camera_snap = bool(RunState.settings.get("snap_camera", false))
	if RunState.story_flags.get("in_reading_room", false):
		phase = "reading_room"
	elif RunState.story_flags.get("in_cistern_vault", false):
		phase = "cistern_vault"
	elif RunState.story_flags.get("in_map_chamber", false):
		phase = "map_chamber"
	elif RunState.story_flags.get("in_quiet_garden", false):
		phase = "quiet_garden"
	elif RunState.story_flags.get("reached_observatory", false):
		phase = "observatory"
	elif RunState.story_flags.get("in_highland_refuge", false):
		phase = "highland_refuge"
	elif RunState.story_flags.get("in_causeway", false):
		phase = "reed_causeway"
	elif RunState.story_flags.get("reached_high_steps", false):
		phase = "high_steps"
	elif RunState.story_flags.get("reached_bell_court", false):
		phase = "bell_court"
	elif RunState.story_flags.get("reached_gallery", false):
		phase = "gallery"
	elif RunState.story_flags.get("reached_archive", false):
		phase = "archive"
	elif RunState.story_flags.get("reached_quarter", false):
		phase = "empty_quarter"
	elif RunState.story_flags.get("reached_waterworks", false):
		phase = "waterworks"
	elif RunState.story_flags.get("reached_orchard", false):
		phase = "orchard"
	elif RunState.story_flags.get("crossed_into_world", false):
		phase = "ruins"
	else:
		phase = "crossing"
	if RunState.checkpoint_valid and _checkpoint_matches_progress(RunState.checkpoint_phase):
		phase = RunState.checkpoint_phase
	status_text = _initial_status_for_phase()
	RunState.set_journey_active(true)
	Soundscape.set_area(phase)
	_create_traveler()
	_create_camera()
	_create_beth()
	_create_hud()
	RunState.inventory_changed.connect(_update_hud)
	RunState.hint_echo_changed.connect(_on_hint_echo_changed)
	_update_hud()
	_update_objective()
	queue_redraw()

func _process(delta: float) -> void:
	if phase == "cistern_vault" and not bool(RunState.settings.get("reduced_motion", false)):
		_cistern_water_time += delta
		queue_redraw()
	if is_instance_valid(traveler):
		RunState.update_checkpoint(phase, traveler.global_position)
		_update_traveler_occlusion()
	if is_instance_valid(camera):
		camera.global_position = traveler.global_position
		if camera_snap:
			camera.rotation = camera_target_rotation
		else:
			var turn_speed := 18.0 if RunState.settings.get("reduced_motion", false) else 7.0
			camera.rotation = lerp_angle(camera.rotation, camera_target_rotation, 1.0 - exp(-delta * turn_speed))
		camera.zoom = camera.zoom.lerp(Vector2.ONE * camera_zoom, 1.0 - exp(-delta * 5.0))
	_update_prompt()

func _unhandled_input(_event: InputEvent) -> void:
	if transitioning:
		return
	if hint_panel != null:
		if Input.is_action_just_pressed("hint_1"):
			_give_hint(1)
		elif Input.is_action_just_pressed("hint_2"):
			_give_hint(2)
		elif Input.is_action_just_pressed("hint_3"):
			_give_hint(3)
		elif Input.is_action_just_pressed("hints") or Input.is_action_just_pressed("pause"):
			_close_hint_panel()
		return
	if pause_panel != null:
		if Input.is_action_just_pressed("pause"):
			_close_pause_menu()
		return
	if inventory_panel != null:
		if Input.is_action_just_pressed("inventory") or Input.is_action_just_pressed("pause"):
			_close_inventory()
		return
	if journal_panel != null:
		if Input.is_action_just_pressed("journal") or Input.is_action_just_pressed("pause"):
			_close_journal()
		return
	if Input.is_action_just_pressed("pause"):
		_open_pause_menu()
	elif Input.is_action_just_pressed("journal"):
		_open_journal()
	elif Input.is_action_just_pressed("hints"):
		_open_hint_panel()
	elif Input.is_action_just_pressed("inventory"):
		_open_inventory()
	elif Input.is_action_just_pressed("use_item"):
		_use_selected_item()
	elif Input.is_action_just_pressed("examine"):
		_examine_target()
	elif Input.is_action_just_pressed("pick_up"):
		_pick_up_target()
	elif Input.is_action_just_pressed("activate"):
		_activate_target()
	if Input.is_action_just_pressed("camera_left"):
		camera_target_rotation -= PI / 2.0
	if Input.is_action_just_pressed("camera_right"):
		camera_target_rotation += PI / 2.0
	if Input.is_action_just_pressed("camera_snap_toggle"):
		camera_snap = not camera_snap
		RunState.set_setting("snap_camera", camera_snap)
	if Input.is_action_just_pressed("zoom_in"):
		camera_zoom = minf(camera_zoom + 0.05, 1.1)
	if Input.is_action_just_pressed("zoom_out"):
		camera_zoom = maxf(camera_zoom - 0.05, 0.9)

func _create_traveler() -> void:
	traveler = TRAVELER_SCENE.instantiate() as Traveler
	if RunState.checkpoint_valid and RunState.checkpoint_phase == phase:
		traveler.position = RunState.checkpoint_position
	else:
		match phase:
			"crossing":
				traveler.position = Vector2(205, 226)
			"ruins":
				traveler.position = Vector2(285, 248)
			"reed_causeway":
				traveler.position = Vector2(320, 310)
			"waterworks":
				traveler.position = Vector2(94, 280)
			"cistern_vault":
				traveler.position = Vector2(320, 284)
			"empty_quarter":
				traveler.position = Vector2(320, 286)
			"reading_room":
				traveler.position = Vector2(320, 284)
			"map_chamber":
				traveler.position = Vector2(320, 282)
			"highland_refuge":
				traveler.position = Vector2(320, 284)
			_:
				traveler.position = Vector2(320, 248)
	traveler.movement_bounds = Rect2(22, 40, 596, 300)
	traveler.z_index = 10
	add_child(traveler)
	RunState.update_checkpoint(phase, traveler.global_position)

func _checkpoint_matches_progress(checkpoint_name: String) -> bool:
	match checkpoint_name:
		"crossing": return not RunState.story_flags.get("crossed_into_world", false)
		"ruins": return RunState.story_flags.get("crossed_into_world", false) and not RunState.story_flags.get("reached_orchard", false)
		"orchard": return RunState.story_flags.get("reached_orchard", false) and not RunState.story_flags.get("reached_waterworks", false) and not RunState.story_flags.get("reached_quarter", false) and not RunState.story_flags.get("reached_archive", false)
		"waterworks": return RunState.story_flags.get("reached_waterworks", false) and not RunState.story_flags.get("reached_quarter", false) and not RunState.story_flags.get("reached_archive", false)
		"cistern_vault": return RunState.story_flags.get("in_cistern_vault", false)
		"empty_quarter": return RunState.story_flags.get("reached_quarter", false) and not RunState.story_flags.get("reached_archive", false)
		"reading_room": return RunState.story_flags.get("in_reading_room", false)
		"archive": return RunState.story_flags.get("reached_archive", false) and not RunState.story_flags.get("reached_gallery", false)
		"map_chamber": return RunState.story_flags.get("in_map_chamber", false)
		"gallery": return RunState.story_flags.get("reached_gallery", false) and not RunState.story_flags.get("reached_bell_court", false)
		"bell_court": return RunState.story_flags.get("reached_bell_court", false) and not RunState.story_flags.get("reached_high_steps", false)
		"highland_refuge": return RunState.story_flags.get("in_highland_refuge", false)
		"high_steps": return RunState.story_flags.get("reached_high_steps", false) and not RunState.story_flags.get("reached_observatory", false)
		"reed_causeway": return RunState.story_flags.get("in_causeway", false)
		"observatory": return RunState.story_flags.get("reached_observatory", false)
		"quiet_garden": return RunState.story_flags.get("in_quiet_garden", false)
		_: return false

func _create_camera() -> void:
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.5
	# Keep the traveler's feet below center so the next stretch of path is visible.
	camera.offset = Vector2(0, -10)
	camera.limit_enabled = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)
	camera.zoom = Vector2.ONE
	traveler.camera_reference = camera
	add_child(camera)
	camera.make_current()
	camera.global_position = traveler.global_position

func _update_traveler_occlusion() -> void:
	# Orchard branches and canopy are painted into the backdrop. Fade the sprite
	# only while it passes beneath those foreground silhouettes.
	var under_canopy := false
	if phase == "orchard":
		var point := traveler.global_position
		under_canopy = _inside_ellipse(point, Vector2(51, 119), Vector2(67, 112)) \
			or _inside_ellipse(point, Vector2(597, 124), Vector2(48, 105)) \
			or _inside_ellipse(point, Vector2(293, 47), Vector2(173, 28))
	var target_alpha := 0.52 if under_canopy else 1.0
	var easing := 0.18 if RunState.settings.get("reduced_motion", false) else 0.12
	var tint := traveler.modulate
	tint.a = lerpf(tint.a, target_alpha, easing)
	traveler.modulate = tint

func _inside_ellipse(point: Vector2, center: Vector2, radii: Vector2) -> bool:
	var normalized := (point - center) / radii
	return normalized.length_squared() <= 1.0

func _create_beth() -> void:
	beth = BETH_SCENE.instantiate() as Beth
	beth.position = Vector2(48, 230) if phase == "ruins" else Vector2(337, 232)
	beth.follow_target = traveler
	beth.awake = RunState.story_flags.get("beth_awake", false)
	beth.react_to_hint(RunState.total_hint_points)
	beth.visible = phase != "crossing"
	beth.z_index = 11
	add_child(beth)

func _create_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var frame := Control.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(frame)
	objective_label = _new_label("", 8, Color("#e5e1cf"), Vector2(8, 5), Vector2(214, 16))
	frame.add_child(objective_label)
	var journal_hint := _new_label("%s  NOTES  %s  HINTS" % [_action_mark("journal"), _action_mark("hints")], 6, Color("#b7c4bc"), Vector2(224, 7), Vector2(88, 12))
	journal_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	frame.add_child(journal_hint)
	inventory_label = _new_label("", 6, Color("#bdc8bb"), Vector2(8, 22), Vector2(230, 12))
	frame.add_child(inventory_label)
	var status_back := ColorRect.new()
	status_back.position = Vector2(5, 137)
	status_back.size = Vector2(310, 27)
	status_back.color = Color("#111b20")
	status_back.modulate.a = 0.88
	frame.add_child(status_back)
	status_label = _new_label(status_text, 7, Color("#e3dfd2"), Vector2(10, 140), Vector2(300, 22))
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	frame.add_child(status_label)
	prompt_label = _new_label("", 7, Color("#d5e8dd"), Vector2(9, 120), Vector2(300, 14))
	frame.add_child(prompt_label)
	target_icon = ColorRect.new()
	target_icon.size = Vector2(7, 7)
	target_icon.color = Color("#dcead4")
	target_icon.visible = false
	frame.add_child(target_icon)
	var icon_center := ColorRect.new()
	icon_center.position = Vector2(2, 2)
	icon_center.size = Vector2(3, 3)
	icon_center.color = Color("#52685e")
	target_icon.add_child(icon_center)
	var controls := _new_label("MOVE %s/%s/%s/%s   RUN %s   LOOK %s   PAUSE %s" % [_action_mark("move_left"), _action_mark("move_right"), _action_mark("move_up"), _action_mark("move_down"), _action_mark("run"), _action_mark("examine"), _action_mark("pause")], 5, Color("#9ca9a4"), Vector2(8, 168), Vector2(304, 9))
	frame.add_child(controls)
	transition_cover = ColorRect.new()
	transition_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_cover.color = Color("#d7e4df")
	transition_cover.modulate.a = 0.0
	transition_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(transition_cover)

func _new_label(text: String, size: int, color: Color, pos: Vector2, dimensions: Vector2) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = dimensions
	var font_size := size + (2 if RunState.settings.get("large_text", false) else 0)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("#0a1115"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label

func _action_mark(action_name: String) -> String:
	var bindings := RunState.get_binding_text(action_name).split(" / ")
	return str(bindings[0]) if not bindings.is_empty() else "?"

func _motion_duration(seconds: float) -> float:
	return 0.0 if bool(RunState.settings.get("reduced_motion", false)) else seconds

func _initial_status_for_phase() -> String:
	match phase:
		"crossing":
			return "A medallion rests beside the buried arch."
		"ruins":
			return "Beth's small light waits among the old stones." if RunState.story_flags.get("beth_awake", false) else "A small light rests beside the silent gate."
		"orchard":
			return "Water runs again through the quiet orchard." if RunState.story_flags.get("orchard_water_restored", false) else "Three dry channels meet at the old basin."
		"waterworks":
			return "The water gate stands open toward the village." if RunState.story_flags.get("waterworks_solved", false) else "The old cistern waits beneath the orchard."
		"cistern_vault":
			return "The lower cistern keeps the old water clock running without a sound."
		"reed_causeway":
			return "The old stones lead across the still water."
		"empty_quarter":
			return "The well holds a pale, starless reflection." if RunState.story_flags.get("archive_puzzle_solved", false) else "Four dark doorways face the village well."
		"reading_room":
			return "A lantern still warms the little room above the square."
		"archive":
			return "The archive holds its breath beneath the orchard. Beth's light doubles in the still water."
		"map_chamber":
			return "An old map gathers the valley's paths beneath a quiet stone arch."
		"gallery":
			return "A quiet pool waits beneath the reflected sky."
		"bell_court":
			return "The garden bells stir in the mountain air."
		"highland_refuge":
			return "The refuge lantern keeps its small pool of warmth against the wind."
		"high_steps":
			return "The wind moves softly across the high steps."
		"quiet_garden":
			return "The hidden garden keeps its small, clear song."
		"observatory":
			return "The world remembers." if RunState.story_flags.get("ending_revealed", false) else "The old inscription waits in the starlight."
		_:
			return status_text

func _get_targets() -> Array[Dictionary]:
	if phase == "crossing":
		var crossing_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("medallion_found", false):
			crossing_targets.append({"id": "medallion", "name": "the medallion", "position": Vector2(278, 170)})
		if not RunState.story_flags.get("moss_button_found", false):
			crossing_targets.append({"id": "moss_button", "name": "the green brass button", "position": Vector2(190, 250)})
		if RunState.story_flags.get("medallion_found", false):
			crossing_targets.append({"id": "arch", "name": "the buried arch", "position": Vector2(490, 123)})
		if not RunState.story_flags.get("crossing_stone_seen", false):
			crossing_targets.append({"id": "crossing_stone", "name": "the old roadstone", "position": Vector2(103, 194)})
		return crossing_targets
	if phase == "orchard":
		var orchard_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("orchard_mural_seen", false):
			orchard_targets.append({"id": "orchard_mural", "name": "the orchard mural", "position": Vector2(83, 151)})
		if not RunState.story_flags.get("orchard_memory_seen", false):
			orchard_targets.append({"id": "memory_bloom", "name": "the pale bloom", "position": Vector2(563, 151)})
		if not RunState.story_flags.get("orchard_water_restored", false):
			orchard_targets.append({"id": "sluice_west", "name": "the western sluice", "position": Vector2(228, 158)})
			orchard_targets.append({"id": "sluice_north", "name": "the northern sluice", "position": Vector2(320, 130)})
			orchard_targets.append({"id": "sluice_east", "name": "the eastern sluice", "position": Vector2(422, 158)})
		else:
			orchard_targets.append({"id": "waterworks_gate", "name": "the channel arch", "position": Vector2(320, 87)})
		if RunState.story_flags.get("orchard_memory_seen", false) and not RunState.story_flags.get("seed_pod_found", false):
			orchard_targets.append({"id": "seed_pod", "name": "the pale seed pod", "position": Vector2(563, 160)})
		if RunState.story_flags.get("orchard_water_restored", false) and not RunState.story_flags.get("river_glass_found", false):
			orchard_targets.append({"id": "river_glass", "name": "a piece of river glass", "position": Vector2(339, 215)})
		if RunState.story_flags.get("orchard_water_restored", false) and not RunState.story_flags.get("quiet_garden_restored", false):
			orchard_targets.append({"id": "seed_bed", "name": "the empty garden bed", "position": Vector2(182, 271)})
		if RunState.story_flags.get("quiet_garden_restored", false):
			orchard_targets.append({"id": "garden_gate", "name": "the hidden garden arch", "position": Vector2(182, 242)})
		if RunState.story_flags.get("orchard_water_restored", false):
			orchard_targets.append({"id": "causeway_gate", "name": "the reed causeway path", "position": Vector2(548, 102)})
		if not RunState.story_flags.get("orchard_rope_seen", false):
			orchard_targets.append({"id": "orchard_rope", "name": "the old grafting stand", "position": Vector2(84, 222)})
		return orchard_targets
	if phase == "waterworks":
		var waterworks_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("waterworks_map_seen", false):
			waterworks_targets.append({"id": "waterworks_map", "name": "the channel map", "position": Vector2(320, 76)})
		if not RunState.story_flags.get("waterworks_bowl_record_seen", false):
			waterworks_targets.append({"id": "waterworks_bowls", "name": "three small bowls by the channel", "position": Vector2(112, 245)})
		if not RunState.story_flags.get("waterworks_solved", false):
			waterworks_targets.append({"id": "waterwheel_west", "name": "the western waterwheel", "position": Vector2(173, 151)})
			waterworks_targets.append({"id": "waterwheel_center", "name": "the middle waterwheel", "position": Vector2(320, 128)})
			waterworks_targets.append({"id": "waterwheel_east", "name": "the eastern waterwheel", "position": Vector2(463, 151)})
		else:
			waterworks_targets.append({"id": "waterworks_exit", "name": "the opened village gate", "position": Vector2(575, 106)})
			waterworks_targets.append({"id": "waterworks_cistern_stair", "name": "the lower cistern stair", "position": Vector2(82, 158)})
		return waterworks_targets
	if phase == "cistern_vault":
		var cistern_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("cistern_mural_seen", false) or (RunState.inventory.has("river_glass") and not RunState.journal_entries.has("cistern_glass_memory")):
			cistern_targets.append({"id": "cistern_mural", "name": "the old water clock", "position": Vector2(320, 88)})
		if not RunState.story_flags.get("cistern_solved", false):
			for valve_name in ["west", "center", "east"]:
				cistern_targets.append({"id": "cistern_valve_%s" % valve_name, "name": "the %s cistern valve" % valve_name, "position": CISTERN_VALVE_POSITIONS[valve_name]})
		elif not RunState.story_flags.get("cistern_record_seen", false):
			cistern_targets.append({"id": "cistern_record", "name": "the water keeper's ledger", "position": Vector2(552, 230)})
		cistern_targets.append({"id": "cistern_return", "name": "the stair back to the waterworks", "position": Vector2(46, 194)})
		return cistern_targets
	if phase == "reed_causeway":
		var causeway_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("causeway_marks_seen", false):
			causeway_targets.append({"id": "causeway_marks", "name": "the shoreline marks", "position": Vector2(84, 220)})
		if not RunState.story_flags.get("causeway_record_seen", false):
			causeway_targets.append({"id": "causeway_record", "name": "a reed basket beside the water", "position": Vector2(554, 264)})
		if not RunState.story_flags.get("causeway_solved", false):
			var step_names := ["near", "second", "third", "far"]
			for index in range(CAUSEWAY_STONE_POSITIONS.size()):
				causeway_targets.append({"id": "causeway_step_%d" % index, "name": "the %s stepping stone" % step_names[index], "position": CAUSEWAY_STONE_POSITIONS[index]})
		else:
			causeway_targets.append({"id": "causeway_village_gate", "name": "the covered channel beyond the water", "position": Vector2(320, 111)})
		causeway_targets.append({"id": "causeway_return", "name": "the shore path back to the orchard", "position": Vector2(320, 324)})
		return causeway_targets
	if phase == "empty_quarter":
		var quarter_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("quarter_mural_seen", false):
			quarter_targets.append({"id": "quarter_mural", "name": "the well's worn carving", "position": Vector2(320, 200)})
		if not RunState.story_flags.get("quarter_household_restored", false):
			quarter_targets.append({"id": "quarter_slot_west", "name": "the west-house niche", "position": Vector2(137, 222)})
			quarter_targets.append({"id": "quarter_slot_north", "name": "the north-house niche", "position": Vector2(224, 152)})
			quarter_targets.append({"id": "quarter_slot_east", "name": "the east-house niche", "position": Vector2(438, 152)})
			quarter_targets.append({"id": "quarter_slot_south", "name": "the south-house niche", "position": Vector2(566, 210)})
		else:
			quarter_targets.append({"id": "quarter_well_stair", "name": "the opened well stair", "position": Vector2(320, 184)})
			quarter_targets.append({"id": "quarter_reading_door", "name": "the open west-house reading room", "position": Vector2(111, 174)})
		if not RunState.story_flags.get("quarter_register_seen", false):
			quarter_targets.append({"id": "quarter_register", "name": "the stone register", "position": Vector2(572, 232)})
		if _village_gathering_clues_complete() and not RunState.story_flags.get("village_gathering_solved", false):
			if not RunState.story_flags.get("village_gathering_marks_seen", false):
				quarter_targets.append({"id": "village_gathering_marks", "name": "the three worn marks around the well", "position": Vector2(320, 166)})
			quarter_targets.append({"id": "village_gathering_bowl", "name": "the bowl mark beside the well", "position": Vector2(292, 166)})
			quarter_targets.append({"id": "village_gathering_lamp", "name": "the lamp mark beside the well", "position": Vector2(320, 166)})
			quarter_targets.append({"id": "village_gathering_bell", "name": "the bell mark beside the well", "position": Vector2(348, 166)})
		elif RunState.story_flags.get("village_gathering_solved", false) and not RunState.story_flags.get("village_gathering_record_seen", false):
			quarter_targets.append({"id": "village_gathering_record", "name": "the newly visible well inscription", "position": Vector2(320, 166)})
		return quarter_targets
	if phase == "reading_room":
		var reading_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("reading_mural_seen", false):
			reading_targets.append({"id": "reading_mural", "name": "the children's lesson slate", "position": Vector2(519, 87)})
		if not RunState.story_flags.get("reading_puzzle_solved", false):
			reading_targets.append({"id": "reading_tile_west", "name": "the west study marker", "position": Vector2(431, 152)})
			reading_targets.append({"id": "reading_tile_center", "name": "the center study marker", "position": Vector2(503, 152)})
			reading_targets.append({"id": "reading_tile_east", "name": "the east study marker", "position": Vector2(575, 152)})
		elif not RunState.story_flags.get("reading_lesson_seen", false):
			reading_targets.append({"id": "reading_ledger", "name": "the open lesson book", "position": Vector2(547, 148)})
		reading_targets.append({"id": "reading_return", "name": "the doorway back to the village square", "position": Vector2(42, 203)})
		return reading_targets
	if phase == "archive":
		var archive_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("archive_mural_seen", false) or (RunState.inventory.has("mirror_shard") and not RunState.journal_entries.has("archive_second_image")):
			archive_targets.append({"id": "archive_mural", "name": "the ceiling mural", "position": Vector2(320, 84)})
		if not RunState.story_flags.get("archive_memory_seen", false) or (RunState.inventory.has("river_glass") and not RunState.journal_entries.has("river_glass_memory")):
			archive_targets.append({"id": "archive_memory", "name": "the reflecting pool", "position": Vector2(434, 192)})
		if not RunState.story_flags.get("archive_puzzle_solved", false):
			archive_targets.append({"id": "lens_west", "name": "the western lens", "position": Vector2(145, 220)})
			archive_targets.append({"id": "lens_center", "name": "the central lens", "position": Vector2(320, 220)})
			archive_targets.append({"id": "lens_east", "name": "the eastern lens", "position": Vector2(525, 220)})
		else:
			if RunState.journal_entries.has("archive_second_image") and not RunState.story_flags.get("archive_fourth_path_solved", false):
				archive_targets.append({"id": "lens_west", "name": "the western lens", "position": Vector2(145, 220)})
				archive_targets.append({"id": "lens_center", "name": "the central lens", "position": Vector2(320, 220)})
				archive_targets.append({"id": "lens_east", "name": "the eastern lens", "position": Vector2(525, 220)})
			archive_targets.append({"id": "archive_stair", "name": "the stair to the map chamber", "position": Vector2(320, 142)})
			archive_targets.append({"id": "archive_well_stair", "name": "the stair back to the village well", "position": Vector2(320, 264)})
		if RunState.story_flags.get("archive_fourth_path_solved", false) and not RunState.story_flags.get("archive_hidden_ledger_seen", false):
			archive_targets.append({"id": "archive_hidden_ledger", "name": "a leaf on the low shelf", "position": Vector2(72, 205)})
		if not RunState.story_flags.get("mirror_shard_found", false):
			archive_targets.append({"id": "mirror_shard", "name": "a silvered glass shard", "position": Vector2(566, 264)})
		if not RunState.story_flags.get("archive_last_entry_seen", false):
			archive_targets.append({"id": "archive_last_entry", "name": "the last catalogue entry", "position": Vector2(76, 270)})
		return archive_targets
	if phase == "gallery":
		var gallery_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("gallery_mural_seen", false):
			gallery_targets.append({"id": "gallery_mural", "name": "the pool-side mural", "position": Vector2(246, 154)})
		if not RunState.story_flags.get("gallery_memory_seen", false) or (RunState.inventory.has("mirror_shard") and not RunState.journal_entries.has("gallery_second_sky")):
			gallery_targets.append({"id": "gallery_pool", "name": "the starless pool", "position": Vector2(320, 184)})
		if not RunState.story_flags.get("gallery_lights_solved", false):
			gallery_targets.append({"id": "gallery_mirror_west", "name": "the western mirror stone", "position": Vector2(160, 190)})
			gallery_targets.append({"id": "gallery_mirror_center", "name": "the central mirror stone", "position": Vector2(320, 190)})
			gallery_targets.append({"id": "gallery_mirror_east", "name": "the eastern mirror stone", "position": Vector2(464, 190)})
		else:
			gallery_targets.append({"id": "gallery_stair", "name": "the stair beneath the pool", "position": Vector2(320, 140)})
		if not RunState.story_flags.get("gallery_figures_seen", false):
			gallery_targets.append({"id": "gallery_figures", "name": "the worn procession", "position": Vector2(88, 252)})
		return gallery_targets
	if phase == "map_chamber":
		var map_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("map_chamber_mural_seen", false):
			map_targets.append({"id": "map_chamber_mural", "name": "the old valley map", "position": Vector2(320, 95)})
		if not RunState.story_flags.get("map_route_solved", false):
			for route_node in ["spring", "bridge", "village"]:
				map_targets.append({"id": "map_route_%s" % route_node, "name": "the %s on the map" % route_node, "position": MAP_ROUTE_POSITIONS[route_node]})
		elif not RunState.story_flags.get("map_chamber_record_seen", false):
			map_targets.append({"id": "map_chamber_record", "name": "the keeper's route ledger", "position": Vector2(88, 274)})
		map_targets.append({"id": "map_chamber_return", "name": "the stair back to the archive", "position": Vector2(320, 314)})
		if RunState.story_flags.get("map_route_solved", false):
			map_targets.append({"id": "map_chamber_exit", "name": "the opened gallery arch", "position": Vector2(320, 222)})
		return map_targets
	if phase == "bell_court":
		var bell_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("bell_mural_seen", false):
			bell_targets.append({"id": "bell_mural", "name": "the bell-garden carving", "position": Vector2(320, 157)})
		if not RunState.story_flags.get("bell_bench_seen", false):
			bell_targets.append({"id": "bell_bench", "name": "the little stone bench", "position": Vector2(88, 270)})
		if not RunState.story_flags.get("bell_court_solved", false):
			bell_targets.append({"id": "court_bell_0", "name": "the first hanging bell", "position": Vector2(148, 166)})
			bell_targets.append({"id": "court_bell_1", "name": "the second hanging bell", "position": Vector2(267, 166)})
			bell_targets.append({"id": "court_bell_2", "name": "the third hanging bell", "position": Vector2(395, 166)})
			bell_targets.append({"id": "court_bell_3", "name": "the last hanging bell", "position": Vector2(520, 166)})
		else:
			bell_targets.append({"id": "bell_door", "name": "the path beyond the bell garden", "position": Vector2(582, 173)})
		if not RunState.story_flags.get("bell_keeper_names_seen", false):
			bell_targets.append({"id": "bell_keeper_names", "name": "the bell keeper's list", "position": Vector2(548, 264)})
		return bell_targets
	if phase == "high_steps":
		var steps_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("high_steps_map_seen", false):
			steps_targets.append({"id": "high_steps_map", "name": "the wind-worn map", "position": Vector2(310, 111)})
		if not RunState.story_flags.get("high_steps_aligned", false):
			steps_targets.append({"id": "steps_vane_west", "name": "the western wind vane", "position": Vector2(118, 175)})
			steps_targets.append({"id": "steps_vane_center", "name": "the middle wind vane", "position": Vector2(268, 146)})
			steps_targets.append({"id": "steps_vane_east", "name": "the eastern wind vane", "position": Vector2(423, 126)})
		else:
			steps_targets.append({"id": "steps_door", "name": "the observatory door", "position": Vector2(560, 110)})
		if not RunState.story_flags.get("high_steps_lantern_seen", false):
			steps_targets.append({"id": "high_steps_lantern", "name": "the last trail lantern", "position": Vector2(205, 262)})
		return steps_targets
	if phase == "highland_refuge":
		var refuge_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("refuge_map_seen", false):
			refuge_targets.append({"id": "refuge_map", "name": "the refuge's high-path map", "position": Vector2(110, 132)})
		if not RunState.story_flags.get("refuge_guest_book_seen", false):
			refuge_targets.append({"id": "refuge_guest_book", "name": "the guest book on the long table", "position": Vector2(304, 205)})
		if not RunState.story_flags.get("refuge_lantern_seen", false):
			refuge_targets.append({"id": "refuge_lantern", "name": "the sheltered lantern", "position": Vector2(78, 190)})
		refuge_targets.append({"id": "refuge_return", "name": "the stair back to the bell garden", "position": Vector2(44, 303)})
		refuge_targets.append({"id": "refuge_exit", "name": "the path climbing to the highland steps", "position": Vector2(588, 125)})
		return refuge_targets
	if phase == "quiet_garden":
		var garden_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("garden_carving_seen", false):
			garden_targets.append({"id": "garden_carving", "name": "the small wall carving", "position": Vector2(218, 104)})
		if not RunState.story_flags.get("garden_bench_seen", false):
			garden_targets.append({"id": "garden_bench", "name": "the old garden bench", "position": Vector2(548, 174)})
		if not RunState.story_flags.get("garden_cup_seen", false):
			garden_targets.append({"id": "garden_cup", "name": "the covered clay cup", "position": Vector2(80, 246)})
		if not RunState.story_flags.get("quiet_garden_song_solved", false):
			garden_targets.append({"id": "garden_chime_0", "name": "the first glass chime", "position": Vector2(342, 124)})
			garden_targets.append({"id": "garden_chime_1", "name": "the second glass chime", "position": Vector2(400, 132)})
			garden_targets.append({"id": "garden_chime_2", "name": "the last glass chime", "position": Vector2(448, 148)})
		garden_targets.append({"id": "garden_return", "name": "the arch back to the orchard", "position": Vector2(58, 190)})
		return garden_targets
	if phase == "observatory":
		var observatory_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("observatory_chart_seen", false):
			observatory_targets.append({"id": "observatory_chart", "name": "the keeper's star chart", "position": Vector2(148, 157)})
		if not RunState.story_flags.get("observatory_orrery_solved", false):
			observatory_targets.append({"id": "observatory_arm_west", "name": "the western astrolabe arm", "position": Vector2(87, 150)})
			observatory_targets.append({"id": "observatory_arm_center", "name": "the upper astrolabe arm", "position": Vector2(108, 126)})
			observatory_targets.append({"id": "observatory_arm_east", "name": "the eastern astrolabe arm", "position": Vector2(132, 150)})
		if not RunState.story_flags.get("ending_revealed", false):
			observatory_targets.append({"id": "final_inscription", "name": "the old inscription", "position": Vector2(320, 101)})
		return observatory_targets
	var targets: Array[Dictionary] = []
	if phase == "ruins" and not RunState.story_flags.get("ruins_kiln_tag_seen", false):
		targets.append({"id": "ruins_kiln_tag", "name": "the kiln's last clay tag", "position": Vector2(500, 255)})
	if not RunState.story_flags.get("beth_awake", false):
		targets.append({"id": "beth", "name": "Beth", "position": Vector2(48, 230)})
	if not RunState.story_flags.get("inscription_seen", false) or (RunState.inventory.has("stone_chip") and not RunState.journal_entries.has("matching_stone_cuts")):
		targets.append({"id": "inscription", "name": "the inscription", "position": Vector2(72, 150)})
	if RunState.story_flags.get("inscription_seen", false) and not RunState.story_flags.get("stone_chip_found", false):
		targets.append({"id": "stone_chip", "name": "a loose inscription chip", "position": Vector2(77, 178)})
	if not RunState.story_flags.get("old_bead_found", false):
		targets.append({"id": "old_bead", "name": "a cloudy bead", "position": Vector2(150, 251)})
	if not RunState.story_flags.get("resonance_clue_seen", false):
		targets.append({"id": "mosaic", "name": "the faded mosaic", "position": Vector2(205, 111)})
	if not RunState.story_flags.get("first_gate_open", false):
		targets.append({"id": "resonator_moon", "name": "the crescent resonator", "position": Vector2(230, 215)})
		targets.append({"id": "resonator_water", "name": "the rain-line resonator", "position": Vector2(320, 204)})
		targets.append({"id": "resonator_seed", "name": "the seed resonator", "position": Vector2(420, 215)})
	else:
		targets.append({"id": "gate", "name": "the opened gate", "position": Vector2(320, 155)})
	return targets

func _nearest_target() -> Dictionary:
	var closest: Dictionary = {}
	var best_distance := 23.0
	for target in _get_targets():
		var distance := traveler.global_position.distance_to(target.position)
		if distance < best_distance:
			best_distance = distance
			closest = target
	return closest

func _update_prompt() -> void:
	if prompt_label == null:
		return
	if journal_panel != null or hint_panel != null or pause_panel != null or inventory_panel != null or transitioning:
		prompt_label.text = ""
		target_icon.visible = false
		return
	var target := _nearest_target()
	if target.is_empty():
		prompt_label.text = ""
		target_icon.visible = false
		return
	var screen_position: Vector2 = get_viewport().get_canvas_transform() * target.position
	target_icon.position = screen_position + Vector2(-3, -18)
	target_icon.visible = true
	var id: String = target.id
	match id:
		"medallion":
			prompt_label.text = "%s  examine     %s  take" % [_action_mark("examine"), _action_mark("pick_up")]
		"moss_button", "stone_chip", "old_bead", "seed_pod", "river_glass", "mirror_shard":
			prompt_label.text = "%s  examine     %s  take" % [_action_mark("examine"), _action_mark("pick_up")]
		"arch":
			prompt_label.text = "%s  examine     %s  cross" % [_action_mark("examine"), _action_mark("activate")]
		"beth":
			prompt_label.text = "%s  wake the small light" % _action_mark("examine")
		"inscription":
			prompt_label.text = "%s  examine inscription" % _action_mark("examine")
			if RunState.selected_item_id == "stone_chip":
				prompt_label.text += "     %s  fit chip" % _action_mark("use_item")
		"mosaic":
			prompt_label.text = "%s  study the worn symbols" % _action_mark("examine")
		"resonator_moon", "resonator_water", "resonator_seed":
			prompt_label.text = "%s  attune" % _action_mark("activate")
		"gate":
			prompt_label.text = "%s  look beyond" % _action_mark("examine")
			if traveler.position.distance_to(Vector2(320, 155)) < 28:
				prompt_label.text = "%s  look beyond     %s  enter the orchard" % [_action_mark("examine"), _action_mark("activate")]
		"orchard_mural":
			prompt_label.text = "%s  study the water channels" % _action_mark("examine")
		"waterworks_map":
			prompt_label.text = "%s  study the channel map" % _action_mark("examine")
		"waterworks_bowls":
			prompt_label.text = "%s  look at the waiting bowls" % _action_mark("examine")
		"waterwheel_west", "waterwheel_center", "waterwheel_east":
			prompt_label.text = "%s  examine     %s  turn the waterwheel" % [_action_mark("examine"), _action_mark("activate")]
		"waterworks_exit":
			prompt_label.text = "%s  look through the open gate     %s  enter the village" % [_action_mark("examine"), _action_mark("activate")]
		"waterworks_cistern_stair":
			prompt_label.text = "%s  descend to the lower cistern" % _action_mark("activate")
		"cistern_mural":
			prompt_label.text = "%s  study the water clock" % _action_mark("examine")
		"cistern_valve_west", "cistern_valve_center", "cistern_valve_east":
			prompt_label.text = "%s  examine     %s  turn the cistern valve" % [_action_mark("examine"), _action_mark("activate")]
		"cistern_record":
			prompt_label.text = "%s  read the water keeper's ledger" % _action_mark("examine")
		"cistern_return":
			prompt_label.text = "%s  return to the waterworks" % _action_mark("activate")
		"memory_bloom":
			prompt_label.text = "%s  listen to the pale bloom" % _action_mark("examine")
		"sluice_west", "sluice_north", "sluice_east":
			prompt_label.text = "%s  turn the sluice" % _action_mark("activate")
		"waterworks_gate":
			prompt_label.text = "%s  follow the water     %s  enter the old waterworks" % [_action_mark("examine"), _action_mark("activate")]
		"causeway_gate":
			prompt_label.text = "%s  examine     %s  follow the reeds" % [_action_mark("examine"), _action_mark("activate")]
		"causeway_marks":
			prompt_label.text = "%s  study the water marks" % _action_mark("examine")
		"causeway_record":
			prompt_label.text = "%s  study the old record" % _action_mark("examine")
		"causeway_step_0", "causeway_step_1", "causeway_step_2", "causeway_step_3":
			prompt_label.text = "%s  step onto the stone" % _action_mark("activate")
		"causeway_village_gate":
			prompt_label.text = "%s  examine     %s  follow the covered channel" % [_action_mark("examine"), _action_mark("activate")]
		"causeway_return":
			prompt_label.text = "%s  return to the orchard" % _action_mark("activate")
		"quarter_mural", "quarter_register", "village_gathering_marks", "village_gathering_record", "refuge_map", "refuge_guest_book", "refuge_lantern":
			prompt_label.text = "%s  study the old record" % _action_mark("examine")
		"refuge_return":
			prompt_label.text = "%s  return to the bell garden" % _action_mark("activate")
		"refuge_exit":
			prompt_label.text = "%s  climb to the highland steps" % _action_mark("activate")
		"village_gathering_bowl", "village_gathering_lamp", "village_gathering_bell":
			prompt_label.text = "%s  examine     %s  answer the mark" % [_action_mark("examine"), _action_mark("activate")]
		"quarter_slot_west", "quarter_slot_north", "quarter_slot_east", "quarter_slot_south":
			prompt_label.text = "%s  examine     %s  turn the niche" % [_action_mark("examine"), _action_mark("activate")]
		"quarter_well_stair":
			prompt_label.text = "%s  look into the well     %s  descend" % [_action_mark("examine"), _action_mark("activate")]
		"quarter_reading_door":
			prompt_label.text = "%s  enter the reading room" % _action_mark("activate")
		"reading_mural":
			prompt_label.text = "%s  study the lesson slate" % _action_mark("examine")
		"reading_tile_west", "reading_tile_center", "reading_tile_east":
			prompt_label.text = "%s  examine     %s  turn the study marker" % [_action_mark("examine"), _action_mark("activate")]
		"reading_ledger":
			prompt_label.text = "%s  read the open lesson book" % _action_mark("examine")
		"reading_return":
			prompt_label.text = "%s  return to the village square" % _action_mark("activate")
		"archive_mural":
			prompt_label.text = "%s  study the reflected shapes" % _action_mark("examine")
		"archive_hidden_ledger":
			prompt_label.text = "%s  read the loose leaf" % _action_mark("examine")
		"archive_memory":
			prompt_label.text = "%s  listen to the reflecting pool" % _action_mark("examine")
		"lens_west", "lens_center", "lens_east":
			prompt_label.text = "%s  turn the lens" % _action_mark("activate")
		"archive_stair":
			prompt_label.text = "%s  look into the light     %s  descend to the map room" % [_action_mark("examine"), _action_mark("activate")]
		"archive_well_stair":
			prompt_label.text = "%s  climb back to the village well" % _action_mark("activate")
		"map_chamber_mural":
			prompt_label.text = "%s  study the valley map" % _action_mark("examine")
		"map_route_spring", "map_route_bridge", "map_route_village":
			prompt_label.text = "%s  trace this place" % _action_mark("activate")
		"map_chamber_record":
			prompt_label.text = "%s  read the route ledger" % _action_mark("examine")
		"map_chamber_return":
			prompt_label.text = "%s  climb back to the archive" % _action_mark("activate")
		"map_chamber_exit":
			prompt_label.text = "%s  enter the reflection gallery" % _action_mark("activate")
		"seed_bed":
			prompt_label.text = "%s  examine     %s  plant the pale seed" % [_action_mark("examine"), _action_mark("use_item")]
		"final_inscription":
			prompt_label.text = "%s  examine     %s  use the selected keepsake" % [_action_mark("examine"), _action_mark("use_item")]
		"observatory_chart":
			prompt_label.text = "%s  read the keeper's chart" % _action_mark("examine")
		"observatory_arm_west", "observatory_arm_center", "observatory_arm_east":
			prompt_label.text = "%s  examine     %s  turn the astrolabe arm" % [_action_mark("examine"), _action_mark("activate")]
		"gallery_mirror_west", "gallery_mirror_center", "gallery_mirror_east":
			prompt_label.text = "%s  examine     %s  turn the mirror" % [_action_mark("examine"), _action_mark("activate")]
		"gallery_stair":
			prompt_label.text = "%s  listen below     %s  descend" % [_action_mark("examine"), _action_mark("activate")]
		"court_bell_0", "court_bell_1", "court_bell_2", "court_bell_3":
			prompt_label.text = "%s  examine     %s  ring the bell" % [_action_mark("examine"), _action_mark("activate")]
		"bell_door":
			prompt_label.text = "%s  look through the arch     %s  enter" % [_action_mark("examine"), _action_mark("activate")]
		"high_steps_map":
			prompt_label.text = "%s  study the wind-worn map" % _action_mark("examine")
		"steps_vane_west", "steps_vane_center", "steps_vane_east":
			prompt_label.text = "%s  examine     %s  turn the vane" % [_action_mark("examine"), _action_mark("activate")]
		"steps_door":
			prompt_label.text = "%s  approach the observatory     %s  enter" % [_action_mark("examine"), _action_mark("activate")]
		"garden_gate":
			prompt_label.text = "%s  look into the sheltered garden     %s  enter" % [_action_mark("examine"), _action_mark("activate")]
		"garden_return":
			prompt_label.text = "%s  look back to the orchard     %s  return" % [_action_mark("examine"), _action_mark("activate")]
		"garden_carving":
			prompt_label.text = "%s  study the small wall carving" % _action_mark("examine")
		"garden_bench":
			prompt_label.text = "%s  rest on the old bench" % _action_mark("examine")
		"garden_chime_0", "garden_chime_1", "garden_chime_2":
			prompt_label.text = "%s  examine     %s  ring the chime" % [_action_mark("examine"), _action_mark("activate")]
		"bell_mural":
			prompt_label.text = "%s  study the bell-garden carving" % _action_mark("examine")
		"bell_bench":
			prompt_label.text = "%s  sit beside Beth" % _action_mark("examine")
		"gallery_mural":
			prompt_label.text = "%s  study the pool-side mural" % _action_mark("examine")
		"gallery_pool":
			prompt_label.text = "%s  listen to the starless pool" % _action_mark("examine")
		"crossing_stone", "ruins_kiln_tag", "orchard_rope", "archive_last_entry", "gallery_figures", "bell_keeper_names", "high_steps_lantern", "garden_cup":
			prompt_label.text = "%s  study the old record" % _action_mark("examine")
	var item_hint := ""
	match [id, RunState.selected_item_id]:
		["arch", "moss_button"]: item_hint = "fit the brass button"
		["arch", "medallion"]: item_hint = "use the medallion"
		["inscription", "stone_chip"]: item_hint = "fit the chip"
		["resonator_water", "old_bead"]: item_hint = "listen with the bead"
		["archive_mural", "mirror_shard"]: item_hint = "look through the shard"
		["archive_memory", "river_glass"]: item_hint = "hold up the glass"
		["cistern_mural", "river_glass"]: item_hint = "hold up the glass"
		["gallery_pool", "mirror_shard"]: item_hint = "look through the shard"
	if not item_hint.is_empty() and not prompt_label.text.contains(_action_mark("use_item") + "  "):
		prompt_label.text += "     %s  %s" % [_action_mark("use_item"), item_hint]

func _examine_target() -> void:
	var target := _nearest_target()
	if target.is_empty():
		_set_status("The quiet gives you time to look around.")
		return
	if target.id != "beth" and is_instance_valid(beth):
		beth.investigate(target.position)
	match target.id:
		"medallion":
			_set_status("A cool medallion rests in the dust. Its worn marks catch the light.")
		"moss_button":
			_set_status("A green brass button, polished by someone's thumb long ago.")
		"crossing_stone":
			_reveal_world_memory("crossing_stone_seen", "crossing_floodlines", "Three floodlines climb the roadstone. Beyond the highest, someone carved a row of little boats.")
		"arch":
			_set_status("The buried arch is older than the path around it. The medallion stirs in your hand.")
		"beth":
			_wake_beth()
		"inscription":
			_set_status("The inscription shifts at the edge of sight, but the marks remain unreadable.")
			var inscription_is_new := RunState.record_clue("gibberish_inscription")
			RunState.set_story_flag("inscription_seen")
			_update_objective()
			if inscription_is_new:
				Soundscape.play_event("journal")
				_animate_journal_signal()
		"stone_chip":
			_set_status("A broken chip fits the blank at the edge of the unreadable line.")
		"old_bead":
			_set_status("A cloudy bead rolls gently in its stone cradle. It holds a fleck of blue light.")
		"mosaic":
			_set_status("Three worn shapes repeat across the stone: crescent, rain-line, seed.")
			if RunState.record_clue("resonance_mosaic"):
				Soundscape.play_event("journal")
				RunState.set_story_flag("resonance_clue_seen")
				_animate_journal_signal()
		"resonator_moon":
			_set_status("A crescent mark is cut into the first resonator.")
		"resonator_water":
			_set_status("A line of falling rain marks the second resonator.")
		"resonator_seed":
			_set_status("A small seed mark rests on the third resonator.")
		"ruins_kiln_tag":
			_reveal_world_memory("ruins_kiln_tag_seen", "ruins_kiln_tag", "The kiln's last clay tag reads: bowls packed first; bells left to dry.")
		"gate":
			_set_status("Beyond the open arch, pale grasses move under a vast unfamiliar sky.")
		"orchard_mural":
			_set_status("Three channels meet at one basin. Each sluice must point along its channel toward the center.")
			RunState.set_story_flag("orchard_mural_seen")
		"memory_bloom":
			_set_status("A pale flower releases a soft chime. For a moment, the orchard feels inhabited.")
			if RunState.record_clue("orchard_memory"):
				Soundscape.play_event("journal")
				RunState.set_story_flag("orchard_memory_seen")
				_animate_journal_signal()
		"seed_pod":
			_set_status("The pale bloom has left one small seed pod, warm despite the dry earth.")
		"river_glass":
			_set_status("A smooth green shard rests where the restored stream bends around a stone.")
		"seed_bed":
			_set_status("An empty bed waits beside the old channel. A shallow hollow remains in the soil.")
		"orchard_rope":
			_reveal_world_memory("orchard_rope_seen", "orchard_grafts_uphill", "A tied label lists grafts sent uphill when the river failed. Every old tree began as a cutting.")
		"sluice_west":
			_set_status("The western sluice points %s. The mural shows the channel turning inward." % _direction_name(_get_valve_orientation("west")))
		"sluice_north":
			_set_status("The northern sluice points %s. The mural shows the channel turning inward." % _direction_name(_get_valve_orientation("north")))
		"sluice_east":
			_set_status("The eastern sluice points %s. The mural shows the channel turning inward." % _direction_name(_get_valve_orientation("east")))
		"waterworks_map":
			_set_status("A channel map gives four marks: rain-line, crescent, seed, crescent. The wheels answer in that order.")
			RunState.set_story_flag("waterworks_map_seen")
			_record_clue_animated("waterworks_channel_map")
		"waterworks_bowls":
			_reveal_world_memory("waterworks_bowl_record_seen", "waterworks_waiting_bowls", "Three clay bowls sit at the waterline. A faded note says the children waited here for the first cool water after summer, and no one drank from the first spill.")
		"waterwheel_west":
			_set_status("A rain-line mark is cut into the western wheel.")
		"waterwheel_center":
			_set_status("A crescent mark is cut into the middle wheel.")
		"waterwheel_east":
			_set_status("A seed mark is cut into the eastern wheel.")
		"waterworks_exit":
			_set_status("The sluice gate has lifted. A dry lane leads into the empty quarter.")
		"waterworks_cistern_stair":
			_set_status("The side stair descends below the waterline. A pale clockface glows in the dark.")
		"cistern_mural":
			_set_status("The water clock's four marks read east, west, center, west. The keeper used the pattern to balance water between the village channels.")
			RunState.set_story_flag("cistern_mural_seen")
			_record_clue_animated("cistern_valve_pattern")
			_update_objective()
		"cistern_valve_west", "cistern_valve_center", "cistern_valve_east":
			_set_status("The %s valve is still. Its brass wheel bears a worn water mark." % target.id.trim_prefix("cistern_valve_"))
		"cistern_record":
			_reveal_world_memory("cistern_record_seen", "cistern_shared_water", "A water keeper's ledger records the dry seasons by household. Each family took one measure at dawn; anyone who missed a turn was written in the next day's margin.")
		"cistern_return":
			_set_status("A narrow stair rises to the roofless waterworks.")
		"waterworks_gate":
			_set_status("The water slips beneath a low stone arch and disappears into a roofless cistern.")
		"causeway_gate":
			_set_status("A narrow reed path has appeared beside the village road. Its stones lead over the still water.")
		"causeway_marks":
			_set_status("Seven waterlines rise and fall: low, middle, high, highest, high, middle, low. The stones may answer if you follow their rhythm.")
			RunState.set_story_flag("causeway_marks_seen")
			_record_clue_animated("causeway_rhythm")
		"causeway_record":
			_reveal_world_memory("causeway_record_seen", "causeway_departure", "A reed basket holds four colored wrist cords. A note says: Wait by the water; no one crosses alone.")
		"causeway_step_0", "causeway_step_1", "causeway_step_2", "causeway_step_3":
			var stone_number := int(target.id.trim_prefix("causeway_step_")) + 1
			_set_status("Stone %d holds a shallow mark worn smooth by many careful steps." % stone_number)
		"causeway_village_gate":
			_set_status("Beyond the last stepping stone, a covered channel leads toward the village waterworks.")
		"quarter_mural":
			_set_status("Four house marks circle the well: book, bowl, seed, lamp. Each belongs to one doorway.")
			RunState.set_story_flag("quarter_mural_seen")
			_record_clue_animated("quarter_household_map")
			_update_objective()
		"quarter_register":
			_reveal_world_memory("quarter_register_seen", "quarter_register", "A stone register lists the village trades: readers, potters, growers, lamplighters. The last column is worn blank.")
		"village_gathering_marks":
			_set_status("A line circles the rim: set aside water, leave one lamp, then ring once after the road is empty.")
			RunState.set_story_flag("village_gathering_marks_seen")
			_record_clue_animated("village_gathering_order")
			_update_objective()
		"village_gathering_bowl", "village_gathering_lamp", "village_gathering_bell":
			_set_status("The %s mark is worn smooth by many hands." % target.id.trim_prefix("village_gathering_"))
		"village_gathering_record":
			_reveal_world_memory("village_gathering_record_seen", "village_last_gathering", "At the last gathering, the village set aside the first clean water, left a lamp in the doorway, and rang once when the road was empty. The register's blank final column is filled with a single word: together.")
		"refuge_map":
			_reveal_world_memory("refuge_map_seen", "refuge_high_path", "The refuge map marks three shelters along the ridge path. A small note says the upper stair remains open in every season.")
		"refuge_guest_book":
			_reveal_world_memory("refuge_guest_book_seen", "refuge_guest_book", "The guest book records two long winters. Its final entry asks whoever leaves last to keep one place by the fire for anyone still on the path.")
		"refuge_lantern":
			_reveal_world_memory("refuge_lantern_seen", "refuge_last_lantern", "The sheltered lantern has been trimmed and filled. A keeper's note asks that it stay lit until the last bell is answered.")
		"quarter_slot_west", "quarter_slot_north", "quarter_slot_east", "quarter_slot_south":
			var quarter_side: String = target.id.trim_prefix("quarter_slot_")
			var quarter_room := {"west": "reading room", "north": "kitchen", "east": "seed room", "south": "entry hall"}
			var quarter_slots := _get_quarter_slots()
			var quarter_object: String = QUARTER_OBJECTS[int(quarter_slots.get(quarter_side, 0))]
			_set_status("The %s doorway opens to a %s. Its niche currently holds the %s." % [quarter_side, quarter_room[quarter_side], quarter_object])
		"quarter_well_stair":
			if RunState.story_flags.get("archive_puzzle_solved", false) and not RunState.story_flags.get("quarter_well_reflection_seen", false):
				_set_status("The well holds the Archive's starless sky. Four warm reflections gather around one quiet gap.")
				RunState.set_story_flag("quarter_well_reflection_seen")
				if RunState.record_clue("quarter_well_reflection"):
					Soundscape.play_event("journal")
					_animate_journal_signal()
			else:
				_set_status("Four warm reflections meet in the well. A stone stair descends through the water without wetting it.")
		"reading_mural":
			_set_status("A child's lesson shows a boat at the west mark, a lantern at the center, and reeds at the east mark.")
			RunState.set_story_flag("reading_mural_seen")
			_record_clue_animated("reading_order")
			_update_objective()
		"reading_tile_west", "reading_tile_center", "reading_tile_east":
			var reading_side: String = target.id.trim_prefix("reading_tile_")
			var reading_tiles: Dictionary = RunState.puzzle_progress.get("reading_tiles", READING_START)
			_set_status("The %s marker shows a %s." % [reading_side, _reading_mark_name(int(reading_tiles.get(reading_side, READING_START[reading_side])))])
		"reading_ledger":
			_reveal_world_memory("reading_lesson_seen", "reading_lesson", "A damp lesson book says children learned the safe river path from boat, lantern, and reeds. The final page is filled with small copied drawings.")
		"reading_return":
			_set_status("The doorway opens back onto the village square.")
		"archive_mural":
			_set_status("Three reflected paths are carved overhead: turn right, then down, then left.")
			RunState.set_story_flag("archive_mural_seen")
			if RunState.record_clue("archive_reflection_map"):
				Soundscape.play_event("journal")
				_animate_journal_signal()
		"archive_memory":
			_set_status("The pool reflects a sky that does not exist above the ruins.")
			if RunState.record_clue("archive_memory"):
				RunState.set_story_flag("archive_memory_seen")
				Soundscape.play_event("journal")
				_animate_journal_signal()
		"mirror_shard":
			_set_status("A silvered shard reflects the room as it might have looked before the roof fell.")
		"archive_last_entry":
			_reveal_world_memory("archive_last_entry_seen", "archive_last_entry", "The last catalogue line says: carry the books east; leave one lamp in the doorway.")
		"archive_hidden_ledger":
			_reveal_world_memory("archive_hidden_ledger_seen", "archive_hidden_register", "A loose leaf is headed “Borrowed skies.” Its last line asks the keeper to leave the east windows uncovered so the final light has somewhere to go.")
		"lens_west":
			_set_status("The western lens can turn through four resting positions.")
		"lens_center":
			_set_status("The central lens catches a thin thread of light.")
		"lens_east":
			_set_status("The eastern lens points toward the sealed stair.")
		"archive_stair":
			_set_status("A narrow stair descends toward a pale, starless glow. Another room waits below.")
		"map_chamber_mural":
			_set_status("A spring, an old bridge, and the village are linked by one safe route. The keeper marked them in the order a traveler would follow.")
			RunState.set_story_flag("map_chamber_mural_seen")
			_record_clue_animated("map_chamber_route")
			_update_objective()
		"map_route_spring", "map_route_bridge", "map_route_village":
			var route_progress := int(RunState.puzzle_progress.get("map_route_sequence", 0))
			_set_status("The %s is the %s mark in the keeper's route." % [target.id.trim_prefix("map_route_"), "first" if route_progress == 0 else ("second" if route_progress == 1 else "last")])
		"map_chamber_record":
			_reveal_world_memory("map_chamber_record_seen", "map_chamber_ledger", "The keeper's ledger records flood seasons, repaired bridges, and which homes shared lantern oil. On its last page, a blank map waits for a river that never came.")
		"map_chamber_return":
			_set_status("The stairs climb back to the archive pool.")
		"map_chamber_exit":
			_set_status("Beyond the arch, a still pool catches the light from below.")
		"gallery_mural":
			_set_status("The mural shows three reflections: west points north, the center points south, and east turns west.")
			RunState.set_story_flag("gallery_mural_seen")
			_record_clue_animated("gallery_reflection_map")
		"gallery_pool":
			_set_status("The pool holds no star except the one Beth's light seems to make.")
			RunState.set_story_flag("gallery_memory_seen")
			_record_clue_animated("gallery_memory")
		"gallery_figures":
			_reveal_world_memory("gallery_figures_seen", "gallery_procession", "Three faceless figures carry bowls and lanterns toward a path cut into the mountain.")
		"gallery_mirror_west", "gallery_mirror_center", "gallery_mirror_east":
			var mirror_name: String = target.id.trim_prefix("gallery_mirror_")
			_set_status("The %s mirror points %s." % [mirror_name, _direction_name(_get_gallery_orientation(mirror_name))])
		"gallery_stair":
			_set_status("The reflected path continues downward, though the water above it stays still.")
		"bell_mural":
			if RunState.story_flags.get("bell_echo_variant", false):
				_set_status("Five marks cross the garden wall. The last rain-line is pale, like an echo left by too many whispers.")
			else:
				_set_status("Four marks are cut into the garden wall: crescent, rain-line, seed, crescent.")
			RunState.set_story_flag("bell_mural_seen")
			_record_clue_animated("bell_garden_pattern")
		"bell_bench":
			_set_status("Beth settles on the warm stone. For a moment, the empty garden feels almost occupied.")
			RunState.set_story_flag("bell_bench_seen")
			_record_clue_animated("bell_bench_memory")
		"bell_keeper_names":
			_reveal_world_memory("bell_keeper_names_seen", "bell_keeper_list", "The keeper marked twelve names beside the bells. Four are crossed out; rain has softened the rest.")
		"court_bell_0", "court_bell_1", "court_bell_2", "court_bell_3":
			var bell_index := int(target.id.trim_prefix("court_bell_"))
			_set_status("A small bell bears the %s mark." % ["crescent", "rain-line", "seed", "crescent"][bell_index])
		"bell_door":
			_set_status("Beyond the arch, a lantern glows beside the path climbing toward the highland steps.")
		"high_steps_map":
			if RunState.story_flags.get("high_steps_echo_variant", false):
				_set_status("The map shows west and east, but a pale doubled arrow turns the middle vane south.")
			else:
				_set_status("A wind-worn map shows the three vanes pointing west, north, and east along the rising path.")
			RunState.set_story_flag("high_steps_map_seen")
			_record_clue_animated("high_steps_wind_map")
		"steps_vane_west", "steps_vane_center", "steps_vane_east":
			var vane_name: String = target.id.trim_prefix("steps_vane_")
			_set_status("The %s vane points %s." % [vane_name, _direction_name(_get_steps_vane_orientation(vane_name))])
		"steps_door":
			_set_status("The upper door stands open. Beyond it, the night sky presses close to the stone.")
		"high_steps_lantern":
			_reveal_world_memory("high_steps_lantern_seen", "high_steps_last_lantern", "The wick is neatly trimmed. Its note asks the last keeper to extinguish it after the descent.")
		"garden_gate":
			_set_status("The planted seed has opened a narrow arch beneath the old tree.")
		"garden_return":
			_set_status("The arch leads back to the orchard path whenever you are ready.")
		"garden_carving":
			_set_status("Three small marks hang above the seed bed: rain-line, seed, crescent.")
			RunState.set_story_flag("garden_carving_seen")
			_record_clue_animated("quiet_garden_order")
		"garden_bench":
			_set_status("The stone holds the last warmth of the day. Beth settles beside you, quiet and still.")
			RunState.set_story_flag("garden_bench_seen")
			_record_clue_animated("quiet_garden_bench")
		"garden_cup":
			_reveal_world_memory("garden_cup_seen", "quiet_garden_cup", "A clay cup sits upside down over a seed hollow, sheltering it from the rain.")
		"garden_chime_0", "garden_chime_1", "garden_chime_2":
			var chime_index := int(target.id.trim_prefix("garden_chime_"))
			_set_status("A small glass chime bears the %s mark." % ["rain-line", "seed", "crescent"][chime_index])
		"final_inscription":
			_set_status("The same unreadable marks from the first ruin. The medallion warms in your hand.")
		"observatory_chart":
			_set_status("The keeper's chart says: the crescent faces west; the rain-line faces north; the seed faces east.")
			RunState.set_story_flag("observatory_chart_seen")
			_record_clue_animated("observatory_star_chart")
		"observatory_arm_west", "observatory_arm_center", "observatory_arm_east":
			var arm_name: String = target.id.trim_prefix("observatory_arm_")
			var arms: Dictionary = RunState.puzzle_progress.get("observatory_arms", {})
			_set_status("The %s astrolabe arm points %s." % [arm_name, _direction_name(int(arms.get(arm_name, 0)))])

func _pick_up_target() -> void:
	var target := _nearest_target()
	if target.is_empty():
		_set_status("There is nothing nearby to carry.")
		return
	var item_id := ""
	match target.id:
		"medallion": item_id = "medallion"
		"moss_button": item_id = "moss_button"
		"stone_chip": item_id = "stone_chip"
		"old_bead": item_id = "old_bead"
		"seed_pod": item_id = "seed_pod"
		"river_glass": item_id = "river_glass"
		"mirror_shard": item_id = "mirror_shard"
		_:
			_set_status("That cannot be carried.")
			return
	if RunState.add_item(item_id):
		_on_item_collected(item_id)
	else:
		pending_pickup_id = item_id
		_open_inventory()
		_set_status("Your hands are full. Leave one keepsake to take this one.")

func _on_item_collected(item_id: String) -> void:
	var flag := "%s_found" % item_id
	RunState.set_story_flag(flag)
	Soundscape.play_event("pickup")
	if item_id == "medallion":
		_set_status("The medallion warms in your palm. The buried arch answers with a low vibration.")
	else:
		_set_status("You tuck away %s. Press %s to choose or inspect keepsakes." % [_item_name(item_id), _action_mark("inventory")])
	_update_hud()
	_update_objective()
	queue_redraw()

func _item_name(item_id: String) -> String:
	match item_id:
		"medallion": return "the medallion"
		"moss_button": return "the green brass button"
		"stone_chip": return "the broken inscription chip"
		"old_bead": return "the cloudy bead"
		"seed_pod": return "the pale seed pod"
		"river_glass": return "the river glass"
		"mirror_shard": return "the silvered glass shard"
		_: return item_id.replace("_", " ")

func _item_description(item_id: String) -> String:
	match item_id:
		"medallion": return "A worn disk. It wakes the buried arch and fits the hollow at the observatory."
		"moss_button": return "A keepsake from the crossing. One side bears a mark like a small sun."
		"stone_chip": return "A chipped fragment from the first inscription. Its marks remain unreadable."
		"old_bead": return "Cloudy glass with one blue fleck held inside. Beth circles it when you carry it."
		"seed_pod": return "A pale seed from the orchard's last bloom. It still holds a little warmth."
		"river_glass": return "A green shard made smooth by water that had been still for many years."
		"mirror_shard": return "A sliver of silvered glass. It catches a second, older image of each room."
		_: return "A small keepsake from the forgotten world."

func _activate_target() -> void:
	var target := _nearest_target()
	if target.is_empty():
		_set_status("Nothing nearby responds.")
		return
	if target.id == "arch" and RunState.inventory.has("medallion"):
		_cross_into_world()
	elif target.id.begins_with("resonator_"):
		_activate_resonator(target.id.trim_prefix("resonator_"))
	elif target.id == "gate" and RunState.story_flags.get("first_gate_open", false):
		_enter_orchard()
	elif target.id.begins_with("sluice_"):
		_toggle_sluice(target.id.trim_prefix("sluice_"))
	elif target.id == "waterworks_gate" and RunState.story_flags.get("orchard_water_restored", false):
		_enter_waterworks()
	elif target.id == "causeway_gate" and RunState.story_flags.get("orchard_water_restored", false):
		_enter_causeway()
	elif target.id.begins_with("causeway_step_"):
		_step_causeway(int(target.id.trim_prefix("causeway_step_")))
	elif target.id == "causeway_return":
		_return_to_orchard()
	elif target.id == "causeway_village_gate" and RunState.story_flags.get("causeway_solved", false):
		_enter_waterworks(true)
	elif target.id.begins_with("waterwheel_"):
		_ring_waterworks_wheel(target.id.trim_prefix("waterwheel_"))
	elif target.id == "waterworks_exit" and RunState.story_flags.get("waterworks_solved", false):
		_enter_empty_quarter()
	elif target.id == "waterworks_cistern_stair" and RunState.story_flags.get("waterworks_solved", false):
		_enter_cistern_vault()
	elif target.id.begins_with("cistern_valve_"):
		_turn_cistern_valve(target.id.trim_prefix("cistern_valve_"))
	elif target.id == "cistern_return":
		_return_to_waterworks()
	elif target.id.begins_with("quarter_slot_"):
		_rotate_quarter_slot(target.id.trim_prefix("quarter_slot_"))
	elif target.id.begins_with("village_gathering_") and ["bowl", "lamp", "bell"].has(target.id.trim_prefix("village_gathering_")):
		_activate_village_gathering(target.id.trim_prefix("village_gathering_"))
	elif target.id == "quarter_well_stair" and RunState.story_flags.get("quarter_household_restored", false):
		_enter_archive()
	elif target.id == "quarter_reading_door" and RunState.story_flags.get("quarter_household_restored", false):
		_enter_reading_room()
	elif target.id == "reading_return":
		_enter_empty_quarter()
	elif target.id.begins_with("reading_tile_"):
		_rotate_reading_tile(target.id.trim_prefix("reading_tile_"))
	elif target.id.begins_with("lens_"):
		_rotate_archive_lens(target.id.trim_prefix("lens_"))
	elif target.id == "archive_stair" and RunState.story_flags.get("archive_puzzle_solved", false):
		_enter_map_chamber()
	elif target.id == "archive_well_stair" and RunState.story_flags.get("archive_puzzle_solved", false):
		_enter_empty_quarter()
	elif target.id.begins_with("map_route_"):
		_trace_map_route(target.id.trim_prefix("map_route_"))
	elif target.id == "map_chamber_return":
		_return_to_archive()
	elif target.id == "map_chamber_exit" and RunState.story_flags.get("map_route_solved", false):
		_enter_gallery()
	elif target.id.begins_with("gallery_mirror_"):
		_rotate_gallery_mirror(target.id.trim_prefix("gallery_mirror_"))
	elif target.id == "gallery_stair" and RunState.story_flags.get("gallery_lights_solved", false):
		_enter_bell_court()
	elif target.id.begins_with("court_bell_"):
		_ring_court_bell(int(target.id.trim_prefix("court_bell_")))
	elif target.id == "bell_door" and RunState.story_flags.get("bell_court_solved", false):
		_enter_highland_refuge()
	elif target.id == "refuge_exit":
		_enter_high_steps()
	elif target.id == "refuge_return":
		_return_to_bell_court()
	elif target.id.begins_with("steps_vane_"):
		_rotate_steps_vane(target.id.trim_prefix("steps_vane_"))
	elif target.id.begins_with("observatory_arm_"):
		_rotate_observatory_arm(target.id.trim_prefix("observatory_arm_"))
	elif target.id == "steps_door" and RunState.story_flags.get("high_steps_aligned", false):
		_enter_observatory()
	elif target.id == "garden_gate" and RunState.story_flags.get("quiet_garden_restored", false):
		_enter_quiet_garden()
	elif target.id.begins_with("garden_chime_"):
		_ring_garden_chime(int(target.id.trim_prefix("garden_chime_")))
	elif target.id == "garden_return":
		_return_to_orchard()
	elif target.id == "seed_bed" or target.id == "final_inscription":
		_use_selected_item()
	else:
		_set_status("The stone remains still.")

func _use_selected_item() -> void:
	var target := _nearest_target()
	if target.is_empty():
		_set_status("Move closer to something that might accept a keepsake.")
		return
	var item_id := RunState.selected_item_id
	if item_id.is_empty():
		_set_status("Open the keepsakes page and choose something to use.")
		return
	if (target.id == "arch" or target.id == "final_inscription") and item_id == "medallion":
		if target.id == "arch":
			_cross_into_world()
		else:
			_begin_inscription_reveal()
		return
	if target.id == "arch" and item_id == "moss_button":
		_record_clue_animated("crossing_sun_mark")
		_set_status("The brass button fits a shallow mark. A small sun appears in the arch's stonework.")
		return
	if target.id == "seed_bed" and item_id == "seed_pod":
		RunState.remove_item(item_id)
		RunState.set_story_flag("quiet_garden_restored")
		_record_clue_animated("quiet_garden_memory")
		Soundscape.play_event("complete")
		_set_status("A small green shoot lifts through the soil. Beth rests beside it for a moment.")
		_update_objective()
		queue_redraw()
		return
	if (target.id == "inscription" or target.id == "final_inscription") and item_id == "stone_chip":
		_record_clue_animated("matching_stone_cuts")
		_set_status("The chip fits a narrow break in the old stone. Its marks align with the line, but remain unreadable.")
		return
	if target.id == "archive_mural" and item_id == "mirror_shard":
		_record_clue_animated("archive_second_image")
		_set_status("In the shard, a fourth path crosses the ceiling map: west points north, center east, and east south.")
		return
	if target.id == "archive_memory" and item_id == "river_glass":
		_record_clue_animated("river_glass_memory")
		_set_status("The green glass catches a thread of reflected water beneath the false sky.")
		return
	if target.id == "cistern_mural" and item_id == "river_glass":
		RunState.set_story_flag("cistern_glass_memory_seen")
		_record_clue_animated("cistern_glass_memory")
		_set_status("Through the green glass, a faint fourth waterline appears beneath the clock. Three small cups wait beside it.")
		return
	if target.id == "gallery_pool" and item_id == "mirror_shard":
		_record_clue_animated("gallery_second_sky")
		_set_status("The shard catches a second sky in the water: the same stars, but arranged around a missing place.")
		return
	if target.id == "resonator_water" and item_id == "old_bead":
		_record_clue_animated("bead_resonance")
		Soundscape.play_event("resonance")
		_set_status("The blue fleck answers the rain-line with a single, low note.")
		return
	_set_status("%s does not belong here." % _item_name(item_id).capitalize())

func _toggle_sluice(which: String) -> void:
	var states: Dictionary = RunState.puzzle_progress.get("orchard_valves", {})
	states[which] = (_valve_orientation(states.get(which, 0)) + 1) % 4
	RunState.puzzle_progress["orchard_valves"] = states
	RunState.save_game()
	var opened := 0
	for name in ["west", "north", "east"]:
		if _valve_orientation(states.get(name, 0)) == int(ORCHARD_SOLUTION[name]):
			opened += 1
	if opened == 3:
		Soundscape.play_event("complete")
		RunState.set_story_flag("orchard_water_restored")
		RunState.reset_local_hint_echo()
		beth.react_to_discovery()
		if RunState.record_clue("orchard_water_memory"):
			_animate_journal_signal()
		_set_status("Water threads through the channels and gathers in the basin. Hidden stones rise from the earth.")
		_update_objective()
	else:
		Soundscape.play_event("resonance")
		_set_status("Stone turns beneath your hand. %d of 3 channels now point toward the basin." % opened)
	queue_redraw()

func _ring_waterworks_wheel(which: String) -> void:
	if not RunState.story_flags.get("waterworks_map_seen", false):
		_set_status("The wheel groans against its frame. The channel map may tell you the keeper's order.")
		return
	var progress := int(RunState.puzzle_progress.get("waterworks_sequence", 0))
	if which == WATERWORKS_WHEEL_SEQUENCE[progress]:
		progress += 1
		RunState.puzzle_progress["waterworks_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("resonance")
		if progress >= WATERWORKS_WHEEL_SEQUENCE.size():
			RunState.set_story_flag("waterworks_solved")
			RunState.reset_local_hint_echo()
			_record_clue_animated("waterworks_gate_open")
			Soundscape.play_event("complete")
			_set_status("The wheels answer one another. Water lifts the old gate, and the dry village lane appears beyond it.")
		else:
			_set_status("The wheel settles into its notch. Water travels farther beneath the cistern.")
	else:
		progress = 1 if which == WATERWORKS_WHEEL_SEQUENCE[0] else 0
		RunState.puzzle_progress["waterworks_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("soft_fade")
		_set_status("The water slows and returns to its steady course. The wheels can be tried again.")
	queue_redraw()

func _turn_cistern_valve(which: String) -> void:
	if not RunState.story_flags.get("cistern_mural_seen", false):
		_set_status("The water clock might explain how the three channels should be balanced.")
		return
	var progress := clampi(int(RunState.puzzle_progress.get("cistern_sequence", 0)), 0, CISTERN_VALVE_SEQUENCE.size() - 1)
	if which == CISTERN_VALVE_SEQUENCE[progress]:
		progress += 1
		RunState.puzzle_progress["cistern_sequence"] = progress
		Soundscape.play_event("resonance")
		if progress == CISTERN_VALVE_SEQUENCE.size():
			RunState.set_story_flag("cistern_solved")
			RunState.reset_local_hint_echo()
			_record_clue_animated("cistern_basin_balanced")
			beth.react_to_discovery()
			Soundscape.play_event("complete")
			_set_status("The three channels settle into an even flow. A keeper's ledger becomes visible beside the cups.")
			_update_objective()
		else:
			_set_status("Water rises a little in the central clock. The channels hold their quiet rhythm.")
	else:
		progress = 1 if which == CISTERN_VALVE_SEQUENCE[0] else 0
		RunState.puzzle_progress["cistern_sequence"] = progress
		Soundscape.play_event("soft_fade")
		_set_status("The water settles back to its resting level. The valves can be tried again.")
	RunState.save_game()
	queue_redraw()

func _get_quarter_slots() -> Dictionary:
	var value: Variant = RunState.puzzle_progress.get("quarter_slots", {})
	var slots: Dictionary = value.duplicate(true) if value is Dictionary else {}
	for side in QUARTER_START:
		if not slots.has(side):
			slots[side] = QUARTER_START[side]
	return slots

func _rotate_quarter_slot(side: String) -> void:
	if not RunState.story_flags.get("quarter_mural_seen", false):
		_set_status("The worn carving around the well may explain these empty niches.")
		return
	var slots := _get_quarter_slots()
	slots[side] = (int(slots[side]) + 1) % QUARTER_OBJECTS.size()
	RunState.puzzle_progress["quarter_slots"] = slots
	RunState.save_game()
	var solved := true
	for house in QUARTER_SOLUTION:
		if int(slots[house]) != int(QUARTER_SOLUTION[house]):
			solved = false
			break
	if solved:
		RunState.set_story_flag("quarter_household_restored")
		RunState.reset_local_hint_echo()
		RunState.record_clue("quarter_household_restored")
		Soundscape.play_event("complete")
		beth.react_to_discovery()
		_set_status("The four small rooms seem to remember their shape. A stair appears beneath the well's reflection.")
		_update_objective()
	else:
		Soundscape.play_event("resonance")
		_set_status("The niche turns with a soft stone click. The other doorways remain dark.")
	queue_redraw()

func _village_gathering_clues_complete() -> bool:
	return RunState.story_flags.get("waterworks_bowl_record_seen", false) and RunState.story_flags.get("archive_last_entry_seen", false) and RunState.story_flags.get("bell_keeper_names_seen", false)

func _activate_village_gathering(mark: String) -> void:
	if not _village_gathering_clues_complete() or not RunState.story_flags.get("village_gathering_marks_seen", false):
		_set_status("The worn marks need the memories kept in the waterworks, Archive, and bell garden.")
		return
	var progress := int(RunState.puzzle_progress.get("village_gathering_sequence", 0))
	if progress < VILLAGE_GATHERING_SEQUENCE.size() and mark == VILLAGE_GATHERING_SEQUENCE[progress]:
		progress += 1
		RunState.puzzle_progress["village_gathering_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("resonance")
		if progress == VILLAGE_GATHERING_SEQUENCE.size():
			RunState.set_story_flag("village_gathering_solved")
			RunState.reset_local_hint_echo()
			_record_clue_animated("village_gathering_restored")
			beth.react_to_discovery()
			Soundscape.play_event("complete")
			_set_status("Three small lights gather in the well. A line of writing appears in the stone.")
			_update_objective()
		else:
			_set_status("The well answers with a quiet tone. Another mark waits around the rim.")
	else:
		RunState.puzzle_progress["village_gathering_sequence"] = 0
		RunState.save_game()
		Soundscape.play_event("soft_fade")
		_set_status("The tone fades. The three marks wait for another try.")
	queue_redraw()

func _rotate_reading_tile(side: String) -> void:
	if not RunState.story_flags.get("reading_mural_seen", false):
		_set_status("The lesson slate may explain the three study markers.")
		return
	var tiles: Dictionary = RunState.puzzle_progress.get("reading_tiles", READING_START).duplicate(true)
	tiles[side] = (int(tiles.get(side, READING_START[side])) + 1) % 3
	RunState.puzzle_progress["reading_tiles"] = tiles
	RunState.save_game()
	var solved := true
	for marker in READING_SOLUTION:
		if int(tiles.get(marker, READING_START[marker])) != int(READING_SOLUTION[marker]):
			solved = false
			break
	if solved:
		RunState.set_story_flag("reading_puzzle_solved")
		RunState.reset_local_hint_echo()
		RunState.record_clue("reading_markers_aligned")
		Soundscape.play_event("complete")
		beth.react_to_discovery()
		_set_status("The markers match the lesson slate. A narrow drawer opens beneath the desk.")
	else:
		Soundscape.play_event("resonance")
		_set_status("The marker turns with a wooden click. The lesson slate remains above it.")
	_update_objective()
	queue_redraw()

func _reading_mark_name(index: int) -> String:
	return ["boat", "lantern", "reeds"][posmod(index, 3)]

func _get_valve_orientation(which: String) -> int:
	var states: Dictionary = RunState.puzzle_progress.get("orchard_valves", {})
	return _valve_orientation(states.get(which, 0))

func _valve_orientation(value: Variant) -> int:
	if value is bool:
		return 1 if value else 0
	return posmod(int(value), 4)

func _direction_name(direction: int) -> String:
	return ["north", "east", "south", "west"][posmod(direction, 4)]

func _get_gallery_orientation(which: String) -> int:
	var mirrors: Dictionary = RunState.puzzle_progress.get("gallery_mirrors", {})
	return posmod(int(mirrors.get(which, 0)), 4)

func _get_steps_vane_orientation(which: String) -> int:
	var vanes: Dictionary = RunState.puzzle_progress.get("high_steps_vanes", {})
	return posmod(int(vanes.get(which, 0)), 4)

func _high_steps_solution() -> Dictionary:
	var solution: Dictionary = HIGH_STEPS_SOLUTION.duplicate()
	if RunState.story_flags.get("high_steps_echo_variant", false):
		solution["center"] = 2
	return solution

func _rotate_steps_vane(which: String) -> void:
	var vanes: Dictionary = RunState.puzzle_progress.get("high_steps_vanes", {"west": 0, "center": 0, "east": 0})
	vanes[which] = (int(vanes.get(which, 0)) + 1) % 4
	RunState.puzzle_progress["high_steps_vanes"] = vanes
	RunState.save_game()
	var aligned := true
	for name in ["west", "center", "east"]:
		if int(vanes.get(name, 0)) != int(_high_steps_solution()[name]):
			aligned = false
	if aligned:
		RunState.set_story_flag("high_steps_aligned")
		RunState.reset_local_hint_echo()
		beth.react_to_discovery()
		_record_clue_animated("high_steps_open_door")
		Soundscape.play_event("complete")
		_set_status("The wind moves through the three vanes at once. A lantern appears beside the upper door.")
		_update_objective()
	else:
		Soundscape.play_event("resonance")
		_set_status("The vane catches the wind, then turns away from the rising path.")
	queue_redraw()

func _rotate_observatory_arm(which: String) -> void:
	if not RunState.story_flags.get("observatory_chart_seen", false):
		_set_status("The astrolabe turns, but the keeper's chart may explain how the arms were set.")
		return
	var arms: Dictionary = RunState.puzzle_progress.get("observatory_arms", {"west": 0, "center": 0, "east": 0})
	arms[which] = (int(arms.get(which, 0)) + 1) % 4
	RunState.puzzle_progress["observatory_arms"] = arms
	RunState.save_game()
	var aligned := true
	for name in ["west", "center", "east"]:
		if int(arms.get(name, 0)) != int(OBSERVATORY_SOLUTION[name]):
			aligned = false
			break
	if aligned:
		RunState.set_story_flag("observatory_orrery_solved")
		RunState.reset_local_hint_echo()
		_record_clue_animated("observatory_weather_log")
		Soundscape.play_event("complete")
		_set_status("The astrolabe settles into the chart's pattern. A narrow drawer opens with a weather ledger inside.")
	else:
		Soundscape.play_event("resonance")
		_set_status("The brass arm catches the starlight, then rests against another mark.")
	queue_redraw()

func _rotate_gallery_mirror(which: String) -> void:
	var mirrors: Dictionary = RunState.puzzle_progress.get("gallery_mirrors", {"west": 0, "center": 0, "east": 0})
	mirrors[which] = (int(mirrors.get(which, 0)) + 1) % 4
	RunState.puzzle_progress["gallery_mirrors"] = mirrors
	RunState.save_game()
	var aligned := true
	for name in ["west", "center", "east"]:
		if int(mirrors.get(name, 0)) != int(GALLERY_SOLUTION[name]):
			aligned = false
	if aligned:
		RunState.set_story_flag("gallery_lights_solved")
		RunState.reset_local_hint_echo()
		beth.react_to_discovery()
		_record_clue_animated("gallery_hidden_stair")
		Soundscape.play_event("complete")
		_set_status("Three reflections meet beneath the pool. A stair appears inside the water's shadow.")
		_update_objective()
	else:
		Soundscape.play_event("resonance")
		_set_status("The reflected light shifts, then settles against the stone.")
	queue_redraw()

func _ring_court_bell(index: int) -> void:
	if not RunState.story_flags.get("bell_mural_seen", false):
		_set_status("The bell answers with a low note, but the old carving may tell you what to listen for.")
		Soundscape.play_event("resonance")
		return
	var sequence := _current_bell_sequence()
	var progress := int(RunState.puzzle_progress.get("bell_sequence", 0))
	var note: String = BELL_SEQUENCE[index]
	if progress < sequence.size() and note == sequence[progress]:
		progress += 1
		RunState.puzzle_progress["bell_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("resonance")
		if progress == sequence.size():
			RunState.set_story_flag("bell_court_solved")
			RunState.reset_local_hint_echo()
			beth.react_to_discovery()
			_record_clue_animated("bell_garden_answer")
			Soundscape.play_event("complete")
			_set_status("The five notes, including the borrowed echo, settle over the garden. Somewhere above, a stone door begins to open." if sequence.size() == 5 else "The four notes settle over the garden. Somewhere above, a stone door begins to open.")
			_update_objective()
		else:
			_set_status("A clear note hangs in the air. Beth listens for the next one.")
	else:
		progress = 1 if note == BELL_SEQUENCE[0] else 0
		RunState.puzzle_progress["bell_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("soft_fade")
		_set_status("The notes drift apart. The garden grows quiet again.")
	queue_redraw()

func _current_bell_sequence() -> Array[String]:
	var sequence: Array[String] = ["moon", "water", "seed", "moon"]
	if RunState.story_flags.get("bell_echo_variant", false):
		sequence.append("water")
	return sequence

func _step_causeway(step_index: int) -> void:
	if not RunState.story_flags.get("causeway_marks_seen", false):
		_set_status("The stepping stones stay quiet. Study the waterlines on the shore first.")
		return
	var progress := int(RunState.puzzle_progress.get("causeway_sequence", 0))
	if progress < CAUSEWAY_STEP_PATTERN.size() and step_index == int(CAUSEWAY_STEP_PATTERN[progress]):
		progress += 1
		RunState.puzzle_progress["causeway_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("resonance")
		var next_order_index := mini(progress, CAUSEWAY_STEP_PATTERN.size() - 1)
		await _hop_causeway_to(int(CAUSEWAY_STEP_PATTERN[next_order_index]))
		if progress == CAUSEWAY_STEP_PATTERN.size():
			RunState.set_story_flag("causeway_solved")
			RunState.reset_local_hint_echo()
			beth.react_to_discovery()
			_record_clue_animated("causeway_crossing_open")
			Soundscape.play_event("complete")
			_set_status("The last stone answers. A line of pale light joins shore to gate.")
			_update_objective()
		else:
			_set_status("The stone answers with a soft note. Follow the waterlines onward.")
	else:
		progress = 1 if step_index == int(CAUSEWAY_STEP_PATTERN[0]) else 0
		RunState.puzzle_progress["causeway_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("soft_fade")
		await _hop_causeway_to(int(CAUSEWAY_STEP_PATTERN[progress]))
		_set_status("The note fades into the water. The stones wait without hurry.")
	queue_redraw()

func _hop_causeway_to(stone_index: int) -> void:
	transitioning = true
	await traveler.hop_to(CAUSEWAY_STONE_POSITIONS[stone_index], _motion_duration(0.28))
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.save_game()
	transitioning = false

func _ring_garden_chime(index: int) -> void:
	if not RunState.story_flags.get("garden_carving_seen", false):
		_set_status("The glass answers softly. The little carving may tell you how the notes belong together.")
		Soundscape.play_event("resonance")
		return
	var progress := int(RunState.puzzle_progress.get("quiet_garden_sequence", 0))
	var note: String = QUIET_GARDEN_SEQUENCE[index]
	if progress < QUIET_GARDEN_SEQUENCE.size() and note == QUIET_GARDEN_SEQUENCE[progress]:
		progress += 1
		RunState.puzzle_progress["quiet_garden_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("resonance")
		if progress == QUIET_GARDEN_SEQUENCE.size():
			RunState.set_story_flag("quiet_garden_song_solved")
			RunState.reset_local_hint_echo()
			beth.react_to_discovery()
			_record_clue_animated("quiet_garden_song")
			Soundscape.play_event("complete")
			_set_status("A low chord passes through the basin. One white flower opens beside the new seedling.")
			_update_objective()
		else:
			_set_status("A clear note hangs among the leaves. Beth waits for the next one.")
	else:
		progress = 1 if note == QUIET_GARDEN_SEQUENCE[0] else 0
		RunState.puzzle_progress["quiet_garden_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("soft_fade")
		_set_status("The notes drift apart in the leaves. The garden grows quiet again.")
	queue_redraw()

func _enter_orchard() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.45))
	await fade_out.finished
	phase = "orchard"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 248)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("reached_orchard")
	beth.global_position = Vector2(337, 232)
	beth.visible = true
	beth.awake = true
	camera_target_rotation = 0.0
	_set_status("The path descends into a quiet orchard, where dry channels cross the grass.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.65))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_quiet_garden() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "quiet_garden"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 250)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("in_quiet_garden")
	beth.global_position = Vector2(337, 232)
	beth.visible = true
	beth.awake = true
	_set_status("The arch opens onto a little garden protected from the wind. Three glass chimes stir above the new seedling.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _return_to_orchard() -> void:
	if transitioning:
		return
	var returned_from_causeway := phase == "reed_causeway"
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.35))
	await fade_out.finished
	phase = "orchard"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(548, 102) if returned_from_causeway else Vector2(182, 242)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("in_quiet_garden", false)
	RunState.set_story_flag("in_causeway", false)
	beth.global_position = Vector2(560, 85) if returned_from_causeway else Vector2(196, 225)
	_set_status("The orchard path is just as you left it. The reed causeway remains open." if returned_from_causeway else "The orchard path is just as you left it. The hidden garden remains open behind you.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.5))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_causeway() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "reed_causeway"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 310)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("in_causeway")
	beth.global_position = Vector2(337, 292)
	beth.visible = true
	beth.awake = true
	_set_status("The reed path follows still water toward the darkened village gate.")
	Soundscape.play_event("soft_fade")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_waterworks(from_causeway: bool = false) -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "waterworks"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(554, 260) if from_causeway else Vector2(94, 280)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("reached_waterworks")
	RunState.set_story_flag("in_causeway", false)
	beth.global_position = Vector2(531, 242) if from_causeway else Vector2(111, 262)
	beth.visible = true
	beth.awake = true
	_set_status("The reed path joins a roofless cistern. Water keeps moving beneath the old stone arches." if from_causeway else "The restored channel pours into a roofless cistern. Three wheels mark its quiet rhythm.")
	Soundscape.play_event("soft_fade")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_cistern_vault() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "cistern_vault"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 284)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("in_cistern_vault")
	RunState.save_game()
	beth.global_position = Vector2(337, 264)
	beth.visible = true
	beth.awake = true
	_set_status("Below the cistern, a water clock keeps time for three quiet channels.")
	Soundscape.play_event("soft_fade")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _return_to_waterworks() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.35))
	await fade_out.finished
	RunState.set_story_flag("in_cistern_vault", false)
	phase = "waterworks"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(82, 164)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.save_game()
	_set_status("The roofless waterworks opens again toward the village and orchard.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.5))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_empty_quarter() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "empty_quarter"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 286)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("in_causeway", false)
	RunState.set_story_flag("in_reading_room", false)
	RunState.set_story_flag("reached_quarter")
	beth.global_position = Vector2(337, 270)
	beth.visible = true
	beth.awake = true
	if RunState.story_flags.get("archive_puzzle_solved", false):
		beth.investigate(Vector2(320, 166))
	Soundscape.play_event("soft_fade")
	if RunState.story_flags.get("archive_puzzle_solved", false):
		_set_status("The square gathers again around the well. Its reflection holds a pale, starless sky.")
	else:
		_set_status("An empty village square gathers around a well. Four dark doorways face the water.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_reading_room() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "reading_room"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 284)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("in_reading_room")
	beth.global_position = Vector2(337, 265)
	beth.visible = true
	beth.awake = true
	_set_status("A small reading room opens above the village square. An old lesson waits on the desk.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_archive() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "archive"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 248)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("reached_archive")
	camera_target_rotation = 0.0
	_set_status("The archive holds its breath beneath the orchard. Beth's light doubles in the still water.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _trace_map_route(node_name: String) -> void:
	if not RunState.story_flags.get("map_chamber_mural_seen", false):
		_set_status("The route marks are difficult to follow until you study the map.")
		return
	var progress := clampi(int(RunState.puzzle_progress.get("map_route_sequence", 0)), 0, MAP_ROUTE_SEQUENCE.size() - 1)
	if node_name == MAP_ROUTE_SEQUENCE[progress]:
		progress += 1
		RunState.puzzle_progress["map_route_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("resonance")
		if progress == MAP_ROUTE_SEQUENCE.size():
			RunState.set_story_flag("map_route_solved")
			RunState.reset_local_hint_echo()
			_record_clue_animated("map_chamber_route_open")
			beth.react_to_discovery()
			Soundscape.play_event("complete")
			_set_status("The three route marks glow in sequence. The stone arch opens onto the still gallery pool.")
			_update_objective()
		else:
			_set_status("A small light follows the river onward. The route remembers the next place.")
	else:
		progress = 1 if node_name == MAP_ROUTE_SEQUENCE[0] else 0
		RunState.puzzle_progress["map_route_sequence"] = progress
		RunState.save_game()
		Soundscape.play_event("soft_fade")
		_set_status("The route's light returns to the spring. The map waits without hurry.")
	RunState.save_game()
	queue_redraw()

func _enter_map_chamber() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "map_chamber"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 282)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("reached_map_chamber")
	RunState.set_story_flag("in_map_chamber")
	RunState.save_game()
	camera_target_rotation = 0.0
	_set_status("A broad map of the valley waits beneath the archive. A stone arch seals the far wall.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _return_to_archive() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.35))
	await fade_out.finished
	RunState.set_story_flag("in_map_chamber", false)
	phase = "archive"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 185)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.save_game()
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.5))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_gallery() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "gallery"
	RunState.set_story_flag("in_map_chamber", false)
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 248)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("reached_gallery")
	RunState.save_game()
	beth.global_position = Vector2(337, 232)
	beth.visible = true
	beth.awake = true
	camera_target_rotation = 0.0
	_set_status("Beneath the archive, a second room opens around a still, starless pool.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_bell_court() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "bell_court"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 250)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("reached_bell_court")
	RunState.set_story_flag("bell_echo_variant", RunState.hint_uses >= 8)
	beth.global_position = Vector2(337, 234)
	beth.visible = true
	beth.awake = true
	camera_target_rotation = 0.0
	_set_status("The stair ends in a small garden where four bells hang beneath an open sky.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.65))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_highland_refuge() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "highland_refuge"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 284)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("in_highland_refuge")
	RunState.set_story_flag("reached_highland_refuge")
	beth.global_position = Vector2(337, 265)
	beth.visible = true
	beth.awake = true
	_set_status("The bells fade behind you. A small refuge waits beside the climbing path.")
	Soundscape.play_event("soft_fade")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.6))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _return_to_bell_court() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.35))
	await fade_out.finished
	RunState.set_story_flag("in_highland_refuge", false)
	phase = "bell_court"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 250)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.save_game()
	_set_status("The bell garden is quiet beneath the open sky.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.5))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_high_steps() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	RunState.set_story_flag("in_highland_refuge", false)
	phase = "high_steps"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 252)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("reached_high_steps")
	RunState.set_story_flag("high_steps_echo_variant", RunState.hint_uses >= 12)
	RunState.save_game()
	beth.global_position = Vector2(337, 234)
	beth.visible = true
	beth.awake = true
	_set_status("The bell notes carry you up a narrow hill path. Three vanes turn above the valley.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.65))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_observatory() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.4))
	await fade_out.finished
	phase = "observatory"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(320, 250)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("reached_observatory")
	camera_target_rotation = 0.0
	_set_status("The stair opens beneath a roofless observatory. The old inscription waits in the starlight.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.7))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _begin_inscription_reveal() -> void:
	if transitioning:
		return
	transitioning = true
	RunState.set_journey_active(false)
	traveler.set_movement_enabled(false)
	RunState.save_game()
	inscription_panel = PanelContainer.new()
	inscription_panel.position = Vector2(24, 180)
	inscription_panel.size = Vector2(272, 56)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#101d25")
	panel_style.border_color = Color("#b8c8c0")
	panel_style.set_border_width_all(1)
	inscription_panel.add_theme_stylebox_override("panel", panel_style)
	inscription_label = _new_label("", 10, Color("#e4e0cc"), Vector2.ZERO, Vector2.ZERO)
	inscription_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inscription_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inscription_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inscription_panel.add_child(inscription_label)
	hud.add_child(inscription_panel)
	var open_tween := create_tween()
	open_tween.tween_property(inscription_panel, "position:y", 62.0, _motion_duration(0.55)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await open_tween.finished
	Soundscape.play_event("journal")
	var reveal_tween := create_tween()
	for count in range(1, FINAL_INSCRIPTION.length() + 1):
		reveal_tween.tween_callback(_show_inscription_reveal.bind(count))
		reveal_tween.tween_interval(_motion_duration(0.14))
	reveal_tween.tween_interval(2.4)
	reveal_tween.tween_callback(_finish_inscription_reveal)

func _show_inscription_reveal(revealed_count: int) -> void:
	var displayed := ""
	var symbols := ["?", "/", "~", "+", ":", "#"]
	for index in range(FINAL_INSCRIPTION.length()):
		var character := FINAL_INSCRIPTION.substr(index, 1)
		if index < revealed_count or character == " " or character == ".":
			displayed += character
		else:
			displayed += symbols[(index + revealed_count) % symbols.size()]
	inscription_label.text = displayed

func _finish_inscription_reveal() -> void:
	RunState.set_journey_active(false)
	RunState.set_story_flag("ending_revealed")
	RunState.record_clue("message_from_past")
	beth.react_to_discovery()
	Soundscape.play_event("complete")
	_set_status("Beth turns toward the medallion. The last mark gives a faint pulse beneath your hand.")
	queue_redraw()
	var ending_tween := create_tween()
	ending_tween.tween_interval(3.0)
	ending_tween.tween_callback(func() -> void: get_tree().change_scene_to_file("res://src/scenes/ending.tscn"))

func _rotate_archive_lens(which: String) -> void:
	var lenses: Dictionary = RunState.puzzle_progress.get("archive_lenses", {
		"west": 0, "center": 0, "east": 0
	})
	lenses[which] = (int(lenses.get(which, 0)) + 1) % 4
	RunState.puzzle_progress["archive_lenses"] = lenses
	RunState.save_game()
	Soundscape.play_event("resonance")
	if not RunState.story_flags.get("archive_puzzle_solved", false):
		var aligned := true
		for name in ["west", "center", "east"]:
			if int(lenses.get(name, 0)) != int(ARCHIVE_SOLUTION[name]):
				aligned = false
		if aligned:
			RunState.set_story_flag("archive_puzzle_solved")
			RunState.record_clue("archive_hidden_stair")
			RunState.reset_local_hint_echo()
			beth.react_to_discovery()
			Soundscape.play_event("complete")
			_set_status("The reflections meet. A stair appears where the light touches the floor.")
			_update_objective()
		else:
			_set_status("The light slips across the water and settles into another angle.")
	else:
		var fourth_path_aligned := true
		for name in ["west", "center", "east"]:
			if int(lenses.get(name, 0)) != int(ARCHIVE_FOURTH_PATH_SOLUTION[name]):
				fourth_path_aligned = false
		if fourth_path_aligned:
			RunState.set_story_flag("archive_fourth_path_solved")
			_record_clue_animated("archive_fourth_path")
			beth.react_to_discovery()
			Soundscape.play_event("complete")
			_set_status("A narrow beam slips beneath the shelf. Something pale rests in the newly lit space.")
		else:
			_set_status("The extra reflection skims the pool and falls away.")
	queue_redraw()

func _activate_resonator(symbol: String) -> void:
	if not RunState.story_flags.get("beth_awake", false):
		_set_status("A soft pulse travels through the stone, then fades. Something is still asleep nearby.")
		return
	if not RunState.story_flags.get("inscription_seen", false):
		_set_status("The old line shifts without becoming readable. Study the wall before attuning the stones.")
		return
	if not RunState.story_flags.get("resonance_clue_seen", false):
		_set_status("The marks answer, but their order is unclear. Look around the old wall.")
		return
	var progress := int(RunState.puzzle_progress.get("first_gate", 0))
	if symbol == PUZZLE_ORDER[progress]:
		Soundscape.play_event("resonance")
		progress += 1
		RunState.puzzle_progress["first_gate"] = progress
		RunState.save_game()
		if progress >= PUZZLE_ORDER.size():
			Soundscape.play_event("complete")
			RunState.set_story_flag("first_gate_open")
			RunState.reset_local_hint_echo()
			beth.react_to_discovery()
			_set_status("The three notes join. Stone eases aside, revealing a path beneath the gate.")
			_update_objective()
			queue_redraw()
		else:
			var next_name: String = ["crescent", "rain-line", "seed"][progress]
			_set_status("A low note settles into the wall. The next mark is the %s." % next_name)
	else:
		Soundscape.play_event("soft_fade")
		RunState.puzzle_progress["first_gate"] = 0
		RunState.save_game()
		_set_status("The note fades gently. The stones settle back into silence.")
	queue_redraw()

func _wake_beth() -> void:
	RunState.set_story_flag("beth_awake")
	beth.wake()
	beth.react_to_discovery()
	beth.global_position = Vector2(48, 230)
	Soundscape.play_event("wake")
	_set_status("The little orb blinks awake, circles your shoulder, and answers with a curious chime.")
	_update_objective()
	queue_redraw()

func _cross_into_world() -> void:
	if transitioning:
		return
	Soundscape.play_event("complete")
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, _motion_duration(0.45))
	await fade_out.finished
	phase = "ruins"
	Soundscape.set_area(phase)
	traveler.global_position = Vector2(285, 248)
	traveler.movement_bounds = Rect2(22, 40, 596, 300)
	RunState.update_checkpoint(phase, traveler.global_position)
	RunState.set_story_flag("crossed_into_world")
	beth.visible = true
	beth.global_position = Vector2(48, 230)
	beth.awake = false
	_set_status("On the other side, a small blue-white light sleeps among the ruins.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, _motion_duration(0.65))
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _open_journal() -> void:
	traveler.set_movement_enabled(false)
	RunState.set_journey_active(false)
	journal_panel = PanelContainer.new()
	journal_panel.position = Vector2(36, 180)
	journal_panel.size = Vector2(248, 138)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#17252a")
	style.border_color = Color("#728781")
	style.set_border_width_all(1)
	journal_panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	journal_panel.add_child(column)
	var title := _new_label("FIELD NOTES", 9, Color("#e2ddc9"), Vector2.ZERO, Vector2.ZERO)
	column.add_child(title)
	var hint := _new_label("Clues settle onto the page. Their meanings are yours to find.", 6, Color("#b8c2b9"), Vector2.ZERO, Vector2.ZERO)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(hint)
	var divider := HSeparator.new()
	column.add_child(divider)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(224, 74)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var entries := VBoxContainer.new()
	entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entries.add_theme_constant_override("separation", 4)
	scroll.add_child(entries)
	if RunState.journal_entries.is_empty():
		entries.add_child(_new_label("No clues recorded yet.", 7, Color("#d2d5c8"), Vector2.ZERO, Vector2.ZERO))
	else:
		for entry_index in range(RunState.journal_entries.size() - 1, -1, -1):
			var clue_id: String = RunState.journal_entries[entry_index]
			var entry := _new_label("•  " + _clue_text(clue_id), 7, Color("#d2d5c8"), Vector2.ZERO, Vector2.ZERO)
			entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			entries.add_child(entry)
	var close_hint := _new_label("%s / %s  close" % [_action_mark("journal"), _action_mark("pause")], 6, Color("#94a39e"), Vector2.ZERO, Vector2.ZERO)
	column.add_child(close_hint)
	hud.add_child(journal_panel)
	var tween := create_tween()
	tween.tween_property(journal_panel, "position:y", 20.0, _motion_duration(0.28)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _close_journal() -> void:
	var panel := journal_panel
	journal_panel = null
	var tween := create_tween()
	tween.tween_property(panel, "position:y", 180.0, _motion_duration(0.2))
	tween.tween_callback(func() -> void:
		panel.queue_free()
		if is_instance_valid(traveler) and not transitioning:
			traveler.set_movement_enabled(true)
			RunState.set_journey_active(true)
	)

func _open_inventory() -> void:
	if inventory_panel != null or transitioning:
		return
	traveler.set_movement_enabled(false)
	RunState.set_journey_active(false)
	inventory_panel = PanelContainer.new()
	inventory_panel.position = Vector2(34, 180)
	inventory_panel.size = Vector2(252, 136)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#17252a")
	style.border_color = Color("#728781")
	style.set_border_width_all(1)
	inventory_panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	inventory_panel.add_child(column)
	column.add_child(_new_label("KEEPSAKES  %d / %d" % [RunState.inventory.size(), RunState.INVENTORY_LIMIT], 8, Color("#e2ddc9"), Vector2.ZERO, Vector2.ZERO))
	inventory_description_label = _new_label("Choose an item to read its note.", 6, Color("#b8c2b9"), Vector2.ZERO, Vector2(232, 18))
	inventory_description_label.custom_minimum_size = Vector2(232, 18)
	inventory_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(inventory_description_label)
	if pending_pickup_id != "":
		column.add_child(_new_label("Leave one keepsake to take %s:" % _item_name(pending_pickup_id), 6, Color("#d5c59a"), Vector2.ZERO, Vector2.ZERO))
	if RunState.inventory.is_empty():
		column.add_child(_new_label("Your hands are empty.", 7, Color("#d2d5c8"), Vector2.ZERO, Vector2.ZERO))
	else:
		for item_id in RunState.inventory:
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 3)
			var item_button := Button.new()
			item_button.text = ("● " if item_id == RunState.selected_item_id else "  ") + _item_name(item_id)
			item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			item_button.custom_minimum_size = Vector2(154, 14 + (4 if RunState.settings.get("large_text", false) else 0))
			item_button.add_theme_font_size_override("font_size", 9 if RunState.settings.get("large_text", false) else 7)
			item_button.pressed.connect(_select_inventory_item.bind(item_id))
			row.add_child(item_button)
			var item_action := Button.new()
			item_action.custom_minimum_size = Vector2(58, 14 + (4 if RunState.settings.get("large_text", false) else 0))
			item_action.add_theme_font_size_override("font_size", 8 if RunState.settings.get("large_text", false) else 6)
			if pending_pickup_id != "":
				item_action.text = "Story item" if item_id == "medallion" else "Swap"
				if item_id != "medallion":
					item_action.pressed.connect(_swap_pending_item.bind(item_id))
			else:
				item_action.text = "Keep" if item_id == "medallion" else "Drop"
				if item_id != "medallion":
					item_action.pressed.connect(_drop_inventory_item.bind(item_id))
			row.add_child(item_action)
			column.add_child(row)
	var close := Button.new()
	close.text = "%s / %s  close" % [_action_mark("inventory"), _action_mark("pause")]
	close.custom_minimum_size = Vector2(224, 15 + (4 if RunState.settings.get("large_text", false) else 0))
	close.add_theme_font_size_override("font_size", 8 if RunState.settings.get("large_text", false) else 6)
	close.pressed.connect(_close_inventory)
	column.add_child(close)
	hud.add_child(inventory_panel)
	if RunState.inventory.has(RunState.selected_item_id):
		inventory_description_label.text = _item_description(RunState.selected_item_id)
	var tween := create_tween()
	tween.tween_property(inventory_panel, "position:y", 20.0, _motion_duration(0.24)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _close_inventory() -> void:
	var panel := inventory_panel
	if panel == null:
		return
	inventory_panel = null
	inventory_description_label = null
	if pending_pickup_id != "":
		pending_pickup_id = ""
	var tween := create_tween()
	tween.tween_property(panel, "position:y", 180.0, _motion_duration(0.16))
	tween.tween_callback(func() -> void:
		panel.queue_free()
		if is_instance_valid(traveler) and not transitioning:
			traveler.set_movement_enabled(true)
			RunState.set_journey_active(true)
	)

func _select_inventory_item(item_id: String) -> void:
	RunState.select_item(item_id)
	if is_instance_valid(inventory_description_label):
		inventory_description_label.text = _item_description(item_id)
		for child in inventory_panel.get_child(0).get_children():
			if child is HBoxContainer:
				var item_button := child.get_child(0) as Button
				var displayed_name: String = item_button.text.trim_prefix("● ").strip_edges()
				item_button.text = ("● " if displayed_name == _item_name(item_id) else "  ") + displayed_name
	_update_hud()

func _drop_inventory_item(item_id: String) -> void:
	RunState.remove_item(item_id)
	RunState.set_story_flag("%s_found" % item_id, false)
	_set_status("You leave %s where someone else may find it." % _item_name(item_id))
	_close_inventory()

func _swap_pending_item(old_item_id: String) -> void:
	if pending_pickup_id.is_empty():
		return
	var new_item_id := pending_pickup_id
	if RunState.replace_item(old_item_id, new_item_id):
		pending_pickup_id = ""
		RunState.set_story_flag("%s_found" % old_item_id, false)
		_on_item_collected(new_item_id)
		_close_inventory()

func _open_hint_panel() -> void:
	if hint_panel != null or transitioning:
		return
	if not RunState.story_flags.get("beth_awake", false):
		_set_status("The quiet offers no reply yet.")
		return
	traveler.set_movement_enabled(false)
	RunState.set_journey_active(false)
	hint_panel = PanelContainer.new()
	hint_panel.position = Vector2(45, 180)
	hint_panel.size = Vector2(230, 104)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#17252a")
	style.border_color = Color("#789394")
	style.set_border_width_all(1)
	hint_panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	hint_panel.add_child(column)
	column.add_child(_new_label("BETH'S WHISPER", 9, Color("#d6f0f2"), Vector2.ZERO, Vector2.ZERO))
	column.add_child(_new_label("Choose how much help you want.", 6, Color("#b8c5c2"), Vector2.ZERO, Vector2.ZERO))
	column.add_child(_new_label("The old stones remember each whisper.", 6, Color("#a999b2"), Vector2.ZERO, Vector2.ZERO))
	_add_hint_button(column, "1  A gentle nudge", 1)
	_add_hint_button(column, "2  A clearer clue", 2)
	_add_hint_button(column, "3  Nearly the answer", 3)
	var close_hint := _new_label("%s / %s  close" % [_action_mark("hints"), _action_mark("pause")], 6, Color("#94a39e"), Vector2.ZERO, Vector2.ZERO)
	column.add_child(close_hint)
	hud.add_child(hint_panel)
	var tween := create_tween()
	tween.tween_property(hint_panel, "position:y", 37.0, _motion_duration(0.28)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _add_hint_button(container: VBoxContainer, text: String, level: int) -> void:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(210, 15)
	button.add_theme_font_size_override("font_size", 9 if RunState.settings.get("large_text", false) else 7)
	button.add_theme_color_override("font_color", Color("#d5e4df"))
	button.pressed.connect(_give_hint.bind(level))
	container.add_child(button)

func _close_hint_panel() -> void:
	var panel := hint_panel
	hint_panel = null
	var tween := create_tween()
	tween.tween_property(panel, "position:y", 180.0, _motion_duration(0.18))
	tween.tween_callback(func() -> void:
		panel.queue_free()
		if is_instance_valid(traveler) and not transitioning:
			traveler.set_movement_enabled(true)
			RunState.set_journey_active(true)
	)

func _give_hint(level: int) -> void:
	var echo_cost := RunState.add_hint(level)
	beth.react_to_hint(echo_cost)
	var hint_text := HINT_CATALOG.get_hint(phase, level, RunState.story_flags, RunState.journal_entries)
	_set_status(hint_text)
	Soundscape.play_event("hint")
	_close_hint_panel()
	queue_redraw()

func _open_pause_menu() -> void:
	if pause_panel != null or transitioning:
		return
	traveler.set_movement_enabled(false)
	RunState.set_journey_active(false)
	pause_panel = PanelContainer.new()
	pause_panel.position = Vector2(55, 180)
	pause_panel.size = Vector2(210, 84)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#17252a")
	style.border_color = Color("#728781")
	style.set_border_width_all(1)
	pause_panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	pause_panel.add_child(column)
	column.add_child(_new_label("PAUSED", 9, Color("#e2ddc9"), Vector2.ZERO, Vector2.ZERO))
	var resume := Button.new()
	resume.text = "Resume journey"
	resume.custom_minimum_size = Vector2(190, 17 + (4 if RunState.settings.get("large_text", false) else 0))
	resume.add_theme_font_size_override("font_size", 10 if RunState.settings.get("large_text", false) else 8)
	resume.pressed.connect(_close_pause_menu)
	column.add_child(resume)
	var save_and_leave := Button.new()
	save_and_leave.text = "Save and return to title"
	save_and_leave.custom_minimum_size = Vector2(190, 17 + (4 if RunState.settings.get("large_text", false) else 0))
	save_and_leave.add_theme_font_size_override("font_size", 10 if RunState.settings.get("large_text", false) else 8)
	save_and_leave.pressed.connect(_save_and_return_to_title)
	column.add_child(save_and_leave)
	hud.add_child(pause_panel)
	resume.call_deferred("grab_focus")
	var tween := create_tween()
	tween.tween_property(pause_panel, "position:y", 49.0, _motion_duration(0.22)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _close_pause_menu() -> void:
	var panel := pause_panel
	if panel == null:
		return
	pause_panel = null
	var tween := create_tween()
	tween.tween_property(panel, "position:y", 180.0, _motion_duration(0.16))
	tween.tween_callback(func() -> void:
		panel.queue_free()
		if is_instance_valid(traveler) and not transitioning:
			traveler.set_movement_enabled(true)
			RunState.set_journey_active(true)
	)

func _save_and_return_to_title() -> void:
	RunState.set_journey_active(false)
	RunState.save_game()
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")

func _animate_journal_signal() -> void:
	if is_instance_valid(inventory_label):
		var tween := create_tween()
		tween.tween_property(inventory_label, "modulate", Color("#e3dfb5"), _motion_duration(0.12))
		tween.tween_property(inventory_label, "modulate", Color("#bdc8bb"), _motion_duration(0.5))

func _record_clue_animated(clue_id: String) -> void:
	if RunState.record_clue(clue_id):
		Soundscape.play_event("journal")
		beth.react_to_discovery()
		_animate_journal_signal()
	queue_redraw()

func _reveal_world_memory(flag_name: String, clue_id: String, message: String) -> void:
	RunState.set_story_flag(flag_name)
	_record_clue_animated(clue_id)
	_set_status(message)

func _clue_text(clue_id: String) -> String:
	return JOURNAL_CATALOG.get_text(clue_id, RunState.story_flags)

func _set_status(message: String) -> void:
	status_text = message
	if status_label != null:
		status_label.text = message

func _update_objective() -> void:
	if objective_label == null:
		return
	match phase:
		"crossing":
			objective_label.text = "Find the medallion" if not RunState.story_flags.get("medallion_found", false) else "Approach the buried arch"
		"ruins":
			if not RunState.story_flags.get("beth_awake", false):
				objective_label.text = "Follow the small light"
			elif not RunState.story_flags.get("inscription_seen", false):
				objective_label.text = "Study the unreadable inscription"
			elif not RunState.story_flags.get("first_gate_open", false):
				objective_label.text = "Listen for the old stones"
			else:
				objective_label.text = "Pass through the opened gate"
		"orchard":
			objective_label.text = "Bring water back to the orchard" if not RunState.story_flags.get("orchard_water_restored", false) else "Follow the channel into the old waterworks"
		"waterworks":
			if not RunState.story_flags.get("waterworks_map_seen", false):
				objective_label.text = "Study the channel map"
			elif not RunState.story_flags.get("waterworks_solved", false):
				objective_label.text = "Follow the four-mark wheel pattern"
			else:
				objective_label.text = "Enter the empty quarter"
		"cistern_vault":
			if not RunState.story_flags.get("cistern_mural_seen", false):
				objective_label.text = "Study the lower cistern's water clock"
			elif not RunState.story_flags.get("cistern_solved", false):
				objective_label.text = "Balance the three channels"
			elif not RunState.story_flags.get("cistern_record_seen", false):
				objective_label.text = "Read the water keeper's ledger or return"
			else:
				objective_label.text = "Return to the waterworks"
		"reed_causeway":
			if not RunState.story_flags.get("causeway_marks_seen", false):
				objective_label.text = "Study the shoreline marks"
			elif not RunState.story_flags.get("causeway_solved", false):
				objective_label.text = "Follow the five-stone rhythm"
			else:
				objective_label.text = "Follow the covered channel or return"
		"empty_quarter":
			if not RunState.story_flags.get("quarter_mural_seen", false):
				objective_label.text = "Read the well carving"
			elif not RunState.story_flags.get("quarter_household_restored", false):
				objective_label.text = "Return each household object to its doorway"
			elif RunState.story_flags.get("archive_puzzle_solved", false):
				objective_label.text = "Follow the well's reflection into the archive"
			else:
				objective_label.text = "Descend into the archive"
		"reading_room":
			if not RunState.story_flags.get("reading_mural_seen", false):
				objective_label.text = "Study the children's lesson slate"
			elif not RunState.story_flags.get("reading_puzzle_solved", false):
				objective_label.text = "Arrange the three study markers"
			elif not RunState.story_flags.get("reading_lesson_seen", false):
				objective_label.text = "Read the open lesson book"
			else:
				objective_label.text = "Return to the village square"
		"archive":
			objective_label.text = "Study the ceiling mural" if not RunState.story_flags.get("archive_mural_seen", false) else ("Align the three lenses" if not RunState.story_flags.get("archive_puzzle_solved", false) else "Follow the reflected light")
		"map_chamber":
			if not RunState.story_flags.get("map_chamber_mural_seen", false):
				objective_label.text = "Study the keeper's valley map"
			elif not RunState.story_flags.get("map_route_solved", false):
				objective_label.text = "Trace spring, bridge, then village"
			elif not RunState.story_flags.get("map_chamber_record_seen", false):
				objective_label.text = "Read the route ledger or enter the open arch"
			else:
				objective_label.text = "Enter the reflection gallery"
		"gallery":
			objective_label.text = "Read the pool mural" if not RunState.story_flags.get("gallery_mural_seen", false) else ("Align the reflected stones" if not RunState.story_flags.get("gallery_lights_solved", false) else "Follow the stair below")
		"bell_court":
			objective_label.text = "Listen to the bell garden" if not RunState.story_flags.get("bell_mural_seen", false) else (("Return the five-note echo" if RunState.story_flags.get("bell_echo_variant", false) else "Return the four-note pattern") if not RunState.story_flags.get("bell_court_solved", false) else "Follow the path beyond the bell garden")
		"highland_refuge":
			objective_label.text = "Explore the refuge or continue to the highland steps"
		"high_steps":
			objective_label.text = "Study the wind-worn map" if not RunState.story_flags.get("high_steps_map_seen", false) else ("Align the three wind vanes" if not RunState.story_flags.get("high_steps_aligned", false) else "Enter the upper door")
		"quiet_garden":
			objective_label.text = "Listen for the garden's three notes" if not RunState.story_flags.get("quiet_garden_song_solved", false) else "Return to the orchard when you are ready"
		"observatory":
			objective_label.text = "Approach the old inscription" if not RunState.story_flags.get("ending_revealed", false) else "The world remembers"

func _update_hud(_items: Array[String] = []) -> void:
	if inventory_label == null:
		return
	if RunState.selected_item_id.is_empty():
		inventory_label.text = "%s  Keepsakes %d / %d" % [_action_mark("inventory"), RunState.inventory.size(), RunState.INVENTORY_LIMIT]
	else:
		inventory_label.text = "%s  Active: %s   (%d / %d)" % [_action_mark("inventory"), _item_name(RunState.selected_item_id), RunState.inventory.size(), RunState.INVENTORY_LIMIT]

func _on_hint_echo_changed(_value: int) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#18282b"))
	match phase:
		"crossing": draw_texture_rect(CROSSING_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"ruins": draw_texture_rect(RUINS_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"orchard": draw_texture_rect(ORCHARD_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"waterworks": draw_texture_rect(WATERWORKS_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"cistern_vault": draw_texture_rect(CISTERN_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"reed_causeway": draw_texture_rect(REED_CAUSEWAY_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"empty_quarter": draw_texture_rect(EMPTY_QUARTER_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"reading_room": draw_texture_rect(READING_ROOM_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"archive": draw_texture_rect(ARCHIVE_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"map_chamber": draw_texture_rect(MAP_CHAMBER_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"gallery":
			draw_texture_rect(GALLERY_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"bell_court":
			draw_texture_rect(BELL_COURT_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"highland_refuge": draw_texture_rect(HIGHLAND_REFUGE_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"quiet_garden":
			draw_texture_rect(QUIET_GARDEN_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"high_steps":
			draw_texture_rect(HIGHLAND_STEPS_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
		"observatory": draw_texture_rect(OBSERVATORY_BACKGROUND, Rect2(Vector2.ZERO, WORLD_SIZE), false)
	_draw_scene_overlays()
	_draw_hint_echo()

func _draw_scene_overlays() -> void:
	match phase:
		"crossing": _draw_threshold()
		"ruins": _draw_ruins()
		"orchard": _draw_orchard()
		"waterworks": _draw_waterworks()
		"cistern_vault": _draw_cistern_vault()
		"reed_causeway": _draw_reed_causeway()
		"empty_quarter": _draw_empty_quarter()
		"reading_room": _draw_reading_room()
		"archive": _draw_archive()
		"map_chamber": _draw_map_chamber()
		"gallery": _draw_gallery()
		"bell_court": _draw_bell_court()
		"highland_refuge": _draw_highland_refuge()
		"quiet_garden": _draw_quiet_garden()
		"high_steps": _draw_high_steps()
		"observatory": _draw_observatory()
	_draw_memory_prop()

func _draw_memory_prop() -> void:
	var stone := Color("#777b68")
	var shadow := Color("#394a45")
	var mark := Color("#c0bd9b")
	match phase:
		"crossing":
			draw_rect(Rect2(96, 184, 16, 15), shadow)
			draw_rect(Rect2(98, 181, 12, 14), stone)
			for index in range(3):
				draw_line(Vector2(100, 185 + index * 3), Vector2(108, 185 + index * 3), mark.darkened(0.2), 1.0)
		"ruins":
			draw_rect(Rect2(493, 249, 18, 9), shadow)
			draw_rect(Rect2(496, 242, 12, 10), Color("#8c7964"))
			draw_rect(Rect2(497, 244, 10, 4), Color("#3a4543"))
			draw_line(Vector2(499, 252), Vector2(506, 252), mark, 1.0)
		"orchard":
			draw_rect(Rect2(77, 216, 15, 7), shadow)
			draw_rect(Rect2(80, 207, 2, 12), stone)
			draw_rect(Rect2(87, 210, 2, 9), stone)
			draw_line(Vector2(80, 211), Vector2(88, 214), Color("#a59b76"), 1.0)
		"waterworks":
			for index in range(3):
				var bowl_x := 104 + index * 8
				draw_rect(Rect2(bowl_x, 242, 6, 2), Color("#9a886e"))
				draw_rect(Rect2(bowl_x + 1, 244, 4, 2), Color("#706e5d"))
				draw_rect(Rect2(bowl_x + 1, 241, 4, 1), Color("#c2b991"))
		"archive":
			draw_rect(Rect2(68, 263, 18, 8), shadow)
			draw_rect(Rect2(70, 258, 15, 8), Color("#998d72"))
			draw_line(Vector2(73, 260), Vector2(82, 260), Color("#d3c79c"), 1.0)
			draw_line(Vector2(73, 263), Vector2(80, 263), Color("#665f50"), 1.0)
		"gallery":
			for index in range(3):
				var x := 80 + index * 9
				draw_rect(Rect2(x, 244, 5, 9), shadow)
				draw_rect(Rect2(x + 1, 241, 3, 6), stone)
				draw_rect(Rect2(x + 1, 243, 3, 1), mark.darkened(0.3))
		"bell_court":
			draw_rect(Rect2(539, 258, 19, 10), shadow)
			draw_rect(Rect2(541, 254, 15, 7), Color("#998d72"))
			for index in range(4):
				draw_rect(Rect2(543 + index * 3, 256, 1, 2), mark.darkened(0.25))
		"high_steps":
			draw_rect(Rect2(199, 250, 12, 14), shadow)
			draw_rect(Rect2(202, 246, 7, 14), stone)
			draw_rect(Rect2(204, 248, 3, 6), Color("#d5b985"))
			draw_rect(Rect2(203, 247, 5, 2), Color("#e7d6a8"))
		"quiet_garden":
			draw_rect(Rect2(74, 245, 11, 8), shadow)
			draw_rect(Rect2(76, 240, 7, 6), Color("#987d64"))
			draw_rect(Rect2(77, 241, 5, 3), Color("#46534b"))

func _draw_ground() -> void:
	var echo_tint := _ambient_echo()
	for i in range(0, 41):
		for j in range(0, 41):
			var center := Vector2(320 + (i - j) * 16, 42 + (i + j) * 8)
			if center.x < -24 or center.x > WORLD_SIZE.x + 24 or center.y < -16 or center.y > WORLD_SIZE.y + 16:
				continue
			var path_tile: bool = abs(i - j) <= 1
			var court_tile: bool = abs(i - 20) <= 5 and abs(j - 20) <= 5
			var variant := (i * 17 + j * 11) % 5
			var base := Color("#40544a")
			if path_tile:
				base = Color("#625f50") if variant % 2 == 0 else Color("#6d6756")
			elif court_tile:
				base = Color("#4d574f") if variant % 2 == 0 else Color("#555e55")
			elif variant == 0:
				base = Color("#465a4b")
			base = base.lerp(Color("#786d8a"), echo_tint * 0.42)
			var half := Vector2(16, 8)
			var points := PackedVector2Array([
				center + Vector2(0, -half.y),
				center + Vector2(half.x, 0),
				center + Vector2(0, half.y),
				center + Vector2(-half.x, 0)
			])
			draw_colored_polygon(points, base)
			draw_line(points[0], points[1], base.lightened(0.08), 1.0)
			if not path_tile and not court_tile and variant == 0:
				draw_rect(Rect2(center.x - 2, center.y - 2, 1, 2), Color("#8a9b73"))
				draw_rect(Rect2(center.x + 3, center.y - 1, 1, 2), Color("#728d68"))

func _draw_threshold() -> void:
	# Small interactive glints are layered over the crossing background.
	if not RunState.story_flags.get("medallion_found", false):
		draw_rect(Rect2(275, 167, 6, 2), Color("#b9aa74"))
		draw_rect(Rect2(277, 165, 3, 6), Color("#d8ca91"))
	if RunState.journal_entries.has("crossing_sun_mark"):
		_draw_symbol(Vector2(490, 123), "seed", Color("#d6c995"))
	if not RunState.story_flags.get("moss_button_found", false):
		draw_rect(Rect2(188, 248, 4, 3), Color("#788c70"))
		draw_rect(Rect2(189, 247, 2, 1), Color("#b8aa76"))
	if RunState.story_flags.get("medallion_found", false):
		draw_rect(Rect2(484, 113, 14, 2), Color("#9dc2b9"))

func _draw_ruins() -> void:
	_draw_inscription(Vector2(72, 150))
	_draw_mosaic(Vector2(205, 111))
	var progress := int(RunState.puzzle_progress.get("first_gate", 0))
	var resonators := [Vector2(230, 208), Vector2(320, 197), Vector2(420, 208)]
	for index in range(resonators.size()):
		var lit: bool = index < progress or RunState.story_flags.get("first_gate_open", false)
		_draw_symbol(resonators[index], PUZZLE_ORDER[index], Color("#d5e8d5") if lit else Color("#a9a58a"))
	if not RunState.story_flags.get("old_bead_found", false):
		draw_rect(Rect2(148, 248, 5, 3), Color("#657b79"))
		draw_rect(Rect2(149, 249, 2, 2), Color("#9acbd2"))
	if RunState.story_flags.get("inscription_seen", false) and not RunState.story_flags.get("stone_chip_found", false):
		draw_rect(Rect2(74, 176, 5, 3), Color("#aaa18a"))
	if not RunState.story_flags.get("first_gate_open", false):
		draw_rect(Rect2(287, 72, 66, 57), Color("#27343a"))
		draw_rect(Rect2(296, 81, 48, 40), Color("#202d33"))
		draw_rect(Rect2(319, 82, 2, 37), Color("#586966"))
	else:
		draw_rect(Rect2(311, 119, 18, 2), Color("#a9d7cc"))
	if RunState.story_flags.get("first_gate_open", false):
		draw_rect(Rect2(312, 163, 16, 2), Color("#a9d7cc"))

func _draw_orchard() -> void:
	_draw_orchard_sluice(Vector2(228, 151), "west", 0)
	_draw_orchard_sluice(Vector2(320, 124), "north", 1)
	_draw_orchard_sluice(Vector2(422, 151), "east", 2)
	var valves: Dictionary = RunState.puzzle_progress.get("orchard_valves", {})
	for name in ["west", "north", "east"]:
		if _valve_orientation(valves.get(name, 0)) == int(ORCHARD_SOLUTION[name]) or RunState.story_flags.get("orchard_water_restored", false):
			_draw_water_channel(name)
	_draw_arrow(Vector2(81, 152), 1, Color("#c2c09c"))
	_draw_arrow(Vector2(93, 152), 2, Color("#a5c3bc"))
	_draw_arrow(Vector2(105, 152), 3, Color("#b0bd99"))
	draw_rect(Rect2(561, 151, 5, 3), Color("#c3d7bf"))
	draw_rect(Rect2(562, 149, 3, 2), Color("#e0e9d2"))
	if RunState.story_flags.get("orchard_water_restored", false):
		_draw_arch(Vector2(320, 87), true)
		if not RunState.story_flags.get("river_glass_found", false):
			draw_rect(Rect2(337, 213, 5, 2), Color("#84b6ad"))
			draw_rect(Rect2(339, 212, 3, 1), Color("#c0d6bc"))
	if RunState.story_flags.get("quiet_garden_restored", false):
		_draw_arch(Vector2(182, 243), true)
		draw_rect(Rect2(179, 268, 6, 4), Color("#bcc99a"))
		draw_rect(Rect2(180, 266, 4, 2), Color("#e0dfb6"))
	elif RunState.story_flags.get("orchard_water_restored", false):
		draw_rect(Rect2(166, 267, 31, 6), Color("#7b7155"))
		draw_rect(Rect2(171, 264, 21, 3), Color("#645b48"))
	if RunState.story_flags.get("orchard_water_restored", false):
		_draw_arch(Vector2(548, 100), RunState.story_flags.get("causeway_solved", false))

func _draw_waterworks() -> void:
	var wheel_positions := [Vector2(173, 151), Vector2(320, 128), Vector2(463, 151)]
	var wheel_marks := ["water", "moon", "seed"]
	for index in range(wheel_positions.size()):
		var pos: Vector2 = wheel_positions[index]
		_draw_symbol(pos + Vector2(0, -18), wheel_marks[index], Color("#e0d2a1"))
	var map_box := Rect2(293, 65, 54, 21)
	draw_rect(map_box, Color("#39443e"))
	draw_rect(Rect2(296, 68, 48, 15), Color("#8c866a"))
	for index in range(WATERWORKS_WHEEL_SEQUENCE.size()):
		var wheel_name: String = WATERWORKS_WHEEL_SEQUENCE[index]
		var mark_index := ["west", "center", "east"].find(wheel_name)
		var mark_name: String = wheel_marks[mark_index]
		var mark_color := Color("#f2dca3") if index <= int(RunState.puzzle_progress.get("waterworks_sequence", 0)) - 1 else Color("#c5c2a5")
		_draw_symbol(Vector2(302 + index * 12, 75), mark_name, mark_color)
	if RunState.story_flags.get("waterworks_solved", false):
		draw_rect(Rect2(559, 104, 31, 3), Color("#a9d7cc"))
		draw_rect(Rect2(571, 107, 3, 16), Color("#c7b788"))
		_draw_arch(Vector2(82, 158), true)

func _draw_cistern_vault() -> void:
	var progress := clampi(int(RunState.puzzle_progress.get("cistern_sequence", 0)), 0, CISTERN_VALVE_SEQUENCE.size())
	if not bool(RunState.settings.get("reduced_motion", false)):
		for ripple_index in range(5):
			var ripple_x := 184.0 + float(ripple_index) * 56.0 + sin(_cistern_water_time * 1.1 + float(ripple_index)) * 4.0
			var ripple_y := 213.0 + float(ripple_index % 2) * 17.0
			draw_line(Vector2(ripple_x, ripple_y), Vector2(ripple_x + 9.0, ripple_y), Color("#9dcfc8", 0.36), 1.0)
	for mark_index in range(CISTERN_VALVE_SEQUENCE.size()):
		var mark_color := Color("#a9d8ce") if mark_index < progress or RunState.story_flags.get("cistern_solved", false) else Color("#7c8274")
		draw_rect(Rect2(303 + mark_index * 8, 110, 5, 2), mark_color)
	for valve_name in ["west", "center", "east"]:
		var point: Vector2 = CISTERN_VALVE_POSITIONS[valve_name]
		var lit: bool = bool(RunState.story_flags.get("cistern_solved", false))
		for sequence_index in range(progress):
			if CISTERN_VALVE_SEQUENCE[sequence_index] == valve_name:
				lit = true
		_draw_symbol(point, "water", Color("#a5d7cc") if lit else Color("#8d9c86"))
		if lit:
			draw_circle(point + Vector2(0, 9), 5.0, Color("#9fd7cc", 0.22))
	if RunState.story_flags.get("cistern_solved", false):
		draw_line(Vector2(188, 181), Vector2(452, 181), Color("#a4d8cd", 0.8), 2.0)
	if not RunState.story_flags.get("cistern_record_seen", false) and RunState.story_flags.get("cistern_solved", false):
		draw_rect(Rect2(545, 226, 18, 7), Color("#394740"))
		draw_rect(Rect2(548, 221, 12, 8), Color("#877c61"))
		draw_rect(Rect2(550, 223, 8, 1), Color("#c1b28b"))

func _draw_reed_causeway() -> void:
	var progress := int(RunState.puzzle_progress.get("causeway_sequence", 0))
	var stone_positions := [Vector2(320, 258), Vector2(320, 218), Vector2(320, 178), Vector2(320, 140)]
	draw_rect(Rect2(36, 205, 100, 28), Color("#35443e"))
	draw_rect(Rect2(39, 208, 94, 22), Color("#556359"))
	for mark_index in range(CAUSEWAY_STEP_PATTERN.size()):
		var mark_name: String = CAUSEWAY_STEP_MARKS[int(CAUSEWAY_STEP_PATTERN[mark_index])]
		var mark_color := Color("#c8c2a0") if mark_index != 2 else Color("#acd0c6")
		_draw_symbol(Vector2(44 + mark_index * 12, 219), mark_name, mark_color)
	for index in range(stone_positions.size()):
		var lit := false
		for path_index in range(mini(progress, CAUSEWAY_STEP_PATTERN.size())):
			if int(CAUSEWAY_STEP_PATTERN[path_index]) == index:
				lit = true
		var mark: String = CAUSEWAY_STEP_MARKS[index]
		var color := Color("#d8ead2") if lit else Color("#aeb8a0")
		_draw_symbol(stone_positions[index] + Vector2(0, -5), mark, color)
		if lit:
			draw_rect(Rect2(stone_positions[index].x - 5, stone_positions[index].y + 5, 10, 1), Color("#a4d4ca"))
	for index in range(progress):
		draw_rect(Rect2(292 + index * 8, 333, 5, 2), Color("#bdd9cd"))
	if not RunState.story_flags.get("causeway_record_seen", false):
		draw_rect(Rect2(544, 264, 18, 8), Color("#394740"))
		draw_rect(Rect2(548, 258, 11, 8), Color("#877c61"))
		draw_rect(Rect2(550, 256, 8, 3), Color("#c1b28b"))
	if RunState.story_flags.get("causeway_solved", false):
		draw_line(Vector2(320, 266), Vector2(320, 129), Color("#9ed8ce"), 2.0)

func _draw_orchard_sluice(pos: Vector2, name: String, index: int) -> void:
	var valves: Dictionary = RunState.puzzle_progress.get("orchard_valves", {})
	var orientation := _valve_orientation(valves.get(name, 0))
	var is_aligned: bool = orientation == int(ORCHARD_SOLUTION[name]) or RunState.story_flags.get("orchard_water_restored", false)
	var body := Color("#77806b") if not is_aligned else Color("#a0aa83")
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-12, 7), pos + Vector2(0, 0),
		pos + Vector2(12, 7), pos + Vector2(0, 13)
	]), Color("#34443e"))
	draw_rect(Rect2(pos.x - 7, pos.y - 8, 14, 14), body)
	draw_rect(Rect2(pos.x - 8, pos.y - 10, 16, 3), Color("#9b9c7a"))
	_draw_arrow(pos + Vector2(0, -1), orientation, Color("#8bc2c0") if is_aligned else Color("#4f6159"))

func _draw_reading_room() -> void:
	var tiles: Dictionary = RunState.puzzle_progress.get("reading_tiles", READING_START)
	if not RunState.story_flags.get("reading_puzzle_solved", false):
		for side in ["west", "center", "east"]:
			var point: Vector2 = {"west": Vector2(431, 152), "center": Vector2(503, 152), "east": Vector2(575, 152)}[side]
			var mark := int(tiles.get(side, READING_START[side]))
			draw_rect(Rect2(point + Vector2(-13, -11), Vector2(26, 23)), Color("#695344"))
			draw_rect(Rect2(point + Vector2(-10, -9), Vector2(20, 18)), Color("#978064"))
			_draw_reading_mark(point, mark, Color("#f1dfb8"))
	else:
		draw_rect(Rect2(538, 153, 21, 7), Color("#6b4c39"))
		draw_rect(Rect2(541, 155, 15, 3), Color("#d6c59c"))
		draw_rect(Rect2(545, 154, 6, 1), Color("#e7ddc0"))

func _draw_reading_mark(point: Vector2, mark: int, color: Color) -> void:
	match posmod(mark, 3):
		0:
			# A tiny boat with a centered mast and a single square sail.
			draw_colored_polygon(PackedVector2Array([point + Vector2(-7, 1), point + Vector2(7, 1), point + Vector2(4, 5), point + Vector2(-4, 5)]), color)
			draw_line(point + Vector2(0, -7), point + Vector2(0, 1), color, 1.0)
			draw_colored_polygon(PackedVector2Array([point + Vector2(1, -6), point + Vector2(6, -2), point + Vector2(1, -2)]), color.lightened(0.1))
		1:
			draw_rect(Rect2(point + Vector2(-4, -3), Vector2(8, 9)), color)
			draw_rect(Rect2(point + Vector2(-2, -1), Vector2(4, 4)), Color("#745c45"))
			draw_line(point + Vector2(0, -8), point + Vector2(0, -4), color, 1.0)
			draw_rect(Rect2(point.x - 1, point.y - 9, 2, 2), Color("#f1c477"))
		2:
			draw_line(point + Vector2(-2, 6), point + Vector2(-3, -6), color, 1.0)
			draw_line(point + Vector2(1, 6), point + Vector2(2, -8), color, 1.0)
			draw_line(point + Vector2(4, 6), point + Vector2(5, -5), color, 1.0)
			draw_line(point + Vector2(-3, -2), point + Vector2(-7, -5), color, 1.0)
			draw_line(point + Vector2(2, 0), point + Vector2(6, -3), color, 1.0)
			draw_line(point + Vector2(2, -4), point + Vector2(-2, -7), color, 1.0)

func _draw_empty_quarter() -> void:
	var slots := _get_quarter_slots()
	var positions := {"west": Vector2(137, 222), "north": Vector2(224, 152), "east": Vector2(438, 152), "south": Vector2(566, 210)}
	for side in positions:
		var point: Vector2 = positions[side]
		var object_name: String = QUARTER_OBJECTS[int(slots[side])]
		var correct := int(slots[side]) == int(QUARTER_SOLUTION[side])
		var tint := Color("#cfcea3") if correct or RunState.story_flags.get("quarter_household_restored", false) else Color("#6b7468")
		_draw_quarter_object(point, object_name, tint)
	if RunState.story_flags.get("quarter_household_restored", false):
		draw_circle(Vector2(320, 166), 12.0, Color("#d8e6d0", 0.28))
		draw_circle(Vector2(320, 166), 5.0, Color("#d6e2c7", 0.72))
	if _village_gathering_clues_complete() and not RunState.story_flags.get("village_gathering_solved", false):
		var gathering_progress := int(RunState.puzzle_progress.get("village_gathering_sequence", 0))
		var gathering_positions := [Vector2(292, 166), Vector2(320, 166), Vector2(348, 166)]
		for index in range(gathering_positions.size()):
			var lit := index < gathering_progress
			var tint := Color("#e7d7a4") if lit else Color("#9c9d82")
			var point: Vector2 = gathering_positions[index]
			draw_circle(point, 8.0, Color("#394a45"))
			draw_circle(point, 6.0, Color("#777b68"))
			if index == 0:
				_draw_quarter_object(point, "bowl", tint)
			elif index == 1:
				_draw_quarter_object(point, "lamp", tint)
			else:
				draw_rect(Rect2(point.x - 4, point.y - 5, 8, 8), tint)
				draw_rect(Rect2(point.x - 6, point.y - 6, 12, 2), tint)
				draw_line(point + Vector2(-3, 4), point + Vector2(3, 4), tint, 1.0)
	if RunState.story_flags.get("village_gathering_solved", false):
		draw_circle(Vector2(320, 166), 16.0, Color("#e4d5a2", 0.16))
		draw_circle(Vector2(320, 166), 8.0, Color("#e4d5a2", 0.22))

func _draw_highland_refuge() -> void:
	draw_rect(Rect2(99, 115, 24, 34), Color("#514b40"))
	draw_rect(Rect2(102, 118, 18, 27), Color("#b3a47e"))
	draw_line(Vector2(105, 125), Vector2(117, 125), Color("#5c6459"), 1.0)
	draw_line(Vector2(105, 131), Vector2(117, 131), Color("#5c6459"), 1.0)
	draw_line(Vector2(105, 137), Vector2(113, 137), Color("#5c6459"), 1.0)
	draw_rect(Rect2(294, 197, 22, 13), Color("#695344"))
	draw_rect(Rect2(296, 198, 9, 10), Color("#e0d3b6"))
	draw_rect(Rect2(306, 198, 8, 10), Color("#d3c5a4"))
	draw_line(Vector2(305, 198), Vector2(305, 208), Color("#6b6656"), 1.0)

func _draw_quarter_object(point: Vector2, object_name: String, tint: Color) -> void:
	match object_name:
		"book":
			draw_rect(Rect2(point + Vector2(-7, -4), Vector2(6, 9)), tint)
			draw_rect(Rect2(point + Vector2(1, -4), Vector2(6, 9)), tint.lightened(0.12))
			draw_line(point + Vector2(0, -4), point + Vector2(0, 5), Color("#4a5148"), 1.0)
		"bowl":
			draw_rect(Rect2(point + Vector2(-7, -3), Vector2(14, 2)), tint)
			draw_colored_polygon(PackedVector2Array([point + Vector2(-6, -1), point + Vector2(6, -1), point + Vector2(3, 5), point + Vector2(-3, 5)]), tint)
		"seed":
			draw_circle(point, 5.0, tint)
			draw_line(point + Vector2(0, -3), point + Vector2(4, -7), Color("#9aa584"), 1.0)
		"lamp":
			draw_rect(Rect2(point + Vector2(-4, -5), Vector2(8, 8)), tint)
			draw_rect(Rect2(point + Vector2(-2, -3), Vector2(4, 4)), Color("#e4c78a"))
			draw_line(point + Vector2(0, 3), point + Vector2(0, 7), tint, 1.0)

func _draw_water_channel(name: String) -> void:
	var water := Color("#6eaaa8")
	match name:
		"west":
			draw_line(Vector2(235, 155), Vector2(303, 185), water, 2.0)
		"north":
			draw_line(Vector2(320, 130), Vector2(320, 179), water, 2.0)
		"east":
			draw_line(Vector2(415, 155), Vector2(337, 185), water, 2.0)

func _draw_archive() -> void:
	_draw_archive_arrows(Vector2(320, 85))
	_draw_archive_lens(Vector2(145, 213), "west")
	_draw_archive_lens(Vector2(320, 213), "center")
	_draw_archive_lens(Vector2(525, 213), "east")
	if RunState.journal_entries.has("archive_second_image") and not RunState.story_flags.get("archive_fourth_path_solved", false):
		for name in ["west", "center", "east"]:
			_draw_arrow(_archive_lens_position(name) + Vector2(0, -13), int(ARCHIVE_FOURTH_PATH_SOLUTION[name]), Color("#91b9bf"))
	if RunState.story_flags.get("archive_puzzle_solved", false):
		draw_line(Vector2(145, 220), Vector2(320, 211), Color("#a9d7cc"), 1.0)
		draw_line(Vector2(320, 211), Vector2(525, 220), Color("#a9d7cc"), 1.0)
		draw_rect(Rect2(304, 94, 32, 31), Color("#526966"))
		draw_rect(Rect2(310, 99, 20, 22), Color("#9fc1b5"))
		draw_circle(Vector2(320, 264), 9.0, Color("#79b5ab", 0.18))
		draw_arc(Vector2(320, 264), 9.0, 0.0, TAU, 20, Color("#9fc9bb", 0.8), 1.0)
		draw_circle(Vector2(320, 264), 2.0, Color("#c2d9be", 0.8))
	else:
		draw_rect(Rect2(302, 94, 36, 31), Color("#27343a"))
		draw_rect(Rect2(311, 101, 18, 19), Color("#202d33"))
	if not RunState.story_flags.get("mirror_shard_found", false):
		draw_rect(Rect2(564, 263, 5, 3), Color("#97babb"))
		draw_rect(Rect2(565, 262, 2, 1), Color("#d6e4da"))
	if RunState.story_flags.get("archive_fourth_path_solved", false):
		draw_line(Vector2(145, 220), Vector2(78, 204), Color("#b0d3cd"), 1.0)
		draw_rect(Rect2(68, 201, 10, 2), Color("#c9c2a0"))
		draw_rect(Rect2(70, 199, 5, 2), Color("#e0dcc4"))

func _draw_map_chamber() -> void:
	var progress := int(RunState.puzzle_progress.get("map_route_sequence", 0))
	var route_colors := [Color("#c5d7aa"), Color("#9ed8ce"), Color("#e3c990")]
	for index in range(MAP_ROUTE_SEQUENCE.size()):
		var point: Vector2 = MAP_ROUTE_POSITIONS[MAP_ROUTE_SEQUENCE[index]]
		var is_lit: bool = bool(RunState.story_flags.get("map_route_solved", false)) or index < progress
		var glow_color: Color = route_colors[index] if is_lit else Color("#857b62")
		draw_circle(point, 8.0, Color(glow_color, 0.22) if is_lit else Color("#192a2a", 0.7))
		draw_arc(point, 9.0, 0.0, TAU, 16, glow_color, 1.5, true)
		if (index < progress - 1 or RunState.story_flags.get("map_route_solved", false)) and index + 1 < MAP_ROUTE_SEQUENCE.size():
			var next_point: Vector2 = MAP_ROUTE_POSITIONS[MAP_ROUTE_SEQUENCE[index + 1]]
			draw_line(point, next_point, Color("#a9d9ce", 0.8), 2.0)
	if RunState.story_flags.get("map_route_solved", false):
		_draw_arch(Vector2(320, 222), true)
	else:
		_draw_arch(Vector2(320, 222), false)
	if not RunState.story_flags.get("map_chamber_record_seen", false) and RunState.story_flags.get("map_route_solved", false):
		draw_rect(Rect2(78, 269, 20, 8), Color("#35443e"))
		draw_rect(Rect2(81, 264, 13, 8), Color("#8f8064"))
		draw_rect(Rect2(83, 266, 9, 1), Color("#d4c394"))

func _draw_archive_arrows(pos: Vector2) -> void:
	_draw_arrow(pos + Vector2(-12, 0), 1, Color("#c2c09c"))
	_draw_arrow(pos, 2, Color("#a5c3bc"))
	_draw_arrow(pos + Vector2(12, 0), 3, Color("#b0bd99"))

func _draw_archive_lens(pos: Vector2, name: String) -> void:
	var lenses: Dictionary = RunState.puzzle_progress.get("archive_lenses", {})
	var direction := int(lenses.get(name, 0))
	var aligned: bool = direction == int(ARCHIVE_SOLUTION[name])
	if RunState.story_flags.get("archive_puzzle_solved", false):
		aligned = RunState.story_flags.get("archive_fourth_path_solved", false) or not RunState.journal_entries.has("archive_second_image") or direction == int(ARCHIVE_FOURTH_PATH_SOLUTION[name])
	_draw_arrow(pos, direction, Color("#e0e0c4") if aligned else Color("#718985"))
	if aligned:
		draw_rect(Rect2(pos.x - 8, pos.y + 7, 16, 1), Color("#a9d7cc"))

func _archive_lens_position(name: String) -> Vector2:
	match name:
		"west": return Vector2(145, 213)
		"center": return Vector2(320, 213)
		_: return Vector2(525, 213)

func _draw_gallery() -> void:
	# Small runes sit on the three mirror faces painted into the background.
	draw_rect(Rect2(239, 141, 34, 18), Color("#626c62"))
	draw_rect(Rect2(242, 144, 28, 12), Color("#414e4b"))
	_draw_symbol(Vector2(248, 150), "moon", Color("#c7bd9b"))
	_draw_symbol(Vector2(256, 150), "water", Color("#9cbcb8"))
	_draw_symbol(Vector2(264, 150), "seed", Color("#abb98f"))
	_draw_gallery_mirror(Vector2(160, 158), "west")
	_draw_gallery_mirror(Vector2(320, 158), "center")
	_draw_gallery_mirror(Vector2(464, 158), "east")
	if RunState.story_flags.get("gallery_lights_solved", false):
		draw_line(Vector2(160, 169), Vector2(320, 177), Color("#9ecbc4"), 1.0)
		draw_line(Vector2(320, 177), Vector2(464, 169), Color("#9ecbc4"), 1.0)
	if RunState.story_flags.get("gallery_lights_solved", false):
		draw_rect(Rect2(308, 143, 24, 3), Color("#afd3cc"))
		draw_rect(Rect2(312, 134, 16, 10), Color("#60756f"))
		draw_rect(Rect2(315, 128, 10, 7), Color("#d1ddc7"))

func _draw_gallery_mirror(pos: Vector2, name: String) -> void:
	var direction := _get_gallery_orientation(name)
	var aligned: bool = direction == int(GALLERY_SOLUTION[name]) or RunState.story_flags.get("gallery_lights_solved", false)
	var rune_color := Color("#e0e0c4") if aligned else Color("#9cae9f")
	_draw_arrow(pos, direction, rune_color)
	if aligned:
		draw_rect(Rect2(pos.x - 5, pos.y + 7, 10, 1), Color("#a6d0c6"))

func _draw_bell_court() -> void:
	var bell_positions := [Vector2(148, 112), Vector2(267, 112), Vector2(395, 112), Vector2(520, 112)]
	for index in range(bell_positions.size()):
		_draw_court_bell(bell_positions[index], index)
	draw_rect(Rect2(300, 145, 40, 18), Color("#5d695f"))
	draw_rect(Rect2(304, 148, 32, 12), Color("#3e4c49"))
	_draw_symbol(Vector2(304, 154), "moon", Color("#c8c4a7"))
	_draw_symbol(Vector2(312, 154), "water", Color("#a7c4bc"))
	_draw_symbol(Vector2(320, 154), "seed", Color("#aeb98e"))
	_draw_symbol(Vector2(328, 154), "moon", Color("#c8c4a7"))
	if RunState.story_flags.get("bell_echo_variant", false):
		_draw_symbol(Vector2(336, 154), "water", Color("#c693bd"))
	var progress := int(RunState.puzzle_progress.get("bell_sequence", 0))
	for index in range(mini(progress, _current_bell_sequence().size())):
		draw_rect(Rect2(290 + index * 15, 218, 5, 2), Color("#b8d2c6"))
	if RunState.story_flags.get("bell_court_solved", false):
		_draw_arch(Vector2(582, 174), true)
		draw_line(Vector2(535, 174), Vector2(550, 174), Color("#aed4c8"), 1.0)

func _draw_court_bell(pos: Vector2, index: int) -> void:
	var progress := int(RunState.puzzle_progress.get("bell_sequence", 0))
	var lit: bool = (index < progress) or RunState.story_flags.get("bell_court_solved", false)
	var bell_color := Color("#e4ead0") if lit else Color("#b6ad87")
	if RunState.story_flags.get("bell_echo_variant", false) and progress == 4 and index == 1:
		bell_color = Color("#c693bd")
	_draw_symbol(pos, BELL_SEQUENCE[index], bell_color)
	if lit:
		draw_rect(Rect2(pos.x - 7, pos.y + 11, 14, 1), Color("#a8d3c7"))

func _draw_quiet_garden() -> void:
	draw_rect(Rect2(204, 93, 30, 16), Color("#687266"))
	draw_rect(Rect2(208, 96, 22, 10), Color("#3f5049"))
	var chime_positions := [Vector2(342, 108), Vector2(400, 116), Vector2(448, 132)]
	for index in range(QUIET_GARDEN_SEQUENCE.size()):
		var pos: Vector2 = chime_positions[index]
		var lit: bool = index < int(RunState.puzzle_progress.get("quiet_garden_sequence", 0)) or RunState.story_flags.get("quiet_garden_song_solved", false)
		_draw_symbol(pos, QUIET_GARDEN_SEQUENCE[index], Color("#e4ead0") if lit else Color("#b6ad87"))
		if lit:
			draw_rect(Rect2(pos.x - 5, pos.y + 7, 10, 1), Color("#a8d3c7"))
	if RunState.story_flags.get("quiet_garden_song_solved", false):
		draw_rect(Rect2(318, 151, 5, 3), Color("#cad8a6"))
		draw_rect(Rect2(316, 149, 3, 2), Color("#e5e7c8"))

func _draw_high_steps() -> void:
	draw_rect(Rect2(294, 96, 32, 18), Color("#606d63"))
	draw_rect(Rect2(298, 99, 24, 12), Color("#3d4a47"))
	_draw_arrow(Vector2(302, 105), 3, Color("#c2c09c"))
	if RunState.story_flags.get("high_steps_echo_variant", false):
		_draw_arrow(Vector2(310, 105), 0, Color("#a5c3bc").darkened(0.25))
		_draw_arrow(Vector2(310, 105), 2, Color("#c693bd"))
	else:
		_draw_arrow(Vector2(310, 105), 0, Color("#a5c3bc"))
	_draw_arrow(Vector2(318, 105), 1, Color("#b0bd99"))
	var vane_positions := [Vector2(118, 137), Vector2(268, 119), Vector2(423, 109)]
	for index in range(vane_positions.size()):
		var name: String = ["west", "center", "east"][index]
		var direction := _get_steps_vane_orientation(name)
		var aligned: bool = direction == int(_high_steps_solution()[name]) or RunState.story_flags.get("high_steps_aligned", false)
		_draw_arrow(vane_positions[index], direction, Color("#eadbb1") if aligned else Color("#b5aa89"))
		if aligned:
			draw_rect(Rect2(vane_positions[index].x - 6, vane_positions[index].y + 7, 12, 1), Color("#b1d0c4"))
	if RunState.story_flags.get("high_steps_aligned", false):
		draw_line(Vector2(423, 126), Vector2(535, 114), Color("#acd1c7"), 1.0)
		draw_rect(Rect2(552, 105, 4, 7), Color("#f1d89b"))
	else:
		draw_rect(Rect2(536, 51, 57, 66), Color("#27343a"))
		draw_rect(Rect2(546, 61, 38, 45), Color("#1e2a31"))

func _draw_observatory() -> void:
	_draw_final_inscription(Vector2(320, 101))
	var arms: Dictionary = RunState.puzzle_progress.get("observatory_arms", {})
	var arm_names := ["west", "center", "east"]
	var arm_symbols := ["moon", "water", "seed"]
	var arm_positions := [Vector2(87, 150), Vector2(108, 126), Vector2(132, 150)]
	for index in range(arm_names.size()):
		var arm_name: String = arm_names[index]
		var pos: Vector2 = arm_positions[index]
		draw_circle(pos, 5.0, Color("#554a39"))
		draw_circle(pos, 3.0, Color("#c5a86c"))
		_draw_arrow(pos, int(arms.get(arm_name, 0)), Color("#f0d798"))
		_draw_symbol(pos + Vector2(0, -8), arm_symbols[index], Color("#e2d3a5"))
	if RunState.story_flags.get("observatory_orrery_solved", false):
		draw_rect(Rect2(132, 178, 14, 2), Color("#dfc891"))
	if RunState.story_flags.get("ending_revealed", false):
		draw_rect(Rect2(315, 143, 10, 2), Color("#e0d29d"))

func _draw_final_inscription(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x - 30, pos.y - 38, 60, 48), Color("#66736a"))
	draw_rect(Rect2(pos.x - 25, pos.y - 33, 50, 39), Color("#465551"))
	for line_index in range(7):
		var y := pos.y - 25 + line_index * 4
		var width := 20 + (line_index % 3) * 7
		draw_rect(Rect2(pos.x - width / 2, y, width, 2), Color("#9dbab0"))
	if RunState.story_flags.get("ending_revealed", false):
		draw_rect(Rect2(pos.x - 20, pos.y + 15, 40, 2), Color("#ddcf9c"))

func _draw_arrow(pos: Vector2, direction: int, color: Color) -> void:
	match direction % 4:
		0:
			draw_rect(Rect2(pos.x - 1, pos.y - 4, 2, 6), color)
			draw_rect(Rect2(pos.x - 3, pos.y - 3, 2, 2), color)
			draw_rect(Rect2(pos.x + 1, pos.y - 3, 2, 2), color)
		1:
			draw_rect(Rect2(pos.x - 1, pos.y - 1, 6, 2), color)
			draw_rect(Rect2(pos.x + 3, pos.y - 3, 2, 2), color)
			draw_rect(Rect2(pos.x + 3, pos.y + 1, 2, 2), color)
		2:
			draw_rect(Rect2(pos.x - 1, pos.y - 1, 2, 6), color)
			draw_rect(Rect2(pos.x - 3, pos.y + 2, 2, 2), color)
			draw_rect(Rect2(pos.x + 1, pos.y + 2, 2, 2), color)
		3:
			draw_rect(Rect2(pos.x - 5, pos.y - 1, 6, 2), color)
			draw_rect(Rect2(pos.x - 5, pos.y - 3, 2, 2), color)
			draw_rect(Rect2(pos.x - 5, pos.y + 1, 2, 2), color)

func _draw_arch(pos: Vector2, opened: bool) -> void:
	var stone := Color("#68756e")
	var shade := Color("#3c4a49")
	draw_rect(Rect2(pos.x - 28, pos.y - 49, 12, 51), shade)
	draw_rect(Rect2(pos.x + 16, pos.y - 49, 12, 51), shade)
	draw_rect(Rect2(pos.x - 31, pos.y - 55, 18, 7), stone)
	draw_rect(Rect2(pos.x + 13, pos.y - 55, 18, 7), stone)
	draw_rect(Rect2(pos.x - 24, pos.y - 62, 48, 10), stone)
	draw_rect(Rect2(pos.x - 18, pos.y - 67, 36, 6), Color("#849087"))
	draw_rect(Rect2(pos.x - 20, pos.y - 1, 40, 3), Color("#343f3d"))
	if not opened:
		draw_rect(Rect2(pos.x - 12, pos.y - 42, 24, 42), Color("#283538"))
		draw_rect(Rect2(pos.x - 4, pos.y - 34, 8, 8), Color("#647d7d"))
		draw_rect(Rect2(pos.x - 2, pos.y - 32, 4, 4), Color("#9ebabc"))
	else:
		draw_rect(Rect2(pos.x - 12, pos.y - 42, 24, 42), Color("#17262e"))
		draw_rect(Rect2(pos.x - 9, pos.y - 38, 18, 30), Color("#253a42"))
		draw_rect(Rect2(pos.x - 1, pos.y - 33, 2, 25), Color("#9ac5bf"))
	draw_rect(Rect2(pos.x - 32, pos.y - 21, 5, 4), Color("#89968b"))
	draw_rect(Rect2(pos.x + 27, pos.y - 32, 4, 5), Color("#89968b"))

func _draw_altar(pos: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-16, 4), pos + Vector2(0, -4),
		pos + Vector2(16, 4), pos + Vector2(0, 12)
	]), Color("#7a7b68"))
	draw_rect(Rect2(pos.x - 11, pos.y - 2, 22, 5), Color("#928d73"))
	draw_rect(Rect2(pos.x - 5, pos.y - 9, 10, 7), Color("#b3a77c"))
	draw_rect(Rect2(pos.x - 2, pos.y - 7, 4, 4), Color("#e0d39a"))
	draw_rect(Rect2(pos.x - 1, pos.y - 6, 2, 2), Color("#f1e8c8"))

func _draw_inscription(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x - 13, pos.y - 21, 27, 34), Color("#66736a"))
	draw_rect(Rect2(pos.x - 10, pos.y - 18, 21, 28), Color("#4e5b56"))
	var glow := Color("#a5c6bd").lerp(Color("#d0a8c5"), clampf(float(RunState.hint_echo) / 12.0, 0.0, 0.7))
	for index in range(7):
		var y := pos.y - 13 + index * 3
		draw_rect(Rect2(pos.x - 7 + (index % 2) * 2, y, 2, 1), glow)
		draw_rect(Rect2(pos.x + 1 - (index % 3), y + 1, 3, 1), glow.darkened(0.2))

func _draw_mosaic(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x - 19, pos.y - 15, 38, 23), Color("#726f5c"))
	draw_rect(Rect2(pos.x - 16, pos.y - 12, 32, 17), Color("#454e49"))
	_draw_symbol(Vector2(pos.x - 9, pos.y - 4), "moon", Color("#c0b790"))
	_draw_symbol(Vector2(pos.x, pos.y - 4), "water", Color("#a4c3bd"))
	_draw_symbol(Vector2(pos.x + 9, pos.y - 4), "seed", Color("#9eb184"))
	draw_rect(Rect2(pos.x - 20, pos.y + 8, 40, 2), Color("#3c4744"))

func _draw_resonator(pos: Vector2, symbol: String, index: int) -> void:
	var progress := int(RunState.puzzle_progress.get("first_gate", 0))
	var activated: bool = RunState.story_flags.get("first_gate_open", false) or index < progress
	var base := Color("#647168") if not activated else Color("#839487")
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-13, 8), pos + Vector2(0, 0),
		pos + Vector2(13, 8), pos + Vector2(0, 14)
	]), Color("#2e3d3b"))
	draw_rect(Rect2(pos.x - 8, pos.y - 13, 16, 18), base)
	draw_rect(Rect2(pos.x - 6, pos.y - 16, 12, 4), Color("#879187"))
	var rune_color := Color("#bfe5dc") if activated else Color("#c4c09e")
	_draw_symbol(pos + Vector2(0, -6), symbol, rune_color)
	if activated:
		draw_rect(Rect2(pos.x - 11, pos.y + 7, 22, 1), Color("#b8d9ca"))

func _draw_symbol(pos: Vector2, symbol: String, color: Color) -> void:
	match symbol:
		"moon":
			draw_rect(Rect2(pos.x - 2, pos.y - 4, 4, 1), color)
			draw_rect(Rect2(pos.x - 4, pos.y - 3, 2, 5), color)
			draw_rect(Rect2(pos.x - 2, pos.y + 2, 4, 1), color)
			draw_rect(Rect2(pos.x + 2, pos.y - 2, 1, 3), color.darkened(0.25))
		"water":
			draw_rect(Rect2(pos.x - 1, pos.y - 4, 2, 2), color)
			draw_rect(Rect2(pos.x - 3, pos.y - 2, 6, 1), color)
			draw_rect(Rect2(pos.x - 2, pos.y, 4, 1), color)
			draw_rect(Rect2(pos.x - 1, pos.y + 2, 2, 1), color)
		"seed":
			draw_rect(Rect2(pos.x - 1, pos.y - 3, 2, 5), color)
			draw_rect(Rect2(pos.x - 4, pos.y - 2, 3, 2), color)
			draw_rect(Rect2(pos.x + 1, pos.y - 1, 3, 2), color)

func _draw_tree(pos: Vector2, color: Color) -> void:
	draw_rect(Rect2(pos.x - 2, pos.y - 18, 4, 20), Color("#453f35"))
	draw_rect(Rect2(pos.x - 12, pos.y - 27, 15, 13), color)
	draw_rect(Rect2(pos.x - 7, pos.y - 34, 13, 12), color.lightened(0.06))
	draw_rect(Rect2(pos.x + 1, pos.y - 27, 10, 10), color.darkened(0.06))
	draw_rect(Rect2(pos.x - 9, pos.y - 24, 4, 2), Color("#6f8065"))
	draw_rect(Rect2(pos.x + 5, pos.y - 19, 3, 2), Color("#708467"))

func _draw_stone(pos: Vector2, width: int, color: Color) -> void:
	draw_rect(Rect2(pos.x - width / 2, pos.y - 4, width, 5), color)
	draw_rect(Rect2(pos.x - width / 2 + 1, pos.y - 6, width - 2, 3), color.lightened(0.08))
	draw_rect(Rect2(pos.x - width / 2 + 2, pos.y - 1, width - 3, 2), color.darkened(0.2))

func _draw_hint_echo() -> void:
	var intensity := clampf(_ambient_echo() * 0.75, 0.0, 0.5)
	if intensity <= 0.0 or phase == "crossing":
		return
	var echo := Color("#c59cce")
	echo.a = intensity
	for index in range(mini(int(RunState.local_hint_points + RunState.total_hint_points * 0.15), 9)):
		var x := 210 + (index * 31) % 218
		var y := 102 + (index * 19) % 92
		draw_rect(Rect2(x, y, 2, 1), echo)
		draw_rect(Rect2(x + 2, y - 2, 1, 2), echo.darkened(0.15))

func _ambient_echo() -> float:
	return clampf(float(RunState.local_hint_points) / 12.0 + float(RunState.total_hint_points) * 0.025, 0.0, 0.55)
