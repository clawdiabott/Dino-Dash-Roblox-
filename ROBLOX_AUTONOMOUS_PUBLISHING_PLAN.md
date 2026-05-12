# Roblox Autonomous Publishing Plan — ClawdiaOS

Goal: move toward a “text → generated Roblox asset/experience → validated package → publish” workflow for ClawdiaOS games and avatar items.

## Key finding

There are two different automation levels:

### 1) Experiences / places — highly automatable
Roblox Open Cloud supports place publishing programmatically.

Current local tool already supports it:

```powershell
D:\Openclaw\tools\bin\rbxcloud.exe experience publish `
  --filename <rbxl/rbxlx> `
  --place-id <PLACE_ID> `
  --universe-id <UNIVERSE_ID> `
  --version-type published `
  --api-key <API_KEY>
```

Known Clawdia’s Claw Machine IDs:
- Place ID: `103982561389598`
- Universe ID: `10135510431`
- API key path: `D:\Openclaw\roblox credentials\roblox api.txt` — never print this key.

Best target workflow:

```text
Prompt
→ modify/generate source files
→ build .rbxlx/.rbxl
→ run lint/static checks
→ publish via Open Cloud
→ optionally restart servers
→ report version number
```

This can become a true “text to publish” flow.

## 2) Avatar accessories / UGC items — semi-automatable today

Roblox docs currently require 3D accessories/clothing to be uploaded through Studio for validation/moderation:

```text
Accessory object in Workspace
→ right-click object
→ Save to Roblox
→ Submit As: Avatar Asset
→ select Asset type: Hat / appropriate type
→ Studio validation
→ metadata
→ submit for moderation
```

Important limitation:
- Open Cloud Assets API can upload assets/models/images, but Marketplace avatar item validation/publish still relies on Studio/Creator Dashboard flow.
- So we can automate asset generation, packaging, texture uploads, accessory wrapping, naming, thumbnails, checklist, and local Studio scripts.
- The final marketplace submit step likely still needs Studio/Dashboard confirmation.

## Proposed architecture

Create a local `D:\Openclaw\roblox-publisher\` tool with commands:

### Experiences

```powershell
roblox-publisher publish-experience claw-machine
```

Does:
1. Reads project config.
2. Builds `.rbxlx`.
3. Publishes through rbxcloud/Open Cloud.
4. Optionally restarts live servers.
5. Writes publish log to `D:\Openclaw\publish-logs\`.

### Avatar accessories

```powershell
roblox-publisher prepare-accessory snapback-lobster
```

Does:
1. Runs Blender CLI generation/export.
2. Produces final FBX/GLB/texture under a clean folder.
3. Generates Roblox Studio Command Bar script:
   - wraps MeshPart as Accessory
   - sets `AccessoryType = Hat`
   - adds `Handle`
   - adds `HatAttachment`
   - applies texture/SurfaceAppearance
   - freezes collision/mass settings
4. Generates listing copy and checklist.
5. Optionally uses Open Cloud Assets API to upload supporting images/decals/models as Creator assets.
6. Stops before final Marketplace submit unless Patrick explicitly approves.

## Best possible “text to publish” user experience

### Experience example

Patrick says:

```text
Add a new lobster prize type, update UI, publish to Roblox.
```

Agent does:
1. Edits source.
2. Builds game.
3. Publishes via Open Cloud.
4. Restarts servers if requested.
5. Reports live version number.

### Accessory example

Patrick says:

```text
Make a premium blue crab hat and prep it for publishing.
```

Agent does:
1. Generates model in Blender CLI.
2. Exports locked-scale FBX and texture.
3. Creates `D:\Openclaw\READY_TO_PUBLISH_<ITEM>\`.
4. Creates Studio wrapping/fitting script.
5. Creates listing copy and thumbnails.
6. If approved, guides/fills final Studio validation flow.

## Open Cloud Assets API uses

Local `rbxcloud.exe assets create` supports:
- `decal-png`, `decal-jpeg`, `decal-bmp`, `decal-tga`
- `model-fbx`
- audio formats

Command pattern:

```powershell
D:\Openclaw\tools\bin\rbxcloud.exe assets create `
  --asset-type decal-png `
  --display-name "The Snap Back Texture" `
  --description "Texture for The Snap Back" `
  --creator-id 828600704 `
  --creator-type group `
  --filepath "D:\Openclaw\READY_TO_PUBLISH_SNAPBACK_LOBSTER\THE_SNAP_BACK_FINAL_TEXTURE.png" `
  --api-key <API_KEY>
```

This can reduce manual texture/image upload work.

Caution: API key needs appropriate permissions for group assets / creator store operations.

## Recommended build phases

### Phase 1 — Experience autopublish wrapper
Build a reliable PowerShell/Python wrapper around existing project IDs and rbxcloud.

Deliverable:
`D:\Openclaw\roblox-publisher\publish-experience.ps1`

### Phase 2 — Accessory prep automation
Standardize folders and generated scripts.

Deliverable:
`D:\Openclaw\roblox-publisher\prepare-accessory.ps1`

### Phase 3 — Studio plugin / bootstrap place
Create a Roblox Studio plugin or `.rbxlx` helper that:
- imports prepared assets
- applies texture
- wraps accessory
- opens Accessory Fitting Tool / validation checklist

This is likely the best way to make avatar items feel close to “one-click publish.”

### Phase 4 — Creator Dashboard assisted mode
Use browser automation only for repetitive dashboard forms when Patrick is present/logged in.

Avoid fully unattended marketplace submission unless explicitly approved because:
- upload fees/moderation may apply
- item cannot be edited after upload in some flows
- public marketplace actions are external/persistent

## Important safety/product rules

- For ClawdiaOS Roblox items: keep listing copy Roblox-native only.
- Do not mention crypto, tokens, real-world value, cash-out, investments, or trading.
- Marketplace submit/publish should require explicit Patrick approval.
- Save all generated artifacts under `D:\Openclaw\...`, never hidden workspace/local folders.

## Immediate next implementation recommendation

Start with the experience autopublish wrapper because it can be fully automated today.

Then build the accessory prep pipeline around Snap Back as the template:

```text
D:\Openclaw\READY_TO_PUBLISH_SNAPBACK_LOBSTER\
  THE_SNAP_BACK_FINAL_IMPORT.fbx
  THE_SNAP_BACK_FINAL_TEXTURE.png
  01_WRAP_AS_ACCESSORY_AND_APPLY_TEXTURE.lua
  02_PUBLISHING_CHECKLIST.txt
  03_LISTING_COPY.txt
  06_FINALIZE_FOR_PUBLISH.lua
```

Turn that into a reusable template generator for future hats/accessories.
