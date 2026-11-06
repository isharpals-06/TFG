# Architecture

Proposed folders: src/core for shared state, settings, and saves; src/player; src/camera; src/world for areas/interactables/puzzles; src/companion for Beth; src/ui; src/data; and src/audio. Do not create every subsystem before a real need appears.

Keep player, Beth, interactables, puzzle mechanisms, and UI in clear scene boundaries. The system that changes a state owns it: puzzles own puzzle progress, journal owns discovered clues, hint logic owns hint consequence state, and the save service serializes persistent state.

Build one small slice first; avoid premature frameworks.
