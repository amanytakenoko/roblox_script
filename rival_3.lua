-- ============================================================
--   ZETA X – ULTIMATE EDITION
--   Theme: Blue Purple
--   Sticky Aimbot + Enhanced Hotkeys + Profile Switcher
--   Rivals専用 完全安定版
-- ============================================================

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- // Local Player
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
--   テーマカラー (Blue Purple)
-- ============================================================
local Theme = {
    Background    = Color3.fromRGB(10, 10, 30),      -- 濃い青黒
    Accent        = Color3.fromRGB(100, 60, 200),    -- パープル
    Accent2       = Color3.fromRGB(60, 120, 255),    -- ブライトブルー
    Text          = Color3.fromRGB(200, 180, 255),   -- ライトパープル
    TextBright    = Color3.fromRGB(255, 255, 255),   -- 白
    SubText       = Color3.fromRGB(150, 140, 200),   -- グレイッシュパープル
    FOVColor      = Color3.fromRGB(100, 60, 200),    -- パープル
    ESPEnemy      = Color3.fromRGB(200, 60, 60),     -- 敵: レッド
    ESPAlly       = Color3.fromRGB(60, 200, 100),    -- 味方: グリーン
    ESPNeutral    = Color3.fromRGB(200, 180, 60),    -- 中立: イエロー
    HealthHigh    = Color3.fromRGB(60, 220, 100),
    HealthMid     = Color3.fromRGB(255, 200, 40),
    HealthLow     = Color3.fromRGB(255, 60, 60),
}

-- ============================================================
--   RAYFIELD UI ロード (テーマ適用)
-- ============================================================
local Rayfield = nil
local RayfieldLoaded = false
pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    if Rayfield then RayfieldLoaded = true end
end)

-- ============================================================
--   設定テーブル
-- ============================================================
local Config = {
    -- Aimbot
    AimbotEnabled     = false,
    AimbotMode        = "Sticky",
    AimbotFOV         = 120,
    AimbotSmoothing   = 0.35,
    AimbotStickyStrength = 0.85,
    AimbotBone        = "Head",
    AimbotTeamCheck   = true,
    AimbotVisCheck    = false,
    AimbotTriggerbot  = false,
    AimbotAutoShoot   = false,
    AimbotMaxAngle    = 8,

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
    AutoHeal          = false,
    HealAmount        = 20,

    -- Misc
    AntiAFK           = true,
    NoFog             = false,
    FullBright        = false,

    -- Rage
    RageMode          = false,

    -- Hotkeys
    Hotkeys = {
        Menu       = "Insert",
        Aimbot     = "Q",
        AimbotMode = "G",
        ESP        = "B",
        Fly        = "J",
        Heal       = "H",
        Noclip     = "N",
        Speed      = "K",
        Jump       = "M",
        BHop       = "V",
        KillAura   = "Z",
        Trigger    = "T",
        AutoShoot  = "Y",
        Teleport   = "X",
        Rage       = "R",
    },

    CurrentProfile = "Default",
}

-- ============================================================
--   プロファイル管理
-- ============================================================
local PROFILES_DIR = "ZetaX_Profiles/"
local function GetProfilePath(name) return PROFILES_DIR .. name .. ".json" end

local function LoadProfile(name)
    local path = GetProfilePath(name)
    local success, data = pcall(function()
        if isfile and isfile(path) then return readfile(path) end
        return nil
    end)
    if success and data then
        local decoded = HttpService:JSONDecode(data)
        if decoded and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if type(v) == "table" and k == "Hotkeys" then
                    for hk, val in pairs(v) do
                        if Config.Hotkeys[hk] ~= nil then Config.Hotkeys[hk] = val end
                    end
                elseif Config[k] ~= nil then
                    Config[k] = v
                end
            end
            Config.CurrentProfile = name
            return true
        end
    end
    return false
end

local function SaveProfile(name)
    pcall(function()
        if makefolder then makefolder(PROFILES_DIR) end
        local json = HttpService:JSONEncode(Config)
        if writefile then writefile(GetProfilePath(name), json) end
    end)
    if RayfieldLoaded then
        Rayfield:Notify({Title = "Profile Saved", Content = name, Duration = 2})
    end
end

local function GetProfileList()
    local profiles = {"Default"}
    pcall(function()
        if listfiles then
            for _, file in ipairs(listfiles(PROFILES_DIR)) do
                local name = file:match("([^/]+)%.json$")
                if name and name ~= "Default" then table.insert(profiles, name) end
            end
        end
    end)
    return profiles
end

pcall(function()
    if isfile and isfile(GetProfilePath("Default")) then LoadProfile("Default") end
end)

-- ============================================================
--   グローバル状態
-- ============================================================
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil
local ESPObjects = {}
local FOVCircle = nil
local LastShot = 0
local IsAlive = false
local ESPUpdateCounter = 0
local CurrentAimbotMode = "Sticky"

-- ============================================================
--   安全な関数実行
-- ============================================================
local function SafeCall(func, ...)
    local results = {pcall(func, ...)}
    if not results[1] then
        warn("[ZETA X] Error:", results[2])
        return nil
    end
    return table.unpack(results, 2)
end

-- ============================================================
--   キャラクター管理
-- ============================================================
local function RefreshCharacter()
    local newChar = LP.Character
    if newChar and newChar ~= Character then
        Character = newChar
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then IsAlive = Humanoid.Health > 0 end
        for pl in pairs(ESPObjects) do SafeCall(RemoveESP, pl) end
        if Config.FlyEnabled and HumanoidRootPart then SafeCall(StartFly) end
        return true
    end
    return false
end

LP.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:FindFirstChild("HumanoidRootPart")
    Humanoid = newChar:FindFirstChildOfClass("Humanoid")
    if Humanoid then IsAlive = Humanoid.Health > 0 end
    for pl in pairs(ESPObjects) do SafeCall(RemoveESP, pl) end
    if Config.FlyEnabled and HumanoidRootPart then SafeCall(StartFly) end
    if RayfieldLoaded then
        Rayfield:Notify({Title = "Match Restart", Content = "All features re-activated", Duration = 2})
    end
end)

LP.CharacterRemoving:Connect(function()
    Character = nil
    HumanoidRootPart = nil
    Humanoid = nil
    IsAlive = false
    if FlyBV then SafeCall(StopFly) end
end)

spawn(function()
    while true do
        wait(1)
        if not Character or not HumanoidRootPart or not Humanoid then
            SafeCall(RefreshCharacter)
        end
        if Character and Humanoid then IsAlive = Humanoid.Health > 0 end
    end
end)

-- ============================================================
--   ユーティリティ
-- ============================================================
local function GetRootPart(pl)
    local ch = pl and pl.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function GetBone(pl, bone)
    local ch = pl and pl.Character
    return ch and (ch:FindFirstChild(bone) or ch:FindFirstChild("HumanoidRootPart"))
end

local function GetHumanoid(pl)
    local ch = pl and pl.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function IsPlayerAlive(pl)
    local h = GetHumanoid(pl)
    return h and h.Health > 0
end

local function IsEnemy(pl)
    if Config.AimbotTeamCheck and LP.Team and pl.Team then
        return LP.Team ~= pl.Team
    end
    return pl ~= LP
end

local function WorldToViewport(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on, sp.Z
end

local function GetDistance(pl)
    local r = GetRootPart(pl)
    if r and HumanoidRootPart then
        return (r.Position - HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function IsVisible(pl)
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
    local result = Workspace:Raycast(Camera.CFrame.Position, (bone.Position - Camera.CFrame.Position).Unit * 1000, params)
    return result == nil
end

local function IsTarget(pl)
    if pl == LP then return false end
    if not IsPlayerAlive(pl) then return false end
    if not IsEnemy(pl) then return false end
    return true
end

-- ============================================================
--   FOV Circle (Blue Purple テーマ)
-- ============================================================
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Radius = Config.AimbotFOV
    FOVCircle.Color = Theme.FOVColor
    FOVCircle.Thickness = 1.5
    FOVCircle.Transparency = 0.6
    FOVCircle.Filled = false
    FOVCircle.ZIndex = 999
end)

-- ============================================================
--   AIMBOT (Sticky + Normal)
-- ============================================================
local function GetClosestTarget()
    if not Camera then return nil end
    local mousePos = UserInputService:GetMouseLocation()
    local minDist = Config.AimbotFOV
    local target = nil

    for _, pl in ipairs(Players:GetPlayers()) do
        if IsTarget(pl) then
            if Config.AimbotVisCheck and not IsVisible(pl) then continue end
            local bone = GetBone(pl, Config.AimbotBone)
            if bone then
                local sp, on = WorldToViewport(bone.Position)
                if on then
                    local dist = (sp - mousePos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = pl
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if not Config.AimbotEnabled then return end
    if not Character or not HumanoidRootPart or not Camera then return end

    local target = GetClosestTarget()
    if not target then return end

    local bone = GetBone(target, Config.AimbotBone)
    if not bone then return end

    local targetPos = bone.Position

    if Config.AimbotMode == "Sticky" then
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        local strength = Config.AimbotStickyStrength
        local newCF = currentCF:Lerp(targetCF, strength)
        Camera.CFrame = newCF
    else
        local sp, on = WorldToViewport(targetPos)
        if not on then return end

        local mousePos = UserInputService:GetMouseLocation()
        local delta = sp - mousePos
        local dist = delta.Magnitude
        if dist < 1 then return end

        local maxMove = Config.AimbotMaxAngle * 1.5
        local smoothFactor = Config.AimbotSmoothing

        local moveX = delta.X * smoothFactor
        local moveY = delta.Y * smoothFactor
        local moveMag = math.sqrt(moveX^2 + moveY^2)
        if moveMag > maxMove then
            moveX = moveX / moveMag * maxMove
            moveY = moveY / moveMag * maxMove
        end

        pcall(function() mousemoverel(moveX, moveY) end)
    end

    if Config.AimbotTriggerbot or Config.AimbotAutoShoot then
        local now = tick()
        local interval = Config.AimbotTriggerbot and 0.12 or 0.05
        if now - LastShot > interval then
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(0, 0))
                    VirtualUser:Button1Up(Vector2.new(0, 0))
                else
                    mouse1click()
                end
            end)
            LastShot = now
        end
    end
end)

-- ============================================================
--   ESP (Blue Purple テーマ連動)
-- ============================================================
local function RemoveESP(pl)
    if ESPObjects[pl] then
        for _, obj in pairs(ESPObjects[pl]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[pl] = nil
    end
end

local function CreateESP(pl)
    RemoveESP(pl)
    local objs = {}
    pcall(function()
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
        nameTag.Color = Theme.TextBright
        objs.nameTag = nameTag

        local distTag = Drawing.new("Text")
        distTag.Visible = false
        distTag.Size = 11
        distTag.Center = true
        distTag.Outline = true
        distTag.Font = Drawing.Fonts.UI
        distTag.Color = Theme.SubText
        objs.distTag = distTag

        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1.5
        tracer.Transparency = 0.6
        objs.tracer = tracer

        local healthBG = Drawing.new("Square")
        healthBG.Visible = false
        healthBG.Color = Color3.fromRGB(20, 20, 40)
        healthBG.Filled = true
        objs.healthBG = healthBG

        local healthBar = Drawing.new("Square")
        healthBar.Visible = false
        healthBar.Filled = true
        objs.healthBar = healthBar
    end)
    ESPObjects[pl] = objs
end

RunService.Heartbeat:Connect(function()
    ESPUpdateCounter = ESPUpdateCounter + 1
    if ESPUpdateCounter % 2 ~= 0 then return end

    if not Config.ESPEnabled then
        for pl in pairs(ESPObjects) do SafeCall(RemoveESP, pl) end
        return
    end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        if not ESPObjects[pl] then SafeCall(CreateESP, pl) end
        if not ESPObjects[pl] then continue end

        local dist = GetDistance(pl)
        if dist > Config.ESPMaxDist then
            for _, obj in pairs(ESPObjects[pl]) do
                pcall(function() obj.Visible = false end)
            end
            continue
        end

        local ch = pl.Character
        local root = GetRootPart(pl)
        local hum = GetHumanoid(pl)
        if not ch or not root or not hum then
            SafeCall(RemoveESP, pl)
            continue
        end

        local headPos = ch:FindFirstChild("Head") and ch.Head.Position or root.Position + Vector3.new(0, 2, 0)
        local feetPos = root.Position - Vector3.new(0, 3, 0)
        local headScr, onH = WorldToViewport(headPos)
        local feetScr, onF = WorldToViewport(feetPos)
        local visible = onH and onF

        local objs = ESPObjects[pl]
        if not objs then continue end

        local isEnemy = IsEnemy(pl)
        local color = isEnemy and Theme.ESPEnemy or Theme.ESPAlly

        if visible and Config.ESPBoxes then
            local height = math.abs(headScr.Y - feetScr.Y)
            local width = height * 0.45
            pcall(function()
                objs.box.Visible = true
                objs.box.Color = color
                objs.box.Size = Vector2.new(width, height)
                objs.box.Position = Vector2.new(headScr.X - width/2, headScr.Y)
            end)

            if Config.ESPHealthBar then
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barH = height
                local barW = 4
                local barX = headScr.X - width/2 - barW - 3
                local barY = headScr.Y
                local hpColor = hp > 0.6 and Theme.HealthHigh or (hp > 0.3 and Theme.HealthMid or Theme.HealthLow)
                pcall(function()
                    objs.healthBG.Visible = true
                    objs.healthBG.Size = Vector2.new(barW, barH)
                    objs.healthBG.Position = Vector2.new(barX, barY)
                    objs.healthBar.Visible = true
                    objs.healthBar.Size = Vector2.new(barW, barH * hp)
                    objs.healthBar.Position = Vector2.new(barX, barY + barH * (1 - hp))
                    objs.healthBar.Color = hpColor
                end)
            else
                pcall(function()
                    objs.healthBG.Visible = false
                    objs.healthBar.Visible = false
                end)
            end
        else
            pcall(function()
                objs.box.Visible = false
                objs.healthBG.Visible = false
                objs.healthBar.Visible = false
            end)
        end

        if visible and Config.ESPNames then
            pcall(function()
                objs.nameTag.Visible = true
                objs.nameTag.Text = pl.DisplayName
                objs.nameTag.Position = Vector2.new(headScr.X, headScr.Y - 16)
            end)
        else
            pcall(function() objs.nameTag.Visible = false end)
        end

        if visible and Config.ESPDistance then
            pcall(function()
                objs.distTag.Visible = true
                objs.distTag.Text = string.format("[%.0fm]", dist)
                objs.distTag.Position = Vector2.new(headScr.X, headScr.Y - 5)
            end)
        else
            pcall(function() objs.distTag.Visible = false end)
        end

        if visible and Config.ESPTracers then
            local vp = Camera.ViewportSize
            pcall(function()
                objs.tracer.Visible = true
                objs.tracer.From = Vector2.new(vp.X/2, vp.Y)
                objs.tracer.To = feetScr
                objs.tracer.Color = color
            end)
        else
            pcall(function() objs.tracer.Visible = false end)
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ============================================================
--   MOVEMENT
-- ============================================================
RunService.Heartbeat:Connect(function()
    if Config.SpeedEnabled and Humanoid and HumanoidRootPart and Humanoid.MoveDirection.Magnitude > 0 then
        pcall(function()
            HumanoidRootPart.Velocity = Humanoid.MoveDirection * Config.SpeedValue + Vector3.new(0, HumanoidRootPart.Velocity.Y, 0)
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Humanoid then
        pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.BunnyHop and Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.Landed then
        pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

RunService.Stepped:Connect(function()
    if Config.NoclipEnabled and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
end)

local FlyBV = nil
local FlyBG = nil

local function StartFly()
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    if not HumanoidRootPart then return end
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBV.Parent = HumanoidRootPart
    FlyBG = Instance.new("BodyGyro")
    FlyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    FlyBG.Parent = HumanoidRootPart
    if Humanoid then Humanoid.PlatformStand = true end
end

local function StopFly()
    if FlyBV then FlyBV:Destroy(); FlyBV = nil end
    if FlyBG then FlyBG:Destroy(); FlyBG = nil end
    if Humanoid then Humanoid.PlatformStand = false end
end

RunService.RenderStepped:Connect(function()
    if not Config.FlyEnabled then
        if FlyBV then SafeCall(StopFly) end
        return
    end
    if not FlyBV or not FlyBV.Parent then SafeCall(StartFly) end
    if not HumanoidRootPart then return end

    local move = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

    if FlyBV then
        if move.Magnitude > 0 then
            FlyBV.Velocity = move.Unit * Config.FlySpeed
        else
            FlyBV.Velocity = Vector3.new(0, 0, 0)
        end
    end
    if FlyBG then
        FlyBG.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + Camera.CFrame.LookVector)
    end
end)

-- ============================================================
--   COMBAT
-- ============================================================
local function GetHitRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remotes then
        for _, name in ipairs({"Hit", "Damage", "Attack", "DealDamage", "HitPlayer"}) do
            local r = remotes:FindFirstChild(name)
            if r then return r end
        end
    end
    for _, name in ipairs({"HitRemote", "DamageRemote", "AttackRemote"}) do
        local r = ReplicatedStorage:FindFirstChild(name)
        if r then return r end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not Config.KillAura then return end
    local hitRemote = GetHitRemote()
    if not hitRemote then return end

    for _, pl in ipairs(Players:GetPlayers()) do
        if IsTarget(pl) and GetDistance(pl) <= Config.KillAuraRange then
            pcall(function() hitRemote:FireServer(pl.Character or pl) end)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AutoHeal and Humanoid and Humanoid.Health < Humanoid.MaxHealth then
        pcall(function() Humanoid.Health = math.min(Humanoid.Health + Config.HealAmount, Humanoid.MaxHealth) end)
    end
end)

-- ============================================================
--   TELEPORT
-- ============================================================
local function TeleportToTarget()
    local target = nil
    local minDist = math.huge
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
        if HumanoidRootPart then
            pcall(function()
                HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
            end)
        end
    end
end

-- ============================================================
--   MISC
-- ============================================================
LP.Idled:Connect(function()
    if Config.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.NoFog then
        pcall(function()
            Lighting.FogStart = 1e6
            Lighting.FogEnd = 1e6
        end)
    end
    if Config.FullBright then
        pcall(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        end)
    end
end)

-- ============================================================
--   RAGE MODE
-- ============================================================
local function ApplyRageMode()
    Config.RageMode = not Config.RageMode
    if Config.RageMode then
        Config.AimbotEnabled = true
        Config.AimbotMode = "Sticky"
        Config.AimbotFOV = 360
        Config.AimbotSmoothing = 0.05
        Config.AimbotStickyStrength = 0.95
        Config.AimbotTriggerbot = true
        Config.AimbotAutoShoot = true
        Config.AimbotMaxAngle = 30
        Config.AimbotTeamCheck = false
        Config.AimbotVisCheck = false
        Config.SpeedEnabled = true
        Config.SpeedValue = 120
        Config.FlyEnabled = true
        Config.FlySpeed = 300
        Config.NoclipEnabled = true
        Config.InfiniteJump = true
        Config.KillAura = true
        Config.KillAuraRange = 50
        Config.AutoHeal = true
        Config.HealAmount = 50
        Config.ESPEnabled = true
        Config.ESPBoxes = true
        Config.ESPNames = true
        Config.ESPDistance = true
        Config.ESPTracers = true
        Config.ESPHealthBar = true
        Config.ESPTeamColor = true
        Config.ESPMaxDist = 5000
        Config.NoFog = true
        Config.FullBright = true
        if RayfieldLoaded then
            Rayfield:Notify({Title = "⚡ RAGE MODE", Content = "Sticky Aimbot + All max!", Duration = 3, Image = 4483362458})
        end
    else
        if RayfieldLoaded then
            Rayfield:Notify({Title = "Rage OFF", Content = "Adjust manually", Duration = 2})
        end
    end
end

-- ============================================================
--   HOTKEY SYSTEM
-- ============================================================
local function Toggle(name, key, notify)
    Config[name] = not Config[name]
    if key == "Fly" and Config[name] then SafeCall(StartFly) elseif key == "Fly" then SafeCall(StopFly) end
    if key == "ESP" and not Config[name] then
        for pl in pairs(ESPObjects) do SafeCall(RemoveESP, pl) end
    end
    if RayfieldLoaded and notify then
        Rayfield:Notify({Title = key, Content = Config[name] and "ON" or "OFF", Duration = 1})
    end
end

local function ToggleAimbotMode()
    if Config.AimbotMode == "Sticky" then
        Config.AimbotMode = "Normal"
        CurrentAimbotMode = "Normal"
        if RayfieldLoaded then
            Rayfield:Notify({Title = "Aimbot Mode", Content = "Normal (Mouse)", Duration = 2})
        end
    else
        Config.AimbotMode = "Sticky"
        CurrentAimbotMode = "Sticky"
        if RayfieldLoaded then
            Rayfield:Notify({Title = "Aimbot Mode", Content = "Sticky (Camera Lock)", Duration = 2})
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = input.KeyCode.Name
    local hk = Config.Hotkeys

    if key == hk.Aimbot then Toggle("AimbotEnabled", "Aimbot", true)
    elseif key == hk.AimbotMode then ToggleAimbotMode()
    elseif key == hk.ESP then Toggle("ESPEnabled", "ESP", true)
    elseif key == hk.Fly then Toggle("FlyEnabled", "Fly", true)
    elseif key == hk.Heal then Toggle("AutoHeal", "Heal", true)
    elseif key == hk.Noclip then Toggle("NoclipEnabled", "Noclip", true)
    elseif key == hk.Speed then Toggle("SpeedEnabled", "Speed", true)
    elseif key == hk.Jump then Toggle("InfiniteJump", "Jump", true)
    elseif key == hk.BHop then Toggle("BunnyHop", "BHop", true)
    elseif key == hk.KillAura then Toggle("KillAura", "KillAura", true)
    elseif key == hk.Trigger then Toggle("AimbotTriggerbot", "Trigger", true)
    elseif key == hk.AutoShoot then Toggle("AimbotAutoShoot", "AutoShoot", true)
    elseif key == hk.Teleport then TeleportToTarget()
    elseif key == hk.Rage then ApplyRageMode()
    end
end)

-- ============================================================
--   RAYFIELD UI (Blue Purple テーマ)
-- ============================================================
local Window = nil
if RayfieldLoaded and Rayfield then
    Window = Rayfield:CreateWindow({
        Name = "ZETA X ULTIMATE",
        Icon = 0,
        LoadingTitle = "ZETA X",
        LoadingSubtitle = "Blue Purple Theme",
        Theme = "Default",  -- Rayfieldのデフォルトテーマを使うが、全体の色は別途調整
        ConfigurationSaving = { Enabled = false },
        KeySystem = false,
    })

    -- ============ RAGE TAB ============
    local RageTab = Window:CreateTab("⚡ Rage", 4483362458)
    RageTab:CreateToggle({Name = "RAGE MODE (R key)", CurrentValue = Config.RageMode, Flag = "RageMode", Callback = function(v) Config.RageMode = v; if v then ApplyRageMode() end end})
    RageTab:CreateButton({Name = "Apply Rage Preset", Callback = function() Config.RageMode = true; ApplyRageMode() end})
    RageTab:CreateButton({Name = "Reset to Default", Callback = function()
        Config.RageMode = false
        Config.AimbotEnabled = false
        Config.AimbotMode = "Sticky"
        Config.AimbotFOV = 120
        Config.AimbotSmoothing = 0.35
        Config.AimbotStickyStrength = 0.85
        Config.AimbotTriggerbot = false
        Config.AimbotAutoShoot = false
        Config.AimbotMaxAngle = 8
        Config.AimbotTeamCheck = true
        Config.AimbotVisCheck = false
        Config.SpeedEnabled = false
        Config.SpeedValue = 32
        Config.FlyEnabled = false
        Config.FlySpeed = 80
        Config.NoclipEnabled = false
        Config.InfiniteJump = false
        Config.KillAura = false
        Config.KillAuraRange = 15
        Config.AutoHeal = false
        Config.HealAmount = 20
        Config.ESPEnabled = false
        Config.ESPBoxes = true
        Config.ESPNames = true
        Config.ESPDistance = true
        Config.ESPTracers = false
        Config.ESPHealthBar = true
        Config.ESPTeamColor = true
        Config.ESPMaxDist = 1000
        Config.NoFog = false
        Config.FullBright = false
        if RayfieldLoaded then Rayfield:Notify({Title = "Reset", Content = "Default settings", Duration = 2}) end
    end})

    -- ============ PROFILES TAB ============
    local ProfileTab = Window:CreateTab("💾 Profiles", 4483362458)
    local ProfileNameInput = ""
    ProfileTab:CreateInput({Name = "Profile Name", PlaceholderText = "Enter name...", RemoveTextAfterFocusLost = false, Callback = function(t) ProfileNameInput = t end})
    ProfileTab:CreateButton({Name = "Save Current Profile", Callback = function()
        if ProfileNameInput and ProfileNameInput ~= "" then SaveProfile(ProfileNameInput)
        else Rayfield:Notify({Title = "Error", Content = "Enter a name", Duration = 2}) end
    end})
    ProfileTab:CreateButton({Name = "Load Profile", Callback = function()
        if ProfileNameInput and ProfileNameInput ~= "" then
            if LoadProfile(ProfileNameInput) then Rayfield:Notify({Title = "Loaded", Content = ProfileNameInput, Duration = 2})
            else Rayfield:Notify({Title = "Error", Content = "Not found", Duration = 2}) end
        end
    end})
    ProfileTab:CreateButton({Name = "Delete Profile", Callback = function()
        if ProfileNameInput and ProfileNameInput ~= "" and ProfileNameInput ~= "Default" then
            pcall(function() if delfile then delfile(GetProfilePath(ProfileNameInput)) end end)
            Rayfield:Notify({Title = "Deleted", Content = ProfileNameInput, Duration = 2})
        end
    end})
    ProfileTab:CreateButton({Name = "Refresh List", Callback = function()
        local list = GetProfileList()
        Rayfield:Notify({Title = "Profiles", Content = table.concat(list, ", "), Duration = 4})
    end})
    ProfileTab:CreateButton({Name = "Load Default", Callback = function() LoadProfile("Default"); Rayfield:Notify({Title = "Loaded", Content = "Default", Duration = 2}) end})

    -- ============ AIMBOT TAB ============
    local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
    AimbotTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = Config.AimbotEnabled, Flag = "AimbotEnabled", Callback = function(v) Config.AimbotEnabled = v; if FOVCircle then FOVCircle.Visible = v end end})
    AimbotTab:CreateToggle({Name = "Team Check", CurrentValue = Config.AimbotTeamCheck, Flag = "AimbotTeamCheck", Callback = function(v) Config.AimbotTeamCheck = v end})
    AimbotTab:CreateToggle({Name = "Visibility Check", CurrentValue = Config.AimbotVisCheck, Flag = "AimbotVisCheck", Callback = function(v) Config.AimbotVisCheck = v end})
    AimbotTab:CreateToggle({Name = "Triggerbot", CurrentValue = Config.AimbotTriggerbot, Flag = "AimbotTriggerbot", Callback = function(v) Config.AimbotTriggerbot = v end})
    AimbotTab:CreateToggle({Name = "Auto Shoot", CurrentValue = Config.AimbotAutoShoot, Flag = "AimbotAutoShoot", Callback = function(v) Config.AimbotAutoShoot = v end})

    AimbotTab:CreateDropdown({
        Name = "Aimbot Mode",
        Options = {"Sticky (Camera Lock)", "Normal (Mouse Move)"},
        CurrentOption = {Config.AimbotMode == "Sticky" and "Sticky (Camera Lock)" or "Normal (Mouse Move)"},
        Flag = "AimbotModeDropdown",
        Callback = function(v)
            if v[1] == "Sticky (Camera Lock)" then
                Config.AimbotMode = "Sticky"
                CurrentAimbotMode = "Sticky"
            else
                Config.AimbotMode = "Normal"
                CurrentAimbotMode = "Normal"
            end
        end,
    })

    AimbotTab:CreateSlider({Name = "FOV Size", Range = {10, 400}, Increment = 5, Suffix = "px", CurrentValue = Config.AimbotFOV, Flag = "AimbotFOV", Callback = function(v) Config.AimbotFOV = v; if FOVCircle then FOVCircle.Radius = v end end})
    AimbotTab:CreateSlider({Name = "Smoothing (Normal mode)", Range = {0.05, 0.9}, Increment = 0.05, Suffix = "", CurrentValue = Config.AimbotSmoothing, Flag = "AimbotSmoothing", Callback = function(v) Config.AimbotSmoothing = v end})
    AimbotTab:CreateSlider({Name = "Sticky Strength", Range = {0.5, 1.0}, Increment = 0.05, Suffix = "", CurrentValue = Config.AimbotStickyStrength, Flag = "AimbotStickyStrength", Callback = function(v) Config.AimbotStickyStrength = v end})
    AimbotTab:CreateSlider({Name = "Max Angle (deg)", Range = {2, 30}, Increment = 1, Suffix = "°", CurrentValue = Config.AimbotMaxAngle, Flag = "AimbotMaxAngle", Callback = function(v) Config.AimbotMaxAngle = v end})
    AimbotTab:CreateDropdown({Name = "Target Bone", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {Config.AimbotBone}, Flag = "AimbotBone", Callback = function(v) Config.AimbotBone = v[1] end})
    AimbotTab:CreateButton({Name = "Toggle Mode (G key)", Callback = ToggleAimbotMode})

    -- ============ ESP TAB ============
    local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
    ESPTab:CreateToggle({Name = "Enable ESP", CurrentValue = Config.ESPEnabled, Flag = "ESPEnabled", Callback = function(v) Config.ESPEnabled = v; if not v then for pl in pairs(ESPObjects) do SafeCall(RemoveESP, pl) end end end})
    ESPTab:CreateToggle({Name = "Boxes", CurrentValue = Config.ESPBoxes, Flag = "ESPBoxes", Callback = function(v) Config.ESPBoxes = v end})
    ESPTab:CreateToggle({Name = "Names", CurrentValue = Config.ESPNames, Flag = "ESPNames", Callback = function(v) Config.ESPNames = v end})
    ESPTab:CreateToggle({Name = "Distance", CurrentValue = Config.ESPDistance, Flag = "ESPDistance", Callback = function(v) Config.ESPDistance = v end})
    ESPTab:CreateToggle({Name = "Tracers", CurrentValue = Config.ESPTracers, Flag = "ESPTracers", Callback = function(v) Config.ESPTracers = v end})
    ESPTab:CreateToggle({Name = "Health Bar", CurrentValue = Config.ESPHealthBar, Flag = "ESPHealthBar", Callback = function(v) Config.ESPHealthBar = v end})
    ESPTab:CreateToggle({Name = "Team Color", CurrentValue = Config.ESPTeamColor, Flag = "ESPTeamColor", Callback = function(v) Config.ESPTeamColor = v end})
    ESPTab:CreateSlider({Name = "Max Distance", Range = {100, 5000}, Increment = 50, Suffix = "studs", CurrentValue = Config.ESPMaxDist, Flag = "ESPMaxDist", Callback = function(v) Config.ESPMaxDist = v end})

    -- ============ MOVEMENT TAB ============
    local MovTab = Window:CreateTab("🏃 Movement", 4483362458)
    MovTab:CreateToggle({Name = "Speed Hack", CurrentValue = Config.SpeedEnabled, Flag = "SpeedEnabled", Callback = function(v) Config.SpeedEnabled = v end})
    MovTab:CreateSlider({Name = "Speed Value", Range = {16, 300}, Increment = 2, Suffix = "studs/s", CurrentValue = Config.SpeedValue, Flag = "SpeedValue", Callback = function(v) Config.SpeedValue = v end})
    MovTab:CreateToggle({Name = "Fly", CurrentValue = Config.FlyEnabled, Flag = "FlyEnabled", Callback = function(v) Config.FlyEnabled = v; if v then SafeCall(StartFly) else SafeCall(StopFly) end end})
    MovTab:CreateSlider({Name = "Fly Speed", Range = {10, 500}, Increment = 5, Suffix = "studs/s", CurrentValue = Config.FlySpeed, Flag = "FlySpeed", Callback = function(v) Config.FlySpeed = v end})
    MovTab:CreateToggle({Name = "Noclip", CurrentValue = Config.NoclipEnabled, Flag = "NoclipEnabled", Callback = function(v) Config.NoclipEnabled = v end})
    MovTab:CreateToggle({Name = "Infinite Jump", CurrentValue = Config.InfiniteJump, Flag = "InfiniteJump", Callback = function(v) Config.InfiniteJump = v end})
    MovTab:CreateToggle({Name = "Bunny Hop", CurrentValue = Config.BunnyHop, Flag = "BunnyHop", Callback = function(v) Config.BunnyHop = v end})

    -- ============ COMBAT TAB ============
    local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
    CombatTab:CreateToggle({Name = "Kill Aura", CurrentValue = Config.KillAura, Flag = "KillAura", Callback = function(v) Config.KillAura = v end})
    CombatTab:CreateSlider({Name = "Kill Aura Range", Range = {5, 100}, Increment = 1, Suffix = "studs", CurrentValue = Config.KillAuraRange, Flag = "KillAuraRange", Callback = function(v) Config.KillAuraRange = v end})
    CombatTab:CreateToggle({Name = "Auto Heal", CurrentValue = Config.AutoHeal, Flag = "AutoHeal", Callback = function(v) Config.AutoHeal = v end})
    CombatTab:CreateSlider({Name = "Heal Amount", Range = {5, 50}, Increment = 1, Suffix = "HP", CurrentValue = Config.HealAmount, Flag = "HealAmount", Callback = function(v) Config.HealAmount = v end})

    -- ============ MISC TAB ============
    local MiscTab = Window:CreateTab("🔧 Misc", 4483362458)
    MiscTab:CreateToggle({Name = "Anti-AFK", CurrentValue = Config.AntiAFK, Flag = "AntiAFK", Callback = function(v) Config.AntiAFK = v end})
    MiscTab:CreateToggle({Name = "No Fog", CurrentValue = Config.NoFog, Flag = "NoFog", Callback = function(v) Config.NoFog = v end})
    MiscTab:CreateToggle({Name = "Full Bright", CurrentValue = Config.FullBright, Flag = "FullBright", Callback = function(v) Config.FullBright = v end})
    MiscTab:CreateButton({Name = "Teleport to Enemy", Callback = TeleportToTarget})
    MiscTab:CreateButton({Name = "Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, LP) end})
    MiscTab:CreateButton({Name = "Respawn", Callback = function() LP:LoadCharacter() end})

    -- ============ HOTKEYS TAB ============
    local HotkeyTab = Window:CreateTab("⌨️ Hotkeys", 4483362458)

    local function HKButton(name, key)
        HotkeyTab:CreateButton({
            Name = name .. " (Current: " .. Config.Hotkeys[key] .. ")",
            Callback = function()
                local newKey = ""
                local con
                con = UserInputService.InputBegan:Connect(function(input)
                    if input.KeyCode ~= Enum.KeyCode.Unknown then
                        newKey = input.KeyCode.Name
                        Config.Hotkeys[key] = newKey
                        if RayfieldLoaded then
                            Rayfield:Notify({Title = "Hotkey Set", Content = name .. " → " .. newKey, Duration = 2})
                        end
                        con:Disconnect()
                        SaveProfile(Config.CurrentProfile)
                        pcall(function()
                            for _, child in ipairs(HotkeyTab:GetChildren()) do
                                if child:IsA("Frame") and child:FindFirstChild("TextLabel") then
                                    local lbl = child:FindFirstChild("TextLabel")
                                    if lbl and lbl.Text and string.find(lbl.Text, name) then
                                        lbl.Text = name .. " (Current: " .. newKey .. ")"
                                    end
                                end
                            end
                        end)
                    end
                end)
                if RayfieldLoaded then
                    Rayfield:Notify({Title = "Press a key", Content = "for " .. name, Duration = 3})
                end
            end,
        })
    end

    HKButton("Menu", "Menu")
    HKButton("Aimbot ON/OFF", "Aimbot")
    HKButton("Aimbot Mode (Sticky/Normal)", "AimbotMode")
    HKButton("ESP", "ESP")
    HKButton("Fly", "Fly")
    HKButton("Auto Heal", "Heal")
    HKButton("Noclip", "Noclip")
    HKButton("Speed Hack", "Speed")
    HKButton("Infinite Jump", "Jump")
    HKButton("Bunny Hop", "BHop")
    HKButton("Kill Aura", "KillAura")
    HKButton("Triggerbot", "Trigger")
    HKButton("Auto Shoot", "AutoShoot")
    HKButton("Teleport", "Teleport")
    HKButton("Rage Mode", "Rage")

    -- ============ 起動通知 ============
    Rayfield:Notify({
        Title = "💙💜 ZETA X ULTIMATE",
        Content = "Blue Purple Theme | Sticky Aimbot",
        Duration = 5,
        Image = 4483362458,
    })
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ZETA X ULTIMATE",
        Text = "Blue Purple Theme | Loaded",
        Duration = 5,
    })
end

-- ============================================================
--   初期化
-- ============================================================
SafeCall(RefreshCharacter)
print("[ZETA X ULTIMATE] Blue Purple Theme loaded.")

while true do
    wait(10)
end