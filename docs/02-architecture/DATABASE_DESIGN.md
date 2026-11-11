# Data and Save Design

There is no database server. Journey state is stored locally at `user://forgotten_world_save.json`.

## Save schema version 3

- `version`: integer schema version.
- `presentation`: selected traveler palette.
- `inventory`, `selected_item_id`: stable item IDs and selected item, bounded to four slots.
- `journal_entries`: stable clue IDs, in discovery order.
- `puzzle_progress`: per-puzzle values such as resonator sequence, sluice states, lens positions, the causeway's seven-step rhythm, and the observatory's three astrolabe arms. Nested maps are rebuilt from known keys; orientations and sequence counts are clamped to their legal ranges.
- `story_flags`: progression and optional-discovery flags, including the archive's independent fourth-path puzzle and hidden-leaf record, plus the observatory chart and weather ledger.
- `hint_echo`, `total_hint_points`, `local_hint_points`, `hint_uses`: escalating hint consequence.
- `journey_started`, `seconds_played`: journey presence and elapsed playtime.
- `settings`, `input_bindings`: local options and user control overrides.

Version 1 saves are accepted and receive a conservative estimated hint-use count. Unknown future versions are rejected. The current checkpoint list includes the optional `reed_causeway` phase. Earlier single-binding and current per-device input bindings are accepted and filtered against supported actions and valid key/button ranges.

## Current limitations

Writes go to a temporary file, rotate a valid prior file to `.bak`, then replace the primary save. Loading falls back to the backup when the primary JSON is malformed. Inventory IDs and capacity, clue IDs and count, boolean story flags, supported settings, nested puzzle keys and ranges, binding actions and ranges, bounded hint counters/playtime, and checkpoint coordinates are validated before use. The current room and a bounded player position are saved; named save slots are not implemented.
