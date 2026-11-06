# Setup

## Requirements

- Windows 10/11 PC.
- Godot 4.7.2 stable.
- Git for source history (optional for simply opening the project).
- No network account or server is needed to run the game.

## Open the project

1. Extract the project files into a folder.
2. Start Godot Project Manager.
3. Select **Import** and open the folder containing `project.godot`.
4. Open the project and press **F5** to start at the title screen.
5. To run an individual scene from the editor, select it and press **F6**.

The creator's workspace contains an extracted Godot 4.7.2 editor folder at the project root. It is ignored by Git and is not part of the source distribution.

## Local data

Godot saves progress and preferences to `user://forgotten_world_save.json`, resolved by Godot to the current user's app-data location. Generated `.godot/` import/cache files can be safely rebuilt by opening the project.

## Troubleshooting

See [Troubleshooting](TROUBLESHOOTING.md). For source contributions, see [Contributing](../04-development/CONTRIBUTING.md).

