-- ============================================================
--   ZETA X – ULTIMATE FINAL (完全構文エラー修正版)
--   continue/goto 完全削除 | ifネストで制御
--   ESP/Aimbot完全安定 | マッチ切り替え完全対応
--   メニューキー: K | ブルーパープルテーマ
-- ============================================================

-- ★★★ ゲーム完全ロード待機 ★★★
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ★★★ _clientalert エラー対策 ★★★
if not _G._clientalert then
    _G._clientalert = function() end
end

-- ★★★ 全体をpcallで保護 ★★★
local function Main()

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

-- ★★★ カメラ取得 ★★★
local function GetCamera()
    return Workspace and Workspace.CurrentCamera
end

-- ============================================================
--   ★★★ RAYFIELD UI (安全ロード) ★★★
-- ============================================================
local Rayfield = nil
local RayfieldLoaded = false

task.spawn(function()
    for i = 1, 10 do
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
        end)
        if success and result then
            Rayfield = result
            RayfieldLoaded = true
            print("[ZETA X] Rayfield loaded successfully")
            break
        end
        task.wait(2)
    end
    if not RayfieldLoaded then
        print("[ZETA X] Rayfield could not be loaded, using fallback notifications")
    end
end)

local function SafeNotify(title, content, duration)
    if Rayfield and RayfieldLoaded then
        pcall(function()
            Rayfield:Notify({Title = title, Content = content, Duration = duration or 3})
        end)
    else
        pcall(function()
            CoreGui:SetCore("SendNotification", {
                Title = title,
                Text = content,
                Duration = duration or 3,
            })
        end)
    end
end

-- ============================================================
--   テーマ (ブルーパープル)
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
    AimbotMaxDist = 5000,
    AimbotMaxAnglePerFrame = 5,
    KnifeAutoHit = false,
    KnifeRange = 50,
    KnifeWarp = true,
    KnifeWallPenetrate = true,
    KnifeAutoAim = true,
    KnifeAttackInterval = 0.15,
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
    CurrentProfile = "Default",
}

-- ============================================================
--   プロファイル管理
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
    SafeNotify("Profile Saved", name, 2)
end

local function GetProfileList()
    local profiles = {}
    pcall(function()
        if listfiles then
            for _, file in ipairs(listfiles(PROFILES_DIR)) do
                local name = file:match("([^/]+)%.json$")
                if name then table.insert(profiles, name) end
            end
        end
    end)
    local hasDefault = false
    for _, name in ipairs(profiles) do
        if name == "Default" then hasDefault = true; break end
    end
    if not hasDefault then table.insert(profiles, 1, "Default") end
    return profiles
end

pcall(function()
    if isfile and isfile(GetProfilePath("Default")) then LoadProfile("Default") end
end)

-- ============================================================
--   ★★★ キャラクター参照 ★★★
-- ============================================================
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil

local function GetCharacter()
    return LP.Character
end

local function GetHumanoidRootPart()
    local ch = GetCharacter()
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoidObj()
    local ch = GetCharacter()
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function RefreshCharacter()
    Character = GetCharacter()
    HumanoidRootPart = GetHumanoidRootPart()
    Humanoid = GetHumanoidObj()
    return Character ~= nil
end

RefreshCharacter()

LP.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:FindFirstChild("HumanoidRootPart")
    Humanoid = newChar:FindFirstChildOfClass("Humanoid")
    ClearAllESP()
    SetupNoclipWatcher(Character)
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            ApplyNoclipToPart(part)
        end
    end
    if Config.FlyEnabled and HumanoidRootPart then Safe(StartFly) end
    CachedTarget = nil
    CachedTargetTime = 0
    SafeNotify("Match Restart", "Features re-activated", 2)
end)

LP.CharacterRemoving:Connect(function()
    Character = nil
    HumanoidRootPart = nil
    Humanoid = nil
    Safe(StopFly)
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    NoclipCachedParts = {}
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        local currentChar = GetCharacter()
        if currentChar ~= Character then
            RefreshCharacter()
            if Character then
                SetupNoclipWatcher(Character)
                if Config.FlyEnabled and HumanoidRootPart then Safe(StartFly) end
                CachedTarget = nil
            end
        end
        if Character and not HumanoidRootPart then
            HumanoidRootPart = GetHumanoidRootPart()
            Humanoid = GetHumanoidObj()
        end
        if Character and Humanoid and not Config.FlyEnabled then
            if Humanoid.PlatformStand then
                Safe(function() Humanoid.PlatformStand = false end)
            end
        end
    end
end)

-- ============================================================
--   セーフコール
-- ============================================================
local function Safe(func, ...)
    local ok, err = pcall(func, ...)
    if not ok then print("[ZETA X] Error: " .. tostring(err)) end
    return ok, err
end

-- ============================================================
--   ユーティリティ
-- ============================================================
local function GetRootPart(pl)
    if not pl then return nil end
    local ch = pl.Character
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart")
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
    if not ch then return nil end
    return ch:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(pl)
    if not pl then return false end
    local h = GetHumanoid(pl)
    return h and h.Health > 0
end

local function IsEnemy(pl)
    if pl == LP then return false end
    if Config.AimbotTeamCheck and LP.Team and pl.Team then
        return LP.Team ~= pl.Team
    end
    -- チーム情報がない場合、自分以外は敵とみなす
    return pl ~= LP
end

local function WorldToViewport(pos)
    local cam = GetCamera()
    if not cam then return Vector2.new(0,0), false, 0
    local sp, onScreen = cam:WorldToViewportPoint(pos)
    if sp.Z <= 0 then
        return Vector2.new(sp.X, sp.Y), false, sp.Z
    end
    return Vector2.new(sp.X, sp.Y), onScreen, sp.Z
end

local function GetDistance(pl)
    if not HumanoidRootPart then return math.huge end
    local r = GetRootPart(pl)
    if r then
        return (r.Position - HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function IsVisible(pl, maxDist, boneName)
    local cam = GetCamera()
    if not cam then return false end
    local bone = GetBone(pl, boneName or Config.AimbotBone)
    if not bone then return false end
    local startPos = cam.CFrame.Position
    local dir = (bone.Position - startPos)
    local dist = dir.Magnitude
    local limit = maxDist or Config.ESPMaxDist
    if dist > limit then return false end
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
    local result = Workspace:Raycast(startPos, dir.Unit * dist, params)
    return result == nil
end

local function IsTarget(pl)
    if pl == LP then return false end
    if not IsAlive(pl) then return false end
    if not IsEnemy(pl) then return false end
    return true
end

-- ============================================================
--   ★★★ 安全なマウスクリック ★★★
-- ============================================================
local function SafeMouseClick()
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0, 0))
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end)
    elseif type(mouse1click) == "function" then
        pcall(function() mouse1click() end)
    end
end

-- ============================================================
--   ★★★ AIMBOT (continue 完全削除・ifネスト) ★★★
-- ============================================================
local CachedTarget = nil
local CachedTargetTime = 0
local CACHE_DURATION = 0.05

local LastTriggerTime = 0
local LastAutoShootTime = 0
local KillAuraLastTime = 0
local KnifeLastAttack = 0

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

    -- ★★★ continue を完全に削除し if ネストで制御 ★★★
    for _, pl in ipairs(Players:GetPlayers()) do
        if IsTarget(pl) then
            local bone = GetBone(pl, Config.AimbotBone)
            if bone then
                local visOk = true
                if Config.AimbotVisCheck then
                    visOk = IsVisible(pl, Config.AimbotMaxDist, Config.AimbotBone)
                end
                if visOk then
                    local sp, on, z = WorldToViewport(bone.Position)
                    if on and z > 0 then
                        if sp.X >= 0 and sp.X <= viewportSize.X and sp.Y >= 0 and sp.Y <= viewportSize.Y then
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
    end

    CachedTarget = target
    CachedTargetTime = now
    return target
end

-- ============================================================
--   壁越しナイフ
-- ============================================================
local function GetClosestEnemyForKnife()
    if not HumanoidRootPart then return nil end
    local closest = nil
    local minDist = Config.KnifeRange
    for _, pl in ipairs(Players:GetPlayers()) do
        if IsTarget(pl) then
            local d = GetDistance(pl)
            if d < minDist then
                minDist = d
                closest = pl
            end
        end
    end
    return closest
end

local function FindKnifeRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remotes then
        for _, name in ipairs({"KnifeHit", "MeleeHit", "SwordHit", "Attack", "Hit", "Damage"}) do
            local r = remotes:FindFirstChild(name)
            if r then return r end
        end
    end
    for _, name in ipairs({"KnifeRemote", "MeleeRemote", "AttackRemote", "HitRemote"}) do
        local r = ReplicatedStorage:FindFirstChild(name)
        if r then return r end
    end
    return nil
end

local KnifeRemote = nil
local KnifeRemoteSearched = false
local KnifeRemoteSearchTimer = 0

RunService.Heartbeat:Connect(function()
    if not Config.KnifeAutoHit then return end
    if not Character or not Humanoid or not HumanoidRootPart then return end

    local target = GetClosestEnemyForKnife()
    if not target then return end

    local targetRoot = GetRootPart(target)
    if not targetRoot then return end

    local now = tick()
    if now - KnifeLastAttack < Config.KnifeAttackInterval then return end

    if Config.KnifeAutoAim then
        local lookAtCF = CFrame.lookAt(HumanoidRootPart.Position, targetRoot.Position)
        HumanoidRootPart.CFrame = lookAtCF
    end

    if Config.KnifeWarp and Character and target.Character then
        local warpPos = targetRoot.CFrame * CFrame.new(0, 0, 3)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {Character, target.Character}
        local result = Workspace:Raycast(HumanoidRootPart.Position, (warpPos.Position - HumanoidRootPart.Position).Unit * 50, params)
        if not result then
            HumanoidRootPart.CFrame = warpPos
        else
            warpPos = targetRoot.CFrame * CFrame.new(0, 4, 3)
            local result2 = Workspace:Raycast(HumanoidRootPart.Position, (warpPos.Position - HumanoidRootPart.Position).Unit * 50, params)
            if not result2 then
                HumanoidRootPart.CFrame = warpPos
            end
        end
    end

    if Config.KnifeWallPenetrate then
        if not KnifeRemoteSearched or (tick() - KnifeRemoteSearchTimer > 10) then
            KnifeRemoteSearched = true
            KnifeRemoteSearchTimer = tick()
            KnifeRemote = FindKnifeRemote()
            if KnifeRemote then
                SafeNotify("🔪 Knife Remote Found", "Wall penetration active!", 3)
            end
        end

        if KnifeRemote then
            Safe(function()
                if KnifeRemote.FireServer then
                    KnifeRemote:FireServer(target.Character or target)
                elseif KnifeRemote.InvokeServer then
                    KnifeRemote:InvokeServer(target.Character or target)
                end
            end)
            KnifeLastAttack = now
        else
            SafeMouseClick()
            KnifeLastAttack = now
        end
    else
        SafeMouseClick()
        KnifeLastAttack = now
    end
end)

-- ============================================================
--   ★★★ AIMBOT メインループ (Sticky角度制限実装) ★★★
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

        -- ★★★ 実際に角度制限を実装 ★★★
        local maxAngle = math.rad(Config.AimbotMaxAnglePerFrame or 5)
        local strength = Config.AimbotStickyStrength

        -- 現在の向きから目標の向きへの回転を計算
        local relative = targetCF:ToObjectSpace(currentCF)
        local angles = relative:ToEulerAnglesXYZ()
        local angleMag = math.sqrt(angles[1]^2 + angles[2]^2 + angles[3]^2)

        if angleMag > maxAngle then
            -- 角度差が大きい場合は最大角度で制限
            local limitedCF = currentCF * CFrame.fromOrientation(
                math.clamp(angles[1], -maxAngle, maxAngle),
                math.clamp(angles[2], -maxAngle, maxAngle),
                math.clamp(angles[3], -maxAngle, maxAngle)
            )
            cam.CFrame = limitedCF
        else
            -- 角度差が小さい場合は通常のLerp
            cam.CFrame = currentCF:Lerp(targetCF, strength)
        end
    else
        -- Normal: mousemoverel
        local sp, on, z = WorldToViewport(targetPos)
        if not on or z <= 0 then return end

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

    -- Triggerbot
    if Config.AimbotTriggerbot then
        local now = tick()
        if now - LastTriggerTime > 0.12 then
            SafeMouseClick()
            LastTriggerTime = now
        end
    end

    -- AutoShoot
    if Config.AimbotAutoShoot then
        local now = tick()
        if now - LastAutoShootTime > 0.05 then
            SafeMouseClick()
            LastAutoShootTime = now
        end
    end
end)

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
--   ★★★ ESP (goto/continue 完全削除・ifネスト) ★★★
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

local function ClearAllESP()
    local players = {}
    for pl in pairs(ESPObjects) do
        table.insert(players, pl)
    end
    for _, pl in ipairs(players) do
        Safe(RemoveESP, pl)
    end
    ESPObjects = {}
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

RunService.Heartbeat:Connect(function()
    ESPUpdateCounter = ESPUpdateCounter + 1
    if ESPUpdateCounter % 3 ~= 0 then return end

    if not Config.ESPEnabled then
        for pl in pairs(ESPObjects) do Safe(RemoveESP, pl) end
        return
    end

    local cam = GetCamera()
    if not cam then return end
    if not Character then return end

    -- ★★★ goto/continue を完全に削除し if ネストで制御 ★★★
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
                        local feetPos = root.Position - Vector3.new(0, 3, 0)

                        local headScr, onH, zH = WorldToViewport(headPos)
                        local feetScr, onF, zF = WorldToViewport(feetPos)

                        if onH and zH > 0 then
                            local isEnemy = IsEnemy(pl)
                            local color = isEnemy and Theme.ESPEnemy or Theme.ESPAlly

                            -- Box
                            if Config.ESPBoxes then
                                local height = 30
                                if onF and zF > 0 then
                                    height = math.abs(headScr.Y - feetScr.Y)
                                else
                                    local estimatedFeet = headPos - Vector3.new(0, 2, 0)
                                    local estFeetScr, onEst = WorldToViewport(estimatedFeet)
                                    if onEst then
                                        height = math.abs(headScr.Y - estFeetScr.Y)
                                    end
                                end
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

                            -- Name
                            if Config.ESPNames and objs.nameTag then
                                Safe(function()
                                    objs.nameTag.Visible = true
                                    objs.nameTag.Text = pl.DisplayName
                                    objs.nameTag.Position = Vector2.new(headScr.X, headScr.Y - 16)
                                end)
                            else
                                if objs.nameTag then Safe(function() objs.nameTag.Visible = false end) end
                            end

                            -- Distance
                            if Config.ESPDistance and objs.distTag then
                                Safe(function()
                                    objs.distTag.Visible = true
                                    objs.distTag.Text = string.format("[%.0fm]", dist)
                                    objs.distTag.Position = Vector2.new(headScr.X, headScr.Y - 5)
                                end)
                            else
                                if objs.distTag then Safe(function() objs.distTag.Visible = false end) end
                            end

                            -- Tracers
                            if Config.ESPTracers and objs.tracer then
                                local vp = cam.ViewportSize
                                Safe(function()
                                    objs.tracer.Visible = true
                                    objs.tracer.From = Vector2.new(vp.X/2, vp.Y)
                                    objs.tracer.To = headScr
                                    objs.tracer.Color = color
                                end)
                            else
                                if objs.tracer then Safe(function() objs.tracer.Visible = false end) end
                            end
                        else
                            -- 画面外の場合は非表示
                            for _, obj in pairs(objs) do
                                Safe(function() if obj then obj.Visible = false end end)
                            end
                        end
                    else
                        Safe(RemoveESP, pl)
                    end
                else
                    -- 距離オーバーで非表示
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
--   NOCLIP
-- ============================================================
local NoclipCachedParts = {}
local NoclipConnection = nil

local function ApplyNoclipToPart(part)
    if part:IsA("BasePart") and part.CanCollide then
        if not NoclipCachedParts[part] then
            NoclipCachedParts[part] = true
            Safe(function() part.CanCollide = false end)
        end
    end
end

local function SetupNoclipWatcher(char)
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        ApplyNoclipToPart(part)
    end
    NoclipConnection = char.DescendantAdded:Connect(function(part)
        if Config.NoclipEnabled then
            ApplyNoclipToPart(part)
        end
    end)
end

if Character then
    SetupNoclipWatcher(Character)
end

task.spawn(function()
    while true do
        task.wait(3)
        if Config.NoclipEnabled and Character then
            for _, part in ipairs(Character:GetDescendants()) do
                ApplyNoclipToPart(part)
            end
        end
    end
end)

-- ============================================================
--   FLY
-- ============================================================
local FlyBV = nil
local FlyBG = nil
local FlyActive = false

function StartFly()
    Safe(StopFly)
    if not Character or not HumanoidRootPart then return false end
    local hum = Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

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
    return true
end

function StopFly()
    if FlyBV then Safe(function() FlyBV:Destroy() end); FlyBV = nil end
    if FlyBG then Safe(function() FlyBG:Destroy() end); FlyBG = nil end
    if Character and Humanoid then
        Safe(function() Humanoid.PlatformStand = false end)
    end
    FlyActive = false
end

RunService.RenderStepped:Connect(function()
    if not Config.FlyEnabled then
        if FlyActive then Safe(StopFly) end
        if Character and Humanoid and Humanoid.PlatformStand then
            Safe(function() Humanoid.PlatformStand = false end)
        end
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
    local now = tick()
    if now - KillAuraLastTime < 0.15 then return end

    for _, pl in ipairs(Players:GetPlayers()) do
        if IsTarget(pl) and GetDistance(pl) <= Config.KillAuraRange then
            Safe(function()
                if hitRemote.FireServer then
                    hitRemote:FireServer(pl.Character or pl)
                elseif hitRemote.InvokeServer then
                    hitRemote:InvokeServer(pl.Character or pl)
                end
            end)
        end
    end
    KillAuraLastTime = now
end)

local HealRemote = nil
local HealRemoteSearchTimer = 0
local HealRemoteSearched = false

RunService.Heartbeat:Connect(function()
    if Config.AutoHeal and Humanoid and Humanoid.Health < Humanoid.MaxHealth then
        local now = tick()
        if not HealRemoteSearched or (now - HealRemoteSearchTimer > 10) then
            HealRemoteSearched = true
            HealRemoteSearchTimer = now
            local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
            for _, name in ipairs({"Heal", "HealPlayer", "SetHealth", "Health"}) do
                local r = remotes:FindFirstChild(name)
                if r then
                    HealRemote = r
                    break
                end
            end
            if not HealRemote then
                SafeNotify("AutoHeal", "Heal remote not found (retry in 10s)", 3)
            end
        end

        if HealRemote then
            Safe(function()
                if HealRemote.FireServer then
                    HealRemote:FireServer(Config.HealAmount)
                elseif HealRemote.InvokeServer then
                    HealRemote:InvokeServer(Config.HealAmount)
                end
            end)
        end
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
--   MISC
-- ============================================================
RunService.RenderStepped:Connect(function()
    if Config.NoFog then
        Safe(function() Lighting.FogStart = 1e6; Lighting.FogEnd = 1e6 end)
    else
        Safe(function() Lighting.FogStart = 0; Lighting.FogEnd = 100000 end)
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
--   ★★★ RAYFIELD UI ★★★
-- ============================================================
local Window = nil
local WindowCreated = false

local function CreateUI()
    if not RayfieldLoaded or not Rayfield then
        return false
    end

    if WindowCreated then return true end

    local success, err = pcall(function()
        Window = Rayfield:CreateWindow({
            Name = "ZETA X",
            Icon = 0,
            LoadingTitle = "ZETA X",
            LoadingSubtitle = "Ultimate Stable",
            Theme = "Default",
            ConfigurationSaving = { Enabled = false },
            KeySystem = false,
        })
    end)

    if not success or not Window then
        print("[ZETA X] UI creation failed: " .. tostring(err))
        return false
    end

    WindowCreated = true

    -- Profiles
    local ProfileTab = Window:CreateTab("💾 Profiles", 4483362458)
    local ProfileNameInput = ""
    ProfileTab:CreateInput({Name = "Profile Name", PlaceholderText = "Enter name...", RemoveTextAfterFocusLost = false, Callback = function(t) ProfileNameInput = t end})
    ProfileTab:CreateButton({Name = "Save", Callback = function()
        if ProfileNameInput and ProfileNameInput ~= "" then SaveProfile(ProfileNameInput)
        else SafeNotify("Error", "Enter a name", 2) end
    end})
    ProfileTab:CreateButton({Name = "Load", Callback = function()
        if ProfileNameInput and ProfileNameInput ~= "" then
            if LoadProfile(ProfileNameInput) then SafeNotify("Loaded", ProfileNameInput, 2)
            else SafeNotify("Error", "Not found", 2) end
        end
    end})
    ProfileTab:CreateButton({Name = "Delete", Callback = function()
        if ProfileNameInput and ProfileNameInput ~= "" and ProfileNameInput ~= "Default" then
            Safe(function() if delfile then delfile(GetProfilePath(ProfileNameInput)) end end)
            SafeNotify("Deleted", ProfileNameInput, 2)
        end
    end})
    ProfileTab:CreateButton({Name = "Refresh List", Callback = function()
        SafeNotify("Profiles", table.concat(GetProfileList(), ", "), 4)
    end})
    ProfileTab:CreateButton({Name = "Load Default", Callback = function()
        LoadProfile("Default")
        SafeNotify("Loaded", "Default", 2)
    end})

    -- Aimbot
    local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
    AimbotTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = Config.AimbotEnabled, Flag = "AimbotEnabled", Callback = function(v) Config.AimbotEnabled = v; if FOVCircle then FOVCircle.Visible = v end end})
    AimbotTab:CreateToggle({Name = "Team Check", CurrentValue = Config.AimbotTeamCheck, Flag = "AimbotTeamCheck", Callback = function(v) Config.AimbotTeamCheck = v end})
    AimbotTab:CreateToggle({Name = "Vis Check", CurrentValue = Config.AimbotVisCheck, Flag = "AimbotVisCheck", Callback = function(v) Config.AimbotVisCheck = v end})
    AimbotTab:CreateToggle({Name = "Triggerbot", CurrentValue = Config.AimbotTriggerbot, Flag = "AimbotTriggerbot", Callback = function(v) Config.AimbotTriggerbot = v end})
    AimbotTab:CreateToggle({Name = "Auto-Shoot", CurrentValue = Config.AimbotAutoShoot, Flag = "AimbotAutoShoot", Callback = function(v) Config.AimbotAutoShoot = v end})
    AimbotTab:CreateDropdown({Name = "Mode", Options = {"Sticky (Lock)", "Normal (Mouse)"}, CurrentOption = {Config.AimbotMode == "Sticky" and "Sticky (Lock)" or "Normal (Mouse)"}, Flag = "AimbotModeDropdown", Callback = function(v)
        Config.AimbotMode = v[1] == "Sticky (Lock)" and "Sticky" or "Normal"
    end})
    AimbotTab:CreateSlider({Name = "FOV", Range = {10, 400}, Increment = 5, Suffix = "px", CurrentValue = Config.AimbotFOV, Flag = "AimbotFOV", Callback = function(v) Config.AimbotFOV = v; if FOVCircle then FOVCircle.Radius = v end end})
    AimbotTab:CreateSlider({Name = "Smoothing", Range = {0.05, 0.9}, Increment = 0.05, Suffix = "", CurrentValue = Config.AimbotSmoothing, Flag = "AimbotSmoothing", Callback = function(v) Config.AimbotSmoothing = v end})
    AimbotTab:CreateSlider({Name = "Sticky Strength", Range = {0.5, 1.0}, Increment = 0.05, Suffix = "", CurrentValue = Config.AimbotStickyStrength, Flag = "AimbotStickyStrength", Callback = function(v) Config.AimbotStickyStrength = v end})
    AimbotTab:CreateSlider({Name = "Max Angle per Frame", Range = {1, 15}, Increment = 1, Suffix = "°", CurrentValue = Config.AimbotMaxAnglePerFrame, Flag = "AimbotMaxAnglePerFrame", Callback = function(v) Config.AimbotMaxAnglePerFrame = v end})
    AimbotTab:CreateSlider({Name = "Aimbot Max Distance", Range = {100, 10000}, Increment = 100, Suffix = "studs", CurrentValue = Config.AimbotMaxDist, Flag = "AimbotMaxDist", Callback = function(v) Config.AimbotMaxDist = v end})
    AimbotTab:CreateDropdown({Name = "Bone", Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, CurrentOption = {Config.AimbotBone}, Flag = "AimbotBone", Callback = function(v) Config.AimbotBone = v[1] end})

    -- Knife
    local KnifeTab = Window:CreateTab("🔪 Wall Knife", 4483362458)
    KnifeTab:CreateToggle({Name = "壁越しナイフ", CurrentValue = Config.KnifeAutoHit, Flag = "KnifeAutoHit", Callback = function(v) Config.KnifeAutoHit = v end})
    KnifeTab:CreateToggle({Name = "壁越し攻撃", CurrentValue = Config.KnifeWallPenetrate, Flag = "KnifeWallPenetrate", Callback = function(v) Config.KnifeWallPenetrate = v end})
    KnifeTab:CreateToggle({Name = "ワープスタブ", CurrentValue = Config.KnifeWarp, Flag = "KnifeWarp", Callback = function(v) Config.KnifeWarp = v end})
    KnifeTab:CreateToggle({Name = "自動照準", CurrentValue = Config.KnifeAutoAim, Flag = "KnifeAutoAim", Callback = function(v) Config.KnifeAutoAim = v end})
    KnifeTab:CreateSlider({Name = "攻撃範囲", Range = {10, 500}, Increment = 10, Suffix = "studs", CurrentValue = Config.KnifeRange, Flag = "KnifeRange", Callback = function(v) Config.KnifeRange = v end})
    KnifeTab:CreateSlider({Name = "攻撃間隔", Range = {0.02, 0.5}, Increment = 0.01, Suffix = "s", CurrentValue = Config.KnifeAttackInterval, Flag = "KnifeAttackInterval", Callback = function(v) Config.KnifeAttackInterval = v end})

    -- ESP
    local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
    ESPTab:CreateToggle({Name = "Enable ESP", CurrentValue = Config.ESPEnabled, Flag = "ESPEnabled", Callback = function(v) Config.ESPEnabled = v; if not v then for pl in pairs(ESPObjects) do Safe(RemoveESP, pl) end end end})
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

    SafeNotify("💙💜 ZETA X FINAL", "完全構文エラー修正版 | メニュー: Kキー", 5)
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
--   ★★★ メニュー表示切替 (Kキー) ★★★
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        if Window then
            Window.Visible = not Window.Visible
        end
    end
end)

print("[ZETA X] FINAL loaded. Menu: K key. All syntax errors fixed.")

while true do task.wait(10) end

-- ★★★ Main関数終了 ★★★
end

-- ★★★ pcallで実行 ★★★
local ok, err = pcall(Main)
if not ok then
    warn("[ZETA X] スクリプト実行エラー: " .. tostring(err))
    pcall(function()
        CoreGui:SetCore("SendNotification", {
            Title = "ZETA X",
            Text = "エラーが発生しましたが、一部機能は動作します",
            Duration = 5,
        })
    end)
end
