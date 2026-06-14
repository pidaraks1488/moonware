local Files = {}

local function unavailable(name)
	return nil, name .. " is not available"
end

local function normalize(path)
	path = tostring(path or "")
	path = path:gsub("\\", "/"):gsub("/+", "/")
	return path
end

function Files.normalize(path)
	return normalize(path)
end

function Files.exists(path)
	path = normalize(path)

	if type(isfile) == "function" and isfile(path) then
		return true
	end
	if type(isfolder) == "function" and isfolder(path) then
		return true
	end

	return false
end

function Files.isFile(path)
	if type(isfile) ~= "function" then
		return false
	end
	return isfile(normalize(path))
end

function Files.isFolder(path)
	if type(isfolder) ~= "function" then
		return false
	end
	return isfolder(normalize(path))
end

function Files.makeFolder(path)
	path = normalize(path)
	if type(makefolder) ~= "function" then
		return unavailable("makefolder")
	end
	if Files.isFolder(path) then
		return true
	end
	return pcall(makefolder, path)
end

function Files.ensureFolder(path)
	path = normalize(path)
	local current = ""

	for part in path:gmatch("[^/]+") do
		current = current == "" and part or (current .. "/" .. part)
		if not Files.isFolder(current) then
			local ok, err = Files.makeFolder(current)
			if not ok then
				return nil, err
			end
		end
	end

	return true
end

function Files.dirname(path)
	path = normalize(path)
	return path:match("^(.*)/[^/]+$") or ""
end

function Files.basename(path)
	path = normalize(path)
	return path:match("([^/]+)$") or path
end

function Files.read(path)
	path = normalize(path)
	if type(readfile) ~= "function" then
		return unavailable("readfile")
	end
	if type(isfile) == "function" and not isfile(path) then
		return nil, "File does not exist"
	end
	local ok, result = pcall(readfile, path)
	if not ok then
		return nil, result
	end
	return result
end

function Files.write(path, content)
	path = normalize(path)
	if type(writefile) ~= "function" then
		return unavailable("writefile")
	end

	local dir = Files.dirname(path)
	if dir ~= "" then
		local ok, err = Files.ensureFolder(dir)
		if not ok then
			return nil, err
		end
	end

	local ok, err = pcall(writefile, path, tostring(content or ""))
	if not ok then
		return nil, err
	end
	return true
end

function Files.append(path, content)
	path = normalize(path)
	if type(appendfile) == "function" then
		local ok, err = pcall(appendfile, path, tostring(content or ""))
		if not ok then
			return nil, err
		end
		return true
	end

	local existing = ""
	if Files.isFile(path) then
		local value, err = Files.read(path)
		if value == nil then
			return nil, err
		end
		existing = value
	end

	return Files.write(path, existing .. tostring(content or ""))
end

function Files.delete(path)
	path = normalize(path)
	if type(delfile) == "function" and Files.isFile(path) then
		return pcall(delfile, path)
	end
	if type(delfolder) == "function" and Files.isFolder(path) then
		return pcall(delfolder, path)
	end
	return false, "delete API is not available or path does not exist"
end

function Files.list(path)
	path = normalize(path)
	if type(listfiles) ~= "function" then
		return unavailable("listfiles")
	end
	local ok, result = pcall(listfiles, path)
	if not ok then
		return nil, result
	end
	return result
end

function Files.readJson(path)
	local content, err = Files.read(path)
	if content == nil then
		return nil, err
	end
	if not game or not game.GetService then
		return nil, "HttpService is not available"
	end
	local http = game:GetService("HttpService")
	local ok, decoded = pcall(function()
		return http:JSONDecode(content)
	end)
	if not ok then
		return nil, decoded
	end
	return decoded
end

function Files.writeJson(path, value)
	if not game or not game.GetService then
		return nil, "HttpService is not available"
	end
	local http = game:GetService("HttpService")
	local ok, encoded = pcall(function()
		return http:JSONEncode(value)
	end)
	if not ok then
		return nil, encoded
	end
	return Files.write(path, encoded)
end

Files.Normalize = Files.normalize
Files.Exists = Files.exists
Files.IsFile = Files.isFile
Files.IsFolder = Files.isFolder
Files.MakeFolder = Files.makeFolder
Files.EnsureFolder = Files.ensureFolder
Files.Dirname = Files.dirname
Files.Basename = Files.basename
Files.Read = Files.read
Files.Write = Files.write
Files.Append = Files.append
Files.Delete = Files.delete
Files.List = Files.list
Files.ReadJson = Files.readJson
Files.WriteJson = Files.writeJson

return Files
