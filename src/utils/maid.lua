local Maid = {}
Maid.__index = Maid

local function cleanup_task(taskValue)
	local valueType = typeof(taskValue)

	if valueType == "RBXScriptConnection" then
		if taskValue.Connected then
			taskValue:Disconnect()
		end
	elseif valueType == "Instance" then
		if taskValue.Parent then
			taskValue:Destroy()
		end
	elseif type(taskValue) == "function" then
		taskValue()
	elseif type(taskValue) == "table" then
		if type(taskValue.Destroy) == "function" then
			taskValue:Destroy()
		elseif type(taskValue.Disconnect) == "function" then
			taskValue:Disconnect()
		end
	end
end

function Maid.new()
	return setmetatable({
		_tasks = {},
	}, Maid)
end

function Maid:Give(taskValue)
	table.insert(self._tasks, taskValue)
	return taskValue
end

function Maid:GiveKey(key, taskValue)
	self:Remove(key)
	self._tasks[key] = taskValue
	return taskValue
end

function Maid:Remove(key)
	local taskValue = self._tasks[key]
	if taskValue ~= nil then
		self._tasks[key] = nil
		cleanup_task(taskValue)
	end
end

function Maid:Cleanup()
	for key, taskValue in pairs(self._tasks) do
		self._tasks[key] = nil
		cleanup_task(taskValue)
	end
end

function Maid:Destroy()
	self:Cleanup()
end

Maid.clean = cleanup_task

return Maid
