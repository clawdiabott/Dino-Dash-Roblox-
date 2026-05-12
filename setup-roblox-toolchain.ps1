# Adds the local Roblox toolchain installed by Clawdia to this PowerShell session.
# Usage from PowerShell:
#   . D:\Openclaw\setup-roblox-toolchain.ps1

$toolBin = 'D:\Openclaw\tools\bin'
if (-not (Test-Path $toolBin)) {
    throw "Toolchain bin folder not found: $toolBin"
}

if (($env:Path -split ';') -notcontains $toolBin) {
    $env:Path = "$toolBin;$env:Path"
}

Write-Host "Roblox toolchain available from $toolBin" -ForegroundColor Green
rojo --version
wally --version
rbxcloud --version
aftman --version
if (Get-Command gh -ErrorAction SilentlyContinue) { gh --version | Select-Object -First 1 }
