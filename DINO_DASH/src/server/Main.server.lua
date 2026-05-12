--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteValidator = require(Shared.Security.RemoteValidator)
local ProductConfig = require(Shared.Monetization.ProductConfig)
local GameConfig = require(Shared.GameConfig)

local Services = script.Parent:WaitForChild("Services")
local NetworkService = require(Services:WaitForChild("NetworkService"))
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local ReceiptProcessor = require(Services:WaitForChild("ReceiptProcessor"))
local WorldService = require(Services:WaitForChild("WorldService"))

local networkService = NetworkService.new()
local playerDataService = PlayerDataService.new()
local receiptProcessor = ReceiptProcessor.new(playerDataService)

local actionEvent = networkService:getEvent("Action")
local stateEvent = networkService:getEvent("State")
local requestStateFunction = networkService:getFunction("RequestState")

local playersInitialized: { [number]: boolean } = {}

local function pushState(player: Player, message: string?, effect: { [string]: any }?): ()
	local state = playerDataService:toPublicState(player)
	if state ~= nil then
		stateEvent:FireClient(player, {
			state = state,
			message = message,
			effect = effect,
		})
	end
end

local function hatchEffect(dinoId: string?): { [string]: any }?
	if dinoId == nil then
		return nil
	end
	local dino = GameConfig.getDinosaur(dinoId :: any)
	if dino == nil then
		return nil
	end
	return {
		kind = "hatchReveal",
		dinoId = dino.id,
		displayName = dino.displayName,
		rarity = dino.rarity,
	}
end

local function applyMovement(player: Player, walkSpeed: number): ()
	local character = player.Character
	if character == nil then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	humanoid.WalkSpeed = walkSpeed
end

local function applyTrail(player: Player): ()
	local data = playerDataService:get(player)
	if data == nil then
		return
	end
	local character = player.Character
	if character == nil then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return
	end
	local oldTrail = root:FindFirstChild("DinoDashTrail")
	if oldTrail ~= nil then
		oldTrail:Destroy()
	end
	local oldA0 = root:FindFirstChild("DinoDashTrailA0")
	if oldA0 ~= nil then
		oldA0:Destroy()
	end
	local oldA1 = root:FindFirstChild("DinoDashTrailA1")
	if oldA1 ~= nil then
		oldA1:Destroy()
	end

	local trailConfig = GameConfig.getTrail(data.equippedTrail)
	if trailConfig == nil or trailConfig.id == "none" then
		return
	end
	local a0 = Instance.new("Attachment")
	a0.Name = "DinoDashTrailA0"
	a0.Position = Vector3.new(0, 1.5, 0.7)
	a0.Parent = root
	local a1 = Instance.new("Attachment")
	a1.Name = "DinoDashTrailA1"
	a1.Position = Vector3.new(0, -1.5, 0.7)
	a1.Parent = root
	local trail = Instance.new("Trail")
	trail.Name = "DinoDashTrail"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = trailConfig.color
	trail.Lifetime = 0.7
	trail.MinLength = 0.1
	trail.Parent = root
end

local actionSchema = {
	action = { type = "string", required = true, maxLength = 32 },
	trailId = { type = "string", required = false, maxLength = 32 },
	nestId = { type = "string", required = false, maxLength = 32 },
	berryNodeId = { type = "string", required = false, maxLength = 32 },
	zoneId = { type = "string", required = false, maxLength = 32 },
	dinoId = { type = "string", required = false, maxLength = 32 },
	mode = { type = "string", required = false, maxLength = 32 },
}

local function getRootPosition(player: Player): Vector3?
	local character = player.Character
	if character == nil then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return nil
	end
	return root.Position
end

local function isPlayerNear(player: Player, targetPosition: Vector3?, maxDistance: number): boolean
	local rootPosition = getRootPosition(player)
	if rootPosition == nil or targetPosition == nil then
		return false
	end
	return (rootPosition - targetPosition).Magnitude <= maxDistance
end

local function collectEggNest(player: Player, nestId: string): ()
	if not isPlayerNear(player, WorldService.getEggNestPosition(nestId), 30) then
		pushState(player, "Move closer to that egg nest first.")
		return
	end
	local ok, message, dinoId = playerDataService:collectEggNest(player, nestId :: any)
	pushState(player, if ok then `CRACK! {message}` else message, if ok then hatchEffect(dinoId) else nil)
end

local function unlockZone(player: Player, zoneId: string): ()
	if not isPlayerNear(player, WorldService.getZoneGatePosition(zoneId), 38) then
		pushState(player, "Stand at that gate to unlock it.")
		return
	end
	local _ok, message = playerDataService:unlockZone(player, zoneId :: any)
	pushState(player, message)
end

local function collectBerryNode(player: Player, berryNodeId: string): ()
	if not isPlayerNear(player, WorldService.getBerryNodePosition(berryNodeId), 28) then
		pushState(player, "Move closer to that berry bush first.")
		return
	end
	local _ok, message = playerDataService:collectBerryNode(player, berryNodeId :: any)
	pushState(player, message)
end

local function feedActiveDinoAtStation(player: Player): ()
	if not isPlayerNear(player, WorldService.getFeedStationPosition(), 24) then
		pushState(player, "Stand beside the feed station to feed your dinosaur.")
		return
	end
	local ok, message = playerDataService:feedActiveDino(player)
	pushState(player, message, if ok then { kind = "feedPulse" } else nil)
end

actionEvent.OnServerEvent:Connect(function(player: Player, payload: any)
	if not networkService:checkLimit(player, "Action") then
		pushState(player, "Slow down a little.")
		return
	end
	local valid, reason = RemoteValidator.validateTable(payload, actionSchema)
	if not valid then
		warn(`Rejected malformed payload from {player.UserId}: {reason or "unknown"}`)
		return
	end

	local action = payload.action :: string
	if action == "hatch" then
		local ok, message, dinoId = playerDataService:hatch(player)
		pushState(player, message, if ok then hatchEffect(dinoId) else nil)
	elseif action == "collectEggNest" then
		if typeof(payload.nestId) == "string" then
			collectEggNest(player, payload.nestId)
		else
			pushState(player, "Choose a real egg nest.")
		end
	elseif action == "collectBerryNode" then
		if typeof(payload.berryNodeId) == "string" then
			collectBerryNode(player, payload.berryNodeId)
		else
			pushState(player, "Choose a real berry bush.")
		end
	elseif action == "setDinoMode" then
		if typeof(payload.dinoId) == "string" and (payload.mode == "Following" or payload.mode == "StoredInNest") then
			local _ok, message = playerDataService:setDinoMode(player, payload.dinoId :: any, payload.mode :: any)
			pushState(player, message)
		else
			pushState(player, "Choose a dinosaur you own.")
		end
	elseif action == "unlockZone" then
		if typeof(payload.zoneId) == "string" then
			unlockZone(player, payload.zoneId)
		else
			pushState(player, "Choose a real zone gate.")
		end
	elseif action == "upgradeNest" then
		local _ok, message = playerDataService:upgradeNest(player)
		pushState(player, message)
	elseif action == "feedActiveDino" then
		feedActiveDinoAtStation(player)
	elseif action == "toggleMount" then
		local _ok, message, walkSpeed = playerDataService:toggleMount(player)
		applyMovement(player, walkSpeed)
		pushState(player, message)
	elseif action == "buyTrail" then
		local ok, message = playerDataService:buyTrail(player, payload.trailId :: any)
		if ok then
			applyTrail(player)
		end
		pushState(player, message)
	elseif action == "buySmallEggPack" then
		local productId = ProductConfig.DEVELOPER_PRODUCTS.SmallEggPack.productId
		if productId > 0 then
			MarketplaceService:PromptProductPurchase(player, productId)
		else
			pushState(player, "Egg pack product ID is not configured yet.")
		end
	elseif action == "buyMegaEggPack" then
		local productId = ProductConfig.DEVELOPER_PRODUCTS.MegaEggPack.productId
		if productId > 0 then
			MarketplaceService:PromptProductPurchase(player, productId)
		else
			pushState(player, "Mega pack product ID is not configured yet.")
		end
	else
		pushState(player, "Unknown action.")
	end
end)

requestStateFunction.OnServerInvoke = function(player: Player): any
	if not networkService:checkLimit(player, "RequestState") then
		return nil
	end
	if playerDataService:get(player) == nil then
		playerDataService:load(player)
		playerDataService:createLeaderstats(player)
		playersInitialized[player.UserId] = true
	end
	return playerDataService:toPublicState(player)
end

MarketplaceService.ProcessReceipt = function(receiptInfo: { [string]: any }): Enum.ProductPurchaseDecision
	return receiptProcessor:processReceipt(receiptInfo)
end

WorldService.build()
WorldService.connectInteractions(collectEggNest, unlockZone, collectBerryNode, feedActiveDinoAtStation)

local function initializePlayer(player: Player): ()
	if playersInitialized[player.UserId] == true then
		pushState(player, "Welcome back to your dino nest!")
		return
	end

	playersInitialized[player.UserId] = true
	playerDataService:load(player)
	playerDataService:createLeaderstats(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		applyMovement(player, playerDataService:getWalkSpeed(player))
		applyTrail(player)
	end)
	pushState(player, "Welcome to your dino nest cave! Collect the glowing starter egg.")
end

Players.PlayerAdded:Connect(function(player: Player)
	initializePlayer(player)
end)

for _, player in Players:GetPlayers() do
	task.spawn(initializePlayer, player)
end

Players.PlayerRemoving:Connect(function(player: Player)
	playersInitialized[player.UserId] = nil
	playerDataService:unload(player)
end)

task.spawn(function()
	while true do
		task.wait(GameConfig.INCOME_TICK_SECONDS)
		for _, player in Players:GetPlayers() do
			playerDataService:growDinos(player, GameConfig.INCOME_TICK_SECONDS)
			local income = playerDataService:getIncomePerSecond(player)
			if income > 0 then
				playerDataService:addEggs(player, income * GameConfig.INCOME_TICK_SECONDS)
			end
			pushState(player, nil)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(GameConfig.AUTOSAVE_SECONDS)
		for _, player in Players:GetPlayers() do
			playerDataService:save(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		playerDataService:save(player)
	end
end)
