-- THE SNAP BACK — fit preset tool
-- Use this to quickly test attachment positions without manually dragging the hat.
--
-- Steps:
-- 1) Select the Accessory named "The Snap Back" OR its Handle in Explorer.
-- 2) Paste this into View > Command Bar.
-- 3) Change PRESET below and rerun until it sits right.
--
-- Presets:
-- "lower"        = sits lower/tighter on head
-- "front"        = moves claws/brim toward face
-- "back"         = moves hat back
-- "low_front"    = recommended first try
-- "low_back"     = if it floats forward
-- "higher"       = if it sinks into head
-- "reset"        = original

local Selection = game:GetService("Selection")

local PRESET = "low_front" -- change this

local presets = {
	reset = Vector3.new(0, 0.015, 0.005),
	lower = Vector3.new(0, 0.055, 0.005),
	higher = Vector3.new(0, -0.005, 0.005),
	front = Vector3.new(0, 0.025, -0.045),
	back = Vector3.new(0, 0.025, 0.045),
	low_front = Vector3.new(0, 0.055, -0.040),
	low_back = Vector3.new(0, 0.055, 0.040),
	front_more = Vector3.new(0, 0.060, -0.075),
	back_more = Vector3.new(0, 0.060, 0.075),
}

local selected = Selection:Get()[1]
if not selected then error("Select The Snap Back accessory or Handle first.") end

local handle
if selected:IsA("Accessory") then
	handle = selected:FindFirstChild("Handle")
elseif selected:IsA("MeshPart") then
	handle = selected
elseif selected:IsA("Model") then
	handle = selected:FindFirstChild("Handle") or selected:FindFirstChildWhichIsA("MeshPart", true)
end
if not handle then error("Could not find Handle. Select the accessory or mesh handle.") end

local att = handle:FindFirstChild("HatAttachment")
if not att then
	att = Instance.new("Attachment")
	att.Name = "HatAttachment"
	att.Parent = handle
end

local value = presets[PRESET]
if not value then
	error("Unknown preset: " .. tostring(PRESET))
end

att.Position = value
att.Orientation = Vector3.new(0, 0, 0)
print("Applied Snap Back fit preset:", PRESET, "Position:", tostring(value))
print("If it moves opposite front/back, use low_back instead of low_front, or vice versa.")
