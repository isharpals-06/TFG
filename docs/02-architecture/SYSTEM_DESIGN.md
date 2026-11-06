# System Design

## Goals
Keep the project small, offline-first, and understandable to a beginner. Prefer built-in Godot features over custom frameworks.

## Runtime systems
Player movement/animation; camera; interaction discovery; inventory; puzzle state; clue journal; Beth follow/reactions/hints; hint consequence state; local save/load and settings before full release.

## Content
Each area is a Godot scene. Interactables and puzzles can be reusable scenes or resources where useful. Keep story text and item descriptions separate from logic when practical.

## Constraints
No server, account, analytics, or AI service. Use local signals/events where they reduce coupling.
