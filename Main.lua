-- LocalScript for CREEPY_SHANKS with GUI and Keybinds
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

if player.Name ~= "CREEPY_SHANKS" then return end

local freeCamEnabled = false
local camSpeed = 5
local camDirection = Vector3.new()
local rotation = Vector2.new()

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminKeybindsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0.5, -150, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiList = Instance.new("UIListLayout")
uiList.Parent = frame
uiList.Padding = UDim.new(0, 5)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

local function addLabel(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSans
	label.Parent = frame
end

addLabel("G - Teleport to Sky Platform")
addLabel("N - Become Invisible")
addLabel("M - Toggle FreeCam")
addLabel("J - Infinite Health")

-- Functions
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

	hrP.CFrame = CFrame.new(platform.Position + Vector3.new(0, 5, 0))
end

local function becomeInvisible()
	local character = player.Character or player.CharacterAdded:Wait()
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 1
			for _, decal in pairs(part:GetChildren()) do
				if decal:IsA("Decal") then
					decal.Transparency = 1
				end
			end
		elseif part:IsA("Accessory") then
			part.Handle.Transparency = 1
		end
	end
end

local function toggleFreeCam()
	freeCamEnabled = not freeCamEnabled
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	if freeCamEnabled then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = hrp.CFrame
		rotation = Vector2.new()

		ContextActionService:BindAction("Forward", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 0, -1) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 0, -1) end
		end, false, Enum.KeyCode.W)
		ContextActionService:BindAction("Backward", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 0, 1) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 0, 1) end
		end, false, Enum.KeyCode.S)
		ContextActionService:BindAction("Left", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(-1, 0, 0) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(-1, 0, 0) end
		end, false, Enum.KeyCode.A)
		ContextActionService:BindAction("Right", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(1, 0, 0) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(1, 0, 0) end
		end, false, Enum.KeyCode.D)
		ContextActionService:BindAction("Up", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 1, 0) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 1, 0) end
		end, false, Enum.KeyCode.Space)
		ContextActionService:BindAction("Down", function(_, s)
			if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, -1, 0) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(0, -1, 0) end
		end, false, Enum.KeyCode.LeftShift)

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false

		RunService:BindToRenderStep("FreeCam", Enum.RenderPriority.Camera.Value, function(dt)
			local move = camera.CFrame:VectorToWorldSpace(camDirection) * camSpeed
			camera.CFrame = camera.CFrame + move * dt

			local delta = UserInputService:GetMouseDelta()
			rotation = rotation + Vector2.new(-delta.Y, -delta.X) * 0.2
			camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), 0)
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

local function makeInvincible()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			humanoid.Health = math.huge
		end)
	end
	character.DescendantAdded:Connect(function(desc)
		if desc:IsA("Script") or desc:IsA("LocalScript") then
			desc.Disabled = true
		end
	end)
end

-- Keybind Handling
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.G then createSkyPlatform() end
	if input.KeyCode == Enum.KeyCode.N then becomeInvisible() end
	if input.KeyCode == Enum.KeyCode.M then toggleFreeCam() end
	if input.KeyCode == Enum.KeyCode.J then makeInvincible() end
end)
