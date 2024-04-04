<#
.SYNOPSIS
    This script reads the list of mods from the Vortex backup.json and provides them as a object array.
.DESCRIPTION 
    This script reads the mods from the latest Vortex backup.json and provides them as a object array.
    The result can then easily be processed by other powershell command to filter, format or convert it. The
    core result is not very useful by itself. It's meant to be further processed by other PowerShell commands.

    Note: Mods with a status of "Uninstalled" in Vortex are not included in the list.
    
    Note: The script reads the data from the newer file in ($($env:APPDATA)\Vortex\temp\state_backups_full\*.json).
    Neither of these files is updated real-time by Vortex. So, if you change something in the mod settings, it's
    best to restart Vortex if you want to see the change in this script.

    The available properties returned by the script can be listed by calling:
    Export-VortexModList | Get-Member

.LINK
    https://github.com/detlefs/Export-VertexModList
.EXAMPLE
    Export-VortexModList

    Reads all data from the Vortex backup file and returns an object array of type ModData.
.EXAMPLE
    Export-VortexModList | Where-Object gameName -eq baldursgate3

    Reads all data from the Vortex backup and the result is piped to the Where-Object command that is
    filtering the mod list for the name of the game.
    The result is a mod list only containing the mods used by Baldur's Gate III
.EXAMPLE
    Export-VortexModList | Select-Object gameName -Unique

    Reads all data from the Vortex backup and the result is piped to Select-Object.
    The result is a list of the games.
#>

[CmdletBinding()]

# Parameters: Currently there are none.
Param(
)

# Class for games. Holds data read about the games in the backup.
class GameData {
    [string]$name
    [string]$id

    GameData([string]$name, [string]$id) {
        $this.name = $name
        $this.id = $id
    }
}

# Class for mod data. Holds data about the mods and games
class ModData
{
    [string]$gameName
    [string]$gameId
    [string]$id
    [string]$author
    [string]$description
    [string]$homepage
    [string]$modName
    [string]$modVersion
    [string]$name
    [string]$newestVersion
    [string]$pictureUrl
    [string]$shortDescription
    [string]$source
    [string]$state
    [long]$loadOrderNumber
    [string]$enabled

    ModData([string]$gameName, [string]$gameId, [string]$id, [string]$description, [string]$author, [string]$homepage, [string]$modName, [string]$modVersion, [string]$name, [string]$newestVersion, [string]$pictureUrl, [string]$shortDescription, [string]$source, [string]$state, [long]$loadOrderNumber, [string]$enabled)
    {
        $this.gameName = $gameName
        $this.gameId = $gameId
        $this.id = $id
        $this.author = $author
        $this.description = $description
        $this.homepage = $homepage
        $this.modName = $modName
        $this.modVersion = $modVersion
        $this.name = $name
        $this.newestVersion = $newestVersion
        $this.pictureUrl = $pictureUrl
        $this.shortDescription = $shortDescription
        $this.source = $source
        $this.state = $state
        $this.loadOrderNumber = $loadOrderNumber
        $this.enabled = $enabled
    }
}

# Globval variables
$vortexBackupJsonPath = "$($env:APPDATA)\Vortex\temp\state_backups_full\*.json"
$game = @()
$mod = @()

# Read the latest backup JSON from the default location of the Vortex backup files.
try {
    $latest = Get-ChildItem -Path $vortexBackupJsonPath | Sort-Object LastAccessTime -Descending | Select-Object -First 1
    $vortexBackupJson = Get-Content -Path $latest | ConvertFrom-Json
}
catch {
    "Could not read the vortex backup file: $_"
    return
}

# Get the last active games from the backup and add it to the $game array.
$lastActiveProfile = $vortexBackupJson.settings.profiles.lastActiveProfile

foreach ($key in $lastActiveProfile.PSObject.Properties.Name) {
    $game += [GameData]::new($key, $($lastActiveProfile.$key))
}

if ($game.count -lt 1) {
    Write-Host "No games found!" -ForegroundColor Yellow
    return
}

# Get the mods for each game from the backup and add details to the $mod array
foreach ($g in $game) {
    $modList = $vortexBackupJson.persistent.mods.$($g.name)

    foreach ($modKey in $modList.PSObject.Properties.Name) {
        $m = $vortexBackupJson.persistent.mods.$($g.name).$($modKey)
        $enabledState = $vortexBackupJson.persistent.profiles.$($g.id).modState.$modKey.enabled
        $sortOrder = $vortexBackupJson.persistent.loadOrder.$($g.id)
        $matchingItem = $sortOrder | Where-Object { $_.modId -eq $($m.id) }
        if ($matchingItem) {
            $index = $sortOrder.IndexOf($matchingItem)
        }
        $mod += [ModData]::new($g.name, $g.id, $m.id, $m.attributes.description, $m.attributes.author, $m.attributes.homepage, $m.attributes.modName, $m.attributes.modVersion, $m.attributes.name, $m.attributes.newestVersion, $m.attributes.pictureUrl, $m.attributes.shortDescription, $m.attributes.source, $m.state, $index, $enabledState)
    }
}

# Return the $mod array
$mod
