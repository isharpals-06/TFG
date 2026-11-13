extends RefCounted

static func get_hint(phase: String, level: int, story_flags: Dictionary, journal_entries: Array[String]) -> String:
	var hint_level := clampi(level, 1, 3)
	if phase == "ruins":
		if story_flags.get("first_gate_open", false):
			return _pick(hint_level, "Beth slips through a patch of sunlight beyond the stones.", "The gate behind the middle stone has opened.", "Activate the open gate to enter the orchard.")
		if not story_flags.get("inscription_seen", false):
			return _pick(hint_level, "Beth brushes dust from a groove in the old wall.", "Above the place where Beth slept, a line of cuts runs across the stone.", "Examine the inscription on the western wall.")
		if not story_flags.get("resonance_clue_seen", false):
			return _pick(hint_level, "A fleck of colored plaster clings to Beth's light.", "Beyond the inscription, three shapes survive on the higher wall.", "Examine the faded mosaic above the crescent resonator.")
		return _pick(hint_level, "Beth traces the first curve of the mosaic in the air.", "Match each shape on the mosaic to a stone, reading from left to right.", "Attune the crescent, then rain-line, then seed.")
	if phase == "reed_causeway":
		return _pick(hint_level, "Beth follows a ripple up the stones, then watches it return to shore.", "The shoreline marks rise to the far stone and descend in reverse.", "Activate near, second, third, far, third, second, then near.")
	if phase == "empty_quarter":
		if story_flags.get("village_gathering_marks_seen", false) and not story_flags.get("village_gathering_solved", false):
			return _pick(hint_level, "Beth follows the carved line around the well, then pauses at its first mark.", "The rim says to set aside water, leave a lamp, then ring once.", "Activate bowl, lamp, then bell.")
		return _pick(hint_level, "Beth peers past the niches into the houses. Examine a doorway to see what its owner left behind.", "The ink belonged to a reader, the ladle to a cook. Look for signs of planting and lamplight at the other doors.", "West holds the book, north the bowl, east the seed, and south the lamp.")
	if phase == "reading_room":
		return _pick(hint_level, "Beth keeps drifting back to the children's lesson slate.", "Arrange the three study markers in the same order as the slate, from west to east.", "Set boat at the west mark, lantern at center, and reeds at the east mark.")
	if phase == "orchard":
		return _pick(hint_level, "Beth listens along the three dry channels.", "The mural shows each channel pointing inward toward the basin.", "Point the western sluice east, the northern sluice south, and the eastern sluice west.")
	if phase == "waterworks":
		return _pick(hint_level, "Beth listens to the three waterwheels, then looks back toward the channel map.", "The map's four marks give the wheel order; the crescents repeat on the middle wheel.", "Turn western, middle, eastern, then middle waterwheel.")
	if phase == "cistern_vault":
		return _pick(hint_level, "Beth follows the quiet water from the eastern channel toward the western one.", "The water clock gives four turns: east, west, center, west.", "Turn the eastern valve, western, center, then western again.")
	if phase == "archive":
		if story_flags.get("archive_puzzle_solved", false) and journal_entries.has("archive_second_image"):
			return _pick(hint_level, "Beth follows the shard's pale line back over the three lenses.", "The fourth reflection points north from west, east from center, and south from east.", "Turn west north, center east, and east south.")
		return _pick(hint_level, "Beth watches the three lenses without blinking.", "The ceiling shows right, down, then left.", "Point west right, center down, and east left.")
	if phase == "map_chamber":
		return _pick(hint_level, "Beth peers at the little cart tracks. Inspect the places along the river.", "Start where clean water fills the cart. Compare the flood marks and look for wheel ruts on dry ground.", "Trace the spring, the bridge, then the village.")
	if phase == "gallery":
		return _pick(hint_level, "Beth watches the quiet water beneath the three mirror stones.", "Read the mural from west to east, then turn each stone to match the direction shown.", "Point west north, center south, and east west.")
	if phase == "bell_court":
		if story_flags.get("bell_echo_variant", false):
			return _pick(hint_level, "Beth's light lingers on a fifth, fainter mark at the end of the carving.", "Follow the first four notes, then ring the pale rain-line once more.", "Ring crescent, rain-line, seed, crescent, then rain-line.")
		return _pick(hint_level, "Beth's light rises and falls with the marks on the garden wall.", "The carving gives four notes. Ring them from left to right, including the repeated mark.", "Ring crescent, rain-line, seed, then crescent.")
	if phase == "high_steps":
		if not story_flags.get("high_steps_map_seen", false):
			return _pick(hint_level, "Beth pauses by the wind-worn map above the trail.", "Study the map set into the stone beside the upper path.", "Examine the wind-worn map before turning the vanes.")
		if not story_flags.get("high_steps_aligned", false):
			if story_flags.get("high_steps_echo_variant", false):
				return _pick(hint_level, "Beth brushes dust off the newer plate, then circles the trail lantern.", "The middle vane now guides people back to the refuge. Read the lantern shutters and cairn for bearings.", "Point the western vane west, the middle vane south, and the eastern vane east.")
			return _pick(hint_level, "Beth flits from the little cairn to the shutters on the trail lantern.", "Read the destinations on the map from left to right. Match each to a bearing on the cairn or lantern.", "Point the western vane west, the middle vane north, and the eastern vane east.")
		if not story_flags.get("high_steps_cairn_seen", false):
			return _pick(hint_level, "A small stack of stones stands beside the ridge path.", "Look near the fork below the eastern vane.", "Examine the little trail cairn near the eastern side of the path.")
		return _pick(hint_level, "Beth watches the open ridge path in the wind.", "The upper door is ready whenever you are.", "Follow the marked trail through the open door.")
	if phase == "highland_refuge":
		return _pick(hint_level, "Beth rests in the sheltered light, then looks toward the ridge path.", "The guest book and lantern hold small pieces of the refuge's story.", "Examine the map, guest book, and lantern; the path to the high steps stays open.")
	if phase == "quiet_garden":
		return _pick(hint_level, "Beth listens to the glass chimes above the seedling.", "The wall carving gives three marks from left to right.", "Ring rain-line, seed, then crescent.")
	if phase == "observatory":
		if not story_flags.get("observatory_orrery_solved", false):
			return _pick(hint_level, "Beth keeps returning to the brass arms beside the old chart.", "Read the keeper's chart, then point the three marked arms where it says.", "Point the crescent west, the rain-line north, and the seed east.")
		return _pick(hint_level, "Beth's light lingers over the hollow beneath the inscription.", "The medallion's edge fits the empty space in the old stone.", "Choose the medallion and use it on the inscription.")
	return "Beth rests quietly beside you."

static func _pick(level: int, first: String, second: String, third: String) -> String:
	match level:
		1: return first
		2: return second
		_: return third
