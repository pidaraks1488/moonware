local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Builder = {}
Builder.__index = Builder

local THEME = {
	Background = Color3.fromRGB(17, 18, 21),
	Panel = Color3.fromRGB(24, 26, 30),
	PanelLight = Color3.fromRGB(31, 34, 39),
	PanelHover = Color3.fromRGB(39, 43, 49),
	Text = Color3.fromRGB(244, 244, 242),
	Muted = Color3.fromRGB(150, 153, 158),
	Stroke = Color3.fromRGB(50, 54, 61),
	SoftStroke = Color3.fromRGB(39, 43, 50),
	Accent = Color3.fromRGB(88, 214, 190),
	AccentDark = Color3.fromRGB(43, 140, 126),
	Good = Color3.fromRGB(112, 220, 154),
	Bad = Color3.fromRGB(232, 103, 116),
}

local THEME_PRESETS = {
	Black = {
		Background = Color3.fromRGB(17, 18, 21),
		Panel = Color3.fromRGB(24, 26, 30),
		PanelLight = Color3.fromRGB(31, 34, 39),
		PanelHover = Color3.fromRGB(39, 43, 49),
		Text = Color3.fromRGB(244, 244, 242),
		Muted = Color3.fromRGB(150, 153, 158),
		Stroke = Color3.fromRGB(50, 54, 61),
		SoftStroke = Color3.fromRGB(39, 43, 50),
		Accent = Color3.fromRGB(88, 214, 190),
		AccentDark = Color3.fromRGB(43, 140, 126),
		Good = Color3.fromRGB(112, 220, 154),
		Bad = Color3.fromRGB(232, 103, 116),
	},
	Purple = {
		Background = Color3.fromRGB(20, 18, 28),
		Panel = Color3.fromRGB(29, 25, 41),
		PanelLight = Color3.fromRGB(39, 33, 55),
		PanelHover = Color3.fromRGB(51, 42, 73),
		Text = Color3.fromRGB(248, 245, 255),
		Muted = Color3.fromRGB(174, 166, 194),
		Stroke = Color3.fromRGB(68, 58, 91),
		SoftStroke = Color3.fromRGB(56, 48, 75),
		Accent = Color3.fromRGB(174, 119, 255),
		AccentDark = Color3.fromRGB(120, 75, 190),
		Good = Color3.fromRGB(112, 220, 154),
		Bad = Color3.fromRGB(232, 103, 116),
	},
	White = {
		Background = Color3.fromRGB(238, 240, 243),
		Panel = Color3.fromRGB(226, 229, 234),
		PanelLight = Color3.fromRGB(216, 220, 228),
		PanelHover = Color3.fromRGB(204, 210, 220),
		Text = Color3.fromRGB(24, 27, 32),
		Muted = Color3.fromRGB(95, 101, 112),
		Stroke = Color3.fromRGB(188, 194, 204),
		SoftStroke = Color3.fromRGB(198, 204, 214),
		Accent = Color3.fromRGB(42, 150, 220),
		AccentDark = Color3.fromRGB(26, 104, 158),
		Good = Color3.fromRGB(40, 170, 95),
		Bad = Color3.fromRGB(218, 80, 94),
	},
	Green = {
		Background = Color3.fromRGB(15, 22, 19),
		Panel = Color3.fromRGB(21, 32, 27),
		PanelLight = Color3.fromRGB(29, 43, 36),
		PanelHover = Color3.fromRGB(39, 57, 48),
		Text = Color3.fromRGB(239, 248, 243),
		Muted = Color3.fromRGB(147, 170, 157),
		Stroke = Color3.fromRGB(45, 68, 56),
		SoftStroke = Color3.fromRGB(37, 56, 47),
		Accent = Color3.fromRGB(91, 220, 150),
		AccentDark = Color3.fromRGB(47, 145, 91),
		Good = Color3.fromRGB(112, 220, 154),
		Bad = Color3.fromRGB(232, 103, 116),
	},
	Red = {
		Background = Color3.fromRGB(24, 17, 19),
		Panel = Color3.fromRGB(34, 23, 27),
		PanelLight = Color3.fromRGB(45, 30, 36),
		PanelHover = Color3.fromRGB(61, 39, 47),
		Text = Color3.fromRGB(255, 244, 246),
		Muted = Color3.fromRGB(183, 151, 157),
		Stroke = Color3.fromRGB(77, 48, 57),
		SoftStroke = Color3.fromRGB(62, 40, 47),
		Accent = Color3.fromRGB(235, 91, 112),
		AccentDark = Color3.fromRGB(166, 50, 68),
		Good = Color3.fromRGB(112, 220, 154),
		Bad = Color3.fromRGB(235, 91, 112),
	},
}

local ICON_SOURCE = "https://raw.githubusercontent.com/pidaraks1488/moonware/refs/heads/main/src/Icons.lua"

local ICON_KEYS = {
	Main = "lucide-home",
	Visuals = "lucide-eye",
	Settings = "lucide-settings",
	Notification = "lucide-keyboard",
}

local FALLBACK_ICONS = {
	["lucide-home"] = "rbxassetid://10723407389",
	["lucide-eye"] = "rbxassetid://10723346959",
	["lucide-settings"] = "rbxassetid://10734950309",
	["lucide-keyboard"] = "rbxassetid://10723407389",
}

local ICONS = {}
local ICON_SOURCE_TEXT = nil

local function tween(object, info, props)
	local t = TweenService:Create(object, info or TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function fetchUrl(url)
	local ok, body = pcall(function()
		if game.HttpGet then
			return game:HttpGet(url)
		end
	end)
	if ok and type(body) == "string" and #body > 0 then
		return body
	end

	ok, body = pcall(function()
		return HttpService:GetAsync(url)
	end)
	if ok and type(body) == "string" and #body > 0 then
		return body
	end

	local request = syn and syn.request or http_request or request
	if type(request) == "function" then
		ok, body = pcall(function()
			local response = request({
				Url = url,
				Method = "GET",
			})
			return response and (response.Body or response.body)
		end)
		if ok and type(body) == "string" and #body > 0 then
			return body
		end
	end

	return nil
end

local function parseIcons(source, keys)
	local parsed = {}
	for _, key in pairs(keys) do
		local pattern = '%["' .. key:gsub("%-", "%%-") .. '"%]%s*=%s*"(rbxassetid://%d+)"'
		local asset = source:match(pattern)
		if asset then
			parsed[key] = asset
		end
	end
	return parsed
end

local function loadIconsFromSource(url, keys)
	local loaded = {}
	ICON_SOURCE_TEXT = nil

	for key, asset in pairs(FALLBACK_ICONS) do
		loaded[key] = asset
	end

	local source = fetchUrl(url)
	if source then
		ICON_SOURCE_TEXT = source
		local parsed = parseIcons(source, keys)
		for key, asset in pairs(parsed) do
			loaded[key] = asset
		end
	end

	return loaded
end

local function resolveIcon(icon)
	if not icon then
		return nil
	end
	if icon:match("^rbxassetid://") then
		return icon
	end
	if not ICONS[icon] and ICON_SOURCE_TEXT then
		local parsed = parseIcons(ICON_SOURCE_TEXT, { icon })
		ICONS[icon] = parsed[icon]
	end
	return ICONS[icon] or FALLBACK_ICONS[icon]
end

local function formatKeyCode(key)
	if typeof(key) ~= "EnumItem" then
		return tostring(key or "Unknown")
	end

	local names = {
		RightControl = "Right Ctrl",
		LeftControl = "Left Ctrl",
		RightShift = "Right Shift",
		LeftShift = "Left Shift",
		RightAlt = "Right Alt",
		LeftAlt = "Left Alt",
	}

	return names[key.Name] or key.Name
end

local function makeMaskName(prefix)
	local raw = HttpService:GenerateGUID(false):gsub("%-", "")
	return (prefix or "CoreGui") .. "_" .. raw:sub(1, 10)
end

local function addCorner(parent, radius)
	local ui = Instance.new("UICorner")
	ui.CornerRadius = UDim.new(0, radius or 8)
	ui.Parent = parent
	return ui
end

local function sendMenuKeyNotification(parent, title, message, key, icon)
	task.defer(function()
		if not parent or not parent.Parent then
			return
		end

		local toast = Instance.new("CanvasGroup")
		toast.Name = makeMaskName("Layer")
		toast.AnchorPoint = Vector2.new(1, 0)
		toast.BackgroundColor3 = THEME.Panel
		toast.BackgroundTransparency = 0.04
		toast.BorderSizePixel = 0
		toast.GroupTransparency = 1
		toast.Position = UDim2.new(1, 330, 0, 18)
		toast.Size = UDim2.fromOffset(304, 70)
		toast.ZIndex = 200
		toast.Parent = parent
		addCorner(toast, 10)

		local toastStroke = Instance.new("UIStroke")
		toastStroke.Color = THEME.SoftStroke
		toastStroke.Transparency = 0.18
		toastStroke.Thickness = 1
		toastStroke.Parent = toast

		local iconHolder = Instance.new("Frame")
		iconHolder.BackgroundColor3 = THEME.PanelLight
		iconHolder.BorderSizePixel = 0
		iconHolder.Position = UDim2.fromOffset(12, 14)
		iconHolder.Size = UDim2.fromOffset(42, 42)
		iconHolder.ZIndex = 201
		iconHolder.Parent = toast
		addCorner(iconHolder, 9)

		local iconImage = Instance.new("ImageLabel")
		iconImage.BackgroundTransparency = 1
		iconImage.ImageColor3 = THEME.Accent
		iconImage.Position = UDim2.fromOffset(10, 10)
		iconImage.Size = UDim2.fromOffset(22, 22)
		iconImage.ZIndex = 202
		iconImage.Parent = iconHolder
		local resolvedIcon = resolveIcon(icon)
		if resolvedIcon then
			iconImage.Image = resolvedIcon
		end

		local titleLabel = Instance.new("TextLabel")
		titleLabel.BackgroundTransparency = 1
		titleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
		titleLabel.Position = UDim2.fromOffset(66, 13)
		titleLabel.Size = UDim2.new(1, -82, 0, 22)
		titleLabel.Text = title or "Menu ready"
		titleLabel.TextColor3 = THEME.Text
		titleLabel.TextSize = 14
		titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.ZIndex = 201
		titleLabel.Parent = toast

		local bodyLabel = Instance.new("TextLabel")
		bodyLabel.BackgroundTransparency = 1
		bodyLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
		bodyLabel.Position = UDim2.fromOffset(66, 36)
		bodyLabel.Size = UDim2.new(1, -82, 0, 20)
		bodyLabel.Text = message or ("Open/close menu: " .. formatKeyCode(key))
		bodyLabel.TextColor3 = THEME.Muted
		bodyLabel.TextSize = 12
		bodyLabel.TextTruncate = Enum.TextTruncate.AtEnd
		bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
		bodyLabel.ZIndex = 201
		bodyLabel.Parent = toast

		local inTween = tween(toast, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			GroupTransparency = 0,
			Position = UDim2.new(1, -18, 0, 18),
		})
		inTween.Completed:Wait()

		task.wait(5)
		if toast.Parent then
			local out = tween(toast, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				GroupTransparency = 1,
				Position = UDim2.new(1, 330, 0, 18),
			})
			out.Completed:Wait()
			if toast.Parent then
				toast:Destroy()
			end
		end
	end)
end

local function setupAutoHideScrollBar(scroller, shownTransparency, hiddenTransparency, idleDelay)
	shownTransparency = shownTransparency or 0
	hiddenTransparency = hiddenTransparency or 1
	idleDelay = idleDelay or 0.75

	scroller:SetAttribute("OpenScrollBarTransparency", shownTransparency)
	scroller:SetAttribute("HiddenScrollBarTransparency", hiddenTransparency)
	scroller.ScrollBarImageTransparency = hiddenTransparency

	local hideToken = 0
	local lastPosition = scroller.CanvasPosition

	local function show()
		if scroller.ScrollingEnabled == false or scroller.Active == false then
			return
		end

		hideToken += 1
		local token = hideToken

		tween(scroller, TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			ScrollBarImageTransparency = shownTransparency,
		})

		task.delay(idleDelay, function()
			if token ~= hideToken or not scroller.Parent then
				return
			end
			tween(scroller, TweenInfo.new(0.34, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				ScrollBarImageTransparency = hiddenTransparency,
			})
		end)
	end

	scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		local currentPosition = scroller.CanvasPosition
		if currentPosition ~= lastPosition then
			lastPosition = currentPosition
			show()
		end
	end)
end

local function corner(parent, radius)
	local ui = Instance.new("UICorner")
	ui.CornerRadius = UDim.new(0, radius or 8)
	ui.Parent = parent
	return ui
end

local function themeKeyForColor(color)
	for key, value in pairs(THEME) do
		if color == value then
			return key
		end
	end
	return nil
end

local function stroke(parent, color, transparency, thickness)
	local ui = Instance.new("UIStroke")
	ui.Color = color or Color3.fromRGB(255, 255, 255)
	ui.Transparency = transparency or 0.82
	ui.Thickness = thickness or 1
	ui.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ui.Parent = parent
	ui:SetAttribute("OpenTransparency", ui.Transparency)
	local key = themeKeyForColor(ui.Color)
	if key then
		ui:SetAttribute("ThemeStroke", key)
	end
	return ui
end

local function themeBg(object, key)
	object:SetAttribute("ThemeBg", key)
	object.BackgroundColor3 = THEME[key]
	return object
end

local function themeText(object, key)
	object:SetAttribute("ThemeText", key)
	object.TextColor3 = THEME[key]
	return object
end

local function themeImage(object, key)
	object:SetAttribute("ThemeImage", key)
	object.ImageColor3 = THEME[key]
	return object
end

local function themeStroke(object, key)
	object:SetAttribute("ThemeStroke", key)
	object.Color = THEME[key]
	return object
end

local function formatNumber(value, step)
	local decimals = 0
	local stepText = tostring(step or 1)
	local dot = stepText:find("%.")

	if dot then
		decimals = #stepText - dot
	end

	local text = string.format("%." .. decimals .. "f", value)
	if decimals > 0 then
		text = text:gsub("0+$", ""):gsub("%.$", "")
	end

	return text
end

local function padding(parent, px)
	local ui = Instance.new("UIPadding")
	ui.PaddingTop = UDim.new(0, px)
	ui.PaddingBottom = UDim.new(0, px)
	ui.PaddingLeft = UDim.new(0, px)
	ui.PaddingRight = UDim.new(0, px)
	ui.Parent = parent
	return ui
end

local function shadow(parent, radius, transparency)
	radius = radius or 48

	local img = Instance.new("ImageLabel")
	img.Name = "UIShadow"
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://6014261993"
	img.ImageColor3 = Color3.fromRGB(0, 0, 0)
	img.ImageTransparency = transparency or 0.52
	img.Position = parent.Position
	img.Size = UDim2.new(parent.Size.X.Scale, parent.Size.X.Offset + radius, parent.Size.Y.Scale, parent.Size.Y.Offset + radius)
	img.ScaleType = Enum.ScaleType.Slice
	img.SliceCenter = Rect.new(49, 49, 450, 450)
	img.ZIndex = math.max(0, parent.ZIndex - 2)
	img.Parent = parent.Parent
	img:SetAttribute("Radius", radius)
	img:SetAttribute("OpenImage", img.ImageTransparency)
	return img
end

local function makeLabel(parent, text, size, color, weight)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", weight or Enum.FontWeight.Medium)
	label.Text = text
	label.TextColor3 = color or THEME.Text
	label.TextSize = size or 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	local key = themeKeyForColor(label.TextColor3)
	if key then
		label:SetAttribute("ThemeText", key)
	end
	return label
end

local function makeIconButton(parent, text, xOffset)
	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0)
	button.AutoButtonColor = false
	button.BackgroundColor3 = THEME.PanelLight
	button.BackgroundTransparency = 0
	button.BorderSizePixel = 0
	button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
	button.Position = UDim2.new(1, xOffset, 0, 0)
	button.Size = UDim2.fromOffset(28, 28)
	button.Text = text
	button.TextColor3 = THEME.Muted
	button.TextSize = 14
	button.ZIndex = 14
	button.Parent = parent
	button:SetAttribute("ThemeBg", "PanelLight")
	button:SetAttribute("ThemeText", "Muted")
	corner(button, 7)
	return button
end

local function applyOrder(object, order)
	if order ~= nil then
		object.LayoutOrder = order
	end
	return object
end

local function scaleUDim2(size, multiplier)
	return UDim2.new(
		size.X.Scale * multiplier,
		math.floor(size.X.Offset * multiplier + 0.5),
		size.Y.Scale * multiplier,
		math.floor(size.Y.Offset * multiplier + 0.5)
	)
end

local function isPressInput(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isDragInput(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function normalizeWindowAnimation(animation, fallback)
	animation = animation or fallback or "Default"
	if animation == "Default" or animation == "Fade" then
		return animation
	end
	return fallback or "Default"
end

local function normalizeTabAnimation(animation, fallback)
	animation = animation or fallback or "Fade"
	if animation == "Default" then
		return "Fade"
	end
	if animation == "Fade" or animation == "Slide" or animation == "Scale" or animation == "None" then
		return animation
	end
	return fallback or "Fade"
end

local function copyTheme(theme)
	local copy = {}
	for key, value in pairs(theme) do
		copy[key] = value
	end
	return copy
end

local function sanitizeKey(text)
	return tostring(text or "item"):gsub("[^%w_%-]+", "_"):gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
end

local function splitOrderOptions(order)
	if type(order) == "table" then
		return order.Order or order.order, order
	end
	return order, nil
end

local function encodeConfig(values)
	local parts = {}
	for key, value in pairs(values) do
		local valueType = typeof(value)
		if valueType == "boolean" or valueType == "number" or valueType == "string" then
			table.insert(parts, HttpService:JSONEncode(key) .. ":" .. HttpService:JSONEncode(value))
		elseif valueType == "Color3" then
			table.insert(parts, HttpService:JSONEncode(key) .. ":" .. HttpService:JSONEncode({
				__type = "Color3",
				r = math.floor(value.R * 255 + 0.5),
				g = math.floor(value.G * 255 + 0.5),
				b = math.floor(value.B * 255 + 0.5),
			}))
		elseif valueType == "EnumItem" then
			table.insert(parts, HttpService:JSONEncode(key) .. ":" .. HttpService:JSONEncode({
				__type = "EnumItem",
				enum = tostring(value.EnumType),
				name = value.Name,
			}))
		end
	end
	table.sort(parts)
	return "{" .. table.concat(parts, ",") .. "}"
end

local function decodeConfig(text)
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(text)
	end)
	if not ok or type(decoded) ~= "table" then
		return nil
	end

	for key, value in pairs(decoded) do
		if type(value) == "table" and value.__type == "Color3" then
			decoded[key] = Color3.fromRGB(value.r or 255, value.g or 255, value.b or 255)
		elseif type(value) == "table" and value.__type == "EnumItem" and type(value.enum) == "string" then
			local enumName = value.enum:match("Enum%.(.+)")
			if enumName and Enum[enumName] and value.name then
				decoded[key] = Enum[enumName][value.name]
			end
		end
	end

	return decoded
end

function Builder.new(config)
	config = config or {}

	local self = setmetatable({}, Builder)
	self.Tabs = {}
	self.CurrentTab = nil
	self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
	self.Open = false
	self.StartOpen = config.StartOpen ~= false
	self.OpenAnimation = normalizeWindowAnimation(config.OpenAnimation or config.Animation or "Default", "Default")
	self.CloseAnimation = normalizeWindowAnimation(config.CloseAnimation or config.Animation or "Default", "Default")
	self.TabAnimation = normalizeTabAnimation(config.TabAnimation or "Fade", "Fade")
	self.TabAnimationEnabled = config.TabAnimationEnabled ~= false
	self.TabAnimationDuration = config.TabAnimationDuration or 0.18
	self.Size = config.Size or UDim2.fromOffset(config.Width or 600, config.Height or 360)
	self.DisplaySize = self.Size
	self.Responsive = config.Responsive ~= false
	self.ResponsiveMargin = config.ResponsiveMargin or 16
	self.MinScale = config.MinScale or 0.58
	self.MaxScale = config.MaxScale or 1
	self.BlurSize = config.BlurSize or 4
	self.BackdropTransparency = config.BackdropTransparency or 0.68
	self.ConfirmTitle = config.ConfirmTitle or "Unload script?"
	self.ConfirmMessage = config.ConfirmMessage or "Are you sure you want to unload this script?"
	self.ConfirmYesText = config.ConfirmYesText or "Yes"
	self.ConfirmNoText = config.ConfirmNoText or "No"
	self.Title = (type(config.Title) == "string" and config.Title ~= "") and config.Title or "Untitled Moonware Script"
	self.SidebarWidth = config.SidebarWidth or 144
	self.SidebarHeight = config.SidebarHeight
	self.TabHeight = config.TabHeight or 38
	self.TabGap = config.TabGap or 8
	self.TabScrollEnabled = config.TabScrollEnabled == true or config.TabScroll == true
	self.MaxVisibleTabs = config.MaxVisibleTabs or config.TabLimit or 6
	self.ConfigControls = {}
	self.Config = config.Config or {}
	self.ConfigEnabled = self.Config.Enabled == true
	self.ConfigFolder = self.Config.Folder or "Moonware"
	self.ConfigFile = self.Config.File or (self.Title .. ".json")
	self.ThemePresets = {}
	for name, theme in pairs(THEME_PRESETS) do
		self.ThemePresets[name] = copyTheme(theme)
	end
	if config.Themes then
		for name, theme in pairs(config.Themes) do
			self.ThemePresets[name] = copyTheme(theme)
		end
	end
	self.IconKeys = {}

	for tabName, iconKey in pairs(ICON_KEYS) do
		self.IconKeys[tabName] = iconKey
	end
	if config.Icons then
		for tabName, iconKey in pairs(config.Icons) do
			self.IconKeys[tabName] = iconKey
		end
	end
	self.NotificationIcon = config.NotificationIcon or self.IconKeys.Notification or "lucide-keyboard"
	self.IconKeys.Notification = self.NotificationIcon

	ICONS = loadIconsFromSource(config.IconSource or ICON_SOURCE, self.IconKeys)

	for _, child in ipairs(PlayerGui:GetChildren()) do
		if child:IsA("ScreenGui") and child:GetAttribute("MoonwareBuilder") == true then
			child:Destroy()
		end
	end

	local blur = Lighting:FindFirstChild("BuilderBlur") or Instance.new("BlurEffect")
	blur.Name = "BuilderBlur"
	blur.Size = 0
	blur.Parent = Lighting
	self.Blur = blur

	local gui = Instance.new("ScreenGui")
	gui.Name = config.GuiName or makeMaskName(config.GuiNamePrefix or "RobloxGui")
	gui:SetAttribute("MoonwareBuilder", true)
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui
	self.Gui = gui

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = self.BackdropTransparency
	backdrop.BorderSizePixel = 0
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.ZIndex = 6
	backdrop.Parent = gui
	self.Backdrop = backdrop

	local holder = Instance.new("Frame")
	holder.Name = "Holder"
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.Position = UDim2.fromScale(0.5, 0.5)
	holder.Size = self.Size
	holder.ZIndex = 8
	holder.Parent = gui
	self.Holder = holder

	local holderScale = Instance.new("UIScale")
	holderScale.Scale = 1
	holderScale.Parent = holder
	self.Scale = holderScale
	self:ApplyResponsiveSize()

	local function bindCamera(camera)
		if self.ViewportConnection then
			self.ViewportConnection:Disconnect()
			self.ViewportConnection = nil
		end
		if camera then
			self.ViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				self:ApplyResponsiveSize()
			end)
		end
	end

	bindCamera(workspace.CurrentCamera)
	self.CameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		bindCamera(workspace.CurrentCamera)
		self:ApplyResponsiveSize()
	end)

	local root = Instance.new("CanvasGroup")
	root.Name = "Root"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.BackgroundColor3 = THEME.Background
	root.BackgroundTransparency = 0
	root.BorderSizePixel = 0
	root.GroupTransparency = 0
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = self.Size
	root.ZIndex = 10
	root.Parent = holder
	root:SetAttribute("ThemeBg", "Background")
	corner(root, 10)
	self.RootShadow = shadow(root, 56, 0.68)
	self.Root = root

	local function syncShadow()
		local radius = self.RootShadow:GetAttribute("Radius") or 72
		self.RootShadow.Position = root.Position
		self.RootShadow.Size = UDim2.new(root.Size.X.Scale, root.Size.X.Offset + radius, root.Size.Y.Scale, root.Size.Y.Offset + radius)
	end

	root:GetPropertyChangedSignal("Position"):Connect(syncShadow)
	root:GetPropertyChangedSignal("Size"):Connect(syncShadow)

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.BackgroundTransparency = 1
	titleBar.Size = UDim2.new(1, 0, 0, 62)
	titleBar.ZIndex = 12
	titleBar.Parent = root
	padding(titleBar, 18)

	local title = makeLabel(titleBar, self.Title, 21, THEME.Text, Enum.FontWeight.Bold)
	title.Position = UDim2.fromOffset(0, 0)
	title.Size = UDim2.new(1, -76, 1, 0)
	title.ZIndex = 13

	local closeButton = makeIconButton(titleBar, "x", -18)
	local hideButton = makeIconButton(titleBar, "-", -52)

	closeButton.MouseButton1Click:Connect(function()
		self:ShowConfirmClose()
	end)

	hideButton.MouseButton1Click:Connect(function()
		self:SetOpen(false)
	end)

	local sidebar = self.TabScrollEnabled and Instance.new("ScrollingFrame") or Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = THEME.Panel
	sidebar.BackgroundTransparency = 0
	sidebar.BorderSizePixel = 0
	sidebar.Position = UDim2.fromOffset(18, 70)
	sidebar.Size = self.SidebarHeight and UDim2.new(0, self.SidebarWidth, 0, self.SidebarHeight) or UDim2.new(0, self.SidebarWidth, 1, -88)
	sidebar.ZIndex = 12
	sidebar.Parent = root
	sidebar:SetAttribute("ThemeBg", "Panel")
	if sidebar:IsA("ScrollingFrame") then
		sidebar.Active = true
		sidebar.CanvasSize = UDim2.fromOffset(0, 0)
		sidebar.ScrollBarImageColor3 = THEME.Accent
		sidebar.ScrollBarThickness = 3
		sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
		sidebar:SetAttribute("OpenScrollBarThickness", sidebar.ScrollBarThickness)
		setupAutoHideScrollBar(sidebar)
	end
	corner(sidebar, 8)
	stroke(sidebar, THEME.SoftStroke, 0.4, 1)
	padding(sidebar, 8)

	local tabList = Instance.new("UIListLayout")
	tabList.Padding = UDim.new(0, self.TabGap)
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Parent = sidebar
	self.Sidebar = sidebar
	self.TabList = tabList

	local function updateSidebarSize()
		local contentHeight = tabList.AbsoluteContentSize.Y + 16
		if self.TabScrollEnabled then
			sidebar.CanvasSize = UDim2.fromOffset(0, contentHeight)
		end
	end

	tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarSize)
	self.UpdateSidebarSize = updateSidebarSize

	local pages = Instance.new("Frame")
	pages.Name = "Pages"
	pages.BackgroundTransparency = 1
	pages.Position = UDim2.fromOffset(self.SidebarWidth + 40, 70)
	pages.Size = UDim2.new(1, -(self.SidebarWidth + 62), 1, -88)
	pages.ZIndex = 12
	pages.Parent = root
	self.Pages = pages

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == self.ToggleKey then
			self:SetOpen(not self.Open)
		end
	end)

	self:MakeDraggable(titleBar)
	if config.Theme then
		self:SetTheme(config.Theme)
	end
	self:ApplyResponsiveSize()
	local initialSize = self.DisplaySize
	local initialCompactSize = scaleUDim2(initialSize, 0.98)
	self.Holder.Size = initialCompactSize
	self.Root.Size = initialCompactSize
	self.Root.GroupTransparency = 1
	self.RootShadow.ImageTransparency = 1
	self.Blur.Size = 0
	if self.Backdrop then
		self.Backdrop.BackgroundTransparency = 1
		self.Backdrop.Visible = self.StartOpen
	end
	self.Holder.Visible = self.StartOpen
	self.Root.Visible = self.StartOpen
	self.RootShadow.Visible = self.StartOpen
	if self.StartOpen then
		self:SetOpen(true)
	end
	if config.NotifyOnCreate ~= false then
		sendMenuKeyNotification(self.Gui, config.NotificationTitle or self.Title, config.NotificationText, self.ToggleKey, self.NotificationIcon)
	end
	return self
end

function Builder:SetOpen(open)
	self.Open = open
	self.AnimationId = (self.AnimationId or 0) + 1
	local animationId = self.AnimationId
	local animation = normalizeWindowAnimation(open and self.OpenAnimation or self.CloseAnimation, "Default")

	if open then
		if self.Backdrop then
			self.Backdrop.Visible = true
		end
		self.Holder.Visible = true
		self.Root.Visible = true
		self.RootShadow.Visible = true
	end

	local info = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	self:ApplyResponsiveSize()
	local targetSize = self.DisplaySize
	local compactSize = scaleUDim2(targetSize, 0.98)

	if open and animation ~= "Fade" then
		self.Holder.Size = compactSize
		self.Root.Size = compactSize
	end

	if animation == "Fade" then
		self.Holder.Size = targetSize
		self.Root.Size = targetSize
	else
		tween(self.Holder, info, { Size = open and targetSize or compactSize })
		tween(self.Root, info, { Size = open and targetSize or compactSize })
	end
	tween(self.Root, info, { GroupTransparency = open and 0 or 1 })
	tween(self.RootShadow, info, {
		ImageTransparency = open and 0.68 or 1,
	})
	tween(self.Blur, info, { Size = open and self.BlurSize or 0 })
	if self.Backdrop then
		tween(self.Backdrop, info, { BackgroundTransparency = open and self.BackdropTransparency or 1 })
	end

	task.delay(0.22, function()
		if not open and self.AnimationId == animationId then
			self.Holder.Visible = false
			if self.Backdrop then
				self.Backdrop.Visible = false
			end
		end
	end)
end

function Builder:SetAnimation(openAnimation, closeAnimation)
	if openAnimation then
		self.OpenAnimation = normalizeWindowAnimation(openAnimation, self.OpenAnimation)
	end
	if closeAnimation then
		self.CloseAnimation = normalizeWindowAnimation(closeAnimation, self.CloseAnimation)
	elseif openAnimation then
		self.CloseAnimation = normalizeWindowAnimation(openAnimation, self.CloseAnimation)
	end
end

function Builder:SetSize(sizeOrWidth, height)
	if typeof(sizeOrWidth) == "UDim2" then
		self.Size = sizeOrWidth
	else
		self.Size = UDim2.fromOffset(sizeOrWidth or 600, height or 360)
	end

	self.Holder.Size = self.Size
	self.Root.Size = self.Size
	self:ApplyResponsiveSize()
end

function Builder:ApplyResponsiveSize()
	if not self.Holder or not self.Root then
		return
	end

	if self.Scale then
		self.Scale.Scale = 1
	end

	if not self.Responsive then
		self.DisplaySize = self.Size
		self.Holder.Size = self.DisplaySize
		self.Root.Size = self.DisplaySize
		return
	end

	local viewport = getViewportSize()
	local margin = self.ResponsiveMargin or 16
	local width = math.max(viewport.X * self.Size.X.Scale + self.Size.X.Offset, 1)
	local height = math.max(viewport.Y * self.Size.Y.Scale + self.Size.Y.Offset, 1)
	local scale = math.min((viewport.X - margin * 2) / width, (viewport.Y - margin * 2) / height, self.MaxScale or 1)
	scale = math.clamp(scale, self.MinScale or 0.58, self.MaxScale or 1)
	self.DisplaySize = UDim2.fromOffset(math.floor(width * scale + 0.5), math.floor(height * scale + 0.5))
	self.Holder.Size = self.DisplaySize
	self.Root.Size = self.DisplaySize
end

function Builder:SetTabAnimation(animation, enabled, duration)
	if animation then
		self.TabAnimation = normalizeTabAnimation(animation, self.TabAnimation)
	end
	if enabled ~= nil then
		self.TabAnimationEnabled = enabled
	end
	if duration then
		self.TabAnimationDuration = duration
	end
end

function Builder:GetThemes()
	local themes = {}
	for name in pairs(self.ThemePresets or THEME_PRESETS) do
		table.insert(themes, name)
	end
	table.sort(themes)
	return themes
end

function Builder:GetTheme()
	return copyTheme(THEME)
end

function Builder:RegisterTheme(name, theme, apply)
	if type(name) ~= "string" or type(theme) ~= "table" then
		return false
	end

	self.ThemePresets = self.ThemePresets or {}
	self.ThemePresets[name] = copyTheme(theme)

	if apply then
		self:SetTheme(name)
	end

	return true
end

function Builder:SetTheme(theme)
	local presets = self.ThemePresets or THEME_PRESETS
	local preset = type(theme) == "string" and presets[theme] or theme
	if type(preset) ~= "table" then
		return false
	end

	local previous = {}
	for key, value in pairs(THEME) do
		previous[key] = value
	end

	for key, value in pairs(preset) do
		if THEME[key] ~= nil then
			THEME[key] = value
		end
	end

	local function remapColor(color)
		for key, oldColor in pairs(previous) do
			if color == oldColor and THEME[key] then
				return THEME[key]
			end
		end
		return color
	end

	if self.Root then
		self.Root.BackgroundColor3 = THEME.Background
	end
	if self.Sidebar then
		self.Sidebar.BackgroundColor3 = THEME.Panel
	end

	for _, object in ipairs(self.Gui:GetDescendants()) do
		if object:IsA("GuiObject") then
			local bgKey = object:GetAttribute("ThemeBg")
			if bgKey and THEME[bgKey] then
				object.BackgroundColor3 = THEME[bgKey]
			else
				object.BackgroundColor3 = remapColor(object.BackgroundColor3)
			end
			if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
				local textKey = object:GetAttribute("ThemeText")
				if textKey and THEME[textKey] then
					object.TextColor3 = THEME[textKey]
				else
					object.TextColor3 = remapColor(object.TextColor3)
				end
				if object:IsA("TextBox") then
					local placeholderKey = object:GetAttribute("ThemePlaceholder")
					if placeholderKey and THEME[placeholderKey] then
						object.PlaceholderColor3 = THEME[placeholderKey]
					else
						object.PlaceholderColor3 = remapColor(object.PlaceholderColor3)
					end
				end
			end
			if object:IsA("ImageLabel") or object:IsA("ImageButton") then
				local imageKey = object:GetAttribute("ThemeImage")
				if imageKey and THEME[imageKey] then
					object.ImageColor3 = THEME[imageKey]
				else
					object.ImageColor3 = remapColor(object.ImageColor3)
				end
			end
			if object:IsA("ScrollingFrame") then
				object.ScrollBarImageColor3 = THEME.Accent
			end
		elseif object:IsA("UIStroke") then
			local strokeKey = object:GetAttribute("ThemeStroke")
			if strokeKey and THEME[strokeKey] then
				object.Color = THEME[strokeKey]
			else
				object.Color = remapColor(object.Color)
			end
		end
	end

	if self.CurrentTab then
		self.CurrentTab:Select(true)
	end

	return true
end

function Builder:GetConfigPath(name)
	local fileName = name or self.ConfigFile or "config.json"
	if not fileName:match("%.json$") then
		fileName = fileName .. ".json"
	end
	return (self.ConfigFolder or "Moonware") .. "/" .. fileName
end

function Builder:RegisterConfigControl(flag, control)
	if not flag or not control or not control.Get or not control.Set then
		return control
	end
	self.ConfigControls[flag] = control
	return control
end

function Builder:GetConfigValues()
	local values = {}
	for flag, control in pairs(self.ConfigControls or {}) do
		local ok, value = pcall(control.Get)
		if ok then
			values[flag] = value
		end
	end
	return values
end

function Builder:ApplyConfigValues(values)
	if type(values) ~= "table" then
		return false
	end
	for flag, value in pairs(values) do
		local control = self.ConfigControls and self.ConfigControls[flag]
		if control and control.Set then
			pcall(control.Set, value)
		end
	end
	return true
end

function Builder:SaveConfig(name)
	if not self.ConfigEnabled then
		return false, "Config support is disabled"
	end
	if type(writefile) ~= "function" then
		return false, "writefile is not available"
	end
	if type(makefolder) == "function" then
		pcall(makefolder, self.ConfigFolder or "Moonware")
	end
	local path = self:GetConfigPath(name)
	local ok, err = pcall(writefile, path, encodeConfig(self:GetConfigValues()))
	return ok, err
end

function Builder:LoadConfig(name)
	if not self.ConfigEnabled then
		return false, "Config support is disabled"
	end
	if type(readfile) ~= "function" then
		return false, "readfile is not available"
	end
	local path = self:GetConfigPath(name)
	if type(isfile) == "function" and not isfile(path) then
		return false, "Config file does not exist"
	end
	local ok, content = pcall(readfile, path)
	if not ok then
		return false, content
	end
	local values = decodeConfig(content)
	if not values then
		return false, "Invalid config file"
	end
	self:ApplyConfigValues(values)
	return true
end

function Builder:CreateConfigSection(tab, title)
	if not tab or not tab.Section then
		return nil
	end
	local section = tab:Section(title or "Config")
	local defaultName = (self.ConfigFile or "config.json"):gsub("%.json$", "")
	local configName = defaultName

	section:Textbox("Config name", "config", defaultName, function(value)
		configName = value ~= "" and value or defaultName
	end)
	section:Button("Save config", function()
		self:SaveConfig(configName)
	end)
	section:Button("Load config", function()
		self:LoadConfig(configName)
	end)

	return section
end

function Builder:ShowConfirmClose()
	if self.ConfirmOpen then
		return
	end

	self.ConfirmOpen = true
	self:SetOpen(false)

	local overlay = self.Gui:FindFirstChild("ConfirmClose")
	if overlay then
		overlay:Destroy()
	end

	overlay = Instance.new("CanvasGroup")
	overlay.Name = "ConfirmClose"
	overlay.AnchorPoint = Vector2.new(0.5, 0.5)
	overlay.BackgroundColor3 = THEME.Background
	overlay.BackgroundTransparency = 0
	overlay.BorderSizePixel = 0
	overlay.GroupTransparency = 1
	overlay.Position = self.Holder.Position
	overlay.Size = UDim2.fromOffset(353, 147)
	overlay.ZIndex = 30
	overlay.Parent = self.Gui
	overlay:SetAttribute("ThemeBg", "Background")
	corner(overlay, 10)
	padding(overlay, 18)
	local overlayShadow = shadow(overlay, 58, 0.62)
	overlayShadow.ZIndex = 28

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = overlay

	local title = makeLabel(overlay, self.ConfirmTitle, 15, THEME.Text, Enum.FontWeight.Bold)
	title.Size = UDim2.new(1, 0, 0, 20)
	title.ZIndex = 31

	local question = makeLabel(overlay, self.ConfirmMessage, 12, THEME.Muted, Enum.FontWeight.Medium)
	question.Position = UDim2.fromOffset(0, 24)
	question.Size = UDim2.new(1, 0, 0, 36)
	question.TextWrapped = true
	question.TextYAlignment = Enum.TextYAlignment.Top
	question.ZIndex = 31

	local buttons = Instance.new("Frame")
	buttons.BackgroundTransparency = 1
	buttons.Position = UDim2.new(0, 0, 1, -44)
	buttons.Size = UDim2.new(1, 0, 0, 34)
	buttons.ZIndex = 31
	buttons.Parent = overlay

	local noButton = Instance.new("TextButton")
	noButton.AutoButtonColor = false
	noButton.BackgroundColor3 = THEME.PanelLight
	noButton.BackgroundTransparency = 0
	noButton.BorderSizePixel = 0
	noButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
	noButton.Size = UDim2.new(0.5, -5, 1, 0)
	noButton.Text = self.ConfirmNoText
	noButton.TextColor3 = THEME.Text
	noButton.TextSize = 13
	noButton.ZIndex = 32
	noButton.Parent = buttons
	noButton:SetAttribute("ThemeBg", "PanelLight")
	noButton:SetAttribute("ThemeText", "Text")
	corner(noButton, 7)

	local yesButton = Instance.new("TextButton")
	yesButton.AutoButtonColor = false
	yesButton.BackgroundColor3 = THEME.Bad
	yesButton.BackgroundTransparency = 0
	yesButton.BorderSizePixel = 0
	yesButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
	yesButton.Position = UDim2.new(0.5, 5, 0, 0)
	yesButton.Size = UDim2.new(0.5, -5, 1, 0)
	yesButton.Text = self.ConfirmYesText
	yesButton.TextColor3 = THEME.Text
	yesButton.TextSize = 13
	yesButton.ZIndex = 32
	yesButton.Parent = buttons
	yesButton:SetAttribute("ThemeBg", "Bad")
	yesButton:SetAttribute("ThemeText", "Text")
	corner(yesButton, 7)

	self.ConfirmOverlay = overlay
	self.ConfirmShadow = overlayShadow

	local info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	tween(overlay, info, {
		GroupTransparency = 0,
		Size = UDim2.fromOffset(360, 150),
	})
	tween(overlayShadow, info, { ImageTransparency = 0.62 })

	noButton.MouseButton1Click:Connect(function()
		self:HideConfirmClose(true)
	end)

	yesButton.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
end

function Builder:HideConfirmClose(reopen)
	if not self.ConfirmOverlay then
		self.ConfirmOpen = false
		if reopen then
			self:SetOpen(true)
		end
		return
	end

	local overlay = self.ConfirmOverlay
	local shadowImage = self.ConfirmShadow
	self.ConfirmOverlay = nil
	self.ConfirmShadow = nil
	self.ConfirmOpen = false

	local info = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	tween(overlay, info, {
		GroupTransparency = 1,
		Size = UDim2.fromOffset(353, 147),
	})
	if shadowImage then
		tween(shadowImage, info, { ImageTransparency = 1 })
	end
	task.delay(0.16, function()
		if overlay then
			overlay:Destroy()
		end
		if shadowImage then
			shadowImage:Destroy()
		end
		if reopen then
			self:SetOpen(true)
		end
	end)
end

function Builder:Destroy()
	if self.ViewportConnection then
		self.ViewportConnection:Disconnect()
		self.ViewportConnection = nil
	end
	if self.CameraConnection then
		self.CameraConnection:Disconnect()
		self.CameraConnection = nil
	end
	if self.ConfirmShadow then
		self.ConfirmShadow:Destroy()
	end
	if self.Gui then
		self.Gui:Destroy()
	end
	if self.Blur then
		self.Blur:Destroy()
	end
end

function Builder:MakeDraggable(handle)
	local dragging = false
	local dragStart
	local startPos

	handle.InputBegan:Connect(function(input)
		if isPressInput(input) then
			dragging = true
			dragStart = input.Position
			startPos = self.Holder.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if isPressInput(input) then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and isDragInput(input) then
			local delta = input.Position - dragStart
			self.Holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function Builder:CreateTab(name, icon)
	local tab = {}
	tab.Gui = self

	local button = Instance.new("TextButton")
	button.Name = name .. "Tab"
	button.AutoButtonColor = false
	button.BackgroundColor3 = THEME.PanelLight
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
	button.Size = UDim2.new(1, 0, 0, self.TabHeight)
	button.Text = ""
	button.TextColor3 = THEME.Muted
	button.TextSize = 13
	button.ZIndex = 13
	button.Parent = self.Sidebar
	button:SetAttribute("OpenBg", button.BackgroundTransparency)
	button:SetAttribute("ThemeBg", "PanelLight")
	button:SetAttribute("ThemeText", "Muted")
	corner(button, 7)

	local iconImage = Instance.new("ImageLabel")
	iconImage.Name = "Icon"
	iconImage.BackgroundTransparency = 1
	iconImage.Image = resolveIcon(icon) or resolveIcon(self.IconKeys[name]) or resolveIcon(ICON_KEYS.Main)
	iconImage.ImageColor3 = THEME.Muted
	iconImage.ImageTransparency = 0.04
	iconImage.Position = UDim2.fromOffset(12, math.floor((self.TabHeight - 18) / 2 + 0.5))
	iconImage.Size = UDim2.fromOffset(18, 18)
	iconImage.ZIndex = 14
	iconImage.Parent = button
	iconImage:SetAttribute("OpenImage", iconImage.ImageTransparency)
	iconImage:SetAttribute("ThemeImage", "Muted")

	local tabLabel = makeLabel(button, name, 13, THEME.Muted, Enum.FontWeight.SemiBold)
	tabLabel.Position = UDim2.fromOffset(40, 0)
	tabLabel.Size = UDim2.new(1, -48, 1, 0)
	tabLabel.ZIndex = 14

	local page = Instance.new("ScrollingFrame")
	page.Name = name .. "Page"
	page.Active = true
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.CanvasSize = UDim2.fromOffset(0, 0)
	page.ScrollBarImageColor3 = THEME.Accent
	page.ScrollBarThickness = 3
	page:SetAttribute("OpenScrollBarThickness", page.ScrollBarThickness)
	setupAutoHideScrollBar(page)
	page.Size = UDim2.fromScale(1, 1)
	page.ZIndex = 13
	page.Visible = false
	page.Parent = self.Pages

	local pageGroup = Instance.new("CanvasGroup")
	pageGroup.Name = "TabCanvas"
	pageGroup.BackgroundTransparency = 1
	pageGroup.BorderSizePixel = 0
	pageGroup.GroupTransparency = 0
	pageGroup.Position = UDim2.fromOffset(0, 0)
	pageGroup.Size = UDim2.new(1, -12, 0, 0)
	pageGroup.ZIndex = 13
	pageGroup.Parent = page

	local pageScale = Instance.new("UIScale")
	pageScale.Name = "TabScale"
	pageScale.Scale = 1
	pageScale.Parent = pageGroup

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = pageGroup
	padding(pageGroup, 2)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
		pageGroup.Size = UDim2.new(1, -12, 0, layout.AbsoluteContentSize.Y + 8)
	end)

	tab.Button = button
	tab.Icon = iconImage
	tab.Label = tabLabel
	tab.Page = page
	tab.Group = pageGroup
	tab.Layout = layout

	local function setPageState(targetTab, active, animated)
		targetTab.Page.Active = active
		targetTab.Page.ScrollingEnabled = active
		targetTab.Page.ScrollBarThickness = targetTab.Page:GetAttribute("OpenScrollBarThickness") or 3

		local hiddenTransparency = targetTab.Page:GetAttribute("HiddenScrollBarTransparency") or 1
		local targetTransparency = hiddenTransparency
		if animated then
			tween(targetTab.Page, TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				ScrollBarImageTransparency = targetTransparency,
			})
		else
			targetTab.Page.ScrollBarImageTransparency = targetTransparency
		end
	end

	function tab:Select(force)
		if self.Gui.CurrentTab == tab and not force then
			return
		end

		self.Gui.TabAnimationId = (self.Gui.TabAnimationId or 0) + 1
		local animationId = self.Gui.TabAnimationId
		local previousTab = self.Gui.CurrentTab
		local previousPage = previousTab and previousTab.Page or nil
		local previousGroup = previousTab and previousTab.Group or nil
		local animation = self.Gui.TabAnimationEnabled and self.Gui.TabAnimation or "None"
		local duration = self.Gui.TabAnimationDuration or 0.18
		local info = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		self.Gui.CurrentTab = tab

		for _, other in ipairs(self.Gui.Tabs) do
			other.Button:SetAttribute("OpenBg", 1)
			other.Button.BackgroundTransparency = 1
			other.Button.BackgroundColor3 = THEME.PanelLight
			other.Icon.ImageColor3 = THEME.Muted
			other.Label.TextColor3 = THEME.Muted
			other.Button:SetAttribute("ThemeBg", "PanelLight")
			other.Icon:SetAttribute("ThemeImage", "Muted")
			other.Label:SetAttribute("ThemeText", "Muted")
			setPageState(other, false, false)
			if other ~= tab and other ~= previousTab then
				other.Page.Visible = false
				other.Group.Position = UDim2.fromOffset(0, 0)
				other.Group.GroupTransparency = 0
				local otherScale = other.Group:FindFirstChild("TabScale")
				if otherScale then
					otherScale.Scale = 1
				end
			end
		end

		if previousPage and previousPage ~= page then
			if animation == "None" then
				previousPage.Visible = false
			elseif previousGroup then
				setPageState(previousTab, false, true)
				tween(previousGroup, TweenInfo.new(duration * 0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					GroupTransparency = 1,
				})
				task.delay(duration * 0.7, function()
					if self.Gui.TabAnimationId == animationId then
						previousPage.Visible = false
						previousGroup.Position = UDim2.fromOffset(0, 0)
						previousGroup.GroupTransparency = 0
						local oldScale = previousGroup:FindFirstChild("TabScale")
						if oldScale then
							oldScale.Scale = 1
						end
					end
				end)
			end
		end

		page.Visible = true
		setPageState(tab, animation == "None", false)
		if pageGroup then
			local scale = pageGroup:FindFirstChild("TabScale")
			if animation == "Fade" then
				pageGroup.Position = UDim2.fromOffset(0, 0)
				pageGroup.GroupTransparency = 1
				if scale then
					scale.Scale = 1
				end
				tween(pageGroup, info, { GroupTransparency = 0 })
			elseif animation == "Slide" then
				pageGroup.GroupTransparency = 1
				pageGroup.Position = UDim2.fromOffset(18, 0)
				if scale then
					scale.Scale = 1
				end
				tween(pageGroup, info, {
					GroupTransparency = 0,
					Position = UDim2.fromOffset(0, 0),
				})
			elseif animation == "Scale" then
				pageGroup.Position = UDim2.fromOffset(0, 0)
				pageGroup.GroupTransparency = 1
				if scale then
					scale.Scale = 1
				end
				tween(pageGroup, info, { GroupTransparency = 0 })
			else
				pageGroup.Position = UDim2.fromOffset(0, 0)
				pageGroup.GroupTransparency = 0
				if scale then
					scale.Scale = 1
				end
			end
		end

		if animation ~= "None" then
			task.delay(duration, function()
				if self.Gui.TabAnimationId == animationId and self.Gui.CurrentTab == tab then
					setPageState(tab, true, true)
				end
			end)
		end

		button:SetAttribute("OpenBg", 0)
		button.BackgroundTransparency = 0
		button.BackgroundColor3 = THEME.PanelLight
		iconImage.ImageColor3 = THEME.Accent
		tabLabel.TextColor3 = THEME.Text
		button:SetAttribute("ThemeBg", "PanelLight")
		iconImage:SetAttribute("ThemeImage", "Accent")
		tabLabel:SetAttribute("ThemeText", "Text")
	end

	if self.UpdateSidebarSize then
		task.defer(self.UpdateSidebarSize)
	end

	button.MouseButton1Click:Connect(function()
		tab:Select()
	end)

	function tab:Section(title)
		local section = Instance.new("Frame")
		section.Name = title .. "Section"
		section.BackgroundColor3 = THEME.Panel
		section.BackgroundTransparency = 0
		section.BorderSizePixel = 0
		section.Size = UDim2.new(1, -6, 0, 48)
		section.ZIndex = 14
		section.Parent = pageGroup
		section:SetAttribute("OpenBg", section.BackgroundTransparency)
		section:SetAttribute("ThemeBg", "Panel")
		corner(section, 8)
		stroke(section, THEME.SoftStroke, 0.45, 1)
		padding(section, 12)

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 9)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = section

		local header = makeLabel(section, title, 14, THEME.Text, Enum.FontWeight.Bold)
		header.Size = UDim2.new(1, 0, 0, 20)
		header.ZIndex = 15

		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			section.Size = UDim2.new(1, -6, 0, list.AbsoluteContentSize.Y + 24)
		end)

		local api = {}
		local sectionKey = sanitizeKey(name) .. "." .. sanitizeKey(title)
		local builder = self.Gui

		local function registerControl(controlText, control, options)
			if not builder.ConfigEnabled then
				return control
			end
			local flag = options and (options.Flag or options.flag or options.Key or options.key)
			flag = flag or (sectionKey .. "." .. sanitizeKey(controlText))
			builder:RegisterConfigControl(flag, control)
			return control
		end

		function api:Button(text, callback, order)
			if type(callback) == "number" then
				order = callback
				callback = nil
			end

			local btn = Instance.new("TextButton")
			btn.AutoButtonColor = false
			btn.BackgroundColor3 = THEME.PanelLight
			btn.BackgroundTransparency = 0
			btn.BorderSizePixel = 0
			btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
			btn.Size = UDim2.new(1, 0, 0, 38)
			btn.Text = text
			btn.TextColor3 = THEME.Text
			btn.TextSize = 13
			btn.ZIndex = 15
			btn.Parent = section
			applyOrder(btn, order)
			btn:SetAttribute("OpenBg", btn.BackgroundTransparency)
			btn:SetAttribute("ThemeBg", "PanelLight")
			btn:SetAttribute("ThemeText", "Text")
			corner(btn, 7)

			btn.MouseEnter:Connect(function()
				btn.BackgroundColor3 = THEME.PanelHover
				btn.TextColor3 = THEME.Text
				btn:SetAttribute("ThemeBg", "PanelHover")
				btn:SetAttribute("ThemeText", "Text")
			end)
			btn.MouseLeave:Connect(function()
				btn.BackgroundColor3 = THEME.PanelLight
				btn.TextColor3 = THEME.Text
				btn:SetAttribute("ThemeBg", "PanelLight")
				btn:SetAttribute("ThemeText", "Text")
			end)
			btn.MouseButton1Click:Connect(function()
				if callback then
					callback()
				end
			end)
			return btn
		end

		function api:Toggle(text, default, callback, order)
			if type(callback) == "number" then
				order = callback
				callback = nil
			end
			local configOptions
			order, configOptions = splitOrderOptions(order)

			local value = default == true

			local row = Instance.new("TextButton")
			row.AutoButtonColor = false
			row.BackgroundColor3 = THEME.PanelLight
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			row.Size = UDim2.new(1, 0, 0, 38)
			row.Text = ""
			row.ZIndex = 15
			row.Parent = section
			applyOrder(row, order)
			row:SetAttribute("OpenBg", row.BackgroundTransparency)
			row:SetAttribute("ThemeBg", "PanelLight")
			corner(row, 7)

			local label = makeLabel(row, text, 13, THEME.Text, Enum.FontWeight.Medium)
			label.Position = UDim2.fromOffset(12, 0)
			label.Size = UDim2.new(1, -68, 1, 0)
			label.ZIndex = 16

			local knobBg = Instance.new("Frame")
			knobBg.AnchorPoint = Vector2.new(1, 0.5)
			knobBg.BackgroundColor3 = value and THEME.Accent or Color3.fromRGB(70, 73, 78)
			knobBg.BorderSizePixel = 0
			knobBg.Position = UDim2.new(1, -12, 0.5, 0)
			knobBg.Size = UDim2.fromOffset(38, 20)
			knobBg.ZIndex = 16
			knobBg.Parent = row
			knobBg:SetAttribute("ThemeBg", value and "Accent" or nil)
			corner(knobBg, 10)

			local knob = Instance.new("Frame")
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			knob.BorderSizePixel = 0
			knob.Position = value and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3)
			knob.Size = UDim2.fromOffset(14, 14)
			knob.ZIndex = 17
			knob.Parent = knobBg
			corner(knob, 7)

			local function set(nextValue)
				value = nextValue
				knobBg:SetAttribute("ThemeBg", value and "Accent" or nil)
				local toggleInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				tween(knobBg, toggleInfo, {
					BackgroundColor3 = value and THEME.Accent or Color3.fromRGB(70, 73, 78),
				})
				tween(knob, toggleInfo, {
					Position = value and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3),
				})
				if callback then
					callback(value)
				end
			end

			row.MouseButton1Click:Connect(function()
				set(not value)
			end)

			if callback then
				task.defer(callback, value)
			end

			return registerControl(text, { Set = set, Get = function() return value end }, configOptions)
		end

		function api:Slider(text, min, max, default, step, callback, order)
			if type(step) == "function" then
				callback = step
				step = nil
			elseif type(callback) == "number" then
				order = callback
				callback = nil
			end
			local configOptions
			order, configOptions = splitOrderOptions(order)

			step = step or 1
			local value = math.clamp(default or min, min, max)
			local dragging = false

			local row = Instance.new("Frame")
			row.BackgroundColor3 = THEME.PanelLight
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			row.Size = UDim2.new(1, 0, 0, 54)
			row.ZIndex = 15
			row.Parent = section
			applyOrder(row, order)
			row:SetAttribute("OpenBg", row.BackgroundTransparency)
			row:SetAttribute("ThemeBg", "PanelLight")
			corner(row, 7)

			local label = makeLabel(row, text, 13, THEME.Text, Enum.FontWeight.Medium)
			label.Position = UDim2.fromOffset(12, 3)
			label.Size = UDim2.new(1, -72, 0, 24)
			label.ZIndex = 16

			local valueLabel = makeLabel(row, formatNumber(value, step), 12, THEME.Accent, Enum.FontWeight.Bold)
			valueLabel.Position = UDim2.new(1, -58, 0, 3)
			valueLabel.Size = UDim2.fromOffset(46, 24)
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.ZIndex = 16

			local track = Instance.new("Frame")
			track.BackgroundColor3 = Color3.fromRGB(58, 62, 70)
			track.BackgroundTransparency = 0
			track.BorderSizePixel = 0
			track.Position = UDim2.fromOffset(12, 34)
			track.Size = UDim2.new(1, -24, 0, 6)
			track.ZIndex = 16
			track.Parent = row
			corner(track, 3)

			local fill = Instance.new("Frame")
			fill.BackgroundColor3 = THEME.Accent
			fill.BorderSizePixel = 0
			fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
			fill.ZIndex = 17
			fill.Parent = track
			fill:SetAttribute("ThemeBg", "Accent")
			corner(fill, 3)

			local function setFromX(x)
				local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				local rawValue = min + (max - min) * pct
				value = math.clamp(math.floor((rawValue / step) + 0.5) * step, min, max)
				pct = (value - min) / (max - min)
				valueLabel.Text = formatNumber(value, step)
				tween(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.fromScale(pct, 1),
				})
				if callback then
					callback(value)
				end
			end

			track.InputBegan:Connect(function(input)
				if isPressInput(input) then
					dragging = true
					setFromX(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if isPressInput(input) then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and isDragInput(input) then
					setFromX(input.Position.X)
				end
			end)

			if callback then
				task.defer(callback, value)
			end

			return registerControl(text, {
				Set = function(nextValue)
					value = math.clamp(math.floor((nextValue / step) + 0.5) * step, min, max)
					valueLabel.Text = formatNumber(value, step)
					tween(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale((value - min) / (max - min), 1),
					})
					if callback then
						callback(value)
					end
				end,
				Get = function()
					return value
				end,
			}, configOptions)
		end

		function api:Keybind(text, defaultKey, callback, order)
			if type(callback) == "number" then
				order = callback
				callback = nil
			end
			local configOptions
			order, configOptions = splitOrderOptions(order)

			local selectedKey = defaultKey or Enum.KeyCode.F
			local listening = false
			local mode = "Toggle"
			local toggled = false
			local menuOpen = false
			local touchHolding = false
			local suppressNextClick = false

			local btn = Instance.new("TextButton")
			btn.AutoButtonColor = false
			btn.BackgroundColor3 = THEME.PanelLight
			btn.BackgroundTransparency = 0
			btn.BorderSizePixel = 0
			btn.ClipsDescendants = true
			btn.Size = UDim2.new(1, 0, 0, 38)
			btn.Text = ""
			btn.ZIndex = 15
			btn.Parent = section
			applyOrder(btn, order)
			btn:SetAttribute("OpenBg", btn.BackgroundTransparency)
			btn:SetAttribute("ThemeBg", "PanelLight")
			corner(btn, 7)

			local label = makeLabel(btn, text, 13, THEME.Text, Enum.FontWeight.Medium)
			label.Position = UDim2.fromOffset(12, 0)
			label.Size = UDim2.new(1, -112, 0, 38)
			label.ZIndex = 16

			local keyLabel = makeLabel(btn, selectedKey.Name, 12, THEME.Accent, Enum.FontWeight.Bold)
			keyLabel.Position = UDim2.new(1, -94, 0, 0)
			keyLabel.Size = UDim2.fromOffset(82, 38)
			keyLabel.TextXAlignment = Enum.TextXAlignment.Right
			keyLabel.ZIndex = 16

			local menu = Instance.new("Frame")
			menu.BackgroundTransparency = 1
			menu.Position = UDim2.fromOffset(12, 42)
			menu.Size = UDim2.new(1, -24, 0, 0)
			menu.ZIndex = 16
			menu.Parent = btn
			menu:SetAttribute("ThemeBg", "PanelLight")

			local menuLayout = Instance.new("UIListLayout")
			menuLayout.FillDirection = Enum.FillDirection.Horizontal
			menuLayout.Padding = UDim.new(0, 6)
			menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
			menuLayout.Parent = menu
			local modeButtons = {}

			local function setMenuOpen(nextOpen)
				menuOpen = nextOpen
				tween(btn, TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 0, menuOpen and 80 or 38),
				})
			end

			local function setMode(nextMode)
				mode = nextMode
				for option, optionButton in pairs(modeButtons) do
					optionButton.BackgroundColor3 = option == mode and THEME.PanelHover or THEME.Panel
					optionButton.TextColor3 = option == mode and THEME.Text or THEME.Muted
					optionButton:SetAttribute("ThemeBg", option == mode and "PanelHover" or "Panel")
					optionButton:SetAttribute("ThemeText", option == mode and "Text" or "Muted")
				end
				setMenuOpen(false)
			end

			local function clearKey()
				selectedKey = nil
				toggled = false
				keyLabel.Text = "None"
				setMenuOpen(false)
				if callback then
					callback(false)
				end
			end

			for _, option in ipairs({ "Toggle", "Hold", "Clear" }) do
				local optionButton = Instance.new("TextButton")
				optionButton.AutoButtonColor = false
				optionButton.BackgroundColor3 = THEME.Panel
				optionButton.BackgroundTransparency = 0
				optionButton.BorderSizePixel = 0
				optionButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
				optionButton.Size = UDim2.new(1 / 3, -4, 0, 30)
				optionButton.Text = option
				optionButton.TextColor3 = option == "Clear" and THEME.Bad or (option == mode and THEME.Text or THEME.Muted)
				optionButton.TextSize = 12
				optionButton.ZIndex = 17
				optionButton.Parent = menu
				optionButton:SetAttribute("ThemeBg", option == mode and "PanelHover" or "Panel")
				optionButton:SetAttribute("ThemeText", option == "Clear" and "Bad" or (option == mode and "Text" or "Muted"))
				corner(optionButton, 6)
				if option ~= "Clear" then
					modeButtons[option] = optionButton
					optionButton.BackgroundColor3 = option == mode and THEME.PanelHover or THEME.Panel
					optionButton:SetAttribute("ThemeBg", option == mode and "PanelHover" or "Panel")
				end

				optionButton.MouseButton1Click:Connect(function()
					if option == "Clear" then
						clearKey()
					else
						setMode(option)
					end
				end)
			end

			btn.MouseButton1Click:Connect(function()
				if suppressNextClick then
					suppressNextClick = false
					return
				end
				listening = true
				setMenuOpen(false)
				keyLabel.Text = "..."
			end)

			btn.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					setMenuOpen(not menuOpen)
				elseif input.UserInputType == Enum.UserInputType.Touch then
					touchHolding = true
					task.delay(0.45, function()
						if touchHolding then
							suppressNextClick = true
							setMenuOpen(not menuOpen)
						end
					end)
				end
			end)

			btn.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					touchHolding = false
				end
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if processed then
					return
				end

				if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
					selectedKey = input.KeyCode
					keyLabel.Text = selectedKey.Name
					listening = false
					toggled = false
				elseif selectedKey and input.KeyCode == selectedKey and callback then
					if mode == "Hold" then
						callback(true)
					else
						toggled = not toggled
						callback(toggled)
					end
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if selectedKey and mode == "Hold" and input.KeyCode == selectedKey and callback then
					callback(false)
				end
			end)

			return registerControl(text, {
				Set = function(key)
					selectedKey = key
					toggled = false
					keyLabel.Text = selectedKey and selectedKey.Name or "None"
				end,
				SetMode = setMode,
				Clear = clearKey,
				Get = function()
					return selectedKey
				end,
				GetMode = function()
					return mode
				end,
			}, configOptions)
		end

		function api:Label(text, order)
			local label = makeLabel(section, text, 13, THEME.Muted, Enum.FontWeight.Medium)
			label.Size = UDim2.new(1, 0, 0, 20)
			label.ZIndex = 15
			applyOrder(label, order)
			return label
		end

		function api:Paragraph(titleText, bodyText, order)
			local row = Instance.new("Frame")
			row.BackgroundColor3 = THEME.PanelLight
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			row.Size = UDim2.new(1, 0, 0, 66)
			row.ZIndex = 15
			row.Parent = section
			applyOrder(row, order)
			row:SetAttribute("OpenBg", row.BackgroundTransparency)
			row:SetAttribute("ThemeBg", "PanelLight")
			corner(row, 7)
			padding(row, 12)

			local titleLabel = makeLabel(row, titleText, 13, THEME.Text, Enum.FontWeight.SemiBold)
			titleLabel.Size = UDim2.new(1, 0, 0, 18)
			titleLabel.ZIndex = 16

			local bodyLabel = makeLabel(row, bodyText or "", 12, THEME.Muted, Enum.FontWeight.Regular)
			bodyLabel.Position = UDim2.fromOffset(0, 22)
			bodyLabel.Size = UDim2.new(1, 0, 0, 28)
			bodyLabel.TextWrapped = true
			bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
			bodyLabel.ZIndex = 16

			local function refreshSize()
				local height = math.max(66, bodyLabel.TextBounds.Y + 48)
				row.Size = UDim2.new(1, 0, 0, height)
				bodyLabel.Size = UDim2.new(1, 0, 0, height - 38)
			end

			bodyLabel:GetPropertyChangedSignal("TextBounds"):Connect(refreshSize)
			task.defer(refreshSize)

			return {
				Set = function(nextTitle, nextBody)
					titleLabel.Text = nextTitle or titleLabel.Text
					bodyLabel.Text = nextBody or bodyLabel.Text
					refreshSize()
				end,
			}
		end

		function api:Textbox(text, placeholder, default, callback, order)
			if type(callback) == "number" then
				order = callback
				callback = nil
			end
			local configOptions
			order, configOptions = splitOrderOptions(order)

			local row = Instance.new("Frame")
			row.BackgroundColor3 = THEME.PanelLight
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			row.Size = UDim2.new(1, 0, 0, 42)
			row.ZIndex = 15
			row.Parent = section
			applyOrder(row, order)
			row:SetAttribute("OpenBg", row.BackgroundTransparency)
			row:SetAttribute("ThemeBg", "PanelLight")
			corner(row, 7)

			local label = makeLabel(row, text, 13, THEME.Text, Enum.FontWeight.Medium)
			label.Position = UDim2.fromOffset(12, 0)
			label.Size = UDim2.new(0.45, -12, 1, 0)
			label.ZIndex = 16

			local box = Instance.new("TextBox")
			box.BackgroundColor3 = THEME.Panel
			box.BackgroundTransparency = 0
			box.BorderSizePixel = 0
			box.ClearTextOnFocus = false
			box.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
			box.PlaceholderColor3 = THEME.Muted
			box.PlaceholderText = placeholder or ""
			box.Position = UDim2.new(0.45, 4, 0, 7)
			box.Size = UDim2.new(0.55, -16, 1, -14)
			box.Text = default or ""
			box.TextColor3 = THEME.Text
			box.TextSize = 12
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.ZIndex = 16
			box.Parent = row
			box:SetAttribute("ThemeBg", "Panel")
			box:SetAttribute("ThemeText", "Text")
			box:SetAttribute("ThemePlaceholder", "Muted")
			corner(box, 6)
			padding(box, 8)

			local function submit()
				if callback then
					callback(box.Text)
				end
			end

			box.FocusLost:Connect(submit)

			if callback then
				task.defer(callback, box.Text)
			end

			return registerControl(text, {
				Set = function(value)
					box.Text = tostring(value or "")
					submit()
				end,
				Get = function()
					return box.Text
				end,
			}, configOptions)
		end

		function api:Dropdown(text, options, default, callback, order)
			if type(callback) == "number" then
				order = callback
				callback = nil
			end
			local configOptions
			order, configOptions = splitOrderOptions(order)

			options = options or {}
			local selected = default or options[1]
			local open = false

			local row = Instance.new("Frame")
			row.BackgroundColor3 = THEME.PanelLight
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			row.ClipsDescendants = true
			row.Size = UDim2.new(1, 0, 0, 42)
			row.ZIndex = 15
			row.Parent = section
			applyOrder(row, order)
			row:SetAttribute("OpenBg", row.BackgroundTransparency)
			row:SetAttribute("ThemeBg", "PanelLight")
			corner(row, 7)

			local label = makeLabel(row, text, 13, THEME.Text, Enum.FontWeight.Medium)
			label.Position = UDim2.fromOffset(12, 0)
			label.Size = UDim2.new(0.45, -12, 0, 42)
			label.ZIndex = 16

			local button = Instance.new("TextButton")
			button.AutoButtonColor = false
			button.BackgroundColor3 = THEME.Panel
			button.BackgroundTransparency = 0
			button.BorderSizePixel = 0
			button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
			button.Position = UDim2.new(0.45, 4, 0, 7)
			button.Size = UDim2.new(0.55, -16, 0, 28)
			button.Text = selected and tostring(selected) or "Select"
			button.TextColor3 = THEME.Text
			button.TextSize = 12
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.ZIndex = 16
			button.Parent = row
			button:SetAttribute("ThemeBg", "Panel")
			button:SetAttribute("ThemeText", "Text")
			corner(button, 6)
			padding(button, 8)

			local optionHolder = Instance.new("Frame")
			optionHolder.BackgroundTransparency = 1
			optionHolder.Position = UDim2.fromOffset(12, 42)
			optionHolder.Size = UDim2.new(1, -24, 0, 0)
			optionHolder.ZIndex = 16
			optionHolder.Parent = row

			local optionLayout = Instance.new("UIListLayout")
			optionLayout.Padding = UDim.new(0, 6)
			optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
			optionLayout.Parent = optionHolder

			local optionButtons = {}

			local function set(value)
				selected = value
				button.Text = selected and tostring(selected) or "Select"
				if callback then
					callback(selected)
				end
			end

			local function setOpen(nextOpen)
				open = nextOpen
				local targetHeight = open and (42 + (#options * 30) + math.max(#options - 1, 0) * 6 + 12) or 42
				tween(row, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 0, targetHeight),
				})
			end

			local function rebuild(nextOptions)
				options = nextOptions or options
				for _, child in ipairs(optionButtons) do
					child:Destroy()
				end
				table.clear(optionButtons)

				for _, option in ipairs(options) do
					local optionButton = Instance.new("TextButton")
					optionButton.AutoButtonColor = false
					optionButton.BackgroundColor3 = THEME.Panel
					optionButton.BackgroundTransparency = 0
					optionButton.BorderSizePixel = 0
					optionButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
					optionButton.Size = UDim2.new(1, 0, 0, 30)
					optionButton.Text = tostring(option)
					optionButton.TextColor3 = THEME.Muted
					optionButton.TextSize = 12
					optionButton.ZIndex = 17
					optionButton.Parent = optionHolder
					optionButton:SetAttribute("ThemeBg", "Panel")
					optionButton:SetAttribute("ThemeText", "Muted")
					corner(optionButton, 6)

					optionButton.MouseButton1Click:Connect(function()
						set(option)
						setOpen(false)
					end)

					table.insert(optionButtons, optionButton)
				end

				optionHolder.Size = UDim2.new(1, -24, 0, #options * 30 + math.max(#options - 1, 0) * 6)
				if open then
					setOpen(true)
				end
			end

			button.MouseButton1Click:Connect(function()
				setOpen(not open)
			end)

			rebuild(options)

			if callback and selected ~= nil then
				task.defer(callback, selected)
			end

			return registerControl(text, {
				Set = set,
				Get = function()
					return selected
				end,
				SetOptions = rebuild,
			}, configOptions)
		end

		function api:List(text, items, callback, order)
			if type(callback) == "number" then
				order = callback
				callback = nil
			end
			local configOptions
			order, configOptions = splitOrderOptions(order)

			items = items or {}
			local itemButtons = {}

			local row = Instance.new("Frame")
			row.BackgroundColor3 = THEME.PanelLight
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			row.Size = UDim2.new(1, 0, 0, 58)
			row.ZIndex = 15
			row.Parent = section
			applyOrder(row, order)
			row:SetAttribute("OpenBg", row.BackgroundTransparency)
			row:SetAttribute("ThemeBg", "PanelLight")
			corner(row, 7)
			padding(row, 12)

			local titleLabel = makeLabel(row, text, 13, THEME.Text, Enum.FontWeight.SemiBold)
			titleLabel.Size = UDim2.new(1, 0, 0, 18)
			titleLabel.ZIndex = 16

			local holder = Instance.new("Frame")
			holder.BackgroundTransparency = 1
			holder.Position = UDim2.fromOffset(0, 28)
			holder.Size = UDim2.new(1, 0, 0, 0)
			holder.ZIndex = 16
			holder.Parent = row

			local holderLayout = Instance.new("UIListLayout")
			holderLayout.Padding = UDim.new(0, 6)
			holderLayout.SortOrder = Enum.SortOrder.LayoutOrder
			holderLayout.Parent = holder

			local function refreshSize()
				local height = holderLayout.AbsoluteContentSize.Y
				holder.Size = UDim2.new(1, 0, 0, height)
				row.Size = UDim2.new(1, 0, 0, height + 58)
			end

			local function clear()
				for _, button in ipairs(itemButtons) do
					button:Destroy()
				end
				table.clear(itemButtons)
				refreshSize()
			end

			local function add(item)
				local itemButton = Instance.new("TextButton")
				itemButton.AutoButtonColor = false
				itemButton.BackgroundColor3 = THEME.Panel
				itemButton.BackgroundTransparency = 0
				itemButton.BorderSizePixel = 0
				itemButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
				itemButton.Size = UDim2.new(1, 0, 0, 30)
				itemButton.Text = tostring(item)
				itemButton.TextColor3 = THEME.Muted
				itemButton.TextSize = 12
				itemButton.TextXAlignment = Enum.TextXAlignment.Left
				itemButton.ZIndex = 17
				itemButton.Parent = holder
				itemButton:SetAttribute("ThemeBg", "Panel")
				itemButton:SetAttribute("ThemeText", "Muted")
				corner(itemButton, 6)
				padding(itemButton, 10)

				itemButton.MouseButton1Click:Connect(function()
					if callback then
						callback(item)
					end
				end)

				table.insert(itemButtons, itemButton)
				task.defer(refreshSize)
				return itemButton
			end

			local function set(nextItems)
				clear()
				items = nextItems or {}
				for _, item in ipairs(items) do
					add(item)
				end
			end

			holderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshSize)
			set(items)

			return registerControl(text, {
				Add = add,
				Clear = clear,
				Set = set,
				Get = function()
					return items
				end,
			}, configOptions)
		end

		function api:ColorPicker(text, default, callback, order)
			if type(callback) == "number" then
				order = callback
				callback = nil
			end
			local configOptions
			order, configOptions = splitOrderOptions(order)

			local hue, saturation, value = Color3.toHSV(default or THEME.Accent)
			local selected = Color3.fromHSV(hue, saturation, value)
			local open = false
			local draggingPalette = false
			local draggingHue = false

			local row = Instance.new("Frame")
			row.BackgroundColor3 = THEME.PanelLight
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			row.ClipsDescendants = true
			row.Size = UDim2.new(1, 0, 0, 42)
			row.ZIndex = 15
			row.Parent = section
			applyOrder(row, order)
			row:SetAttribute("OpenBg", row.BackgroundTransparency)
			row:SetAttribute("ThemeBg", "PanelLight")
			corner(row, 7)

			local label = makeLabel(row, text, 13, THEME.Text, Enum.FontWeight.Medium)
			label.Position = UDim2.fromOffset(12, 0)
			label.Size = UDim2.new(1, -92, 0, 42)
			label.ZIndex = 16

			local preview = Instance.new("Frame")
			preview.AnchorPoint = Vector2.new(1, 0)
			preview.BackgroundColor3 = selected
			preview.BorderSizePixel = 0
			preview.Position = UDim2.new(1, -48, 0, 12)
			preview.Size = UDim2.fromOffset(18, 18)
			preview.ZIndex = 16
			preview.Parent = row
			corner(preview, 5)
			stroke(preview, THEME.SoftStroke, 0.35, 1)

			local toggleButton = Instance.new("TextButton")
			toggleButton.AnchorPoint = Vector2.new(1, 0)
			toggleButton.AutoButtonColor = false
			toggleButton.BackgroundTransparency = 1
			toggleButton.BorderSizePixel = 0
			toggleButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
			toggleButton.Position = UDim2.new(1, -12, 0, 0)
			toggleButton.Size = UDim2.fromOffset(24, 42)
			toggleButton.Text = "+"
			toggleButton.TextColor3 = THEME.Muted
			toggleButton.TextSize = 16
			toggleButton.ZIndex = 16
			toggleButton.Parent = row

			local paletteFrame = Instance.new("Frame")
			paletteFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			paletteFrame.BorderSizePixel = 0
			paletteFrame.Position = UDim2.fromOffset(12, 50)
			paletteFrame.Size = UDim2.new(1, -48, 0, 112)
			paletteFrame.ZIndex = 16
			paletteFrame.Parent = row
			corner(paletteFrame, 7)

			local saturationOverlay = Instance.new("Frame")
			saturationOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			saturationOverlay.BackgroundTransparency = 0
			saturationOverlay.BorderSizePixel = 0
			saturationOverlay.Size = UDim2.fromScale(1, 1)
			saturationOverlay.ZIndex = 17
			saturationOverlay.Parent = paletteFrame
			corner(saturationOverlay, 7)

			local saturationGradient = Instance.new("UIGradient")
			saturationGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			saturationGradient.Parent = saturationOverlay

			local valueOverlay = Instance.new("Frame")
			valueOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			valueOverlay.BackgroundTransparency = 0
			valueOverlay.BorderSizePixel = 0
			valueOverlay.Size = UDim2.fromScale(1, 1)
			valueOverlay.ZIndex = 18
			valueOverlay.Parent = paletteFrame
			corner(valueOverlay, 7)

			local valueGradient = Instance.new("UIGradient")
			valueGradient.Rotation = 90
			valueGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			})
			valueGradient.Parent = valueOverlay

			local paletteCursor = Instance.new("Frame")
			paletteCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			paletteCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			paletteCursor.BorderSizePixel = 0
			paletteCursor.Size = UDim2.fromOffset(10, 10)
			paletteCursor.ZIndex = 19
			paletteCursor.Parent = paletteFrame
			corner(paletteCursor, 5)
			stroke(paletteCursor, Color3.fromRGB(0, 0, 0), 0.25, 1)

			local hueFrame = Instance.new("Frame")
			hueFrame.AnchorPoint = Vector2.new(1, 0)
			hueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			hueFrame.BorderSizePixel = 0
			hueFrame.Position = UDim2.new(1, -12, 0, 50)
			hueFrame.Size = UDim2.fromOffset(18, 112)
			hueFrame.ZIndex = 16
			hueFrame.Parent = row
			corner(hueFrame, 7)

			local hueGradient = Instance.new("UIGradient")
			hueGradient.Rotation = 90
			hueGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
			})
			hueGradient.Parent = hueFrame

			local hueCursor = Instance.new("Frame")
			hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			hueCursor.BorderSizePixel = 0
			hueCursor.Size = UDim2.new(1, 4, 0, 4)
			hueCursor.ZIndex = 17
			hueCursor.Parent = hueFrame
			corner(hueCursor, 2)

			local function updateVisuals(fireCallback)
				selected = Color3.fromHSV(hue, saturation, value)
				preview.BackgroundColor3 = selected
				paletteFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
				paletteCursor.Position = UDim2.fromScale(saturation, 1 - value)
				hueCursor.Position = UDim2.fromScale(0.5, hue)
				if fireCallback and callback then
					callback(selected)
				end
			end

			local function setPaletteFromInput(input)
				local x = math.clamp((input.Position.X - paletteFrame.AbsolutePosition.X) / paletteFrame.AbsoluteSize.X, 0, 1)
				local y = math.clamp((input.Position.Y - paletteFrame.AbsolutePosition.Y) / paletteFrame.AbsoluteSize.Y, 0, 1)
				saturation = x
				value = 1 - y
				updateVisuals(true)
			end

			local function setHueFromInput(input)
				hue = math.clamp((input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y, 0, 1)
				updateVisuals(true)
			end

			local function setOpen(nextOpen)
				open = nextOpen
				toggleButton.Text = open and "-" or "+"
				tween(row, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 0, open and 188 or 42),
				})
			end

			paletteFrame.InputBegan:Connect(function(input)
				if isPressInput(input) then
					draggingPalette = true
					setPaletteFromInput(input)
				end
			end)

			hueFrame.InputBegan:Connect(function(input)
				if isPressInput(input) then
					draggingHue = true
					setHueFromInput(input)
				end
			end)

			toggleButton.MouseButton1Click:Connect(function()
				setOpen(not open)
			end)

			UserInputService.InputEnded:Connect(function(input)
				if isPressInput(input) then
					draggingPalette = false
					draggingHue = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if isDragInput(input) then
					if draggingPalette then
						setPaletteFromInput(input)
					elseif draggingHue then
						setHueFromInput(input)
					end
				end
			end)

			updateVisuals(false)
			if callback then
				task.defer(callback, selected)
			end

			return registerControl(text, {
				Set = function(color)
					hue, saturation, value = Color3.toHSV(color)
					updateVisuals(true)
				end,
				Get = function()
					return selected
				end,
			}, configOptions)
		end

		return api
	end

	table.insert(self.Tabs, tab)
	if self.UpdateSidebarSize then
		task.defer(self.UpdateSidebarSize)
	end
	if not self.CurrentTab then
		tab:Select()
	end

	return tab
end

return Builder
