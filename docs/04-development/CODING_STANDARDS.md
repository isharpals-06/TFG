# Coding Standards

- Use Godot 4.7.2 GDScript and project-native scenes; avoid plugins without a clear need.
- Prefer clear names, small scripts, typed variables where helpful, and stable IDs separate from display text.
- Put persistent state in RunState; keep one owner for each saved value.
- Use signals where they reduce coupling; avoid broad global state beyond the existing autoload.
- Keep functions small and explain unusual reasoning with short comments.
- Preserve beginner readability; do not hide essential game behavior behind complex abstractions.
- Track authored and third-party asset sources and rights.
- Save local Git checkpoints at clear milestones; do not include editor binaries, caches, generated imports, credentials, or personal save files.
- Do not add or run tests unless the creator asks to test or verify.

