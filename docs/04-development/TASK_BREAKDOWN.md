# Task Breakdown

## Foundation and first route

- [x] Create the Godot project and local Git history.
- [x] Add a title screen and traveler appearance choice.
- [x] Add isometric movement, run, camera follow/turn/zoom, and interaction prompts.
- [x] Add the crossing, medallion, ruins, Beth, inscription, and first rune sequence.
- [x] Add orchard water restoration, empty-quarter household niches, archive lens alignment, observatory, and cliffhanger.
- [x] Add the reflection gallery and bell garden as two further puzzle areas.
- [x] Add the optional seed-restored quiet garden and its chime puzzle.
- [x] Add the highland approach and wind-vane alignment before the observatory.
- [x] Add clue journal, three hint levels, initial escalating hint trace, and generated sound cues.
- [x] Add generated backgrounds for the title and all twelve main locations plus optional areas, with asset credits.
- [x] Add the optional reed causeway art, rhythm crossing, valley record, and routes back to the orchard or onward to the waterworks.
- [x] Give correct causeway steps a brief traveler hop animation; make wrong stones return safely to shore, with the hop removed in reduced-motion mode.
- [x] Add an optional shard-revealed archive lens path with a hidden valley-history record, independent of the main stair.
- [x] Require the keeper's chart and three-arm astrolabe alignment before the inscription cliffhanger; keep the opened weather drawer optional.
- [x] Add the old waterworks as a main-route room between orchard and village, with a saved four-mark wheel sequence, optional history record, and original generated background.
- [x] Open a return stair from the Archive to the empty quarter after the lens puzzle; the village well gains a new, optional reflection clue on revisiting it.
- [x] Add an optional reading room in the restored west house, with a saved three-marker observation puzzle, two history records, three hint levels, and a return to the village square.
- [x] Extend the main Archive route through a map chamber with a saved spring-bridge-village sequence, three hint levels, a return stair, an open gallery route, and an optional valley-history ledger.
- [x] Add an optional lower cistern beneath the restored waterworks with a saved four-turn valve puzzle, three hint levels, safe return, water-sharing history ledger, and an optional river-glass clue.
- [x] Combine three ordinary-history records from separate areas into a saved optional village-well sequence and final gathering record.
- [x] Add a highland refuge between the bell garden and High Steps, with three local history discoveries, distinct ambience, a return stair, a saved checkpoint, and original background art.
- [x] Add an optional ridge-fork cairn discovery and journal record, with a proportional Beth hint, to deepen the High Steps route without adding another identity clue.
- [x] Add subtle lower-cistern water ripples and suppress them when reduced motion is enabled.
- [x] Add a four-frame traveler walk cycle with horizontal facing that follows isometric movement and camera turns.
- [x] Add Beth's neutral, blink, curious, and happy face poses to her idle/reaction animation.
- [x] Add a brief idle-time playful orbit for Beth that yields to player movement, discoveries, and reduced-motion settings.
- [x] Animate the restored orchard channels with subtle ripples and suppress the motion when reduced motion is enabled.
- [x] Carry the restored-water animation into the waterworks pool, with reduced-motion support.
- [x] Crossfade between the existing area ambience loops when the player changes rooms.
- [x] Add a quiet chord-tone motif to each area's procedural ambience; final level and headphone review remain open.

## Core-system work in progress

- [x] Add four-slot keepsake inventory, descriptions, selection, item-use combinations, and a protected story item.
- [x] Keep authored journal clue text in its own catalog file, separate from room and puzzle flow.
- [x] Keep authored three-level puzzle hints and hint variants in a separate catalog, while the journey controller owns hint costs and Beth's reactions.
- [x] Add item replacement when full and optional keepsake discoveries.
- [x] Add pause/resume, save-and-return, autosave time, save version handling, and remapping for movement, interaction, inventory, journal, hints, pause, and camera controls.
- [x] Make HUD prompts follow the last-used input device and show readable controller button positions and analog-stick directions.
- [ ] Review the inventory, rebinding, save migration, and pause flows in a runtime playthrough.
- [x] Add temporary-file save replacement, previous-save backup, and fallback loading.
- [x] Save and restore the current room and bounded player position, show a progress-aware status on resume, and pause the playtime counter in menus.
- [x] Validate nested save data, inventory and clue IDs, settings, puzzle values, story flag types, checkpoints, input bindings, hint counters, and playtime.
- [ ] Review controller prompts and all remapped actions in a runtime playthrough.
- [x] Shift the camera framing upward to show more of the path ahead and fade the traveler under orchard canopy silhouettes.
- [ ] Review camera framing and orchard occlusion zones in a runtime playthrough; extend foreground handling to other areas where it improves readability.

## Content and production remaining

- [ ] Design and implement enough exploration and puzzle content for a 2–3 hour first playthrough; the current route is not yet long enough.
- [x] Add optional history records across the route without revealing the traveler's past.
- [ ] Deepen area exploration and multi-step puzzles to meet the 2–3 hour target.
- [ ] Runtime-review the Archive map chamber sequence, its save/return paths, and its optional history ledger.
- [ ] Runtime-review the lower cistern's entrance, four-turn valve sequence, save/return behavior, and history ledger.
- [ ] Runtime-review the highland refuge checkpoint, three journal discoveries, Bell Court return, and onward transition to High Steps.
- [x] Add a fair hint-dependent Bell Court variant: eight prior hints add a visible, clued fifth note.
- [x] Add a fair hint-dependent High Steps variant: twelve prior hints change the middle vane and its visible clue.
- [ ] Balance both hint-dependent variants in a full runtime playthrough and add further variations if needed.
- [ ] Refine generated environment art into the final consistent visual treatment; review traveler and Beth animations in runtime.
- [ ] Refine ambient music and area-specific effects.
- [ ] Complete a full beginning-to-cliffhanger playthrough and accessibility review.
- [x] Produce a local Windows x86_64 release build with an embedded PCK.
- [ ] Runtime-review the exported build, select a license, and finish release materials.
