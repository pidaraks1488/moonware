local CacheUtil = {}
CacheUtil.__index = CacheUtil

local function now()
	return os.clock()
end

function CacheUtil.new(options)
	options = options or {}

	local self = setmetatable({}, CacheUtil)
	self.Store = {}
	self.DefaultTtl = options.DefaultTtl or options.defaultTtl
	self.MaxSize = options.MaxSize or options.maxSize

	return self
end

function CacheUtil:set(key, value, ttl)
	local expiresAt
	ttl = ttl or self.DefaultTtl

	if ttl and ttl > 0 then
		expiresAt = now() + ttl
	end

	self.Store[key] = {
		value = value,
		expiresAt = expiresAt,
		createdAt = now(),
		lastAccess = now(),
	}

	if self.MaxSize then
		self:trim(self.MaxSize)
	end

	return value
end

function CacheUtil:get(key, fallback)
	local entry = self.Store[key]
	if not entry then
		return fallback
	end

	if entry.expiresAt and entry.expiresAt <= now() then
		self.Store[key] = nil
		return fallback
	end

	entry.lastAccess = now()
	return entry.value
end

function CacheUtil:has(key)
	return self:get(key, nil) ~= nil
end

function CacheUtil:delete(key)
	local hadValue = self.Store[key] ~= nil
	self.Store[key] = nil
	return hadValue
end

function CacheUtil:clear()
	self.Store = {}
end

function CacheUtil:remember(key, ttl, factory)
	if type(ttl) == "function" then
		factory = ttl
		ttl = nil
	end

	local cached = self:get(key)
	if cached ~= nil then
		return cached
	end

	local value = factory()
	self:set(key, value, ttl)
	return value
end

function CacheUtil:cleanup()
	local current = now()
	local removed = 0

	for key, entry in pairs(self.Store) do
		if entry.expiresAt and entry.expiresAt <= current then
			self.Store[key] = nil
			removed = removed + 1
		end
	end

	return removed
end

function CacheUtil:size()
	local count = 0
	for _ in pairs(self.Store) do
		count = count + 1
	end
	return count
end

function CacheUtil:keys()
	local keys = {}
	for key in pairs(self.Store) do
		keys[#keys + 1] = key
	end
	return keys
end

function CacheUtil:trim(maxSize)
	maxSize = maxSize or self.MaxSize
	if not maxSize then
		return 0
	end

	self:cleanup()

	local count = self:size()
	if count <= maxSize then
		return 0
	end

	local entries = {}
	for key, entry in pairs(self.Store) do
		entries[#entries + 1] = {
			key = key,
			lastAccess = entry.lastAccess or entry.createdAt or 0,
		}
	end

	table.sort(entries, function(a, b)
		return a.lastAccess < b.lastAccess
	end)

	local removed = 0
	for i = 1, count - maxSize do
		self.Store[entries[i].key] = nil
		removed = removed + 1
	end

	return removed
end

CacheUtil.New = CacheUtil.new
CacheUtil.Set = CacheUtil.set
CacheUtil.Get = CacheUtil.get
CacheUtil.Has = CacheUtil.has
CacheUtil.Delete = CacheUtil.delete
CacheUtil.Clear = CacheUtil.clear
CacheUtil.Remember = CacheUtil.remember
CacheUtil.Cleanup = CacheUtil.cleanup
CacheUtil.Size = CacheUtil.size
CacheUtil.Keys = CacheUtil.keys
CacheUtil.Trim = CacheUtil.trim

return CacheUtil
