# UI Specification

## Screen layout

The game uses a 320×180 logical viewport with integer viewport scaling. Keep interaction text and prompts inside safe margins; do not cover important landmarks with persistent UI.

## Current components

- Title: Begin/Continue, traveler palette choice, Controls, Settings, Quit.
- Play HUD: current objective, journal/hints prompts, selected-keepsake status, interaction icon and action prompt, short status line, keyboard reminder.
- Journal: clue list, open with J; entries are observations, not automatic puzzle solutions.
- Beth hints: H opens three choices, from gentle nudge to near-answer. 1/2/3 are available while open.
- Keepsakes: I opens four slots with descriptions, selection, dropping, and item exchange when full. U uses the selected item on authored targets.
- Pause: Escape opens Resume or Save and Return to Title.
- Ending: animated gibberish-to-message inscription, quiet aftermath, return to title.
- Settings: ambient audio, reduced motion, larger text, and camera snap.
- Controls: six core actions can be rebound by keyboard or controller button.

## Visual rules

Use a restrained blue-green night palette, muted stone and brass, pale blue-white light for Beth, and clear shape/silhouette differences. Keep text short and high contrast. Buttons must retain visible focus and hover states. No arbitrary color-only puzzle clue.

## Current limitations

UI is hand-built in scripts and has not been reviewed at window sizes or with a controller. Journal scrolling, display scaling choices, full input rebinding, and a cohesive production UI theme remain.

