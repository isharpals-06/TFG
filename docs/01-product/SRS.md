# Software Requirements Specification

Draft for the first playable slice and eventual single-player game. Canvas and inventory values are provisional.

## Functional requirements
- FR-01: Eight-direction movement mapped to the isometric world, with walk and run.
- FR-02: Prompted low-pressure traversal actions such as stepping over a gap or climbing a low ledge.
- FR-03: Nearby interactables show a small icon; examine, pick up, and activate are distinct actions.
- FR-04: Player can carry a few objects, inspect descriptions, select an item, and use it on a world object.
- FR-05: When inventory is full, player can swap an item for a newly found one.
- FR-06: Journal automatically records clues and animates entries; it does not deduce answers.
- FR-07: Puzzle progress is shown in the environment and usually persists when leaving.
- FR-08: Wrong attempts do not consume resources or block progress.
- FR-09: Beth offers three optional hint levels and reacts to hint use.
- FR-10: Hint consequences can affect later puzzle variants, optional discoveries, companion behavior, and ending details.
- FR-11: Camera reframes, has limited zoom, supports smooth rotation with optional snapping, and handles foreground occlusion.
- FR-12: Keyboard and controller are supported; remapping is planned.
- FR-13: Full release must preserve progress, clues, inventory, puzzle states, hint state, and settings in local saves.

## Quality requirements
- Offline-first; no account or network service.
- Crisp pixel art at supported display sizes.
- Readable and scalable text; reduced camera motion/effects.
- Core actions are possible with keyboard or controller.
- Hint consequences never hard-lock the main route.
- Content remains understandable to a beginner maintainer.

## Open
Exact save format, final display settings, identity-selection details, and final story content.
