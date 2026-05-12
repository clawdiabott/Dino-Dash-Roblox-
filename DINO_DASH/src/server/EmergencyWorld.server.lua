--!strict

-- Zero-dependency safety bootstrap.
-- This runs independently of Main.server.lua so players always have a physical spawn platform
-- even if another gameplay service fails during startup.

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local WORLD_FOLDER_NAME = "DinoDashWorld"

local function getWorldFolder(): Folder
	local existing = Workspace:FindFirstChild(WORLD_FOLDER_NAME)
	if existing ~= nil and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = WORLD_FOLDER_NAME
	folder.Parent = Workspace
	return folder
end

local function ensurePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): BasePart
	local existing = parent:FindFirstChild(name)
	if existing ~= nil and existing:IsA("BasePart") then
		return existing
	end

	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function ensureSpawn(parent: Instance): SpawnLocation
	local existing = parent:FindFirstChild("DinoDashSpawn")
	if existing ~= nil and existing:IsA("SpawnLocation") then
		return existing
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "DinoDashSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(18, 1, 18)
	spawn.Position = Vector3.new(0, 8, 0)
	spawn.Color = Color3.fromRGB(250, 204, 21)
	spawn.Material = Enum.Material.Neon
	spawn.Neutral = true
	spawn.AllowTeamChangeOnTouch = false
	spawn.Duration = 0
	spawn.Parent = parent
	return spawn
end

local world = getWorldFolder()
Workspace.FallenPartsDestroyHeight = -500

pcall(function()
	Lighting.ClockTime = 14
	Lighting.Brightness = 2
end)

ensurePart(world, "EmergencyDinoDashIsland", Vector3.new(220, 8, 220), Vector3.new(0, 0, 0), Color3.fromRGB(74, 222, 128), Enum.Material.Grass)
ensurePart(world, "EmergencySpawnBase", Vector3.new(42, 4, 42), Vector3.new(0, 5, 0), Color3.fromRGB(22, 163, 74), Enum.Material.Grass)
ensureSpawn(world)
