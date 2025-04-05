-- LocalScript for CREEPY_SHANKS
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

if player.Name ~= "CREEPY_SHANKS" then return end

-- Variables
local freeCamEnabled = false
local godMode = false
local invisible = false
local camSpeed = 2
local camDirection = Vector3.new()
local rotation = Vector2.new()

-- Functions
local function makeGui()
	local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
	gui.Name = "AdminControlPanel"
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 300, 0, 300)
	frame.Position = UDim2.new(0.5, -150, 0.5, -150)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true

	local uiList = Instance.new("UIListLayout", frame)
	uiList.Padding = UDim.new(0, 5)

	local function createToggle(labelText, callback)
		local container = Instance.new("Frame", frame)
		container.Size = UDim2.new(1, 0, 0, 30)
		container.BackgroundTransparency = 1

		local label = Instance.new("TextLabel", container)
		label.Size = UDim2.new(0.6, 0, 1, 0)
		label.Text = labelText
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.SourceSans
		label.TextSize = 16

		local button = Instance.new("TextButton", container)
		button.Size = UDim2.new(0.3, 0, 1, 0)
		button.Position = UDim2.new(0.7, 0, 0, 0)
		button.Text = "OFF"
		button.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Font = Enum.Font.SourceSansBold
		button.TextSize = 14

		local active = false
		button.MouseButton1Click:Connect(function()
			active = not active
			button.Text = active and "ON" or "OFF"
			button.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
			callback(active)
		end)
	end

	local footer = Instance.new("TextLabel", frame)
	footer.Size = UDim2.new(1, 0, 0, 25)
	footer.Text = "CREDIT TO - VANITAS"
	footer.TextColor3 = Color3.fromRGB(200, 200, 200)
	footer.BackgroundTransparency = 1
	footer.Font = Enum.Font.SourceSansBold
	footer.TextSize = 14

	return createToggle
end

-- Actions
local function toggleFreeCam(state)
	freeCamEnabled = state
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	if freeCamEnabled then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = hrp.CFrame

		ContextActionService:BindAction("Forward", function(_, s) if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 0, -1) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 0, -1) end end, false, Enum.KeyCode.W)
		ContextActionService:BindAction("Backward", function(_, s) if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 0, 1) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 0, 1) end end, false, Enum.KeyCode.S)
		ContextActionService:BindAction("Left", function(_, s) if s == Enum.UserInputState.Begin then camDirection += Vector3.new(-1, 0, 0) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(-1, 0, 0) end end, false, Enum.KeyCode.A)
		ContextActionService:BindAction("Right", function(_, s) if s == Enum.UserInputState.Begin then camDirection += Vector3.new(1, 0, 0) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(1, 0, 0) end end, false, Enum.KeyCode.D)
		ContextActionService:BindAction("Up", function(_, s) if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, 1, 0) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(0, 1, 0) end end, false, Enum.KeyCode.Space)
		ContextActionService:BindAction("Down", function(_, s) if s == Enum.UserInputState.Begin then camDirection += Vector3.new(0, -1, 0) elseif s == Enum.UserInputState.End then camDirection -= Vector3.new(0, -1, 0) end end, false, Enum.KeyCode.LeftShift)

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false

		RunService:BindToRenderStep("FreeCam", Enum.RenderPriority.Camera.Value, function(dt)
			camera.CFrame = camera.CFrame + camera.CFrame:VectorToWorldSpace(camDirection) * camSpeed * dt
			local delta = UserInputService:GetMouseDelta()
			rotation = rotation + Vector2.new(-delta.Y, -delta.X) * 0.2
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

local function setGodMode(state)
	godMode = state
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if godMode then
			humanoid.Health = math.huge
			humanoid.MaxHealth = math.huge
			humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if godMode then
					humanoid.Health = math.huge
				end
			end)
		else
			humanoid.MaxHealth = 100
			humanoid.Health = 100
		end
	end
end

local function setInvisible(state)
	invisible = state
	local char = player.Character or player.CharacterAdded:Wait()
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = state and 1 or 0
		elseif part:IsA("Accessory") then
			part.Handle.Transparency = state and 1 or 0
		elseif part:IsA("Decal") then
			part.Transparency = state and 1 or 0
		end
	end
end

local function createSkyPlatform()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local platform = Instance.new("Part")
	platform.Name = "SkyPlatform"
	platform.Size = Vector3.new(20, 1, 20)
	platform.Position = Vector3.new(0, 500, 0)
	platform.Anchored = true
	platform.BrickColor = BrickColor.new("Bright yellow")
	platform.Material = Enum.Material.Neon
	platform.Parent = workspace

	hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, 5, 0))
end

-- GUI creation and hook
local createToggle = makeGui()

createToggle("Invisibility (N)", setInvisible)
createToggle("God Mode (J)", setGodMode)
createToggle("FreeCam (M)", toggleFreeCam)
createToggle("Sky Platform (G)", function(state)
	if state then
		createSkyPlatform()
	end
end)
