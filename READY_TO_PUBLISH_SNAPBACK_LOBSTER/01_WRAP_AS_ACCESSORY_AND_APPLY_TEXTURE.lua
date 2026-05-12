-- THE SNAP BACK — final accessory wrapper + texture applier
-- Use in Roblox Studio Command Bar.
--
-- BEFORE RUNNING:
-- 1) Import THE_SNAP_BACK_FINAL_IMPORT.fbx into Workspace.
-- 2) Upload THE_SNAP_BACK_FINAL_TEXTURE.png as an Image/Decal in Asset Manager.
-- 3) Replace PASTE_TEXTURE_ASSET_ID_HERE below with the numeric image asset id.
-- 4) Select the imported Snap Back MeshPart in Explorer.
-- 5) Paste this whole script into View > Command Bar and press Enter.

local Selection = game:GetService("Selection")

local TEXTURE_ASSET_ID = "PASTE_TEXTURE_ASSET_ID_HERE"

if TEXTURE_ASSET_ID == "PASTE_TEXTURE_ASSET_ID_HERE" or TEXTURE_ASSET_ID == "" then
	error("Replace TEXTURE_ASSET_ID with the uploaded Roblox texture/image asset id first.")
end

local selected = Selection:Get()[1]
if not selected then
	error("Select the imported Snap Back MeshPart first.")
end

local handle
if selected:IsA("MeshPart") then
	handle = selected
elseif selected:IsA("Model") or selected:IsA("Folder") then
	handle = selected:FindFirstChildWhichIsA("MeshPart", true)
elseif selected:IsA("Accessory") then
	handle = selected:FindFirstChild("Handle") or selected:FindFirstChildWhichIsA("MeshPart", true)
end
if not handle then
	error("Selection must be a MeshPart, Model, Folder, or Accessory containing the Snap Back MeshPart.")
end

-- Detach old wrappers/attachments/welds so reruns are clean.
for _, child in ipairs(handle:GetChildren()) do
	if child:IsA("Attachment") or child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("SurfaceAppearance") then
		child:Destroy()
	end
end

handle.Name = "Handle"
handle.Anchored = false
handle.CanCollide = false
handle.CanTouch = false
handle.CanQuery = true
handle.Massless = true
handle.Material = Enum.Material.SmoothPlastic
handle.Color = Color3.fromRGB(255, 255, 255) -- white lets baked texture show accurately
handle.Reflectance = 0.06
handle.TextureID = "rbxassetid://" .. TEXTURE_ASSET_ID

local surface = Instance.new("SurfaceAppearance")
surface.Name = "TheSnapBack_BakedLobsterTexture"
surface.ColorMap = "rbxassetid://" .. TEXTURE_ASSET_ID
surface.Parent = handle

local accessory = handle:FindFirstAncestorOfClass("Accessory")
if not accessory then
	accessory = Instance.new("Accessory")
	accessory.Name = "The Snap Back"
	handle.Parent = accessory
	accessory.Parent = workspace
else
	accessory.Name = "The Snap Back"
end

local attachment = Instance.new("Attachment")
attachment.Name = "HatAttachment"
attachment.Parent = handle

-- Locked fit starting point. If Studio preview sits high/low, adjust this only — do NOT resize mesh.
attachment.Position = Vector3.new(0, 0.015, 0.005)
attachment.Orientation = Vector3.new(0, 0, 0)

Selection:Set({accessory})
print("The Snap Back is wrapped as an Accessory and texture applied:", accessory:GetFullName())
print("If fit needs tuning, adjust Handle.HatAttachment.Position only. Do not scale the mesh.")
