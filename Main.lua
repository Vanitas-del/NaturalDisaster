local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

if player.Name ~= "CREEPY_SHANKS" then return end

-- Infinite Health
local function makeGodMode()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = math.huge
		humanoid.MaxHealth = math.huge
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		humanoid.BreakJointsOnDeath = false
	end
	character:FindFirstChildOfClass("Humanoid").HealthChanged:Connect(function()
		humanoid.Health = math.huge
	end)
end

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

-- Freecam
local freeCamEnabled = false
local camSpeed = 5
local camDirection = Vector3.new()
local rotation = Vector2.new()

local function handleInput(actionName, inputState)
	if inputState == Enum.UserInputState.Begin then
		if actionName == "Forward" then camDirection += Vector3.new(0, 0, -1) end
		if actionName == "Backward" then camDirection += Vector3.new(0, 0, 1) end
		if actionName == "Left" then camDirection += Vector3.new(-1, 0, 0) end
		if actionName == "Right" then camDirection += Vector3.new(1, 0, 0) end
		if actionName == "Up" then camDirection += Vector3.new(0, 1, 0) end
		if actionName == "Down" then camDirection += Vector3.new(0, -1, 0) end
	elseif inputState == Enum.UserInputState.End then
		if actionName == "Forward" then camDirection -= Vector3.new(0, 0, -1) end
		if actionName == "Backward" then camDirection -= Vector3.new(0, 0, 1) end
		if actionName == "Left" then camDirection -= Vector3.new(-1, 0, 0) end
		if actionName == "Right" then camDirection -= Vector3.new(1, 0, 0) end
		if actionName == "Up" then camDirection -= Vector3.new(0, 1, 0) end
		if actionName == "Down" then camDirection -= Vector3.new(0, -1, 0) end
	end
end

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
			rotation += Vector2.new(-delta.Y, -delta.X) * 0.2

			local pitch = math.rad(rotation.X)
			local yaw = math.rad(rotation.Y)
			camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.Angles(pitch, yaw, 0)
		end)
	else
		RunService:UnbindFromRenderStep("FreeCam")
		camera.CameraType = Enum.CameraType.Custom
		ContextActionService:UnbindAllActions()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end
end

-- GUI
local function createKeybindGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "KeybindInfo"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 200)
	frame.Position = UDim2.new(0.5, -150, 0.5, -100)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Draggable = true
	frame.Active = true
	frame.Parent = screenGui

	local uilist = Instance.new("UIListLayout", frame)
	uilist.Padding = UDim.new(0, 4)

	local keybinds = {
		"G - Sky Platform",
		"J - God Mode",
		"N - Invisibility",
		"M - Toggle Freecam"
	}

	for _, text in pairs(keybinds) do
		local label = Instance.new("TextLabel")
		label.Text = text
		label.Size = UDim2.new(1, -10, 0, 20)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 16
		label.Parent = frame
	end

	local credit = Instance.new("TextLabel")
	credit.Text = "CREDIT TO - VANITAS"
	credit.Size = UDim2.new(1, -10, 0, 20)
	credit.BackgroundTransparency = 1
	credit.TextColor3 = Color3.fromRGB(255, 215, 0)
	credit.Font = Enum.Font.SourceSansBold
	credit.TextSize = 14
	credit.TextXAlignment = Enum.TextXAlignment.Center
	credit.Parent = frame
end

-- Binds
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.G then createSkyPlatform() end
	if input.KeyCode == Enum.KeyCode.J then makeGodMode() end
	if input.KeyCode == Enum.KeyCode.N then becomeInvisible() end
	if input.KeyCode == Enum.KeyCode.M then toggleFreeCam() end
end)

createKeybindGui()
