# Dino Dash v1 Tycoon Blueprint

> Status: product alignment blueprint. Do not publish from this document alone. Build and playtest locally first.

## Game Identity

Dino Dash is a dinosaur nest tycoon and exploration hatch game.

The player owns a prehistoric nest cave. They collect eggs from the world, hatch dinosaurs, decide whether dinos follow them or stay in the cave, upgrade the cave, then unlock new zones with rarer egg nests.

This should not feel like a small hatch lobby. It should feel like the player's dino home base sits inside a larger ancient world.

## Core Fantasy

- I found a dinosaur egg.
- It hatched into my first companion.
- My cave is now my dinosaur home.
- I can explore paths into new prehistoric zones.
- I can find rarer egg nests.
- My dinosaurs help me earn and progress.
- My nest cave visibly grows as I upgrade it.

## First 5 Minutes

### Minute 0: Spawn

Player spawns inside or directly outside a starter nest cave.

Visible immediately:

- Player's nest cave entrance.
- One glowing starter egg in a nearby straw/stone nest.
- A clear path leading outward into Starter Valley.
- At least one locked gate in the distance: Jungle Zone.
- A huge far landmark: volcano, giant dino skeleton, or ancient ruin silhouette.

HUD should be minimal:

- Egg currency.
- Current objective.
- Small dino/follow/nest button after first hatch.
- No giant panels covering the world.

Initial objective text:

`Collect your first egg!`

### Minute 1: First Egg Collection

Player walks to the starter egg and collects it.

Server-authoritative action:

- Server validates the egg nest ID, player distance, one-time starter state, and cooldown.
- Server grants a pending starter egg.
- Server starts a short hatch timer or immediately triggers a guided hatch sequence.

Client feedback:

- Egg glow pulse.
- Pickup sound.
- Short message: `You found a Starter Egg!`
- Objective changes to `Return to your nest to hatch it!` or `Watch it hatch!`

### Minute 1-2: First Hatch

The starter egg hatches shortly after collection.

Recommended first hatch flow:

1. Egg lands in the player's nest cave incubator.
2. Egg shakes 3 times.
3. Crack effect appears.
4. Starter Raptor pops out.
5. Rarity banner: `Common - Starter Raptor`.
6. Player chooses or is taught:
   - `Follow Me`
   - `Stay in Nest`

Default behavior if no choice is made:

- Starter Raptor follows the player.
- It can later be sent back to the nest cave.

### Minute 2-3: Nest Tycoon Introduction

The first dinosaur begins generating eggs/resources.

The cave should visibly change:

- Starter Raptor bed appears.
- First dino perch/slot fills.
- Incubator activates.
- Upgrade pedestal becomes visible.

Objective:

`Upgrade your nest or explore for another egg nest.`

Player can:

- Collect generated eggs.
- View dino in cave.
- Toggle dino follow/store.
- See the next nest upgrade requirement.

### Minute 3-5: Exploration Begins

Player follows a path from the starter cave into Starter Valley.

Visible features:

- Small nearby egg nests.
- Zone gate to Jungle Zone locked behind nest level / egg cost / collection requirement.
- Signs or arrows pointing to `Starter Valley Egg Nest`.
- Optional low-stakes obstacle/path moment.

By the end of 5 minutes, the player should have:

- Collected first starter egg.
- Hatched first dinosaur.
- Seen the dinosaur follow or store in the nest.
- Understood the nest cave upgrades.
- Found or seen another egg nest.
- Seen at least one locked zone to work toward.

## World Structure

### Zone 1: Starter Valley

Purpose:

- Safe intro area.
- First cave, first egg, basic egg nests.

Theme:

- Grass, dirt paths, bones, small rocks, small waterfalls, friendly vibe.

Unlock:

- Always unlocked.

Egg nests:

- Starter Nest.
- Valley Nest.

Dinos:

- Starter Raptor.
- Tiny Trike.
- Pebble Bronto.

### Zone 2: Jungle Grove

Purpose:

- First major unlock.
- More dense world, hidden nests, stronger dinos.

Theme:

- Jungle trees, vines, ruins, mist, bigger ambient sound.

Unlock idea:

- Nest Level 2 plus egg cost.

Egg nests:

- Jungle Nest.
- Vine Nest.

Dinos:

- Leaf Raptor.
- Jungle Trike.
- Moss Bronto.

### Zone 3: Volcano Ridge

Purpose:

- Mid-game aspiration visible from spawn.

Theme:

- Lava, black rock, smoke, red glow, obsidian nests.

Unlock idea:

- Nest Level 4 plus Jungle collection progress.

Egg nests:

- Ember Nest.
- Lava Nest.

Dinos:

- Ember Rex.
- Magma Ptero.
- Ash Raptor.

### Zone 4: Ancient Ruins

Purpose:

- Rare eggs, prestige/future expansion.

Theme:

- Stone ruins, fossils, crystal eggs, ancient gates.

Unlock idea:

- Collection requirement or future rebirth/prestige.

Egg nests:

- Relic Nest.
- Crystal Nest.

Dinos:

- Crystal Trike.
- Ancient Rex.
- Golden Ptero.

## Nest Cave Tycoon Progression

Nest Level 1:

- Basic cave.
- One incubator.
- 3 dino display/follow slots.
- Starter Raptor bed.

Nest Level 2:

- Larger cave room.
- More dino beds.
- Jungle gate access.
- Better egg generation multiplier.

Nest Level 3:

- Side chamber opens.
- Dino storage display expands.
- Decoration pedestal/trophies.

Nest Level 4:

- Cave becomes a full dino den.
- Volcano gate access.
- Multiple incubators.

Nest Level 5:

- Large decorated prehistoric base.
- Rare dino showcase area.
- Ruins progression hook.

## Dino Follow / Store Design

Each owned dino has a state:

- `Following`
- `StoredInNest`

Server owns the authoritative state.

Client visuals:

- Following dinos trail behind player with spacing and collision disabled.
- Stored dinos appear on cave pads/beds.

Rules:

- Limit active following dinos for mobile/network performance.
- Store overflow dinos in cave display/index.
- Server validates follow/store requests against ownership.
- Client may animate pet movement, but server owns ownership, slot counts, and economy.

Suggested v1 limits:

- 1-3 following dinos depending nest level.
- More stored/displayed dinos as nest upgrades.

## Egg Nest Interaction Model

World egg nests are not free client pickups.

Server validation required:

- Player is close enough to nest.
- Zone is unlocked.
- Nest cooldown is ready.
- Player has required nest level or quest state.
- Player inventory/capacity allows a hatch or pending egg.
- Starter egg can only be claimed once per new profile.

Suggested types:

- Starter egg: one-time guided claim.
- Common nests: short cooldown, low rarity.
- Zone nests: require zone unlock.
- Rare nests: longer cooldown or quest requirement.

## Build Strategy Recommendation

Best approach for this situation:

Use a hybrid workflow.

1. Roblox Studio / Terrain / models for the actual world layout and visual composition.
2. Rojo source control for scripts, services, configs, and reusable object templates.
3. Server-side services for egg nests, zone unlocks, dino ownership, nest upgrades, and persistence.
4. Client-side controllers for hatch reveal, objective prompts, pet visuals, and lightweight UI.

Reason:

- A purely script-generated part map already failed the visual goal.
- A real tycoon world needs authored composition, scale, sightlines, and landmarks.
- Scripts should drive gameplay and state, not be the only tool for art direction.

## Publish Gate

Do not publish the next version until this is true in local Studio/playtest screenshots:

- Spawn shows a cave/nest home base, not an empty rectangle.
- Starter egg is visible and understandable.
- First hatch works within the first 1-2 minutes.
- First dino can follow or sit in the cave.
- At least Starter Valley and a locked Jungle gate are visible.
- HUD is small enough to see the world.
- No monetization prompts are enabled.
- Selene passes.
- Rojo build passes.
- Patrick approves the visual direction.
