local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local espEnabled, aimbotEnabled, flyEnabled = false, false, false
local flySpeed = 50
local isFlying = false
local flyVelocity

local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "RivalsCheatGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "RIVARS ULTIMATE"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold

local function notify(msg)
    StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[RIVARS] " .. msg, Color = Color3.new(0.3, 0.6, 1)})
end

local function createToggle(name, pos, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, 100, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(50, 50, 60)
        callback(state)
    end)
end

createToggle("ESP", UDim2.new(0, 20, 0, 60), function(v) espEnabled = v end)
createToggle("Aimbot", UDim2.new(0, 130, 0, 60), function(v) aimbotEnabled = v end)
createToggle("Fly", UDim2.new(0, 240, 0, 60), function(v) toggleFly(v) end)

local espObjects = {}
local function addESP(player)
    if espObjects[player] then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 2)
    if not hrp then return end

    local bbg = Instance.new("BillboardGui", hrp)
    bbg.Size = UDim2.new(0, 60, 0, 25)
    bbg.StudsOffset = Vector3.new(0, 3, 0)
    bbg.AlwaysOnTop = true
    local txt = Instance.new("TextLabel", bbg)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = player.Name
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextStrokeTransparency = 0
    txt.TextSize = 14

    local h = char:WaitForChild("Humanoid", 2)
    if h then
        h.HealthChanged:Connect(function()
            if espObjects[player] then
                txt.Text = player.Name .. " [" .. math.floor(h.Health) .. "/" .. h.MaxHealth .. "]"
            end
        end)
    end
    espObjects[player] = bbg
end

local function removeESP(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end

local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            if espEnabled then
                addESP(p)
            else
                removeESP(p)
            end
        end
    end
end
Players.PlayerAdded:Connect(function(p) if espEnabled then addESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)
game:GetService("RunService").Heartbeat:Connect(updateESP)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local closest, dist = nil, 9999
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local mag = (p.Character.Head.Position - camera.CFrame.Position).Magnitude
                if mag < dist then dist, closest = mag, p end
            end
        end
        if closest and closest.Character:FindFirstChild("Head") then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Character.Head.Position)
        end
    end
end)

local function toggleFly(state)
    isFlying = state
    if state then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyVelocity.P = 1e4
            flyVelocity.Parent = player.Character.HumanoidRootPart
            player.Character.Humanoid.PlatformStand = true
            notify("Fly ON")
        end
    else
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
        notify("Fly OFF")
    end
end

local flyControls = {W=false, A=false, S=false, D=false, Space=false, Shift=false}
UserInputService.InputBegan:Connect(function(i, gpe) if not gpe then if i.KeyCode==Enum.KeyCode.W then flyControls.W=true elseif i.KeyCode==Enum.KeyCode.A then flyControls.A=true elseif i.KeyCode==Enum.KeyCode.S then flyControls.S=true elseif i.KeyCode==Enum.KeyCode.D then flyControls.D=true elseif i.KeyCode==Enum.KeyCode.Space then flyControls.Space=true elseif i.KeyCode==Enum.KeyCode.LeftShift then flyControls.Shift=true end end end)
UserInputService.InputEnded:Connect(function(i, gpe) if not gpe then if i.KeyCode==Enum.KeyCode.W then flyControls.W=false elseif i.KeyCode==Enum.KeyCode.A then flyControls.A=false elseif i.KeyCode==Enum.KeyCode.S then flyControls.S=false elseif i.KeyCode==Enum.KeyCode.D then flyControls.D=false elseif i.KeyCode==Enum.KeyCode.Space then flyControls.Space=false elseif i.KeyCode==Enum.KeyCode.LeftShift then flyControls.Shift=false end end end)

RunService.Heartbeat:Connect(function()
    if isFlying and flyVelocity then
        local dir = Vector3.new()
        local cam = camera.CFrame
        if flyControls.W then dir = dir + cam.LookVector end
        if flyControls.S then dir = dir - cam.LookVector end
        if flyControls.A then dir = dir - cam.RightVector end
        if flyControls.D then dir = dir + cam.RightVector end
        if flyControls.Space then dir = dir + Vector3.new(0, 1, 0) end
        if flyControls.Shift then dir = dir - Vector3.new(0, 1, 0) end
        flyVelocity.Velocity = dir.Unit * flySpeed
    end
end)

notify("Script Loaded")
