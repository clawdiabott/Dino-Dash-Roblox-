--!strict

export type RemoteDefinition = {
	name: string,
	kind: "RemoteEvent" | "RemoteFunction",
	maxCalls: number,
	windowSeconds: number,
}

local RemoteRegistry = {}

RemoteRegistry.FOLDER_NAME = "DinoDashRemotes"

RemoteRegistry.REMOTES = {
	Action = {
		name = "Action",
		kind = "RemoteEvent",
		maxCalls = 10,
		windowSeconds = 3,
	},
	State = {
		name = "State",
		kind = "RemoteEvent",
		maxCalls = 120,
		windowSeconds = 60,
	},
	RequestState = {
		name = "RequestState",
		kind = "RemoteFunction",
		maxCalls = 5,
		windowSeconds = 10,
	},
} :: { [string]: RemoteDefinition }

return RemoteRegistry
