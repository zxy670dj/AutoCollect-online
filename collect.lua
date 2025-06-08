local isOn = false

-- GUI Setup
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "auto_collect_gui"
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 102)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
frame.Parent = gui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 128, 0, 34)
toggleButton.Position = UDim2.new(0.15, 0, 0.4, 0)
toggleButton.Text = "Off"
toggleButton.Parent = frame

toggleButton.MouseButton1Click:Connect(function()
	isOn = not isOn
	toggleButton.Text = isOn and "On" or "Off"
end)

-- Get player's Humanoid and RootPart safely
local function getCharacter()
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")
	local rootPart = char:WaitForChild("HumanoidRootPart")
	return humanoid, rootPart
end

-- Move humanoid to a Vector3 position and wait until close enough or timeout
local function moveToPosition(position, maxDistance, timeout)
	maxDistance = maxDistance or 5
	timeout = timeout or 15

	local humanoid, rootPart = getCharacter()
	humanoid:MoveTo(position)

	local startTime = os.clock()
	while os.clock() - startTime < timeout do
		task.wait(0.1)
		if (rootPart.Position - position).Magnitude <= maxDistance then
			return true -- reached
		end
		if not isOn then
			return false -- stopped early
		end
	end
	return false -- timeout
end

-- Find nearest 'new_part' BasePart directly inside any 'dropped_food' in trees
local function findNearestNewPart()
	local humanoid, rootPart = getCharacter()
	local treesFolder = workspace:FindFirstChild("trees")
	if not treesFolder then return nil end

	local nearestPart = nil
	local nearestDistance = math.huge

	for _, tree in ipairs(treesFolder:GetChildren()) do
		if tree:IsA("Model") then
			local droppedFoodFolder = tree:FindFirstChild("dropped_food")
			if droppedFoodFolder then
				for _, part in ipairs(droppedFoodFolder:GetChildren()) do
					if part:IsA("BasePart") and part.Name == "new_part" then
						local dist = (rootPart.Position - part.Position).Magnitude
						if dist < nearestDistance then
							nearestDistance = dist
							nearestPart = part
						end
					end
				end
			end
		end
	end

	return nearestPart
end

-- Main auto-collect loop
task.spawn(function()
	while true do
		task.wait(0.1)
		if isOn then
			local targetPart = findNearestNewPart()
			if targetPart and targetPart:IsDescendantOf(workspace) then
				local reached = moveToPosition(targetPart.Position, 5, 15)
				if reached then
					-- Add your collect logic here if needed (like touching, firing remote, etc)
					print("Reached part:", targetPart:GetFullName())
				end
			else
				-- No parts found, wait a bit
				task.wait(1)
			end
		else
			task.wait(1)
		end
	end
end)
