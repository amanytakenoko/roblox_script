local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local isLagging = false
local packetDelay = 0.5
local targetLagDuration = 2.0
local originalNetworkSettings = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 200)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 230, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Text = "Advanced Lag Switch"
titleLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 230, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 50)
toggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "Toggle Lag Switch"
toggleButton.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 230, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 90)
statusLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Text = "Status: OFF"
statusLabel.Parent = mainFrame

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0, 230, 0, 20)
delayLabel.Position = UDim2.new(0, 10, 0, 130)
delayLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
delayLabel.TextColor3 = Color3.new(1, 1, 1)
delayLabel.Text = "Packet Delay: 0.5s"
delayLabel.Parent = mainFrame

local delaySlider = Instance.new("TextButton")
delaySlider.Size = UDim2.new(0, 230, 0, 10)
delaySlider.Position = UDim2.new(0, 10, 0, 150)
delaySlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
delaySlider.Parent = mainFrame

local lagOthersButton = Instance.new("TextButton")
lagOthersButton.Size = UDim2.new(0, 230, 0, 30)
lagOthersButton.Position = UDim2.new(0, 10, 0, 170)
lagOthersButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
lagOthersButton.TextColor3 = Color3.new(1, 1, 1)
lagOthersButton.Text = "Lag Other Players"
lagOthersButton.Parent = mainFrame

local function manipulatePackets(enabled)
    if enabled then
        originalNetworkSettings.IncomingReplicationLag = game:GetService("NetworkSettings").IncomingReplicationLag
        originalNetworkSettings.ClientReplicator = game:GetService("NetworkSettings").ClientReplicator
        game:GetService("NetworkSettings").IncomingReplicationLag = packetDelay
        game:GetService("NetworkSettings").ClientReplicator = "LagSwitch"
    else
        if originalNetworkSettings.IncomingReplicationLag then
            game:GetService("NetworkSettings").IncomingReplicationLag = originalNetworkSettings.IncomingReplicationLag
        end
        if originalNetworkSettings.ClientReplicator then
            game:GetService("NetworkSettings").ClientReplicator = originalNetworkSettings.ClientReplicator
        end
    end
end

local function manipulateVisuals(enabled)
    if enabled then
        local originalPosition = character.PrimaryPart.Position
        local visualOffset = Vector3.new(0, 5, 0)
        
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player then
                local otherCharacter = otherPlayer.Character
                if otherCharacter and otherCharacter:FindFirstChild("HumanoidRootPart") then
                    otherCharacter.HumanoidRootPart:SetNetworkOwner(nil)
                    otherCharacter.HumanoidRootPart.Position = otherCharacter.HumanoidRootPart.Position + visualOffset
                end
            end
        end
        
        game:GetService("Debris"):AddItem(character, 0.1)
        character:MoveTo(originalPosition)
    else
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart:SetNetworkOwner(player)
        end
    end
end

local function lagOtherPlayers()
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherCharacter = otherPlayer.Character
            if otherCharacter and otherCharacter:FindFirstChild("Humanoid") then
                otherCharacter.Humanoid.WalkSpeed = 0.1
                game:GetService("Debris"):AddItem(otherCharacter, targetLagDuration)
                
                local networkPeer = game:GetService("NetworkClient"):GetServerPeer()
                if networkPeer then
                    networkPeer:SendPacket({
                        Type = "LagOther",
                        Target = otherPlayer.UserId,
                        Duration = targetLagDuration
                    })
                end
            end
        end
    end
end

toggleButton.MouseButton1Click:Connect(function()
    isLagging = not isLagging
    statusLabel.Text = isLagging and "Status: ON" or "Status: OFF"
    
    manipulatePackets(isLagging)
    manipulateVisuals(isLagging)
end)

lagOthersButton.MouseButton1Click:Connect(function()
    lagOtherPlayers()
end)

delaySlider.MouseButton1Down:Connect(function()
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local updateDelay
    updateDelay = mouse.Move:Connect(function()
        local relativeX = mouse.X - delaySlider.AbsolutePosition.X
        local clampedX = math.clamp(relativeX, 0, delaySlider.AbsoluteSize.X)
        local percentage = clampedX / delaySlider.AbsoluteSize.X
        packetDelay = percentage * 2.0
        delayLabel.Text = "Packet Delay: " .. string.format("%.1f", packetDelay) .. "s"
        
        if isLagging then
            manipulatePackets(false)
            manipulatePackets(true)
        end
    end)
    
    delaySlider.MouseButton1Up:Connect(function()
        if updateDelay then
            updateDelay:Disconnect()
        end
    end)
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.L then
            toggleButton.MouseButton1Click:Fire()
        elseif input.KeyCode == Enum.KeyCode.K then
            lagOtherPlayers()
        end
    end
end)