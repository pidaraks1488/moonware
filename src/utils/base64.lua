local Base64 = {}

local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local URL_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

local decodeMap = {}
local urlDecodeMap = {}

for i = 1, #ALPHABET do
	decodeMap[ALPHABET:sub(i, i)] = i - 1
	urlDecodeMap[URL_ALPHABET:sub(i, i)] = i - 1
end

local function byte_at(text, index)
	return string.byte(text, index) or 0
end

local function encode_with_alphabet(value, alphabet, stripPadding)
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

		output[outIndex] = alphabet:sub(c1 + 1, c1 + 1)
		output[outIndex + 1] = alphabet:sub(c2 + 1, c2 + 1)

		if remaining > 1 then
			output[outIndex + 2] = alphabet:sub(c3 + 1, c3 + 1)
		elseif not stripPadding then
			output[outIndex + 2] = "="
		end

		if remaining > 2 then
			output[outIndex + 3] = alphabet:sub(c4 + 1, c4 + 1)
		elseif not stripPadding then
			output[outIndex + 3] = "="
		end

		outIndex = outIndex + 4
	end

	return table.concat(output)
end

local function normalize_input(value)
	value = tostring(value or "")
	value = value:gsub("%s+", "")

	local padding = #value % 4
	if padding == 2 then
		value = value .. "=="
	elseif padding == 3 then
		value = value .. "="
	elseif padding == 1 then
		return nil, "Invalid base64 length"
	end

	return value
end

local function decode_with_map(value, map)
	local normalized, err = normalize_input(value)
	if not normalized then
		return nil, err
	end

	local output = {}
	local outIndex = 1

	for i = 1, #normalized, 4 do
		local ch1 = normalized:sub(i, i)
		local ch2 = normalized:sub(i + 1, i + 1)
		local ch3 = normalized:sub(i + 2, i + 2)
		local ch4 = normalized:sub(i + 3, i + 3)

		local c1 = map[ch1]
		local c2 = map[ch2]
		local c3 = ch3 == "=" and 0 or map[ch3]
		local c4 = ch4 == "=" and 0 or map[ch4]

		if c1 == nil or c2 == nil or c3 == nil or c4 == nil then
			return nil, "Invalid base64 character"
		end

		local chunk = c1 * 262144 + c2 * 4096 + c3 * 64 + c4
		local b1 = math.floor(chunk / 65536) % 256
		local b2 = math.floor(chunk / 256) % 256
		local b3 = chunk % 256

		output[outIndex] = string.char(b1)
		outIndex = outIndex + 1

		if ch3 ~= "=" then
			output[outIndex] = string.char(b2)
			outIndex = outIndex + 1
		end

		if ch4 ~= "=" then
			output[outIndex] = string.char(b3)
			outIndex = outIndex + 1
		end
	end

	return table.concat(output)
end

function Base64.encode(value)
	return encode_with_alphabet(value, ALPHABET, false)
end

function Base64.decode(value)
	return decode_with_map(value, decodeMap)
end

function Base64.encodeUrl(value, stripPadding)
	return encode_with_alphabet(value, URL_ALPHABET, stripPadding ~= false)
end

function Base64.decodeUrl(value)
	return decode_with_map(value, urlDecodeMap)
end

Base64.Encode = Base64.encode
Base64.Decode = Base64.decode
Base64.urlEncode = Base64.encodeUrl
Base64.urlDecode = Base64.decodeUrl

return Base64
