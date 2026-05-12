--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProductConfig = require(ReplicatedStorage.Shared.Monetization.ProductConfig)

local ReceiptProcessor = {}

type ReceiptInfo = {
	PlayerId: number,
	ProductId: number,
	PurchaseId: string,
}

local productById: { [number]: ProductConfig.DeveloperProduct } = {}
for _, product in pairs(ProductConfig.DeveloperProducts) do
	if product.id > 0 then
		productById[product.id] = product
	end
end

local function grantProduct(receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision
	local product = productById[receiptInfo.ProductId]
	if product == nil then
		warn(`Unknown developer product id: {receiptInfo.ProductId}`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Production rule: make grants idempotent in your profile/data layer using PurchaseId.
	-- Wire this to ProfileService or your selected persistence wrapper per game.
	print(`Grant product {product.key} to user {receiptInfo.PlayerId}; purchase={receiptInfo.PurchaseId}`)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function ReceiptProcessor.start(): nil
	MarketplaceService.ProcessReceipt = function(receiptInfo: ReceiptInfo)
		local ok, decision = pcall(grantProduct, receiptInfo)
		if not ok then
			warn(`ProcessReceipt failed: {decision}`)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		return decision
	end

	return nil
end

return ReceiptProcessor
