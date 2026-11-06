# The Forgotten World

An isometric exploration and puzzle adventure about a silent traveler, a sleeping world, and Beth, a small spirit who remembers more than she can say.

## Project status

The project is in active development. A first end-to-end route connects the crossing, ruins, orchard, archive, and observatory and reaches the planned inscription cliffhanger. Core movement, interaction, journal, hints, local saving, settings, a small keepsake inventory, and procedural ambience are implemented in the prototype.

The intended 2–3 hour experience, full art and audio pass, complete puzzle set, and release build are still outstanding. The current route has not been timed or reviewed in a runtime playthrough; it is not a finished release.

## Creative direction

- Peaceful, mysterious, nostalgic, and occasionally melancholic.
- Original fictional medieval world; magic stays subtle.
- Silent protagonist with two appearance palettes.
- Isometric pixel-art presentation; no combat or time pressure.
- Exploration, environmental puzzles, Beth's reactions, and a clue journal carry the story.
- The cliffhanger is the first clear sign of the traveler's connection to the past: an inscription found earlier starts as gibberish and animates into **“YOUR HAND HAS BEEN HERE BEFORE.”**

## Current prototype features

- Eight-direction isometric movement, running, camera follow, quarter turns, zoom, and optional snap turns.
- Separate examine, take, activate, and use-keepsake actions with nearby prompts.
- Four-slot keepsake inventory, item notes, selection, safe swapping, and a protected story medallion.
- Persistent first-gate sequence, orchard water puzzle, and archive lens puzzle.
- Beth's three hint levels; repeated use adds an escalating visual echo that changes her color and the ending image.
- Local clue journal, save/resume, playtime tracking, and autosave.
- Reduced camera motion, larger text, ambient-audio toggle, and remappable core actions.
- Procedural ambient layers and event chimes; generated title-screen artwork.

## Run the project

1. Install or open Godot **4.7.2 stable**.
2. Open the folder containing `project.godot` in Godot Project Manager.
3. Press **F6** to run the current scene or **F5** to start from the title screen.

Keyboard defaults: WASD or arrows move; Shift runs; E examines; F takes; Space activates; U uses the selected keepsake; I opens keepsakes; J opens the journal; H opens Beth's hints; Escape pauses. The Controls screen lets you rebind the core actions. Controller defaults are shown there too.

Godot-generated import data is excluded from Git. No external account or network service is needed to run the game.

## Project map

- `src/actors/` traveler and Beth.
- `src/audio/` generated ambient sound and event chimes.
- `src/core/` input, settings, save data, inventory, journal IDs, and hint state.
- `src/scenes/` title, journey, and cliffhanger scenes.
- `design/assets/` original project artwork and asset notes.
- `design/references/` inspiration links only; these images are not included game assets.
- `docs/` product, architecture, design, production, QA, operations, and handoff notes.

## Documentation

Start with [product requirements](docs/01-product/PRD.md), [scope](docs/01-product/SCOPE.md), [roadmap](docs/04-development/ROADMAP.md), and [setup](docs/06-operations/SETUP.md). See [visual references](design/references/VISUAL_REFERENCES.md) and [asset credits](design/assets/ASSET_CREDITS.md).

## Rights

No open-source license has been selected. Project code, writing, and original assets remain reserved to the creator. The visual reference links are for research only; verify third-party rights before using any referenced work.

