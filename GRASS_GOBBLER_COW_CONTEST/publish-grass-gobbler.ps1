param(
  [Parameter(Mandatory=$true)] [string] $PlaceId,
  [Parameter(Mandatory=$true)] [string] $UniverseId,
  [switch] $Saved,
  [switch] $Yes
)

$ErrorActionPreference = 'Stop'
$rbxcloud = 'D:\Openclaw\tools\bin\rbxcloud.exe'
$file = 'D:\Openclaw\GRASS_GOBBLER_COW_CONTEST\build\Grass-Gobbler-Cow-Contest.rbxlx'
$keyPath = 'D:\Openclaw\roblox credentials\roblox api.txt'
$apiKey = (Get-Content -Raw -Path $keyPath).Trim()
$versionType = if ($Saved) { 'saved' } else { 'published' }

if (-not (Test-Path $file)) { throw "Build file not found: $file" }

Write-Host "Publishing Grass Gobbler Cow Contest" -ForegroundColor Cyan
Write-Host "File: $file" -ForegroundColor Cyan
Write-Host "PlaceId: $PlaceId" -ForegroundColor Cyan
Write-Host "UniverseId: $UniverseId" -ForegroundColor Cyan
Write-Host "VersionType: $versionType" -ForegroundColor Cyan

if (-not $Yes) {
  $answer = Read-Host 'Type PUBLISH to publish this new cow farm experience'
  if ($answer -ne 'PUBLISH') { Write-Host 'Cancelled.'; exit 1 }
}

& $rbxcloud experience publish --filename $file --place-id $PlaceId --universe-id $UniverseId --version-type $versionType --api-key $apiKey --pretty
if ($LASTEXITCODE -ne 0) { throw "rbxcloud publish failed with exit code $LASTEXITCODE" }

$logDir = 'D:\Openclaw\publish-logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
@"
Experience: Grass Gobbler Cow Contest
File: $file
PlaceId: $PlaceId
UniverseId: $UniverseId
VersionType: $versionType
PublishedAt: $(Get-Date -Format o)
"@ | Set-Content -Path (Join-Path $logDir "grass-gobbler-$stamp.txt")
