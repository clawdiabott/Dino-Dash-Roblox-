-- Snap Back v8 multi-color accessory wrapper.
-- This version keeps multiple colored MeshParts, welds them to one Handle, and attaches to an R15 rig.
-- Steps:
-- 1) Import snap_back_v8_real_lobster_colors_multi.fbx or .glb
-- 2) Drag all imported v8 parts/model into Workspace if needed
-- 3) Select either the imported Model OR all imported v8 MeshParts in Explorer
-- 4) Paste/run this in Studio Command Bar

local Selection = game:GetService("Selection")
local selected = Selection:Get()
if #selected == 0 then error("Select the imported v8 Model or all v8 MeshParts first.") end

local parts = {}
local function collect(obj)
	if obj:IsA("MeshPart") then
		table.insert(parts, obj)
	elseif obj:IsA("Model") or obj:IsA("Folder") then
		for _, d in ipairs(obj:GetDescendants()) do
			if d:IsA("MeshPart") then table.insert(parts, d) end
		end
	end
end
for _, obj in ipairs(selected) do collect(obj) end
if #parts == 0 then error("No MeshParts found in selection.") end

local rig
for _, obj in ipairs(workspace:GetChildren()) do
	if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("Head") then rig = obj; break end
end
if not rig then error("No rig found. Add one: Avatar tab > Rig Builder > R15.") end
local humanoid = rig:FindFirstChildOfClass("Humanoid")

-- Choose biggest part as Handle.
table.sort(parts, function(a,b) return a.Size.Magnitude > b.Size.Magnitude end)
local handle = parts[1]
handle.Name = "Handle"
handle.Anchored = false
handle.CanCollide = false
handle.CanTouch = false
handle.Massless = true

local accessory = Instance.new("Accessory")
accessory.Name = "The Snap Back v8 Real Colors Test"
accessory.Parent = workspace
handle.Parent = accessory

for _, p in ipairs(parts) do
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.Massless = true
	if p ~= handle then
		p.Parent = accessory
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = p
		weld.Parent = handle
	end
end

for _, child in ipairs(handle:GetChildren()) do
	if child:IsA("Attachment") then child:Destroy() end
end
local att = Instance.new("Attachment")
att.Name = "HatAttachment"
att.Parent = handle
att.Position = Vector3.new(0, 0.015, 0.005)
att.Orientation = Vector3.new(0, 0, 0)

humanoid:AddAccessory(accessory)
Selection:Set({accessory})
print("Attached Snap Back v8 multi-color accessory with " .. tostring(#parts) .. " mesh parts welded to Handle.")
