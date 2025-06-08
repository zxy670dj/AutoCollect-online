--== AUTO COLLECT GUI AND LOGIC ==--

local isOn = false

-- GUI setup
local GUI = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
GUI.Name = "autocollect_gui"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame", GUI)
Frame.Size = UDim2.new(0, 220, 0, 100)
Frame.Position = UDim2.new(0.4, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
Frame.BorderSizePixel = 0

Instance.new("UICorner", Frame)
Instance.new("UIDragDetector", Frame)

local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(122, 122, 122)
Instance.new("UICorner", TitleBar)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "auto-collect"
Title.TextColor3 = Color3.new(0, 0, 0)
Title.TextScaled = true

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(0, 128, 0, 34)
Button.Position = UDim2.new(0.5, -64, 0.5, 0)
Button.BackgroundColor3 = Color3.fromRGB(162, 162, 162)
Button.Text = "off"
Button.TextScaled = true
Instance.new("UICorner", Button)

-- Toggle auto-collect
Button.MouseButton1Click:Connect(function()
	isOn = not isOn
	Button.Text = isOn and "on" or "off"
end)

--== COLLECT LOGIC ==--

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getCharacter()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	return char, hum, root
end

local function goTo(position)
	local _, hum = getCharacter()
	hum:MoveTo(position)
	hum.MoveToFinished:Wait()
end

local function findNearestTree()
	local _, _, root = getCharacter()
	local treesFolder = workspace:FindFirstChild("trees")
	if not treesFolder then return nil end

	local nearestTree = nil
	local shortestDist = math.huge

	for _, tree in ipairs(treesFolder:GetChildren()) do
		local treePos
		if tree:IsA("Model") then
			treePos = tree.PrimaryPart and tree.PrimaryPart.Position or tree:FindFirstChildWhichIsA("BasePart") and tree:FindFirstChildWhichIsA("BasePart").Position
		elseif tree:IsA("BasePart") then
			treePos = tree.Position
		end

		if treePos then
			local dist = (treePos - root.Position).Magnitude
			if dist < shortestDist then
				shortestDist = dist
				nearestTree = tree
			end
		end
	end

	return nearestTree
end

local function findNearestNewPart(tree)
	if not tree then return nil end
	local _, _, root = getCharacter()

	local droppedFood = tree:FindFirstChild("dropped_food")
	if not droppedFood then return nil end

	local newPartFolder = droppedFood:FindFirstChild("new_part")
	if not newPartFolder then return nil end

	local nearestPart = nil
	local shortestDist = math.huge

	for _, part in ipairs(newPartFolder:GetChildren()) do
		if part:IsA("BasePart") then
			local dist = (part.Position - root.Position).Magnitude
			if dist < shortestDist then
				shortestDist = dist
				nearestPart = part
			end
		end
	end

	return nearestPart
end

--== AUTO LOOP ==--

task.spawn(function()
	while true do
		task.wait(0.1)
		if not isOn then continue end

		local tree = findNearestTree()
		if not tree then task.wait(1) continue end

		-- Go to tree
		local treePart = tree:IsA("Model") and (tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart"))
			or (tree:IsA("BasePart") and tree)
		if treePart then goTo(treePart.Position) end

		-- Collect parts from tree
		while true do
			local part = findNearestNewPart(tree)
			if not part then break end
			goTo(part.Position)

			-- Simulate collecting (replace this if needed)
			if part and part.Parent then
				part:Destroy()
			end

			task.wait(0.2)
		end

		task.wait(0.2)
	end
end)
