--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.Shared.Network.RemoteRegistry)
local RateLimiter = require(ReplicatedStorage.Shared.Security.RateLimiter)
local RemoteValidator = require(ReplicatedStorage.Shared.Security.RemoteValidator)

local NetworkService = {}

local limiter = RateLimiter.new()

local clientActionSchema = {
	action = { type = "string", required = true, maxLength = 48 },
	clientTime = { type = "number", required = false, min = 0, max = 9999999999 },
}

function NetworkService.start(): nil
	local remote = RemoteRegistry.getOrCreateRemoteEvent(RemoteRegistry.Definitions.ClientAction.name)

	remote.OnServerEvent:Connect(function(player: Player, payload: any)
		local rate = limiter:check(player, "ClientAction", RemoteRegistry.Definitions.ClientAction.maxCalls, RemoteRegistry.Definitions.ClientAction.windowSeconds)
		if not rate.allowed then
			warn(`Rate limited {player.UserId} for ClientAction; retryAfter={rate.retryAfter}`)
			return
		end

		local ok, reason = RemoteValidator.validateTable(payload, clientActionSchema)
		if not ok then
			warn(`Rejected invalid ClientAction from {player.UserId}: {reason}`)
			return
		end

		-- Route validated actions to game-specific handlers here.
	end)

	return nil
end

return NetworkService
