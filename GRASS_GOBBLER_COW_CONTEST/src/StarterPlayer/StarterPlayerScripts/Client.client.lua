-- Grass Gobbler Cow Contest client HUD/effects.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("GrassGobblerRemotes")
local updateRemote = remotes:WaitForChild("UpdateHUD")
local eventRemote = remotes:WaitForChild("GameEvent")
local cowhatRemote = remotes:WaitForChild("CowhatShop")

local gui = Instance.new("ScreenGui")
gui.Name = "GrassGobblerHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeLabel(name, text, size, position, bg, fg)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundColor3 = bg or Color3.fromRGB(25, 35, 22)
	label.BackgroundTransparency = 0.08
	label.BorderSizePixel = 0
	label.Text = text
	label.TextColor3 = fg or Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = label
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 255, 95)
	stroke.Thickness = 2
	stroke.Transparency = 0.25
	stroke.Parent = label
	return label
end

local title = makeLabel("Title", "🐄 GRASS GOBBLER", UDim2.fromOffset(430, 54), UDim2.new(0.5, -215, 0, 16), Color3.fromRGB(40, 80, 35), Color3.fromRGB(245, 255, 230))
local timer = makeLabel("Timer", "60.0s", UDim2.fromOffset(210, 70), UDim2.new(0.5, -105, 0, 82), Color3.fromRGB(28, 36, 28), Color3.fromRGB(255, 250, 120))
local score = makeLabel("Score", "Grass: 0", UDim2.fromOffset(250, 56), UDim2.new(0, 22, 0, 26), Color3.fromRGB(26, 55, 22))
local mult = makeLabel("Multiplier", "x1.00", UDim2.fromOffset(210, 56), UDim2.new(0, 22, 0, 92), Color3.fromRGB(32, 48, 24), Color3.fromRGB(120, 255, 130))
local field = makeLabel("Field", "Field: 0", UDim2.fromOffset(230, 50), UDim2.new(1, -252, 0, 28), Color3.fromRGB(40, 42, 26), Color3.fromRGB(230, 255, 180))
local best = makeLabel("Best", "Best: 0", UDim2.fromOffset(230, 50), UDim2.new(1, -252, 0, 86), Color3.fromRGB(45, 35, 55), Color3.fromRGB(255, 230, 255))

local cowhatButton = Instance.new("TextButton")
cowhatButton.Name = "CowhatButton"
cowhatButton.Size = UDim2.fromOffset(275, 58)
cowhatButton.Position = UDim2.new(1, -297, 0, 146)
cowhatButton.BackgroundColor3 = Color3.fromRGB(255, 218, 86)
cowhatButton.BackgroundTransparency = 0.02
cowhatButton.BorderSizePixel = 0
cowhatButton.Text = "🌾 Hayhalo Cowhat — 49 grass"
cowhatButton.TextColor3 = Color3.fromRGB(45, 31, 0)
cowhatButton.TextScaled = true
cowhatButton.Font = Enum.Font.GothamBlack
cowhatButton.Parent = gui
local cowhatCorner = Instance.new("UICorner")
cowhatCorner.CornerRadius = UDim.new(0, 16)
cowhatCorner.Parent = cowhatButton
local cowhatStroke = Instance.new("UIStroke")
cowhatStroke.Color = Color3.fromRGB(255, 255, 180)
cowhatStroke.Thickness = 3
cowhatStroke.Transparency = 0.15
cowhatStroke.Parent = cowhatButton

local help = makeLabel("Help", "Eat grass to add time. More grass = bigger time multiplier. If the field runs low, route smarter!", UDim2.new(0.82, 0, 0, 46), UDim2.new(0.09, 0, 1, -72), Color3.fromRGB(20, 26, 20), Color3.fromRGB(235, 255, 235))
help.Font = Enum.Font.GothamBold

local toast = makeLabel("Toast", "+grass", UDim2.fromOffset(320, 62), UDim2.new(0.5, -160, 0.43, 0), Color3.fromRGB(255, 239, 64), Color3.fromRGB(32, 28, 0))
toast.Visible = false

local restartButton = Instance.new("TextButton")
restartButton.Name = "RestartRunButton"
restartButton.Size = UDim2.fromOffset(300, 64)
restartButton.Position = UDim2.new(0.5, -150, 0.56, 0)
restartButton.BackgroundColor3 = Color3.fromRGB(255, 95, 75)
restartButton.BorderSizePixel = 0
restartButton.Text = "RESTART RUN"
restartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
restartButton.TextScaled = true
restartButton.Font = Enum.Font.GothamBlack
restartButton.Visible = false
restartButton.Parent = gui
local restartCorner = Instance.new("UICorner")
restartCorner.CornerRadius = UDim.new(0, 16)
restartCorner.Parent = restartButton
local restartStroke = Instance.new("UIStroke")
restartStroke.Color = Color3.fromRGB(255, 230, 210)
restartStroke.Thickness = 3
restartStroke.Parent = restartButton

local debugLabel = makeLabel("DebugProbe", "debug", UDim2.fromOffset(520, 44), UDim2.new(0, 22, 1, -124), Color3.fromRGB(10, 10, 10), Color3.fromRGB(255, 255, 255))
debugLabel.TextScaled = false
debugLabel.TextSize = 14
debugLabel.Font = Enum.Font.Code
debugLabel.TextXAlignment = Enum.TextXAlignment.Left

local cowhatOwned = false
local cowhatEquipped = false
local cowhatPrice = 49

local function updateCowhatButton()
	if cowhatOwned and cowhatEquipped then
		cowhatButton.Text = "🌾 Hayhalo equipped"
		cowhatButton.BackgroundColor3 = Color3.fromRGB(115, 255, 140)
	elseif cowhatOwned then
		cowhatButton.Text = "🌾 Equip Hayhalo Cowhat"
		cowhatButton.BackgroundColor3 = Color3.fromRGB(145, 225, 255)
	else
		cowhatButton.Text = "🌾 Hayhalo Cowhat — " .. tostring(cowhatPrice) .. " grass"
		cowhatButton.BackgroundColor3 = Color3.fromRGB(255, 218, 86)
	end
end

local function popToast(text, color)
	toast.Text = text
	toast.TextColor3 = Color3.fromRGB(30, 30, 20)
	toast.BackgroundColor3 = color or Color3.fromRGB(255, 239, 64)
	toast.Visible = true
	toast.Size = UDim2.fromOffset(260, 48)
	toast.Position = UDim2.new(0.5, -130, 0.46, 0)
	TweenService:Create(toast, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(360, 72),
		Position = UDim2.new(0.5, -180, 0.42, 0),
	}):Play()
	task.delay(0.55, function()
		if toast then
			TweenService:Create(toast, TweenInfo.new(0.24), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			task.wait(0.25)
			toast.Visible = false
			toast.BackgroundTransparency = 0.08
			toast.TextTransparency = 0
		end
	end)
end

updateRemote.OnClientEvent:Connect(function(data)
	timer.Text = string.format("%.1fs", tonumber(data.timeLeft) or 0)
	score.Text = "Grass: " .. tostring(data.score or 0)
	mult.Text = string.format("x%.2f", tonumber(data.multiplier) or 1)
	field.Text = "Field: " .. tostring(data.grassRemaining or 0)
	best.Text = "Best: " .. tostring(data.best or 0)

	local timeLeft = tonumber(data.timeLeft) or 0
	if timeLeft < 10 then
		timer.TextColor3 = Color3.fromRGB(255, 80, 80)
	elseif timeLeft > 90 then
		timer.TextColor3 = Color3.fromRGB(115, 255, 140)
	else
		timer.TextColor3 = Color3.fromRGB(255, 250, 120)
	end
end)

cowhatButton.MouseButton1Click:Connect(function()
	if cowhatOwned and cowhatEquipped then
		cowhatRemote:FireServer("unequip")
	elseif cowhatOwned then
		cowhatRemote:FireServer("equip")
	else
		cowhatRemote:FireServer("buy")
	end
end)

cowhatRemote.OnClientEvent:Connect(function(data)
	cowhatPrice = tonumber(data.price) or cowhatPrice
	cowhatOwned = data.owned == true
	cowhatEquipped = data.equipped == true
	updateCowhatButton()
	if data.message then
		popToast(tostring(data.message), Color3.fromRGB(255, 230, 120))
	end
end)

updateCowhatButton()
cowhatRemote:FireServer("state")

restartButton.MouseButton1Click:Connect(function()
	restartButton.Visible = false
	eventRemote:FireServer("restartRun")
end)

eventRemote.OnClientEvent:Connect(function(data)
	if data.kind == "eat" then
		local timeGain = tonumber(data.timeGain) or 0
		local scoreGain = tonumber(data.scoreGain) or 1
		if data.golden then
			popToast(string.format("GOLDEN GRASS! +%d / +%.1fs", scoreGain, timeGain), Color3.fromRGB(255, 220, 50))
		else
			popToast(string.format("+%d grass  +%.1fs", scoreGain, timeGain), Color3.fromRGB(120, 255, 105))
		end
	elseif data.kind == "gameover" then
		popToast("TIME! Score: " .. tostring(data.score or 0), Color3.fromRGB(255, 80, 80))
		restartButton.Visible = true
	elseif data.kind == "restart" then
		restartButton.Visible = false
		popToast("New run! Eat fast!", Color3.fromRGB(120, 220, 255))
	elseif data.kind == "cowhatPurchased" then
		popToast("Hayhalo Cowhat unlocked!", Color3.fromRGB(255, 218, 86))
	end
end)

local currentCharacter = nil

local function makeLocalCameraSafe(character)
	local function hideFromOwner(inst)
		if inst:IsA("BasePart") then
			-- Local-only. Prevents the owner's camera from clipping into white avatar/cosmetic geometry.
			-- Other players still see the character/cosmetics normally.
			inst.LocalTransparencyModifier = 1
			inst.CanQuery = false
		elseif inst:IsA("Decal") then
			inst.LocalTransparencyModifier = 1
		end
	end

	for _, inst in ipairs(character:GetDescendants()) do
		hideFromOwner(inst)
	end
	character.DescendantAdded:Connect(function(inst)
		task.defer(function()
			hideFromOwner(inst)
		end)
	end)
end

local function setupGameCamera(character)
	currentCharacter = character
	player.CameraMinZoomDistance = 24
	player.CameraMaxZoomDistance = 90
	task.wait(0.25)
	makeLocalCameraSafe(character)
	local camera = workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 68
	end
end

-- Stable chase camera for Grass Gobbler. This avoids Roblox's default camera sitting inside
-- the local cow/player model, which was making the whole play view turn white.
local debugTimer = 0

RunService.RenderStepped:Connect(function(dt)
	local camera = workspace.CurrentCamera
	local character = currentCharacter or player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not camera or not root then return end

	local focus = root.Position + Vector3.new(0, 2.5, 0)
	local cameraPosition = focus + Vector3.new(0, 42, 38)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(cameraPosition, focus)

	debugTimer += dt
	if debugTimer >= 0.35 then
		debugTimer = 0
		local farm = workspace:FindFirstChild("FarmField")
		local farmInfo = "FarmField missing"
		if farm and farm:IsA("BasePart") then
			farmInfo = string.format("field rgb=%d,%d,%d y=%.1f mat=%s trans=%.2f coll=%s", math.floor(farm.Color.R * 255), math.floor(farm.Color.G * 255), math.floor(farm.Color.B * 255), farm.Position.Y, farm.Material.Name, farm.Transparency, tostring(farm.CanCollide))
		end
		debugLabel.Text = string.format("root y=%.1f cam y=%.1f | %s", root.Position.Y, camera.CFrame.Position.Y, farmInfo)
	end
end)

player.CharacterAdded:Connect(setupGameCamera)

if player.Character then
	setupGameCamera(player.Character)
end
