# Dino Dash

Dinosaur egg tycoon built from Patrick's Roblox Studio pipeline.

## Game loop

Players earn eggs from hatched dinosaurs, spend eggs to hatch more dinosaurs, upgrade their nest for more capacity/income, and unlock purely cosmetic trails.

## Current scope

- Server-authoritative egg economy.
- Weighted dinosaur hatching.
- Nest upgrades and capacity limits.
- Cosmetic trail shop bought with earned eggs.
- Developer Product placeholders for egg packs, disabled until real IDs are added.
- DataStore-backed player data with retries, sanitization, autosave, and offline earnings cap.
- Mobile-first HUD built in Luau.
- Simple generated world so the place is playable immediately after Rojo sync/build.

## Roblox IDs

This project is registered in `../ROBLOX_STUDIO_PIPELINE/experiences.json` as `dino-dash`.

- Universe ID: `10089814885`
- Root Place ID: `121490965476892`
- API key env var: `ROBLOX_OPEN_CLOUD_API_KEY_DINODASH`

Publish through the pipeline dry-run first, then upload a saved version only after visual acceptance.

## Build

```bash
cd /mnt/d/Openclaw/DINO_DASH
rojo build default.project.json -o DinoDash.rbxlx
```
