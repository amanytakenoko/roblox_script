-- ============================================================
--   ZETA X – ULTIMATE FINAL
--   マッチ切り替え完全対応 | 全機能永続動作
--   ブルーパープルテーマ | Rivals専用
-- ============================================================

-- // サービス
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

-- // ローカルプレイヤー
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
--   デバッグ
-- ============================================================
local function Debug(msg)
    print("[ZETA] " .. tostring(msg))
end

-- ============================================================
--   RAYFIELD UI
-- ============================================================
local Rayfield = nil
local RayfieldLoaded = false
pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    if Rayfield then RayfieldLoaded = true end
end)

-- ============================================================
--   テーマ
-- ============================================================
local Theme = {
    Background = Color3.fromRGB(10, 10, 30),
    Accent = Color3.fromRGB(100, 60, 200),
    Accent2 = Color3.fromRGB(60, 120, 255),
    Text = Color3.fromRGB(200, 180, 255),
    TextBright = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 140, 200),
    FOVColor = Color3.fromRGB(100, 60, 200),
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
    AimbotMaxAngle = 8,
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPTracers = false,
    ESPHealthBar = true,
    ESPTeamColor = true,
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
    AutoHeal = false,
    HealAmount = 20,
    AntiAFK = true,
    NoFog = false,
    FullBright = false,
    RageMode = false,
    CurrentProfile = "Default",
}

-- ============================================================
--   プロファイル
-- ============================================================
local PROFILES_DIR = "ZetaX_Profiles/"
local function GetProfilePath(name) return PROFILES_DIR .. name .. ".json" end

local function LoadProfile(name)
    if not name or name == "" then name = "Default" end
    local path = GetProfilePath(name)
    local ok, data = pcall(function()
        if isfile and isfile(path) then return readfile(path) end
        return nil
    end)
    if ok and data then
        local decoded = HttpService:JSONDecode(data)
        if decoded then
            for k, v in pairs(decoded) do
                if Config[k] ~= nil then Config[k] = v end
            end
            Config.CurrentProfile = name
            return true
        end
    end
    return false
end

local function SaveProfile(name)
    if not name or name == "" then name = "Default" end
    pcall(function()
        if makefolder then makefolder(PROFILES_DIR) end
        if writefile then writefile(GetProfilePath(name), HttpService:JSONEncode(Config)) end
    end)
    if RayfieldLoaded and Rayfield then
        Rayfield:Notify({Title = "Saved", Content = name, Duration = 2})
    end
end

pcall(function()
    if isfile and isfile(GetProfilePath("Default")) then LoadProfile("Default") end
end)

-- ============================================================
--   キャラクター参照 (常に最新に保つ)
-- ============================================================
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil

-- キャラクター更新関数 (必ず最新の参照を取得)
local function UpdateCharacter()
    local newChar = LP.Character
    if newChar then
        Character = newChar
        HumanoidRootPart = newChar:FindFirstChild("HumanoidRootPart")
        Humanoid = newChar:FindFirstChildOfClass("Humanoid")
        Debug("Character updated")
        return true
    end
    return false
end

-- 初回取得
UpdateCharacter()

-- CharacterAddedで確実に更新
LP.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:FindFirstChild("HumanoidRootPart")
    Humanoid = newChar:FindFirstChildOfClass("Humanoid")
    Debug("CharacterAdded: new character")
    -- ESPオブジェクトをクリア (再構築させる)
    for pl in pairs(ESPObjects) do Safe(RemoveESP, pl) end
    -- Fly再起動
    if Config.FlyEnabled and HumanoidRootPart then
        Safe(StartFly)
    end
    if RayfieldLoaded and Rayfield then
        Rayfield:Notify({Title = "Match Restart", Content = "All features re-activated", Duration = 2})
    end
end)

-- CharacterRemovingでクリア
LP.CharacterRemoving:Connect(function()
    Character = nil
    HumanoidRootPart = nil
    Humanoid = nil
    Safe(StopFly)
    Debug("CharacterRemoving: character lost")
end)

-- 定期チェック (1秒ごとに更新を試みる)
spawn(function()
    while true do
        wait(1)
        if not Character or not HumanoidRootPart or not Humanoid then
            if UpdateCharacter() then
                Debug("Character recovered by periodic check")
                -- Fly再起動
                if Config.FlyEnabled and HumanoidRootPart then
                    Safe(StartFly)
                end
            end
        end
    end
end)

-- ============================================================
--   セーフコール
-- ============================================================
local function Safe(func, ...)
    local ok, err = pcall(func, ...)
    if not ok then Debug("Error: " .. tostring(err)) end
    return ok, err
end

-- ============================================================
--   ユーティリティ (Characterがnilでもエラーにならないように)
-- ============================================================
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
    if Config.AimbotTeamCheck and LP.Team and pl.Team then
        return LP.Team ~= pl.Team
    end
    return pl ~= LP
end

local function WorldToViewport(pos)
    if not Camera then return Vector2.new(0,0), false end
    local sp, on = Camera:WorldToViewportPoint(pos)
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
    if not Camera then return false end
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
    if not IsAlive(pl) then return false end
    if not IsEnemy(pl) then return false end
    return true
end

-- ============================================================
--   ESP (Drawing)
-- ============================================================
local ESPObjects = {}

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
            nameTag.Visible = false; nameTag.Size = 13; nameTag.Center = true
            nameTag.Outline = true; nameTag.Font = Drawing.Fonts.UI
            nameTag.Color = Theme.TextBright
            objs.nameTag = nameTag
        end

        local distTag = Drawing.new("Text")
        if distTag then
            distTag.Visible = false; distTag.Size = 11; distTag.Center = true
            distTag.Outline = true; distTag.Font = Drawing.Fonts.UI
            distTag.Color = Theme.SubText
            objs.distTag = distTag
        end

        local tracer = Drawing.new("Line")
        if tracer then tracer.Visible = false; tracer.Thickness = 1.5; tracer.Transparency = 0.6; objs.tracer = tracer end

        local healthBG = Drawing.new("Square")
        if healthBG then healthBG.Visible = false; healthBG.Color = Color3.fromRGB(20,20,40); healthBG.Filled = true; objs.healthBG = healthBG end

        local healthBar = Drawing.new("Square")
        if healthBar then healthBar.Visible = false; healthBar.Filled = true; objs.healthBar = healthBar end
    end)
    ESPObjects[pl] = objs
end

local ESPUpdateCounter = 0
RunService.Heartbeat:Connect(function()
    ESPUpdateCounter = ESPUpdateCounter + 1
    if ESPUpdateCounter % 2 ~= 0 then return end

    if not Config.ESPEnabled then
        for pl in pairs(ESPObjects) do Safe(RemoveESP, pl) end
        return
    end

    if not Camera then return end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LP then continue end
        if not ESPObjects[pl] then Safe(CreateESP, pl) end
        if not ESPObjects[pl] then continue end

        local dist = GetDistance(pl)
        if dist > Config.ESPMaxDist then
            for _, obj in pairs(ESPObjects[pl]) do
                Safe(function() if obj then obj.Visible = false end end)
            end
            continue
        end

        local ch = pl.Character
        local root = GetRootPart(pl)
        local hum = GetHumanoid(pl)
        if not ch or not root or not hum then
            Safe(RemoveESP, pl)
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
            if height < 1 then height = 30 end
            local width = height * 0.45
            if objs.box then
                Safe(function()
                    objs.box.Visible = true
                    objs.box.Color = color
                    objs.box.Size = Vector2.new(width, height)
                    objs.box.Position = Vector2.new(headScr.X - width/2, headScr.Y)
                end)
            end

            if Config.ESPHealthBar then
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barH = height
                local barW = 4
                local barX = headScr.X - width/2 - barW - 3
                local barY = headScr.Y
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

        if visible and Config.ESPNames and objs.nameTag then
            Safe(function()
                objs.nameTag.Visible = true
                objs.nameTag.Text = pl.DisplayName
                objs.nameTag.Position = Vector2.new(headScr.X, headScr.Y - 16)
            end)
        else
            if objs.nameTag then Safe(function() objs.nameTag.Visible = false end) end
        end

        if visible and Config.ESPDistance and objs.distTag then
            Safe(function()
                objs.distTag.Visible = true
                objs.distTag.Text = string.format("[%.0fm]", dist)
                objs.distTag.Position = Vector2.new(headScr.X, headScr.Y - 5)
            end)
        else
            if objs.distTag then Safe(function() objs.distTag.Visible = false end) end
        end

        if visible and Config.ESPTracers and objs.tracer then
            local vp = Camera.ViewportSize
            Safe(function()
                objs.tracer.Visible = true
                objs.tracer.From = Vector2.new(vp.X/2, vp.Y)
                objs.tracer.To = feetScr
                objs.tracer.Color = color
            end)
        else
            if objs.tracer then Safe(function() objs.tracer.Visible = false end) end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ============================================================
--   FOV Circle
-- ============================================================
local FOVCircle = nil
Safe(function()
    FOVCircle = Drawing.new("Circle")
    if FOVCircle then
        FOVCircle.Visible = false
        FOVCircle.Radius = Config.AimbotFOV
        FOVCircle.Color = Theme.FOVColor
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
--   AIMBOT (常にCharacterを参照)
-- ============================================================
local function GetClosestTarget()
    if not Camera then return nil end
    if not HumanoidRootPart then return nil end  -- キャラクターがなければ処理しない
    local mousePos = UserInputService:GetMouseLocation()
    if not mousePos then return nil end
    local minDist = Config.AimbotFOV
    local target = nil
    local viewportSize = Camera.ViewportSize

    for _, pl in ipairs(Players:GetPlayers()) do
        if not IsTarget(pl) then continue end
        if Config.AimbotVisCheck and not IsVisible(pl) then continue end

        local bone = GetBone(pl, Config.AimbotBone)
        if not bone then continue end

        local sp, on = WorldToViewport(bone.Position)
        if not on then continue end
        if sp.X < 0 or sp.X > viewportSize.X or sp.Y < 0 or sp.Y > viewportSize.Y then
            continue
        end

        local dist = (sp - mousePos).Magnitude
        if dist < minDist then
            minDist = dist
            target = pl
        end
    end
    return target
end

local LastShot = 0
RunService.RenderStepped:Connect(function()
    if not Config.AimbotEnabled then return end
    if not Character or not HumanoidRootPart or not Camera then return end

    local target = GetClosestTarget()
    if not target then return end

    local bone = GetBone(target, Config.AimbotBone)
    if not bone then return end

    local targetPos = bone.Position
    if not targetPos then return end

    if Config.AimbotMode == "Sticky" then
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        local strength = math.clamp(Config.AimbotStickyStrength, 0.3, 1.0)
        Camera.CFrame = currentCF:Lerp(targetCF, strength)
    else
        local sp, on = WorldToViewport(targetPos)
        if not on then return end

        local mousePos = UserInputService:GetMouseLocation()
        if not mousePos then return end

        local delta = sp - mousePos
        local dist = delta.Magnitude
        if dist < 0.5 then return end

        local maxMove = Config.AimbotMaxAngle * 1.2
        local smoothFactor = math.clamp(Config.AimbotSmoothing, 0.01, 0.9)

        local moveX = delta.X * smoothFactor
        local moveY = delta.Y * smoothFactor
        local moveMag = math.sqrt(moveX^2 + moveY^2)
        if moveMag > maxMove then
            moveX = moveX / moveMag * maxMove
            moveY = moveY / moveMag * maxMove
        end

        if math.abs(moveX) > 0.1 or math.abs(moveY) > 0.1 then
            Safe(function() mousemoverel(moveX, moveY) end)
        end
    end

    -- Triggerbot / AutoShoot
    if Config.AimbotTriggerbot or Config.AimbotAutoShoot then
        local now = tick()
        local interval = Config.AimbotTriggerbot and 0.12 or 0.05
        if now - LastShot > interval then
            Safe(function()
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
--   MOVEMENT (すべてCharacterが存在するかチェック)
-- ============================================================

-- Speed
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    if not Humanoid or not HumanoidRootPart then return end
    if Humanoid.MoveDirection.Magnitude > 0 then
        Safe(function()
            HumanoidRootPart.Velocity = Humanoid.MoveDirection * Config.SpeedValue + Vector3.new(0, HumanoidRootPart.Velocity.Y, 0)
        end)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Humanoid then
        Safe(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

-- Bunny Hop
RunService.Heartbeat:Connect(function()
    if Config.BunnyHop and Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.Landed then
        Safe(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not Config.NoclipEnabled then return end
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            Safe(function() part.CanCollide = false end)
        end
    end
end)

-- ============================================================
--   FLY (完全修正 + キャラクター再取得対応)
-- ============================================================
local FlyBV = nil
local FlyBG = nil
local FlyActive = false

function StartFly()
    Safe(StopFly)
    if not Character or not HumanoidRootPart then
        Debug("StartFly: No character/root")
        return false
    end
    local hum = Character:FindFirstChildOfClass("Humanoid")
    if not hum then
        Debug("StartFly: No humanoid")
        return false
    end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = HumanoidRootPart
    FlyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.CFrame = HumanoidRootPart.CFrame
    bg.Parent = HumanoidRootPart
    FlyBG = bg

    hum.PlatformStand = true
    FlyActive = true
    Debug("Fly started")
    return true
end

function StopFly()
    if FlyBV then Safe(function() FlyBV:Destroy() end); FlyBV = nil end
    if FlyBG then Safe(function() FlyBG:Destroy() end); FlyBG = nil end
    if Character and Humanoid then
        Safe(function() Humanoid.PlatformStand = false end)
    end
    FlyActive = false
    Debug("Fly stopped")
end

-- Fly更新 (Characterが変わっても動作)
RunService.RenderStepped:Connect(function()
    if not Config.FlyEnabled then
        if FlyActive then Safe(StopFly) end
        return
    end

    -- キャラクターが存在しない場合、再取得を試みる
    if not Character or not HumanoidRootPart then
        if not UpdateCharacter() then
            return
        end
    end

    -- Flyオブジェクトがない場合は再作成
    if (not FlyBV or not FlyBV.Parent) and HumanoidRootPart then
        Safe(StartFly)
        if not FlyBV or not FlyBV.Parent then return end
    end

    if not HumanoidRootPart or not FlyBV or not FlyBG then return end

    local move = Vector3.new()
    local cf = Camera.CFrame
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
--   COMBAT (KillAura, AutoHeal)
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
            Safe(function() hitRemote:FireServer(pl.Character or pl) end)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AutoHeal and Humanoid and Humanoid.Health < Humanoid.MaxHealth then
        Safe(function()
            Humanoid.Health = math.min(Humanoid.Health + Config.HealAmount, Humanoid.MaxHealth)
        end)
    end
end)

-- ============================================================
--   TELEPORT
-- ============================================================
local function TeleportToTarget()
    if not HumanoidRootPart then return end
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
        Safe(function()
            HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
        end)
    end
end

-- ============================================================
--   MISC (AntiAFK, NoFog, FullBright)
-- ============================================================
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

RunService.RenderStepped:Connect(function()
    if Config.NoFog then
        Safe(function()
            Lighting.FogStart = 1e6
            Lighting.FogEnd = 1e6
        end)
    end
    if Config.FullBright then
        Safe(function()
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
        Safe(StartFly)
        if RayfieldLoaded and Rayfield then
            Rayfield:Notify({Title = "⚡ RAGE", Content = "All max!", Duration = 3})
        end
    else
        if RayfieldLoaded and Rayfield then
            Rayfield:Notify({Title = "Rage OFF", Content = "Manual adjust", Duration = 2})
        end
    end
end

-- ============================================================
--   RAYFIELD UI
-- ============================================================
local Window = nil
if RayfieldLoaded and Rayfield then
    Safe(function()
        Window = Rayfield:CreateWindow({
            Name = "ZETA X",
            Icon = 0,
            LoadingTitle = "ZETA X",
            LoadingSubtitle = "Ultimate Final",
            Theme = "Default",
            ConfigurationSaving = { Enabled = false },
            KeySystem = false,
        })
    end)

    if Window then
        -- Rage
        local RageTab = Window:CreateTab("⚡ Rage", 4483362458)
        RageTab:CreateToggle({Name = "RAGE MODE", CurrentValue = Config.RageMode, Flag = "RageMode", Callback = function(v) Config.RageMode = v; if v then ApplyRageMode() end end})
        RageTab:CreateButton({Name = "Apply Rage", Callback = function() Config.RageMode = true; ApplyRageMode() end})
        RageTab:CreateButton({Name = "Reset All", Callback = function()
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
            Safe(StopFly)
            if Rayfield then Rayfield:Notify({Title = "Reset", Content = "Default", Duration = 2}) end
        end})

        -- Profiles
        local ProfileTab = Window:CreateTab("💾 Profiles", 4483362458)
        local ProfileNameInput = ""
        ProfileTab:CreateInput({Name = "Profile Name", PlaceholderText = "Enter name...", RemoveTextAfterFocusLost = false, Callback = function(t) ProfileNameInput = t end})
        ProfileTab:CreateButton({Name = "Save", Callback = function()
            if ProfileNameInput and ProfileNameInput ~= "" then SaveProfile(ProfileNameInput)
            else if Rayfield then Rayfield:Notify({Title = "Error", Content = "Enter name", Duration = 2}) end end
        end})
        ProfileTab:CreateButton({Name = "Load", Callback = function()
            if ProfileNameInput and ProfileNameInput ~= "" then
                if LoadProfile(ProfileNameInput) then
                    if Rayfield then Rayfield:Notify({Title = "Loaded", Content = ProfileNameInput, Duration = 2}) end
                else
                    if Rayfield then Rayfield:Notify({Title = "Error", Content = "Not found", Duration = 2}) end
                end
            end
        end})
        ProfileTab:CreateButton({Name = "Delete", Callback = function()
            if ProfileNameInput and ProfileNameInput ~= "" and ProfileNameInput ~= "Default" then
                Safe(function() if delfile then delfile(GetProfilePath(ProfileNameInput)) end end)
                if Rayfield then Rayfield:Notify({Title = "Deleted", Content = ProfileNameInput, Duration = 2}) end
            end
        end})
        ProfileTab:CreateButton({Name = "Refresh", Callback = function()
            local list = GetProfileList()
            if Rayfield then Rayfield:Notify({Title = "Profiles", Content = table.concat(list, ", "), Duration = 4}) end
        end})
        ProfileTab:CreateButton({Name = "Load Default", Callback = function() LoadProfile("Default"); if Rayfield then Rayfield:Notify({Title = "Loaded", Content = "Default", Duration = 2}) end end})

        -- Aimbot
        local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
        AimbotTab:CreateToggle({Name = "Enable", CurrentValue = Config.AimbotEnabled, Flag = "AimbotEnabled", Callback = function(v) Config.AimbotEnabled = v; if FOVCircle then FOVCircle.Visible = v end end})
        AimbotTab:CreateToggle({Name = "Team Check", CurrentValue = Config.AimbotTeamCheck, Flag = "AimbotTeamCheck", Callback = function(v) Config.AimbotTeamCheck = v end})
        AimbotTab:CreateToggle({Name = "Vis Check", CurrentValue = Config.AimbotVisCheck, Flag = "AimbotVisCheck", Callback = function(v) Config.AimbotVisCheck = v end})
        AimbotTab:CreateToggle({Name = "Triggerbot", CurrentValue = Config.AimbotTriggerbot, Flag = "AimbotTriggerbot", Callback = function(v) Config.AimbotTriggerbot = v end})
        AimbotTab:CreateToggle({Name = "Auto Shoot", CurrentValue = Config.AimbotAutoShoot, Flag = "AimbotAutoShoot", Callback = function(v) Config.AimbotAutoShoot = v end})
        AimbotTab:CreateDropdown({Name = "Mode", Options = {"Sticky (Lock)", "Normal (Mouse)"}, CurrentOption = {Config.AimbotMode == "Sticky" and "Sticky (Lock)" or "Normal (Mouse)"}, Flag = "AimbotModeDropdown", Callback = function(v)
            Config.AimbotMode = v[1] == "Sticky (Lock)" and "Sticky" or "Normal"
        end})
        AimbotTab:CreateSlider({Name = "FOV", Range = {10, 400}, Increment = 5, Suffix = "px", CurrentValue = Config.AimbotFOV, Flag = "AimbotFOV", Callback = function(v) Config.AimbotFOV = v; if FOVCircle then FOVCircle.Radius = v end end})
        AimbotTab:CreateSlider({Name = "Smoothing", Range = {0.05, 0.9}, Increment = 0.05, Suffix = "", CurrentValue = Config.AimbotSmoothing, Flag = "AimbotSmoothing", Callback = function(v) Config.AimbotSmoothing = v end})
        AimbotTab:CreateSlider({Name = "Sticky Strength", Range = {0.5, 1.0}, Increment = 0.05, Suffix = "", CurrentValue = Config.AimbotStickyStrength, Flag = "AimbotStickyStrength", Callback = function(v) Config.AimbotStickyStrength = v end})
        AimbotTab:CreateSlider({Name = "Max Angle", Range = {2, 30}, Increment = 1, Suffix = "°", CurrentValue = Config.AimbotMaxAngle, Flag = "AimbotMaxAngle", Callback = function(v) Config.AimbotMaxAngle = v end})
        AimbotTab:CreateDropdown({Name = "Bone", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {Config.AimbotBone}, Flag = "AimbotBone", Callback = function(v) Config.AimbotBone = v[1] end})

        -- ESP
        local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
        ESPTab:CreateToggle({Name = "Enable", CurrentValue = Config.ESPEnabled, Flag = "ESPEnabled", Callback = function(v) Config.ESPEnabled = v; if not v then for pl in pairs(ESPObjects) do Safe(RemoveESP, pl) end end end})
        ESPTab:CreateToggle({Name = "Boxes", CurrentValue = Config.ESPBoxes, Flag = "ESPBoxes", Callback = function(v) Config.ESPBoxes = v end})
        ESPTab:CreateToggle({Name = "Names", CurrentValue = Config.ESPNames, Flag = "ESPNames", Callback = function(v) Config.ESPNames = v end})
        ESPTab:CreateToggle({Name = "Distance", CurrentValue = Config.ESPDistance, Flag = "ESPDistance", Callback = function(v) Config.ESPDistance = v end})
        ESPTab:CreateToggle({Name = "Tracers", CurrentValue = Config.ESPTracers, Flag = "ESPTracers", Callback = function(v) Config.ESPTracers = v end})
        ESPTab:CreateToggle({Name = "Health Bar", CurrentValue = Config.ESPHealthBar, Flag = "ESPHealthBar", Callback = function(v) Config.ESPHealthBar = v end})
        ESPTab:CreateToggle({Name = "Team Color", CurrentValue = Config.ESPTeamColor, Flag = "ESPTeamColor", Callback = function(v) Config.ESPTeamColor = v end})
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

        -- Combat
        local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
        CombatTab:CreateToggle({Name = "Kill Aura", CurrentValue = Config.KillAura, Flag = "KillAura", Callback = function(v) Config.KillAura = v end})
        CombatTab:CreateSlider({Name = "Range", Range = {5, 100}, Increment = 1, Suffix = "studs", CurrentValue = Config.KillAuraRange, Flag = "KillAuraRange", Callback = function(v) Config.KillAuraRange = v end})
        CombatTab:CreateToggle({Name = "Auto Heal", CurrentValue = Config.AutoHeal, Flag = "AutoHeal", Callback = function(v) Config.AutoHeal = v end})
        CombatTab:CreateSlider({Name = "Heal Amount", Range = {5, 50}, Increment = 1, Suffix = "HP", CurrentValue = Config.HealAmount, Flag = "HealAmount", Callback = function(v) Config.HealAmount = v end})

        -- Misc
        local MiscTab = Window:CreateTab("🔧 Misc", 4483362458)
        MiscTab:CreateToggle({Name = "Anti-AFK", CurrentValue = Config.AntiAFK, Flag = "AntiAFK", Callback = function(v) Config.AntiAFK = v end})
        MiscTab:CreateToggle({Name = "No Fog", CurrentValue = Config.NoFog, Flag = "NoFog", Callback = function(v) Config.NoFog = v end})
        MiscTab:CreateToggle({Name = "Full Bright", CurrentValue = Config.FullBright, Flag = "FullBright", Callback = function(v) Config.FullBright = v end})
        MiscTab:CreateButton({Name = "Teleport to Enemy", Callback = TeleportToTarget})
        MiscTab:CreateButton({Name = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, LP) end})
        MiscTab:CreateButton({Name = "Respawn", Callback = function() LP:LoadCharacter() end})

        Rayfield:Notify({
            Title = "💙💜 ZETA X FINAL",
            Content = "Match-switch stable | All features persistent",
            Duration = 5,
        })
    end
else
    pcall(function()
        CoreGui:SetCore("SendNotification", {
            Title = "ZETA X FINAL",
            Text = "Loaded | Match-switch stable",
            Duration = 5,
        })
    end)
end

-- ============================================================
--   メニュー表示切替 (Insertのみ)
-- ============================================================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        if Window and Window.Visible ~= nil then
            Window.Visible = not Window.Visible
        end
    end
end)

-- ============================================================
--   初期化完了
-- ============================================================
Debug("ZETA X FINAL loaded. Insert toggles menu.")
Debug("All features persistent across matches.")

while true do wait(10) end
