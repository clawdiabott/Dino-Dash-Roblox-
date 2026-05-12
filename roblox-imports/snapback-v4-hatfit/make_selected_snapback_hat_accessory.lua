-- Select the imported Snap Back MeshPart in Explorer, then run this in Roblox Studio Command Bar.
-- It wraps the selected mesh as a wearable Hat Accessory and fits it to the first rig in Workspace.

local Selection = game:GetService("Selection")

local selected = Selection:Get()[1]
if not selected then
	error("Select the imported Snap Back MeshPart first.")
end

local handle
if selected:IsA("MeshPart") then
	handle = selected
elseif selected:IsA("Model") then
	handle = selected:FindFirstChildWhichIsA("MeshPart", true)
end
if not handle then
	error("Selected object must be a MeshPart or Model containing a MeshPart.")
end

-- Find a test rig/avatar.
local rig
for _, obj in ipairs(workspace:GetChildren()) do
	if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("Head") then
		rig = obj
		break
	end
end
if not rig then
	error("No rig found. Add one first: Avatar tab > Rig Builder > R15.")
end

local head = rig:FindFirstChild("Head")
local headHat = head and head:FindFirstChild("HatAttachment")
if not headHat then
	error("Rig head has no HatAttachment.")
end

-- Clean old accessory wrapper if this mesh was already wrapped.
local accessory = Instance.new("Accessory")
accessory.Name = "The Snap Back - Test Accessory"

handle.Name = "Handle"
handle.Anchored = false
handle.CanCollide = false
handle.Massless = true
handle.Parent = accessory

-- Attachment offset: tweak this if it sits too high/low/front/back.
local hatAtt = handle:FindFirstChild("HatAttachment") or Instance.new("Attachment")
hatAtt.Name = "HatAttachment"
hatAtt.Parent = handle
hatAtt.Position = Vector3.new(0, 0.05, 0.02)
hatAtt.Orientation = Vector3.new(0, 0, 0)

accessory.Parent = workspace
rig:FindFirstChildOfClass("Humanoid"):AddAccessory(accessory)
Selection:Set({accessory})
print("Snap Back accessory attached. If it floats, tweak Handle.HatAttachment.Position.")
