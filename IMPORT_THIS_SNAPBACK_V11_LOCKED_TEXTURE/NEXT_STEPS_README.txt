SNAP BACK V11 — NEXT STEPS

Do not resize or switch mesh versions. Scale is fixed now.

FILES:
1) Mesh to import:
   D:\Openclaw\IMPORT_THIS_SNAPBACK_V11_LOCKED_TEXTURE\IMPORT_THIS_snap_back_v11_LOCKED_TEXTURE.fbx

2) Texture to upload:
   D:\Openclaw\IMPORT_THIS_SNAPBACK_V11_LOCKED_TEXTURE\snap_back_v11_LOCKED_lobster_texture.png

3) Helper script:
   D:\Openclaw\IMPORT_THIS_SNAPBACK_V11_LOCKED_TEXTURE\apply_snapback_v11_texture.lua

ROBLOX STUDIO FLOW:

A) Keep/import the visible v11 mesh.
   If v10 is already visible and v11 imports visible too, use v11.
   If v11 has any issue, use the visible v10 mesh but still apply this texture workflow.

B) Upload the texture PNG:
   - Open Asset Manager.
   - Click Images.
   - Bulk Import or Add Image.
   - Select snap_back_v11_LOCKED_lobster_texture.png.
   - After upload, right-click the image / copy asset id, or open it and copy the numeric id from the URL/details.

C) Apply the texture:
   - Open apply_snapback_v11_texture.lua in Notepad/VS Code.
   - Replace PASTE_IMAGE_ASSET_ID_HERE with the numeric image asset id.
   - Select the Snap Back MeshPart in Explorer.
   - View > Command Bar.
   - Paste the whole script and press Enter.

D) Expected result:
   - Mesh stays the same visible size.
   - Texture color appears: lobster reds, dark tips, shell detail.
   - MeshPart Color should be white, because white allows the texture to show correctly.

IMPORTANT:
- Do not use new size variants anymore.
- Do not tint the mesh red after applying the texture. That will wash out the lobster texture.
- If the texture appears backwards/warped, the next fix is UV layout, not scale.
