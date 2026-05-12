SNAP BACK V12 COLOR FIXED — USE THIS VERSION

This fixes the gray texture issue from v11.

Use this mesh first:
D:\Openclaw\IMPORT_THIS_SNAPBACK_V12_COLOR_FIXED\IMPORT_THIS_snap_back_v12_COLOR_FIXED_LOCKED_SIZE.fbx

Texture:
D:\Openclaw\IMPORT_THIS_SNAPBACK_V12_COLOR_FIXED\snap_back_v12_REAL_LOBSTER_COLORS_TEXTURE.png

Fallback GLB:
D:\Openclaw\IMPORT_THIS_SNAPBACK_V12_COLOR_FIXED\fallback_snap_back_v12_COLOR_FIXED_LOCKED_SIZE.glb

What changed:
- Same locked visible size as v10/v11.
- Color bake was fixed. The PNG now contains actual red/orange/black lobster color data.
- Verified with image stats: color extrema include strong red/orange values, not gray-only.

Roblox Studio simple flow:
1) Import the FBX.
2) If it still appears gray, select the MeshPart.
3) In Properties, set TextureID/Texture to the uploaded PNG image asset.
4) Keep MeshPart Color = white.
5) Do NOT resize this mesh. Scale is locked.
