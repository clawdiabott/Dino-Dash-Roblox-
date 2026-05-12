--!strict

export type Dictionary<T> = { [string]: T }
export type RateLimitResult = {
	allowed: boolean,
	retryAfter: number,
}

export type RemoteDefinition = {
	name: string,
	maxCalls: number,
	windowSeconds: number,
}

return nil
