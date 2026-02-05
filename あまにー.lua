local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ScreenGui = Instance.new("ScreenGui")
local TextLabel = Instance.new("TextLabel")

-- GUIの設定
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
TextLabel.Size = UDim2.new(0, 200, 0, 50)
TextLabel.Position = UDim2.new(0, 10, 0, 10)
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.Text = "Fake Position: (200, 200, 200)"
TextLabel.Parent = ScreenGui

local function onTouch(Hit)
    local player = Players:GetPlayerFromCharacter(Hit.Parent)
    if player then
        local targetPosition = Vector3.new(100, 100, 100) -- テレポート先の位置をここに設定
        player.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    end
end

local part = Instance.new("Part")
part.Size = Vector3.new(1, 1, 1)
part.Position = Vector3.new(0, 0, 0) -- パートの初期位置を設定
part.Anchored = true
part.CanCollide = false
part.Transparency = 1
part.Parent = workspace

local touchConnection = part.Touched:Connect(onTouch)

-- 偽の位置表示
RunService.RenderStepped:Connect(function()
    local player = Players.LocalPlayer
    if player and player.Character then
        local fakePosition = Vector3.new(200, 200, 200) -- 表示する偽の位置を設定
        player.Character:SetPrimaryPartCFrame(CFrame.new(fakePosition))
    end
end)

-- ESPの設定
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESPGui"
espGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local function createEspBox(player)
    local espBox = Instance.new("TextLabel")
    espBox.Size = UDim2.new(0, 100, 0, 20)
    espBox.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    espBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBox.Text = player.Name
    espBox.Parent = espGui
    espBox.ZIndex = 10

    RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                espBox.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 10)
            end
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createEspBox(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        createEspBox(player)
    end
end)

-- トラッキング機能
local trackingPlayer = nil
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        if trackingPlayer then
            trackingPlayer = nil
            print("トラッキングを解除しました。")
        else
            local closestPlayer = nil
            local closestDistance = math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
            if closestPlayer then
                trackingPlayer = closestPlayer
                print("プレイヤー " .. closestPlayer.Name .. " をトラッキング開始しました。")
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if trackingPlayer and trackingPlayer.Character and trackingPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = trackingPlayer.Character.HumanoidRootPart.Position
        local direction = (targetPosition - Players.LocalPlayer.Character.HumanoidRootPart.Position).unit
        Players.LocalPlayer.Character.Humanoid:MoveTo(targetPosition)
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Players.LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
    end
end)

-- ノックバック機能
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.N then
        if trackingPlayer and trackingPlayer.Character and trackingPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local knockbackForce = Vector3.new(0, 50, 0) -- ノックバックの力を調整
            trackingPlayer.Character.HumanoidRootPart.Velocity = knockbackForce
            print("プレイヤー " .. trackingPlayer.Name .. " をノックバックしました。")
        end
    end
end)

-- ファーストパーソン視点の切り替え
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        if trackingPlayer and trackingPlayer.Character and trackingPlayer.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CameraSubject = trackingPlayer.Character
            workspace.CurrentCamera.CFrame = CFrame.new(trackingPlayer.Character.Head.Position)
            print("プレイヤー " .. trackingPlayer.Name .. " の視点に切り替えました。")
        end
    end
end)

-- アイテムの自動取得
RunService.RenderStepped:Connect(function()
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Part") and item.Name == "Item" then
            local distance = (Players.LocalPlayer.Character.HumanoidRootPart.Position - item.Position).magnitude
            if distance < 10 then -- 10スタジオユニット以内のアイテムを取得
                item.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

-- ウォールハック
local function isVisible(part)
    local ray = Ray.new(part.Position, (workspace.CurrentCamera.CFrame.Position - part.Position).unit)
    local hit, position = workspace:FindPartOnRay(ray, Players.LocalPlayer.Character)
    return hit == part
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if not onScreen and isVisible(player.Character.HumanoidRootPart) then
                local espBox = Instance.new("TextLabel")
                espBox.Size = UDim2.new(0, 100, 0, 20)
                espBox.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                espBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                espBox.Text = player.Name
                espBox.Parent = espGui
                espBox.ZIndex = 10

                RunService.RenderStepped:Connect(function()
                    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                        if onScreen then
                            espBox.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 10)
                        end
                    end
                end)
            end
        end
    end
end)