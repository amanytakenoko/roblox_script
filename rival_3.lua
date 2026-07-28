-- ============================================================
--   ZETA X – FINAL COMPLETE (完全最終版)
--   Rivals専用 完全安定版チート
--   メニューキー: K | 起動時自動表示
--   continue完全排除 | AutoHeal削除 | 全機能安定動作
-- ============================================================

-- ★★★ ゲームロード待機 ★★★
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ★★★ サービス定義 ★★★
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

-- // ローカルプレイヤー
local LP = Players.LocalPlayer

-- ★★★ 全体をpcallで保護 ★★★
local function Main()

-- ============================================================
--   RAYFIELD UI
-- ============================================================
local Rayfield = nil
local RayfieldLoaded = false

task.spawn(function()
    for i = 1, 5 do
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
        end)
        if success and result then
            Rayfield = result
            RayfieldLoaded = true
            break
        end
        task.wait(2)
    end
end)

local function Notify(title, content)
    if Rayfield and RayfieldLoaded then
        pcall(function() Rayfield:Notify({Title = title, Content = content, Duration = 3}) end)
    else
        print("[ZETA X] " .. title .. ": " .. content)
    end
end

-- ============================================================
--   テーマ
-- ============================================================
local Theme = {
    Accent = Color3.fromRGB(100, 60, 200),
    ESPEnemy = Color3.fromRGB(220, 50, 50),
    ESPAlly = Color3.fromRGB(50, 220, 80),
    HealthHigh = Color3.fromRGB(60, 220, 100),
    HealthMid = Color3.fromRGB(255, 200, 40),
    HealthLow = Color3.fromRGB(255, 60, 60),
}

-- ============================================================
--   設定
-- ============================================================
local Config = {
    AimbotEnabled = false,
    AimbotMode = "Sticky",
    AimbotFOV = 120,
    AimbotSmoothing = 0.35,
    AimbotStickyStrength = 0.85,
    AimbotBone = "Head",
    AimbotTeamCheck = true,
    AimbotVisCheck = false,
    AimbotTriggerbot = false,
    AimbotAutoShoot = false,
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPHealthBar = true,
    ESPMaxDist = 1000,
    SpeedEnabled = false,
    SpeedValue = 32,
    FlyEnabled = false,
    FlySpeed = 80,
    NoclipEnabled = false,
    InfiniteJump = false,
    BunnyHop = false,
    KillAura = false,
    KillAuraRange = 15,
    AntiAFK = true,
    NoFog = false,
    FullBright = false,
}

-- ============================================================
--   セーフコール
-- ============================================================
local function Safe(func, ...)
    local ok, err = pcall(func, ...)
    if not ok then print("[ZETA X] Error:", err) end
    return ok, err
end

-- ============================================================
--   ユーティリティ
-- ============================================================
local function GetCamera()
    return Workspace.CurrentCamera
end

local function GetRootPart(pl)
    if not pl then return nil end
    local ch = pl.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function GetBone(pl, bone)
    if not pl then return nil end
    local ch = pl.Character
    if not ch then return nil end
    return ch:FindFirstChild(bone) or ch:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(pl)
    if not pl then return nil end
    local ch = pl.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(pl)
    local h = GetHumanoid(pl)
    return h and h.Health > 0
end

local function IsEnemy(pl)
    if pl == LP then return false end
    if Config.AimbotTeamCheck and LP.Team and pl.Team then
        return LP.Team ~= pl.Team
    end
    return pl ~= LP
end

local function WorldToViewport(pos)
    local cam = GetCamera()
    if not cam then return Vector2.new(0,0), false
    local sp, on = cam:WorldToViewportPoint(pos)
    if sp.Z <= 0 then return Vector2.new(sp.X, sp.Y), false
    return Vector2.new(sp.X, sp.Y), on
end

local function GetDistance(pl)
    if not HumanoidRootPart then return math.huge end
    local r = GetRootPart(pl)
    if r then
        return (r.Position - HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function IsVisible(pl)
    local cam = GetCamera()
    if not cam then return false end
    local bone = GetBone(pl, Config.AimbotBone)
    if not bone then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local ignore = {}
    if Character then
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then table.insert(ignore, v) end
        end
    end
    if pl.Character then
        for _, v in ipairs(pl.Character:GetDescendants()) do
            if v:IsA("BasePart") then table.insert(ignore, v) end
        end
    end
    params.FilterDescendantsInstances = ignore
    local result = Workspace:Raycast(cam.CFrame.Position, (bone.Position - cam.CFrame.Position).Unit * 1000, params)
    return result == nil
end

local function IsTarget(pl)
    if pl == LP then return false end
    if not IsAlive(pl) then return false end
    if not IsEnemy(pl) then return false end
    return true
end

-- ★★★ SafeMouseClick (mouse1click フォールバック追加) ★★★
local function SafeMouseClick()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0, 0))
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end)
    elseif rawget(_G, "mouse1click") and type(mouse1click) == "function" then
        pcall(function() mouse1click() end)
    end
end

-- ============================================================
--   ESP (continue完全排除・距離連動ボックスサイズ)
-- ============================================================
local ESPObjects = {}
local ESPUpdateCounter = 0

local function RemoveESP(pl)
    if ESPObjects[pl] then
        for _, obj in pairs(ESPObjects[pl]) do
            Safe(function() obj:Remove() end)
        end
        ESPObjects[pl] = nil
    end
end

local function CreateESP(pl)
    RemoveESP(pl)
    local objs = {}
    Safe(function()
        local box = Drawing.new("Square")
        if box then box.Visible = false; box.Thickness = 1.5; box.Filled = false; objs.box = box end

        local nameTag = Drawing.new("Text")
        if nameTag then
            nameTag.Visible = false; nameTag.Size = 12; nameTag.Center = true
            nameTag.Outline = true; nameTag.Font = Drawing.Fonts.UI
            nameTag.Color = Color3.fromRGB(255,255,255)
            objs.nameTag = nameTag
        end

        local distTag = Drawing.new("Text")
        if distTag then
            distTag.Visible = false; distTag.Size = 10; distTag.Center = true
            distTag.Outline = true; distTag.Font = Drawing.Fonts.UI
            distTag.Color = Color3.fromRGB(200,200,200)
            objs.distTag = distTag
        end

        local healthBG = Drawing.new("Square")
        if healthBG then healthBG.Visible = false; healthBG.Color = Color3.fromRGB(20,20,40); healthBG.Filled = true; objs.healthBG = healthBG end

        local healthBar = Drawing.new("Square")
        if healthBar then healthBar.Visible = false; healthBar.Filled = true; objs.healthBar = healthBar end
    end)
    ESPObjects[pl] = objs
end

RunService.Heartbeat:Connect(function()
    ESPUpdateCounter = ESPUpdateCounter + 1
    if ESPUpdateCounter % 5 ~= 0 then return end

    if not Config.ESPEnabled then
        for pl in pairs(ESPObjects) do Safe(RemoveESP, pl) end
        return
    end

    local cam = GetCamera()
    if not cam or not Character then return end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            if not ESPObjects[pl] then Safe(CreateESP, pl) end
            local objs = ESPObjects[pl]

            if objs then
                local dist = GetDistance(pl)

                if dist <= Config.ESPMaxDist then
                    local ch = pl.Character
                    local root = GetRootPart(pl)
                    local hum = GetHumanoid(pl)

                    if ch and root and hum then
                        local head = ch:FindFirstChild("Head")
                        local headPos = head and head.Position or root.Position + Vector3.new(0, 2, 0)
                        local headScr, onH = WorldToViewport(headPos)

                        if onH then
                            local isEnemy = IsEnemy(pl)
                            local color = isEnemy and Theme.ESPEnemy or Theme.ESPAlly

                            if Config.ESPBoxes then
                                -- ★★★ 距離に応じてボックスサイズを可変 ★★★
                                local baseSize = 40
                                local scale = math.clamp(40 / (dist + 20), 0.3, 1.5)
                                local height = baseSize * scale
                                local width = height * 0.5

                                if objs.box then
                                    Safe(function()
                                        objs.box.Visible = true
                                        objs.box.Color = color
                                        objs.box.Size = Vector2.new(width, height)
                                        objs.box.Position = Vector2.new(headScr.X - width/2, headScr.Y - height/2)
                                    end)
                                end

                                if Config.ESPHealthBar then
                                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                    local barH = height
                                    local barW = 3
                                    local barX = headScr.X + width/2 + 2
                                    local barY = headScr.Y - height/2
                                    local hpColor = hp > 0.6 and Theme.HealthHigh or (hp > 0.3 and Theme.HealthMid or Theme.HealthLow)
                                    if objs.healthBG and objs.healthBar then
                                        Safe(function()
                                            objs.healthBG.Visible = true
                                            objs.healthBG.Size = Vector2.new(barW, barH)
                                            objs.healthBG.Position = Vector2.new(barX, barY)
                                            objs.healthBar.Visible = true
                                            objs.healthBar.Size = Vector2.new(barW, barH * hp)
                                            objs.healthBar.Position = Vector2.new(barX, barY + barH * (1 - hp))
                                            objs.healthBar.Color = hpColor
                                        end)
                                    end
                                else
                                    if objs.healthBG then Safe(function() objs.healthBG.Visible = false end) end
                                    if objs.healthBar then Safe(function() objs.healthBar.Visible = false end) end
                                end
                            else
                                if objs.box then Safe(function() objs.box.Visible = false end) end
                                if objs.healthBG then Safe(function() objs.healthBG.Visible = false end) end
                                if objs.healthBar then Safe(function() objs.healthBar.Visible = false end) end
                            end

                            if Config.ESPNames and objs.nameTag then
                                Safe(function()
                                    objs.nameTag.Visible = true
                                    objs.nameTag.Text = pl.DisplayName
                                    objs.nameTag.Position = Vector2.new(headScr.X, headScr.Y - height/2 - 14)
                                end)
                            else
                                if objs.nameTag then Safe(function() objs.nameTag.Visible = false end) end
                            end

                            if Config.ESPDistance and objs.distTag then
                                Safe(function()
                                    objs.distTag.Visible = true
                                    objs.distTag.Text = string.format("[%.0fm]", dist)
                                    objs.distTag.Position = Vector2.new(headScr.X, headScr.Y + height/2 + 12)
                                end)
                            else
                                if objs.distTag then Safe(function() objs.distTag.Visible = false end) end
                            end
                        else
                            for _, obj in pairs(objs) do
                                Safe(function() if obj then obj.Visible = false end end)
                            end
                        end
                    else
                        Safe(RemoveESP, pl)
                    end
                else
                    for _, obj in pairs(objs) do
                        Safe(function() if obj then obj.Visible = false end end)
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ============================================================
--   Noclip
-- ============================================================
local NoclipCachedParts = {}

local function ApplyNoclipToPart(part)
    if part:IsA("BasePart") and part.CanCollide then
        if not NoclipCachedParts[part] then
            NoclipCachedParts[part] = true
            Safe(function() part.CanCollide = false end)
        end
    end
end

-- ============================================================
--   Fly
-- ============================================================
local FlyBV, FlyBG, FlyActive = nil, nil, false

function StartFly()
    Safe(StopFly)
    if not Character or not HumanoidRootPart then return false end
    local hum = Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    FlyBV = Instance.new("BodyVelocity")
    FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBV.Velocity = Vector3.new(0, 0, 0)
    FlyBV.Parent = HumanoidRootPart

    FlyBG = Instance.new("BodyGyro")
    FlyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    FlyBG.CFrame = HumanoidRootPart.CFrame
    FlyBG.Parent = HumanoidRootPart

    hum.PlatformStand = true
    FlyActive = true
    return true
end

function StopFly()
    if FlyBV then FlyBV:Destroy(); FlyBV = nil end
    if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    if Character and Humanoid then Humanoid.PlatformStand = false end
    FlyActive = false
end

-- ============================================================
--   キャラクター管理
-- ============================================================
local Character, HumanoidRootPart, Humanoid = nil, nil, nil

local function RefreshCharacter()
    Character = LP.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
    end
    return Character ~= nil
end

RefreshCharacter()

LP.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:FindFirstChild("HumanoidRootPart")
    Humanoid = newChar:FindFirstChildOfClass("Humanoid")
    CachedTarget = nil
    CachedTargetTime = 0
    for pl in pairs(ESPObjects) do Safe(RemoveESP, pl) end
    if Config.FlyEnabled and HumanoidRootPart then Safe(StartFly) end
end)

LP.CharacterRemoving:Connect(function()
    Character = nil
    HumanoidRootPart = nil
    Humanoid = nil
    Safe(StopFly)
    NoclipCachedParts = {}
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not Character or not HumanoidRootPart then
            RefreshCharacter()
            if Config.FlyEnabled and HumanoidRootPart then Safe(StartFly) end
        end
        if Character and Humanoid and not Config.FlyEnabled then
            if Humanoid.PlatformStand then
                Safe(function() Humanoid.PlatformStand = false end)
            end
        end
    end
end)

-- ============================================================
--   AIMBOT (continue完全排除)
-- ============================================================
local CachedTarget, CachedTargetTime = nil, 0
local CACHE_DURATION = 0.05
local LastTriggerTime, LastAutoShootTime, KillAuraLastTime = 0, 0, 0

local function GetClosestTarget()
    if not Character or not HumanoidRootPart then
        CachedTarget = nil
        return nil
    end

    local cam = GetCamera()
    if not cam then return nil end

    local now = tick()
    if CachedTarget and (now - CachedTargetTime) < CACHE_DURATION then
        if CachedTarget and IsTarget(CachedTarget) then
            return CachedTarget
        else
            CachedTarget = nil
        end
    end

    local mousePos = UserInputService:GetMouseLocation()
    if not mousePos then return nil end
    local minDist = Config.AimbotFOV
    local target = nil
    local viewportSize = cam.ViewportSize

    for _, pl in ipairs(Players:GetPlayers()) do
        if IsTarget(pl) then
            local bone = GetBone(pl, Config.AimbotBone)
            if bone then
                local visOk = true
                if Config.AimbotVisCheck then
                    visOk = IsVisible(pl)
                end
                if visOk then
                    local sp, on = WorldToViewport(bone.Position)
                    if on and sp.X >= 0 and sp.X <= viewportSize.X and sp.Y >= 0 and sp.Y <= viewportSize.Y then
                        local dist = (sp - mousePos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target = pl
                        end
                    end
                end
            end
        end
    end

    CachedTarget = target
    CachedTargetTime = now
    return target
end

-- ============================================================
--   FOV Circle
-- ============================================================
local FOVCircle = nil
Safe(function()
    FOVCircle = Drawing.new("Circle")
    if FOVCircle then
        FOVCircle.Visible = false
        FOVCircle.Radius = Config.AimbotFOV
        FOVCircle.Color = Theme.Accent
        FOVCircle.Thickness = 1.5
        FOVCircle.Transparency = 0.6
        FOVCircle.Filled = false
        FOVCircle.ZIndex = 999
    end
end)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        if Config.AimbotEnabled then
            local mouse = UserInputService:GetMouseLocation()
            if mouse then
                FOVCircle.Position = mouse
                FOVCircle.Radius = Config.AimbotFOV
                FOVCircle.Visible = true
            end
        else
            FOVCircle.Visible = false
        end
    end
end)

-- ============================================================
--   AIMBOT メインループ
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not Config.AimbotEnabled then return end
    if not Character or not HumanoidRootPart then return end

    local cam = GetCamera()
    if not cam then return end

    local target = GetClosestTarget()
    if not target then return end

    local bone = GetBone(target, Config.AimbotBone)
    if not bone then return end

    local targetPos = bone.Position
    if not targetPos then return end

    if Config.AimbotMode == "Sticky" then
        local currentCF = cam.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        local strength = math.clamp(Config.AimbotStickyStrength, 0.3, 1.0)
        cam.CFrame = currentCF:Lerp(targetCF, strength)
    else
        local sp, on = WorldToViewport(targetPos)
        if not on then return end

        local mousePos = UserInputService:GetMouseLocation()
        if not mousePos then return end

        local delta = sp - mousePos
        local dist = delta.Magnitude
        if dist < 0.5 then return end

        local smoothFactor = math.clamp(Config.AimbotSmoothing, 0.01, 0.9)
        local moveX = delta.X * smoothFactor
        local moveY = delta.Y * smoothFactor

        if math.abs(moveX) > 0.1 or math.abs(moveY) > 0.1 then
            Safe(function() mousemoverel(moveX, moveY) end)
        end
    end

    if Config.AimbotTriggerbot then
        local now = tick()
        if now - LastTriggerTime > 0.15 then
            SafeMouseClick()
            LastTriggerTime = now
        end
    end

    if Config.AimbotAutoShoot then
        local now = tick()
        if now - LastAutoShootTime > 0.08 then
            SafeMouseClick()
            LastAutoShootTime = now
        end
    end
end)

-- ============================================================
--   MOVEMENT
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    if not Humanoid or not HumanoidRootPart then return end
    if Humanoid.MoveDirection.Magnitude > 0 then
        Safe(function()
            HumanoidRootPart.Velocity = Humanoid.MoveDirection * Config.SpeedValue + Vector3.new(0, HumanoidRootPart.Velocity.Y, 0)
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Humanoid then
        Safe(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.BunnyHop and Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.Landed then
        Safe(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

-- ============================================================
--   FLY 更新ループ
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not Config.FlyEnabled then
        if FlyActive then Safe(StopFly) end
        return
    end

    if not Character or not HumanoidRootPart then
        RefreshCharacter()
        if not Character or not HumanoidRootPart then return end
    end

    if (not FlyBV or not FlyBV.Parent) and HumanoidRootPart then
        Safe(StartFly)
        if not FlyBV or not FlyBV.Parent then return end
    end

    if not HumanoidRootPart or not FlyBV or not FlyBG then return end

    local cam = GetCamera()
    if not cam then return end

    local move = Vector3.new()
    local cf = cam.CFrame
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector * Vector3.new(1,0,1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector * Vector3.new(1,0,1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

    Safe(function()
        if move.Magnitude > 0 then
            FlyBV.Velocity = move.Unit * Config.FlySpeed
        else
            FlyBV.Velocity = Vector3.new(0, 0, 0)
        end
        FlyBG.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + cf.LookVector)
    end)
end)

-- ============================================================
--   Noclip 適用
-- ============================================================
task.spawn(function()
    while true do
        task.wait(2)
        if Config.NoclipEnabled and Character then
            for _, part in ipairs(Character:GetDescendants()) do
                ApplyNoclipToPart(part)
            end
        end
    end
end)

-- ============================================================
--   COMBAT (KillAuraのみ)
-- ============================================================
local function GetHitRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remotes then
        for _, name in ipairs({"Hit", "Damage", "Attack", "DealDamage"}) do
            local r = remotes:FindFirstChild(name)
            if r then return r end
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not Config.KillAura then return end
    local hitRemote = GetHitRemote()
    if not hitRemote then return end
    local now = tick()
    if now - KillAuraLastTime < 0.2 then return end

    for _, pl in ipairs(Players:GetPlayers()) do
        if IsTarget(pl) and GetDistance(pl) <= Config.KillAuraRange then
            Safe(function() hitRemote:FireServer(pl.Character or pl) end)
        end
    end
    KillAuraLastTime = now
end)

-- ============================================================
--   TELEPORT
-- ============================================================
local function TeleportToTarget()
    if not HumanoidRootPart then return end
    local target, minDist = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if IsTarget(pl) then
            local d = GetDistance(pl)
            if d < minDist then
                minDist = d
                target = pl
            end
        end
    end
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        Safe(function()
            HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
        end)
    end
end

-- ============================================================
--   ★★★ MISC (NoFog / FullBright リセット対応) ★★★
-- ============================================================
RunService.RenderStepped:Connect(function()
    if Config.NoFog then
        Safe(function()
            Lighting.FogStart = 1e6
            Lighting.FogEnd = 1e6
        end)
    else
        Safe(function()
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        end)
    end

    if Config.FullBright then
        Safe(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        end)
    else
        Safe(function()
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = true
        end)
    end
end)

LP.Idled:Connect(function()
    if Config.AntiAFK then
        Safe(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    end
end)

-- ============================================================
--   RAYFIELD UI
-- ============================================================
local Window, WindowCreated = nil, false

local function CreateUI()
    if not RayfieldLoaded or not Rayfield then return false end
    if WindowCreated then return true end

    local success, err = pcall(function()
        Window = Rayfield:CreateWindow({
            Name = "ZETA X",
            Icon = 0,
            LoadingTitle = "ZETA X",
            LoadingSubtitle = "Final Complete",
            Theme = "Default",
            ConfigurationSaving = { Enabled = false },
            KeySystem = false,
        })
    end)

    if not success or not Window then return false end

    WindowCreated = true
    Window.Visible = true

    -- Aimbot
    local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
    AimbotTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = Config.AimbotEnabled, Flag = "AimbotEnabled", Callback = function(v) Config.AimbotEnabled = v; if FOVCircle then FOVCircle.Visible = v end end})
    AimbotTab:CreateToggle({Name = "Team Check", CurrentValue = Config.AimbotTeamCheck, Flag = "AimbotTeamCheck", Callback = function(v) Config.AimbotTeamCheck = v end})
    AimbotTab:CreateToggle({Name = "Vis Check", CurrentValue = Config.AimbotVisCheck, Flag = "AimbotVisCheck", Callback = function(v) Config.AimbotVisCheck = v end})
    AimbotTab:CreateToggle({Name = "Triggerbot", CurrentValue = Config.AimbotTriggerbot, Flag = "AimbotTriggerbot", Callback = function(v) Config.AimbotTriggerbot = v end})
    AimbotTab:CreateToggle({Name = "Auto-Shoot", CurrentValue = Config.AimbotAutoShoot, Flag = "AimbotAutoShoot", Callback = function(v) Config.AimbotAutoShoot = v end})
    AimbotTab:CreateDropdown({Name = "Mode", Options = {"Sticky", "Normal"}, CurrentOption = {Config.AimbotMode}, Flag = "AimbotMode", Callback = function(v) Config.AimbotMode = v[1] end})
    AimbotTab:CreateSlider({Name = "FOV", Range = {10, 400}, Increment = 5, Suffix = "px", CurrentValue = Config.AimbotFOV, Flag = "AimbotFOV", Callback = function(v) Config.AimbotFOV = v; if FOVCircle then FOVCircle.Radius = v end end})
    AimbotTab:CreateSlider({Name = "Smoothing", Range = {0.05, 0.9}, Increment = 0.05, Suffix = "", CurrentValue = Config.AimbotSmoothing, Flag = "AimbotSmoothing", Callback = function(v) Config.AimbotSmoothing = v end})
    AimbotTab:CreateSlider({Name = "Sticky Strength", Range = {0.5, 1.0}, Increment = 0.05, Suffix = "", CurrentValue = Config.AimbotStickyStrength, Flag = "AimbotStickyStrength", Callback = function(v) Config.AimbotStickyStrength = v end})
    AimbotTab:CreateDropdown({Name = "Bone", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {Config.AimbotBone}, Flag = "AimbotBone", Callback = function(v) Config.AimbotBone = v[1] end})

    -- ESP
    local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
    ESPTab:CreateToggle({Name = "Enable ESP", CurrentValue = Config.ESPEnabled, Flag = "ESPEnabled", Callback = function(v) Config.ESPEnabled = v; if not v then for pl in pairs(ESPObjects) do Safe(RemoveESP, pl) end end end})
    ESPTab:CreateToggle({Name = "Boxes", CurrentValue = Config.ESPBoxes, Flag = "ESPBoxes", Callback = function(v) Config.ESPBoxes = v end})
    ESPTab:CreateToggle({Name = "Names", CurrentValue = Config.ESPNames, Flag = "ESPNames", Callback = function(v) Config.ESPNames = v end})
    ESPTab:CreateToggle({Name = "Distance", CurrentValue = Config.ESPDistance, Flag = "ESPDistance", Callback = function(v) Config.ESPDistance = v end})
    ESPTab:CreateToggle({Name = "Health Bar", CurrentValue = Config.ESPHealthBar, Flag = "ESPHealthBar", Callback = function(v) Config.ESPHealthBar = v end})
    ESPTab:CreateSlider({Name = "Max Distance", Range = {100, 5000}, Increment = 50, Suffix = "studs", CurrentValue = Config.ESPMaxDist, Flag = "ESPMaxDist", Callback = function(v) Config.ESPMaxDist = v end})

    -- Movement
    local MovTab = Window:CreateTab("🏃 Movement", 4483362458)
    MovTab:CreateToggle({Name = "Speed", CurrentValue = Config.SpeedEnabled, Flag = "SpeedEnabled", Callback = function(v) Config.SpeedEnabled = v end})
    MovTab:CreateSlider({Name = "Speed Value", Range = {16, 300}, Increment = 2, Suffix = "studs/s", CurrentValue = Config.SpeedValue, Flag = "SpeedValue", Callback = function(v) Config.SpeedValue = v end})
    MovTab:CreateToggle({Name = "Fly", CurrentValue = Config.FlyEnabled, Flag = "FlyEnabled", Callback = function(v) Config.FlyEnabled = v; if v then Safe(StartFly) else Safe(StopFly) end end})
    MovTab:CreateSlider({Name = "Fly Speed", Range = {10, 500}, Increment = 5, Suffix = "studs/s", CurrentValue = Config.FlySpeed, Flag = "FlySpeed", Callback = function(v) Config.FlySpeed = v end})
    MovTab:CreateToggle({Name = "Noclip", CurrentValue = Config.NoclipEnabled, Flag = "NoclipEnabled", Callback = function(v) Config.NoclipEnabled = v end})
    MovTab:CreateToggle({Name = "Infinite Jump", CurrentValue = Config.InfiniteJump, Flag = "InfiniteJump", Callback = function(v) Config.InfiniteJump = v end})
    MovTab:CreateToggle({Name = "Bunny Hop", CurrentValue = Config.BunnyHop, Flag = "BunnyHop", Callback = function(v) Config.BunnyHop = v end})

    -- Combat (AutoHeal削除)
    local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
    CombatTab:CreateToggle({Name = "Kill Aura", CurrentValue = Config.KillAura, Flag = "KillAura", Callback = function(v) Config.KillAura = v end})
    CombatTab:CreateSlider({Name = "Range", Range = {5, 100}, Increment = 1, Suffix = "studs", CurrentValue = Config.KillAuraRange, Flag = "KillAuraRange", Callback = function(v) Config.KillAuraRange = v end})

    -- Misc
    local MiscTab = Window:CreateTab("🔧 Misc", 4483362458)
    MiscTab:CreateToggle({Name = "Anti-AFK", CurrentValue = Config.AntiAFK, Flag = "AntiAFK", Callback = function(v) Config.AntiAFK = v end})
    MiscTab:CreateToggle({Name = "No Fog", CurrentValue = Config.NoFog, Flag = "NoFog", Callback = function(v) Config.NoFog = v end})
    MiscTab:CreateToggle({Name = "Full Bright", CurrentValue = Config.FullBright, Flag = "FullBright", Callback = function(v) Config.FullBright = v end})
    MiscTab:CreateButton({Name = "Teleport to Enemy", Callback = TeleportToTarget})
    MiscTab:CreateButton({Name = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, LP) end})
    MiscTab:CreateButton({Name = "Respawn", Callback = function() LP:LoadCharacter() end})

    Notify("ZETA X", "Final Complete loaded", 3)
    return true
end

task.spawn(function()
    while true do
        if RayfieldLoaded then
            if CreateUI() then break end
        end
        task.wait(1)
    end
end)

-- ============================================================
--   メニュー表示切替 (Kキー)
-- ============================================================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        if Window then
            Window.Visible = not Window.Visible
        end
    end
end)

print("[ZETA X] Final Complete loaded. Menu: K key.")

while true do task.wait(10) end

end

-- ★★★ 実行 ★★★
pcall(Main)
