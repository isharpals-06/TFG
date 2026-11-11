# Design System

## Experience principles

- Peaceful, mysterious, nostalgic, occasionally melancholic.
- Beautiful without becoming overly cheerful.
- Original medieval fantasy, with subtle magic and no combat spectacle.
- Environmental storytelling and expressive animation over exposition.
- Use silence and space; avoid busy HUD decoration.

## Palette

- Deep blue-green and charcoal for night and shadow.
- Sage, moss, and lichen for vegetation.
- Dusty gray-green for aged stone.
- Quiet brass and faded cream for warm points of attention.
- Blue-white light for Beth; a restrained violet trace for accumulated hint echoes.

## Scale and rendering

- Provisional canvas: 320×180 logical pixels.
- Provisional isometric tile: 32×16 pixels.
- Nearest filtering and integer viewport scaling.
- Traveler and interactable silhouettes must read against the ground at the logical resolution.

## Current state

All eleven main locations and the optional garden, causeway, reading room, and cistern use original generated pixel-art-style backgrounds. Traveler and Beth use original pixel-art sprites; the traveler has a four-frame walk cycle and resting pose, while Beth has four expression poses with reduced-motion-aware floating, nearby-object investigation, and discovery movement. Puzzle marks and much of the interface are drawn in GDScript, including three brass direction arms on the observatory astrolabe. The game remains a prototype: runtime animation review, tile-level animation, and a final polish pass remain.
