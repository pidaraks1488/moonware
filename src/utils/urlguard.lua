local UrlGuard = {}

local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local decodeMap = {}

for i = 1, #ALPHABET do
	decodeMap[ALPHABET:sub(i, i)] = i - 1
end

local function byte_at(text, index)
	return string.byte(text, index) or 0
end

local function base64_encode(value)
	value = tostring(value or "")

	local output = {}
	local outIndex = 1

	for i = 1, #value, 3 do
		local b1 = byte_at(value, i)
		local b2 = byte_at(value, i + 1)
		local b3 = byte_at(value, i + 2)
		local chunk = b1 * 65536 + b2 * 256 + b3
		local remaining = #value - i + 1

		local c1 = math.floor(chunk / 262144) % 64
		local c2 = math.floor(chunk / 4096) % 64
		local c3 = math.floor(chunk / 64) % 64
		local c4 = chunk % 64

		output[outIndex] = ALPHABET:sub(c1 + 1, c1 + 1)
		output[outIndex + 1] = ALPHABET:sub(c2 + 1, c2 + 1)
		output[outIndex + 2] = remaining > 1 and ALPHABET:sub(c3 + 1, c3 + 1) or "="
		output[outIndex + 3] = remaining > 2 and ALPHABET:sub(c4 + 1, c4 + 1) or "="

		outIndex = outIndex + 4
	end

	return table.concat(output)
end

local function base64_decode(value)
	value = tostring(value or ""):gsub("%s+", "")

	local padding = #value % 4
	if padding == 2 then
		value = value .. "=="
	elseif padding == 3 then
		value = value .. "="
	elseif padding == 1 then
		return nil, "Invalid base64 length"
	end

	local output = {}
	local outIndex = 1

	for i = 1, #value, 4 do
		local ch1 = value:sub(i, i)
		local ch2 = value:sub(i + 1, i + 1)
		local ch3 = value:sub(i + 2, i + 2)
		local ch4 = value:sub(i + 3, i + 3)

		local c1 = decodeMap[ch1]
		local c2 = decodeMap[ch2]
		local c3 = ch3 == "=" and 0 or decodeMap[ch3]
		local c4 = ch4 == "=" and 0 or decodeMap[ch4]

		if c1 == nil or c2 == nil or c3 == nil or c4 == nil then
			return nil, "Invalid base64 character"
		end

		local chunk = c1 * 262144 + c2 * 4096 + c3 * 64 + c4
		output[outIndex] = string.char(math.floor(chunk / 65536) % 256)
		outIndex = outIndex + 1

		if ch3 ~= "=" then
			output[outIndex] = string.char(math.floor(chunk / 256) % 256)
			outIndex = outIndex + 1
		end

		if ch4 ~= "=" then
			output[outIndex] = string.char(chunk % 256)
			outIndex = outIndex + 1
		end
	end

	return table.concat(output)
end

local function xor_crypt(value, key)
	value = tostring(value or "")
	key = tostring(key or "")

	if key == "" then
		return value
	end

	local output = table.create and table.create(#value) or {}

	for i = 1, #value do
		local valueByte = string.byte(value, i)
		local keyByte = string.byte(key, ((i - 1) % #key) + 1)
		output[i] = string.char(bit32.bxor(valueByte, keyByte))
	end

	return table.concat(output)
end

function UrlGuard.encode(url, key)
	return base64_encode(xor_crypt(url, key or "moonware"))
end

function UrlGuard.decode(encoded, key)
	local decoded, err = base64_decode(encoded)
	if not decoded then
		return nil, err
	end

	return xor_crypt(decoded, key or "moonware")
end

function UrlGuard.fromParts(parts)
	return table.concat(parts or "")
end

function UrlGuard.safeGet(encoded, key)
	local url, err = UrlGuard.decode(encoded, key)
	if not url then
		return nil, err
	end

	return game:HttpGet(url)
end

UrlGuard.Encode = UrlGuard.encode
UrlGuard.Decode = UrlGuard.decode
UrlGuard.FromParts = UrlGuard.fromParts
UrlGuard.SafeGet = UrlGuard.safeGet

return UrlGuard
