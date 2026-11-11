# Deployment

## Status

The latest single-file Windows x86_64 development export exists at `build/The Forgotten World.exe` (about 144 MB). Its PCK is embedded. Godot 4.7.2 stable release templates were installed from the official release mirror. A prior export was opened on Windows: the title menu, traveler selection, and transition into the crossing all appeared. The latest export, including the ridge-fork cairn, revised High Steps hint order, required chart-led observatory alignment, Beth's playful idle orbit, reduced-motion-aware water ripples in the orchard and waterworks, and the About & Credits page, has not been opened in runtime. No complete playthrough, full controls review, or release review has been performed. This is not an approved public release.

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
