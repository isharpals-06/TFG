# Product Requirements Document

## Status
Working product baseline. The initial route exists in source, but it has not been playthrough-reviewed. The 2–3 hour target and release quality are not complete.

## Product
The Forgotten World is a single-player isometric pixel-art narrative exploration and puzzle adventure. The experience is calm, mysterious, nostalgic, and occasionally melancholic. Storytelling relies on places, objects, animation, and limited text.

## Goals
1. Deliver a complete beginning, middle, and ending in roughly 2–3 hours.
2. Make a small, memorable world with consistent art and sound.
3. Center exploration, environmental observation, and puzzles.
4. Make Beth an expressive companion and subtle guide.
5. Let players request help while allowing repeated hint use to leave meaningful in-world consequences.

## Audience and experience
For players who enjoy calm exploration, environmental puzzles, atmosphere, and subtle mystery. No combat or time pressure. Players should feel curious, observant, and connected to the world and Beth.

## Current gameplay baseline
- One continuous journey; the current twelve main spaces are an implementation slice, not a fixed limit on the final level plan.
- Main route leads; optional branches are short. A few return paths permit revisiting discoveries.
- Direct eight-direction movement mapped to the isometric view; walking and player-controlled running.
- The optional reed causeway uses short hop animations between stepping stones as a low-pressure traversal action.
- A small icon marks interactable objects. Examine, pick up, and activate are distinct actions.
- Four inventory slots as a provisional baseline; most items reusable, rare consumables, swap when full.
- Journal automatically animates discovered clues into an archive; players make connections themselves.
- Mostly short observation-led puzzles, with occasional multi-step puzzles across connected areas.
- Wrong attempts are free. Puzzle progress usually persists after leaving.
- Solutions may open routes, reveal history, and visibly change the environment.
- Optional puzzles mainly reward extra history and restoration, sometimes a shortcut.
- Main-route difficulty rises gradually; optional puzzles may be harder.
- Prototype camera follows the traveler, offers limited zoom and quarter turns, and can snap instead of easing. Reframing and foreground occlusion handling remain open.
- Beth is primarily a subtle guide, with companion reactions and occasional puzzle-partner moments.

## Narrative direction
The opening combines an ancient structure, an unusual medallion, crossing into a forgotten world, and discovering Beth asleep among ruins. An inscription found earlier animates from gibberish into a hidden message near the ending. This is the first clear sign of the protagonist's connection to the world's past; the deeper explanation remains open.

## Hint consequences
Beth offers a gentle nudge, a clearer clue, and a near-solution. Repeated use escalates an in-world effect, communicated through the environment and Beth rather than a direct warning. Effects build within a puzzle, mostly recede afterward, and leave a small trace. Across the journey they may change Beth, later puzzle variants, optional discoveries, and ending presentation. The main route remains completable.

Current prototype: each hint adds an echo; every second request makes the added cost higher. A solved puzzle clears its local echo, while the journey-wide trace remains and changes the world tint, Beth, and the ending image. If eight or more hints have been used before entering the Bell Court, a pale fifth echo note is added to its visible carving and bell pattern. At twelve or more before the High Steps, the middle vane's direction changes and a doubled arrow shows the new direction in the map and journal. Both routes remain completable by following their changed clues. Additional hint-dependent variations still need design and runtime review.

## First playable slice
A small opening sequence demonstrating movement, camera, interaction, one environmental puzzle, a visible world response, Beth, one journal entry, and a prototype of hint consequences. Placeholder art and writing are acceptable.

## Success criteria
A player can move and interact without unexplained friction; fair clues support puzzle solving; optional hints help; solving the puzzle visibly changes the world and prompts a readable Beth reaction.

## Completion gap

The current implementation routes through twelve main spaces: crossing, ruins, orchard, waterworks, empty quarter, archive, map chamber, reflection gallery, bell garden, highland refuge, highland steps, and observatory, with optional lower-cistern, restored-garden, reed-causeway, and west-house-reading-room branches. The map chamber extends the Archive route with a saved spring → bridge → village sequence and a ledger about shared flood-season work; it adds no clue about the traveler. The lower cistern branches from the restored waterworks and offers a saved four-turn valve sequence, a river-glass discovery, and a water-sharing ledger without blocking the village gate. Restoring the village households opens the reading room's saved three-marker puzzle and two ordinary-life records. The waterworks adds a four-mark wheel sequence, an optional household waterline record, and the passage into the village. The causeway adds a seven-step crossing puzzle, an optional departure record, and a return path into the waterworks. Solving the Archive opens a return stair to the village well and an optional reflection clue. Three ordinary-history records from the waterworks, Archive, and bell garden unlock a saved bowl → lamp → bell sequence at the well, revealing the valley's last gathering. The archive's mirror shard reveals an optional second lens path and keeper's note after the main stair opens. The observatory's keeper's star chart guides an optional three-arm astrolabe, revealing a weather ledger without blocking the inscription. The route has nine main puzzle mechanisms, seven optional puzzles, optional valley-history records, and generated backgrounds throughout. It has not been timed or reviewed in a complete runtime playthrough and is shorter than the 2–3 hour target. Character animation, final audio, accessibility review, and full-route runtime review remain release work. A local Windows x86_64 export passed a startup review through the crossing but is not a finished release.

The village well adds a seventh optional puzzle once the player has found the waterworks bowl record, the Archive's last catalogue entry, and the bell keeper's list. Its saved bowl → lamp → bell sequence restores an account of the valley's final gathering; it adds no clue about the traveler. This content has not received runtime review or a playtime estimate.
