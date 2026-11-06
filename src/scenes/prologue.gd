extends Node2D

const TRAVELER_SCENE := preload("res://src/scenes/traveler.tscn")
const BETH_SCENE := preload("res://src/scenes/beth.tscn")
const WORLD_SIZE := Vector2(640, 360)
const PUZZLE_ORDER := ["moon", "water", "seed"]
const ARCHIVE_SOLUTION := {"west": 1, "center": 2, "east": 3}
const ORCHARD_SOLUTION := {"west": 1, "north": 2, "east": 3}

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

func _ready() -> void:
	camera_snap = bool(RunState.settings.get("snap_camera", false))
	if RunState.story_flags.get("reached_orchard", false):
		if RunState.story_flags.get("reached_observatory", false):
			phase = "observatory"
		elif RunState.story_flags.get("reached_archive", false):
			phase = "archive"
		else:
			phase = "orchard"
	elif RunState.story_flags.get("crossed_into_world", false):
		phase = "ruins"
	else:
		phase = "crossing"
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
	match phase:
		"crossing":
			traveler.position = Vector2(205, 226)
		"ruins":
			traveler.position = Vector2(285, 248)
		_:
			traveler.position = Vector2(320, 248)
	traveler.movement_bounds = Rect2(22, 40, 596, 300)
	traveler.z_index = 10
	add_child(traveler)

func _create_camera() -> void:
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.5
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

func _create_beth() -> void:
	beth = BETH_SCENE.instantiate() as Beth
	beth.position = Vector2(344, 214) if phase == "ruins" else Vector2(337, 232)
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
	var journal_hint := _new_label("J  JOURNAL     H  HINTS", 6, Color("#b7c4bc"), Vector2(224, 7), Vector2(88, 12))
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
	var controls := _new_label("WASD Move   Shift Run   E Look   F Take   U Use   I Bag   Space Act   J Notes   H Hints", 5, Color("#9ca9a4"), Vector2(8, 168), Vector2(304, 9))
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

func _get_targets() -> Array[Dictionary]:
	if phase == "crossing":
		var crossing_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("medallion_found", false):
			crossing_targets.append({"id": "medallion", "name": "the medallion", "position": Vector2(302, 222)})
		if not RunState.story_flags.get("moss_button_found", false):
			crossing_targets.append({"id": "moss_button", "name": "the green brass button", "position": Vector2(190, 250)})
		if RunState.story_flags.get("medallion_found", false):
			crossing_targets.append({"id": "arch", "name": "the buried arch", "position": Vector2(420, 184)})
		return crossing_targets
	if phase == "orchard":
		var orchard_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("orchard_mural_seen", false):
			orchard_targets.append({"id": "orchard_mural", "name": "the orchard mural", "position": Vector2(245, 174)})
		if not RunState.story_flags.get("orchard_memory_seen", false):
			orchard_targets.append({"id": "memory_bloom", "name": "the pale bloom", "position": Vector2(430, 196)})
		if not RunState.story_flags.get("orchard_water_restored", false):
			orchard_targets.append({"id": "sluice_west", "name": "the western sluice", "position": Vector2(260, 226)})
			orchard_targets.append({"id": "sluice_north", "name": "the northern sluice", "position": Vector2(320, 198)})
			orchard_targets.append({"id": "sluice_east", "name": "the eastern sluice", "position": Vector2(380, 226)})
		else:
			orchard_targets.append({"id": "archive_gate", "name": "the archive gate", "position": Vector2(320, 145)})
		if RunState.story_flags.get("orchard_memory_seen", false) and not RunState.story_flags.get("seed_pod_found", false):
			orchard_targets.append({"id": "seed_pod", "name": "the pale seed pod", "position": Vector2(430, 196)})
		if RunState.story_flags.get("orchard_water_restored", false) and not RunState.story_flags.get("river_glass_found", false):
			orchard_targets.append({"id": "river_glass", "name": "a piece of river glass", "position": Vector2(460, 262)})
		if RunState.story_flags.get("orchard_water_restored", false) and not RunState.story_flags.get("quiet_garden_restored", false):
			orchard_targets.append({"id": "seed_bed", "name": "the empty garden bed", "position": Vector2(215, 266)})
		return orchard_targets
	if phase == "archive":
		var archive_targets: Array[Dictionary] = []
		if not RunState.story_flags.get("archive_mural_seen", false) or (RunState.inventory.has("mirror_shard") and not RunState.journal_entries.has("archive_second_image")):
			archive_targets.append({"id": "archive_mural", "name": "the ceiling mural", "position": Vector2(250, 154)})

		if not RunState.story_flags.get("archive_memory_seen", false) or (RunState.inventory.has("river_glass") and not RunState.journal_entries.has("river_glass_memory")):
			archive_targets.append({"id": "archive_memory", "name": "the reflecting pool", "position": Vector2(434, 188)})
		if not RunState.story_flags.get("archive_puzzle_solved", false):
			archive_targets.append({"id": "lens_west", "name": "the western lens", "position": Vector2(264, 220)})
			archive_targets.append({"id": "lens_center", "name": "the central lens", "position": Vector2(320, 194)})
			archive_targets.append({"id": "lens_east", "name": "the eastern lens", "position": Vector2(376, 220)})
		else:
			archive_targets.append({"id": "archive_stair", "name": "the revealed stair", "position": Vector2(320, 142)})
		if not RunState.story_flags.get("mirror_shard_found", false):
			archive_targets.append({"id": "mirror_shard", "name": "a silvered glass shard", "position": Vector2(474, 255)})
		return archive_targets
	if phase == "observatory":
		if not RunState.story_flags.get("ending_revealed", false):
			return [{"id": "final_inscription", "name": "the old inscription", "position": Vector2(320, 164)}]
		return []
	var targets: Array[Dictionary] = []
	if not RunState.story_flags.get("beth_awake", false):
		targets.append({"id": "beth", "name": "Beth", "position": Vector2(344, 214)})
	if not RunState.story_flags.get("inscription_seen", false) or (RunState.inventory.has("stone_chip") and not RunState.journal_entries.has("matching_stone_cuts")):
		targets.append({"id": "inscription", "name": "the inscription", "position": Vector2(232, 177)})
	if RunState.story_flags.get("inscription_seen", false) and not RunState.story_flags.get("stone_chip_found", false):
		targets.append({"id": "stone_chip", "name": "a loose inscription chip", "position": Vector2(232, 202)})
	if not RunState.story_flags.get("old_bead_found", false):
		targets.append({"id": "old_bead", "name": "a cloudy bead", "position": Vector2(180, 250)})
	if not RunState.story_flags.get("resonance_clue_seen", false):
		targets.append({"id": "mosaic", "name": "the faded mosaic", "position": Vector2(276, 165)})
	if not RunState.story_flags.get("first_gate_open", false):
		targets.append({"id": "resonator_moon", "name": "the crescent resonator", "position": Vector2(272, 226)})
		targets.append({"id": "resonator_water", "name": "the rain-line resonator", "position": Vector2(320, 199)})
		targets.append({"id": "resonator_seed", "name": "the seed resonator", "position": Vector2(368, 226)})
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
			prompt_label.text = "E  examine     F  take"
		"moss_button", "stone_chip", "old_bead", "seed_pod", "river_glass", "mirror_shard":
			prompt_label.text = "E  examine     F  take"
		"arch":
			prompt_label.text = "E  examine     Space  cross"
		"beth":
			prompt_label.text = "E  wake the small light"
		"inscription":
			prompt_label.text = "E  examine inscription"
			if RunState.selected_item_id == "stone_chip":
				prompt_label.text += "     U  fit chip"
		"mosaic":
			prompt_label.text = "E  study the worn symbols"
		"resonator_moon", "resonator_water", "resonator_seed":
			prompt_label.text = "Space  attune"
		"gate":
			prompt_label.text = "E  look beyond"
			if traveler.position.distance_to(Vector2(320, 155)) < 28:
				prompt_label.text = "E  look beyond     Space  enter the orchard"
		"orchard_mural":
			prompt_label.text = "E  study the water channels"
		"memory_bloom":
			prompt_label.text = "E  listen to the pale bloom"
		"sluice_west", "sluice_north", "sluice_east":
			prompt_label.text = "Space  turn the sluice"
		"archive_gate":
			prompt_label.text = "E  examine     Space  enter the archive"
		"archive_mural":
			prompt_label.text = "E  study the reflected shapes"
		"archive_memory":
			prompt_label.text = "E  listen to the reflecting pool"
		"lens_west", "lens_center", "lens_east":
			prompt_label.text = "Space  turn the lens"
		"archive_stair":
			prompt_label.text = "E  look into the light     Space  climb"
		"seed_bed":
			prompt_label.text = "E  examine     U  plant the pale seed"
		"final_inscription":
			prompt_label.text = "E  examine     U  use the selected keepsake"
	var item_hint := ""
	if id == "arch" and RunState.selected_item_id == "moss_button":
		item_hint = "fit the brass button"
	elif id == "arch" and RunState.selected_item_id == "medallion":
		item_hint = "use the medallion"
	elif id == "inscription" and RunState.selected_item_id == "stone_chip":
		item_hint = "fit the chip"
	elif id == "resonator_water" and RunState.selected_item_id == "old_bead":
		item_hint = "listen with the bead"
	elif id == "archive_mural" and RunState.selected_item_id == "mirror_shard":
		item_hint = "look through the shard"
	elif id == "archive_memory" and RunState.selected_item_id == "river_glass":
		item_hint = "hold up the glass"
	if not item_hint.is_empty() and not prompt_label.text.contains("U  "):
		prompt_label.text += "     U  " + item_hint
	var item_hint := ""
	match [id, RunState.selected_item_id]:
		["arch", "moss_button"]: item_hint = "fit the brass button"
		["arch", "medallion"]: item_hint = "use the medallion"
		["inscription", "stone_chip"]: item_hint = "fit the chip"
		["resonator_water", "old_bead"]: item_hint = "listen with the bead"
		["archive_mural", "mirror_shard"]: item_hint = "look through the shard"
		["archive_memory", "river_glass"]: item_hint = "hold up the glass"
	if not item_hint.is_empty() and not prompt_label.text.contains("U  "):
		prompt_label.text += "     U  " + item_hint

func _examine_target() -> void:
	var target := _nearest_target()
	if target.is_empty():
		_set_status("The quiet gives you time to look around.")
		return
	match target.id:
		"medallion":
			_set_status("A cool medallion rests in the dust. Its worn marks catch the light.")
		"moss_button":
			_set_status("A green brass button, polished by someone's thumb long ago.")
		"arch":
			_set_status("The buried arch is older than the path around it. The medallion stirs in your hand.")
		"beth":
			_wake_beth()
		"inscription":
			_set_status("The inscription shifts at the edge of sight, but the marks remain unreadable.")
			if RunState.record_clue("gibberish_inscription"):
				Soundscape.play_event("journal")
				RunState.set_story_flag("inscription_seen")
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
		"sluice_west":
			_set_status("The western sluice points %s. The mural shows the channel turning inward." % _direction_name(_get_valve_orientation("west")))
		"sluice_north":
			_set_status("The northern sluice points %s. The mural shows the channel turning inward." % _direction_name(_get_valve_orientation("north")))
		"sluice_east":
			_set_status("The eastern sluice points %s. The mural shows the channel turning inward." % _direction_name(_get_valve_orientation("east")))
		"archive_gate":
			_set_status("The stone lintel is marked with the same three shapes as the mural.")
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
		"lens_west":
			_set_status("The western lens can turn through four resting positions.")
		"lens_center":
			_set_status("The central lens catches a thin thread of light.")
		"lens_east":
			_set_status("The eastern lens points toward the sealed stair.")
		"archive_stair":
			_set_status("A narrow stair descends toward a pale, starless glow.")
		"final_inscription":
			_set_status("The same unreadable marks from the first ruin. The medallion warms in your hand.")

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
		_set_status("You tuck away %s. Press I to choose or inspect keepsakes." % _item_name(item_id))
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
	elif target.id == "archive_gate" and RunState.story_flags.get("orchard_water_restored", false):
		_enter_archive()
	elif target.id.begins_with("lens_"):
		_rotate_archive_lens(target.id.trim_prefix("lens_"))
	elif target.id == "archive_stair" and RunState.story_flags.get("archive_puzzle_solved", false):
		_enter_observatory()
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
		_set_status("In the shard, a fourth path crosses the ceiling map and ends at the empty pool.")
		return
	if target.id == "archive_memory" and item_id == "river_glass":
		_record_clue_animated("river_glass_memory")
		_set_status("The green glass catches a thread of reflected water beneath the false sky.")
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
		if RunState.record_clue("orchard_water_memory"):
			_animate_journal_signal()
		_set_status("Water threads through the channels and gathers in the basin. Hidden stones rise from the earth.")
		_update_objective()
	else:
		Soundscape.play_event("resonance")
		_set_status("Stone turns beneath your hand. %d of 3 channels now point toward the basin." % opened)
	queue_redraw()

func _get_valve_orientation(which: String) -> int:
	var states: Dictionary = RunState.puzzle_progress.get("orchard_valves", {})
	return _valve_orientation(states.get(which, 0))

func _valve_orientation(value: Variant) -> int:
	if value is bool:
		return 1 if value else 0
	return posmod(int(value), 4)

func _direction_name(direction: int) -> String:
	return ["north", "east", "south", "west"][posmod(direction, 4)]

func _enter_orchard() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, 0.45)
	await fade_out.finished
	phase = "orchard"
	Soundscape.set_area(phase)
	RunState.set_story_flag("reached_orchard")
	traveler.global_position = Vector2(320, 248)
	beth.global_position = Vector2(337, 232)
	beth.visible = true
	beth.awake = true
	camera_target_rotation = 0.0
	_set_status("The path descends into a quiet orchard, where dry channels cross the grass.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, 0.65)
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_archive() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, 0.4)
	await fade_out.finished
	phase = "archive"
	Soundscape.set_area(phase)
	RunState.set_story_flag("reached_archive")
	traveler.global_position = Vector2(320, 248)
	camera_target_rotation = 0.0
	_set_status("The archive holds its breath beneath the orchard. Beth's light doubles in the still water.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, 0.6)
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _enter_observatory() -> void:
	if transitioning:
		return
	transitioning = true
	traveler.set_movement_enabled(false)
	var fade_out := create_tween()
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, 0.4)
	await fade_out.finished
	phase = "observatory"
	Soundscape.set_area(phase)
	RunState.set_story_flag("reached_observatory")
	traveler.global_position = Vector2(320, 250)
	camera_target_rotation = 0.0
	_set_status("The stair opens beneath a roofless observatory. The old inscription waits in the starlight.")
	Soundscape.play_event("complete")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, 0.7)
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _begin_inscription_reveal() -> void:
	if transitioning:
		return
	transitioning = true
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
	open_tween.tween_property(inscription_panel, "position:y", 62.0, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await open_tween.finished
	Soundscape.play_event("journal")
	var reveal_tween := create_tween()
	for count in range(1, FINAL_INSCRIPTION.length() + 1):
		reveal_tween.tween_callback(_show_inscription_reveal.bind(count))
		reveal_tween.tween_interval(0.14)
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
	RunState.set_story_flag("ending_revealed")
	RunState.record_clue("message_from_past")
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
	var aligned := true
	for name in ["west", "center", "east"]:
		if int(lenses.get(name, 0)) != int(ARCHIVE_SOLUTION[name]):
			aligned = false
	if aligned:
		RunState.set_story_flag("archive_puzzle_solved")
		RunState.record_clue("archive_hidden_stair")
		RunState.reset_local_hint_echo()
		Soundscape.play_event("complete")
		_set_status("The reflections meet. A stair appears where the light touches the floor.")
		_update_objective()
	else:
		_set_status("The light slips across the water and settles into another angle.")
	queue_redraw()

func _activate_resonator(symbol: String) -> void:
	if not RunState.story_flags.get("beth_awake", false):
		_set_status("A soft pulse travels through the stone, then fades. Something is still asleep nearby.")
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
			_set_status("The three notes join. Stone eases aside, revealing a path beneath the gate.")
			_update_objective()
			queue_redraw()
		else:
			var next_name := ["crescent", "rain-line", "seed"][progress]
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
	fade_out.tween_property(transition_cover, "modulate:a", 1.0, 0.45)
	await fade_out.finished
	phase = "ruins"
	Soundscape.set_area(phase)
	RunState.set_story_flag("crossed_into_world")
	traveler.global_position = Vector2(285, 248)
	traveler.movement_bounds = Rect2(22, 40, 596, 300)
	beth.visible = true
	beth.global_position = Vector2(344, 214)
	beth.awake = false
	_set_status("On the other side, a small blue-white light sleeps among the ruins.")
	_update_objective()
	queue_redraw()
	var fade_in := create_tween()
	fade_in.tween_property(transition_cover, "modulate:a", 0.0, 0.65)
	await fade_in.finished
	traveler.set_movement_enabled(true)
	transitioning = false

func _open_journal() -> void:
	journal_panel = PanelContainer.new()
	journal_panel.position = Vector2(36, 180)
	journal_panel.size = Vector2(248, 112)
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
	if RunState.journal_entries.is_empty():
		column.add_child(_new_label("No clues recorded yet.", 7, Color("#d2d5c8"), Vector2.ZERO, Vector2.ZERO))
	else:
		for clue_id in RunState.journal_entries:
			var entry := _new_label(_clue_text(clue_id), 7, Color("#d2d5c8"), Vector2.ZERO, Vector2.ZERO)
			entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			column.add_child(entry)
	var close_hint := _new_label("J / Esc  close", 6, Color("#94a39e"), Vector2.ZERO, Vector2.ZERO)
	column.add_child(close_hint)
	hud.add_child(journal_panel)
	var tween := create_tween()
	tween.tween_property(journal_panel, "position:y", 34.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _close_journal() -> void:
	var panel := journal_panel
	journal_panel = null
	var tween := create_tween()
	tween.tween_property(panel, "position:y", 180.0, 0.2)
	tween.tween_callback(panel.queue_free)

func _open_inventory() -> void:
	if inventory_panel != null or transitioning:
		return
	traveler.set_movement_enabled(false)
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
			item_button.custom_minimum_size = Vector2(154, 14)
			item_button.add_theme_font_size_override("font_size", 7)
			item_button.pressed.connect(_select_inventory_item.bind(item_id))
			row.add_child(item_button)
			var item_action := Button.new()
			item_action.custom_minimum_size = Vector2(58, 14)
			item_action.add_theme_font_size_override("font_size", 6)
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
	close.text = "I / Esc  close"
	close.custom_minimum_size = Vector2(224, 15)
	close.add_theme_font_size_override("font_size", 6)
	close.pressed.connect(_close_inventory)
	column.add_child(close)
	hud.add_child(inventory_panel)
	if RunState.inventory.has(RunState.selected_item_id):
		inventory_description_label.text = _item_description(RunState.selected_item_id)
	var tween := create_tween()
	tween.tween_property(inventory_panel, "position:y", 20.0, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _close_inventory() -> void:
	var panel := inventory_panel
	if panel == null:
		return
	inventory_panel = null
	inventory_description_label = null
	if pending_pickup_id != "":
		pending_pickup_id = ""
	var tween := create_tween()
	tween.tween_property(panel, "position:y", 180.0, 0.16)
	tween.tween_callback(func() -> void:
		panel.queue_free()
		if is_instance_valid(traveler) and not transitioning:
			traveler.set_movement_enabled(true)
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
	var close_hint := _new_label("H / Esc  close", 6, Color("#94a39e"), Vector2.ZERO, Vector2.ZERO)
	column.add_child(close_hint)
	hud.add_child(hint_panel)
	var tween := create_tween()

	tween.tween_property(hint_panel, "position:y", 37.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

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
	tween.tween_property(panel, "position:y", 180.0, 0.18)
	tween.tween_callback(panel.queue_free)

func _give_hint(level: int) -> void:
	var echo_cost := RunState.add_hint(level)
	beth.react_to_hint(echo_cost)
	var hint_text := ""
	if phase == "orchard":
		match level:
			1:
				hint_text = "Beth listens along the three dry channels."
			2:
				hint_text = "The mural shows each channel pointing inward toward the basin."
			3:
				hint_text = "Point the western sluice east, the northern sluice south, and the eastern sluice west."
	elif phase == "archive":
		match level:
			1:
				hint_text = "Beth watches the three lenses without blinking."
			2:
				hint_text = "The ceiling shows right, down, then left."
			3:
				hint_text = "Point west right, center down, and east left."
	else:
		match level:
			1:
				hint_text = "Beth tilts toward the crescent-shaped stone."
			2:
				hint_text = "Start with the crescent. Follow it with the rain-line."
			3:
				hint_text = "Attune the crescent, then rain-line, then seed."
	_set_status(hint_text)
	Soundscape.play_event("hint")
	_close_hint_panel()
	queue_redraw()

func _open_pause_menu() -> void:
	if pause_panel != null or transitioning:
		return
	traveler.set_movement_enabled(false)
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
	resume.custom_minimum_size = Vector2(190, 17)
	resume.add_theme_font_size_override("font_size", 8)
	resume.pressed.connect(_close_pause_menu)
	column.add_child(resume)
	var save_and_leave := Button.new()
	save_and_leave.text = "Save and return to title"
	save_and_leave.custom_minimum_size = Vector2(190, 17)
	save_and_leave.add_theme_font_size_override("font_size", 8)
	save_and_leave.pressed.connect(_save_and_return_to_title)
	column.add_child(save_and_leave)
	hud.add_child(pause_panel)
	resume.call_deferred("grab_focus")
	var tween := create_tween()
	tween.tween_property(pause_panel, "position:y", 49.0, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _close_pause_menu() -> void:
	var panel := pause_panel
	if panel == null:
		return
	pause_panel = null
	var tween := create_tween()
	tween.tween_property(panel, "position:y", 180.0, 0.16)
	tween.tween_callback(func() -> void:
		panel.queue_free()
		if is_instance_valid(traveler) and not transitioning:
			traveler.set_movement_enabled(true)
	)

func _save_and_return_to_title() -> void:
	RunState.save_game()
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")

func _animate_journal_signal() -> void:
	if is_instance_valid(inventory_label):
		var tween := create_tween()
		tween.tween_property(inventory_label, "modulate", Color("#e3dfb5"), 0.12)
		tween.tween_property(inventory_label, "modulate", Color("#bdc8bb"), 0.5)

func _record_clue_animated(clue_id: String) -> void:
	if RunState.record_clue(clue_id):
		Soundscape.play_event("journal")
		_animate_journal_signal()

func _clue_text(clue_id: String) -> String:
	match clue_id:
		"gibberish_inscription":
			return "At the ruin wall: a line of marks, still unreadable."
		"resonance_mosaic":
			return "A worn mosaic repeats three shapes: crescent, rain-line, seed."
		"orchard_memory":
			return "A pale flower chimed as the orchard water returned."
		"orchard_water_memory":
			return "Three sluices feed the same basin; water returns to the garden."
		"archive_reflection_map":
			return "The archive ceiling shows a reflection turning right, down, then left."
		"archive_memory":
			return "The reflecting pool holds a sky that is absent above the ruins."
		"archive_hidden_stair":
			return "Aligned lenses reveal a stair below the archive."
		"matching_stone_cuts":
			return "A broken chip fits a narrow break at the observatory inscription."
		"crossing_sun_mark":
			return "A green brass button fits an old mark on the buried arch."
		"quiet_garden_memory":
			return "A small green shoot returned where the orchard channels meet."
		"archive_second_image":
			return "A silvered shard shows one more path in the archive ceiling."
		"river_glass_memory":
			return "Green river glass catches a hidden thread beneath the pool's false sky."
		"bead_resonance":
			return "A blue fleck in a cloudy bead answers the rain-line with a low note."
		"message_from_past":
			return "The old inscription changed: Your hand has been here before."
		_:
			return clue_id.replace("_", " ").capitalize()

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
			elif not RunState.story_flags.get("first_gate_open", false):
				objective_label.text = "Listen for the old stones"
			else:
				objective_label.text = "Pass through the opened gate"
		"orchard":
			objective_label.text = "Bring water back to the orchard" if not RunState.story_flags.get("orchard_water_restored", false) else "Find a way into the archive"
		"archive":
			objective_label.text = "Study the ceiling mural" if not RunState.story_flags.get("archive_mural_seen", false) else ("Align the three lenses" if not RunState.story_flags.get("archive_puzzle_solved", false) else "Follow the reflected light")
		"observatory":
			objective_label.text = "Approach the old inscription" if not RunState.story_flags.get("ending_revealed", false) else "The world remembers"

func _update_hud(_items: Array[String] = []) -> void:
	if inventory_label == null:
		return
	if RunState.selected_item_id.is_empty():
		inventory_label.text = "I  Keepsakes %d / %d" % [RunState.inventory.size(), RunState.INVENTORY_LIMIT]
	else:
		inventory_label.text = "I  Active: %s   (%d / %d)" % [_item_name(RunState.selected_item_id), RunState.inventory.size(), RunState.INVENTORY_LIMIT]

func _on_hint_echo_changed(_value: int) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#18282b"))
	_draw_ground()
	if phase == "crossing":
		_draw_threshold()
	elif phase == "orchard":
		_draw_orchard()
	elif phase == "archive":
		_draw_archive()
	elif phase == "observatory":
		_draw_observatory()
	else:
		_draw_ruins()
	_draw_hint_echo()

func _draw_ground() -> void:
	var echo_tint := _ambient_echo()
	for i in range(0, 41):
		for j in range(0, 41):
			var center := Vector2(320 + (i - j) * 16, 42 + (i + j) * 8)
			if center.x < -24 or center.x > WORLD_SIZE.x + 24 or center.y < -16 or center.y > WORLD_SIZE.y + 16:
				continue
			var path_tile := abs(i - j) <= 1
			var court_tile := abs(i - 20) <= 5 and abs(j - 20) <= 5
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
	_draw_tree(Vector2(126, 163), Color("#253c39"))
	_draw_tree(Vector2(536, 184), Color("#2a4038"))
	_draw_altar(Vector2(302, 222))
	if RunState.journal_entries.has("crossing_sun_mark"):
		_draw_symbol(Vector2(420, 132), "seed", Color("#d6c995"))
	if not RunState.story_flags.get("moss_button_found", false):
		draw_rect(Rect2(188, 248, 4, 3), Color("#788c70"))
		draw_rect(Rect2(189, 247, 2, 1), Color("#b8aa76"))
	_draw_arch(Vector2(420, 170), false)
	_draw_stone(Vector2(365, 218), 8, Color("#69756b"))
	_draw_stone(Vector2(468, 204), 11, Color("#58685f"))
	_draw_stone(Vector2(204, 187), 6, Color("#78816e"))
	draw_rect(Rect2(120, 286, 86, 2), Color("#283b35"))
	draw_rect(Rect2(448, 288, 70, 2), Color("#273a35"))

func _draw_ruins() -> void:
	_draw_tree(Vector2(116, 156), Color("#263a38"))
	_draw_tree(Vector2(540, 190), Color("#2b4039"))
	_draw_arch(Vector2(320, 152), RunState.story_flags.get("first_gate_open", false))
	_draw_inscription(Vector2(232, 177))
	_draw_mosaic(Vector2(276, 165))

	_draw_resonator(Vector2(272, 226), "moon", 0)
	_draw_resonator(Vector2(320, 199), "water", 1)
	_draw_resonator(Vector2(368, 226), "seed", 2)
	_draw_stone(Vector2(180, 224), 9, Color("#65756b"))
	_draw_stone(Vector2(448, 240), 12, Color("#5f7068"))
	_draw_stone(Vector2(215, 255), 6, Color("#707a68"))
	if not RunState.story_flags.get("old_bead_found", false):
		draw_rect(Rect2(178, 248, 5, 3), Color("#657b79"))
		draw_rect(Rect2(179, 249, 2, 2), Color("#9acbd2"))
	if RunState.story_flags.get("inscription_seen", false) and not RunState.story_flags.get("stone_chip_found", false):
		draw_rect(Rect2(229, 200, 5, 3), Color("#aaa18a"))
	if RunState.story_flags.get("first_gate_open", false):
		draw_rect(Rect2(312, 163, 16, 2), Color("#a9d7cc"))

func _draw_orchard() -> void:
	_draw_tree(Vector2(126, 156), Color("#34483d"))
	_draw_tree(Vector2(516, 160), Color("#354b3f"))
	_draw_tree(Vector2(468, 282), Color("#30453a"))
	_draw_tree(Vector2(174, 286), Color("#344a3d"))
	draw_rect(Rect2(185, 211, 270, 3), Color("#34483f"))
	draw_rect(Rect2(188, 215, 262, 4), Color("#53685a"))
	draw_rect(Rect2(312, 176, 16, 112), Color("#354a41"))
	draw_rect(Rect2(315, 178, 10, 110), Color("#61766a"))
	draw_rect(Rect2(221, 182, 48, 28), Color("#786f5d"))
	draw_rect(Rect2(225, 186, 40, 20), Color("#4f5b53"))
	for index in range(4):
		draw_rect(Rect2(230 + index * 9, 191 + (index % 2) * 4, 4, 3), Color("#a7aa85"))
	_draw_arrow(Vector2(232, 193), 1, Color("#c2c09c"))
	_draw_arrow(Vector2(245, 193), 2, Color("#a5c3bc"))
	_draw_arrow(Vector2(258, 193), 3, Color("#b0bd99"))
	_draw_orchard_sluice(Vector2(260, 226), "west", 0)
	_draw_orchard_sluice(Vector2(320, 198), "north", 1)
	_draw_orchard_sluice(Vector2(380, 226), "east", 2)
	var valves: Dictionary = RunState.puzzle_progress.get("orchard_valves", {})
	for name in ["west", "north", "east"]:
		if _valve_orientation(valves.get(name, 0)) == int(ORCHARD_SOLUTION[name]) or RunState.story_flags.get("orchard_water_restored", false):
			_draw_water_channel(name)
	_draw_tree(Vector2(430, 196), Color("#526652"))
	draw_rect(Rect2(426, 186, 8, 7), Color("#c3d7bf"))
	draw_rect(Rect2(428, 184, 4, 2), Color("#e0e9d2"))
	if RunState.story_flags.get("orchard_water_restored", false):
		_draw_arch(Vector2(320, 145), true)
		draw_rect(Rect2(306, 209, 28, 2), Color("#9fc9be"))
		for index in range(3):
			draw_rect(Rect2(306 + index * 5, 205 - index % 2, 3, 2), Color("#badbd0"))
		if not RunState.story_flags.get("river_glass_found", false):
			draw_rect(Rect2(458, 260, 5, 2), Color("#84b6ad"))
			draw_rect(Rect2(460, 259, 3, 1), Color("#c0d6bc"))
	if RunState.story_flags.get("quiet_garden_restored", false):
		_draw_tree(Vector2(215, 261), Color("#68785b"))
		draw_rect(Rect2(212, 238, 6, 4), Color("#bcc99a"))
		draw_rect(Rect2(213, 236, 4, 2), Color("#e0dfb6"))
	elif RunState.story_flags.get("orchard_water_restored", false):
		draw_rect(Rect2(199, 260, 32, 8), Color("#645d49"))
		draw_rect(Rect2(203, 258, 24, 2), Color("#7b7255"))

func _draw_orchard_sluice(pos: Vector2, name: String, index: int) -> void:
	var valves: Dictionary = RunState.puzzle_progress.get("orchard_valves", {})
	var orientation := _valve_orientation(valves.get(name, 0))
	var is_aligned := orientation == int(ORCHARD_SOLUTION[name]) or RunState.story_flags.get("orchard_water_restored", false)
	var body := Color("#77806b") if not is_aligned else Color("#a0aa83")
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-12, 7), pos + Vector2(0, 0),
		pos + Vector2(12, 7), pos + Vector2(0, 13)
	]), Color("#34443e"))
	draw_rect(Rect2(pos.x - 7, pos.y - 8, 14, 14), body)
	draw_rect(Rect2(pos.x - 8, pos.y - 10, 16, 3), Color("#9b9c7a"))
	_draw_arrow(pos + Vector2(0, -1), orientation, Color("#8bc2c0") if is_aligned else Color("#4f6159"))

func _draw_water_channel(name: String) -> void:
	var water := Color("#6eaaa8")
	match name:
		"west":
			draw_rect(Rect2(268, 223, 42, 2), water)
		"north":
			draw_rect(Rect2(318, 204, 3, 18), water)
		"east":
			draw_rect(Rect2(330, 223, 42, 2), water)

func _draw_archive() -> void:
	draw_rect(Rect2(76, 88, 22, 147), Color("#3b4546"))
	draw_rect(Rect2(542, 88, 22, 147), Color("#3b4546"))
	for row in range(7):
		for shelf in range(2):
			var sx := 81 if shelf == 0 else 547
			var sy := 95 + row * 18
			draw_rect(Rect2(sx, sy, 12, 2), Color("#738078"))
			for book in range(4):
				var color := [Color("#817568"), Color("#5e7370"), Color("#8a8165"), Color("#4f6470")][(row + book) % 4]
				draw_rect(Rect2(sx + 1 + book * 3, sy - 5, 2, 5), color)
	draw_rect(Rect2(197, 206, 247, 44), Color("#344545"))
	draw_rect(Rect2(203, 211, 235, 33), Color("#567172"))
	draw_rect(Rect2(220, 219, 201, 15), Color("#79918c"))
	draw_rect(Rect2(250, 156, 39, 24), Color("#6d756a"))
	draw_rect(Rect2(254, 160, 31, 16), Color("#4d5c57"))
	_draw_archive_arrows(Vector2(270, 168))
	_draw_archive_lens(Vector2(264, 220), "west")
	_draw_archive_lens(Vector2(320, 194), "center")
	_draw_archive_lens(Vector2(376, 220), "east")
	draw_rect(Rect2(430, 183, 9, 8), Color("#bacdc0"))
	draw_rect(Rect2(432, 180, 5, 3), Color("#e1e5d0"))
	if RunState.story_flags.get("archive_puzzle_solved", false):
		draw_line(Vector2(264, 214), Vector2(320, 190), Color("#a9d7cc"), 1.0)
		draw_line(Vector2(320, 190), Vector2(376, 214), Color("#a9d7cc"), 1.0)
		draw_rect(Rect2(309, 147, 22, 4), Color("#9ebbb2"))
		draw_rect(Rect2(313, 139, 14, 9), Color("#657c73"))
		draw_rect(Rect2(316, 133, 8, 7), Color("#bfd7c7"))
	if not RunState.story_flags.get("mirror_shard_found", false):
		draw_rect(Rect2(472, 253, 5, 3), Color("#97babb"))
		draw_rect(Rect2(473, 252, 2, 1), Color("#d6e4da"))

func _draw_archive_arrows(pos: Vector2) -> void:
	_draw_arrow(pos + Vector2(-9, 0), 1, Color("#c2c09c"))
	_draw_arrow(pos, 2, Color("#a5c3bc"))
	_draw_arrow(pos + Vector2(9, 0), 3, Color("#b0bd99"))

func _draw_archive_lens(pos: Vector2, name: String) -> void:
	var lenses: Dictionary = RunState.puzzle_progress.get("archive_lenses", {})
	var direction := int(lenses.get(name, 0))
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-14, 7), pos + Vector2(0, 0),
		pos + Vector2(14, 7), pos + Vector2(0, 14)
	]), Color("#2e3c3d"))
	draw_rect(Rect2(pos.x - 9, pos.y - 7, 18, 13), Color("#596a66"))
	draw_rect(Rect2(pos.x - 7, pos.y - 9, 14, 3), Color("#89978a"))
	draw_rect(Rect2(pos.x - 4, pos.y - 5, 8, 8), Color("#b5c8b8"))
	_draw_arrow(pos + Vector2(0, -1), direction, Color("#607d7d"))

func _draw_observatory() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#15232e"))
	for index in range(55):
		var x := (index * 79 + 23) % 640
		var y := (index * 37 + 11) % 170
		var star := Color("#a8bec4")
		star.a = 0.45 if index % 4 == 0 else 0.78
		draw_rect(Rect2(x, y, 1, 1), star)
	draw_rect(Rect2(0, 174, 640, 186), Color("#243339"))
	for index in range(18):
		var x := index * 38
		draw_rect(Rect2(x, 250 + index % 3 * 4, 24, 2), Color("#34464a"))
	draw_rect(Rect2(104, 96, 13, 93), Color("#3d4b4c"))
	draw_rect(Rect2(523, 88, 14, 101), Color("#3b484a"))
	draw_rect(Rect2(93, 91, 36, 8), Color("#58675f"))
	draw_rect(Rect2(513, 83, 34, 8), Color("#59675e"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(260, 286), Vector2(320, 254), Vector2(380, 286), Vector2(320, 319)
	]), Color("#495c59"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(274, 286), Vector2(320, 262), Vector2(366, 286), Vector2(320, 309)
	]), Color("#61716a"))
	_draw_final_inscription(Vector2(320, 164))
	_draw_altar(Vector2(320, 238))
	for index in range(4):
		draw_rect(Rect2(304 + index * 10, 241 + (index % 2), 3, 2), Color("#a4c8bf"))

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
	var activated := RunState.story_flags.get("first_gate_open", false) or index < progress
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

