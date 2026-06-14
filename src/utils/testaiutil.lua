local TestAIUtil = {}

local DEFAULT_SYSTEM_PROMPT = "You are a helpful assistant."

local function getHttpService()
	if game and game.GetService then
		return game:GetService("HttpService")
	end
	return nil
end

local function requestImpl()
	return syn and syn.request or http_request or request or fluxus and fluxus.request
end

local function jsonEncode(value)
	local http = getHttpService()
	if not http then
		return nil, "HttpService is not available"
	end

	local ok, result = pcall(function()
		return http:JSONEncode(value)
	end)
	if not ok then
		return nil, result
	end
	return result
end

local function jsonDecode(value)
	local http = getHttpService()
	if not http then
		return nil, "HttpService is not available"
	end

	local ok, result = pcall(function()
		return http:JSONDecode(value)
	end)
	if not ok then
		return nil, result
	end
	return result
end

local function sleep(seconds)
	if task and task.wait then
		task.wait(seconds)
	else
		wait(seconds)
	end
end

function TestAIUtil.message(role, content)
	return {
		role = role,
		content = tostring(content or ""),
	}
end

function TestAIUtil.system(content)
	return TestAIUtil.message("system", content)
end

function TestAIUtil.user(content)
	return TestAIUtil.message("user", content)
end

function TestAIUtil.assistant(content)
	return TestAIUtil.message("assistant", content)
end

function TestAIUtil.messages(prompt, systemPrompt, history)
	local messages = {}

	if systemPrompt ~= false then
		messages[#messages + 1] = TestAIUtil.system(systemPrompt or DEFAULT_SYSTEM_PROMPT)
	end

	for _, message in ipairs(history or {}) do
		messages[#messages + 1] = message
	end

	if prompt ~= nil then
		messages[#messages + 1] = TestAIUtil.user(prompt)
	end

	return messages
end

function TestAIUtil.extractText(response)
	if type(response) == "string" then
		local decoded = jsonDecode(response)
		response = decoded or response
	end

	if type(response) ~= "table" then
		return nil
	end

	if response.text then
		return response.text
	end

	if response.output_text then
		return response.output_text
	end

	if response.choices and response.choices[1] then
		local choice = response.choices[1]
		if choice.message and choice.message.content then
			return choice.message.content
		end
		if choice.text then
			return choice.text
		end
	end

	if response.output and response.output[1] then
		local parts = response.output[1].content
		if type(parts) == "table" then
			local text = {}
			for _, part in ipairs(parts) do
				if part.text then
					text[#text + 1] = part.text
				end
			end
			return table.concat(text)
		end
	end

	return nil
end

function TestAIUtil.request(options)
	options = options or {}

	local request = requestImpl()
	if type(request) ~= "function" then
		return nil, "HTTP request is not available"
	end

	local body = options.Body or options.body
	if type(body) == "table" then
		local encoded, err = jsonEncode(body)
		if not encoded then
			return nil, err
		end
		body = encoded
	end

	local headers = options.Headers or options.headers or {}
	if body and not headers["Content-Type"] then
		headers["Content-Type"] = "application/json"
	end

	local ok, response = pcall(request, {
		Url = options.Url or options.url,
		Method = options.Method or options.method or "POST",
		Headers = headers,
		Body = body,
	})

	if not ok then
		return nil, response
	end

	local responseBody = response.Body or response.body or ""
	local decoded = jsonDecode(responseBody)
	return decoded or responseBody, response
end

function TestAIUtil.retry(callback, options)
	options = options or {}
	local attempts = options.Attempts or options.attempts or 3
	local delay = options.Delay or options.delay or 0.5
	local lastErr

	for attempt = 1, attempts do
		local ok, result, extra = pcall(callback, attempt)
		if ok and result ~= nil then
			return result, extra
		end

		lastErr = ok and extra or result
		if attempt < attempts then
			sleep(delay * attempt)
		end
	end

	return nil, lastErr or "Retry failed"
end

function TestAIUtil.createClient(config)
	config = config or {}

	local client = {}
	client.Url = config.Url or config.url
	client.ApiKey = config.ApiKey or config.apiKey
	client.Model = config.Model or config.model
	client.SystemPrompt = config.SystemPrompt or config.systemPrompt or DEFAULT_SYSTEM_PROMPT
	client.Headers = config.Headers or config.headers or {}

	function client:complete(prompt, options)
		options = options or {}

		local headers = {}
		for key, value in pairs(self.Headers) do
			headers[key] = value
		end
		if self.ApiKey and not headers.Authorization then
			headers.Authorization = "Bearer " .. self.ApiKey
		end

		local body = options.Body or options.body or {
			model = options.Model or options.model or self.Model,
			messages = options.Messages or options.messages or TestAIUtil.messages(prompt, options.SystemPrompt or self.SystemPrompt, options.History or options.history),
			temperature = options.Temperature or options.temperature,
			max_tokens = options.MaxTokens or options.maxTokens,
		}

		local response, raw = TestAIUtil.request({
			Url = options.Url or options.url or self.Url,
			Method = options.Method or options.method or "POST",
			Headers = headers,
			Body = body,
		})

		if not response then
			return nil, raw
		end

		return TestAIUtil.extractText(response), response, raw
	end

	return client
end

function TestAIUtil.parseJson(text)
	return jsonDecode(text)
end

function TestAIUtil.toJson(value)
	return jsonEncode(value)
end

TestAIUtil.Message = TestAIUtil.message
TestAIUtil.System = TestAIUtil.system
TestAIUtil.User = TestAIUtil.user
TestAIUtil.Assistant = TestAIUtil.assistant
TestAIUtil.Messages = TestAIUtil.messages
TestAIUtil.ExtractText = TestAIUtil.extractText
TestAIUtil.Request = TestAIUtil.request
TestAIUtil.Retry = TestAIUtil.retry
TestAIUtil.CreateClient = TestAIUtil.createClient
TestAIUtil.ParseJson = TestAIUtil.parseJson
TestAIUtil.ToJson = TestAIUtil.toJson

return TestAIUtil
