# Software Requirements Specification

This is the working requirements baseline for a Windows-first, offline, single-player game. “Prototype” means the feature has an initial implementation; it has not passed a runtime playthrough or release review.

## Functional requirements

| ID | Requirement | Current state |
| --- | --- | --- |
| FR-01 | Eight-direction movement in the isometric view, with walking and running. | Prototype implemented. |
| FR-02 | Optional low-pressure traversal actions with a short animation. | Not implemented. |
| FR-03 | Nearby targets provide a prompt; examine, take, activate, and use item are separate actions. | Prototype implemented. |
| FR-04 | Carry, inspect, select, and use a few items on compatible objects. | Prototype implemented with item notes and authored combinations. |
| FR-05 | A full inventory allows the player to exchange a non-story item for a new find. | Prototype implemented; medallion is protected. |
| FR-06 | The journal records clues automatically and animates discovery feedback without solving connections. | Partly implemented; entries are recorded and signaled, but journal presentation needs a full pass. |
| FR-07 | Puzzle state is visible in the scene and normally persists after a transition. | Implemented for the current route. |
| FR-08 | Wrong attempts do not consume items or block the main route. | Implemented for current puzzles; future puzzles need review. |
| FR-09 | Beth offers three optional hint levels and reacts to their use. | Prototype implemented. |
| FR-10 | Hint echoes build, recede locally after puzzle completion, and affect later content and ending details. | Partly implemented: Beth, environment tint, and ending art change; later puzzle variants remain. |
| FR-11 | Camera follow, limited zoom, isometric turns, snap option, and occlusion handling. | Follow, zoom, turns, and snap option implemented; reframing and occlusion handling remain. |
| FR-12 | Keyboard and controller support, with remapping for core actions. | Prototype implemented; movement/camera remapping and device review remain. |
| FR-13 | Local save/resume preserves progress, clues, inventory, puzzles, hint state, playtime, and settings. | Versioned JSON with periodic autosave and backup fallback; exact-position restore and deeper nested-data validation remain. |

## Quality requirements

- Offline-first; no accounts, server, analytics, or network service.
- Crisp integer-scaled pixel art; a consistent production art pass remains.
- Readable text, reduced motion, and useful non-audio cues.
- No time pressure, combat, resource loss on wrong attempts, or hint-induced hard locks.
- GDScript and scenes should remain understandable to a beginner maintainer.
- Save data must be local and versioned; do not place personal data or credentials in it.

## Open requirements

Final display options, control coverage, save recovery behavior, traversal actions, camera occlusion rules, story text, and exact content length need design and review before release.

