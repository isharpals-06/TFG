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
- [x] Add generated backgrounds for the title and all nine main locations plus the optional garden, with asset credits.

## Core-system work in progress

- [x] Add four-slot keepsake inventory, descriptions, selection, item-use combinations, and a protected story item.
- [x] Add item replacement when full and optional keepsake discoveries.
- [x] Add pause/resume, save-and-return, autosave time, save version handling, and remapping for movement, interaction, inventory, journal, hints, pause, and camera controls.
- [ ] Review the inventory, rebinding, save migration, and pause flows in a runtime playthrough.
- [x] Add temporary-file save replacement, previous-save backup, and fallback loading.
- [x] Save and restore the current room and bounded player position; pause the playtime counter in menus.
- [x] Validate nested save data, inventory and clue IDs, settings, puzzle values, story flag types, checkpoints, input bindings, hint counters, and playtime.
- [ ] Review controller prompts and all remapped actions in a runtime playthrough.
- [ ] Improve camera framing and object occlusion.

## Content and production remaining

- [ ] Design and implement enough exploration and puzzle content for a 2–3 hour first playthrough; the current route is not yet long enough.
- [x] Add optional history records across the route without revealing the traveler's past.
- [ ] Deepen area exploration and multi-step puzzles to meet the 2–3 hour target.
- [ ] Add hint-dependent later variants while preserving a completable main route.
- [ ] Refine generated environment art into the final consistent visual treatment; produce and animate the traveler and Beth sprites.
- [ ] Refine ambient music and area-specific effects.
- [ ] Complete a full beginning-to-cliffhanger playthrough and accessibility review.
- [x] Produce a local Windows x86_64 release build with an embedded PCK.
- [ ] Runtime-review the exported build, select a license, and finish release materials.
