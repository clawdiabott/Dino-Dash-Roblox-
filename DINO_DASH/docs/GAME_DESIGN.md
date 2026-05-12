# Dino Dash game design

## Core loop

1. Player starts with 25 eggs.
2. Player hatches a dinosaur egg.
3. Each dinosaur generates eggs per second on the server.
4. Player spends eggs on more hatches or nest upgrades.
5. Nest upgrades increase capacity and income multiplier.
6. Player unlocks cosmetic trails using earned eggs.

## Dinosaur hatch table

| Dinosaur | Rarity | Weight | Eggs/sec |
|---|---:|---:|---:|
| Starter Raptor | Common | 620 | 1 |
| Tri-Horn | Rare | 250 | 4 |
| Bronto Buddy | Epic | 95 | 12 |
| Shadow Rex | Legendary | 30 | 42 |
| Golden Ptero | Legendary | 5 | 125 |

## Nest upgrades

| Level | Cost | Capacity | Multiplier |
|---:|---:|---:|---:|
| 1 | starter | 8 | 1.0x |
| 2 | 100 | 16 | 1.25x |
| 3 | 500 | 30 | 1.6x |
| 4 | 2,500 | 50 | 2.1x |
| 5 | 12,000 | 85 | 3.0x |

## Monetization placeholder plan

Current monetization is intentionally disabled until real Roblox product/pass IDs exist.

Recommended first products:

- Small Egg Pack: grants 1,000 eggs.
- Mega Egg Pack: grants 12,000 eggs.
- VIP Nest Cosmetics pass: cosmetic-only VIP nest skins/trails; no authoritative advantage unless Patrick decides otherwise.

All grants must stay server-side in ReceiptProcessor.

## Security model

- Clients send only requested actions.
- Server validates payload shape and action names.
- Server rate-limits action remotes.
- Server owns eggs, hatch rolls, nest level, inventory, trail ownership, and purchase receipt grants.
- Developer Product IDs remain 0 until configured, so purchase prompts are disabled safely.

## Current product direction

Patrick's target is a full ancient dinosaur land and addictive dino hatch tycoon, not a small floating test platform.

Confirmed direction:

- More like a tycoon / base-building simulator than a simple hatch lobby.
- Player spawns near a personal nest cave with a single starter egg to collect.
- The starter egg hatches shortly after collection for an immediate first dinosaur.
- Dinosaurs can follow the player or be stored/displayed in the nest cave.
- Progression moves into exploration: find other egg nests and unlock separate zones.
- Use Roblox Studio-authored world assets, Terrain, models, or hybrid content as needed for the best full-world result.

Do not rush another publish until the next build is visually and mechanically aligned with the plan in:

- `docs/plans/2026-05-10-dino-dash-world-and-core-loop-plan.md`

## Expansion path

- Replace the prototype block/platform first impression with a full ancient island world.
- Rework HUD so it does not cover exploration.
- Add satisfying hatch reveal animations and rarity feedback.
- Add visible dinosaur pets or nest displays after hatching.
- Add zone progression: starter valley, jungle, volcano, ruins.
- Add nest plots per player.
- Add daily quests and retention rewards.
- Add analytics events for hatch, upgrade, trail unlock, session length, and purchase prompts.
- Replace starter DataStore wrapper with a full session-locking profile library before heavy live traffic.
