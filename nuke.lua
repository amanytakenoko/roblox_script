local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local FLY_SPEED = 50
local WALK_SPEED = 100

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local isFlying = false
        
        local ScreenGui = Instance.new("ScreenGui")
        local StartButton = Instance.new("TextButton")
        local FlyButton = Instance.new("TextButton")
        
        ScreenGui.Parent = player:WaitForChild("PlayerGui")
        
        StartButton.Size = UDim2.new(0, 200, 0, 50)
        StartButton.Position = UDim2.new(0.5, -100, 0.5, -100)
        StartButton.Text = "Start"
        StartButton.BackgroundColor3 = Color3.new(1, 0, 0)
        StartButton.Parent = ScreenGui
        
        FlyButton.Size = UDim2.new(0, 200, 0, 50)
        FlyButton.Position = UDim2.new(0.5, -100, 0.5, 0)
        FlyButton.Text = "Fly"
        FlyButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        FlyButton.Parent = ScreenGui
        
        local BodyVelocity
        local BodyGyro
        
        local function increaseWalkSpeed()
            humanoid.WalkSpeed = WALK_SPEED
        end
        
        local function enableFly()
            if not BodyVelocity then
                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                BodyVelocity.P = 2000
                BodyVelocity.Parent = character.PrimaryPart
            end
            
            if not BodyGyro then
                BodyGyro = Instance.new("BodyGyro")
                BodyGyro.P = 9e4
                BodyGyro.maxTorque = Vector3.new(4000, 4000, 4000)
                BodyGyro.cframe = character.PrimaryPart.CFrame
                BodyGyro.Parent = character.PrimaryPart
            end
            
            isFlying = true
        end
        
        local function disableFly()
            isFlying = false
            if BodyVelocity then
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
        
        StartButton.MouseButton1Click:Connect(function()
            increaseWalkSpeed()
            enableFly()
            StartButton.BackgroundColor3 = Color3.new(0, 1, 0)
        end)
        
        FlyButton.MouseButton1Click:Connect(function()
            isFlying = not isFlying
            if isFlying then
                enableFly()
                FlyButton.BackgroundColor3 = Color3.new(0, 1, 0)
            else
                disableFly()
                FlyButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
            end
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.E then
                isFlying = not isFlying
                if isFlying then
                    enableFly()
                    FlyButton.BackgroundColor3 = Color3.new(0, 1, 0)
                else
                    disableFly()
                    FlyButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
                end
            end
        end)
        
        local rotation = 0
        RunService.RenderStepped:Connect(function()
            if isFlying and BodyVelocity and BodyGyro then
                local camera = workspace.CurrentCamera
                BodyVelocity.Velocity = (camera.CoordinateFrame.lookVector * Vector3.new(1, 0, 1)).unit * FLY_SPEED
                BodyGyro.cframe = camera.CoordinateFrame * CFrame.Angles(0, math.rad(rotation), 0)
            end
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
