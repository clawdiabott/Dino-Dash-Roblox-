-- Apply Snap Back v11 lobster texture to the selected MeshPart.
-- Use this AFTER uploading snap_back_v11_LOCKED_lobster_texture.png to Roblox as an image/decal.
-- Steps:
-- 1) Replace TEXTURE_ASSET_ID below with the numeric Roblox asset id from the uploaded image.
-- 2) Select the visible Snap Back MeshPart in Explorer.
-- 3) Paste this whole script into View > Command Bar and press Enter.

local Selection = game:GetService("Selection")

local TEXTURE_ASSET_ID = "PASTE_IMAGE_ASSET_ID_HERE"

if TEXTURE_ASSET_ID == "PASTE_IMAGE_ASSET_ID_HERE" or TEXTURE_ASSET_ID == "" then
	error("Replace TEXTURE_ASSET_ID with the uploaded Roblox image asset id first.")
end

local selected = Selection:Get()[1]
if not selected then
	error("Select the Snap Back MeshPart first.")
end

local meshPart
if selected:IsA("MeshPart") then
	meshPart = selected
elseif selected:IsA("Model") then
	meshPart = selected:FindFirstChildWhichIsA("MeshPart", true)
elseif selected:IsA("Accessory") then
	meshPart = selected:FindFirstChild("Handle") or selected:FindFirstChildWhichIsA("MeshPart", true)
end

if not meshPart or not meshPart:IsA("MeshPart") then
	error("Selection must be the Snap Back MeshPart, Model, or Accessory containing a MeshPart.")
end

local textureUri = "rbxassetid://" .. TEXTURE_ASSET_ID

-- MeshPart.TextureID is the important one for baked texture color.
meshPart.TextureID = textureUri
meshPart.Material = Enum.Material.SmoothPlastic
meshPart.Color = Color3.fromRGB(255, 255, 255) -- white lets texture show accurately
meshPart.Reflectance = 0.08

-- Optional extra polish: SurfaceAppearance if supported on this asset.
local existing = meshPart:FindFirstChildOfClass("SurfaceAppearance")
if existing then existing:Destroy() end
local surface = Instance.new("SurfaceAppearance")
surface.Name = "SnapBack_Lobster_SurfaceAppearance"
surface.ColorMap = textureUri
surface.RoughnessMap = ""
surface.MetalnessMap = ""
surface.NormalMap = ""
surface.Parent = meshPart

print("Applied Snap Back v11 lobster texture to", meshPart:GetFullName(), textureUri)
