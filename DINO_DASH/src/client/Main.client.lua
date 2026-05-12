--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("DinoDashRemotes")
local actionEvent = remotes:WaitForChild("Action") :: RemoteEvent
local stateEvent = remotes:WaitForChild("State") :: RemoteEvent
local requestState = remotes:WaitForChild("RequestState") :: RemoteFunction
local dinoModelsFolder = ReplicatedStorage:WaitForChild("DinoDashAssets"):WaitForChild("DinoModels")

local gui = Instance.new("ScreenGui")
gui.Name = "DinoDashHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0)
root.Position = UDim2.fromScale(0.5, 0.02)
root.Size = UDim2.new(0.92, 0, 0, 156)
root.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
root.BackgroundTransparency = 0.18
root.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(310, 138)
sizeConstraint.MaxSize = Vector2.new(980, 168)
sizeConstraint.Parent = root

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = root

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = root

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.BackgroundTransparency = 1
stats.Position = UDim2.fromOffset(0, 0)
stats.Size = UDim2.new(1, 0, 0, 28)
stats.Font = Enum.Font.GothamBold
stats.TextColor3 = Color3.fromRGB(250, 204, 21)
stats.TextScaled = true
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.Text = "Loading your dino nest..."
stats.Parent = root

local objective = Instance.new("TextLabel")
objective.Name = "Objective"
objective.BackgroundTransparency = 1
objective.Position = UDim2.fromOffset(0, 28)
objective.Size = UDim2.new(1, 0, 0, 28)
objective.Font = Enum.Font.GothamMedium
objective.TextColor3 = Color3.fromRGB(226, 232, 240)
objective.TextScaled = true
objective.TextXAlignment = Enum.TextXAlignment.Left
objective.Text = "Objective: collect your first egg."
objective.Parent = root

local buttonRow = Instance.new("Frame")
buttonRow.Name = "Buttons"
buttonRow.BackgroundTransparency = 1
buttonRow.Position = UDim2.fromOffset(0, 64)
buttonRow.Size = UDim2.new(1, 0, 0, 38)
buttonRow.Parent = root

local list = Instance.new("UIListLayout")
list.FillDirection = Enum.FillDirection.Horizontal
list.HorizontalAlignment = Enum.HorizontalAlignment.Left
list.VerticalAlignment = Enum.VerticalAlignment.Center
list.Padding = UDim.new(0, 8)
list.Parent = buttonRow

local function makeButton(label: string, color: Color3): TextButton
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 112, 1, 0)
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.Text = label
	button.AutoButtonColor = true
	button.Parent = buttonRow
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = button
	return button
end

local hatchButton = makeButton("Hatch", Color3.fromRGB(34, 197, 94))
local upgradeButton = makeButton("Upgrade Nest", Color3.fromRGB(245, 158, 11))
local dinoModeButton = makeButton("Store Dino", Color3.fromRGB(59, 130, 246))
local valleyNestButton = makeButton("Starter Egg", Color3.fromRGB(20, 184, 166))
local feedButton = makeButton("Feed Dino", Color3.fromRGB(132, 204, 22))
local berryButton = makeButton("Berries", Color3.fromRGB(244, 63, 94))
local mountButton = makeButton("Mount", Color3.fromRGB(168, 85, 247))
local dexButton = makeButton("DinoDex", Color3.fromRGB(14, 165, 233))

local dinoInfo = Instance.new("TextLabel")
dinoInfo.Name = "DinoInfo"
dinoInfo.BackgroundTransparency = 1
dinoInfo.Position = UDim2.fromOffset(0, 108)
dinoInfo.Size = UDim2.new(1, 0, 0, 28)
dinoInfo.Font = Enum.Font.GothamMedium
dinoInfo.TextColor3 = Color3.fromRGB(190, 242, 100)
dinoInfo.TextScaled = true
dinoInfo.TextXAlignment = Enum.TextXAlignment.Left
dinoInfo.Text = "DinoDex: hatch a starter dino."
dinoInfo.Parent = root

local hasLoadedState = false
local latestState: any = nil
local currentPet: Model? = nil
local dexOpen = false

local berryNodePositions: { [string]: Vector3 } = {
	["cave-berry"] = Vector3.new(-36, 12, 52),
	["path-berry-a"] = Vector3.new(-62, 12, 126),
	["path-berry-b"] = Vector3.new(48, 12, 176),
	["valley-berry"] = Vector3.new(144, 12, 92),
	["jungle-berry"] = Vector3.new(0, 12, 330),
}

local dexPanel = Instance.new("Frame")
dexPanel.Name = "DinoDexPanel"
dexPanel.AnchorPoint = Vector2.new(1, 0)
dexPanel.Position = UDim2.new(0.98, 0, 0, 188)
dexPanel.Size = UDim2.fromOffset(340, 300)
dexPanel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
dexPanel.BackgroundTransparency = 0.08
dexPanel.Visible = false
dexPanel.Parent = gui

local dexCorner = Instance.new("UICorner")
dexCorner.CornerRadius = UDim.new(0, 14)
dexCorner.Parent = dexPanel

local dexPadding = Instance.new("UIPadding")
dexPadding.PaddingTop = UDim.new(0, 10)
dexPadding.PaddingBottom = UDim.new(0, 10)
dexPadding.PaddingLeft = UDim.new(0, 10)
dexPadding.PaddingRight = UDim.new(0, 10)
dexPadding.Parent = dexPanel

local dexTitle = Instance.new("TextLabel")
dexTitle.Name = "Title"
dexTitle.BackgroundTransparency = 1
dexTitle.Size = UDim2.new(1, 0, 0, 30)
dexTitle.Font = Enum.Font.GothamBold
dexTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
dexTitle.TextScaled = true
dexTitle.TextXAlignment = Enum.TextXAlignment.Left
dexTitle.Text = "DinoDex"
dexTitle.Parent = dexPanel

local dexList = Instance.new("TextLabel")
dexList.Name = "List"
dexList.BackgroundTransparency = 1
dexList.Position = UDim2.fromOffset(0, 38)
dexList.Size = UDim2.new(1, 0, 1, -38)
dexList.Font = Enum.Font.GothamMedium
dexList.TextColor3 = Color3.fromRGB(226, 232, 240)
dexList.TextSize = 16
dexList.TextWrapped = true
dexList.TextXAlignment = Enum.TextXAlignment.Left
dexList.TextYAlignment = Enum.TextYAlignment.Top
dexList.Text = "Hatch dinos to fill your collection."
dexList.Parent = dexPanel

local DINO_COLORS: { [string]: Color3 } = {
	["starter-raptor"] = Color3.fromRGB(74, 222, 128),
	["tri-horn"] = Color3.fromRGB(96, 165, 250),
	["bronto-buddy"] = Color3.fromRGB(168, 85, 247),
	["shadow-rex"] = Color3.fromRGB(30, 41, 59),
	["golden-ptero"] = Color3.fromRGB(250, 204, 21),
}

local DINO_NAMES: { [string]: string } = {
	["starter-raptor"] = "Starter Raptor",
	["tri-horn"] = "Tri-Horn",
	["bronto-buddy"] = "Bronto",
	["shadow-rex"] = "Shadow Rex",
	["golden-ptero"] = "Golden Ptero",
}

local DINO_MODEL_NAMES: { [string]: string } = {
	["starter-raptor"] = "StarterRaptor",
	["tri-horn"] = "TriHorn",
	["bronto-buddy"] = "BrontoBuddy",
	["shadow-rex"] = "ShadowRex",
	["golden-ptero"] = "GoldenPtero",
}

local RARITY_COLORS: { [string]: Color3 } = {
	Common = Color3.fromRGB(148, 163, 184),
	Rare = Color3.fromRGB(96, 165, 250),
	Epic = Color3.fromRGB(168, 85, 247),
	Legendary = Color3.fromRGB(250, 204, 21),
}

local function send(payload: { [string]: any }): ()
	actionEvent:FireServer(payload)
end

local function formatNumber(value: number): string
	if value >= 1_000_000 then
		return string.format("%.1fM", value / 1_000_000)
	elseif value >= 1_000 then
		return string.format("%.1fK", value / 1_000)
	end
	return tostring(math.floor(value))
end

local function getFirstOwnedDino(state: any): string?
	local dinos = state.dinos
	if typeof(dinos) ~= "table" then
		return nil
	end
	for _, dinoId in { "starter-raptor", "tri-horn", "bronto-buddy", "shadow-rex", "golden-ptero" } do
		if (dinos[dinoId] or 0) > 0 then
			return dinoId
		end
	end
	return nil
end

local function findNearestBerryNode(): string?
	local character = player.Character
	if character == nil then
		return nil
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart == nil or not rootPart:IsA("BasePart") then
		return nil
	end
	local bestNodeId: string? = nil
	local bestDistance = math.huge
	for nodeId, position in berryNodePositions do
		local distance = (rootPart.Position - position).Magnitude
		if distance < bestDistance then
			bestNodeId = nodeId
			bestDistance = distance
		end
	end
	if bestDistance > 32 then
		return nil
	end
	return bestNodeId
end

local function buildDexText(state: any): string
	local ownedCounts = if typeof(state.dinos) == "table" then state.dinos else {}
	local ownedDinos = if typeof(state.ownedDinos) == "table" then state.ownedDinos else {}
	local lines = table.create(8)
	table.insert(lines, `Snacks: {state.berryFood or 0}  •  Collection: {#ownedDinos}/{state.nestCapacity or 8}`)
	for _, dinoId in { "starter-raptor", "tri-horn", "bronto-buddy", "shadow-rex", "golden-ptero" } do
		local count = ownedCounts[dinoId] or 0
		local name = DINO_NAMES[dinoId] or dinoId
		if count > 0 then
			local bestStage = "Baby"
			for _, owned in ownedDinos do
				if typeof(owned) == "table" and owned.id == dinoId and typeof(owned.stage) == "string" then
					bestStage = owned.stage
					if bestStage == "Adult" then
						break
					end
				end
			end
			table.insert(lines, `✅ {name} x{count} — best: {bestStage}`)
		else
			table.insert(lines, `🔒 {name} — hatch from egg nests`)
		end
	end
	local cooldowns = if typeof(state.berryCooldowns) == "table" then state.berryCooldowns else {}
	table.insert(lines, "")
	table.insert(lines, `Berry regrow: cave {cooldowns["cave-berry"] or 0}s • valley {cooldowns["valley-berry"] or 0}s`)
	return table.concat(lines, "\n")
end

local function makePetPart(parent: Model, name: string, size: Vector3, offset: CFrame, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.Anchored = true
	part.CFrame = offset
	part.Parent = parent
	return part
end

local function setModelPartsNonColliding(model: Model): ()
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
		end
	end
end

local function cloneDinoTemplate(dinoId: string, stage: string?): Model?
	local modelPrefix = DINO_MODEL_NAMES[dinoId]
	if modelPrefix == nil then
		return nil
	end
	local template = dinoModelsFolder:FindFirstChild(`{modelPrefix}_{stage or "Baby"}`)
	if template == nil or not template:IsA("Model") then
		return nil
	end
	local pet = template:Clone()
	pet.Name = `DinoPet_{dinoId}_{stage or "Baby"}`
	local body = pet:FindFirstChild("Body", true)
	if body ~= nil and body:IsA("BasePart") then
		pet.PrimaryPart = body
	elseif pet.PrimaryPart == nil then
		local firstPart = pet:FindFirstChildWhichIsA("BasePart", true)
		if firstPart ~= nil then
			pet.PrimaryPart = firstPart
		end
	end
	setModelPartsNonColliding(pet)
	return pet
end

local function addPetNameplate(pet: Model, dinoId: string, stage: string?): ()
	local body = pet.PrimaryPart
	if body == nil then
		return
	end
	local old = body:FindFirstChild("Nameplate")
	if old ~= nil then
		old:Destroy()
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Nameplate"
	billboard.Size = UDim2.fromOffset(190, 46)
	billboard.StudsOffset = Vector3.new(0, if stage == "Adult" then 9 else 5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = body

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.25
	label.Text = `{DINO_NAMES[dinoId] or "Dino"} • {stage or "Baby"}`
	label.Parent = billboard
end

local function createGeneratedPet(dinoId: string, stage: string?): Model
	local color = DINO_COLORS[dinoId] or Color3.fromRGB(74, 222, 128)
	local scale = if stage == "Adult" then 1.8 elseif stage == "Juvenile" then 1.25 else 0.82
	local pet = Instance.new("Model")
	pet.Name = `DinoPet_{dinoId}_{stage or "Baby"}`

	local body = makePetPart(pet, "Body", Vector3.new(4.8, 2.4, 7.2) * scale, CFrame.new(0, 0, 0), color)
	pet.PrimaryPart = body
	makePetPart(pet, "Head", Vector3.new(2.8, 2.2, 2.8) * scale, CFrame.new(0, 0.6 * scale, -4.4 * scale), color)
	makePetPart(pet, "Tail", Vector3.new(1.4, 1.4, 5.4) * scale, CFrame.new(0, 0.25 * scale, 5.6 * scale) * CFrame.Angles(math.rad(-8), 0, 0), color)
	makePetPart(pet, "LeftLeg", Vector3.new(1.1, 2.4, 1.1) * scale, CFrame.new(-1.35 * scale, -2 * scale, -1.5 * scale), color)
	makePetPart(pet, "RightLeg", Vector3.new(1.1, 2.4, 1.1) * scale, CFrame.new(1.35 * scale, -2 * scale, -1.5 * scale), color)
	makePetPart(pet, "BackSpike", Vector3.new(0.8, 2.8, 0.8) * scale, CFrame.new(0, 2.1 * scale, -0.6 * scale), Color3.fromRGB(255, 255, 255))
	if stage == "Adult" then
		makePetPart(pet, "RideSaddle", Vector3.new(3.8, 0.7, 3.6) * scale, CFrame.new(0, 1.65 * scale, -0.2 * scale), Color3.fromRGB(92, 51, 23))
	end
	return pet
end

local function ensurePet(dinoId: string?, stage: string?): ()
	if dinoId == nil then
		if currentPet ~= nil then
			currentPet:Destroy()
			currentPet = nil
		end
		return
	end
	local petName = `DinoPet_{dinoId}_{stage or "Baby"}`
	if currentPet ~= nil and currentPet.Name == petName then
		return
	end
	if currentPet ~= nil then
		currentPet:Destroy()
	end

	local pet = cloneDinoTemplate(dinoId, stage) or createGeneratedPet(dinoId, stage)
	pet.Parent = workspace
	addPetNameplate(pet, dinoId, stage)
	currentPet = pet
end

local function getCharacterEffectPosition(): Vector3
	local character = player.Character
	if character ~= nil then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart ~= nil and rootPart:IsA("BasePart") then
			return rootPart.Position + Vector3.new(0, 2, -5)
		end
	end
	return Vector3.new(0, 14, 78)
end

local function createBurstPart(name: string, position: Vector3, color: Color3, size: number, lifetime: number): ()
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.15
	part.Size = Vector3.new(size, size, size)
	part.Position = position
	part.Parent = workspace
	task.delay(lifetime, function()
		if part.Parent ~= nil then
			part:Destroy()
		end
	end)
end

local function playHatchReveal(effect: any): ()
	local rarity = if typeof(effect.rarity) == "string" then effect.rarity else "Common"
	local color = RARITY_COLORS[rarity] or RARITY_COLORS.Common
	local position = getCharacterEffectPosition()
	for index = 1, 8 do
		local angle = math.rad(index * 45)
		createBurstPart("HatchRevealSpark", position + Vector3.new(math.cos(angle) * 5, 1 + (index % 3), math.sin(angle) * 5), color, 1.2 + index * 0.08, 1.4)
	end
	createBurstPart("HatchRevealCore", position + Vector3.new(0, 2, 0), color, if rarity == "Legendary" then 8 else 5, 1.8)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = `{rarity} Hatch!`,
			Text = tostring(effect.displayName or "New dinosaur"),
			Duration = 4,
		})
	end)
end

local function playFeedPulse(): ()
	local position = getCharacterEffectPosition()
	for index = 1, 5 do
		createBurstPart("FeedHeartPulse", position + Vector3.new((index - 3) * 1.4, 3 + (index % 2), -1), Color3.fromRGB(244, 63, 94), 1.1, 1.2)
	end
end

local function playEffect(effect: any): ()
	if typeof(effect) ~= "table" or typeof(effect.kind) ~= "string" then
		return
	end
	if effect.kind == "hatchReveal" then
		playHatchReveal(effect)
	elseif effect.kind == "feedPulse" then
		playFeedPulse()
	end
end

RunService.RenderStepped:Connect(function()
	if currentPet == nil then
		return
	end
	local character = player.Character
	if character == nil then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart == nil or not rootPart:IsA("BasePart") then
		return
	end
	local target = if latestState ~= nil and latestState.isMounted == true then rootPart.CFrame * CFrame.new(0, -3.1, -1.2) else rootPart.CFrame * CFrame.new(-4, -1.5, 5)
	currentPet:PivotTo(currentPet:GetPivot():Lerp(target, if latestState ~= nil and latestState.isMounted == true then 0.35 else 0.12))
end)

local function update(payload: any): ()
	local state = if typeof(payload) == "table" and payload.state ~= nil then payload.state else payload
	if typeof(state) ~= "table" then
		return
	end
	hasLoadedState = true
	latestState = state

	stats.Text = `🥚 {formatNumber(state.eggs or 0)} eggs  •  +{formatNumber(state.incomePerSecond or 0)}/sec  •  Nest Lv.{state.nestLevel or 1}  •  Follow slots {state.followSlots or 1}`
	objective.Text = `Objective: {state.objective or "Explore egg nests and grow your cave."}`

	local activeDino: any = nil
	if typeof(state.ownedDinos) == "table" then
		for _, owned in state.ownedDinos do
			if typeof(owned) == "table" and owned.uid == state.activeDinoUid then
				activeDino = owned
				break
			end
		end
	end
	local followingDinoId = if activeDino ~= nil and typeof(activeDino.id) == "string" then activeDino.id else if typeof(state.followingDinoId) == "string" then state.followingDinoId else nil
	local activeStage = if activeDino ~= nil and typeof(activeDino.stage) == "string" then activeDino.stage else nil
	ensurePet(followingDinoId, activeStage)
	if activeDino ~= nil then
		local age = if typeof(activeDino.ageSeconds) == "number" then activeDino.ageSeconds else 0
		local growth = if typeof(activeDino.growthSeconds) == "number" and activeDino.growthSeconds > 0 then activeDino.growthSeconds else 1
		local progress = math.clamp(age / growth, 0, 1) * 100
		dinoInfo.Text = `DinoDex: {activeDino.displayName or "Dino"} • {activeStage or "Baby"} • {math.floor(progress)}% grown • Snacks {state.berryFood or 0}`
	else
		dinoInfo.Text = `DinoDex: {#(state.ownedDinos or {})} dinos discovered • Snacks {state.berryFood or 0}`
	end
	dexList.Text = buildDexText(state)

	if state.starterEggClaimed == true then
		valleyNestButton.Text = "Valley Nest"
	else
		valleyNestButton.Text = "Starter Egg"
	end

	if followingDinoId == nil then
		dinoModeButton.Text = "Follow Dino"
	else
		dinoModeButton.Text = "Store Dino"
	end
	mountButton.Text = if state.isMounted == true then "Dismount" else "Mount"

	if typeof(payload) == "table" and typeof(payload.message) == "string" and payload.message ~= "" then
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = "Dino Dash",
				Text = payload.message,
				Duration = 3,
			})
		end)
	end
	if typeof(payload) == "table" then
		playEffect(payload.effect)
	end
end

hatchButton.Activated:Connect(function()
	send({ action = "hatch" })
end)

upgradeButton.Activated:Connect(function()
	send({ action = "upgradeNest" })
end)

valleyNestButton.Activated:Connect(function()
	local targetNest = "valley-nest"
	if latestState ~= nil and latestState.starterEggClaimed ~= true then
		targetNest = "starter-egg"
	end
	send({ action = "collectEggNest", nestId = targetNest })
end)

dinoModeButton.Activated:Connect(function()
	if latestState == nil then
		return
	end
	local followingDinoId = if typeof(latestState.followingDinoId) == "string" then latestState.followingDinoId else nil
	if followingDinoId ~= nil then
		send({ action = "setDinoMode", dinoId = followingDinoId, mode = "StoredInNest" })
		return
	end
	local firstOwned = getFirstOwnedDino(latestState)
	if firstOwned ~= nil then
		send({ action = "setDinoMode", dinoId = firstOwned, mode = "Following" })
	end
end)

feedButton.Activated:Connect(function()
	send({ action = "feedActiveDino" })
end)

berryButton.Activated:Connect(function()
	local nearestNode = findNearestBerryNode()
	if nearestNode == nil then
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = "Dino Dash",
				Text = "Stand near a glowing berry bush to gather snacks.",
				Duration = 2,
			})
		end)
		return
	end
	send({ action = "collectBerryNode", berryNodeId = nearestNode })
end)

mountButton.Activated:Connect(function()
	send({ action = "toggleMount" })
end)

dexButton.Activated:Connect(function()
	dexOpen = not dexOpen
	dexPanel.Visible = dexOpen
end)

stateEvent.OnClientEvent:Connect(update)

task.spawn(function()
	for attempt = 1, 10 do
		local ok, state = pcall(function()
			return requestState:InvokeServer()
		end)
		if ok then
			update(state)
		end
		if hasLoadedState then
			break
		end
		objective.Text = `Objective: loading your nest cave... retry {attempt}/10`
		task.wait(2)
	end
	if not hasLoadedState then
		objective.Text = "Objective: still connecting. Rejoin if this does not clear soon."
	end
end)
