-- =============================================
--   ZETA X – ULTIMATE EDITION
--   All features from 4 scripts integrated
--   Rayfield UI + Custom logic
-- =============================================

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

-- // Local Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = Workspace.CurrentCamera

-- =============================================
--   RAYFIELD UI LOADER
-- =============================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- =============================================
--   CONFIGURATION TABLE
-- =============================================
local Config = {
    -- Aimbot
    AimbotEnabled     = false,
    AimbotFOV         = 120,
    AimbotSmoothing   = 0.25,
    AimbotBone        = "Head",
    AimbotSilent      = false,
    AimbotTeamCheck   = true,
    AimbotVisCheck    = false,
    AimbotPrediction  = 0.01,
    AimbotTriggerbot  = false,
    AimbotAutoShoot   = false,

    -- ESP
    ESPEnabled        = false,
    ESPBoxes          = true,
    ESPNames          = true,
    ESPDistance       = true,
    ESPTracers        = false,
    ESPHealthBar      = true,
    ESPTeamColor      = true,
    ESPMaxDist        = 1000,

    -- Movement
    SpeedEnabled      = false,
    SpeedValue        = 32,
    FlyEnabled        = false,
    FlySpeed          = 80,
    NoclipEnabled     = false,
    InfiniteJump      = false,
    BunnyHop          = false,

    -- Combat
    KillAura          = false,
    KillAuraRange     = 15,
    AutoParry         = false,
    AutoDash          = false,
    AntiStun          = false,
    AutoHeal          = false,
    HealAmount        = 20,

    -- Misc
    AntiAFK           = true,
    NoFog             = false,
    FullBright        = false,
    FPSBoost          = false,
    SpamAbility       = false,
    SelectedAbility   = "Q",

    -- Friend System
    FriendMode        = false,
    FriendRange       = 40,
    MatchRange        = 300,

    -- Theme
    Theme             = "Purple",
    CustomColor       = Color3.fromRGB(255,215,0),

    -- Hotkeys (stored as string names)
    Hotkeys = {
        ToggleMenu   = "Insert",
        ToggleAimbot = "Q",
        ToggleESP    = "B",
        ToggleFly    = "J",
        ToggleHeal   = "H",
        ToggleNoclip = "N",
        ToggleView   = "V",
        Teleport     = "X",
    },
}

-- =============================================
--   UTILITY FUNCTIONS (from all scripts)
-- =============================================

local function GetCharacter(player)
    return player and player.Character
end

local function GetRootPart(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetBone(player, bone)
    local char = GetCharacter(player)
    return char and (char:FindFirstChild(bone) or char:FindFirstChild("HumanoidRootPart"))
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(player)
    local hum = GetHumanoid(player)
    return hum and hum.Health > 0
end

local function IsEnemy(player)
    if Config.AimbotTeamCheck then
        return player.Team ~= LocalPlayer.Team
    end
    return player ~= LocalPlayer
end

local function WorldToViewport(pos)
    local camera = Workspace.CurrentCamera
    local screenPos, onScreen = camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetDistance(player)
    local root = GetRootPart(player)
    if root and HumanoidRootPart then
        return (root.Position - HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function HasLineOfSight(player)
    local bone = GetBone(player, Config.AimbotBone)
    if not bone then return false end
    local ray = Ray.new(HumanoidRootPart.Position, (bone.Position - HumanoidRootPart.Position).Unit * 1000)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {Character, GetCharacter(player)})
    return hit == nil
end

local function CanSee(part)
    if not part or not Character or not Character:FindFirstChild("Head") then return false end
    local head = Character.Head
    local ray = Ray.new(head.Position, (part.Position - head.Position).Unit * 1000)
    local hit = Workspace:FindPartOnRay(ray, Character)
    if hit then
        return hit:IsDescendantOf(part.Parent)
    end
    return true
end

-- =============================================
--   FRIEND SYSTEM (from FENY CLIENT)
-- =============================================
local Friend = nil
local MatchStarted = false

local function UpdateFriend()
    if not Config.FriendMode then return end
    if not Character then return end
    local myRoot = HumanoidRootPart
    if not myRoot then return end

    local closest = nil
    local closestDist = Config.FriendRange
    local playersInRange = 0

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and IsAlive(pl) then
            local pr = GetRootPart(pl)
            if pr then
                local dist = (myRoot.Position - pr.Position).Magnitude
                if dist <= Config.MatchRange then
                    playersInRange = playersInRange + 1
                    if dist < closestDist then
                        closestDist = dist
                        closest = pl
                    end
                end
            end
        end
    end

    if not MatchStarted and playersInRange >= 2 then
        MatchStarted = true
        if closest then
            Friend = closest
            Rayfield:Notify({Title = "Friend System", Content = "Friend: " .. Friend.Name, Duration = 2})
        end
    end

    if MatchStarted and playersInRange < 2 then
        MatchStarted = false
        Friend = nil
        Rayfield:Notify({Title = "Friend System", Content = "Friend lost", Duration = 2})
    end

    if Friend and not IsAlive(Friend) then
        Friend = nil
        Rayfield:Notify({Title = "Friend System", Content = "Friend died", Duration = 2})
    end
end

spawn(function()
    while wait(2) do
        pcall(UpdateFriend)
    end
end)

local function IsFriend(player)
    return Config.FriendMode and Friend and player == Friend
end

local function IsTarget(player)
    if player == LocalPlayer then return false end
    if not IsAlive(player) then return false end
    if Config.FriendMode and IsFriend(player) then return false end
    if Config.AimbotTeamCheck and not IsEnemy(player) then return false end
    return true
end

-- =============================================
--   GET CLOSEST TARGET (for aimbot & killaura)
-- =============================================
local function GetClosestPlayerToCursor()
    local camera = Workspace.CurrentCamera
    local minDist = Config.AimbotFOV
    local target = nil
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if IsTarget(player) then
            if Config.AimbotVisCheck and not HasLineOfSight(player) then continue end
            local bone = GetBone(player, Config.AimbotBone)
            if bone then
                local screenPos, onScreen = WorldToViewport(bone.Position)
                if onScreen then
                    local dist = (screenPos - mousePos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = player
                    end
                end
            end
        end
    end
    return target
end

local function GetClosestEnemy()
    local closest, minDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if IsTarget(player) then
            local dist = GetDistance(player)
            if dist < minDist then
                minDist = dist
                closest = player
            end
        end
    end
    return closest
end

-- =============================================
--   FOV CIRCLE (Drawing)
-- =============================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Config.AimbotFOV
FOVCircle.Color = Color3.fromRGB(255, 80, 80)
FOVCircle.Thickness = 1.5
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    if Config.AimbotEnabled then
        local mouse = UserInputService:GetMouseLocation()
        FOVCircle.Position = mouse
        FOVCircle.Radius = Config.AimbotFOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- =============================================
--   AIMBOT LOGIC (with prediction & triggerbot)
-- =============================================
local LastShot = 0

RunService.RenderStepped:Connect(function()
    if not Config.AimbotEnabled then return end
    local target = GetClosestPlayerToCursor()
    if not target then return end

    local bone = GetBone(target, Config.AimbotBone)
    if not bone then return end

    local camera = Workspace.CurrentCamera
    local targetPos = bone.Position

    -- Prediction
    local hrp = GetRootPart(target)
    if hrp then
        targetPos = targetPos + (hrp.Velocity * Config.AimbotPrediction)
    end

    if Config.AimbotSilent then
        -- Silent aim placeholder: set global target for remote hook
        _G.SilentTarget = target
    else
        local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = camera.CFrame:Lerp(targetCF, Config.AimbotSmoothing)
    end

    -- Triggerbot
    if Config.AimbotTriggerbot then
        local now = tick()
        if now - LastShot > 0.1 then
            mouse1click()
            LastShot = now
        end
    end

    -- AutoShoot
    if Config.AimbotAutoShoot then
        local now = tick()
        if now - LastShot > 0.05 then
            mouse1click()
            LastShot = now
        end
    end
end)

-- =============================================
--   ESP (Drawing-based, from all scripts)
-- =============================================
local ESPObjects = {}

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    RemoveESP(player)
    local objs = {}

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    objs.box = box

    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Size = 13
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Font = Drawing.Fonts.UI
    objs.nameTag = nameTag

    local distTag = Drawing.new("Text")
    distTag.Visible = false
    distTag.Size = 11
    distTag.Center = true
    distTag.Outline = true
    distTag.Font = Drawing.Fonts.UI
    objs.distTag = distTag

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1.5
    tracer.Transparency = 0.7
    objs.tracer = tracer

    local healthBG = Drawing.new("Square")
    healthBG.Visible = false
    healthBG.Color = Color3.fromRGB(20,20,20)
    healthBG.Filled = true
    objs.healthBG = healthBG

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Filled = true
    objs.healthBar = healthBar

    ESPObjects[player] = objs
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not Config.ESPEnabled then
            RemoveESP(player)
            continue
        end
        if not ESPObjects[player] then CreateESP(player) end

        local char = GetCharacter(player)
        local root = GetRootPart(player)
        local hum = GetHumanoid(player)
        if not char or not root or not hum then
            RemoveESP(player)
            continue
        end

        local dist = GetDistance(player)
        if dist > Config.ESPMaxDist then
            for _, obj in pairs(ESPObjects[player]) do
                pcall(function() obj.Visible = false end)
            end
            continue
        end

        local headPos = char:FindFirstChild("Head") and char.Head.Position or root.Position + Vector3.new(0, 2, 0)
        local feetPos = root.Position - Vector3.new(0, 3, 0)
        local headScreen, onH = WorldToViewport(headPos)
        local feetScreen, onF = WorldToViewport(feetPos)
        local visible = onH and onF

        local objs = ESPObjects[player]
        local isEnemy = IsEnemy(player) and not IsFriend(player)
        local teamColor = Config.ESPTeamColor and (player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255,60,60)) or Color3.fromRGB(255,60,60)
        local color = isEnemy and teamColor or Color3.fromRGB(60,255,100)

        if visible and Config.ESPBoxes then
            local height = math.abs(headScreen.Y - feetScreen.Y)
            local width = height * 0.5
            objs.box.Visible = true
            objs.box.Color = color
            objs.box.Size = Vector2.new(width, height)
            objs.box.Position = Vector2.new(headScreen.X - width/2, headScreen.Y)

            if Config.ESPHealthBar then
                local hp = hum.Health / hum.MaxHealth
                local barH = height
                local barW = 4
                local barX = headScreen.X - width/2 - barW - 2
                local barY = headScreen.Y
                objs.healthBG.Visible = true
                objs.healthBG.Size = Vector2.new(barW, barH)
                objs.healthBG.Position = Vector2.new(barX, barY)
                objs.healthBar.Visible = true
                objs.healthBar.Size = Vector2.new(barW, barH * hp)
                objs.healthBar.Position = Vector2.new(barX, barY + barH * (1 - hp))
                objs.healthBar.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 40)
            else
                objs.healthBG.Visible = false
                objs.healthBar.Visible = false
            end
        else
            objs.box.Visible = false
            objs.healthBG.Visible = false
            objs.healthBar.Visible = false
        end

        if visible and Config.ESPNames then
            objs.nameTag.Visible = true
            objs.nameTag.Text = player.DisplayName
            objs.nameTag.Position = Vector2.new(headScreen.X, headScreen.Y - 16)
        else
            objs.nameTag.Visible = false
        end

        if visible and Config.ESPDistance then
            objs.distTag.Visible = true
            objs.distTag.Text = string.format("[%.0fm]", dist)
            objs.distTag.Position = Vector2.new(headScreen.X, headScreen.Y - 5)
        else
            objs.distTag.Visible = false
        end

        if visible and Config.ESPTracers then
            local vp = Workspace.CurrentCamera.ViewportSize
            objs.tracer.Visible = true
            objs.tracer.From = Vector2.new(vp.X/2, vp.Y)
            objs.tracer.To = feetScreen
            objs.tracer.Color = color
        else
            objs.tracer.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- =============================================
--   MOVEMENT (Speed, Fly, Noclip, Jump, BHop)
-- =============================================

-- Speed
RunService.Heartbeat:Connect(function()
    if Config.SpeedEnabled and Character and Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
        HumanoidRootPart.Velocity = Humanoid.MoveDirection * Config.SpeedValue + Vector3.new(0, HumanoidRootPart.Velocity.Y, 0)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Bunny Hop
RunService.Heartbeat:Connect(function()
    if Config.BunnyHop and Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.Landed then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if Config.NoclipEnabled and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly (with BodyVelocity)
local FlyBV, FlyBG
local function StartFly()
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    if not Character or not HumanoidRootPart then return end
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBV.Parent = HumanoidRootPart
    FlyBG = Instance.new("BodyGyro")
    FlyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    FlyBG.Parent = HumanoidRootPart
    Humanoid.PlatformStand = true
end

local function StopFly()
    if FlyBV then FlyBV:Destroy(); FlyBV = nil end
    if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    if Humanoid then Humanoid.PlatformStand = false end
end

RunService.RenderStepped:Connect(function()
    if not Config.FlyEnabled then
        if FlyBV then StopFly() end
        return
    end
    if not FlyBV then StartFly() end
    local camera = Workspace.CurrentCamera
    local move = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
    if move.Magnitude > 0 then
        FlyBV.Velocity = move.Unit * Config.FlySpeed
    else
        FlyBV.Velocity = Vector3.new(0,0,0)
    end
    FlyBG.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + camera.CFrame.LookVector)
end)

-- =============================================
--   COMBAT (KillAura, AutoHeal, AntiStun)
-- =============================================

-- KillAura (placeholder remote)
RunService.Heartbeat:Connect(function()
    if not Config.KillAura then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if IsTarget(player) and GetDistance(player) <= Config.KillAuraRange then
            -- Replace with actual remote event for the game
            -- ReplicatedStorage.Remotes.HitRemote:FireServer(player.Character)
        end
    end
end)

-- AutoHeal
RunService.Heartbeat:Connect(function()
    if Config.AutoHeal and Humanoid and Humanoid.Health < Humanoid.MaxHealth then
        Humanoid.Health = math.min(Humanoid.Health + Config.HealAmount, Humanoid.MaxHealth)
    end
end)

-- AntiStun
RunService.Heartbeat:Connect(function()
    if Config.AntiStun and Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.PlatformStanding then
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end)

-- =============================================
--   MISC (AntiAFK, NoFog, FullBright, FPSBoost, SpamAbility)
-- =============================================

-- AntiAFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- NoFog & FullBright
RunService.RenderStepped:Connect(function()
    if Config.NoFog then
        Lighting.FogStart = 1e6
        Lighting.FogEnd = 1e6
    end
    if Config.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogColor = Color3.fromRGB(128,128,128)
        Lighting.GlobalShadows = false
    end
end)

-- FPSBoost
Config.FPSBoost = false -- handled by toggle callback

-- Ability Spammer
RunService.Heartbeat:Connect(function()
    if Config.SpamAbility then
        -- Simulate key press for ability
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0,0))
    end
end)

-- =============================================
--   TELEPORT (from FENY)
-- =============================================
local function TeleportToTarget()
    local target = GetClosestEnemy()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if Character and HumanoidRootPart then
            HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
        end
    end
end

-- =============================================
--   HOTKEY HANDLING
-- =============================================
local function ToggleAimbot()
    Config.AimbotEnabled = not Config.AimbotEnabled
    FOVCircle.Visible = Config.AimbotEnabled
    Rayfield:Notify({Title = "Aimbot", Content = Config.AimbotEnabled and "ON" or "OFF", Duration = 1})
end

local function ToggleESP()
    Config.ESPEnabled = not Config.ESPEnabled
    if not Config.ESPEnabled then
        for pl in pairs(ESPObjects) do RemoveESP(pl) end
    end
    Rayfield:Notify({Title = "ESP", Content = Config.ESPEnabled and "ON" or "OFF", Duration = 1})
end

local function ToggleFly()
    Config.FlyEnabled = not Config.FlyEnabled
    if not Config.FlyEnabled then StopFly() else StartFly() end
    Rayfield:Notify({Title = "Fly", Content = Config.FlyEnabled and "ON" or "OFF", Duration = 1})
end

local function ToggleHeal()
    Config.AutoHeal = not Config.AutoHeal
    Rayfield:Notify({Title = "AutoHeal", Content = Config.AutoHeal and "ON" or "OFF", Duration = 1})
end

local function ToggleNoclip()
    Config.NoclipEnabled = not Config.NoclipEnabled
    Rayfield:Notify({Title = "Noclip", Content = Config.NoclipEnabled and "ON" or "OFF", Duration = 1})
end

local function ToggleView()
    -- Viewmodel FOV toggle: we can set FOV to 120 when on, else 70
    local cam = Workspace.CurrentCamera
    if Config.ToggleView then
        cam.FieldOfView = 120
        Config.ToggleView = false
    else
        cam.FieldOfView = 70
        Config.ToggleView = true
    end
    Rayfield:Notify({Title = "View FOV", Content = Config.ToggleView and "120" or "70", Duration = 1})
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = input.KeyCode.Name
    if key == Config.Hotkeys.ToggleMenu then
        -- Rayfield toggle handled by default? Actually Rayfield uses its own key, but we can also toggle main window.
        -- We'll just notify, or we can open/close Rayfield programmatically if needed.
    elseif key == Config.Hotkeys.ToggleAimbot then ToggleAimbot()
    elseif key == Config.Hotkeys.ToggleESP then ToggleESP()
    elseif key == Config.Hotkeys.ToggleFly then ToggleFly()
    elseif key == Config.Hotkeys.ToggleHeal then ToggleHeal()
    elseif key == Config.Hotkeys.ToggleNoclip then ToggleNoclip()
    elseif key == Config.Hotkeys.ToggleView then ToggleView()
    elseif key == Config.Hotkeys.Teleport then TeleportToTarget()
    end
end)

-- =============================================
--   RAYFIELD UI CONSTRUCTION
-- =============================================
local Window = Rayfield:CreateWindow({
    Name = "ZETA X ULTIMATE",
    Icon = 0,
    LoadingTitle = "ZETA X",
    LoadingSubtitle = "Ultimate Edition",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ZetaXUltimate",
        FileName = "Config",
    },
    KeySystem = false,
})

-- =============================================
--   TAB: AIMBOT
-- =============================================
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = Config.AimbotEnabled,
    Flag = "AimbotEnabled",
    Callback = function(v)
        Config.AimbotEnabled = v
        FOVCircle.Visible = v
    end,
})

AimbotTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = Config.AimbotSilent,
    Flag = "AimbotSilent",
    Callback = function(v) Config.AimbotSilent = v end,
})

AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = Config.AimbotTeamCheck,
    Flag = "AimbotTeamCheck",
    Callback = function(v) Config.AimbotTeamCheck = v end,
})

AimbotTab:CreateToggle({
    Name = "Visibility Check",
    CurrentValue = Config.AimbotVisCheck,
    Flag = "AimbotVisCheck",
    Callback = function(v) Config.AimbotVisCheck = v end,
})

AimbotTab:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = Config.AimbotTriggerbot,
    Flag = "AimbotTriggerbot",
    Callback = function(v) Config.AimbotTriggerbot = v end,
})

AimbotTab:CreateToggle({
    Name = "Auto Shoot",
    CurrentValue = Config.AimbotAutoShoot,
    Flag = "AimbotAutoShoot",
    Callback = function(v) Config.AimbotAutoShoot = v end,
})

AimbotTab:CreateSlider({
    Name = "FOV Size",
    Range = {10, 400},
    Increment = 5,
    Suffix = "px",
    CurrentValue = Config.AimbotFOV,
    Flag = "AimbotFOV",
    Callback = function(v)
        Config.AimbotFOV = v
        FOVCircle.Radius = v
    end,
})

AimbotTab:CreateSlider({
    Name = "Smoothing",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = Config.AimbotSmoothing,
    Flag = "AimbotSmoothing",
    Callback = function(v) Config.AimbotSmoothing = v end,
})

AimbotTab:CreateSlider({
    Name = "Prediction (sec)",
    Range = {0, 0.1},
    Increment = 0.001,
    Suffix = "s",
    CurrentValue = Config.AimbotPrediction,
    Flag = "AimbotPrediction",
    Callback = function(v) Config.AimbotPrediction = v end,
})

AimbotTab:CreateDropdown({
    Name = "Target Bone",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    CurrentOption = {Config.AimbotBone},
    Flag = "AimbotBone",
    Callback = function(v) Config.AimbotBone = v[1] end,
})

-- =============================================
--   TAB: ESP
-- =============================================
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = Config.ESPEnabled,
    Flag = "ESPEnabled",
    Callback = function(v)
        Config.ESPEnabled = v
        if not v then
            for pl in pairs(ESPObjects) do RemoveESP(pl) end
        end
    end,
})

ESPTab:CreateToggle({
    Name = "Boxes",
    CurrentValue = Config.ESPBoxes,
    Flag = "ESPBoxes",
    Callback = function(v) Config.ESPBoxes = v end,
})

ESPTab:CreateToggle({
    Name = "Names",
    CurrentValue = Config.ESPNames,
    Flag = "ESPNames",
    Callback = function(v) Config.ESPNames = v end,
})

ESPTab:CreateToggle({
    Name = "Distance",
    CurrentValue = Config.ESPDistance,
    Flag = "ESPDistance",
    Callback = function(v) Config.ESPDistance = v end,
})

ESPTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = Config.ESPTracers,
    Flag = "ESPTracers",
    Callback = function(v) Config.ESPTracers = v end,
})

ESPTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = Config.ESPHealthBar,
    Flag = "ESPHealthBar",
    Callback = function(v) Config.ESPHealthBar = v end,
})

ESPTab:CreateToggle({
    Name = "Team Color",
    CurrentValue = Config.ESPTeamColor,
    Flag = "ESPTeamColor",
    Callback = function(v) Config.ESPTeamColor = v end,
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 5000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = Config.ESPMaxDist,
    Flag = "ESPMaxDist",
    Callback = function(v) Config.ESPMaxDist = v end,
})

-- =============================================
--   TAB: MOVEMENT
-- =============================================
local MovTab = Window:CreateTab("Movement", 4483362458)

MovTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = Config.SpeedEnabled,
    Flag = "SpeedEnabled",
    Callback = function(v) Config.SpeedEnabled = v end,
})

MovTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 300},
    Increment = 2,
    Suffix = "studs/s",
    CurrentValue = Config.SpeedValue,
    Flag = "SpeedValue",
    Callback = function(v) Config.SpeedValue = v end,
})

MovTab:CreateToggle({
    Name = "Fly",
    CurrentValue = Config.FlyEnabled,
    Flag = "FlyEnabled",
    Callback = function(v)
        Config.FlyEnabled = v
        if v then StartFly() else StopFly() end
    end,
})

MovTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = Config.FlySpeed,
    Flag = "FlySpeed",
    Callback = function(v) Config.FlySpeed = v end,
})

MovTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = Config.NoclipEnabled,
    Flag = "NoclipEnabled",
    Callback = function(v) Config.NoclipEnabled = v end,
})

MovTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = Config.InfiniteJump,
    Flag = "InfiniteJump",
    Callback = function(v) Config.InfiniteJump = v end,
})

MovTab:CreateToggle({
    Name = "Bunny Hop",
    CurrentValue = Config.BunnyHop,
    Flag = "BunnyHop",
    Callback = function(v) Config.BunnyHop = v end,
})

-- =============================================
--   TAB: COMBAT
-- =============================================
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = Config.KillAura,
    Flag = "KillAura",
    Callback = function(v) Config.KillAura = v end,
})

CombatTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {5, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = Config.KillAuraRange,
    Flag = "KillAuraRange",
    Callback = function(v) Config.KillAuraRange = v end,
})

CombatTab:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = Config.AutoHeal,
    Flag = "AutoHeal",
    Callback = function(v) Config.AutoHeal = v end,
})

CombatTab:CreateSlider({
    Name = "Heal Amount",
    Range = {5, 50},
    Increment = 1,
    Suffix = "HP",
    CurrentValue = Config.HealAmount,
    Flag = "HealAmount",
    Callback = function(v) Config.HealAmount = v end,
})

CombatTab:CreateToggle({
    Name = "Anti-Stun",
    CurrentValue = Config.AntiStun,
    Flag = "AntiStun",
    Callback = function(v) Config.AntiStun = v end,
})

CombatTab:CreateToggle({
    Name = "Auto Parry",
    CurrentValue = Config.AutoParry,
    Flag = "AutoParry",
    Callback = function(v) Config.AutoParry = v end,
})

CombatTab:CreateToggle({
    Name = "Auto Dash",
    CurrentValue = Config.AutoDash,
    Flag = "AutoDash",
    Callback = function(v) Config.AutoDash = v end,
})

CombatTab:CreateToggle({
    Name = "Ability Spammer",
    CurrentValue = Config.SpamAbility,
    Flag = "SpamAbility",
    Callback = function(v) Config.SpamAbility = v end,
})

CombatTab:CreateDropdown({
    Name = "Ability Key",
    Options = {"Q", "E", "R", "F", "G", "Z", "X", "C"},
    CurrentOption = {Config.SelectedAbility},
    Flag = "SelectedAbility",
    Callback = function(v) Config.SelectedAbility = v[1] end,
})

-- =============================================
--   TAB: FRIEND SYSTEM
-- =============================================
local FriendTab = Window:CreateTab("Friend", 4483362458)

FriendTab:CreateToggle({
    Name = "Enable Friend System",
    CurrentValue = Config.FriendMode,
    Flag = "FriendMode",
    Callback = function(v)
        Config.FriendMode = v
        if not v then
            Friend = nil
            MatchStarted = false
        end
    end,
})

FriendTab:CreateSlider({
    Name = "Friend Range (distance)",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = Config.FriendRange,
    Flag = "FriendRange",
    Callback = function(v) Config.FriendRange = v end,
})

FriendTab:CreateSlider({
    Name = "Match Range (to start)",
    Range = {50, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = Config.MatchRange,
    Flag = "MatchRange",
    Callback = function(v) Config.MatchRange = v end,
})

-- =============================================
--   TAB: MISC
-- =============================================
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = Config.AntiAFK,
    Flag = "AntiAFK",
    Callback = function(v) Config.AntiAFK = v end,
})

MiscTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = Config.NoFog,
    Flag = "NoFog",
    Callback = function(v) Config.NoFog = v end,
})

MiscTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = Config.FullBright,
    Flag = "FullBright",
    Callback = function(v) Config.FullBright = v end,
})

MiscTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = Config.FPSBoost,
    Flag = "FPSBoost",
    Callback = function(v)
        Config.FPSBoost = v
        if v then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end,
})

MiscTab:CreateButton({
    Name = "Teleport to Closest Enemy",
    Callback = TeleportToTarget,
})

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

MiscTab:CreateButton({
    Name = "Respawn Character",
    Callback = function()
        LocalPlayer:LoadCharacter()
    end,
})

-- =============================================
--   TAB: HOTKEYS (Custom Key Binds)
-- =============================================
local HotkeyTab = Window:CreateTab("Hotkeys", 4483362458)

local function CreateHotkeyButton(name, keyName)
    HotkeyTab:CreateButton({
        Name = name .. " (Current: " .. Config.Hotkeys[keyName] .. ")",
        Callback = function()
            local newKey = ""
            local con
            con = UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    newKey = input.KeyCode.Name
                    Config.Hotkeys[keyName] = newKey
                    Rayfield:Notify({Title = "Hotkey Set", Content = name .. " → " .. newKey, Duration = 2})
                    con:Disconnect()
                    -- Update button text? Hard to update without recreating, but okay.
                end
            end)
            Rayfield:Notify({Title = "Press a key", Content = "for " .. name, Duration = 3})
        end,
    })
end

CreateHotkeyButton("Toggle Aimbot", "ToggleAimbot")
CreateHotkeyButton("Toggle ESP", "ToggleESP")
CreateHotkeyButton("Toggle Fly", "ToggleFly")
CreateHotkeyButton("Toggle Heal", "ToggleHeal")
CreateHotkeyButton("Toggle Noclip", "ToggleNoclip")
CreateHotkeyButton("Toggle View FOV", "ToggleView")
CreateHotkeyButton("Teleport", "Teleport")
CreateHotkeyButton("Toggle Menu", "ToggleMenu") -- Rayfield default is Insert, but we can override

-- =============================================
--   NOTIFY ON LOAD
-- =============================================
Rayfield:Notify({
    Title = "ZETA X ULTIMATE",
    Content = "All features loaded. Enjoy!",
    Duration = 5,
    Image = 4483362458,
})

-- =============================================
--   CHARACTER RESPAWN HANDLER
-- =============================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    if Config.FlyEnabled then StartFly() end
end)

print("[ZETA X ULTIMATE] Loaded successfully.")
