--!strict

-- Fill these IDs only after creating the real Roblox products/passes.
-- Keep authoritative grants on the server in ReceiptProcessor; never grant from the client.
local ProductConfig = {}

ProductConfig.DEVELOPER_PRODUCTS = {
	SmallEggPack = {
		productId = 0,
		displayName = "Small Egg Pack",
		eggs = 1_000,
	},
	MegaEggPack = {
		productId = 0,
		displayName = "Mega Egg Pack",
		eggs = 12_000,
	},
} :: { [string]: { productId: number, displayName: string, eggs: number } }

ProductConfig.GAME_PASSES = {
	VipNest = {
		passId = 0,
		displayName = "VIP Nest Cosmetics",
	},
} :: { [string]: { passId: number, displayName: string } }

return ProductConfig
