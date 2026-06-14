local XOR = {}

local bitLib = bit32 or bit

local function bxor(a, b)
	if bitLib and bitLib.bxor then
		return bitLib.bxor(a, b)
	end

	local result = 0
	local bitValue = 1

	while a > 0 or b > 0 do
		local abit = a % 2
		local bbit = b % 2
		if abit ~= bbit then
			result = result + bitValue
		end
		a = math.floor(a / 2)
		b = math.floor(b / 2)
		bitValue = bitValue * 2
	end

	return result
end

local function normalizeKey(key)
	key = tostring(key or "")
	if key == "" then
		return nil, "XOR key cannot be empty"
	end
	return key
end

function XOR.apply(input, key)
	input = tostring(input or "")
	key = normalizeKey(key)
	if not key then
		return nil, "XOR key cannot be empty"
	end

	local output = table.create and table.create(#input) or {}
	local keyLength = #key

	for i = 1, #input do
		local inputByte = input:byte(i)
		local keyByte = key:byte(((i - 1) % keyLength) + 1)
		output[i] = string.char(bxor(inputByte, keyByte))
	end

	return table.concat(output)
end

function XOR.encrypt(input, key)
	return XOR.apply(input, key)
end

function XOR.decrypt(input, key)
	return XOR.apply(input, key)
end

function XOR.toHex(input)
	input = tostring(input or "")
	local output = table.create and table.create(#input) or {}

	for i = 1, #input do
		output[i] = string.format("%02x", input:byte(i))
	end

	return table.concat(output)
end

function XOR.fromHex(input)
	input = tostring(input or ""):gsub("%s+", "")
	if #input % 2 ~= 0 or input:find("[^%x]") then
		return nil, "Invalid hex input"
	end

	local output = table.create and table.create(#input / 2) or {}
	for i = 1, #input, 2 do
		output[#output + 1] = string.char(tonumber(input:sub(i, i + 1), 16))
	end

	return table.concat(output)
end

function XOR.encryptHex(input, key)
	local encrypted, err = XOR.encrypt(input, key)
	if not encrypted then
		return nil, err
	end
	return XOR.toHex(encrypted)
end

function XOR.decryptHex(input, key)
	local raw, err = XOR.fromHex(input)
	if not raw then
		return nil, err
	end
	return XOR.decrypt(raw, key)
end

XOR.Apply = XOR.apply
XOR.Encrypt = XOR.encrypt
XOR.Decrypt = XOR.decrypt
XOR.ToHex = XOR.toHex
XOR.FromHex = XOR.fromHex
XOR.EncryptHex = XOR.encryptHex
XOR.DecryptHex = XOR.decryptHex

return XOR
