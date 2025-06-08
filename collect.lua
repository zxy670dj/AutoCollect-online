local isOn = false

-- GUI setup (same as before)
local GUI = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
GUI.Name = "auto_collect_gui"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 102)
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
Frame.Parent = GUI

Instance.new("UIDragDetector", Frame)
Instance.new("UICorner", Frame)
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(3, 70, 255)
UIStroke.Thickness = 3

local Header = Instance.new("Frame", Frame)
Header.Size = UDim2.new(1, 0, 0, 23)
Header.BackgroundColor3 = Color3.fromRGB(122, 122, 122)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Auto-collect"
Title.TextColor3 = Color3.new(0, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.Sarpanch

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0, 128, 0, 34)
Toggle.Position = UDim2.new(0.209, 0, 0.412, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(162, 162, 162)
Toggle.Text = "Off"
Toggle.TextColor3 = Color3.new(0, 0, 0)
Toggle.TextScaled = true
Toggle.Font = Enum.Font.SourceSans
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
	isOn = not isOn
	Toggle.Text = isOn and "On" or "Off"
end)

-- FUNCTIONS

local function getCharacter()
	local plr = game.Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")
	return humanoid, root
end

local function goTo(pos)
	local humanoid, _ = getCharacter()
	humanoid:MoveTo(pos)
end

local function findNearestNewPart()
	local _, root = getCharacter()
	local nearest = nil
	local minDist = math.huge
	local trees = workspace:FindFirstChild("trees")

	if not trees then return nil end

	for _, tree in ipairs(trees:GetChildren()) do
		local dropped_food = tree:FindFirstChild("dropped_food")
		if dropped_food then
			-- Loop all new_part folders inside dropped_food
			for _, new_folder in ipairs(dropped_food:GetChildren()) do
				if new_folder.Name == "new_part" then
					for _, part in ipairs(new_folder:GetChildren()) do
						if part:IsA("BasePart") then
							local dist = (part.Position - root.Position).Magnitude
							if dist < minDist then
								minDist = dist
								nearest = part
							end
						end
					end
				end
			end
		end
	end

	return nearest
end

-- MAIN LOOP
task.spawn(function()
	while true do
		task.wait(0.1)
		if isOn then
			local target = findNearestNewPart()
			if target and target:IsDescendantOf(workspace) then
				goTo(target.Position)

				repeat
					task.wait(0.2)
					local humanoid, root = getCharacter()
				until not target:IsDescendantOf(workspace) or (target.Position - root.Position).Magnitude < 5
			end
		end
	end
end)
