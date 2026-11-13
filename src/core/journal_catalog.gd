extends RefCounted

static func get_place_name(clue_id: String) -> String:
	if clue_id.begins_with("crossing_"):
		return "The buried crossing"
	if clue_id.begins_with("ruins_") or clue_id in ["gibberish_inscription", "bead_resonance", "resonance_mosaic"]:
		return "The first ruins"
	if clue_id.begins_with("orchard_"):
		return "The quiet orchard"
	if clue_id.begins_with("causeway_"):
		return "The reed causeway"
	if clue_id.begins_with("waterworks_"):
		return "The old waterworks"
	if clue_id.begins_with("cistern_"):
		return "The lower cistern"
	if clue_id.begins_with("quarter_") or clue_id.begins_with("village_"):
		return "The empty quarter"
	if clue_id.begins_with("reading_"):
		return "The reading room"
	if clue_id.begins_with("archive_") or clue_id == "river_glass_memory":
		return "The Archive"
	if clue_id.begins_with("map_chamber_"):
		return "The map chamber"
	if clue_id.begins_with("gallery_"):
		return "The reflection gallery"
	if clue_id.begins_with("bell_"):
		return "The bell garden"
	if clue_id.begins_with("refuge_"):
		return "The highland refuge"
	if clue_id.begins_with("high_steps_"):
		return "The High Steps"
	if clue_id.begins_with("quiet_garden_"):
		return "The quiet garden"
	if clue_id.begins_with("observatory_") or clue_id == "message_from_past":
		return "The observatory"
	if clue_id == "matching_stone_cuts":
		return "The old inscription"
	return "The journey"

static func get_text(clue_id: String, story_flags: Dictionary) -> String:
	match clue_id:
		"crossing_floodlines":
			return "Three floodlines climb the roadstone. Beyond the highest, someone carved a row of little boats."
		"ruins_kiln_tag":
			return "The kiln's last clay tag says: bowls packed first; bells left to dry."
		"orchard_grafts_uphill":
			return "A grafting label lists trees sent uphill when the river failed. Each orchard tree began as a cutting."
		"causeway_rhythm":
			return "Seven waterlines climb to the highest mark, then return to shore: near, second, third, far, third, second, near."
		"causeway_departure":
			return "A reed basket held four colored wrist cords. Its note asked the families to wait by the water and cross together."
		"causeway_crossing_open":
			return "The old stepping stones answered in a path that rose toward the gate and returned to shore."
		"archive_last_entry":
			return "The last catalogue line says: carry the books east; leave one lamp in the doorway."
		"gallery_procession":
			return "Three faceless figures carry bowls and lanterns toward a path cut into the mountain."
		"bell_keeper_list":
			return "The keeper marked twelve names beside the bells. Four are crossed out; rain has softened the rest."
		"high_steps_last_lantern":
			return "A neatly trimmed wick waits beside a note: extinguish the last lantern after the descent."
		"high_steps_trail_cairn":
			return "At the ridge fork, travelers added one stone before continuing. Its three marks point to the village, the refuge, and the upper path."
		"refuge_high_path":
			return "The refuge map marks three shelters along the ridge path. A note says the upper stair remains open in every season."
		"refuge_guest_book":
			return "The guest book records two long winters. Its final entry asks whoever leaves last to keep one place by the fire for anyone still on the path."
		"refuge_last_lantern":
			return "A keeper asks that the sheltered lantern stay lit until the last bell is answered."
		"quiet_garden_cup":
			return "An upside-down clay cup shelters a seed hollow from the rain."
		"gibberish_inscription":
			return "At the ruin wall: a line of marks, still unreadable."
		"resonance_mosaic":
			return "A worn mosaic repeats three shapes: crescent, rain-line, seed."
		"orchard_memory":
			return "A pale flower chimed as the orchard water returned."
		"quarter_household_map":
			return "Four things were returned each evening: a book, a bowl, a seed and a lamp. The carving shows four doorways. Its labels have washed away."
		"quarter_threshold_west":
			return "West house. A strip of linen lies between two thin boards. On the sill someone practiced the same letter until the ink ran out."
		"quarter_threshold_north":
			return "North house. A ladle hangs above a round hollow in the counter. Dried broth marks its rim."
		"quarter_threshold_east":
			return "East house. Folded paper packets fill the shelves. A single green shoot has split the seam of one."
		"quarter_threshold_south":
			return "South house. Soot stains the underside of a hook. A coil of unused wick hangs beside the door."
		"quarter_register":
			return "The village register remembers readers, potters, growers, and lamplighters. Its last column is worn blank."
		"quarter_household_restored":
			return "Four household objects sit once more in the doorways around the well. A stair appears in its reflection."
		"quarter_well_reflection":
			return "After the Archive opens, the village well reflects its starless sky. Four warm lights gather around a quiet gap."
		"village_gathering_order":
			return "A worn line around the village well says: set aside water, leave one lamp, then ring once after the road is empty."
		"village_gathering_restored":
			return "The three marks answer around the well. A hidden line remembers how the village gathered before the road closed."
		"village_last_gathering":
			return "At the last gathering, the village set aside the first clean water, left a lamp in the doorway, and rang once when the road was empty. The register's blank final column is filled with one word: together."
		"reading_order":
			return "The children's slate shows a boat at the west mark, a lantern at center, and reeds at the east mark."
		"reading_markers_aligned":
			return "The three study markers now follow the order of the children's lesson slate."
		"reading_lesson":
			return "A damp lesson book says children learned the safe river path from boat, lantern, and reeds. The final page is filled with small copied drawings."
		"orchard_water_memory":
			return "Three sluices feed the same basin; water returns to the garden."
		"archive_reflection_map":
			return "The archive ceiling shows a reflection turning right, down, then left."
		"archive_memory":
			return "The reflecting pool holds a sky that is absent above the ruins."
		"archive_hidden_stair":
			return "Aligned lenses reveal a stair below the archive."
		"gallery_reflection_map":
			return "The pool-side mural shows west pointing north, center pointing south, and east turning west."
		"gallery_memory":
			return "Beth's light is the only star reflected in the lower pool."
		"gallery_second_sky":
			return "The mirror shard catches the same stars around a missing place in the reflected sky."
		"gallery_hidden_stair":
			return "Three aligned reflections reveal a stair beneath the starless pool."
		"bell_garden_pattern":
			return "The bell garden's carving repeats five marks: crescent, rain-line, seed, crescent, then a pale rain-line echo." if story_flags.get("bell_echo_variant", false) else "The bell garden's carving repeats four marks: crescent, rain-line, seed, crescent."
		"bell_bench_memory":
			return "Beth rested on the old garden bench as if she had sat there many times before."
		"bell_garden_answer":
			return "The bells answered in the order of the four marks carved into the garden wall."
		"high_steps_wind_map":
			return "The wind-worn map marks west, south (under a doubled arrow), and east across the three vanes." if story_flags.get("high_steps_echo_variant", false) else "The wind-worn map marks west, north, and east across the three vanes."
		"high_steps_open_door":
			return "When the three vanes faced the rising path, a lantern appeared beside the upper door."
		"waterworks_channel_map":
			return "The channel map gives four wheel marks in order: rain-line, crescent, seed, crescent."
		"waterworks_gate_open":
			return "The waterwheels raise the sluice gate and uncover the dry lane into the village."
		"waterworks_waiting_bowls":
			return "Three bowls waited at the waterline each summer. A note says no one drank from the first spill."
		"cistern_valve_pattern":
			return "The lower cistern's water clock gives four turns: east, west, center, west."
		"cistern_basin_balanced":
			return "The three cistern channels settle into an even flow."
		"cistern_shared_water":
			return "The water keeper recorded the dry seasons by household. Each family took one measure at dawn; anyone who missed a turn was written in the next day's margin."
		"cistern_glass_memory":
			return "Through river glass, a fourth waterline appears beneath the cistern clock. Three cups wait beside the mark, one for each shared channel."
		"observatory_star_chart":
			return "The keeper's star chart sets the crescent west, the rain-line north, and the seed east."
		"observatory_orrery_aligned":
			return "The three brass arms settle into the keeper's star chart. A narrow drawer opens beneath the astrolabe."
		"observatory_weather_log":
			return "The drawer holds years of careful weather notes: first floodwater, last spring rain, and the nights the valley's lanterns were lit. The final page is a blank table for the next season."
		"quiet_garden_order":
			return "The small garden carving gives three marks: rain-line, seed, crescent."
		"quiet_garden_bench":
			return "The old stone bench holds the warmth of a place where someone once waited."
		"quiet_garden_song":
			return "Three glass chimes answered above the seedling; one white flower opened by the basin."
		"matching_stone_cuts":
			return "A broken chip fits a narrow break at the observatory inscription."
		"crossing_sun_mark":
			return "A green brass button fits an old mark on the buried arch."
		"quiet_garden_memory":
			return "A small green shoot returned where the orchard channels meet."
		"archive_second_image":
			return "In the silvered shard, a fourth archive path points north from west, east from center, and south from east."
		"archive_fourth_path":
			return "A fourth path of reflected light opens a narrow shelf beneath the archive's western wall."
		"archive_hidden_register":
			return "A loose leaf is headed “Borrowed skies.” Its final line asks the keeper to leave the east windows uncovered so the last light has somewhere to go."
		"map_chamber_route":
			return "Flood duty. Fill the cart with clean water. Find a crossing its wheels can use and take the load to the waiting households."
		"map_chamber_spring":
			return "Spring. Water runs clear above the flood line. Two wheel ruts lead away from the filling trough."
		"map_chamber_ford":
			return "Ford. The flood gauge stands a hand above the tallest stepping stone. A cart would sink to its axles."
		"map_chamber_ferry":
			return "Ferry. The landing posts stand on opposite banks. A frayed length of towrope hangs from one. The boat is gone."
		"map_chamber_bridge":
			return "Bridge. Silt streaks the stone below the deck. Paired wheel ruts cross its dry planks."
		"map_chamber_village":
			return "Village. Empty pitchers line the steps. Each door has a chalk mark for the day's water."
		"map_chamber_route_open":
			return "The spring, bridge, and village answer in sequence. A quiet arch opens toward the reflected pool."
		"map_chamber_ledger":
			return "The map keeper recorded flood seasons, bridge repairs, and which homes shared lantern oil. The last page leaves a blank map for a river that never came."
		"river_glass_memory":
			return "Green river glass catches a hidden thread beneath the pool's false sky."
		"bead_resonance":
			return "A blue fleck in a cloudy bead answers the rain-line with a low note."
		"message_from_past":
			return "The old inscription changed: Your hand has been here before."
		_:
			return clue_id.replace("_", " ").capitalize()
