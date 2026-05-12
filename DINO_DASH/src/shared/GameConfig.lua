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
		id = "velociraptor" :: DinosaurId,
		displayName = "Velociraptor (Swift Pack Hunter)",
		rarity = "Common",
		weight = 520,
		eggsPerSecond = 2,
		color = Color3.fromRGB(120, 200, 80),
		modelName = "Velociraptor",
		growthSeconds = 180,
		mountable = true,
		movementBonus = 14,
		favoriteFood = "Jungle Berries",
		baseHealth = 80,
		baseDamage = 25,
		baseSpeed = 35,
		traits = {"PackHunter", "SwiftRunner"},
	},
	{
		id = "triceratops" :: DinosaurId,
		displayName = "Triceratops (Three-Horned Defender)",
		rarity = "Uncommon",
		weight = 380,
		eggsPerSecond = 5,
		color = Color3.fromRGB(180, 140, 60),
		modelName = "Triceratops",
		growthSeconds = 420,
		mountable = true,
		movementBonus = 7,
		favoriteFood = "Palm Leaves",
		baseHealth = 180,
		baseDamage = 35,
		baseSpeed = 12,
		traits = {"HerbivoreTank"},
	},
	{
		id = "brachiosaurus" :: DinosaurId,
		displayName = "Brachiosaurus (Giant Long-Neck)",
		rarity = "Rare",
		weight = 220,
		eggsPerSecond = 14,
		color = Color3.fromRGB(90, 160, 220),
		modelName = "Brachiosaurus",
		growthSeconds = 720,
		mountable = true,
		movementBonus = 5,
		favoriteFood = "Ancient Ferns",
		baseHealth = 250,
		baseDamage = 20,
		baseSpeed = 8,
		traits = {"HerbivoreTank"},
	},
	{
		id = "tyrannosaurus" :: DinosaurId,
		displayName = "Tyrannosaurus rex (Apex Predator)",
		rarity = "Epic",
		weight = 110,
		eggsPerSecond = 35,
		color = Color3.fromRGB(160, 40, 40),
		modelName = "Tyrannosaurus",
		growthSeconds = 960,
		mountable = true,
		movementBonus = 11,
		favoriteFood = "Volcanic Meat",
		baseHealth = 220,
		baseDamage = 65,
		baseSpeed = 22,
		traits = {"ApexPredator"},
	},
	{
		id = "pteranodon" :: DinosaurId,
		displayName = "Pteranodon (Sky Soarer)",
		rarity = "Epic",
		weight = 85,
		eggsPerSecond = 18,
		color = Color3.fromRGB(240, 220, 100),
		modelName = "Pteranodon",
		growthSeconds = 600,
		mountable = true,
		movementBonus = 16,
		favoriteFood = "Sunfruit",
		baseHealth = 90,
		baseDamage = 30,
		baseSpeed = 40,
		traits = {"SwiftRunner"},
	},
	{
		id = "stegosaurus" :: DinosaurId,
		displayName = "Stegosaurus (Plated Guardian)",
		rarity = "Uncommon",
		weight = 240,
		eggsPerSecond = 8,
		color = Color3.fromRGB(200, 180, 60),
		modelName = "Stegosaurus",
		growthSeconds = 540,
		mountable = true,
		movementBonus = 6,
		favoriteFood = "Ancient Ferns",
		baseHealth = 160,
		baseDamage = 40,
		baseSpeed = 10,
		traits = {"ArmoredPlates"},
	},
	{
		id = "ankylosaurus" :: DinosaurId,
		displayName = "Ankylosaurus (Armored Tank)",
		rarity = "Rare",
		weight = 140,
		eggsPerSecond = 11,
		color = Color3.fromRGB(110, 90, 70),
		modelName = "Ankylosaurus",
		growthSeconds = 660,
		mountable = true,
		movementBonus = 4,
		favoriteFood = "Palm Leaves",
		baseHealth = 280,
		baseDamage = 28,
		baseSpeed = 9,
		traits = {"ArmoredPlates", "HerbivoreTank"},
	},
	{
		id = "spinosaurus" :: DinosaurId,
		displayName = "Spinosaurus (Sail-Backed River Hunter)",
		rarity = "Legendary",
		weight = 35,
		eggsPerSecond = 48,
		color = Color3.fromRGB(80, 140, 200),
		modelName = "Spinosaurus",
		growthSeconds = 1080,
		mountable = true,
		movementBonus = 13,
		favoriteFood = "Volcanic Meat",
		baseHealth = 200,
		baseDamage = 55,
		baseSpeed = 18,
		traits = {"SemiAquatic", "ApexPredator"},
	},
	{
		id = "parasaurolophus" :: DinosaurId,
		displayName = "Parasaurolophus (Crested Trumpeter)",
		rarity = "Rare",
		weight = 160,
		eggsPerSecond = 22,
		color = Color3.fromRGB(140, 200, 220),
		modelName = "Parasaurolophus",
		growthSeconds = 480,
		mountable = true,
		movementBonus = 10,
		favoriteFood = "Jungle Berries",
		baseHealth = 140,
		baseDamage = 22,
		baseSpeed = 15,
		traits = {"CrestDisplay"},
	},
	{
		id = "dilophosaurus" :: DinosaurId,
		displayName = "Dilophosaurus (Crested Hunter)",
		rarity = "Legendary",
		weight = 25,
		eggsPerSecond = 65,
		color = Color3.fromRGB(180, 80, 200),
		modelName = "Dilophosaurus",
		growthSeconds = 840,
		mountable = true,
		movementBonus = 12,
		favoriteFood = "Volcanic Meat",
		baseHealth = 130,
		baseDamage = 45,
		baseSpeed = 28,
		traits = {"SwiftRunner", "PackHunter"},
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
		dinoId = "velociraptor" :: DinosaurId,  -- Updated
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

GameConfig.BERRY_NODES = { ... } -- keep your original

GameConfig.TRAILS = { ... } -- keep your original

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
	if progress < 0.25 then
		return "Hatchling"
	elseif progress < 0.50 then
		return "Juvenile"
	elseif progress < 0.75 then
		return "Subadult"
	else
		return "Adult"
	end
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
