# Data and Save Design

There is no server database. Persistent local data will likely include schema version, selected protagonist presentation, current area/safe position, inventory IDs, discovered clue IDs, puzzle states, hint consequence state, story flags, and settings.

Use stable identifiers rather than display text as keys. Choose the concrete Godot resource and save-file format during implementation. Add version handling before full release. Do not store secrets or personal data.
