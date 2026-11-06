# Troubleshooting

- **Godot does not open:** confirm extraction completed and Windows has not blocked the executable.
- **Project Manager cannot import:** choose the directory containing `project.godot`, not `src/` or the editor executable folder.
- **First import takes time:** Godot rebuilds the ignored `.godot/` import cache.
- **Pixel art looks blurry:** check nearest texture filtering, viewport stretch mode, and integer scaling.
- **Movement feels wrong for the diamond grid:** inspect the input-to-isometric conversion in `src/actors/traveler.gd`.
- **Continue is missing:** Continue only appears when the local JSON save reports an active journey.
- **A clue or puzzle looks reset:** check that its state is written to RunState and saved after the interaction.
- **Git lists editor/cache files:** review `.gitignore`; editor binaries and `.godot/` are excluded, authored project files are not.

