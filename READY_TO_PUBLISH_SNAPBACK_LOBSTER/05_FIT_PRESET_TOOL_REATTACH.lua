-- THE SNAP BACK — fit preset tool v2
-- This version forces Roblox to rebuild the accessory weld after changing HatAttachment.
-- Use this if the first preset script changed values but the hat did not visibly move.
--
-- Steps:
-- 1) Select "The Snap Back" Accessory OR its Handle in Explorer.
-- 2) Change PRESET below.
-- 3) Paste/run in View > Command Bar.
--
-- Valid presets:
-- reset, lower, higher, front, back, low_front, low_back, front_more, back_more

local Selection = game:GetService("Selection")

local PRESET = "low_front" -- change this preset and rerun

local presets = {
	reset = Vector3.new(0, 0.015, 0.005),
	lower = Vector3.new(0, 0.070, 0.005),
	higher = Vector3.new(0, -0.010, 0.005),
	front = Vector3.new(0, 0.035, -0.055),
	back = Vector3.new(0, 0.035, 0.055),
	low_front = Vector3.new(0, 0.070, -0.055),
	low_back = Vector3.new(0, 0.070, 0.055),
	front_more = Vector3.new(0, 0.080, -0.095),
	back_more = Vector3.new(0, 0.080, 0.095),
}

local selected = Selection:Get()[1]
if not selected then error("Select The Snap Back accessory or Handle first.") end

local accessory
local handle

if selected:IsA("Accessory") then
	accessory = selected
	handle = selected:FindFirstChild("Handle")
elseif selected:IsA("MeshPart") then
	handle = selected
	accessory = selected:FindFirstAncestorOfClass("Accessory")
elseif selected:IsA("Model") then
	accessory = selected:FindFirstChildOfClass("Accessory") or selected:FindFirstAncestorOfClass("Accessory")
	handle = selected:FindFirstChild("Handle", true) or selected:FindFirstChildWhichIsA("MeshPart", true)
end

if not handle then error("Could not find Handle. Select the accessory or mesh handle.") end
if not accessory then
	accessory = handle:FindFirstAncestorOfClass("Accessory")
end
if not accessory then error("Could not find Accessory ancestor. Wrap the mesh as an Accessory first.") end

local value = presets[PRESET]
if not value then error("Unknown preset: " .. tostring(PRESET)) end

local att = handle:FindFirstChild("HatAttachment")
if not att then
	att = Instance.new("Attachment")
	att.Name = "HatAttachment"
	att.Parent = handle
end
att.Position = value
att.Orientation = Vector3.new(0, 0, 0)

-- Remove old weld so Roblox recalculates from the attachment position.
for _, child in ipairs(handle:GetChildren()) do
	if child:IsA("Weld") or child:IsA("WeldConstraint") then
		child:Destroy()
	end
end

-- Find a humanoid rig/avatar in Workspace.
local rig = accessory:FindFirstAncestorOfClass("Model")
if not (rig and rig:FindFirstChildOfClass("Humanoid")) then
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("Head") then
			rig = obj
			break
		end
	end
end
if not rig then error("No rig/avatar with Humanoid and Head found in Workspace.") end

local humanoid = rig:FindFirstChildOfClass("Humanoid")
accessory.Parent = workspace
humanoid:AddAccessory(accessory)
Selection:Set({accessory})

print("Applied and reattached preset:", PRESET, "HatAttachment.Position:", tostring(value))
print("If front/back moves opposite of what you expect, switch low_front <-> low_back.")
