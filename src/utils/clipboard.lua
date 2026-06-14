local Clipboard = {}

local function get_setter()
	if type(setclipboard) == "function" then
		return setclipboard
	end

	if type(toclipboard) == "function" then
		return toclipboard
	end

	if syn and type(syn.write_clipboard) == "function" then
		return syn.write_clipboard
	end

	return nil
end

function Clipboard.isSupported()
	return get_setter() ~= nil
end

function Clipboard.copy(value)
	local setter = get_setter()
	if not setter then
		return false, "Clipboard is not supported"
	end

	local ok, err = pcall(setter, tostring(value or ""))
	if not ok then
		return false, err
	end

	return true
end

function Clipboard.copyUrl(url)
	return Clipboard.copy(url)
end

return Clipboard
