local player = game.Players.LocalPlayer
local isLagging = false
local packetDelay = 0.5
local originalNetworkSettings = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.Parent = screenGui

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 230, 0, 40)
startButton.Position = UDim2.new(0, 10, 0, 10)
startButton.BackgroundColor3 = Color3.new(0, 1, 0)
startButton.TextColor3 = Color3.new(1, 1, 1)
startButton.Text = "Start"
startButton.Font = Enum.Font.SourceSansBold
startButton.TextSize = 20
startButton.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 230, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 60)
statusLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Text = "Status: OFF"
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 18
statusLabel.Parent = mainFrame

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0, 230, 0, 20)
delayLabel.Position = UDim2.new(0, 10, 0, 100)
delayLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
delayLabel.TextColor3 = Color3.new(1, 1, 1)
delayLabel.Text = "Lag Intensity: 50%"
delayLabel.Font = Enum.Font.SourceSans
delayLabel.TextSize = 16
delayLabel.Parent = mainFrame

local delaySlider = Instance.new("TextButton")
delaySlider.Size = UDim2.new(0, 230, 0, 10)
delaySlider.Position = UDim2.new(0, 10, 0, 130)
delaySlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
delaySlider.Parent = mainFrame

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

startButton.MouseButton1Click:Connect(function()
    isLagging = not isLagging
    statusLabel.Text = isLagging and "Status: ON" or "Status: OFF"
    
    if isLagging then
        startButton.Text = "Stop"
        startButton.BackgroundColor3 = Color3.new(1, 0, 0)
    else
        startButton.Text = "Start"
        startButton.BackgroundColor3 = Color3.new(0, 1, 0)
    end
    
    manipulatePackets(isLagging)
end)

delaySlider.MouseButton1Down:Connect(function()
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local updateDelay
    updateDelay = mouse.Move:Connect(function()
        local relativeX = mouse.X - delaySlider.AbsolutePosition.X
        local clampedX = math.clamp(relativeX, 0, delaySlider.AbsoluteSize.X)
        local percentage = clampedX / delaySlider.AbsoluteSize.X
        packetDelay = percentage * 2.0
        delayLabel.Text = "Lag Intensity: " .. math.floor(percentage * 100) .. "%"
        
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
