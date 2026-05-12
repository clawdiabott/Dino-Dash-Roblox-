--!strict

local Players = game:GetService("Players")

export type Result = {
	allowed: boolean,
	retryAfter: number,
}

type Bucket = {
	windowStart: number,
	count: number,
}

type PlayerBuckets = { [string]: Bucket }

local RateLimiter = {}
RateLimiter.__index = RateLimiter

export type RateLimiter = typeof(setmetatable({} :: {
	_buckets: { [number]: PlayerBuckets },
}, RateLimiter))

function RateLimiter.new(): RateLimiter
	local self = setmetatable({
		_buckets = {},
	}, RateLimiter)

	Players.PlayerRemoving:Connect(function(player: Player)
		self._buckets[player.UserId] = nil
	end)

	return self
end

function RateLimiter.check(self: RateLimiter, player: Player, action: string, maxCalls: number, windowSeconds: number): Result
	assert(maxCalls > 0, "maxCalls must be > 0")
	assert(windowSeconds > 0, "windowSeconds must be > 0")

	local now = os.clock()
	local userBuckets = self._buckets[player.UserId]
	if userBuckets == nil then
		userBuckets = {}
		self._buckets[player.UserId] = userBuckets
	end

	local bucket = userBuckets[action]
	if bucket == nil or now - bucket.windowStart >= windowSeconds then
		userBuckets[action] = {
			windowStart = now,
			count = 1,
		}
		return { allowed = true, retryAfter = 0 }
	end

	if bucket.count >= maxCalls then
		return {
			allowed = false,
			retryAfter = math.max(0, windowSeconds - (now - bucket.windowStart)),
		}
	end

	bucket.count += 1
	return { allowed = true, retryAfter = 0 }
end

return RateLimiter
