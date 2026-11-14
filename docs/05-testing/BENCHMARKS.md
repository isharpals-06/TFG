# Benchmarks

No numeric performance target is established for this small 2D game. During the vertical slice, review startup, frame pacing on a typical Windows PC, input responsiveness, and pixel clarity. Set numeric targets only if profiling shows a need.

## First-playthrough duration

Use a fresh journey and a player who has not seen the puzzle solutions. Start timing when the player chooses a traveler and stop when the inscription becomes readable. Include exploration, reading the journal, using Beth's hints and retracing steps. Subtract breaks away from the game. The save's `seconds_played` counter pauses in menus, so report that separately from the player's elapsed time.

Record the build revision, elapsed time, optional areas visited, hints used and any place where the player stopped making progress. A run through the main route with known solutions verifies progression. Only first-time player timings can establish whether the release meets the 2–3 hour target.
