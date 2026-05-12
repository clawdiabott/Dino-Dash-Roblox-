--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ProductConfig = require(Shared.Monetization.ProductConfig)

local ReceiptProcessor = {}
ReceiptProcessor.__index = ReceiptProcessor

export type ReceiptInfo = {
	PlayerId: number,
	ProductId: number,
	PurchaseId: string,
}

export type ReceiptProcessor = typeof(setmetatable({} :: {
	_playerDataService: any,
	_processed: { [string]: boolean },
}, ReceiptProcessor))

function ReceiptProcessor.new(playerDataService: any): ReceiptProcessor
	return setmetatable({
		_playerDataService = playerDataService,
		_processed = {},
	}, ReceiptProcessor)
end

function ReceiptProcessor.processReceipt(self: ReceiptProcessor, receiptInfo: { [string]: any }): Enum.ProductPurchaseDecision
	local rawPurchaseId = receiptInfo.PurchaseId
	if typeof(rawPurchaseId) ~= "string" or rawPurchaseId == "" then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local purchaseId = rawPurchaseId
	if self._processed[purchaseId] == true then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local playerId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	if typeof(playerId) ~= "number" or typeof(productId) ~= "number" then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local player = game:GetService("Players"):GetPlayerByUserId(playerId)
	if player == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if self._playerDataService:hasProcessedReceipt(player, purchaseId) then
		self._processed[purchaseId] = true
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	for _, product in ProductConfig.DEVELOPER_PRODUCTS do
		if product.productId == productId and product.productId > 0 then
			if not self._playerDataService:grantReceiptEggs(player, purchaseId, product.eggs) then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			self._processed[purchaseId] = true
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end

	warn(`Unknown developer product receipt: {productId}`)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

return ReceiptProcessor
