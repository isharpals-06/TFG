# Software Requirements Specification

This is the working requirements baseline for a Windows-first, offline, single-player game. “Prototype” means the feature has an initial implementation; it has not passed a runtime playthrough or release review.

## Functional requirements

| ID | Requirement | Current state |
| --- | --- | --- |
| FR-01 | Eight-direction movement in the isometric view, with walking and running. | Prototype implemented. |
| FR-02 | Optional low-pressure traversal actions with a short animation. | Implemented on the optional reed causeway: each correct stone advances the traveler with a brief hop; mistakes return safely to shore, and reduced-motion mode removes the hop. |
| FR-03 | Nearby targets provide a prompt; examine, take, activate, and use item are separate actions. | Prototype implemented. |
| FR-04 | Carry, inspect, select, and use a few items on compatible objects. | Prototype implemented with item notes and authored combinations. |
| FR-05 | A full inventory allows the player to exchange a non-story item for a new find. | Prototype implemented; medallion is protected. |
| FR-06 | The journal records clues automatically and animates discovery feedback without solving connections. | Partly implemented; entries are recorded and signaled, but journal presentation needs a full pass. |
| FR-07 | Puzzle state is visible in the scene and normally persists after a transition. | Implemented for the current route. |
| FR-08 | Wrong attempts do not consume items or block the main route. | Implemented for current puzzles; future puzzles need review. |
| FR-09 | Beth offers three optional hint levels and reacts to their use. | Prototype implemented. |
| FR-10 | Hint echoes build, recede locally after puzzle completion, and affect later content and ending details. | Prototype implemented: Beth, environment tint, and ending art change; eight or more prior hint uses add a visible, clued fifth Bell Court note, and twelve or more change the High Steps' middle-vane direction with a doubled map mark. Runtime balance review remains due. |
| FR-11 | Camera follow, limited zoom, isometric turns, snap option, and occlusion handling. | Follow, zoom, turns, and snap option implemented; reframing and occlusion handling remain. |
| FR-12 | Keyboard and controller support, with remapping for movement and core actions. | Remapping is implemented for movement, interaction, inventory, journal, hints, pause, and camera controls; device review remains. |
| FR-13 | Local save/resume preserves progress, clues, inventory, puzzles, hint state, playtime, settings, and the current checkpoint. | Version 3 JSON stores the room and player position, autosaves during play, falls back to a backup, and validates nested IDs, types, and ranges. Runtime recovery review remains due. |
| FR-14 | The Archive route includes a map chamber with a saved sequence puzzle, optional history record, and safe return to the Archive. | Implemented: trace spring, bridge, village; the open arch leads to the reflection gallery. Runtime review remains due. |
| FR-15 | The restored waterworks offers an optional lower-cistern puzzle and a safe return without closing the village route. | Implemented: saved four-turn valve sequence, three hint levels, optional river-glass discovery, water-sharing ledger, and return stair. Runtime review remains due. |

## Quality requirements

- Offline-first; no accounts, server, analytics, or network service.
- Crisp integer-scaled pixel art; a consistent production art pass remains.
- Readable text, reduced motion, and useful non-audio cues.
- No time pressure, combat, resource loss on wrong attempts, or hint-induced hard locks.
- GDScript and scenes should remain understandable to a beginner maintainer.
- Save data must be local and versioned; do not place personal data or credentials in it.

## Open requirements

Final display options, control coverage, save recovery behavior, causeway traversal animation, camera occlusion rules, story text, and exact content length need review before release.
