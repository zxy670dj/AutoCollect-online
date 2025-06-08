local isOn = false

-- UI Setup
local GUI = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
GUI.Name = "autoCollectGui"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 102)
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
Frame.Parent = GUI

local UIDragDetector = Instance.new("UIDragDetector")
UIDragDetector.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(3, 70, 255)
UIStroke.Thickness = 3
UIStroke.Parent = Frame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 23)
Header.BackgroundColor3 = Color3.fromRGB(122, 122, 122)
Header.Parent = Frame

local UICornerHeader = Instance.new("UICorner")
UICornerHeader.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Auto-collect"
Title.TextColor3 = Color3.new(0, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.Sarpanch
Title.Parent = Header

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 128, 0, 34)
Toggle.Position = UDim2.new(0.209, 0, 0.412, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(162, 162, 162)
Toggle.Text = "Off"
Toggle.TextColor3 = Color3.new(0, 0, 0)
Toggle.TextScaled = true
Toggle.Font = Enum.Font.SourceSans
Toggle.Parent = Frame

local UICornerToggle = Instance.new("UICorner")
UICornerToggle.Parent = Toggle

Toggle.MouseButton1Click:Connect(function()
	isOn = not isOn
	Toggle.Text = isOn and "On" or "Off"
end)

-- Utility functions
local function getCharacter()
	local plr = game.Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")
	return char, humanoid, root
end

local function goTo(pos)
	local _, humanoid, _ = getCharacter()
	humanoid:MoveTo(pos)
end

local function findNearestNewPartGlobal()
	local _, _, root = getCharacter()
	local treesFolder = workspace:FindFirstChild("trees")
	if not treesFolder then return nil end

	local nearestPart = nil
	local shortestDist = math.huge

	for _, tree in ipairs(treesFolder:GetChildren()) do
		local droppedFood = tree:FindFirstChild("dropped_food")
		local newPartFolder = droppedFood and droppedFood:FindFirstChild("new_part")

		if newPartFolder then
			for _, part in ipairs(newPartFolder:GetChildren()) do
				if part:IsA("BasePart") then
					local dist = (part.Position - root.Position).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						nearestPart = part
					end
				end
			end
		end
	end

	return nearestPart
end

-- Main loop
task.spawn(function()
	while true do
		task.wait(0.1)
		if not isOn then continue end

		local part = findNearestNewPartGlobal()
		if part then
			goTo(part.Position)

			repeat
				task.wait(0.25)
			until (part.Position - (getCharacter())).Magnitude < 6 or not part.Parent

			-- Auto-collect: delete or interact
			if part and part.Parent then
				part:Destroy()
			end
		end
	end
end)
