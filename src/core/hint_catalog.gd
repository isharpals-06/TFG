extends RefCounted

static func get_hint(phase: String, level: int, story_flags: Dictionary, journal_entries: Array[String]) -> String:
	var hint_level := clampi(level, 1, 3)
	if phase == "crossing":
		if not story_flags.get("medallion_found", false):
			return _pick(hint_level, "Beth peers through the grass beside the old stones.", "A small glint rests just left of the worn path.", "The medallion lies beside the path, near the buried stones.")
		return _pick(hint_level, "Beth's light circles the arch, then the medallion in your hand.", "The disk's low pulse grows stronger beside the buried arch.", "Choose the medallion and use it on the arch.")
	if phase == "reed_causeway":
		return _pick(hint_level, "Beth follows a ripple up the stones, then watches it return to shore.", "The shoreline marks rise to the far stone and descend in reverse.", "Activate near, second, third, far, third, second, then near.")
	if phase == "empty_quarter":
		if story_flags.get("village_gathering_marks_seen", false) and not story_flags.get("village_gathering_solved", false):
			return _pick(hint_level, "Beth follows the carved line around the well, then pauses at its first mark.", "The rim says to set aside water, leave a lamp, then ring once.", "Activate bowl, lamp, then bell.")
		return _pick(hint_level, "Beth watches the four doorways around the well.", "The carving pairs a household symbol with each side of the square.", "West holds the book, north the bowl, east the seed, and south the lamp.")
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
		return _pick(hint_level, "Beth traces the river from its spring toward the old bridge.", "The keeper marked the spring first, then the bridge, then the village.", "Activate spring, bridge, then village in that order.")
	if phase == "gallery":
		return _pick(hint_level, "Beth watches the quiet water beneath the three mirror stones.", "Read the mural from west to east, then turn each stone to match the direction shown.", "Point west north, center south, and east west.")
	if phase == "bell_court":
		if story_flags.get("bell_echo_variant", false):
			return _pick(hint_level, "Beth's light lingers on a fifth, fainter mark at the end of the carving.", "Follow the first four notes, then ring the pale rain-line once more.", "Ring crescent, rain-line, seed, crescent, then rain-line.")
		return _pick(hint_level, "Beth's light rises and falls with the marks on the garden wall.", "The carving gives four notes. Ring them from left to right, including the repeated mark.", "Ring crescent, rain-line, seed, then crescent.")
	if phase == "high_steps":
		if story_flags.get("high_steps_echo_variant", false):
			return _pick(hint_level, "Beth watches the doubled arrow on the map, where the old direction still lingers.", "Follow the pale arrow for the middle vane; it points south.", "Point the western vane west, the middle vane south, and the eastern vane east.")
		return _pick(hint_level, "Beth watches the three vanes turn over the valley.", "The map gives one direction for each vane, from west to east.", "Point the western vane west, the middle vane north, and the eastern vane east.")
	if phase == "highland_refuge":
		return _pick(hint_level, "Beth rests in the sheltered light, then looks toward the ridge path.", "The guest book and lantern hold small pieces of the refuge's story.", "Examine the map, guest book, and lantern; the path to the high steps stays open.")
	if phase == "quiet_garden":
		return _pick(hint_level, "Beth listens to the glass chimes above the seedling.", "The wall carving gives three marks from left to right.", "Ring rain-line, seed, then crescent.")
	if phase == "observatory":
		if not story_flags.get("observatory_orrery_solved", false):
			return _pick(hint_level, "Beth keeps returning to the brass arms beside the old chart.", "Read the keeper's chart, then point the three marked arms where it says.", "Point the crescent west, the rain-line north, and the seed east.")
		return _pick(hint_level, "Beth's light lingers over the hollow beneath the inscription.", "The medallion's edge fits the empty space in the old stone.", "Choose the medallion and use it on the inscription.")
	return _pick(hint_level, "Beth tilts toward the crescent-shaped stone.", "Start with the crescent. Follow it with the rain-line.", "Attune the crescent, then rain-line, then seed.")

static func _pick(level: int, first: String, second: String, third: String) -> String:
	match level:
		1: return first
		2: return second
		_: return third
