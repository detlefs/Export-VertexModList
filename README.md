# Export-VortexModList

**Important:** This script is for those who know PowerShell. You should know piping and how to process the result using other commands.

The script reads the list of games and mods of the last active profiles from the latest Vortex backup JSON and provides them for further processing.

The result is returned as an array of type `ModData` and is meant to be further processed by other PowerShell commands, to further filter, format, sort and convert it. See some samples below...

## Notes

* The script reads the data from the newer file in ($($env:APPDATA)\Vortex\temp\state_backups_full\*.json). Neither of these files is updated real-time by Vortex. So, if you change something in the mod settings, it's best to restart Vortex if you want to see the change in this script.
* Mods with a status of "Uninstalled" in Vortex are not included in the list.

## The custom type `ModData`

The returned array of type `ModData` contains most attributes that can be read from the Vortex backup file and that are useful.

The available properties can be listed by calling

```powershell
Export-VortexModList | Get-Member
```

## Disclaimer

I only tested this script with my own local copy of Vortex version 1.10.8. The script behavior with other installations, older Vortex versions, or non-standard installations may be unpredictable or it may not work at all.

## Installation

Either clone this repository to a location you like, or download the script from NexusMods.

## Usage examples

### Example 1

```powershell
Export-VortexModList
```

Reads all data from the Vortex backup file and returns a custom object array.

### Example 2

```powershell
Export-VortexModList `
| Where-Object gameName -eq baldursgate3
```

Reads all data from the Vortex backup. The result is piped to the `Where-Object` command to filter the list for the name of the game.

The result is a mod list only containing the mods used by Baldur's Gate 3.

### Example 3

```powershell
Export-VortexModList `
| Select-Object gameName -Unique
```

Reads all data from the Vortex backup. The result is piped to `Select-Object` to select only a unique list of game names.

The result is a list of just the game names.

### Example 4

```powershell
Export-VortexModList `
| Where-Object gameName -eq baldursgate3 `
| Select-Object modName, id, author, modVersion, state, loadOrderNumber, enabled `
| Sort-Object loadOrderNumber `
| Format-Table -AutoSize
```

Reads all data from the Vortex backup. The result is piped to `Where-Object`, to `Select-Object`, to `Sort-Object` and finally to `Format-Table`.

The result is a list of mods for the game Baldur's Gate 3, with only the columns `modName`, `id`, `author`, `modVersion`, `state`, `loadOrderNumber` and `enabled`.

The result is sorted by the load order number and formatted as a table.

### Example 5

```powershell
Export-VortexModList `
| Where-Object gameName -eq baldursgate3 `
| Select-Object modName, modVersion, newestVersion, author, source, `
    enabled, shortDescription `
| ConvertTo-Markdown -Title "Baldur's Gate 3 mods" -AsTable `
| Set-Clipboard
```

This example creates a tabe view in markdown syntax that can be easily pasted into any markdown-aware software like a Wiki website, or a notes app like Joplin, etc.

**Note:** The `ConvertTo-Markdown` command is part of a module [Utility.PS](https://www.powershellgallery.com/packages/Utility.PS/2.0.1). If you want to run this example, you first need to install the module.
