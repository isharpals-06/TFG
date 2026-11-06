# System Design

## Design goals

Keep the project offline, small, and understandable to a beginner. Prefer Godot's built-in scene tree, input map, audio, and save APIs. Add a framework only when it solves a concrete problem.

## Runtime shape

- **RunState autoload:** journey state, inventory, journal IDs, settings, input bindings, hint echo, local JSON save/load, and elapsed playtime.
- **Soundscape autoload:** generated ambience and short event tones. Area changes select a matching loop.
- **Main menu scene:** title, traveler palette choice, continue, settings, controls, and key rebinding.
- **Prologue scene:** currently owns area progression, interactions, puzzles, HUD, fades, and environment drawing for five spaces. This is a prototype boundary; split it into area/interaction/UI scripts as content grows.
- **Traveler and Beth scenes:** direct movement and the glowing companion.

## Persistence

Use stable IDs for inventory, clues, puzzles, and story flags. Save locally in versioned JSON. Keep migration behavior when adding or changing data. The current save is schema version 2; safe-position restore and interrupted-write recovery remain outstanding.

## Content boundaries

The current world route is a single scene that switches area state. The planned production shape is one scene per area with reusable interaction/puzzle scenes and data-driven text, introduced gradually so the project stays maintainable.

## Constraints

No server, account, analytics, external API, or runtime AI. Do not include credentials or personal data in saves or Git.

