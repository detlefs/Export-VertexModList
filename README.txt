EXPORT-VORTEXMODLIST
--------------------
Important: This script is for those who know PowerShell! You should know
piping and how to process the result using other commands.

The script reads the list of games and mods of the last active profiles
from the latest Vortex backup.json and provides them for further processing.

The result is returned as an array of type `ModData` and is meant to be further
processed by other PowerShell commands, to further filter, format, sort and
convert it. See some samples below...

Note: Mods with a status of "Uninstalled" in Vortex are not included
in the list.

THE CUSTOM TYPE `MODDATA`
-------------------------
The returned array of type `ModData` contains most attributes that can be read
from the Vertex backup file and that are useful.

The available properties can be listed by calling

    Export-VortexModList | Get-Member

NOTES
-----
* The script reads the data from the newer file in
  ($($env:APPDATA)\Vortex\temp\state_backups_full\*.json). Neither of these
  files is updated real-time by Vortex. So, if you change something in the
  mod settings, it's best to restart Vortex if you want to see the change in
  this script.
* Mods with a status of "Uninstalled" in Vortex are not included in the list.

DISCLAIMER
----------
I only tested this script with my own local copy of Vortex version 1.10.8.
The script behavior with other installations, older Vortex versions, or non-
standard installations may be unpredictable or not work at all.

INSTALLATION
------------
Either clone this repository to a location you like, or download the script
from NexusMods.

USAGE EXAMPLES
--------------
You can find usage examples in the readme.md on GitHub here:
https://github.com/detlefs/Export-VertexModList
