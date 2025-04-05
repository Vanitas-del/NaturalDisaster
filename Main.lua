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
local mouseDelta = Vector2.new()
local rotation = Vector2.new()

-- Sky Platform
local function createSkyPlatform()
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local platform = Instance.new("Part")
	platform.Name = "SkyPlatform"
	platform.Size = Vector3.new(20, 1, 20)
	platform.Position = Vector3.new(0, 500, 0)
	platform.Anchored = true
	platform.CanCollide = true
	platform.BrickColor = BrickColor.new("Bright yellow")
	platform.Material = Enum.Material.Neon
	platform.Parent = workspace

	hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, 5, 0))
end

-- Invisibility
local function becomeInvisible()
	local character = player.Character or player.CharacterAdded:Wait()
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 1
			if part:FindFirstChildOfClass("Decal") then
				for _, decal in pairs(part:GetChildren()) do
					if decal:IsA("Decal") then
						decal.Transparency = 1
					end
				end
			end
		elseif part:IsA("Accessory") then
			part.Handle.Transparency = 1
		end
	end
end

-- Invincibility
local function makeInvincible()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Health = math.huge
	humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if humanoid.Health < math.huge then
			humanoid.Health = math.huge
		end
	end)
end

-- Freecam movement input
local function handleInput(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then
		if actionName == "Forward" then camDirection = camDirection + Vector3.new(0, 0, -1) end
		if actionName == "Backward" then camDirection = camDirection + Vector3.new(0, 0, 1) end
		if actionName == "Left" then camDirection = camDirection + Vector3.new(-1, 0, 0) end
		if actionName == "Right" then camDirection = camDirection + Vector3.new(1, 0, 0) end
		if actionName == "Up" then camDirection = camDirection + Vector3.new(0, 1, 0) end
		if actionName == "Down" then camDirection = camDirection + Vector3.new(0, -1, 0) end
	elseif inputState == Enum.UserInputState.End then
		if actionName == "Forward" then camDirection = camDirection - Vector3.new(0, 0, -1) end
		if actionName == "Backward" then camDirection = camDirection - Vector3.new(0, 0, 1) end
		if actionName == "Left" then camDirection = camDirection - Vector3.new(-1, 0, 0) end
		if actionName == "Right" then camDirection = camDirection - Vector3.new(1, 0, 0) end
		if actionName == "Up" then camDirection = camDirection - Vector3.new(0, 1, 0) end
		if actionName == "Down" then camDirection = camDirection - Vector3.new(0, -1, 0) end
	end
end

-- Toggle FreeCam
local function toggleFreeCam()
	freeCamEnabled = not freeCamEnabled
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	if freeCamEnabled then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = hrp.CFrame

		ContextActionService:BindAction("Forward", handleInput, false, Enum.KeyCode.W)
		ContextActionService:BindAction("Backward", handleInput, false, Enum.KeyCode.S)
		ContextActionService:BindAction("Left", handleInput, false, Enum.KeyCode.A)
		ContextActionService:BindAction("Right", handleInput, false, Enum.KeyCode.D)
		ContextActionService:BindAction("Up", handleInput, false, Enum.KeyCode.Space)
		ContextActionService:BindAction("Down", handleInput, false, Enum.KeyCode.LeftShift)

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false

		RunService:BindToRenderStep("FreeCam", Enum.RenderPriority.Camera.Value, function(dt)
			local move = camera.CFrame:VectorToWorldSpace(camDirection) * camSpeed
			camera.CFrame = camera.CFrame + move * dt

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

-- GUI showing keybinds
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeybindInfoGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "CREEPY_SHANKS Keybinds"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local keybinds = {
	{Key = "G", Action = "Teleport to Sky Platform"},
	{Key = "N", Action = "Become Invisible"},
	{Key = "M", Action = "Toggle Freecam"},
	{Key = "J", Action = "Become Invincible (God Mode)"}
}

for i, bind in ipairs(keybinds) do
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 25)
	label.Position = UDim2.new(0, 10, 0, 30 + (i - 1) * 30)
	label.BackgroundTransparency = 1
	label.Text = "[" .. bind.Key .. "] - " .. bind.Action
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
end

-- Key binds
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.G then
		createSkyPlatform()
	elseif input.KeyCode == Enum.KeyCode.N then
		becomeInvisible()
	elseif input.KeyCode == Enum.KeyCode.M then
		toggleFreeCam()
	elseif input.KeyCode == Enum.KeyCode.J then
		makeInvincible()
	end
end)
