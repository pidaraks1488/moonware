-- load builder
local Builder = loadstring(game:HttpGet("https://raw.githubusercontent.com/pidaraks1488/moonware/refs/heads/main/src/builder.lua"))()
local UTILS_URL = "https://raw.githubusercontent.com/pidaraks1488/moonware/refs/heads/main/src/utils/"

local function safeLoadUtil(name)
	local ok, result = pcall(function()
		return loadstring(game:HttpGet(UTILS_URL .. name .. ".lua"))()
	end)
	if ok then
		return result
	end
	warn("Failed to load " .. name .. ":", result)
	return nil
end

local Base64 = safeLoadUtil("base64")
local XOR = safeLoadUtil("xor")
local CacheUtil = safeLoadUtil("cacheutil")
local Files = safeLoadUtil("files")
local AI = safeLoadUtil("testaiutil")

-- create window
local window = Builder.new({
	Title = "Example Moonware",
	ToggleKey = Enum.KeyCode.RightControl,
	Animation = "Default",
	TabAnimation = "Fade",
	TabAnimationEnabled = true,
	TabAnimationDuration = 0.18,
	Responsive = true,
	ResponsiveMargin = 16,
	MinScale = 0.58,
	MaxScale = 1,
	BlurSize = 4,
	BackdropTransparency = 0.68,
	ConfirmTitle = "Unload script?",
	ConfirmMessage = "Are you sure you want to unload this script?",
	ConfirmYesText = "Yes",
	ConfirmNoText = "No",
	Width = 600,
	Height = 440,
	SidebarWidth = 144,
	TabHeight = 38,
	TabGap = 8,
	TabScrollEnabled = true,
	MaxVisibleTabs = 6,
	Config = {
		Enabled = true,
		Folder = "MoonwareExample",
		File = "default.json",
	},
	Themes = {
		Ocean = {
			Background = Color3.fromRGB(13, 22, 30),
			Panel = Color3.fromRGB(18, 31, 42),
			PanelLight = Color3.fromRGB(25, 42, 56),
			PanelHover = Color3.fromRGB(34, 56, 74),
			Text = Color3.fromRGB(235, 247, 255),
			Muted = Color3.fromRGB(139, 166, 184),
			Stroke = Color3.fromRGB(45, 72, 91),
			SoftStroke = Color3.fromRGB(36, 58, 74),
			Accent = Color3.fromRGB(72, 190, 235),
			AccentDark = Color3.fromRGB(38, 124, 158),
			Good = Color3.fromRGB(112, 220, 154),
			Bad = Color3.fromRGB(232, 103, 116),
		},
	},
})

-- custom theme
window:RegisterTheme("Candy", {
	Background = Color3.fromRGB(28, 20, 28),
	Panel = Color3.fromRGB(39, 27, 39),
	PanelLight = Color3.fromRGB(51, 36, 52),
	PanelHover = Color3.fromRGB(67, 45, 68),
	Text = Color3.fromRGB(255, 244, 252),
	Muted = Color3.fromRGB(190, 150, 180),
	Stroke = Color3.fromRGB(79, 54, 80),
	SoftStroke = Color3.fromRGB(66, 45, 68),
	Accent = Color3.fromRGB(255, 118, 190),
	AccentDark = Color3.fromRGB(177, 62, 124),
	Good = Color3.fromRGB(112, 220, 154),
	Bad = Color3.fromRGB(232, 103, 116),
})

-- script values
local state = {
	enabled = false,
	espBoxes = false,
	espNames = true,
	distance = 1200,
	mode = "Legit",
	target = nil,
	accent = Color3.fromRGB(88, 214, 190),
	configName = "Default",
}

-- tabs
local main = window:CreateTab("Main", "lucide-home")
local visuals = window:CreateTab("Visuals", "lucide-eye")
local settings = window:CreateTab("Settings", "lucide-settings")
local themes = window:CreateTab("Themes", "lucide-palette")
local utils = window:CreateTab("Utils", "lucide-box")

-- combat controls
local combat = main:Section("Combat")
combat:Toggle("Enable script", state.enabled, function(enabled)
	state.enabled = enabled
	print("Script enabled:", enabled)
end, 1)

combat:Button("Run action", function()
	print("Action clicked. Current mode:", state.mode)
end, 2)

combat:Keybind("Quick action", Enum.KeyCode.V, function(value)
	print("Quick action:", value)
end, 3)

combat:Dropdown("Mode", { "Legit", "Rage", "Silent" }, state.mode, function(value)
	state.mode = value
	print("Mode:", value)
end, 4)

combat:List("Targets", { "PlayerOne", "PlayerTwo", "PlayerThree" }, function(value)
	state.target = value
	print("Selected target:", value)
end, 5)

-- movement controls
local movement = main:Section("Movement")
movement:Slider("Walk speed", 16, 100, 16, 1, function(value)
	print("Walk speed:", value)
end, 1)
movement:Toggle("Auto jump", false, function(enabled)
	print("Auto jump:", enabled)
end, 2)

-- visual controls
local esp = visuals:Section("ESP")
esp:Paragraph("Preview", "Configure what should be visible on screen.")
esp:Toggle("Boxes", state.espBoxes, function(enabled)
	state.espBoxes = enabled
	print("Boxes:", enabled)
end)
esp:Toggle("Names", state.espNames, function(enabled)
	state.espNames = enabled
	print("Names:", enabled)
end)
esp:Slider("Distance", 50, 5000, state.distance, 5, function(value)
	state.distance = value
	print("Distance:", value)
end)
esp:ColorPicker("ESP color", state.accent, function(color)
	state.accent = color
	print("ESP color:", color)
end)

-- ui controls
local ui = settings:Section("UI")
ui:Textbox("Config name", "Type config name", state.configName, function(value)
	state.configName = value
	print("Config name:", value)
end, 1)

ui:Dropdown("Tab animation", { "None", "Fade", "Slide", "Scale" }, "Fade", function(value)
	window:SetTabAnimation(value, value ~= "None", 0.18)
	print("Tab animation:", value)
end, 2)

ui:Slider("Blur", 0, 24, 4, 1, function(value)
	window.BlurSize = value
	window.Blur.Size = value
	print("Blur:", value)
end, 3)

-- unload ui
ui:Button("Destroy GUI", function()
	window:Destroy()
end, 4)

-- theme controls
local themeSection = themes:Section("Theme")
themeSection:Dropdown("Preset", window:GetThemes(), "Black", function(value)
	window:SetTheme(value)
	print("Theme:", value)
end, 1)

window:CreateConfigSection(settings, "Configs")

-- utility examples
local encodeSection = utils:Section("Encoding")
local base64Preview = "base64.lua is not loaded"
if Base64 then
	local encoded = Base64.encode("Moonware")
	local decoded = Base64.decode(encoded)
	base64Preview = encoded .. " -> " .. tostring(decoded)
end
encodeSection:Paragraph("Base64", base64Preview, 1)

local xorPreview = "xor.lua is not loaded"
if XOR then
	local encrypted = XOR.encryptHex("Moonware", "secret")
	local decrypted = XOR.decryptHex(encrypted, "secret")
	xorPreview = encrypted .. " -> " .. tostring(decrypted)
end
encodeSection:Paragraph("XOR", xorPreview, 2)

local cacheSection = utils:Section("Cache")
local cachePreview = "cacheutil.lua is not loaded"
local rememberPreview = "cacheutil.lua is not loaded"
if CacheUtil then
	local cache = CacheUtil.new({
		DefaultTtl = 10,
		MaxSize = 20,
	})
	cache:set("username", "Moonware")
	cachePreview = "username = " .. tostring(cache:get("username", "missing"))
	local value = cache:remember("expensive", 10, function()
		return "created once"
	end)
	rememberPreview = "expensive = " .. tostring(value)
end
cacheSection:Paragraph("Cache set/get", cachePreview, 1)
cacheSection:Paragraph("Cache remember", rememberPreview, 2)

local fileSection = utils:Section("Files")
local filePreview = "files.lua is not loaded"
local jsonPreview = "files.lua is not loaded"
if Files then
	local ok, err = Files.write("MoonwareExample/utils.txt", "hello from files.lua")
	if ok then
		local content = Files.read("MoonwareExample/utils.txt")
		filePreview = "utils.txt = " .. tostring(content)
	else
		filePreview = "Write failed: " .. tostring(err)
	end

	local jsonOk, jsonErr = Files.writeJson("MoonwareExample/state.json", {
		enabled = state.enabled,
		mode = state.mode,
		distance = state.distance,
	})
	if jsonOk then
		local data = Files.readJson("MoonwareExample/state.json")
		jsonPreview = "state.mode = " .. tostring(data and data.mode)
	else
		jsonPreview = "JSON write failed: " .. tostring(jsonErr)
	end
end
fileSection:Paragraph("Write/read file", filePreview, 1)
fileSection:Paragraph("JSON file", jsonPreview, 2)

local aiSection = utils:Section("AI")
local messagesPreview = "testaiutil.lua is not loaded"
local extractPreview = "testaiutil.lua is not loaded"
if AI then
	local messages = AI.messages("Say hello", "You are Moonware AI")
	messagesPreview = AI.toJson(messages) or "JSON encode failed"

	local text = AI.extractText({
		choices = {
			{
				message = {
					content = "Hello from AI utility",
				},
			},
		},
	})
	extractPreview = tostring(text)
end
aiSection:Paragraph("Messages", messagesPreview, 1)
aiSection:Paragraph("Extract text", extractPreview, 2)

return window
