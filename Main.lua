-- LocalScript for CREEPY_SHANKS
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

if player.Name ~= "CREEPY_SHANKS" then return end

local freeCamEnabled = false
local camSpeed = 2
local camDirection = Vector3.new()
local rotation = Vector2.new()
local godMode = false
local invisEnabled = false

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 220)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 5)
uiList.Parent = mainFrame

local function createToggleButton(labelText, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1
	container.Parent = mainFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Text = labelText
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true
	label.Parent = container

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.3, 0, 1, 0)
	button.Position = UDim2.new(0.7, 0, 0, 0)
	button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	button.Text = "OFF"
	button.Font = Enum.Font.SourceSansBold
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Parent = container

	local enabled = false
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.Text = enabled and "ON" or "OFF"
		button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
		callback(enabled)
	end)
end

-- Invisible Sky Platform
local function createSkyPlatform()
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local platform = Instance.new("Part")
	platform.Name = "SkyPlatform"
	platform.Size = Vector3.new(20, 1, 20)
	platform.Position = Vector3.new(0, 500, 0)
	platform.Anchored = true
	platform.CanCollide = true
	platform.Transparency = 1
	platform.Parent = workspace

	hrps = character:WaitForChild("HumanoidRootPart")
	hrps.CFrame = CFrame.new(platform.Position + Vector3.new(0, 5, 0))
end

-- Invisibility
local function setInvisible(state)
	local character = player.Character or player.CharacterAdded:Wait()
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = state and 1 or 0
		elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
			part.Handle.Transparency = state and 1 or 0
		end
		if part:IsA("Decal") then
			part.Transparency = state and 1 or 0
		end
	end
end

-- God Mode
local function setGodMode(state)
	godMode = state
	if state then
		local humanoid = player.Character:WaitForChild("Humanoid")
		humanoid.Health = math.huge
		humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if godMode then
				humanoid.Health = math.huge
			end
		end)
	end
end

-- Freecam
local function toggleFreeCam(state)
	freeCamEnabled = state
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	if state then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = hrp.CFrame

		ContextActionService:BindAction("Forward", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 0, -1) end
			if s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 0, -1) end
		end, false, Enum.KeyCode.W)
		ContextActionService:BindAction("Backward", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 0, 1) end
			if s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 0, 1) end
		end, false, Enum.KeyCode.S)
		ContextActionService:BindAction("Left", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(-1, 0, 0) end
			if s == Enum.UserInputState.End then camDirection -= Vector3.new(-1, 0, 0) end
		end, false, Enum.KeyCode.A)
		ContextActionService:BindAction("Right", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(1, 0, 0) end
			if s == Enum.UserInputState.End then camDirection -= Vector3.new(1, 0, 0) end
		end, false, Enum.KeyCode.D)
		ContextActionService:BindAction("Up", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 1, 0) end
			if s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 1, 0) end
		end, false, Enum.KeyCode.Space)
		ContextActionService:BindAction("Down", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, -1, 0) end
			if s == Enum.UserInputState.End then camDirection -= Vector3.new(0, -1, 0) end
		end, false, Enum.KeyCode.LeftShift)

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false

		RunService:BindToRenderStep("FreeCam", Enum.RenderPriority.Camera.Value, function(dt)
			local move = camera.CFrame:VectorToWorldSpace(camDirection) * camSpeed * dt
			camera.CFrame = camera.CFrame + move

			local delta = UserInputService:GetMouseDelta()
			rotation = rotation + Vector2.new(-delta.Y, -delta.X) * 0.2
			local pitch = math.rad(rotation.X)
			local yaw = math.rad(rotation.Y)
			camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.Angles(pitch, yaw, 0)
		end)
	else
		RunService:UnbindFromRenderStep("FreeCam")
		camera.CameraType = Enum.CameraType.Custom
		ContextActionService:UnbindAction("Forward")
		ContextActionService:UnbindAction("Backward")
		ContextActionService:UnbindAction("Left")
		ContextActionService:UnbindAction("Right")
		ContextActionService:UnbindAction("Up")
		ContextActionService:UnbindAction("Down")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end
end

-- Add toggles to GUI
createToggleButton("Invisibility (N)", function(enabled)
	invisEnabled = enabled
	setInvisible(enabled)
end)

createToggleButton("God Mode (J)", function(enabled)
	setGodMode(enabled)
end)

createToggleButton("FreeCam (M)", function(enabled)
	toggleFreeCam(enabled)
end)

createToggleButton("Sky Platform (G)", function(enabled)
	if enabled then
		createSkyPlatform()
	end
end)

-- Footer credit
local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, 0, 0, 20)
credit.Text = "CREDIT TO - VANITAS"
credit.TextColor3 = Color3.new(1, 1, 1)
credit.BackgroundTransparency = 1
credit.Font = Enum.Font.SourceSansItalic
credit.TextScaled = true
credit.Parent = mainFrame
