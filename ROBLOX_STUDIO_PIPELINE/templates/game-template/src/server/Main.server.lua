--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local NetworkService = require(ServerScriptService.Server.Services.NetworkService)
local ReceiptProcessor = require(ServerScriptService.Server.Services.ReceiptProcessor)

NetworkService.start()
ReceiptProcessor.start()

print("ClawdiaOS Roblox pipeline server started")
