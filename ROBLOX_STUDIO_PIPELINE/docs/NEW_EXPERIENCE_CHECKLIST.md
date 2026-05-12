# New Roblox Experience Checklist

Use this every time Patrick creates a new game.

## Patrick does this once per game

1. Create a blank Roblox experience.
2. Set ownership correctly: personal `clawdiaos` or the ClawdiaOS group.
3. Copy the Universe ID.
4. Copy the root Place ID.
5. Create or update an Open Cloud API key with the minimum required scopes.
6. Add the key to `D:\Openclaw\roblox credentials\roblox api.txt` as a new env var.

Example:

```text
ROBLOX_OPEN_CLOUD_API_KEY_DINODASH=...
ROBLOX_UNIVERSE_ID_DINODASH=123456
ROBLOX_PLACE_ID_DINODASH=987654
```

## Hermes/RobloxMax does this

```bash
cd /mnt/d/Openclaw/ROBLOX_STUDIO_PIPELINE
python3 tools/new_game.py dino-dash \
  --name "Dino Dash" \
  --universe-id 123456 \
  --place-id 987654 \
  --api-key-env ROBLOX_OPEN_CLOUD_API_KEY_DINODASH
```

Then all production files live at:

```text
D:\Openclaw\DINO_DASH
```

## Open Cloud scopes

Minimum for publishing place versions:

- Place publishing / create place version permission for the target universe/place.

Add only if needed:

- Universes/places metadata update
- Developer products
- Game passes
- Badges
- Data stores
- Localization
- Luau execution

Never use broad keys unless there is a clear reason.
