# ClawdiaOS Roblox Studio Pipeline

This is Patrick's reusable text-to-production Roblox pipeline.

Goal: Patrick supplies the game idea plus Roblox IDs for each new blank experience. Hermes/RobloxMax turns the text into a Rojo/Wally/strict-Luau project, safe networking, monetization modules, build output, and a controlled publish command.

## What this includes

- Rojo project template
- Wally package file
- Selene config
- StyLua config
- `.luaurc` strict Luau config
- secure RemoteEvent registry
- per-player rate limiter
- payload validator
- MarketplaceService developer product receipt processor skeleton
- game pass entitlement service
- Python publisher that does not print secrets
- new-game generator that registers each new experience

## Golden workflow

1. Patrick creates a blank Roblox experience in Studio or Creator Dashboard.
2. Patrick adds the IDs/key to `D:\Openclaw\roblox credentials\roblox api.txt`.
3. Run `python tools/new_game.py <slug> --name "Game Name" --universe-id <id> --place-id <id> --api-key-env ROBLOX_OPEN_CLOUD_API_KEY_<GAME>`.
4. Build/enhance the generated project under `D:\Openclaw\<GAME_SLUG>`.
5. Dry-run publish.
6. Publish as `saved` first.
7. Smoke-test in Studio / Roblox.
8. Publish/release when approved.

## Commands from WSL

```bash
cd /mnt/d/Openclaw/ROBLOX_STUDIO_PIPELINE
python3 tools/new_game.py dino-dash --name "Dino Dash" --universe-id 123 --place-id 456 --api-key-env ROBLOX_OPEN_CLOUD_API_KEY_DINODASH
python3 tools/publish_place.py dino-dash --dry-run
```

## Commands from Windows PowerShell

```powershell
cd D:\Openclaw\ROBLOX_STUDIO_PIPELINE
py tools\new_game.py dino-dash --name "Dino Dash" --universe-id 123 --place-id 456 --api-key-env ROBLOX_OPEN_CLOUD_API_KEY_DINODASH
py tools\publish_place.py dino-dash --dry-run
```

## Publish safety

- The publisher defaults to `--version-type saved`.
- It asks for `PUBLISH` before uploading unless `--yes` is passed.
- It redacts API keys from logs.
- It requires IDs from `experiences.json`; no guessing.
- Use one API key per game when possible.

## What Patrick gives for every new game

```text
Game name:
Slug:
Universe ID:
Root Place ID:
API key env var name:
Genre:
One-sentence hook:
Monetization wanted:
```

Do not send passwords, cookies, 2FA codes, or recovery codes.
