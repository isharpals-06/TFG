# Deployment

## Status

The development build is a standalone Windows x86_64 executable with embedded game data. For a playtest, give the player `build/The Forgotten World.exe` and its matching `build/SHA256SUMS.txt`. They can launch the executable directly without installing Godot.

Build `5f67feb` started from an empty working directory on Windows with an isolated save folder. Its SHA-256 matched the export manifest. This was a headless startup check. An automated journey against the embedded game data also reached the cliffhanger and resumed through Continue. First-time puzzle comprehension, physical controller use and the 2–3 hour duration still need player testing.

## Release preparation

1. Finish the 2–3 hour route and final art/audio.
2. Complete creator runtime, accessibility, save/resume, and rights reviews.
3. Launch and review the exported build on a Windows system without the editor.
4. Choose the project license and distribution channel with the creator.
5. Prepare final release notes and credits; obtain creator approval before publishing.

## Rebuild the local Windows artifact

With the matching Godot 4.7.2 stable release template installed, run from the project root:

```powershell
New-Item -ItemType Directory -Force -Path build | Out-Null
powershell -ExecutionPolicy Bypass -File scripts/export_windows.ps1
```

The export preset is stored in `export_presets.cfg`. Close a running copy of the game before exporting; the script refuses to replace a locked executable. It checks for the expected template, writes to the ignored `build/` directory, and records a SHA-256 checksum in `build/SHA256SUMS.txt`. Pass `-GodotExe "C:\path\to\Godot.exe"` if the editor is installed elsewhere.

Do not include editor binaries, Godot cache/import files, local save data, or secrets in the release package.
