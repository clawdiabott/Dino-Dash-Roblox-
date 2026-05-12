param(
  [Parameter(Position=0)] [string] $Target = 'claw-machine',
  [string] $File,
  [switch] $Saved,
  [switch] $Yes,
  [switch] $RestartServers,
  [switch] $DryRun
)

$ErrorActionPreference = 'Stop'

$targets = @{
  'claw-machine' = @{
    Project = 'D:\Openclaw\CLAWDIAS-CLAWMACHINE'
    BuildDir = 'D:\Openclaw\CLAWDIAS-CLAWMACHINE\build'
    PlaceId = '103982561389598'
    UniverseId = '10135510431'
    ApiKeyPath = 'D:\Openclaw\roblox credentials\roblox api.txt'
  }
}

if (-not $targets.ContainsKey($Target)) {
  throw "Unknown target '$Target'. Known targets: $($targets.Keys -join ', ')"
}

$t = $targets[$Target]
$rbxcloud = 'D:\Openclaw\tools\bin\rbxcloud.exe'
if (-not (Test-Path $rbxcloud)) { throw "rbxcloud not found: $rbxcloud" }
if (-not (Test-Path $t.ApiKeyPath)) { throw "Roblox API key file not found: $($t.ApiKeyPath)" }

$apiKey = (Get-Content -Raw -Path $t.ApiKeyPath).Trim()
if ([string]::IsNullOrWhiteSpace($apiKey)) { throw 'Roblox API key file is empty.' }

if (-not $File) {
  $latest = Get-ChildItem -Path $t.BuildDir -Filter '*.rbxl*' -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $latest) { throw "No .rbxl/.rbxlx files found in $($t.BuildDir)" }
  $File = $latest.FullName
}

if (-not (Test-Path $File)) { throw "Publish file not found: $File" }

$versionType = if ($Saved) { 'saved' } else { 'published' }

Write-Host "Target: $Target" -ForegroundColor Cyan
Write-Host "File: $File" -ForegroundColor Cyan
Write-Host "PlaceId: $($t.PlaceId)" -ForegroundColor Cyan
Write-Host "UniverseId: $($t.UniverseId)" -ForegroundColor Cyan
Write-Host "VersionType: $versionType" -ForegroundColor Cyan

if ($DryRun) {
  Write-Host 'Dry run only. Nothing published.' -ForegroundColor Yellow
  exit 0
}

if (-not $Yes) {
  $answer = Read-Host "Publish this place to Roblox now? Type PUBLISH to continue"
  if ($answer -ne 'PUBLISH') {
    Write-Host 'Cancelled.' -ForegroundColor Yellow
    exit 1
  }
}

$args = @(
  'experience','publish',
  '--filename', $File,
  '--place-id', $t.PlaceId,
  '--universe-id', $t.UniverseId,
  '--version-type', $versionType,
  '--api-key', $apiKey,
  '--pretty'
)

& $rbxcloud @args
$code = $LASTEXITCODE
if ($code -ne 0) { throw "rbxcloud publish failed with exit code $code" }

if ($RestartServers) {
  Write-Host 'Restarting Roblox servers...' -ForegroundColor Yellow
  & $rbxcloud universe restart --universe-id $t.UniverseId --api-key $apiKey --pretty
  if ($LASTEXITCODE -ne 0) { throw "rbxcloud server restart failed with exit code $LASTEXITCODE" }
}

$logDir = 'D:\Openclaw\publish-logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$log = Join-Path $logDir "$Target-$stamp.txt"
@"
Target: $Target
File: $File
PlaceId: $($t.PlaceId)
UniverseId: $($t.UniverseId)
VersionType: $versionType
RestartServers: $RestartServers
PublishedAt: $(Get-Date -Format o)
"@ | Set-Content -Path $log
Write-Host "Publish log: $log" -ForegroundColor Green
