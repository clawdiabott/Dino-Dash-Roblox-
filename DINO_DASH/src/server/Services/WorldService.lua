--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local WorldService = {}
local WORLD_FOLDER_NAME = "DinoDashWorld"
local ASSETS_FOLDER_NAME = "DinoDashAssets"
local DINO_MODELS_FOLDER_NAME = "DinoModels"

type PartShape = "Block" | "Ball" | "Cylinder"
type DecorationPart = {
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material,
	shape: PartShape?,
	orientation: Vector3?,
	transparency: number?,
	canCollide: boolean?,
}

local function ensureFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing ~= nil and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function getWorldFolder(): Folder
	return ensureFolder(Workspace, WORLD_FOLDER_NAME)
end

local function getDinoModelsFolder(): Folder
	local assets = ensureFolder(ReplicatedStorage, ASSETS_FOLDER_NAME)
	return ensureFolder(assets, DINO_MODELS_FOLDER_NAME)
end

local function shapeToEnum(shape: PartShape?): Enum.PartType
	if shape == "Ball" then
		return Enum.PartType.Ball
	elseif shape == "Cylinder" then
		return Enum.PartType.Cylinder
	end
	return Enum.PartType.Block
end

local function ensurePart(parent: Instance, spec: DecorationPart): Part
	local existing = parent:FindFirstChild(spec.name)
	local part: Part
	if existing ~= nil and existing:IsA("Part") then
		part = existing
	else
		part = Instance.new("Part")
		part.Name = spec.name
		part.Parent = parent
	end

	part.Anchored = true
	part.CanCollide = if spec.canCollide == nil then true else spec.canCollide
	part.Size = spec.size
	part.Position = spec.position
	part.Orientation = spec.orientation or Vector3.zero
	part.Color = spec.color
	part.Material = spec.material
	part.Shape = shapeToEnum(spec.shape)
	part.Transparency = spec.transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function ensureModel(parent: Instance, name: string): Folder
	return ensureFolder(parent, name)
end

local function ensureLabel(parent: BasePart, text: string, offset: Vector3?): ()
	local existing = parent:FindFirstChild("Label")
	if existing ~= nil and existing:IsA("BillboardGui") then
		local label = existing:FindFirstChild("Text")
		if label ~= nil and label:IsA("TextLabel") then
			label.Text = text
		end
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(330, 100)
	billboard.StudsOffset = offset or Vector3.new(0, 8, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 160
	billboard.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.2
	label.Text = text
	label.Parent = billboard
end

local function ensurePrompt(parent: BasePart, name: string, actionText: string, objectText: string): ProximityPrompt
	local existing = parent:FindFirstChild(name)
	local prompt: ProximityPrompt
	if existing ~= nil and existing:IsA("ProximityPrompt") then
		prompt = existing
	else
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = name
		prompt.Parent = parent
	end
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 16
	prompt.RequiresLineOfSight = false
	return prompt
end

local function ensureSpawn(parent: Instance): SpawnLocation
	local existing = parent:FindFirstChild("DinoDashSpawn")
	local spawn: SpawnLocation
	if existing ~= nil and existing:IsA("SpawnLocation") then
		spawn = existing
	else
		spawn = Instance.new("SpawnLocation")
		spawn.Name = "DinoDashSpawn"
		spawn.Parent = parent
	end

	spawn.Anchored = true
	spawn.Size = Vector3.new(16, 1, 16)
	spawn.Position = Vector3.new(0, 9, 34)
	spawn.Color = Color3.fromRGB(250, 204, 21)
	spawn.Material = Enum.Material.Neon
	spawn.Neutral = true
	spawn.AllowTeamChangeOnTouch = false
	spawn.Duration = 0
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	return spawn
end

local function createTree(parent: Instance, index: number, position: Vector3, scale: number): ()
	ensurePart(parent, {
		name = `AncientTreeTrunk_{index}`,
		size = Vector3.new(4 * scale, 26 * scale, 4 * scale),
		position = position + Vector3.new(0, 13 * scale, 0),
		color = Color3.fromRGB(104, 62, 28),
		material = Enum.Material.Wood,
	})
	for layer = 1, 3 do
		ensurePart(parent, {
			name = `AncientTreeCanopy_{index}_{layer}`,
			size = Vector3.new((26 - layer * 3) * scale, (13 - layer * 2) * scale, (26 - layer * 3) * scale),
			position = position + Vector3.new(0, (27 + layer * 6) * scale, 0),
			color = Color3.fromRGB(28, 130 + layer * 15, 66),
			material = Enum.Material.Grass,
			shape = "Ball",
		})
	end
end

local function createBone(parent: Instance, index: number, position: Vector3, yaw: number): ()
	ensurePart(parent, {
		name = `FossilBone_{index}`,
		size = Vector3.new(34, 4, 4),
		position = position,
		color = Color3.fromRGB(245, 245, 220),
		material = Enum.Material.SmoothPlastic,
		orientation = Vector3.new(0, yaw, 10),
	})
	ensurePart(parent, {
		name = `FossilBoneKnobA_{index}`,
		size = Vector3.new(8, 8, 8),
		position = position + Vector3.new(math.cos(math.rad(yaw)) * 17, 0, -math.sin(math.rad(yaw)) * 17),
		color = Color3.fromRGB(245, 245, 220),
		material = Enum.Material.SmoothPlastic,
		shape = "Ball",
	})
	ensurePart(parent, {
		name = `FossilBoneKnobB_{index}`,
		size = Vector3.new(8, 8, 8),
		position = position - Vector3.new(math.cos(math.rad(yaw)) * 17, 0, -math.sin(math.rad(yaw)) * 17),
		color = Color3.fromRGB(245, 245, 220),
		material = Enum.Material.SmoothPlastic,
		shape = "Ball",
	})
end

local function createEggNest(parent: Instance, nestId: string, displayName: string, position: Vector3, color: Color3, promptText: string): ()
	local nest = ensurePart(parent, {
		name = `{nestId}_NestBowl`,
		size = Vector3.new(24, 6, 24),
		position = position,
		color = Color3.fromRGB(120, 53, 15),
		material = Enum.Material.Wood,
		shape = "Cylinder",
		orientation = Vector3.new(0, 0, 90),
	})
	nest:SetAttribute("EggNestId", nestId)
	ensureLabel(nest, displayName, Vector3.new(0, 8, 0))

	local egg = ensurePart(parent, {
		name = `{nestId}_Egg`,
		size = Vector3.new(10, 14, 10),
		position = position + Vector3.new(0, 9, 0),
		color = color,
		material = Enum.Material.Neon,
		shape = "Ball",
		canCollide = false,
	})
	egg:SetAttribute("EggNestId", nestId)
	ensurePrompt(egg, "CollectEggPrompt", promptText, displayName)
end

local function createBerryBush(parent: Instance, berryNodeId: string, displayName: string, position: Vector3): ()
	local bush = ensurePart(parent, {
		name = `{berryNodeId}_BerryBush`,
		size = Vector3.new(12, 8, 12),
		position = position + Vector3.new(0, 4, 0),
		color = Color3.fromRGB(22, 163, 74),
		material = Enum.Material.Grass,
		shape = "Ball",
	})
	bush:SetAttribute("BerryNodeId", berryNodeId)
	ensureLabel(bush, `{displayName}\nGather dino snacks`, Vector3.new(0, 8, 0))
	ensurePrompt(bush, "CollectBerryPrompt", "Gather", displayName)

	for berry = 1, 5 do
		local angle = math.rad(berry * 72)
		local berryPart = ensurePart(parent, {
			name = `{berryNodeId}_Berry_{berry}`,
			size = Vector3.new(2.1, 2.1, 2.1),
			position = position + Vector3.new(math.cos(angle) * 4, 7 + (berry % 2), math.sin(angle) * 4),
			color = Color3.fromRGB(239, 68, 68),
			material = Enum.Material.Neon,
			shape = "Ball",
			canCollide = false,
		})
		berryPart:SetAttribute("BerryNodeId", berryNodeId)
	end
end

local function ensureTemplatePart(parent: Model, name: string, size: Vector3, cframe: CFrame, color: Color3): Part
	local existing = parent:FindFirstChild(name)
	local part: Part
	if existing ~= nil and existing:IsA("Part") then
		part = existing
	else
		part = Instance.new("Part")
		part.Name = name
		part.Parent = parent
	end
	part.Anchored = true
	part.CanCollide = false
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function ensureDinoTemplate(parent: Instance, name: string, scale: number, color: Color3): ()
	local existing = parent:FindFirstChild(name)
	local model: Model
	if existing ~= nil and existing:IsA("Model") then
		model = existing
	else
		model = Instance.new("Model")
		model.Name = name
		model.Parent = parent
	end
	model:SetAttribute("DinoDashTemplate", true)
	model:SetAttribute("TemplateVersion", 1)
	model:SetAttribute("ReplaceWithAuthoredArt", true)

	local body = ensureTemplatePart(model, "Body", Vector3.new(4.8, 2.4, 7.2) * scale, CFrame.new(0, 0, 0), color)
	model.PrimaryPart = body
	ensureTemplatePart(model, "Head", Vector3.new(2.8, 2.2, 2.8) * scale, CFrame.new(0, 0.6 * scale, -4.4 * scale), color)
	ensureTemplatePart(model, "Tail", Vector3.new(1.4, 1.4, 5.4) * scale, CFrame.new(0, 0.25 * scale, 5.6 * scale) * CFrame.Angles(math.rad(-8), 0, 0), color)
	ensureTemplatePart(model, "LeftLeg", Vector3.new(1.1, 2.4, 1.1) * scale, CFrame.new(-1.35 * scale, -2 * scale, -1.5 * scale), color)
	ensureTemplatePart(model, "RightLeg", Vector3.new(1.1, 2.4, 1.1) * scale, CFrame.new(1.35 * scale, -2 * scale, -1.5 * scale), color)
	ensureTemplatePart(model, "BackSpike", Vector3.new(0.8, 2.8, 0.8) * scale, CFrame.new(0, 2.1 * scale, -0.6 * scale), Color3.fromRGB(255, 255, 255))
	if name:find("Adult") ~= nil then
		ensureTemplatePart(model, "RideSaddle", Vector3.new(3.8, 0.7, 3.6) * scale, CFrame.new(0, 1.65 * scale, -0.2 * scale), Color3.fromRGB(92, 51, 23))
	end
end

local function buildDinoModelTemplates(): ()
	local models = getDinoModelsFolder()
	ensureDinoTemplate(models, "StarterRaptor_Baby", 0.82, Color3.fromRGB(74, 222, 128))
	ensureDinoTemplate(models, "StarterRaptor_Juvenile", 1.25, Color3.fromRGB(74, 222, 128))
	ensureDinoTemplate(models, "StarterRaptor_Adult", 1.8, Color3.fromRGB(74, 222, 128))
end

local function createZoneGate(parent: Instance, gateId: string, displayName: string, position: Vector3, color: Color3, required: string): ()
	local frame = ensurePart(parent, {
		name = `{gateId}_GateFrame`,
		size = Vector3.new(54, 42, 8),
		position = position + Vector3.new(0, 21, 0),
		color = color,
		material = Enum.Material.Cobblestone,
		transparency = 0.1,
	})
	frame:SetAttribute("ZoneId", gateId)
	ensureLabel(frame, `{displayName}\n{required}`, Vector3.new(0, 30, 0))

	local door = ensurePart(parent, {
		name = `{gateId}_GateDoor`,
		size = Vector3.new(44, 28, 4),
		position = position + Vector3.new(0, 16, -2),
		color = Color3.fromRGB(15, 23, 42),
		material = Enum.Material.ForceField,
		transparency = 0.25,
	})
	door:SetAttribute("ZoneId", gateId)
	ensurePrompt(door, "UnlockZonePrompt", "Unlock", displayName)
end

function WorldService.build(): ()
	buildDinoModelTemplates()
	local world = getWorldFolder()
	Workspace.FallenPartsDestroyHeight = -500
	pcall(function()
		Lighting.ClockTime = 14
		Lighting.Brightness = 2.7
		Lighting.EnvironmentDiffuseScale = 0.9
		Lighting.EnvironmentSpecularScale = 0.45
		Lighting.FogEnd = 950
		Lighting.FogColor = Color3.fromRGB(181, 231, 205)
	end)

	ensurePart(world, {
		name = "StarterValleyIsland",
		size = Vector3.new(780, 18, 780),
		position = Vector3.new(0, -4, 0),
		color = Color3.fromRGB(53, 154, 74),
		material = Enum.Material.Grass,
	})
	ensurePart(world, {
		name = "StarterValleyBackRidge",
		size = Vector3.new(760, 60, 62),
		position = Vector3.new(0, 18, -365),
		color = Color3.fromRGB(68, 117, 72),
		material = Enum.Material.Rock,
	})
	ensurePart(world, {
		name = "LeftCliffWall",
		size = Vector3.new(60, 48, 620),
		position = Vector3.new(-370, 14, -25),
		color = Color3.fromRGB(71, 85, 105),
		material = Enum.Material.Rock,
	})
	ensurePart(world, {
		name = "RightCliffWall",
		size = Vector3.new(60, 48, 620),
		position = Vector3.new(370, 14, -25),
		color = Color3.fromRGB(71, 85, 105),
		material = Enum.Material.Rock,
	})

	local cave = ensureModel(world, "StarterNestCave")
	ensurePart(cave, {
		name = "CaveFloor",
		size = Vector3.new(112, 7, 88),
		position = Vector3.new(0, 4, 0),
		color = Color3.fromRGB(146, 64, 14),
		material = Enum.Material.Ground,
	})
	ensurePart(cave, {
		name = "CaveBackWall",
		size = Vector3.new(120, 54, 15),
		position = Vector3.new(0, 28, -44),
		color = Color3.fromRGB(87, 83, 78),
		material = Enum.Material.Rock,
	})
	ensurePart(cave, {
		name = "CaveLeftWall",
		size = Vector3.new(15, 42, 88),
		position = Vector3.new(-60, 23, 0),
		color = Color3.fromRGB(87, 83, 78),
		material = Enum.Material.Rock,
	})
	ensurePart(cave, {
		name = "CaveRightWall",
		size = Vector3.new(15, 42, 88),
		position = Vector3.new(60, 23, 0),
		color = Color3.fromRGB(87, 83, 78),
		material = Enum.Material.Rock,
	})
	ensurePart(cave, {
		name = "CaveRoofArch",
		size = Vector3.new(132, 34, 96),
		position = Vector3.new(0, 54, -8),
		color = Color3.fromRGB(68, 64, 60),
		material = Enum.Material.Slate,
		shape = "Cylinder",
		orientation = Vector3.new(0, 0, 90),
	})
	local caveSign = ensurePart(cave, {
		name = "NestCaveSign",
		size = Vector3.new(42, 12, 3),
		position = Vector3.new(0, 25, 48),
		color = Color3.fromRGB(120, 53, 15),
		material = Enum.Material.WoodPlanks,
	})
	ensureLabel(caveSign, "YOUR DINO NEST\nCollect your first egg", Vector3.new(0, 12, 0))

	ensureSpawn(world)
	createEggNest(world, "starter-egg", "STARTER EGG\nWalk here or press Starter Egg", Vector3.new(0, 10, 78), Color3.fromRGB(250, 250, 210), "Collect")
	createEggNest(world, "valley-nest", "VALLEY EGG NEST\nFind more dinos", Vector3.new(116, 9, 134), Color3.fromRGB(191, 219, 254), "Search")
	createBerryBush(world, "cave-berry", "NEST BERRIES", Vector3.new(-36, 8, 52))
	createBerryBush(world, "path-berry-a", "PATH BERRIES", Vector3.new(-62, 8, 126))
	createBerryBush(world, "path-berry-b", "SUNNY BERRIES", Vector3.new(48, 8, 176))
	createBerryBush(world, "valley-berry", "VALLEY BERRY PATCH", Vector3.new(144, 8, 92))
	createBerryBush(world, "jungle-berry", "JUNGLE BERRY PATCH", Vector3.new(0, 8, 330))

	local starterArrow = ensurePart(world, {
		name = "StarterEggArrow",
		size = Vector3.new(24, 3, 10),
		position = Vector3.new(0, 18, 50),
		color = Color3.fromRGB(250, 204, 21),
		material = Enum.Material.Neon,
		orientation = Vector3.new(0, 0, 0),
		canCollide = false,
	})
	ensureLabel(starterArrow, "FIRST EGG THIS WAY", Vector3.new(0, 7, 0))

	ensurePart(world, {
		name = "StarterPathFromCave",
		size = Vector3.new(34, 1, 230),
		position = Vector3.new(0, 6, 152),
		color = Color3.fromRGB(217, 168, 91),
		material = Enum.Material.Ground,
	})
	ensurePart(world, {
		name = "PathToValleyNest",
		size = Vector3.new(28, 1, 170),
		position = Vector3.new(72, 6.2, 158),
		color = Color3.fromRGB(217, 168, 91),
		material = Enum.Material.Ground,
		orientation = Vector3.new(0, -42, 0),
	})

	createZoneGate(world, "jungle-grove", "JUNGLE GROVE", Vector3.new(0, 4, 285), Color3.fromRGB(22, 101, 52), "Nest Lv.2 + 250 eggs")
	createZoneGate(world, "volcano-ridge", "VOLCANO RIDGE", Vector3.new(-235, 4, 48), Color3.fromRGB(127, 29, 29), "Nest Lv.4 + 4000 eggs")
	createZoneGate(world, "ancient-ruins", "ANCIENT RUINS", Vector3.new(235, 4, 48), Color3.fromRGB(88, 28, 135), "Nest Lv.5 + 20000 eggs")

	ensurePart(world, {
		name = "FarVolcanoSilhouette",
		size = Vector3.new(130, 86, 130),
		position = Vector3.new(-250, 42, -246),
		color = Color3.fromRGB(68, 64, 60),
		material = Enum.Material.Slate,
		shape = "Cylinder",
		orientation = Vector3.new(0, 0, 90),
	})
	ensurePart(world, {
		name = "VolcanoGlow",
		size = Vector3.new(42, 4, 42),
		position = Vector3.new(-250, 88, -246),
		color = Color3.fromRGB(239, 68, 68),
		material = Enum.Material.Neon,
		shape = "Cylinder",
		orientation = Vector3.new(0, 0, 90),
	})
	ensurePart(world, {
		name = "AncientRuinsSilhouette",
		size = Vector3.new(150, 10, 70),
		position = Vector3.new(248, 10, -228),
		color = Color3.fromRGB(161, 161, 170),
		material = Enum.Material.Cobblestone,
	})
	for pillar = 1, 6 do
		ensurePart(world, {
			name = `RuinsTallPillar_{pillar}`,
			size = Vector3.new(10, 52 + (pillar % 2) * 18, 10),
			position = Vector3.new(190 + pillar * 19, 34, -230),
			color = Color3.fromRGB(212, 212, 216),
			material = Enum.Material.Marble,
		})
	end

	local treePositions = {
		Vector3.new(-160, 7, 126), Vector3.new(-128, 7, 184), Vector3.new(-76, 7, 240),
		Vector3.new(142, 7, 72), Vector3.new(178, 7, 140), Vector3.new(210, 7, 212),
		Vector3.new(-212, 7, -34), Vector3.new(212, 7, -42), Vector3.new(-108, 7, -176),
		Vector3.new(112, 7, -162), Vector3.new(-284, 7, 168), Vector3.new(286, 7, 170),
	}
	for index, position in treePositions do
		createTree(world, index, position, 0.85 + (index % 4) * 0.14)
	end
	for bone = 1, 5 do
		createBone(world, bone, Vector3.new(-160 + bone * 52, 13, 218 + (bone % 2) * 28), bone * 31)
	end

	ensurePart(world, {
		name = "NestUpgradePedestal",
		size = Vector3.new(22, 5, 22),
		position = Vector3.new(33, 9, -8),
		color = Color3.fromRGB(245, 158, 11),
		material = Enum.Material.Neon,
		shape = "Cylinder",
		orientation = Vector3.new(0, 0, 90),
	})
	local feedStation = ensurePart(world, {
		name = "DinoFeedStation",
		size = Vector3.new(24, 5, 18),
		position = Vector3.new(-33, 9, 12),
		color = Color3.fromRGB(34, 197, 94),
		material = Enum.Material.WoodPlanks,
	})
	ensureLabel(feedStation, "FEED & RAISE\nGrow baby dinos", Vector3.new(0, 10, 0))
	ensurePrompt(feedStation, "FeedDinoPrompt", "Feed", "Dino Feed Station")
	ensurePart(world, {
		name = "AdultRaptorPreview",
		size = Vector3.new(10, 5, 16),
		position = Vector3.new(-48, 13, 32),
		color = Color3.fromRGB(22, 163, 74),
		material = Enum.Material.SmoothPlastic,
	})
	ensurePart(world, {
		name = "StoredDinoBed_1",
		size = Vector3.new(18, 3, 14),
		position = Vector3.new(-34, 9, -17),
		color = Color3.fromRGB(202, 138, 4),
		material = Enum.Material.WoodPlanks,
	})
	ensurePart(world, {
		name = "StoredDinoBed_2",
		size = Vector3.new(18, 3, 14),
		position = Vector3.new(0, 9, -23),
		color = Color3.fromRGB(202, 138, 4),
		material = Enum.Material.WoodPlanks,
	})
end

function WorldService.getEggNestPosition(nestId: string): Vector3?
	local world = getWorldFolder()
	local egg = world:FindFirstChild(`{nestId}_Egg`, true)
	if egg ~= nil and egg:IsA("BasePart") then
		return egg.Position
	end
	return nil
end

function WorldService.getZoneGatePosition(zoneId: string): Vector3?
	local world = getWorldFolder()
	local door = world:FindFirstChild(`{zoneId}_GateDoor`, true)
	if door ~= nil and door:IsA("BasePart") then
		return door.Position
	end
	return nil
end

function WorldService.getBerryNodePosition(berryNodeId: string): Vector3?
	local world = getWorldFolder()
	local bush = world:FindFirstChild(`{berryNodeId}_BerryBush`, true)
	if bush ~= nil and bush:IsA("BasePart") then
		return bush.Position
	end
	return nil
end

function WorldService.getFeedStationPosition(): Vector3?
	local world = getWorldFolder()
	local station = world:FindFirstChild("DinoFeedStation", true)
	if station ~= nil and station:IsA("BasePart") then
		return station.Position
	end
	return nil
end

function WorldService.connectInteractions(onEggNest: (Player, string) -> (), onZoneGate: (Player, string) -> (), onBerryNode: (Player, string) -> (), onFeedDino: (Player) -> ()): ()
	local world = getWorldFolder()
	for _, descendant in world:GetDescendants() do
		if descendant:IsA("ProximityPrompt") then
			if descendant.Name == "CollectEggPrompt" then
				descendant.Triggered:Connect(function(player: Player)
					local parent = descendant.Parent
					local nestId = if parent ~= nil then parent:GetAttribute("EggNestId") else nil
					if typeof(nestId) == "string" then
						onEggNest(player, nestId)
					end
				end)
			elseif descendant.Name == "UnlockZonePrompt" then
				descendant.Triggered:Connect(function(player: Player)
					local parent = descendant.Parent
					local zoneId = if parent ~= nil then parent:GetAttribute("ZoneId") else nil
					if typeof(zoneId) == "string" then
						onZoneGate(player, zoneId)
					end
				end)
			elseif descendant.Name == "CollectBerryPrompt" then
				descendant.Triggered:Connect(function(player: Player)
					local parent = descendant.Parent
					local berryNodeId = if parent ~= nil then parent:GetAttribute("BerryNodeId") else nil
					if typeof(berryNodeId) == "string" then
						onBerryNode(player, berryNodeId)
					end
				end)
			elseif descendant.Name == "FeedDinoPrompt" then
				descendant.Triggered:Connect(function(player: Player)
					onFeedDino(player)
				end)
			end
		end
	end
end

return WorldService
