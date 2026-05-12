--!strict

local MarketplaceService = game:GetService("MarketplaceService")

local EntitlementService = {}

function EntitlementService.userOwnsPassAsync(player: Player, passId: number): boolean
	if passId <= 0 then
		return false
	end

	local ok, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)

	if not ok then
		warn(`Game pass ownership check failed for {player.UserId}/{passId}: {result}`)
		return false
	end

	return result == true
end

return EntitlementService
