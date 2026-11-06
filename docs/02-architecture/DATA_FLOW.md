# Data Flow

- Interaction: player input → nearby interactable → prompt → selected action → object/puzzle response → feedback.
- Puzzle: observe → discover clue → animate journal entry → experiment → puzzle state changes → environment responds → persist state.
- Hint: select one of three levels → Beth delivers hint → local consequence rises → world/Beth react → small trace may persist.
- Save: runtime systems expose persistent state to a local, versioned save service. Exact schema is deferred.
