local isOn = false

local GUI = Instance.new("ScreenGui")
GUI.Name = "GUI"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Name = "Frame"
Frame.Position = UDim2.new(0.343706, 0, 0.352436, 0)
Frame.Size = UDim2.new(0, 220, 0, 102)
Frame.BackgroundColor3 = Color3.new(0.294118, 0.294118, 0.294118)
Frame.BorderSizePixel = 0
Frame.BorderColor3 = Color3.new(0, 0, 0)
Frame.Parent = GUI

local UIDragDetector = Instance.new("UIDragDetector")
UIDragDetector.Name = "UIDragDetector"
UIDragDetector.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.Name = "UICorner"

UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Name = "UIStroke"
UIStroke.Color = Color3.new(0.0117647, 0.27451, 1)
UIStroke.Thickness = 3
UIStroke.Parent = Frame

local Frame2 = Instance.new("Frame")
Frame2.Name = "Frame"
Frame2.Size = UDim2.new(0, 220, 0, 23)
Frame2.BackgroundColor3 = Color3.new(0.478431, 0.478431, 0.478431)
Frame2.BorderSizePixel = 0
Frame2.BorderColor3 = Color3.new(0, 0, 0)
Frame2.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.Name = "UICorner"

UICorner2.Parent = Frame2

local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "TextLabel"
TextLabel.Size = UDim2.new(0, 220, 0, 23)
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderSizePixel = 0
TextLabel.BorderColor3 = Color3.new(0, 0, 0)
TextLabel.Transparency = 1
TextLabel.Text = "Auto-collect"
TextLabel.TextColor3 = Color3.new(0, 0, 0)
TextLabel.TextSize = 14
TextLabel.FontFace = Font.new("rbxasset://fonts/families/Sarpanch.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
TextLabel.TextScaled = true
TextLabel.TextWrapped = true
TextLabel.Parent = Frame2
TextLabel.LayoutOrder = 1

local Collect = Instance.new("TextButton")
Collect.Name = "Collect"
Collect.Position = UDim2.new(0.209091, 0, 0.411765, 0)
Collect.Size = UDim2.new(0, 128, 0, 34)
Collect.BackgroundColor3 = Color3.new(0.635294, 0.635294, 0.635294)
Collect.BorderSizePixel = 0
Collect.BorderColor3 = Color3.new(0, 0, 0)
Collect.Text = "Off"
Collect.TextColor3 = Color3.new(0, 0, 0)
Collect.TextSize = 14
Collect.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Collect.TextScaled = true
Collect.TextWrapped = true
Collect.Parent = Frame

local UICorner3 = Instance.new("UICorner")
UICorner3.Name = "UICorner"

UICorner3.Parent = Collect

Collect.MouseButton1Click:Connect(function()
	if not isOn then
		Collect.Text = "On"
		isOn = true
	else
		Collect.Text = "Off"
		isOn = false
	end
end)

local repeatPrevent = false

function goTo(part: Instance)
	if part:IsA("Part") or part:IsA("Model") then
		local plr = game.Players.LocalPlayer
		local char = plr.Character or plr.CharacterAdded:Wait()
		local hum = char:WaitForChild("Humanoid")

		local targetPosition

		if part:IsA("Model") then
			local primary = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart")
			if primary then
				targetPosition = primary.Position
			end
		elseif part:IsA("BasePart") then
			targetPosition = part.Position
		end

		if targetPosition then
			hum:MoveTo(targetPosition)
		end
	end
end

function nearestPart()
	local plr = game.Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")

	local nearest = nil
	local shortest = math.huge

	-- Change "MyPartsFolder" to your folder's actual name
	local partsFolder = workspace:FindFirstChild("Parts")
	if not partsFolder then
		warn("Folder 'Parts' not found in workspace")
		return nil
	end

	for _, obj in ipairs(partsFolder:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide then
			local dist = (obj.Position - root.Position).Magnitude
			if dist < shortest then
				shortest = dist
				nearest = obj
			end
		end
	end

	return nearest
end



while true do
	task.wait(1)

	if isOn and not repeatPrevent then
		repeatPrevent = true
		print("Auto-collect started")

		task.spawn(function()
			local plr = game.Players.LocalPlayer
			local char = plr.Character or plr.CharacterAdded:Wait()
			local hum = char:WaitForChild("Humanoid")

			while isOn do
				local part = nearestPart()
				if part then
					goTo(part)
					hum.MoveToFinished:Wait()
				end
				task.wait(0.2)
			end

			print("Auto-collect stopped")
			repeatPrevent = false
		end)
	end
end
