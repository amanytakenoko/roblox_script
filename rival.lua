-- RIVALS Ultimate Cheat Script - Final Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local flySpeed = 50
local walkSpeedMultiplier = 2
local isFlying = false
local flyVelocity
local originalWalkSpeed

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsCheatGUI"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.ClipsDescendants = true

local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 40)

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = titleBar
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "RIVALS ULTIMATE"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Parent = mainFrame
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
contentFrame.BorderSizePixel = 0
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.Size = UDim2.new(1, -20, 1, -60)

local function createToggleButton(name, position, defaultState, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = contentFrame
    button.BackgroundColor3 = defaultState and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(0, 120, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button

    local state = defaultState
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
        callback(state)
    end)

    return button
end

local function createSlider(name, position, min, max, defaultValue, callback)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = contentFrame
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = UDim2.new(0, 100, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = name .. ": " .. defaultValue
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("TextButton")
    slider.Name = name .. "Slider"
    slider.Parent = contentFrame
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.BorderSizePixel = 0
    slider.Position = UDim2.new(0, position.X.Offset + 110, 0, position.Y.Offset)
    slider.Size = UDim2.new(0, 150, 0, 20)
    slider.Font = Enum.Font.SourceSans
    slider.Text = ""
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.TextSize = 14

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = slider

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Parent = slider
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = sliderFill

    local sliding = false
    slider.MouseButton1Down:Connect(function() sliding = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding then
            local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * relativeX
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            label.Text = name .. ": " .. math.floor(value)
            callback(value)
        end
    end)
end

local espEnabled = false
local aimbotEnabled = false
local infiniteAmmoEnabled = false
local flyEnabled = false

createToggleButton("ESP", UDim2.new(0, 10, 0, 10), false, function(state) espEnabled = state end)
createToggleButton("Aimbot", UDim2.new(0, 140, 0, 10), false, function(state) aimbotEnabled = state end)
createToggleButton("Infinite Ammo", UDim2.new(0, 270, 0, 10), false, function(state) infiniteAmmoEnabled = state end)
createToggleButton("Fly", UDim2.new(0, 10, 0, 50), false, function(state) toggleFly(state) end)

createSlider("Fly Speed", UDim2.new(0, 10, 0, 90), 10, 200, 50, function(value) flySpeed = value end)
createSlider("Walk Speed", UDim2.new(0, 10, 0, 120), 16, 100, 32, function(value) setWalkSpeed(value) end)

local function notify(message)
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Color = Color3.fromRGB(100, 200, 255);
        Font = Enum.Font.GothamBold;
        Text = "[RIVALS ULTIMATE] " .. message;
    })
end

local function createESP(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Vector3.new(4, 5, 2)
    espBox.Adornee = humanoidRootPart
    espBox.Color3 = Color3.new(1, 0, 0)
    espBox.Transparency = 0.7
    espBox.AlwaysOnTop = true
    espBox.ZIndex = 10
    espBox.Parent = humanoidRootPart

    local nameLabel = Instance.new("BillboardGui")
nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0, 100, 0, 20)
    nameLabel.StudsOffset = Vector3.new(0, 3, 0)
    nameLabel.AlwaysOnTop = true
    nameLabel.Parent = humanoidRootPart

    local nameText = Instance.new("TextLabel")
    nameText.Size = UDim2.new(1, 0, 1, 0)
    nameText.BackgroundTransparency = 1
    nameText.Text = player.Name
    nameText.TextColor3 = Color3.new(1, 1, 1)
    nameText.TextStrokeTransparency = 0
    nameText.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameText.Font = Enum.Font.SourceSansBold
    nameText.TextSize = 14
    nameText.Parent = nameLabel

    local healthBar = Instance.new("BillboardGui")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(0, 50, 0, 5)
    healthBar.StudsOffset = Vector3.new(0, 2, 0)
    healthBar.AlwaysOnTop = true
    healthBar.Parent = humanoidRootPart

    local healthBackground = Instance.new("Frame")
    healthBackground.Size = UDim2.new(1, 0, 1, 0)
    healthBackground.BackgroundColor3 = Color3.new(0, 0, 0)
    healthBackground.BorderSizePixel = 0
    healthBackground.Parent = healthBar

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBackground

    humanoid.HealthChanged:Connect(function(health)
        local maxHealth = humanoid.MaxHealth
        local healthPercentage = math.clamp(health / maxHealth, 0, 1)
        healthFill.Size = UDim2.new(healthPercentage, 0, 1, 0)
        if healthPercentage <= 0.3 then
            healthFill.BackgroundColor3 = Color3.new(1, 0, 0)
        elseif healthPercentage <= 0.6 then
            healthFill.BackgroundColor3 = Color3.new(1, 1, 0)
        else
            healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
        end
    end)

    humanoid.Died:Connect(function()
        espBox:Destroy()
        nameLabel:Destroy()
        healthBar:Destroy()
        player.CharacterAdded:Connect(function(newCharacter)
            if espEnabled then createESP(player, newCharacter) end
        end)
    end)
end

local function enableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= player then
            if player.Character then
                createESP(player, player.Character)
            else
                player.CharacterAdded:Connect(function(character)
                    createESP(player, character)
                end)
            end
        end
    end

    Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer ~= player then
            newPlayer.CharacterAdded:Connect(function(character)
                if espEnabled then createESP(newPlayer, character) end
            end)
        end
    end)
end

local function enableAimbot()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
            local closestPlayer = nil
            local shortestDistance = math.huge

            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    local character = targetPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local distance = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = targetPlayer
                        end
                    end
                end
            end

            if closestPlayer and closestPlayer.Character:FindFirstChild("Head") then
                local cam = Workspace.CurrentCamera
                cam.CFrame = CFrame.new(cam.CFrame.Position, closestPlayer.Character.Head.Position)
            end
        end
    end)
end

local function setWalkSpeed(speed)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed
    end
end

local function toggleFly(state)
    isFlying = state
    if state then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyVelocity.Parent = player.Character.HumanoidRootPart
            player.Character.Humanoid.PlatformStand = true
            notify("Fly Enabled")
        end
    else
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
        notify("Fly Disabled")
    end
end

local flyControls = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    Shift = false
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.W then flyControls.W = true end
        if input.KeyCode == Enum.KeyCode.A then flyControls.A = true end
        if input.KeyCode == Enum.KeyCode.S then flyControls.S = true end
        if input.KeyCode == Enum.KeyCode.D then flyControls.D = true end
        if input.KeyCode == Enum.KeyCode.Space then flyControls.Space = true end
        if input.KeyCode == Enum.KeyCode.LeftShift then flyControls.Shift = true end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.W then flyControls.W = false end
        if input.KeyCode == Enum.KeyCode.A then flyControls.A = false end
        if input.KeyCode == Enum.KeyCode.S then flyControls.S = false end
        if input.KeyCode == Enum.KeyCode.D then flyControls.D = false end
        if input.KeyCode == Enum.KeyCode.Space then flyControls.Space = false end
        if input.KeyCode == Enum.KeyCode.LeftShift then flyControls.Shift = false end
    end
end)

RunService.Heartbeat:Connect(function()
    if isFlying and flyVelocity then
        local direction = Vector3.new()
        local camCF = camera.CFrame
        if flyControls.W then direction = direction + camCF.LookVector end
        if flyControls.S then direction = direction - camCF.LookVector end
        if flyControls.A then direction = direction - camCF.RightVector end
        if flyControls.D then direction = direction + camCF.RightVector end
        if flyControls.Space then direction = direction + Vector3.new(0, 1, 0) end
        if flyControls.Shift then direction = direction - Vector3.new(0, 1, 0) end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit
        end
        
        flyVelocity.Velocity = direction * flySpeed
    end
end)

local function infiniteAmmoLoop()
    while true do
        if infiniteAmmoEnabled then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local ammoValue = tool:FindFirstChild("Ammo") or tool:FindFirstChild("AmmoCount") or tool:FindFirstChild("RemainingAmmo")
                        if ammoValue and ammoValue:IsA("NumberValue") or ammoValue:IsA("IntValue") then
                            ammoValue.Value = math.huge
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

enableESP()
enableAimbot()
spawn(infiniteAmmoLoop)
notify("RIVARS ULTIMATE Loaded. Use GUI to toggle features.")