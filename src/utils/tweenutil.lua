local TweenService = game:GetService("TweenService")

local TweenUtil = {}

local active = setmetatable({}, { __mode = "k" })

function TweenUtil.info(duration, style, direction)
	return TweenInfo.new(
		duration or 0.2,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
end

function TweenUtil.play(instance, properties, duration, style, direction)
	if active[instance] then
		active[instance]:Cancel()
	end

	local tween = TweenService:Create(instance, TweenUtil.info(duration, style, direction), properties)
	active[instance] = tween

	tween.Completed:Connect(function()
		if active[instance] == tween then
			active[instance] = nil
		end
	end)

	tween:Play()
	return tween
end

function TweenUtil.cancel(instance)
	local tween = active[instance]
	if tween then
		tween:Cancel()
		active[instance] = nil
	end
end

function TweenUtil.fade(instance, transparency, duration)
	local properties = {}

	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		properties.TextTransparency = transparency
	end

	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		properties.ImageTransparency = transparency
	end

	if instance:IsA("GuiObject") then
		properties.BackgroundTransparency = transparency
	end

	return TweenUtil.play(instance, properties, duration or 0.2)
end

return TweenUtil
