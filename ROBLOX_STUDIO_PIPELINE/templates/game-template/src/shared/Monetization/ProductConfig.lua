--!strict

export type DeveloperProduct = {
	id: number,
	key: string,
	name: string,
	grantType: "currency" | "item" | "boost" | "custom",
	amount: number,
}

export type GamePass = {
	id: number,
	key: string,
	name: string,
}

local ProductConfig = {}

ProductConfig.DeveloperProducts = {
	-- Replace IDs after Patrick creates products in Creator Dashboard.
	SmallCoins = {
		id = 0,
		key = "SmallCoins",
		name = "Small Coin Pack",
		grantType = "currency",
		amount = 100,
	},
} :: { [string]: DeveloperProduct }

ProductConfig.GamePasses = {
	-- Replace IDs after Patrick creates passes in Creator Dashboard.
	VIP = {
		id = 0,
		key = "VIP",
		name = "VIP",
	},
} :: { [string]: GamePass }

return ProductConfig
