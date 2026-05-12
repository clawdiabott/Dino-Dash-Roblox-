# Roblox Toolchain Status

## Repo
- Cloned: `D:\Openclaw\CLAWDIAS-CLAWMACHINE`
- Remote: `https://github.com/clawdiabott/CLAWDIAS-CLAWMACHINE.git`
- Rojo project: `default.project.json`

## Installed locally
Tools were installed locally under `D:\Openclaw\tools\bin` instead of system-wide.

- Aftman `0.3.0`
- Rojo `7.6.1`
- Wally `0.3.2`
- rbxcloud `0.17.0`

## Use in PowerShell
```powershell
. D:\Openclaw\setup-roblox-toolchain.ps1
cd D:\Openclaw\CLAWDIAS-CLAWMACHINE
rojo serve default.project.json
```

## Build verification
Built successfully with:
```powershell
rojo build default.project.json --output D:\Openclaw\CLAWDIAS-CLAWMACHINE\build\LobsterClawArena.rbxlx
```

Output:
`D:\Openclaw\CLAWDIAS-CLAWMACHINE\build\LobsterClawArena.rbxlx`

## GitHub auth status
- `gh` CLI is not installed/detected.
- Public clone/access works.
- Push/private repo operations may require Git Credential Manager, a PAT, or installing/authing GitHub CLI.

## Roblox Open Cloud auth needed later
`rbxcloud` is installed, but publishing/experience automation will require a Roblox Open Cloud API key plus universe/place IDs.
