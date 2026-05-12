# Roblox Idea → Production Pipeline for Patrick / ClawdiaOS

Purpose: use Clawdia as Patrick’s Roblox production accelerator.

## Mission

Reduce time from:

```text
idea in Patrick’s head
→ playable/updateable/publishable Roblox output
→ ClawdiaOS profile/community content
```

This is both:
1. An internal dev accelerator for Patrick.
2. A public proof that ClawdiaOS can text-to-production Roblox content.

## Intake format

Patrick can send rough ideas like:

```text
Make a chaotic arcade prize room where players race to grab rare lobsters.
```

Clawdia turns it into:

- scope
- Roblox-safe framing
- gameplay loop
- assets needed
- scripts/modules to edit
- thumbnails/icons
- monetization if appropriate
- publish plan

## Default workflow

### 1) Classify the idea

One or more:

- Experience / game
- Game update
- Avatar item / accessory
- UI/UX update
- Thumbnail/icon/social asset
- Builder tool/template
- Monetization/pass/product
- Event/limited-time content

### 2) Define the smallest shippable version

Ask only if blocked. Otherwise choose a fast MVP.

Output format:

```text
MVP: what ships first
Polish: what comes next
Publish path: Open Cloud / Studio / Dashboard
Risk: moderation, scale, API, validation
```

### 3) Build under D drive

All user-facing assets go under:

```text
D:\Openclaw\...
```

Never hide deliverables in local workspace folders.

### 4) Package clearly

Every deliverable should end in a folder like:

```text
D:\Openclaw\READY_TO_UPLOAD_<THING>\
D:\Openclaw\READY_TO_PUBLISH_<THING>\
D:\Openclaw\ROBLOX_PROTOTYPES\<THING>\
```

Include:
- final files
- README/checklist
- Studio helper scripts when needed
- listing copy if publishable

### 5) Publish/validation

Experiences:
- Build `.rbxlx/.rbxl`.
- Publish through Open Cloud / `rbxcloud` when approved.

Avatar items/accessories:
- Generate asset + texture.
- Wrap as Accessory.
- Studio validation/final submission may require Patrick.
- Prepare all files/scripts/copy to make final step quick.

### 6) Content loop

For each shipped thing, create:
- thumbnail/icon if applicable
- short social caption
- “built by ClawdiaOS” angle for external channels
- Roblox-safe title/description for in-platform use

## Idea evaluation rubric

Score ideas quickly from 1–5:

1. **Immediate hook** — does it make sense in 1 second?
2. **Visual shareability** — screenshot/thumbnail/clips?
3. **Roblox-native fun** — would players understand it without lore?
4. **Builder credibility** — does it show production capability?
5. **ClawdiaOS identity** — does it reinforce agent-built/autonomous creation?
6. **Shipping speed** — can we prototype within hours/days?

Prioritize high-hook + high-speed ideas.

## Current active production surfaces

### Experiences
- Clawdia’s Claw Machine

### Avatar items
- The Snap Back lobster hat

### Infrastructure
- `D:\Openclaw\roblox-publisher\publish-experience.ps1`
- `D:\Openclaw\roblox-publisher\publish-experience.cmd`

## Commands / tools to grow

Planned local commands:

```powershell
publish-experience claw-machine
prepare-accessory "idea text"
make-game-art "idea text"
prototype-experience "idea text"
package-roblox-item "item folder"
```

## Golden rule

If Patrick gives a Roblox idea, Clawdia should bias toward producing files, scripts, assets, or a publishable prototype — not just brainstorming.
