--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.Shared.Network.RemoteRegistry)

local Client = {}

function Client.start(): nil
	local remote = RemoteRegistry.getOrCreateRemoteEvent(RemoteRegistry.Definitions.ClientAction.name)
	remote:FireServer({
		action = "ClientReady",
		clientTime = os.clock(),
	})
	return nil
end

Client.start()
