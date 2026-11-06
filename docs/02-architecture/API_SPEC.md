# API Specification

No external API is planned. The offline single-player game needs no online service.

Conceptual internal contracts:
- Interactable exposes available actions and handles selected actions.
- Puzzle accepts interaction events and emits state-changed/completed events.
- Journal accepts a clue identifier and presents its entry animation.
- Hint system accepts puzzle identifier and chosen level, returns hint content, and updates consequence state.
- Save service stores and restores versioned local progress.

These are design contracts, not finalized code signatures.

