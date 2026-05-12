--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Types = require(Shared.Types)

type PlayerData = Types.PlayerData
type PublicState = Types.PublicState
type DinosaurId = Types.DinosaurId
type TrailId = Types.TrailId
type ZoneId = Types.ZoneId
type EggNestId = Types.EggNestId
type BerryNodeId = Types.BerryNodeId
type DinoMode = Types.DinoMode
type OwnedDinoRecord = Types.OwnedDinoRecord

local STORE_NAME = "DinoDash_PlayerData_v1"

local PlayerDataService = {}
PlayerDataService.__index = PlayerDataService

export type PlayerDataService = typeof(setmetatable({} :: {
	_store: GlobalDataStore,
	_profiles: { [number]: PlayerData },
	_rng: Random,
}, PlayerDataService))

local function defaultData(): PlayerData
	return {
		schemaVersion = GameConfig.SCHEMA_VERSION,
		eggs = GameConfig.STARTING_EGGS,
		nestLevel = 1,
		hatchCount = 0,
		dinos = {},
		ownedTrails = { none = true },
		equippedTrail = "none",
		lastSaveUnix = os.time(),
		starterEggClaimed = false,
		followingDinoId = nil,
		dinoModes = {},
		unlockedZones = { ["starter-valley"] = true },
		nestCooldowns = {},
		berryCooldowns = {},
		processedReceipts = {},
		ownedDinos = {},
		nextDinoUid = 1,
		activeDinoUid = nil,
		mountedDinoUid = nil,
		berryFood = GameConfig.STARTING_BERRY_FOOD,
	}
end

local function makeOwnedDino(uid: string, dinoId: DinosaurId, ageSeconds: number, mode: DinoMode): OwnedDinoRecord
	return {
		uid = uid,
		id = dinoId,
		ageSeconds = math.max(0, math.floor(ageSeconds)),
		bornUnix = os.time(),
		mode = mode,
		colorVariant = "standard",
	}
end

local function sanitize(raw: any): PlayerData
	local data = defaultData()
	if typeof(raw) ~= "table" then
		return data
	end

	data.schemaVersion = GameConfig.SCHEMA_VERSION
	data.eggs = math.max(0, math.floor(if typeof(raw.eggs) == "number" then raw.eggs else data.eggs))
	data.nestLevel = math.clamp(math.floor(if typeof(raw.nestLevel) == "number" then raw.nestLevel else 1), 1, #GameConfig.NESTS)
	data.hatchCount = math.max(0, math.floor(if typeof(raw.hatchCount) == "number" then raw.hatchCount else 0))
	data.lastSaveUnix = math.floor(if typeof(raw.lastSaveUnix) == "number" then raw.lastSaveUnix else os.time())
	data.starterEggClaimed = raw.starterEggClaimed == true
	data.nextDinoUid = math.max(1, math.floor(if typeof(raw.nextDinoUid) == "number" then raw.nextDinoUid else 1))
	data.berryFood = math.max(0, math.floor(if typeof(raw.berryFood) == "number" then raw.berryFood else GameConfig.STARTING_BERRY_FOOD))

	local ownsAnyDino = false
	local firstOwnedDinoId: DinosaurId? = nil
	if typeof(raw.dinos) == "table" then
		for _, dino in GameConfig.DINOSAURS do
			local amount = raw.dinos[dino.id]
			if typeof(amount) == "number" and amount > 0 then
				data.dinos[dino.id] = math.floor(amount)
				ownsAnyDino = true
				if firstOwnedDinoId == nil then
					firstOwnedDinoId = dino.id
				end
			end
		end
	end
	if ownsAnyDino and not data.starterEggClaimed then
		-- Migration for pre-tycoon test profiles that already hatched a dino through the old Hatch button.
		data.starterEggClaimed = true
	end

	if typeof(raw.ownedTrails) == "table" then
		for _, trail in GameConfig.TRAILS do
			if raw.ownedTrails[trail.id] == true then
				data.ownedTrails[trail.id] = true
			end
		end
	end

	if typeof(raw.equippedTrail) == "string" and data.ownedTrails[raw.equippedTrail :: TrailId] == true then
		data.equippedTrail = raw.equippedTrail :: TrailId
	end

	if typeof(raw.unlockedZones) == "table" then
		for _, zone in GameConfig.ZONES do
			if raw.unlockedZones[zone.id] == true then
				data.unlockedZones[zone.id] = true
			end
		end
	end
	data.unlockedZones["starter-valley"] = true

	if typeof(raw.nestCooldowns) == "table" then
		for _, eggNest in GameConfig.EGG_NESTS do
			local cooldown = raw.nestCooldowns[eggNest.id]
			if typeof(cooldown) == "number" then
				data.nestCooldowns[eggNest.id] = math.max(0, math.floor(cooldown))
			end
		end
	end

	if typeof(raw.berryCooldowns) == "table" then
		for _, berryNode in GameConfig.BERRY_NODES do
			local cooldown = raw.berryCooldowns[berryNode.id]
			if typeof(cooldown) == "number" then
				data.berryCooldowns[berryNode.id] = math.max(0, math.floor(cooldown))
			end
		end
	end

	if typeof(raw.processedReceipts) == "table" then
		local copied = 0
		for purchaseId, processed in raw.processedReceipts do
			if typeof(purchaseId) == "string" and processed == true and #purchaseId <= 128 then
				data.processedReceipts[purchaseId] = true
				copied += 1
				if copied >= 250 then
					break
				end
			end
		end
	end

	if typeof(raw.ownedDinos) == "table" then
		for uid, record in raw.ownedDinos do
			if typeof(uid) == "string" and typeof(record) == "table" and typeof(record.id) == "string" then
				local dinoId = record.id :: DinosaurId
				if GameConfig.getDinosaur(dinoId) ~= nil then
					local mode: DinoMode = if record.mode == "StoredInNest" then "StoredInNest" else "Following"
					local ageSeconds = if typeof(record.ageSeconds) == "number" then record.ageSeconds else 0
					data.ownedDinos[uid] = makeOwnedDino(uid, dinoId, ageSeconds, mode)
					ownsAnyDino = true
					if firstOwnedDinoId == nil then
						firstOwnedDinoId = dinoId
					end
				end
			end
		end
	end

	if next(data.ownedDinos) ~= nil then
		data.dinos = {}
		for _, record in data.ownedDinos do
			data.dinos[record.id] = (data.dinos[record.id] or 0) + 1
		end
	end

	if next(data.ownedDinos) == nil then
		for _, dino in GameConfig.DINOSAURS do
			local amount = data.dinos[dino.id] or 0
			for _index = 1, amount do
				local uid = `dino_{data.nextDinoUid}`
				data.nextDinoUid += 1
				data.ownedDinos[uid] = makeOwnedDino(uid, dino.id, if dino.id == "starter-raptor" then 45 else 0, "Following")
			end
		end
	end

	if typeof(raw.activeDinoUid) == "string" and data.ownedDinos[raw.activeDinoUid] ~= nil then
		data.activeDinoUid = raw.activeDinoUid
	end
	if data.activeDinoUid == nil then
		for uid, _record in data.ownedDinos do
			data.activeDinoUid = uid
			break
		end
	end

	if typeof(raw.mountedDinoUid) == "string" and data.ownedDinos[raw.mountedDinoUid] ~= nil then
		data.mountedDinoUid = raw.mountedDinoUid
	end

	if typeof(raw.dinoModes) == "table" then
		for _, dino in GameConfig.DINOSAURS do
			local mode = raw.dinoModes[dino.id]
			if (mode == "Following" or mode == "StoredInNest") and (data.dinos[dino.id] or 0) > 0 then
				data.dinoModes[dino.id] = mode :: DinoMode
			end
		end
	end

	if typeof(raw.followingDinoId) == "string" and (data.dinos[raw.followingDinoId :: DinosaurId] or 0) > 0 then
		data.followingDinoId = raw.followingDinoId :: DinosaurId
		data.dinoModes[data.followingDinoId :: DinosaurId] = "Following"
	elseif firstOwnedDinoId ~= nil then
		data.followingDinoId = firstOwnedDinoId
		data.dinoModes[firstOwnedDinoId] = "Following"
	end

	return data
end

local function dataKey(player: Player): string
	return `player_{player.UserId}`
end

local function retry<T>(callback: () -> T): (boolean, T?)
	local lastResult: T? = nil
	for attempt = 1, 4 do
		local ok, result = pcall(callback)
		if ok then
			lastResult = result
			return true, lastResult
		end
		task.wait(0.5 * attempt)
	end
	return false, lastResult
end

local function countOwnedDinos(data: PlayerData): number
	local ownedCount = 0
	for _, _record in data.ownedDinos do
		ownedCount += 1
	end
	if ownedCount > 0 then
		return ownedCount
	end
	for _, amount in data.dinos do
		ownedCount += amount
	end
	return ownedCount
end

function PlayerDataService.new(): PlayerDataService
	return setmetatable({
		_store = DataStoreService:GetDataStore(STORE_NAME),
		_profiles = {},
		_rng = Random.new(),
	}, PlayerDataService)
end

function PlayerDataService.load(self: PlayerDataService, player: Player): PlayerData
	local ok, raw = retry(function()
		return self._store:GetAsync(dataKey(player))
	end)

	local data = if ok then sanitize(raw) else defaultData()
	local offlineSeconds = math.clamp(os.time() - data.lastSaveUnix, 0, GameConfig.MAX_OFFLINE_SECONDS)
	if offlineSeconds > 0 then
		data.eggs += math.floor(self:getIncomePerSecondFromData(data) * offlineSeconds * 0.25)
	end

	self._profiles[player.UserId] = data
	return data
end

function PlayerDataService.save(self: PlayerDataService, player: Player): boolean
	local data = self._profiles[player.UserId]
	if data == nil then
		return true
	end
	data.lastSaveUnix = os.time()

	local ok = retry(function()
		self._store:UpdateAsync(dataKey(player), function(_old: any)
			return data
		end)
		return true
	end)
	return ok
end

function PlayerDataService.unload(self: PlayerDataService, player: Player): ()
	self:save(player)
	self._profiles[player.UserId] = nil
end

function PlayerDataService.get(self: PlayerDataService, player: Player): PlayerData?
	return self._profiles[player.UserId]
end

function PlayerDataService.getIncomePerSecondFromData(_self: PlayerDataService, data: PlayerData): number
	local income = 0
	for _, dino in GameConfig.DINOSAURS do
		income += (data.dinos[dino.id] or 0) * dino.eggsPerSecond
	end
	return income * GameConfig.getNest(data.nestLevel).incomeMultiplier
end

function PlayerDataService.getIncomePerSecond(self: PlayerDataService, player: Player): number
	local data = self:get(player)
	if data == nil then
		return 0
	end
	return self:getIncomePerSecondFromData(data)
end

function PlayerDataService.addEggs(self: PlayerDataService, player: Player, amount: number): ()
	local data = self:get(player)
	if data == nil then
		return
	end
	data.eggs = math.max(0, math.floor(data.eggs + amount))
end

function PlayerDataService.createOwnedDino(_self: PlayerDataService, data: PlayerData, dinoId: DinosaurId, startingAgeSeconds: number?): string
	local uid = `dino_{data.nextDinoUid}`
	data.nextDinoUid += 1
	local record = makeOwnedDino(uid, dinoId, startingAgeSeconds or 0, "Following")
	data.ownedDinos[uid] = record
	data.dinos[dinoId] = (data.dinos[dinoId] or 0) + 1
	data.activeDinoUid = uid
	data.followingDinoId = dinoId
	data.dinoModes[dinoId] = "Following"
	data.mountedDinoUid = nil
	return uid
end

function PlayerDataService.growDinos(self: PlayerDataService, player: Player, deltaSeconds: number): ()
	local data = self:get(player)
	if data == nil then
		return
	end
	for _, record in data.ownedDinos do
		record.ageSeconds += deltaSeconds
	end
end

function PlayerDataService.getActiveDino(self: PlayerDataService, player: Player): OwnedDinoRecord?
	local data = self:get(player)
	if data == nil or data.activeDinoUid == nil then
		return nil
	end
	return data.ownedDinos[data.activeDinoUid]
end

function PlayerDataService.feedActiveDino(self: PlayerDataService, player: Player): (boolean, string)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading."
	end
	if data.activeDinoUid == nil then
		return false, "Hatch a dinosaur before feeding."
	end
	local record = data.ownedDinos[data.activeDinoUid]
	if record == nil then
		return false, "Choose a dinosaur to feed."
	end
	if data.berryFood <= 0 then
		return false, "You need more dino snacks. Explore berry bushes soon."
	end
	local dino = GameConfig.getDinosaur(record.id)
	if dino == nil then
		return false, "That dinosaur is missing from the catalog."
	end
	data.berryFood -= 1
	record.ageSeconds = math.min(dino.growthSeconds, record.ageSeconds + GameConfig.FEED_GROWTH_SECONDS)
	local stage = GameConfig.getGrowthStage(record.ageSeconds, dino.growthSeconds)
	return true, `{dino.displayName} loved the {dino.favoriteFood}! Growth stage: {stage}.`
end

function PlayerDataService.toggleMount(self: PlayerDataService, player: Player): (boolean, string, number)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading.", 16
	end
	if data.mountedDinoUid ~= nil then
		data.mountedDinoUid = nil
		return true, "You hopped off your dinosaur.", 16
	end
	if data.activeDinoUid == nil then
		return false, "Hatch a dinosaur before mounting.", 16
	end
	local record = data.ownedDinos[data.activeDinoUid]
	if record == nil then
		return false, "Choose a dinosaur to ride.", 16
	end
	local dino = GameConfig.getDinosaur(record.id)
	if dino == nil or not dino.mountable then
		return false, "This dinosaur cannot be mounted.", 16
	end
	local stage = GameConfig.getGrowthStage(record.ageSeconds, dino.growthSeconds)
	if stage ~= "Adult" then
		return false, `Raise {dino.displayName} to Adult before riding.`, 16
	end
	data.mountedDinoUid = record.uid
	return true, `Mounted {dino.displayName}!`, 16 + dino.movementBonus
end

function PlayerDataService.getWalkSpeed(self: PlayerDataService, player: Player): number
	local data = self:get(player)
	if data == nil or data.mountedDinoUid == nil then
		return 16
	end
	local record = data.ownedDinos[data.mountedDinoUid]
	if record == nil then
		data.mountedDinoUid = nil
		return 16
	end
	local dino = GameConfig.getDinosaur(record.id)
	if dino == nil or GameConfig.getGrowthStage(record.ageSeconds, dino.growthSeconds) ~= "Adult" then
		data.mountedDinoUid = nil
		return 16
	end
	return 16 + dino.movementBonus
end

function PlayerDataService.collectBerryNode(self: PlayerDataService, player: Player, berryNodeId: BerryNodeId): (boolean, string)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading."
	end
	local berryNode = GameConfig.getBerryNode(berryNodeId)
	if berryNode == nil then
		return false, "That berry bush does not exist."
	end
	if data.unlockedZones[berryNode.zoneId] ~= true then
		return false, "That berry patch is in a locked zone."
	end
	local now = os.time()
	local readyAt = data.berryCooldowns[berryNodeId] or 0
	if readyAt > now then
		return false, `That bush needs {readyAt - now}s to regrow berries.`
	end
	data.berryFood += berryNode.berriesGranted
	data.berryCooldowns[berryNodeId] = now + berryNode.cooldownSeconds
	return true, `Collected {berryNode.berriesGranted} snacks from {berryNode.displayName}.`
end

function PlayerDataService.hasProcessedReceipt(self: PlayerDataService, player: Player, purchaseId: string): boolean
	local data = self:get(player)
	if data == nil then
		return false
	end
	return data.processedReceipts[purchaseId] == true
end

function PlayerDataService.grantReceiptEggs(self: PlayerDataService, player: Player, purchaseId: string, eggs: number): boolean
	local data = self:get(player)
	if data == nil then
		return false
	end
	if data.processedReceipts[purchaseId] == true then
		return true
	end

	local previousEggs = data.eggs
	data.eggs = math.max(0, math.floor(data.eggs + eggs))
	data.processedReceipts[purchaseId] = true
	if self:save(player) then
		return true
	end

	data.eggs = previousEggs
	data.processedReceipts[purchaseId] = nil
	return false
end

function PlayerDataService.collectEggNest(self: PlayerDataService, player: Player, nestId: EggNestId): (boolean, string, DinosaurId?)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading.", nil
	end

	local eggNest = GameConfig.getEggNest(nestId)
	if eggNest == nil then
		return false, "That egg nest does not exist.", nil
	end
	if data.unlockedZones[eggNest.zoneId] ~= true then
		return false, "That zone is locked. Upgrade your nest and open the gate first.", nil
	end
	if eggNest.id == "starter-egg" and data.starterEggClaimed then
		return false, "Your starter egg already hatched. Explore Starter Valley for more nests.", nil
	end
	if countOwnedDinos(data) >= GameConfig.getNest(data.nestLevel).capacity then
		return false, "Your nest is full. Upgrade it before collecting more dinos.", nil
	end

	local now = os.time()
	local cooldownReadyAt = data.nestCooldowns[nestId] or 0
	if cooldownReadyAt > now then
		return false, `This nest needs {cooldownReadyAt - now}s to settle.`, nil
	end

	local dino = if eggNest.dinoId ~= nil then GameConfig.getDinosaur(eggNest.dinoId) else GameConfig.rollDinosaur(self._rng)
	if dino == nil then
		return false, "No dinosaur could hatch from that egg.", nil
	end

	self:createOwnedDino(data, dino.id, if eggNest.id == "starter-egg" then 45 else 0)
	data.hatchCount += 1

	if eggNest.id == "starter-egg" then
		data.starterEggClaimed = true
		data.eggs += 15
	else
		data.nestCooldowns[nestId] = now + eggNest.cooldownSeconds
	end

	return true, `Your {eggNest.displayName} hatched into {dino.displayName}!`, dino.id
end

function PlayerDataService.setDinoMode(self: PlayerDataService, player: Player, dinoId: DinosaurId, mode: DinoMode): (boolean, string)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading."
	end
	local dino = GameConfig.getDinosaur(dinoId)
	if dino == nil or (data.dinos[dinoId] or 0) <= 0 then
		return false, "You do not own that dinosaur yet."
	end

	local selectedUid: string? = nil
	for uid, record in data.ownedDinos do
		if record.id == dinoId then
			selectedUid = uid
			break
		end
	end
	if selectedUid == nil then
		return false, "That dinosaur needs to hatch again before it can follow you."
	end

	local record = data.ownedDinos[selectedUid]
	if mode == "Following" then
		data.activeDinoUid = selectedUid
		data.followingDinoId = dinoId
		data.dinoModes[dinoId] = "Following"
		record.mode = "Following"
		return true, `{dino.displayName} is following you.`
	end
	if data.followingDinoId == dinoId then
		data.followingDinoId = nil
	end
	if data.activeDinoUid == selectedUid then
		data.activeDinoUid = nil
	end
	if data.mountedDinoUid == selectedUid then
		data.mountedDinoUid = nil
	end
	record.mode = "StoredInNest"
	data.dinoModes[dinoId] = "StoredInNest"
	return true, `{dino.displayName} is resting in your nest cave.`
end

function PlayerDataService.unlockZone(self: PlayerDataService, player: Player, zoneId: ZoneId): (boolean, string)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading."
	end
	local zone = GameConfig.getZone(zoneId)
	if zone == nil then
		return false, "Unknown zone."
	end
	if data.unlockedZones[zoneId] == true then
		return false, `{zone.displayName} is already unlocked.`
	end
	if data.nestLevel < zone.requiredNestLevel then
		return false, `Upgrade your nest to level {zone.requiredNestLevel} to unlock {zone.displayName}.`
	end
	if data.eggs < zone.unlockCost then
		return false, `You need {zone.unlockCost} eggs to unlock {zone.displayName}.`
	end
	data.eggs -= zone.unlockCost
	data.unlockedZones[zoneId] = true
	return true, `{zone.displayName} unlocked! New egg nests are open.`
end

function PlayerDataService.hatch(self: PlayerDataService, player: Player): (boolean, string, string?)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading.", nil
	end
	if not data.starterEggClaimed then
		return false, "Collect the glowing starter egg beside your nest cave first.", nil
	end

	local nest = GameConfig.getNest(data.nestLevel)
	if countOwnedDinos(data) >= nest.capacity then
		return false, "Your nest is full. Upgrade it before hatching more dinos.", nil
	end

	local cost = GameConfig.getHatchCost(data.hatchCount)
	if data.eggs < cost then
		return false, "Not enough eggs to hatch. Let your dinos work or find egg nests.", nil
	end

	data.eggs -= cost
	data.hatchCount += 1
	local dino = GameConfig.rollDinosaur(self._rng)
	self:createOwnedDino(data, dino.id, 0)
	return true, `Hatched {dino.displayName}! Feed it at your nest to grow it.`, dino.id
end

function PlayerDataService.upgradeNest(self: PlayerDataService, player: Player): (boolean, string)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading."
	end
	local nextNest = GameConfig.getNextNest(data.nestLevel)
	if nextNest == nil then
		return false, "Your nest is already max level."
	end
	if data.eggs < nextNest.upgradeCost then
		return false, "Not enough eggs to upgrade your nest."
	end
	data.eggs -= nextNest.upgradeCost
	data.nestLevel = nextNest.level
	return true, `Nest upgraded to level {nextNest.level}! Your cave expanded.`
end

function PlayerDataService.buyTrail(self: PlayerDataService, player: Player, trailId: TrailId): (boolean, string)
	local data = self:get(player)
	if data == nil then
		return false, "Data is still loading."
	end
	local trail = GameConfig.getTrail(trailId)
	if trail == nil then
		return false, "Invalid trail."
	end
	if data.ownedTrails[trailId] == true then
		data.equippedTrail = trailId
		return true, `Equipped {trail.displayName}.`
	end
	if data.eggs < trail.cost then
		return false, "Not enough eggs for that trail."
	end
	data.eggs -= trail.cost
	data.ownedTrails[trailId] = true
	data.equippedTrail = trailId
	return true, `Unlocked {trail.displayName}!`
end

function PlayerDataService.getObjective(self: PlayerDataService, player: Player): string
	local data = self:get(player)
	if data == nil then
		return "Loading your nest cave..."
	end
	if not data.starterEggClaimed then
		return "Collect the glowing starter egg beside your nest cave."
	end
	if countOwnedDinos(data) == 1 then
		local activeRecord = if data.activeDinoUid ~= nil then data.ownedDinos[data.activeDinoUid] else nil
		if activeRecord ~= nil then
			local activeDino = GameConfig.getDinosaur(activeRecord.id)
			if activeDino ~= nil and GameConfig.getGrowthStage(activeRecord.ageSeconds, activeDino.growthSeconds) ~= "Adult" then
				if data.berryFood <= 0 then
					return "Gather berries from glowing bushes, then feed your baby dinosaur."
				end
				return "Feed your baby dinosaur at the nest station to grow it into a rideable adult."
			end
		end
		return "Your Starter Raptor is ready! Mount up or explore the valley for another egg nest."
	end
	if data.nestLevel < 2 then
		return "Earn 100 eggs and upgrade your nest to open Jungle Grove."
	end
	if data.unlockedZones["jungle-grove"] ~= true then
		return "Open the Jungle Grove gate to find rarer egg nests."
	end
	return "Explore unlocked zones, find egg nests, and grow your dino cave."
end

function PlayerDataService.toPublicState(self: PlayerDataService, player: Player): PublicState?
	local data = self:get(player)
	if data == nil then
		return nil
	end
	local publicDinos: { [string]: number } = {}
	for _, dino in GameConfig.DINOSAURS do
		publicDinos[dino.id] = data.dinos[dino.id] or 0
	end
	local ownedTrails: { [string]: boolean } = {}
	for _, trail in GameConfig.TRAILS do
		ownedTrails[trail.id] = data.ownedTrails[trail.id] == true
	end
	local dinoModes: { [string]: string } = {}
	for _, dino in GameConfig.DINOSAURS do
		dinoModes[dino.id] = data.dinoModes[dino.id] or "StoredInNest"
	end
	local unlockedZones: { [string]: boolean } = {}
	for _, zone in GameConfig.ZONES do
		unlockedZones[zone.id] = data.unlockedZones[zone.id] == true
	end
	local berryCooldowns: { [string]: number } = {}
	local now = os.time()
	for _, berryNode in GameConfig.BERRY_NODES do
		berryCooldowns[berryNode.id] = math.max(0, (data.berryCooldowns[berryNode.id] or 0) - now)
	end
	local ownedDinos: { Types.PublicOwnedDino } = {}
	for _, record in data.ownedDinos do
		local dino = GameConfig.getDinosaur(record.id)
		if dino ~= nil then
			table.insert(ownedDinos, {
				uid = record.uid,
				id = record.id,
				displayName = dino.displayName,
				ageSeconds = record.ageSeconds,
				growthSeconds = dino.growthSeconds,
				stage = GameConfig.getGrowthStage(record.ageSeconds, dino.growthSeconds),
				mode = record.mode,
				color = dino.color,
				mountable = dino.mountable,
				movementBonus = dino.movementBonus,
			})
		end
	end
	local nest = GameConfig.getNest(data.nestLevel)
	return {
		eggs = data.eggs,
		nestLevel = data.nestLevel,
		nestCapacity = nest.capacity,
		followSlots = nest.followSlots,
		storedSlots = nest.storedSlots,
		incomePerSecond = self:getIncomePerSecond(player),
		hatchCost = GameConfig.getHatchCost(data.hatchCount),
		dinos = publicDinos,
		ownedTrails = ownedTrails,
		equippedTrail = data.equippedTrail,
		starterEggClaimed = data.starterEggClaimed,
		followingDinoId = data.followingDinoId,
		activeDinoUid = data.activeDinoUid,
		mountedDinoUid = data.mountedDinoUid,
		isMounted = data.mountedDinoUid ~= nil,
		berryFood = data.berryFood,
		ownedDinos = ownedDinos,
		berryCooldowns = berryCooldowns,
		dinoModes = dinoModes,
		unlockedZones = unlockedZones,
		objective = self:getObjective(player),
	}
end

function PlayerDataService.createLeaderstats(self: PlayerDataService, player: Player): ()
	local existing = player:FindFirstChild("leaderstats")
	if existing ~= nil and existing:IsA("Folder") then
		return
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local eggs = Instance.new("IntValue")
	eggs.Name = "Eggs"
	eggs.Parent = leaderstats

	local nest = Instance.new("IntValue")
	nest.Name = "Nest"
	nest.Parent = leaderstats

	task.spawn(function()
		while player.Parent == Players do
			local data = self:get(player)
			if data ~= nil then
				eggs.Value = math.floor(data.eggs)
				nest.Value = data.nestLevel
			end
			task.wait(2)
		end
	end)
end

return PlayerDataService
