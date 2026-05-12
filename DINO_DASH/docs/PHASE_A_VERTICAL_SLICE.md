# Dino Dash Phase A vertical slice

Goal: move Dino Dash toward a Dragon Adventures-style creature RPG feel without copying Dragon Adventures assets, UI, names, or economy.

## Implemented in this pass

### Individual dinosaur ownership foundation

The old count-based `dinos` table still exists for compatibility and leader/game summary use, but new hatches now create individual owned dino records:

- unique dino UID
- species ID
- age seconds
- born timestamp
- mode: following or stored
- active dino UID
- mounted dino UID

Existing count-only profiles migrate into individual records on load.

### Growth stages

Each species now has catalog fields:

- modelName
- growthSeconds
- mountable
- movementBonus
- favoriteFood

Growth stage is computed as:

- Baby: under 45% grown
- Juvenile: 45% to under 100%
- Adult: 100% grown

Dinos grow passively while the player is in server. Feeding accelerates growth.

### Feed and raise loop

Players now have `berryFood` snacks.

- New HUD button: `Feed Dino`
- Server action: `feedActiveDino`
- Feeding consumes one snack and adds growth progress to the active dino.
- Objective text now points players to feeding after the starter hatch.
- World contains a visible `DinoFeedStation` in the nest cave.
- `DinoFeedStation` now has `FeedDinoPrompt` for in-world feeding.
- Feeding is now distance-gated by the server so exploiters cannot feed from anywhere by firing the remote.
- Successful feeding sends a short client-side `feedPulse` effect payload.

### Mount loop foundation

- New HUD button: `Mount` / `Dismount`
- Server action: `toggleMount`
- Only Adult mountable dinos can be mounted.
- Server applies authoritative humanoid WalkSpeed boost.
- Dismount resets WalkSpeed to default.

This is intentionally the first mount foundation: visual seated riding/animation can be layered next.

### Better pet presentation

The client pet is no longer a single block. It now creates a small multi-part low-poly dino-like model with:

- body
- head
- tail
- legs
- back spike
- stage-scaled size
- nameplate showing dino name and growth stage

This is still a generated placeholder, but it reads much more like a dinosaur than the previous block pet and gives us a model template API to replace with authored meshes/models later.

### DinoDex HUD line and panel

HUD now shows active dino progression:

- dino name
- growth stage
- growth percentage
- snack count

A `DinoDex` button opens a compact collection panel with:

- owned species counts
- locked species silhouettes/placeholders by name
- best discovered growth stage per species
- snack inventory
- berry regrow timers for key nodes

### Berry bush resource nodes

Snacks are now earned through exploration instead of only being starter inventory.

- New catalog: `GameConfig.BERRY_NODES`
- New saved cooldown table: `berryCooldowns`
- New server action: `collectBerryNode`
- New HUD button: `Berries`, which gathers from the nearest bush if the player is close enough
- New world ProximityPrompt: `CollectBerryPrompt`
- Server validates node ID, zone unlock, cooldown, and physical distance before granting snacks.

Starter Valley nodes:

- `cave-berry`
- `path-berry-a`
- `path-berry-b`
- `valley-berry`

Jungle Grove future node:

- `jungle-berry`

### Mount visual polish

Mounting is still server-authoritative for speed, but the client now snaps the active Adult dino visual under the character with a generated saddle while mounted. This gives immediate ride feedback without trusting the client for movement authority.

## Validation completed

Commands:

```bash
cd /mnt/d/Openclaw/DINO_DASH
selene src
rojo build default.project.json -o build/dino-dash.rbxlx
```

Both pass after implementation.

## Next Phase A steps

1. Replace generated dino placeholder with Studio-authored low-poly Starter Raptor baby/juvenile/adult models.
2. Add feeding interaction through a ProximityPrompt on `DinoFeedStation` in addition to the HUD button.
3. Add hatch reveal animation and rarity VFX.
4. Add a proper scalable DinoDex card UI with viewport models once authored models exist.
5. Add production session-locking/profile wrapper before large-scale live launch.

## Publish gate

Do not publish live until a local/Studio playtest screenshot confirms:

- starter egg is visible from spawn
- feed station is visible in cave
- hatched dino visibly follows player
- HUD shows DinoDex/growth state without blocking play
- mount button correctly refuses Baby/Juvenile and works for Adult after feeding/growth
