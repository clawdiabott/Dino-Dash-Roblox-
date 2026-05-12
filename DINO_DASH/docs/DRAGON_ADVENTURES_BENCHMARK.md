# Dino Dash benchmark: Dragon Adventures-inspired direction

Source checked: Roblox game page for `Dragon Adventures` (`3475397644`) and public gallery/description on 2026-05-11.

## What Dragon Adventures is selling

Roblox page description highlights:

- Pet dragon taming RPG.
- Explore unique worlds and unlock secrets.
- Discover 200+ dragon species.
- Discover, collect, and hatch eggs.
- Raise dragons from birth.
- Design your own dragon lair.
- Grow massive dragon species.
- Soar/run with dragons.
- Fight enemies.
- Timed events and guild wars.

Gallery takeaways:

- Huge emotional creature fantasy: the mount/companion is the star of the thumbnail, not the avatar.
- Bright fantasy biomes with strong silhouettes: cliffs, waterfalls, crystals, mushrooms, floating islands, portals, ruins.
- Clear egg-to-baby-to-grown-creature progression.
- Collection wall fantasy: many species/variants visible at once.
- Social fantasy: adventure with friends, picnic/lair hangout, event participation.
- Creature rarity/cosmetic identity through color, horns/spikes/wings/markings.

## Dino Dash version — similar genre, original dinosaur identity

We should not clone Dragon Adventures assets, logos, exact UI, names, dragons, events, or economy. The safe product target is:

`Dino Dash = dinosaur hatch, raise, ride, and explore RPG with a nest cave/lair base.`

Core pillars:

1. Hatch
   - Find eggs in biome nests.
   - Bring/claim eggs at your nest cave.
   - Hatch into baby dinos with rarity, species, color, and trait rolls.

2. Raise
   - Baby -> juvenile -> adult growth stages.
   - Feed/care/train loops accelerate growth.
   - Adult dinos generate eggs/resources and can unlock traversal/combat abilities.

3. Bond / Ride / Follow
   - Small dinos follow.
   - Medium dinos can be mounted for ground speed.
   - Flying/gliding prehistoric creatures can unlock air routes later.

4. Explore worlds
   - Starter Valley, Jungle Grove, Volcano Ridge, Ancient Ruins, Crystal Caverns, Sky Fossil Isles.
   - Each biome has unique egg nests, resources, enemies, and locked traversal gates.

5. Build the nest cave
   - Personal lair display pads.
   - Incubators.
   - Food garden.
   - Fossil trophies.
   - Cosmetic nest themes.

6. Collect
   - Dino index/dex.
   - Species, rarity, skin/pattern, mutation, size, and shiny/ancient variants.
   - Collection milestones unlock cosmetics and titles.

7. Events
   - Timed fossil digs.
   - Meteor egg event.
   - Volcano eruption event.
   - Team/guild nest wars later, if we want social competition.

## Gaps in current Dino Dash build

Current build already has:

- Starter nest cave.
- Starter egg.
- Server-authoritative hatching/economy.
- Follow/store mode.
- Zone gates.
- DataStore save/load.
- Basic generated world.

Missing to feel like Dragon Adventures-level fantasy:

- Real creature models/animations instead of block pet placeholder.
- Growth stages.
- Riding/mounting.
- Dino index collection UI.
- Biome-specific egg nests and resources.
- Lair customization/build mode.
- Event cadence.
- Social loop/guild/team goals.
- Strong thumbnail-level visual composition in the actual spawn view.

## Production implementation roadmap

### Phase A — first 10-minute Dragon-like fantasy slice

Goal: make the player feel: "I hatched a dinosaur, raised it, and used it to explore."

Deliverables:

- Replace block pet with modular low-poly dino model templates:
  - Starter Raptor baby/juvenile/adult.
  - Tri-Horn baby/adult.
  - Bronto Buddy baby/adult.
- Add `DinoDefinition` fields:
  - speciesClass
  - growthSeconds
  - mountableAtStage
  - movementBonus
  - favoriteFood
  - modelName
  - biome
- Add growth data:
  - per-owned-dino unique ID, not just species counts.
  - stage: Baby/Juvenile/Adult.
  - ageSeconds.
  - nickname optional later.
- Add feeding station in nest cave.
- Add adult Starter Raptor mount/faster sprint.
- Add DinoDex UI panel with discovered species.
- Add stronger world labels and first biome resource nodes.

### Phase B — lair/nest identity

- Nest display pads show stored dinos.
- Incubator upgrades reduce hatch time.
- Food garden produces berries/meat/fish.
- Cosmetic cave skins.
- Trophy wall for fossils/events.

### Phase C — exploration worlds

- Convert gates to teleport/portal zones or separate streamed biome areas.
- Add biome-specific nests:
  - Jungle Grove: Tri-Horn, Feather Raptor.
  - Volcano Ridge: Lava Rex, Ankylosaur.
  - Ancient Ruins: Bronto Buddy, Fossil Rex.
  - Sky Isles: Ptero glider.
- Add enemies/resource hazards with server-authoritative validation.

### Phase D — live-ops and monetization

Ethical monetization options:

- Cosmetics: nest skins, saddle skins, trail VFX, emotes.
- Convenience: extra incubator slots, not direct pay-to-win power.
- Event pass: cosmetic event rewards if allowed/current policy confirms.
- Developer Products: egg/resource packs only after economy tuning.

All purchase handling remains server-side and idempotent.

## Architecture changes needed

Current species-count inventory is not enough for raising individual dinos. Add modules:

- `src/shared/DinoCatalog.lua`
- `src/shared/ResourceConfig.lua`
- `src/server/Services/DinoService.lua`
- `src/server/Services/GrowthService.lua`
- `src/server/Services/NestBuildService.lua`
- `src/server/Services/BiomeService.lua`
- `src/client/Controllers/DinoHudController.lua`
- `src/client/Controllers/DinoDexController.lua`

Data model shift:

```lua
ownedDinos = {
    [uniqueDinoId] = {
        speciesId = "starter-raptor",
        stage = "Baby",
        ageSeconds = 0,
        bornUnix = 0,
        traits = {
            color = "leaf-green",
            size = 1.0,
            pattern = "stripe",
        },
        mode = "Following",
    },
}
```

Keep a migration from current count-based `dinos` so existing test data is not lost.

## Acceptance criteria before publishing a Dragon-like pivot

- Spawn screenshot shows a fantasy valley/cave, not a block test map.
- Starter egg is visible within 3 seconds of spawning.
- Starter raptor hatches and appears as a recognizable baby dinosaur, not a block.
- Player can feed/raise it at least once.
- Dino growth progress is visible in UI.
- At least one aspirational adult/mount or locked biome is visible.
- No client can spoof hatches, growth, mounts, resources, or purchases.
- Performance holds on mobile: limited active pets, capped particles, simple models, no per-frame server loops per dino.
