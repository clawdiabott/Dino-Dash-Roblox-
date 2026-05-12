param(
  [Parameter(Position=0)] [ValidateSet('list','status','publish','restart','update-name','update-description','register','help')] [string] $Command = 'help',
  [Parameter(Position=1)] [string] $Target,
  [string] $File,
  [string] $PlaceId,
  [string] $UniverseId,
  [string] $Name,
  [string] $Description,
  [switch] $Saved,
  [switch] $Yes,
  [switch] $DryRun
)

$ErrorActionPreference = 'Stop'
$Root = 'D:\Openclaw\roblox-publisher'
$RegistryPath = Join-Path $Root 'experiences.json'
$RbxCloud = 'D:\Openclaw\tools\bin\rbxcloud.exe'
$LogDir = 'D:\Openclaw\publish-logs'

function ConvertTo-Hashtable($obj) {
  if ($null -eq $obj) { return $null }
  if ($obj -is [System.Collections.IDictionary]) {
    $h = @{}
    foreach ($k in $obj.Keys) { $h[$k] = ConvertTo-Hashtable $obj[$k] }
    return $h
  }
  if ($obj -is [System.Management.Automation.PSCustomObject]) {
    $h = @{}
    foreach ($p in $obj.PSObject.Properties) { $h[$p.Name] = ConvertTo-Hashtable $p.Value }
    return $h
  }
  if ($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])) {
    return @($obj | ForEach-Object { ConvertTo-Hashtable $_ })
  }
  return $obj
}

function Load-Registry {
  if (-not (Test-Path $RegistryPath)) { return @{} }
  $raw = Get-Content -Raw -Path $RegistryPath
  if ([string]::IsNullOrWhiteSpace($raw)) { return @{} }
  return ConvertTo-Hashtable ($raw | ConvertFrom-Json)
}

function Save-Registry($registry) {
  New-Item -ItemType Directory -Force -Path (Split-Path $RegistryPath) | Out-Null
  ($registry | ConvertTo-Json -Depth 8) | Set-Content -Path $RegistryPath -Encoding UTF8
}

function Get-ApiKey($path) {
  if (-not (Test-Path $path)) { throw "API key file not found: $path" }
  # Credentials file may contain notes/extra lines. Use first line that looks like an Open Cloud API token.
  $lines = Get-Content -Path $path | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  $candidates = @()
  foreach ($line in $lines) {
    $value = $line
    if ($line.Contains('=')) { $value = ($line -split '=', 2)[1].Trim() }
    elseif ($line.Contains(':')) { $value = ($line -split ':', 2)[1].Trim() }
    $value = $value.Trim('"').Trim("'")
    if ($value) { $candidates += $value }
  }
  foreach ($candidate in $candidates) {
    if ($candidate.Length -gt 80 -and $candidate -notmatch '\s') { return $candidate }
  }
  if ($candidates.Count -gt 0) { return $candidates[0] }
  throw "API key file is empty: $path"
}

function Get-Target($registry, $target) {
  if (-not $target) { throw 'Target required. Example: roblox-prod publish claw-machine' }
  if (-not $registry.ContainsKey($target)) {
    throw "Unknown target '$target'. Run: roblox-prod list"
  }
  return $registry[$target]
}

function Get-LatestBuild($t) {
  if ($File) { if (-not (Test-Path $File)) { throw "File not found: $File" }; return $File }
  $pattern = if ($t.latestBuildPattern) { $t.latestBuildPattern } else { '*.rbxl*' }
  $latest = Get-ChildItem -Path $t.buildDir -Filter $pattern -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $latest) { throw "No build files found in $($t.buildDir)" }
  return $latest.FullName
}

function Confirm-Live($message) {
  if ($Yes) { return }
  $answer = Read-Host "$message Type PUBLISH to continue"
  if ($answer -ne 'PUBLISH') { throw 'Cancelled.' }
}

function Help {
  @'
roblox-prod — ClawdiaOS Roblox production tool

Commands:
  roblox-prod list
  roblox-prod status <target>
  roblox-prod publish <target> [-File path] [-Saved] [-Yes] [-DryRun]
  roblox-prod restart <target> [-Yes]
  roblox-prod update-name <target> -Name "New Name" [-Yes]
  roblox-prod update-description <target> -Description "Text" [-Yes]
  roblox-prod register <target> -PlaceId ID -UniverseId ID

Examples:
  roblox-prod list
  roblox-prod publish claw-machine
  roblox-prod register grass-gobbler -PlaceId 123 -UniverseId 456
  roblox-prod publish grass-gobbler

Notes:
- Creating brand-new Roblox experiences may still require Creator Dashboard/Studio.
- Once PlaceId + UniverseId are registered, publishing/updating is automated.
- Avatar Marketplace final submission still requires Studio validation/moderation.
'@ | Write-Host
}

$registry = Load-Registry

switch ($Command) {
  'help' { Help; break }
  'list' {
    foreach ($key in $registry.Keys) {
      $t = $registry[$key]
      $place = if ($t.placeId) { $t.placeId } else { '[needs PlaceId]' }
      $universe = if ($t.universeId) { $t.universeId } else { '[needs UniverseId]' }
      Write-Host "$key`t$($t.name)`tPlace=$place`tUniverse=$universe"
    }
    break
  }
  'register' {
    if (-not $Target) { throw 'Target required.' }
    if (-not $PlaceId -or -not $UniverseId) { throw 'Register requires -PlaceId and -UniverseId.' }
    if (-not $registry.ContainsKey($Target)) { $registry[$Target] = @{} }
    $registry[$Target].placeId = $PlaceId
    $registry[$Target].universeId = $UniverseId
    if (-not $registry[$Target].apiKeyPath) { $registry[$Target].apiKeyPath = 'D:\Openclaw\roblox credentials\roblox api.txt' }
    Save-Registry $registry
    Write-Host "Registered $Target => Place=$PlaceId Universe=$UniverseId" -ForegroundColor Green
    break
  }
}

if ($Command -in @('status','publish','restart','update-name','update-description')) {
  if (-not (Test-Path $RbxCloud)) { throw "rbxcloud not found: $RbxCloud" }
  $t = Get-Target $registry $Target
  if (-not $t.placeId -or -not $t.universeId) {
    throw "$Target is not connected to a Roblox place yet. Create/choose a place in Creator Dashboard, then run: roblox-prod register $Target -PlaceId <id> -UniverseId <id>"
  }
  $apiKey = Get-ApiKey $t.apiKeyPath

  if ($Command -eq 'status') {
    & $RbxCloud universe get --universe-id $t.universeId --api-key $apiKey --pretty
    & $RbxCloud place get --universe-id $t.universeId --place-id $t.placeId --api-key $apiKey --pretty
  }

  if ($Command -eq 'publish') {
    $publishFile = Get-LatestBuild $t
    $versionType = if ($Saved) { 'saved' } else { 'published' }
    Write-Host "Target: $Target" -ForegroundColor Cyan
    Write-Host "Name: $($t.name)" -ForegroundColor Cyan
    Write-Host "File: $publishFile" -ForegroundColor Cyan
    Write-Host "PlaceId: $($t.placeId)" -ForegroundColor Cyan
    Write-Host "UniverseId: $($t.universeId)" -ForegroundColor Cyan
    Write-Host "VersionType: $versionType" -ForegroundColor Cyan
    if ($DryRun) { Write-Host 'Dry run only.' -ForegroundColor Yellow; exit 0 }
    Confirm-Live 'Publish this Roblox experience now?'
    & $RbxCloud experience publish --filename $publishFile --place-id $t.placeId --universe-id $t.universeId --version-type $versionType --api-key $apiKey --pretty
    if ($LASTEXITCODE -ne 0) { throw "Publish failed with exit code $LASTEXITCODE" }
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    "Published $Target`nFile=$publishFile`nPlace=$($t.placeId)`nUniverse=$($t.universeId)`nAt=$(Get-Date -Format o)" | Set-Content (Join-Path $LogDir "$Target-$stamp.txt")
  }

  if ($Command -eq 'restart') {
    Confirm-Live 'Restart live Roblox servers now?'
    & $RbxCloud universe restart --universe-id $t.universeId --api-key $apiKey --pretty
    if ($LASTEXITCODE -ne 0) { throw "Restart failed with exit code $LASTEXITCODE" }
  }

  if ($Command -eq 'update-name') {
    if (-not $Name) { throw 'Use -Name "New Name"' }
    Confirm-Live "Update experience name to '$Name'?"
    & $RbxCloud universe update-name --universe-id $t.universeId --name $Name --api-key $apiKey --pretty
    if ($LASTEXITCODE -ne 0) { throw "Update name failed with exit code $LASTEXITCODE" }
  }

  if ($Command -eq 'update-description') {
    if (-not $Description) { throw 'Use -Description "New description"' }
    Confirm-Live 'Update experience description?'
    & $RbxCloud universe update-description --universe-id $t.universeId --description $Description --api-key $apiKey --pretty
    if ($LASTEXITCODE -ne 0) { throw "Update description failed with exit code $LASTEXITCODE" }
  }
}
