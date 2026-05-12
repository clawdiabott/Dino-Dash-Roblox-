--!strict

local Types = require(script.Parent.Types)

type DinosaurDefinition = Types.DinosaurDefinition
type NestDefinition = Types.NestDefinition
type TrailDefinition = Types.TrailDefinition
type ZoneDefinition = Types.ZoneDefinition
type EggNestDefinition = Types.EggNestDefinition
type BerryNodeDefinition = Types.BerryNodeDefinition
type DinosaurId = Types.DinosaurId
type TrailId = Types.TrailId
type ZoneId = Types.ZoneId
type EggNestId = Types.EggNestId
type BerryNodeId = Types.BerryNodeId

local GameConfig = {}

GameConfig.SCHEMA_VERSION = 3
GameConfig.STARTING_EGGS = 0
GameConfig.BASE_HATCH_COST = 25
GameConfig.HATCH_COST_GROWTH = 1.08
GameConfig.MAX_OFFLINE_SECONDS = 60 * 60 * 4
GameConfig.AUTOSAVE_SECONDS = 60
GameConfig.INCOME_TICK_SECONDS = 1
GameConfig.FEED_GROWTH_SECONDS = 60
GameConfig.STARTING_BERRY_FOOD = 5

GameConfig.DINOSAURS = {
	{
		id = "starter-raptor" :: DinosaurId,
		displayName = "Starter Raptor",
		rarity = "Common",
		weight = 620,
		eggsPerSecond = 1,
		color = Color3.fromRGB(74, 222, 128),
		modelName = "StarterRaptor",
		growthSeconds = 240,
		mountable = true,
		movementBonus = 8,
		favoriteFood = "Jungle Berries",
	},
	{
		id = "tri-horn" :: DinosaurId,
		displayName = "Tri-Horn",
		rarity = "Rare",
		weight = 250,
		eggsPerSecond = 4,
		color = Color3.fromRGB(96, 165, 250),
		modelName = "TriHorn",
		growthSeconds = 420,
		mountable = true,
		movementBonus = 6,
		favoriteFood = "Palm Leaves",
	},
	{
		id = "bronto-buddy" :: DinosaurId,
		displayName = "Bronto Buddy",
		rarity = "Epic",
		weight = 95,
		eggsPerSecond = 12,
		color = Color3.fromRGB(168, 85, 247),
		modelName = "BrontoBuddy",
		growthSeconds = 720,
		mountable = true,
		movementBonus = 4,
		favoriteFood = "Ancient Ferns",
	},
	{
		id = "shadow-rex" :: DinosaurId,
		displayName = "Shadow Rex",
		rarity = "Legendary",
		weight = 30,
		eggsPerSecond = 42,
		color = Color3.fromRGB(30, 41, 59),
		modelName = "ShadowRex",
		growthSeconds = 900,
		mountable = true,
		movementBonus = 10,
		favoriteFood = "Volcanic Meat",
	},
	{
		id = "golden-ptero" :: DinosaurId,
		displayName = "Golden Ptero",
		rarity = "Legendary",
		weight = 5,
		eggsPerSecond = 125,
		color = Color3.fromRGB(250, 204, 21),
		modelName = "GoldenPtero",
		growthSeconds = 1_080,
		mountable = true,
		movementBonus = 12,
		favoriteFood = "Sunfruit",
	},
} :: { DinosaurDefinition }

GameConfig.NESTS = {
	{ level = 1, upgradeCost = 100, capacity = 8, incomeMultiplier = 1, followSlots = 1, storedSlots = 3 },
	{ level = 2, upgradeCost = 500, capacity = 16, incomeMultiplier = 1.25, followSlots = 2, storedSlots = 8 },
	{ level = 3, upgradeCost = 2_500, capacity = 30, incomeMultiplier = 1.6, followSlots = 2, storedSlots = 14 },
	{ level = 4, upgradeCost = 12_000, capacity = 50, incomeMultiplier = 2.1, followSlots = 3, storedSlots = 24 },
	{ level = 5, upgradeCost = 60_000, capacity = 85, incomeMultiplier = 3, followSlots = 3, storedSlots = 40 },
} :: { NestDefinition }

GameConfig.ZONES = {
	{ id = "starter-valley" :: ZoneId, displayName = "Starter Valley", requiredNestLevel = 1, unlockCost = 0 },
	{ id = "jungle-grove" :: ZoneId, displayName = "Jungle Grove", requiredNestLevel = 2, unlockCost = 250 },
	{ id = "volcano-ridge" :: ZoneId, displayName = "Volcano Ridge", requiredNestLevel = 4, unlockCost = 4_000 },
	{ id = "ancient-ruins" :: ZoneId, displayName = "Ancient Ruins", requiredNestLevel = 5, unlockCost = 20_000 },
} :: { ZoneDefinition }

GameConfig.EGG_NESTS = {
	{
		id = "starter-egg" :: EggNestId,
		displayName = "Starter Egg",
		zoneId = "starter-valley" :: ZoneId,
		dinoId = "starter-raptor" :: DinosaurId,
		cooldownSeconds = 0,
		oneTime = true,
	},
	{
		id = "valley-nest" :: EggNestId,
		displayName = "Valley Egg Nest",
		zoneId = "starter-valley" :: ZoneId,
		dinoId = nil,
		cooldownSeconds = 20,
		oneTime = false,
	},
	{
		id = "jungle-nest" :: EggNestId,
		displayName = "Jungle Egg Nest",
		zoneId = "jungle-grove" :: ZoneId,
		dinoId = nil,
		cooldownSeconds = 45,
		oneTime = false,
	},
	{
		id = "volcano-nest" :: EggNestId,
		displayName = "Volcano Egg Nest",
		zoneId = "volcano-ridge" :: ZoneId,
		dinoId = nil,
		cooldownSeconds = 90,
		oneTime = false,
	},
	{
		id = "ruins-nest" :: EggNestId,
		displayName = "Ancient Ruins Egg Nest",
		zoneId = "ancient-ruins" :: ZoneId,
		dinoId = nil,
		cooldownSeconds = 150,
		oneTime = false,
	},
} :: { EggNestDefinition }

GameConfig.BERRY_NODES = {
	{
		id = "cave-berry" :: BerryNodeId,
		displayName = "Nest Berry Bush",
		zoneId = "starter-valley" :: ZoneId,
		berriesGranted = 3,
		cooldownSeconds = 30,
	},
	{
		id = "path-berry-a" :: BerryNodeId,
		displayName = "Path Berry Bush",
		zoneId = "starter-valley" :: ZoneId,
		berriesGranted = 2,
		cooldownSeconds = 45,
	},
	{
		id = "path-berry-b" :: BerryNodeId,
		displayName = "Sunny Berry Bush",
		zoneId = "starter-valley" :: ZoneId,
		berriesGranted = 2,
		cooldownSeconds = 45,
	},
	{
		id = "valley-berry" :: BerryNodeId,
		displayName = "Valley Berry Patch",
		zoneId = "starter-valley" :: ZoneId,
		berriesGranted = 4,
		cooldownSeconds = 75,
	},
	{
		id = "jungle-berry" :: BerryNodeId,
		displayName = "Jungle Berry Patch",
		zoneId = "jungle-grove" :: ZoneId,
		berriesGranted = 7,
		cooldownSeconds = 120,
	},
} :: { BerryNodeDefinition }

GameConfig.TRAILS = {
	{
		id = "none" :: TrailId,
		displayName = "No Trail",
		cost = 0,
		color = ColorSequence.new(Color3.new(1, 1, 1)),
	},
	{
		id = "leaf-swirl" :: TrailId,
		displayName = "Leaf Swirl",
		cost = 750,
		color = ColorSequence.new(Color3.fromRGB(34, 197, 94), Color3.fromRGB(190, 242, 100)),
	},
	{
		id = "lava-spark" :: TrailId,
		displayName = "Lava Spark",
		cost = 3_500,
		color = ColorSequence.new(Color3.fromRGB(239, 68, 68), Color3.fromRGB(251, 191, 36)),
	},
	{
		id = "cosmic-comet" :: TrailId,
		displayName = "Cosmic Comet",
		cost = 15_000,
		color = ColorSequence.new(Color3.fromRGB(99, 102, 241), Color3.fromRGB(236, 72, 153)),
	},
} :: { TrailDefinition }

local totalWeight = 0
for _, dino in GameConfig.DINOSAURS do
	totalWeight += dino.weight
end
GameConfig.TOTAL_DINO_WEIGHT = totalWeight

function GameConfig.getNest(level: number): NestDefinition
	return GameConfig.NESTS[math.clamp(level, 1, #GameConfig.NESTS)]
end

function GameConfig.getNextNest(level: number): NestDefinition?
	return GameConfig.NESTS[level + 1]
end

function GameConfig.getTrail(trailId: TrailId): TrailDefinition?
	for _, trail in GameConfig.TRAILS do
		if trail.id == trailId then
			return trail
		end
	end
	return nil
end

function GameConfig.getDinosaur(dinoId: DinosaurId): DinosaurDefinition?
	for _, dino in GameConfig.DINOSAURS do
		if dino.id == dinoId then
			return dino
		end
	end
	return nil
end

function GameConfig.getZone(zoneId: ZoneId): ZoneDefinition?
	for _, zone in GameConfig.ZONES do
		if zone.id == zoneId then
			return zone
		end
	end
	return nil
end

function GameConfig.getEggNest(nestId: EggNestId): EggNestDefinition?
	for _, eggNest in GameConfig.EGG_NESTS do
		if eggNest.id == nestId then
			return eggNest
		end
	end
	return nil
end

function GameConfig.getBerryNode(berryNodeId: BerryNodeId): BerryNodeDefinition?
	for _, berryNode in GameConfig.BERRY_NODES do
		if berryNode.id == berryNodeId then
			return berryNode
		end
	end
	return nil
end

function GameConfig.getHatchCost(hatchCount: number): number
	return math.floor(GameConfig.BASE_HATCH_COST * (GameConfig.HATCH_COST_GROWTH ^ hatchCount))
end

function GameConfig.getGrowthStage(ageSeconds: number, growthSeconds: number): Types.GrowthStage
	local progress = if growthSeconds <= 0 then 1 else ageSeconds / growthSeconds
	if progress >= 1 then
		return "Adult"
	elseif progress >= 0.45 then
		return "Juvenile"
	end
	return "Baby"
end

function GameConfig.rollDinosaur(rng: Random): DinosaurDefinition
	local roll = rng:NextInteger(1, GameConfig.TOTAL_DINO_WEIGHT)
	local running = 0
	for _, dino in GameConfig.DINOSAURS do
		running += dino.weight
		if roll <= running then
			return dino
		end
	end
	return GameConfig.DINOSAURS[1]
end

return GameConfig
