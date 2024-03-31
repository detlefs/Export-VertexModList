<#
.SYNOPSIS
    This script reads the mods of last active profiles from the latest Vortex backup.json and provides them as a custom object array.
.DESCRIPTION
    This script reads the mods of the last active profiles from the latest Vortex backup.json and provides them as a custom object array.
    The result can then easily be processed by other powershell command to filter, format or convert it. The plain result is not very
    useful. It's meant to be further processed by other PowerShell commands, like Select-Object, Format-Table, Where-Object, Sort-Object, etc.

    Note: Mods with a status of "Uninstalled" in Vortex are not included in the list.

    The custom object array provides the following attributes:
    gameName            - The name of the game
    gameId              - The ID of the game
    id                  - The ID of the mod
    author              - The author name of the mod
    description         - The long description of tghe mod. In many cases, this field contains HTML markup
    homepage            - The homepage URL of the mod
    modName             - The mod name of the mod
    modVersion          - The version number of the mod
    name                - The name of the mod
    newestVersion       - The version number of the newest version of the mod
    pictureUrl          - The picture URL of the mod
    shortDescription    - The short descricption of the mod
    source              - The source (origin) of the mode
    state               - The state of the mode. Can only be "installed"
    loadOrderNumber     - The numeric value specifying the load order in Vortex
    enabled             - Whether the mod is enabled or disabled

.NOTES
    As Vortex updates the used backup file ($($env:APPDATA)\Vortex\temp\state_backups_full\startup.json) during
    a new start of the tool, it's best to use Export-VortexModList right after starting Vortex. If settings are
    changed in Vortex, it's necessary to restart it to update the backup file.
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
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
    .\Export-VortexModlist | Where-Object gameName -eq baldursgate3 | Select-Object modName, id, `
    author, modVersion, state, loadOrderNumber, enabled | Sort-Object loadOrderNumber | `
    Format-Table -AutoSize

    Reads all data from the Vortex backup and the result is piped to Where-Object, then to Select-Object,
    then to Sort-Object and finally to Format-Table.
    The result is a list of mods for the game Baldur's Gate III with only the columns modName, id, author,
    modVersion, state, loadOrderNumber and enabled. The result is sorted by the load order and formatted as a table
.EXAMPLE
    .\Export-VortexModlist | Where-Object gameName -eq baldursgate3 | Select-Object modName, modVersion, `
    newestVersion, author, source, enabled, shortDescription | ConvertTo-Markdown `
    -Title "Baldur's Gate 3 mods" -AsTable | Set-Clipboard

    This example creates a tabe view in markdown syntax that can be easily pasted into any markdown-aware software
    like a Wiki website, or a notes app like Anytype, Notion or Joplyn, etc.

    Note: The ConvertTo-Markdown command belongs to a module Utility.PS that can be found
    here: https://www.powershellgallery.com/packages/Utility.PS/2.0.1
#>

[CmdletBinding()]

Param(
)

# Class for games
class GameData {
    [string]$name
    [string]$id

    GameData([string]$name, [string]$id) {
        $this.name = $name
        $this.id = $id
    }
}

# Class for mod data
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

# variable
$vortexBackupJsonPath = "$($env:APPDATA)\Vortex\temp\state_backups_full\startup.json"
$game = @()
$mod = @()

# Read the latest backup JSON
$vortexBackupJson = Get-Content -Path $vortexBackupJsonPath | ConvertFrom-Json

# Get the last active games
$lastActiveProfile = $vortexBackupJson.settings.profiles.lastActiveProfile
foreach ($key in $lastActiveProfile.PSObject.Properties.Name) {
    #Write-Host "Name: $key, Value $($lastActiveProfile.$key)"
    $game += [GameData]::new($key, $($lastActiveProfile.$key))
}

# Get the mods for each game
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

$mod