# Grass Gobbler Roblox Prototype Debug Research — 2026-05-09

Focus: white screen/whiteout debugging, UI overlays, camera occlusion, custom character/cosmetic pitfalls, StarterGui/StarterPlayerScripts patterns, Lighting/post-processing safe defaults, Rojo build gotchas, Play Solo vs published behavior, and monetization/cosmetic purchase best practices.

## Top actionable findings

1. **Treat a white screen as either UI, camera, or Lighting — isolate in that order.**
   - Disable `StarterGui`/`PlayerGui` ScreenGuis first. DevForum reports full-white screens caused by StarterGui UI where disabling the UI removes the whiteout.
   - Then inspect `CurrentCamera`: camera `CFrame`, `CameraSubject`, `CameraType`, FOV, and whether the camera is inside/behind an opaque part, custom character mesh, or accessory.
   - Then disable/normalize post-processing under `Lighting` and `CurrentCamera` (`BloomEffect`, `BlurEffect`, `ColorCorrectionEffect`, `DepthOfFieldEffect`, `SunRaysEffect`, `ColorGradingEffect`). Roblox docs confirm effects in `Lighting` affect all players, while effects under `Camera` affect only one player.

2. **Debug UI overlays by looking for full-screen frames and bad ZIndex/DisplayOrder.**
   - Common culprit: a `ScreenGui` with a full-screen `Frame`/`ImageLabel` at `BackgroundTransparency = 0`, white `BackgroundColor3`, high `ZIndex`, or high `DisplayOrder`.
   - Check if `IgnoreGuiInset`/`ClipToDeviceSafeArea` plus `Size = UDim2.fromScale(1, 1)` makes an overlay cover the entire viewport.
   - In Studio: turn off ScreenGuis one by one in `PlayerGui`, not only `StarterGui`, because `StarterGui` is cloned into `PlayerGui` at runtime.

3. **Use the right container pattern.**
   - `StarterGui` is for `ScreenGui`/LayerCollector objects cloned into each player’s `PlayerGui`; contents reset on respawn unless each `ScreenGui.ResetOnSpawn = false`.
   - `StarterPlayerScripts` is for player-level LocalScripts copied once into `PlayerScripts` on join. Roblox docs note that LocalScripts named `CameraScript` or `ControlScript` here replace the default Roblox camera/control scripts; empty ones disable defaults. Avoid accidental names.
   - Put UI construction/controllers either as LocalScripts under the specific ScreenGui for small UI or as a client system under `StarterPlayerScripts` requiring modules from `ReplicatedStorage` for larger projects. Avoid random LocalScripts scattered through UI without a clear ownership model.

4. **Camera occlusion settings matter for small/prototype maps.**
   - `DevCameraOcclusionMode.Zoom`: camera zooms inward until no object is between camera and subject.
   - `DevCameraOcclusionMode.Invisicam`: objects between camera and subject become translucent locally.
   - For tight arenas/grass/foliage and custom gobbler bodies, `Invisicam` is often safer while debugging because occluders become transparent instead of forcing weird zoom. Also check `StarterPlayer.CameraMaxZoomDistance`, `CameraMinZoomDistance`, and spawned character scale.

5. **Custom characters/cosmetics can whiteout or block view.**
   - Avatar characters require standard components: body MeshParts, textures, rigging/bones, cages, and attachments. Bad scale/origin/attachment placement can put a huge mesh or accessory between camera and subject.
   - Rigid accessories should be a single `MeshPart` in a model, with textures via `SurfaceAppearance`/`TextureID`, and proper attachments. Roblox docs note geometry with `_Att` suffix converts to Attachments on import.
   - Debug step: spawn with default Roblox character first. If whiteout disappears, reintroduce custom character, then cosmetics, one at a time. Set suspect accessories temporarily transparent or move them far away.

6. **Lighting/post-processing safe defaults for prototypes.**
   - Start with no post-processing, `Lighting.Brightness` around normal defaults, neutral `Ambient`/`OutdoorAmbient`, no extreme `ColorCorrectionEffect.Brightness`, no white `TintColor` wash, and modest/disabled `BloomEffect`.
   - Add effects back one at a time. Keep global effects in `Lighting`; player-specific menu blur/tint belongs under that player’s `CurrentCamera` and must be cleaned up when the menu closes.
   - If a UI menu uses blur, do not combine a full-white overlay + blur + high bloom until base gameplay view is verified.

7. **Rojo gotchas to check before building/opening a place.**
   - Project files are `.project.json`; paths are relative to the project file.
   - Root tree should be a `DataModel` for full places, with services explicitly mapped (`ReplicatedStorage`, `ServerScriptService`, `StarterGui`, `StarterPlayer/StarterPlayerScripts`, `Workspace`, `Lighting`).
   - `$ignoreUnknownInstances` defaults differ: false when `$path` is specified, true otherwise. Be careful connecting Rojo to an existing Studio place; unknown instances may be deleted depending on mapping.
   - Avoid duplicate `$className` definitions for root services. Services usually infer class by service name; subcontainers like `StarterPlayerScripts` often need explicit `$className`.
   - Rojo docs: `emitLegacyScripts` defaults true; if changed, script class/run context behavior can differ from older expectations.

8. **Play Solo vs published behavior to remember.**
   - Some monetization products/passes require the experience to be published and accessible before setup/use.
   - API-backed systems can behave differently in Studio unless Studio/API access/settings are enabled and the place is published to the correct experience.
   - Always test once in a real published private/beta server after Studio Play Solo, especially for MarketplaceService, DataStores, assets, permissions, and mobile UI safe areas.

9. **Monetization/cosmetic purchase best practices.**
   - Use **passes** for permanent one-time cosmetics/privileges.
   - Use **developer products** for repeatable consumables/currency/potions/boosts.
   - For developer products, Roblox docs are explicit: use `MarketplaceService.ProcessReceipt`; do **not** grant based only on `PromptProductPurchaseFinished`, because that event does not guarantee purchase success.
   - For passes, prompt from client UI, but grant/validate privileges server-side. Store player-specific purchase/entitlement state if your game needs history beyond Roblox ownership checks.
   - Keep monetization player-friendly. Roblox docs warn disliked monetization can drive downvotes; social, visible cosmetics and fair immediate value usually fit Roblox better than timers or paywalls.

## Quick whiteout triage checklist

1. In Play mode, open Explorer → `Players > LocalPlayer > PlayerGui`; disable ScreenGuis one at a time.
2. Search UI for full-screen white objects: `Frame`, `ImageLabel`, `CanvasGroup`, high `DisplayOrder`, high `ZIndex`, `BackgroundTransparency = 0`.
3. Disable post-processing under `Lighting` and `Workspace.CurrentCamera`.
4. Reset camera defaults: default character, default camera scripts, no custom `CameraScript`/`ControlScript`, normal zoom distances.
5. Switch `StarterPlayer.DevCameraOcclusionMode` to `Invisicam` for tight maps.
6. Spawn without custom gobbler/cosmetics; then add them back incrementally.
7. Build with Rojo and inspect the resulting data model: ensure `StarterGui`, `StarterPlayerScripts`, `Lighting`, and `Workspace` landed where expected.
8. Publish a private test version and retest if Marketplace/DataStore/assets are involved.

## Sources checked

- Roblox Creator Docs — StarterGui: cloned into PlayerGui; ResetOnSpawn behavior; CoreGui interactions. https://create.roblox.com/docs/reference/engine/classes/StarterGui
- Roblox Creator Docs — StarterPlayerScripts: copied once to PlayerScripts; `CameraScript`/`ControlScript` replacement behavior. https://create.roblox.com/docs/reference/engine/classes/StarterPlayerScripts
- Roblox Creator Docs — Post-processing effects: Lighting effects affect all players; Camera effects affect one player; effect types. https://create.roblox.com/docs/environment/post-processing-effects
- Roblox Creator Docs — DevCameraOcclusionMode: Zoom vs Invisicam behavior. https://create.roblox.com/docs/reference/engine/enums/DevCameraOcclusionMode
- Roblox Creator Docs — Monetization, passes, developer products, ProcessReceipt guidance. https://create.roblox.com/docs/en-us/production/monetization
- Roblox Creator Docs — Avatar characters and rigid accessories. https://create.roblox.com/docs/art/characters and https://create.roblox.com/docs/art/accessories
- Roblox Creator Docs — publishing experiences/places. https://create.roblox.com/docs/production/publishing/publish-experiences-and-places
- Rojo docs — project format and new game/live-sync/build flow. https://rojo.space/docs/v7/project-format/ and https://rojo.space/docs/v7/getting-started/new-game/
- Roblox DevForum — UI white screen report tied to StarterGui UI. https://devforum.roblox.com/t/ui-white-screen/374393
