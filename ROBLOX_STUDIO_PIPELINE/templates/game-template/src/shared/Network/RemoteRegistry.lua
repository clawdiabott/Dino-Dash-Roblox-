--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type RemoteDefinition = {
	name: string,
	maxCalls: number,
	windowSeconds: number,
}

local RemoteRegistry = {}

RemoteRegistry.Definitions = {
	PurchaseRequest = {
		name = "PurchaseRequest",
		maxCalls = 6,
		windowSeconds = 10,
	},
	ClientAction = {
		name = "ClientAction",
		maxCalls = 20,
		windowSeconds = 10,
	},
} :: { [string]: RemoteDefinition }

function RemoteRegistry.getFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	return folder :: Folder
end

function RemoteRegistry.getOrCreateRemoteEvent(name: string): RemoteEvent
	local folder = RemoteRegistry.getFolder()
	local existing = folder:FindFirstChild(name)
	if existing ~= nil then
		assert(existing:IsA("RemoteEvent"), `{name} exists but is not a RemoteEvent`)
		return existing :: RemoteEvent
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote
end

return RemoteRegistry
