# Dino Dash deployment readiness

Status: buildable and ready for saved-version deployment through Patrick's Roblox Studio pipeline after visual approval.

## Current target

- Slug: `dino-dash`
- Universe ID: `10089814885`
- Place ID: `121490965476892`
- API key env var: `ROBLOX_OPEN_CLOUD_API_KEY_DINODASH`
- Build artifact: `build/dino-dash.rbxlx`

## Production gates completed

- Strict Luau source files are under `src/`.
- Server-authoritative economy, hatching, nest upgrades, zone unlocks, trails, and receipt grants.
- RemoteEvent payload validation and per-player rate limits.
- Server distance checks for egg nest collection and zone gate unlock remotes.
- DataStore load/save retry, sanitization, schema migration, autosave, offline earnings cap, and safe shutdown save.
- Persistent developer-product receipt tracking in player data so a purchase ID is granted once.
- Starter valley fallback objects in `default.project.json` so the place never opens as empty sky.
- Runtime generated ancient valley/cave/egg-nest world through `WorldService`.
- Mobile-first HUD with objective guidance and state retry recovery.
- Selene validation passes.
- Rojo build passes.
- Pipeline dry-run resolves IDs, builds the rbxlx, and redacts the API key.

## Publish sequence

Run from `D:\Openclaw\ROBLOX_STUDIO_PIPELINE` or `/mnt/d/Openclaw/ROBLOX_STUDIO_PIPELINE`:

```bash
python3 tools/publish_place.py dino-dash --dry-run
python3 tools/publish_place.py dino-dash --version-type saved
```

Only after a Studio/playtest spawn screenshot confirms the player immediately sees the nest cave, glowing starter egg, first objective, and starter valley landmarks should the saved version be promoted/published live.

## Current validation commands

```bash
cd /mnt/d/Openclaw/DINO_DASH
selene src
rojo build default.project.json -o build/dino-dash.rbxlx

cd /mnt/d/Openclaw/ROBLOX_STUDIO_PIPELINE
python3 tools/publish_place.py dino-dash --dry-run
```

## Remaining before real monetization

- Replace Developer Product IDs in `src/shared/Monetization/ProductConfig.lua`; all product IDs must remain `0` until real products exist.
- Test purchases in Roblox's normal purchase flow before enabling paid traffic.
- Consider a mature profile/session-locking library before large live traffic, or add explicit session lock fields to this custom DataStore wrapper.
- Add analytics events for tutorial completion, hatches, upgrades, zone unlocks, session length, and purchase prompt outcomes.
