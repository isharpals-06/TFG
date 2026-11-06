# Data and Save Design

There is no database server. Journey state is stored locally at `user://forgotten_world_save.json`.

## Save schema version 2

- `version`: integer schema version.
- `presentation`: selected traveler palette.
- `inventory`, `selected_item_id`: stable item IDs and selected item, bounded to four slots.
- `journal_entries`: stable clue IDs, in discovery order.
- `puzzle_progress`: per-puzzle values such as resonator sequence, sluice states, and lens positions.
- `story_flags`: progression and optional-discovery flags.
- `hint_echo`, `total_hint_points`, `local_hint_points`, `hint_uses`: escalating hint consequence.
- `journey_started`, `seconds_played`: journey presence and elapsed playtime.
- `settings`, `input_bindings`: local options and user control overrides.

Version 1 saves are accepted and receive a conservative estimated hint-use count. Unknown future versions are rejected. Version 2 input bindings can be read in the initial single-device format and the current per-device format.

## Current limitations

Writes go to a temporary file, rotate a valid prior file to `.bak`, then replace the primary save. Loading falls back to the backup when the primary JSON is malformed. Inventory, clue, settings, puzzle, and story containers are type-checked; deeper validation of every nested ID/value still remains. Exact world position and named save slots are not implemented.

