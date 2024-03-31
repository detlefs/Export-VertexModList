<#PSScriptInfo
.VERSION 1.0.0
.GUID 4609f00c-e850-4d3f-9c69-3741e56e4133
.AUTHOR detlefs@gmail.com
.COMPANYNAME
.COPYRIGHT © 2024 detlefs@gmail.com
.TAGS
.LICENSEURI
.PROJECTURI https://github.com/detlefs/Export-VertexModList
.ICONURI
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.PRIVATEDATA
#>

<#
.SYNOPSIS
    This script reads the mods of last active profiles from the latest Vortex backup.json and provides them as a custom object array.
.DESCRIPTION 
    This script reads the mods of the last active profiles from the latest Vortex backup.json and provides them as a custom object array.
    The result can then easily be processed by other powershell command to filter, format or convert it. The plain result is not very
    useful. It's meant to be further processed by other PowerShell commands, like Select-Object, Format-Table, Where-Object, Sort-Object, etc.

    Note: Mods with a status of "Uninstalled" in Vortex are not included in the list.
    
    Note: As Vortex updates the used backup file ($($env:APPDATA)\Vortex\temp\state_backups_full\startup.json) during
    a new start of the tool, it's best to use Export-VortexModList right after starting Vortex. If settings are
    changed in Vortex, it's necessary to restart it to update the backup file.

    The available properties can be listed by calling:
    Export-VortexModList | Get-Member

.LINK
    https://github.com/detlefs/Export-VertexModList/blob/master/README.md
.EXAMPLE
    Export-VortexModList

    Reads all data from the Vortex backup file and returns a custom object array.
.EXAMPLE
    Export-VortexModList | Where-Object gameName -eq baldursgate3

    Reads all data from the Vortex backup and the result is piped to the Where-Object command that is
    filtering the mod list for the name of the game.
    The result is a mod list only containing the mods used by Baldur's Gate III
.EXAMPLE
    Export-VortexModList | Select-Object gameName -Unique

    Reads all data from the Vortex backup and the result is piped to Select-Object.
    The result is a list of the games.
.EXAMPLE
    Export-VortexModlist | Where-Object gameName -eq baldursgate3 | Select-Object modName, id, `
    author, modVersion, state, loadOrderNumber, enabled | Sort-Object loadOrderNumber | `
    Format-Table -AutoSize

    Reads all data from the Vortex backup and the result is piped to Where-Object, then to Select-Object,
    then to Sort-Object and finally to Format-Table.
    The result is a list of mods for the game Baldur's Gate III with only the columns modName, id, author,
    modVersion, state, loadOrderNumber and enabled. The result is sorted by the load order and formatted as a table
.EXAMPLE
    Export-VortexModlist | Where-Object gameName -eq baldursgate3 | Select-Object modName, modVersion, `
    newestVersion, author, source, enabled, shortDescription | ConvertTo-Markdown `
    -Title "Baldur's Gate 3 mods" -AsTable | Set-Clipboard

    This example creates a tabe view in markdown syntax that can be easily pasted into any markdown-aware software
    like a Wiki website, or a notes app like Anytype, Notion or Joplyn, etc.

    Note: The ConvertTo-Markdown command belongs to a module Utility.PS that can be found
    here: https://www.powershellgallery.com/packages/Utility.PS/2.0.1
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
$vortexBackupJsonPath = "$($env:APPDATA)\Vortex\temp\state_backups_full\startup.json"
$game = @()
$mod = @()

# Read the latest backup JSON. Note, this is the default location of the Vortex backup file.
$vortexBackupJson = Get-Content -Path $vortexBackupJsonPath | ConvertFrom-Json

# Get the last active games from the backup and add it to the $game array.
$lastActiveProfile = $vortexBackupJson.settings.profiles.lastActiveProfile
foreach ($key in $lastActiveProfile.PSObject.Properties.Name) {
    $game += [GameData]::new($key, $($lastActiveProfile.$key))
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
