# Export-VortexModList

The script reads the list of games and mods of the last active profiles from the latest Vortex backup.json and provides them as a custom object array.

The result is returned as an array of type `ModData` and is meant to be further processed by other PowerShell commands, to further filter, format, sort and convert it. See some samples below...

**Note:** Mods with a status of "Uninstalled" in Vortex are not included in the list.

## The custom type `ModData`

The returned array of type `ModData` contains most attributes thet can be read from the Vertex backup file and that are helpful.

The available properties can be listed by calling

```powershell
Export-VortexModList | Get-Member
```

This command will output a list of all properties of the `ModData` data type.

## Notes

* The mod list is read from the file `%AppData%\Vortex\temp\state_backups_full\startup.json`. If this is nlot where the local installation of Vortex mod manager stores the status backups, the path must be manually changed in the source code.
* The list of games is extracted from the node `settings/profiles/lastActiveProfile` of the status backup file. The list may not be complete under some circumstances. It's the best I could find in my local backup file.

## Disclaimer

I only tested this script with my own local copy of Vortex mod manager. the results of the script with other installations, older Vortex formats, or non-standard installations may be unpredictable or the script may return errors.

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
Export-VortexModList | Where-Object gameName -eq baldursgate3
```

Reads all data from the Vortex backup. The result is piped to the `Where-Object` command that is filtering the list for the name of the game.

The result is a mod list only containing the mods used by Baldur's Gate 3.

### Example 3

```powershell
Export-VortexModList | Select-Object gameName -Unique
```

Reads all data from the Vortex backup. The result is piped to `Select-Object` which selects only a unique list of game names.

The result is a list of just the game names.

### Example 4

```powershell
Export-VortexModList | Where-Object gameName -eq baldursgate3 | Select-Object modName, id, `
 author, modVersion, state, loadOrderNumber, enabled | Sort-Object loadOrderNumber | `
 Format-Table -AutoSize
```

Reads all data from the Vortex backup. The result is piped to `Where-Object`, then to `Select-Object`, then to `Sort-Object` and finally to `Format-Table`.

The result is a list of mods for the game Baldur's Gate 3, with only the columns `modName`, `id`, `author`, `modVersion`, `state`, `loadOrderNumber` and `enabled`. 

The result is sorted by the load order number and formatted as a table.

### Example 5

```powershell
Export-VortexModList | Where-Object gameName -eq baldursgate3 | Select-Object modName, `
 modVersion, newestVersion, author, source, enabled, shortDescription | `
 ConvertTo-Markdown -Title "Baldur's Gate 3 mods" -AsTable | Set-Clipboard
```

This example creates a tabe view in markdown syntax that can be easily pasted into any markdown-aware software like a Wiki website, or a notes app like Anytype, Notion or Joplyn, etc.

**Note:** The `ConvertTo-Markdown` command is part of a module [Utility.PS](https://www.powershellgallery.com/packages/Utility.PS/2.0.1). If you want to run this example, you firts need to unstall the module

### Example 6

```powershell
Export-VortexModList | Get-Member
```

This example returns a list of all properties the `ModData` type provides.
