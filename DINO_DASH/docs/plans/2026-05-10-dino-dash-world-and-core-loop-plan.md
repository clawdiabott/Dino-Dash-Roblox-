# Dino Dash Full World + Addictive Hatch Loop Implementation Plan

> **For Hermes:** Do not publish during this planning phase. Use this plan to align the game vision first, then implement in small verified milestones.

**Goal:** Turn Dino Dash from a flat prototype into a full ancient dinosaur land with a clear, addictive hatch/collect/upgrade loop.

**Architecture:** Keep the existing server-authoritative economy and Rojo pipeline, but stop generating a tiny runtime test map as the final experience. Build a proper staged world system with visible landmarks, player guidance, collectible dino pets, zone progression, and clear UI feedback. Each milestone must be validated in Studio/Roblox before publishing.

**Tech Stack:** Roblox Studio + Rojo, strict Luau, Selene, Open Cloud publishing only after approval.

---

## Current Screenshot Diagnosis

The current live game is not meeting the product goal.

Observed from Patrick's screenshot:

- The loading issue is fixed: the HUD now receives state and shows eggs, income, nest, hatch cost, and collection progress.
- The world still visually reads as a small rectangular green platform floating in the sky.
- The player cannot immediately see an ancient dinosaur land, volcano, forest, hatchery, or clear adventure layout.
- The HUD covers a large amount of screen space and hides the world. It is functional, but too dominant for exploration.
- The game loop exists technically, but the fantasy is not visible yet.

Likely technical reasons:

- The visible static fallback platform from `default.project.json` is still dominating the first impression.
- The runtime-generated world parts are either too far from spawn, too low-detail, too hidden by camera/HUD, or not loading in a way that creates a convincing first view.
- The current world strategy is still a prototype: procedural Parts and signs, not a composed full experience.

Decision:

- Pause publishing updates until the next version is visibly correct in local build/Studio/playtest.
- Treat the next work as a proper design/build pass, not a quick patch.

---

## Product Pillars

## Patrick's Confirmed Direction

Dino Dash should lean more like a **tycoon / base-building simulator** than a pure pet hatch lobby. The player's nest cave is their home base, and exploration feeds that base.

Confirmed gameplay direction:

- Player spawns near their own nest cave / starter nest, not in an empty lobby.
- First 5 minutes begin with a single nearby starter egg to collect.
- The first egg hatches shortly after the player collects it, giving an immediate dinosaur companion.
- Dinosaurs can either follow the player or be stored/displayed in the player's nest cave.
- Progression comes from exploring the world and finding other egg nests.
- The world should have separate unlockable zones, each with different egg nests, dinosaurs, resources, and visual identity.
- Use Roblox Studio-authored world pieces, Terrain, models, or hybrid authored/generated content -- whichever produces the strongest full-world result. Do not rely on a small script-generated block map as the final experience.

Design interpretation:

- **Home base loop:** collect eggs -> hatch dinos -> assign/follow/store dinos -> generate eggs/resources -> upgrade nest cave -> unlock new zone.
- **Exploration loop:** leave nest -> follow paths/signposts -> discover egg nests -> collect/activate eggs -> return to cave or hatch in-world -> expand collection.
- **Tycoon feel:** the nest cave visibly upgrades over time with more platforms, decorations, dino beds, egg incubators, gates, trophies, and storage slots.

---

### 1. First 5 Minutes

When a player joins, they should immediately understand:

- This is their dinosaur nest cave / tycoon base.
- A starter egg is nearby and should be collected first.
- The starter egg hatches shortly after collection so the player gets a quick win.
- The first dinosaur can follow the player or be sent back to the nest cave.
- The nest cave is upgradeable and should visibly grow over time.
- Exploration is the next objective: paths lead to other egg nests and locked zones.
- Separate unlockable zones are the long-term progression path.
- There are cool places to discover: starter valley, jungle, volcano, ruins, river/lake, rare nests, shops.

### 2. Core Addictive Loop

1. Hatch egg.
2. Get dinosaur reveal with rarity feedback.
3. Dinosaur appears/follows/stands in nest.
4. Dinosaur generates eggs.
5. Spend eggs on more hatches or nest upgrades.
6. Fill collection index.
7. Unlock new zones/eggs with better dinosaurs.
8. Come back for offline earnings/daily rewards.

### 3. World Fantasy

The world must feel like:

- Ancient prehistoric island.
- Big readable landmarks.
- Central spawn plaza.
- Hatchery as the main destination.
- Nest/base area as the player's home.
- Forest/jungle zone.
- Volcano zone.
- Ancient ruins zone.
- Future expansion paths visible but locked.

### 4. Production Guardrails

- Server owns all economy, hatches, unlocks, products, and rewards.
- Client only requests actions and shows UI/animations.
- DataStore code remains conservative until a session-locking profile library is added.
- No monetization products are enabled until IDs and grant behavior are reviewed.
- No publish until Patrick approves the playtest result.

---

## Acceptance Criteria Before Next Publish

The next publish is approved only if all are true:

- Spawn view shows a real ancient land, not a small flat block.
- Player sees at least 3 major landmarks without walking far.
- Hatchery, nest, shop, and at least 2 biomes are visually obvious.
- HUD does not cover the main play view.
- A new player spawns beside a personal nest cave / starter nest area.
- A single starter egg is visible, collectible, and clearly guided.
- The first egg hatches shortly after collection, not after confusing grinding.
- Hatch result has satisfying feedback: animation/message/rarity color.
- At least one visible dino appears after hatching and can follow the player or be stored/displayed in the nest cave.
- Economy state updates reliably after hatch/upgrade.
- Server lint/build pass with 0 Selene errors.
- Manual playtest checklist is completed.

---

## Milestone 0: Stop the Rushed Publish Loop

**Objective:** Lock the process so we build correctly before uploading again.

**Files:**
- Modify: `docs/GAME_DESIGN.md`
- Create: `docs/plans/2026-05-10-dino-dash-world-and-core-loop-plan.md`

**Steps:**

1. Keep this plan in repo.
2. Do not run `publish_place.py --version-type published` until Patrick explicitly says the build matches the vision.
3. Use local Rojo build and Roblox Studio/playtest verification first.

**Verification:**

- Plan exists.
- Final response clearly says no new publish happened from this planning step.

---

## Milestone 1: Replace Prototype Platform With Real World Layout

**Objective:** Remove the small-block first impression and create a full island layout that reads well from spawn.

**Files:**
- Modify: `default.project.json`
- Modify: `src/server/Services/WorldService.lua`
- Possibly create: `src/shared/World/WorldConfig.lua`

**Design:**

The world should use a large layered island, not one flat rectangle:

- Main island: 900x900+ studs, rounded/organic shape using overlapping terrain-like parts or Studio terrain.
- Central spawn plaza: elevated stone/dirt circle.
- Hatchery: front-left from spawn, bright egg shrine.
- Player nest: front-center/right from spawn.
- Shop/cosmetic area: right side.
- Jungle: dense trees and path to the right/back.
- Volcano: large readable mountain left/back, visible from spawn.
- Ruins: stone temple/arches back/right.
- Water: river/lake crossing the map.

**Important:** If using generated Parts, the generated structures must be close enough and tall enough to be visible from spawn. If using Studio/Terrain, export via Rojo-compatible place file workflow.

**Tasks:**

1. Remove or shrink static fallback green platform in `default.project.json` so it does not dominate the live view.
2. Keep one emergency spawn safety pad hidden/embedded inside the real spawn plaza.
3. Build island as multiple overlapping biome sections, not one rectangular block.
4. Add landmark scale targets:
   - Volcano height: 120-180 studs.
   - Central spawn plaza diameter: 100-140 studs.
   - Hatchery egg: 35-50 studs high.
   - Ruins pillars: 40-70 studs high.
   - Trees: 30-80 studs high.
5. Add spawn-facing signs/arrows only where helpful; avoid cheap placeholder look.

**Verification:**

- In Studio/playtest, take a screenshot immediately after spawn.
- Screenshot must clearly show at least central plaza, hatchery, volcano/forest/ruins silhouette.
- From spawn, no floating rectangular test block should be the main visual.

---

## Milestone 2: Rework HUD So It Supports Exploration

**Objective:** Make the UI useful without covering the world.

**Files:**
- Modify: `src/client/Main.client.lua`

**Design:**

- Top-left compact currency/income panel.
- Bottom-center 2-3 primary action buttons max.
- Collection/index button opens a panel instead of always showing every dino count.
- Hatch button should be large near the hatchery, but not permanently cover the world.
- Mobile-first: buttons readable but not half-screen.

**Tasks:**

1. Split current large bottom HUD into compact panels.
2. Add `Eggs`, `Income`, `Nest` as top bar stats.
3. Move collection details into a toggle panel.
4. Keep `Hatch` as the primary button.
5. Make trail buttons secondary/shop-only or in a shop panel.
6. Add responsive constraints for phone, tablet, desktop.

**Verification:**

- On 1024x768-ish window, world remains visible.
- HUD covers less than 25% of screen during normal exploration.
- Player can hatch and upgrade without searching.

---

## Milestone 3: Make Hatching Feel Addictive

**Objective:** The first hatch should feel rewarding, not just text changing.

**Files:**
- Modify: `src/server/Services/PlayerDataService.lua`
- Modify: `src/server/Main.server.lua`
- Modify: `src/client/Main.client.lua`
- Modify: `src/shared/GameConfig.lua`
- Possibly create: `src/shared/DinoVisuals.lua`

**Design:**

- Server rolls hatch and returns result.
- Client plays egg shake/pop reveal animation.
- Rarity colors and sound/particles communicate reward tier.
- Newly hatched dino appears as a simple visible pet/statue near player/nest.

**Tasks:**

1. Ensure hatch response includes dinosaur ID and rarity.
2. Add a client reveal overlay/panel.
3. Add rarity color mapping.
4. Add simple dinosaur visual spawning on server or client-safe cosmetic layer.
5. Add collection update animation.

**Verification:**

- Hatch one egg.
- Player sees clear reveal: name, rarity, color, and collection update.
- No client can fake eggs/dinos because server still owns inventory.

---

## Milestone 4: Add Visible Dinosaur Pets / Nest Display

**Objective:** Make collected dinosaurs visible in the world.

**Files:**
- Create: `src/server/Services/DinoVisualService.lua`
- Modify: `src/server/Main.server.lua`
- Possibly create: `src/shared/DinoVisualConfig.lua`

**Design:**

Starter version can use stylized low-poly Part models, not marketplace assets:

- Common Raptor: green small biped.
- Tri-Horn: blue triceratops-inspired body/horns.
- Bronto: purple long-neck silhouette.
- Shadow Rex: dark bigger predator silhouette.
- Golden Ptero: gold flying/floating pterosaur silhouette.

Two acceptable starter approaches:

1. Nest display: dinos stand around the player's nest.
2. Follow pet: top 1-3 dinos follow the player.

Recommendation for first implementation: nest display first, follow pets second.

**Verification:**

- After hatching, player can see a dinosaur model in the world.
- Models do not cause physics/network spam.
- Models are anchored/cosmetic or server-controlled safely.

---

## Milestone 5: Zone Progression + Retention Hooks

**Objective:** Give players reasons to keep hatching.

**Files:**
- Modify: `src/shared/GameConfig.lua`
- Modify: `src/server/Services/PlayerDataService.lua`
- Modify: `src/client/Main.client.lua`

**Design:**

Zones:

1. Starter Valley: free egg.
2. Jungle Grove: unlock with eggs/nest level.
3. Volcano Ridge: unlock for rare/legendary pool.
4. Ancient Ruins: quests/artifacts.

Retention:

- Daily reward chest.
- Collection index rewards.
- Offline egg earnings already exists; make it visible.
- Short-term goals: next hatch, next upgrade, next zone.

**Verification:**

- Player always has a visible next goal.
- Zone locks are server-authoritative.
- UI explains what is needed to unlock.

---

## Milestone 6: Monetization Later, Not Now

**Objective:** Only add monetization after the game is fun.

**Files:**
- Modify later: `src/shared/Monetization/ProductConfig.lua`
- Modify later: `src/server/Services/ReceiptProcessor.lua`

**Allowed future monetization:**

- Egg packs.
- Cosmetic dino skins.
- VIP nest cosmetics.
- Extra equipped pet slots if balanced carefully.
- Luck boosts only if disclosed and not abusive.

**Not now:**

- Do not configure real product IDs yet.
- Do not push purchase prompts until the core loop is fun.

---

## Manual Playtest Checklist

Before any future publish:

1. Join fresh server.
2. Confirm spawn view looks like a full dinosaur land.
3. Confirm no huge test rectangle dominates the view.
4. Confirm HUD loads within 5 seconds.
5. Hatch one dinosaur.
6. Confirm eggs decrease and dino count increases.
7. Wait 10 seconds and confirm egg income increases eggs.
8. Try upgrade with insufficient eggs and confirm good error message.
9. Buy/equip a trail with insufficient eggs and confirm good error message.
10. Reset character and confirm spawn remains safe.
11. Rejoin and confirm DataStore state loads.
12. Test on small window/mobile-ish resolution.

---

## Commands For Validation Only

Run from `/mnt/d/Openclaw/DINO_DASH`:

```bash
selene src
rojo build default.project.json --output build/dino-dash.rbxlx
python3 - <<'PY'
import pathlib, xml.etree.ElementTree as ET
p = pathlib.Path('build/dino-dash.rbxlx')
ET.parse(p)
print('build ok', p.stat().st_size)
PY
```

Dry-run publish only, no upload:

```bash
cd /mnt/d/Openclaw/ROBLOX_STUDIO_PIPELINE
python3 tools/publish_place.py dino-dash --dry-run
```

Do not run the real publish command until Patrick approves the playtest.
