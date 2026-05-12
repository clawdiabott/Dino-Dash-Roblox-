--!strict

export type DinosaurId = 
	"velociraptor" | "triceratops" | "brachiosaurus" | "tyrannosaurus" | 
	"pteranodon" | "stegosaurus" | "ankylosaurus" | "spinosaurus" | 
	"parasaurolophus" | "dilophosaurus"

export type GrowthStage = "Hatchling" | "Juvenile" | "Subadult" | "Adult"

export type DinosaurTrait = 
	"PackHunter" | "HerbivoreTank" | "ApexPredator" | "SwiftRunner" | 
	"ArmoredPlates" | "SailThermoregulator" | "CrestDisplay" | "SemiAquatic"

export type DinosaurDefinition = {
	id: DinosaurId,
	displayName: string,
	rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary",
	weight: number,
	eggsPerSecond: number,
	color: Color3,
	modelName: string,
	growthSeconds: number,
	mountable: boolean,
	movementBonus: number,
	favoriteFood: string,
	
	-- Realistic stats
	baseHealth: number,
	baseDamage: number,
	baseSpeed: number,
	traits: { DinosaurTrait },
}

export type OwnedDinoRecord = {
	uid: string,
	id: DinosaurId,
	ageSeconds: number,
	bornUnix: number,
	mode: DinoMode,
	colorVariant: string,
	traits: { DinosaurTrait }?,  -- Added for persistence
}

-- Keep all your existing types below for compatibility
export type TrailId = "none" | "leaf-swirl" | "lava-spark" | "cosmic-comet"
export type ZoneId = "starter-valley" | "jungle-grove" | "volcano-ridge" | "ancient-ruins"
export type EggNestId = "starter-egg" | "valley-nest" | "jungle-nest" | "volcano-nest" | "ruins-nest"
export type BerryNodeId = "cave-berry" | "path-berry-a" | "path-berry-b" | "valley-berry" | "jungle-berry"
export type DinoMode = "Following" | "StoredInNest"

export type NestDefinition = {
	level: number,
	upgradeCost: number,
	capacity: number,
	incomeMultiplier: number,
	followSlots: number,
	storedSlots: number,
}

export type TrailDefinition = {
	id: TrailId,
	displayName: string,
	cost: number,
	color: ColorSequence,
}

export type ZoneDefinition = {
	id: ZoneId,
	displayName: string,
	requiredNestLevel: number,
	unlockCost: number,
}

export type EggNestDefinition = {
	id: EggNestId,
	displayName: string,
	zoneId: ZoneId,
	dinoId: DinosaurId?,
	cooldownSeconds: number,
	oneTime: boolean,
}

export type BerryNodeDefinition = {
	id: BerryNodeId,
	displayName: string,
	zoneId: ZoneId,
	berriesGranted: number,
	cooldownSeconds: number,
}

export type PlayerDino = {
	id: DinosaurId,
	count: number,
}

export type PlayerData = {
	schemaVersion: number,
	eggs: number,
	nestLevel: number,
	hatchCount: number,
	dinos: { [DinosaurId]: number },
	ownedTrails: { [TrailId]: boolean },
	equippedTrail: TrailId,
	lastSaveUnix: number,
	starterEggClaimed: boolean,
	followingDinoId: DinosaurId?,
	dinoModes: { [DinosaurId]: DinoMode },
	unlockedZones: { [ZoneId]: boolean },
	nestCooldowns: { [EggNestId]: number },
	berryCooldowns: { [BerryNodeId]: number },
	processedReceipts: { [string]: boolean },
	ownedDinos: { [string]: OwnedDinoRecord },
	nextDinoUid: number,
	activeDinoUid: string?,
	mountedDinoUid: string?,
	berryFood: number,
}

export type PublicOwnedDino = {
	uid: string,
	id: string,
	displayName: string,
	ageSeconds: number,
	growthSeconds: number,
	stage: string,
	mode: string,
	color: Color3,
	mountable: boolean,
	movementBonus: number,
	traits: { DinosaurTrait }?,
}

export type PublicState = {
	eggs: number,
	nestLevel: number,
	nestCapacity: number,
	followSlots: number,
	storedSlots: number,
	incomePerSecond: number,
	hatchCost: number,
	dinos: { [string]: number },
	ownedTrails: { [string]: boolean },
	equippedTrail: string,
	starterEggClaimed: boolean,
	followingDinoId: string?,
	activeDinoUid: string?,
	mountedDinoUid: string?,
	isMounted: boolean,
	berryFood: number,
	ownedDinos: { PublicOwnedDino },
	berryCooldowns: { [string]: number },
	dinoModes: { [string]: string },
	unlockedZones: { [string]: boolean },
	objective: string,
}

return nil
