-- Snap Back v7 wearable accessory wrapper/fitter.
-- Steps:
-- 1) Import snap_back_v7_wearable_s0048.fbx or s0042.fbx
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
if not humanoid or not head then
	error("Rig needs Humanoid and Head.")
end

handle.Name = "Handle"
handle.Anchored = false
handle.CanCollide = false
handle.CanTouch = false
handle.Massless = true

-- Make prototype less gray inside Studio. Final version should use texture/SurfaceAppearance.
handle.Material = Enum.Material.SmoothPlastic
handle.Color = Color3.fromRGB(220, 45, 25)

for _, child in ipairs(handle:GetChildren()) do
	if child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("Attachment") then
		child:Destroy()
	end
end

local accessory = Instance.new("Accessory")
accessory.Name = "The Snap Back v7 Test"
handle.Parent = accessory

local att = Instance.new("Attachment")
att.Name = "HatAttachment"
att.Parent = handle

-- Tuned starting point for v7. Adjust if it sits high/low/front/back.
att.Position = Vector3.new(0, 0.015, 0.005)
att.Orientation = Vector3.new(0, 0, 0)

accessory.Parent = workspace
humanoid:AddAccessory(accessory)
Selection:Set({accessory})

print("Attached The Snap Back v7 Test. Next: tune Handle.HatAttachment.Position/Orientation if needed.")
