# Roblox Whiteout / White Screen Debug Checklist

Use this before changing gameplay scripts when a Roblox playtest turns white after a few seconds.

## 1. Full-screen UI overlay
Check all `ScreenGui`, `Frame`, `ImageLabel`, `TextLabel`, and `TextButton` objects.

Look for:
- `Size = UDim2.fromScale(1, 1)` or full-screen offsets
- `BackgroundColor3 = Color3.new(1, 1, 1)` / `Color3.fromRGB(255,255,255)`
- `BackgroundTransparency = 0`
- high `ZIndex`
- delayed enable logic: `wait(5)`, `task.delay`, loading/fade scripts

## 2. Lighting / post-processing
Check `Lighting` and scripts that modify it.

Look for:
- `ColorCorrectionEffect`
- `BloomEffect`
- `DepthOfFieldEffect`
- `SunRaysEffect`
- `Atmosphere`
- extreme `Brightness`, `ExposureCompensation`, white `TintColor`

Safe baseline:
- `Brightness`: 1-2
- neutral gray ambient
- no post-processing until the base game is stable

## 3. Camera / viewport
Check LocalScripts for:
- `workspace.CurrentCamera`
- `CameraType = Scriptable`
- `Camera.CFrame`
- `RenderStepped` camera loops
- `ViewportFrame`
- large custom avatar/body geometry that can sit between camera and map

## 4. Runtime render/property loops
Search scripts for:
- `RenderStepped`
- `Heartbeat`
- `while true do`
- repeated UI/background/camera/lighting assignments

## 5. Studio renderer issue
If code audit is clean and only Studio is affected:
- Studio Settings → Rendering → Graphics Mode
- Try Direct3D11 or Vulkan
- Restart Studio after changing

## Grass Gobbler current audit — 2026-05-09
Checked current files:
- No full-screen white UI overlay found.
- HUD uses small labels/buttons; no `Frame` or `ImageLabel` fullscreen cover.
- Only delayed UI is toast fade/restart button; neither is fullscreen.
- No post-processing effects found.
- Lighting only set in `default.project.json` with mild brightness/ambient.
- Camera is restored to `Enum.CameraType.Custom`; no forced `Scriptable`/`RenderStepped` camera remains.
- No code found repeatedly setting a white full-screen UI/background.

Remaining likely cause from our build history:
- The previous oversized white welded cow shell could occlude the camera and make the world appear white. It has been replaced with lightweight `CowLite` horns/ears.
