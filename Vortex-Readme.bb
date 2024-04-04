[size=6]Export-VortexModList[/size]
[u][b]Important:[/b] This script is for those who know PowerShell. You should know piping and how to process the result using other commands.[/u]

The script reads the list of games and mods of the last active profiles from the latest Vortex backup JSON and provides them for further processing.
The result is returned as an array of type [font=Courier New]ModData [/font]and is meant to be further processed by other PowerShell commands, to filter, format, sort and convert it. See some examples below...

[size=5]Notes[/size]
[list]
[*] The script reads the data from the newer file in [font=Courier New]($($env:APPDATA)\Vortex\temp\state_backups_full\*.json)[/font]. Neither of these files is updated in real-time by Vortex. So, if you change something in the mod settings, it's best to restart Vortex.
[*] Mods with a status of [font=Courier New]Uninstalled[/font] in Vortex are not included in the list.
[/list]

[size=5]The custom type [b]ModData[/b][/size]
The returned array of type [font=Courier New]ModData[/font] contains most attributes that can be read from the Vortex backup file and that are useful.
The available properties can be listed by calling:

[code]Export-VortexModList | Get-Member
[/code]

[size=5]Disclaimer[/size]
I only tested this script with my own local copy of Vortex version 1.10.8. The script behaviour with other installations, older Vortex versions, or non-standard installations may be unpredictable or it may not work at all.

[size=5]Installation[/size]
Either clone this repository from GitHub to a location you like, or download the script here from NexusMods.

[size=5]Usage examples[/size]
You can find some examples in the Readme on [url=https://github.com/detlefs/Export-VertexModList]GitHub[/url]