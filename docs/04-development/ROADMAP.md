# Roadmap

The creator is a beginner with a few hours per week. Deliver small, understandable milestones and keep the full 2–3 hour target visible. Implementation is authorized and in progress.

## Milestones

1. **Foundation** — create the Godot project, title, controls, movement, camera, local state, and first interaction loop. Initial source pass is present.
2. **Core journey loop** — add Beth, clue journal, three hint levels, first rune puzzle, save/resume, settings, and pause. Prototype source is present; runtime review is still due.
3. **Route and item loop** — connect the orchard, waterworks and optional lower cistern, optional reed causeway, empty quarter, archive, map chamber, reflection gallery, bell garden, and observatory; add water, household, lens, map-route, mirror, bell, wheel-order, causeway, cistern-valve, and village-gathering puzzles, keepsakes, item swapping, optional discoveries, and the cliffhanger. The expanded route is present; content is still short and unfinished.
4. **Full content** — expand the world with enough authored exploration, puzzles, story fragments, and optional discoveries to meet the 2–3 hour target. Not complete.

5. **Visual/audio production** — replace remaining placeholder drawing, refine area art/audio, and verify attribution. Pixel-art-style backgrounds now cover the title, twelve main locations, optional garden, causeway, reading room, and lower cistern; the traveler has a four-frame cycle, Beth has four expression poses, and area ambiences crossfade with quiet chord-tone motifs. Runtime review and final music/audio polish remain outstanding.
6. **Quality and accessibility** — review controls, readability, motion, puzzle clarity, save recovery, and hint consequences in an end-to-end playthrough. Not complete.
7. **Release** — a Windows x86_64 export and preset now exist locally. The export script builds from an isolated copy and refuses to report success on parser errors or a stale package. Runtime review, license choice, final release notes, and creator approval remain.

## Current evidence

Use [CONTENT_PLAN.md](CONTENT_PLAN.md) for the chapter pacing targets and the current content gap. The times are design goals and have not been measured in play.

The current Windows export includes return steps between Bell Court and the village and a village lane to the waterworks. Its checksum is recorded alongside the executable in `build/SHA256SUMS.txt`.

An isolated Godot run began at a Bell Court checkpoint with the Archive record already collected. Using the room's interaction handlers, it read the keeper's list, returned to the village, collected the missed bowl record at the waterworks, saved and resumed in the village, solved the gathering, read the final record and returned to Bell Court. The run passed those checks and reported six live objects at shutdown. Their source needs investigation. Visual review, input-device review and a timed full playthrough are still open.

A fresh, isolated Godot run selected the Mist mantle and completed all twelve main areas using their interaction handlers. The ending save held 20 journal entries including the message from the past. Returning to the title released the journey audio, and Continue restored the ending. This run positioned the traveler beside each interaction, so walking, visual readability, physical controls and first-play duration still need a playthrough.
