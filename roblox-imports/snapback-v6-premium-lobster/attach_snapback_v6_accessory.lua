-- Snap Back v6 accessory wrapper/fitter.
-- Steps:
-- 1) Import snap_back_v6_premium_lobster_s0042.fbx
-- 2) Select the imported MeshPart in Explorer
-- 3) Paste/run this in Roblox Studio Command Bar

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

local rig
for _, obj in ipairs(workspace:GetChildren()) do
	if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("Head") then
		rig = obj
		break
	end
end
if not rig then
	error("No rig found. Add one: Avatar tab > Rig Builder > R15.")
end

local humanoid = rig:FindFirstChildOfClass("Humanoid")
local head = rig:FindFirstChild("Head")
local headHat = head:FindFirstChild("HatAttachment")
if not headHat then
	error("Rig head has no HatAttachment.")
end

-- Prepare mesh as accessory handle.
handle.Name = "Handle"
handle.Anchored = false
handle.CanCollide = false
handle.CanTouch = false
handle.Massless = true

-- Clean existing welds/attachments from earlier tests.
for _, child in ipairs(handle:GetChildren()) do
	if child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("Attachment") then
		child:Destroy()
	end
end

local accessory = Instance.new("Accessory")
accessory.Name = "The Snap Back v6 Test"
handle.Parent = accessory

local att = Instance.new("Attachment")
att.Name = "HatAttachment"
att.Parent = handle

-- Tuning values. If it floats/rotates wrong, tweak these first.
-- Positive Y generally moves accessory relative to front/back after AddAccessory.
-- Positive Z moves it up/down depending on imported orientation.
att.Position = Vector3.new(0, 0.02, 0.015)
att.Orientation = Vector3.new(0, 0, 0)

accessory.Parent = workspace
humanoid:AddAccessory(accessory)
Selection:Set({accessory})

print("Attached The Snap Back v6 Test. If it is offset, select Handle > HatAttachment and adjust Position/Orientation.")
