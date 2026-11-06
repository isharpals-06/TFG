# Data Flow

## Interaction

Movement input → nearest visible target → contextual prompt → examine/take/activate/use action → authored feedback → persistent state update when needed.

## Puzzle

Observe environment → examine a clue → add a clue ID to the journal → experiment without resource loss → update puzzle state → show a visible world response → autosave.

## Hint

Open Beth's hint panel → choose level 1, 2, or 3 → provide the matching authored clue → increment the journey-wide hint-use count and echo → increase added echo on repeated requests → update Beth/world appearance. Solving a puzzle clears the local echo; the journey-wide trace remains.

## Inventory

Take item → add if a slot is free → otherwise open the exchange panel → protect the medallion → replace a selected non-story item → select and inspect an item → use on an authored compatible target.

## Save

Persistent state → JSON version 2 in Godot's per-user data directory. Writes use a temporary file and a `.bak` fallback. Autosave runs every 30 seconds during a journey and state-changing interactions save immediately. Continue loads the data before resuming the route.

The current save does not store an exact player position; resuming returns the player to the current area's safe entry point.

