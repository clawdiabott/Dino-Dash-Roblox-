-- THE SNAP BACK — final publish cleanup
-- Run this after the hat looks good on the avatar.
-- Select "The Snap Back" accessory in Explorer, paste into Command Bar, run.

local Selection = game:GetService("Selection")

local selected = Selection:Get()[1]
if not selected then error("Select The Snap Back accessory first.") end

local accessory
if selected:IsA("Accessory") then
	accessory = selected
elseif selected:IsA("MeshPart") then
	accessory = selected:FindFirstAncestorOfClass("Accessory")
elseif selected:IsA("Model") then
	accessory = selected:FindFirstChildOfClass("Accessory") or selected:FindFirstAncestorOfClass("Accessory")
end

if not accessory then error("Could not find Accessory. Select The Snap Back accessory or its Handle.") end
accessory.Name = "The Snap Back"

pcall(function()
	accessory.AccessoryType = Enum.AccessoryType.Hat
end)

local handle = accessory:FindFirstChild("Handle") or accessory:FindFirstChildWhichIsA("MeshPart", true)
if not handle then error("Accessory needs a MeshPart named Handle.") end
handle.Name = "Handle"
handle.Anchored = false
handle.CanCollide = false
handle.CanTouch = false
handle.CanQuery = true
handle.Massless = true
handle.Material = Enum.Material.SmoothPlastic
handle.Color = Color3.fromRGB(255,255,255)
handle.Reflectance = 0.06

local hatAttachment = handle:FindFirstChild("HatAttachment")
if not hatAttachment then
	hatAttachment = Instance.new("Attachment")
	hatAttachment.Name = "HatAttachment"
	hatAttachment.Parent = handle
end

print("Finalized The Snap Back for publish.")
print("AccessoryType:", tostring(accessory.AccessoryType))
print("Structure should be: The Snap Back > Handle > HatAttachment")
Selection:Set({accessory})
