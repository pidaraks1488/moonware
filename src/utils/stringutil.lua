local StringUtil = {}

function StringUtil.trim(value)
	return tostring(value or ""):match("^%s*(.-)%s*$")
end

function StringUtil.startsWith(value, prefix)
	value = tostring(value or "")
	prefix = tostring(prefix or "")
	return value:sub(1, #prefix) == prefix
end

function StringUtil.endsWith(value, suffix)
	value = tostring(value or "")
	suffix = tostring(suffix or "")
	return suffix == "" or value:sub(-#suffix) == suffix
end

function StringUtil.split(value, separator)
	value = tostring(value or "")
	separator = tostring(separator or ",")

	local result = {}
	if separator == "" then
		for i = 1, #value do
			result[i] = value:sub(i, i)
		end
		return result
	end

	local start = 1

	while true do
		local found = value:find(separator, start, true)
		if not found then
			table.insert(result, value:sub(start))
			break
		end

		table.insert(result, value:sub(start, found - 1))
		start = found + #separator
	end

	return result
end

function StringUtil.limit(value, maxLength, suffix)
	value = tostring(value or "")
	maxLength = tonumber(maxLength) or #value
	suffix = suffix or "..."

	if #value <= maxLength then
		return value
	end

	return value:sub(1, math.max(0, maxLength - #suffix)) .. suffix
end

function StringUtil.slug(value)
	value = StringUtil.trim(value):lower()
	value = value:gsub("[^%w%s%-_]", "")
	value = value:gsub("%s+", "-")
	value = value:gsub("%-+", "-")
	return value
end

function StringUtil.random(length, alphabet)
	length = tonumber(length) or 12
	alphabet = alphabet or "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

	local output = {}
	for i = 1, length do
		local index = math.random(1, #alphabet)
		output[i] = alphabet:sub(index, index)
	end

	return table.concat(output)
end

return StringUtil
