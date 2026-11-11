# The Forgotten World

An isometric exploration and puzzle adventure about a silent traveler, a sleeping world, and Beth, a small spirit who remembers more than she can say.

## Project status

The project is in active development. The current main route connects the crossing, first ruins, orchard, old waterworks, empty quarter, archive, map chamber, reflection gallery, bell garden, highland steps, and observatory and reaches the planned inscription cliffhanger. The map chamber adds a saved spring-bridge-village tracing puzzle and an optional ledger about valley flood seasons. Solving the Archive also opens a return to the village well, where a new optional reflection clue appears. Restoring the village households opens an optional west-house reading room with a three-marker puzzle and two local history records. Restoring orchard water opens an optional reed causeway; planting the pale seed opens an optional hidden garden. The waterworks adds a four-mark wheel sequence and an optional record. In the observatory, a keeper's chart offers an optional three-arm astrolabe puzzle and a weather ledger. Core movement, interaction, journal, hints, local saving, settings, a small keepsake inventory, and procedural ambience are implemented.

The current route is shorter than the intended 2–3 hour experience. Character animation and audio still need production passes. A startup review reached the crossing in the Windows export, but the game has not had a full playthrough or release review. The local Windows export under `build/` is not a finished release.

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
- Persistent first-gate sequence, orchard water puzzle, four-household empty-quarter puzzle, Archive lens puzzle, saved map-route sequence, reflection alignment, four-note bell sequence, and highland vane alignment.
- Optional restored garden with its own short chime puzzle and memory clues.
- Optional reed causeway with a seven-step waterline pattern, brief stepping-stone hops, a return route, a village entrance, and a record about families crossing together.
- Optional archive reflection puzzle unlocked by the mirror shard, revealing a hidden keeper's note without touching the main route.
- Optional west-house reading room unlocked by restoring the village households, with a saved three-marker puzzle and ordinary-history journal entries.
- Optional environmental records add the valley's history to the field journal without resolving the traveler's mystery.
- Beth's three hint levels; repeated use adds an escalating visual echo that changes her color and the ending image.
- A four-frame traveler walk animation that turns left/right with movement, plus Beth's four expressive faces, subtle floating, nearby-object investigations, and discovery reactions with reduced-motion support.
- Scrollable clue journal, save/resume at the current room and position, playtime tracking that pauses in menus, and autosave.
- Reduced camera motion, larger text, ambient-audio toggle, and remappable movement, interaction, journal, inventory, pause, and camera controls. Context prompts use the current binding.
- Procedural ambient layers with crossfaded area changes and event chimes; original generated backgrounds for the title, eleven main locations, optional garden, causeway, and reading room, plus Beth's four-pose expression sheet.

## Run the project

1. Install or open Godot **4.7.2 stable**.
2. Open the folder containing `project.godot` in Godot Project Manager.
3. Press **F6** to run the current scene or **F5** to start from the title screen.

Keyboard defaults: WASD or arrows move; Shift runs; E examines; F takes; Space activates; U uses the selected keepsake; I opens keepsakes; J opens the journal; H opens Beth's hints; Escape pauses. The Controls screen lets you rebind movement, interaction, menus, and camera actions. Controller defaults are shown there too.

Godot-generated import data is excluded from Git. No external account or network service is needed to run the game.

To rebuild the local Windows x86_64 executable, install the matching Godot export template and run `powershell -ExecutionPolicy Bypass -File scripts/export_windows.ps1`. The output goes to the ignored `build/` folder. See [deployment notes](docs/06-operations/DEPLOYMENT.md).

## Project map

- `src/actors/` traveler and Beth.
- `src/audio/` generated ambient sound and event chimes.
- `src/core/` input, settings, save data, inventory, journal IDs, and hint state.
- `src/scenes/` title, journey, and cliffhanger scenes.
- `design/assets/` original project backgrounds, import metadata, and asset credits.
- `design/references/` inspiration links only; these images are not included game assets.
- `docs/` product, architecture, design, production, QA, operations, and handoff notes.

## Documentation

Start with [product requirements](docs/01-product/PRD.md), [scope](docs/01-product/SCOPE.md), [roadmap](docs/04-development/ROADMAP.md), and [setup](docs/06-operations/SETUP.md). See [visual references](design/references/VISUAL_REFERENCES.md) and [asset credits](design/assets/ASSET_CREDITS.md).

## Rights

No open-source license has been selected. Project code, writing, and original assets remain reserved to the creator. The visual reference links are for research only; verify third-party rights before using any referenced work.
