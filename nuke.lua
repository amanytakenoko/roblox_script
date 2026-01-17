local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function onPlayerAdded(player)
    local function increaseWalkSpeed(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 100 -- 速度を大幅に増加
    end

    local function enableFly(character)
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        BodyVelocity.P = 2000

        local BodyGyro = Instance.new("BodyGyro")
        BodyGyro.P = 9e4
        BodyGyro.maxTorque = Vector3.new(4000, 4000, 4000)

        BodyGyro.cframe = character.PrimaryPart.CFrame
        BodyVelocity.Parent = character.PrimaryPart
        BodyGyro.Parent = character.PrimaryPart

        local fly = false
        local e = 0

        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.E then
                fly = not fly
                e = fly and 1 or 0
            end
        end)

        game:GetService("RunService").RenderStepped:Connect(function()
            if fly then
                BodyVelocity.Velocity = (workspace.CurrentCamera.CoordinateFrame.lookVector * Vector3.new(1, 0, 1)).unit * 50
                BodyGyro.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(0, math.rad(e), 0)
            end
        end)
    end

    local function knockbackOtherPlayers(character)
        game:GetService("RunService").RenderStepped:Connect(function()
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.PrimaryPart.Position - otherPlayer.Character.PrimaryPart.Position).magnitude
                    if distance < 20 then -- 近くにいるプレイヤーを吹き飛ばす
                        local direction = (otherPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).unit
                        otherPlayer.Character.PrimaryPart.Velocity = direction * 500
                    end
                end
            end
        end)
    end

    local ScreenGui = Instance.new("ScreenGui")
    local StartButton = Instance.new("TextButton")
    local FlyButton = Instance.new("TextButton")

    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    StartButton.Size = UDim2.new(0, 200, 0, 50)
    StartButton.Position = UDim2.new(0.5, -100, 0.5, -100)
    StartButton.Text = "Start"
    StartButton.BackgroundColor3 = Color3.new(1, 0, 0) -- 赤
    StartButton.Parent = ScreenGui

    FlyButton.Size = UDim2.new(0, 200, 0, 50)
    FlyButton.Position = UDim2.new(0.5, -100, 0.5, 0)
    FlyButton.Text = "Fly"
    FlyButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5) -- 灰色
    FlyButton.Parent = ScreenGui

    StartButton.MouseButton1Click:Connect(function()
        increaseWalkSpeed(player.Character)
        enableFly(player.Character)
        knockbackOtherPlayers(player.Character)
        StartButton.BackgroundColor3 = Color3.new(0, 1, 0) -- 緑
    end)

    FlyButton.MouseButton1Click:Connect(function()
        local character = player.Character
        local fly = not fly
        if fly then
            enableFly(character)
            FlyButton.BackgroundColor3 = Color3.new(0, 1, 0) -- 緑
        else
            FlyButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5) -- 灰色
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)