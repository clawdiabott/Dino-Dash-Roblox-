# ClawdiaOS Roblox: Oversized Lobster Claw Machine

## Core concept
A giant arcade claw machine where players are tiny operators inside/around the cabinet. The prize pit is full of smart, chaotic lobsters with rarity, behavior, mutations, and physics-driven escapes.

## North star
Make it feel like a living ClawdiaOS arcade: autonomous agents, Base data storms, lobster hunts, community events, and an off-platform token-aware dashboard — while keeping the Roblox experience compliant and fun without requiring crypto.

## Next-level gameplay pillars

### 1. Giant-machine spectacle
- Players spawn inside a neon transparent claw machine the size of a building.
- The prize pit is an aquarium/arena: water currents, glass reflections, LED rails, coin slots, conveyor belts.
- Crane movement should feel physical, weighty, and skill-based.
- Lobsters react: cling to objects, hide, sprint, stack, sabotage, or bait the claw.

### 2. Lobsters with personality
- Rarity tiers: Common, Chrome, Glitch, Agent, Abyssal, Golden CLAW.
- Each lobster has procedural traits: speed, grip, panic, shine, intelligence, escape style.
- Some lobsters are mini-bosses: King Pincher, The Treasurer, The Rug Lobster, Smart Money Lobster.
- Captured lobsters go to a personal tank/collection room.

### 3. Agent-powered world
- NPC agent terminals give missions: scan the tank, identify rare movement patterns, trigger machine upgrades.
- Players can unlock helper drones/crawlers that mark lobster behavior but do not auto-win.
- Clawdia appears as the cabinet OS: mission voice, event announcer, terminal UI.

### 4. Live-event energy
- Timed global events: Token Tide, Liquidity Surge, Smart Wallet Drop, Base Storm.
- Events change the aquarium: currents, lighting, lobster spawns, multipliers, boss arrivals.
- Safest implementation: Roblox server calls a ClawdiaOS backend endpoint for sanitized event flags. Do not put API keys or raw blockchain logic in client scripts.

### 5. Social hooks
- Co-op mega-claw rounds: multiple players operate different axes/buttons.
- Crew tanks: groups pool catches into a community aquarium.
- Trading should be approached carefully; avoid exploit-prone direct value transfer unless designed/server-validated well.
- Screenshot/photo booth: players pose inside the claw with captured lobsters.

## Token tie-in, safely
Roblox is sensitive around off-platform economy, crypto/NFTs, and directing users off-platform. The safest direction:

- The Roblox game is playable and complete without crypto.
- Do not ask users to connect wallets inside Roblox.
- Do not advertise token buying, token price, external purchases, or financial rewards inside Roblox.
- Use ClawdiaOS/token connection as lore + off-platform companion layer.

Better token integrations:
1. Off-platform dashboard on ClawdiaOS
   - Shows game events, leaderboards, and community milestones.
   - Can read CLAW holdings outside Roblox.
   - Can display holder-only analytics or community stats.

2. Token-influenced global events
   - Backend checks public Base activity and returns abstract game events like `TokenTide=true`.
   - In Roblox this is just a themed event, not a financial promise.

3. Community perks outside Roblox
   - Holder-only Discord roles, site badges, alpha access, lore votes, event naming.
   - Keep Roblox reward claims generic and compliant.

4. Roblox-native monetization
   - Use Game Passes/Developer Products for in-game purchases.
   - Robux stays the in-game economy.

## Technical architecture

### Recommended Roblox stack
- Rojo: sync source files between Git and Roblox Studio.
- Aftman: pin tool versions.
- Wally: package manager for Roblox Lua libraries.
- Selene/StyLua: lint/format Luau.
- GitHub Actions optional: lint and release artifact checks.

### Suggested project layout
```text
D:\Openclaw\clawdia-clawmachine\
  default.project.json
  aftman.toml
  wally.toml
  src\
    ReplicatedStorage\
      Shared\
      Remotes\
    ServerScriptService\
      Services\
        ClawService.lua
        LobsterService.lua
        RewardService.lua
        EventService.lua
        DataService.lua
    StarterPlayer\
      StarterPlayerScripts\
        Client\
    StarterGui\
      UI\
  assets\
  docs\
```

### Security rules
- Server owns claw results, catches, rewards, inventory, cooldowns, and purchases.
- Client only sends input intent, never final outcomes.
- Every RemoteEvent must validate player, distance, cooldown, state, and sane values.
- DataStore writes use UpdateAsync, pcall, retries, and batching.
- Backend endpoints return simple public game-state JSON; never expose private keys.

## Access needed from Patrick
- GitHub repo URL or local path for `clawdia clawmachine`.
- Roblox Studio installed + Team Create access.
- Roblox Universe ID and Place ID.
- Roblox Open Cloud API key if we want automation for game passes/dev products/publishing.
- Confirmation whether this is personal account or Roblox group-owned experience.
- Any existing assets: lobster models, cabinet model, logos, sounds, UI references.
- Whether ClawdiaOS backend should provide live Base event flags.

## Skills/tooling status
- Installed `roblox` skill: Roblox server/client security, DataStore, replication, memory leak guidance.
- Found `roblox-cli` skill for Open Cloud game passes/products, but it is flagged suspicious by ClawHub, so I did not force-install it. Review first if we need it.
- Git exists on this machine.
- Rojo, Aftman, Wally, rbxcloud/roblox-cli are not currently installed.

## Immediate next steps
1. Get repo URL/path and clone/copy it into `D:\Openclaw`.
2. Inspect project structure and decide whether to convert to Rojo layout.
3. Draft MVP loop: operate claw -> catch lobster -> resolve server-side -> save collection -> show tank.
4. Build vertical slice: one machine, 5 lobster types, one global event, one collection UI.
5. Add ClawdiaOS backend hook for abstract live events.
