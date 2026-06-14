local Runtime = {}

function Runtime.safe(callback, ...)
	local args = table.pack(...)

	return pcall(function()
		return callback(table.unpack(args, 1, args.n))
	end)
end

function Runtime.retry(attempts, delaySeconds, callback, ...)
	local args = table.pack(...)
	local lastResult

	attempts = math.max(1, tonumber(attempts) or 1)
	delaySeconds = tonumber(delaySeconds) or 0

	for attempt = 1, attempts do
		local ok, result = Runtime.safe(callback, table.unpack(args, 1, args.n))
		if ok then
			return true, result, attempt
		end

		lastResult = result
		if attempt < attempts and delaySeconds > 0 then
			task.wait(delaySeconds)
		end
	end

	return false, lastResult, attempts
end

function Runtime.debounce(delaySeconds, callback)
	local busy = false

	return function(...)
		if busy then
			return false
		end

		busy = true
		local args = table.pack(...)

		task.delay(delaySeconds or 0, function()
			busy = false
		end)

		callback(table.unpack(args, 1, args.n))
		return true
	end
end

function Runtime.throttle(delaySeconds, callback)
	local nextCall = 0

	return function(...)
		local now = os.clock()
		if now < nextCall then
			return false
		end

		nextCall = now + (delaySeconds or 0)
		callback(...)
		return true
	end
end

function Runtime.waitFor(parent, childName, timeout)
	local started = os.clock()
	local child = parent:FindFirstChild(childName)

	while not child do
		if timeout and os.clock() - started >= timeout then
			return nil
		end

		parent.ChildAdded:Wait()
		child = parent:FindFirstChild(childName)
	end

	return child
end

return Runtime
