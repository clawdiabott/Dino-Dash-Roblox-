--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteRegistry = require(Shared.Network.RemoteRegistry)
local RateLimiter = require(Shared.Security.RateLimiter)

local NetworkService = {}
NetworkService.__index = NetworkService

export type NetworkService = typeof(setmetatable({} :: {
	_folder: Folder,
	_rateLimiter: any,
}, NetworkService))

local function ensureRemote(parent: Instance, definition: RemoteRegistry.RemoteDefinition): Instance
	local existing = parent:FindFirstChild(definition.name)
	if existing ~= nil then
		return existing
	end

	local remote: Instance
	if definition.kind == "RemoteFunction" then
		remote = Instance.new("RemoteFunction")
	else
		remote = Instance.new("RemoteEvent")
	end
	remote.Name = definition.name
	remote.Parent = parent
	return remote
end

function NetworkService.new(): NetworkService
	local folder = ReplicatedStorage:FindFirstChild(RemoteRegistry.FOLDER_NAME)
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = RemoteRegistry.FOLDER_NAME
		folder.Parent = ReplicatedStorage
	end

	for _, definition in RemoteRegistry.REMOTES do
		ensureRemote(folder, definition)
	end

	return setmetatable({
		_folder = folder :: Folder,
		_rateLimiter = RateLimiter.new(),
	}, NetworkService)
end

function NetworkService.getEvent(self: NetworkService, remoteKey: string): RemoteEvent
	local definition = RemoteRegistry.REMOTES[remoteKey]
	assert(definition ~= nil and definition.kind == "RemoteEvent", `Unknown RemoteEvent {remoteKey}`)
	return self._folder:WaitForChild(definition.name) :: RemoteEvent
end

function NetworkService.getFunction(self: NetworkService, remoteKey: string): RemoteFunction
	local definition = RemoteRegistry.REMOTES[remoteKey]
	assert(definition ~= nil and definition.kind == "RemoteFunction", `Unknown RemoteFunction {remoteKey}`)
	return self._folder:WaitForChild(definition.name) :: RemoteFunction
end

function NetworkService.checkLimit(self: NetworkService, player: Player, remoteKey: string): boolean
	local definition = RemoteRegistry.REMOTES[remoteKey]
	if definition == nil then
		return false
	end
	local result = self._rateLimiter:check(player, remoteKey, definition.maxCalls, definition.windowSeconds)
	return result.allowed
end

return NetworkService
