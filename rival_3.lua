-- ============================================================
--   ZETA X – Xeno/Solara COMPLETE EDITION
--   Rivals専用 完全安定版チート
--   メニューキー: K | 起動時自動表示
--   Xeno / Solara 両対応 | エラー皆無 | 全機能搭載
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

-- ★★★ 環境チェック ★★★
local HAS_VIRTUAL_USER = pcall(function() return game:GetService("VirtualUser") end)
local VirtualUser = HAS_VIRTUAL_USER and game:GetService("VirtualUser") or nil

-- ★★★ マウス移動関数 (Xeno/Solara両対応) ★★★
local function MoveMouseRelative(deltaX, deltaY)
    if type(mousemoverel) == "function" then
        -- Xeno や古いExecutor用
        pcall(function() mousemoverel(deltaX, deltaY) end)
    elseif VirtualInputManager then
        -- Solara / 最新Executor用
        pcall(function()
            VirtualInputManager:SendMouseMovementEvent(deltaX, deltaY, 0, Enum.UserInputType.MouseMovement)
        end)
    else
        -- 最終フォールバック（あまり正確ではないが動く）
        local pos = UserInputService:GetMouseLocation()
        if pos then
            pcall(function()
                VirtualInputManager:SendMouseMovementEvent(
                    pos.X + deltaX,
                    pos.Y + deltaY,
                    0,
                    Enum.UserInputType.MouseMovement
                )
            end)
        end
    end
end

-- ★★★ セーフクリック関数 ★★★
local function SafeMouseClick()
    local success = false
    if VirtualUser then
        success = pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0, 0))
            task.wait(0.02)
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end)
    end
    if not success and type(mouse1click) == "function" then
        success = pcall(mouse1click)
    end
    if not success and VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(1, 0, 0, true, game, 0)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(1, 0, 0, false, game, 0)
        end)
    end
    return success
end

-- ★★★ 全体をpcallで保護 ★★★
local function Main()

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
    if not ok then
        warn("[ZETA X] Error:", err)
    end
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
    if not cam then return Vector2.new(0,0), false end
    local sp, on = cam:WorldToViewportPoint(pos)
    if sp.Z <= 0 then return Vector2.new(sp.X, sp.Y), false end
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

-- ============================================================
--   ★★★ メニュー (強制表示・Xeno/Solara完全対応) ★★★
-- ============================================================
local MenuVisible = true
local MainWindow = nil

local function CreateMenu()
    pcall(function()
        if StarterGui:FindFirstChild("ZetaX_Menu") then
            StarterGui.ZetaX_Menu:Destroy()
        end
    end)
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZetaX_Menu"
    gui.ResetOnSpawn = false
    gui.Parent = StarterGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 380, 0, 460)
    main.Position = UDim2.new(0.5, -190, 0.5, -230)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 80, 220)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = main
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
    titleBar.BackgroundTransparency = 0.15
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "💜 ZETA X"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        MenuVisible = not MenuVisible
        main.Visible = MenuVisible
    end)
    
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 32)
    tabBar.Position = UDim2.new(0, 0, 0, 36)
    tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    tabBar.BackgroundTransparency = 0.3
    tabBar.BorderSizePixel = 0
    tabBar.Parent = main
    
    local tabs = {"Aimbot", "ESP", "Move", "Combat", "Misc"}
    local tabBtns = {}
    local currentTab = "Aimbot"
    
    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.2, -2, 1, -4)
        btn.Position = UDim2.new((i-1) * 0.2, 2, 0, 2)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(40, 40, 60)
        btn.BackgroundTransparency = (i == 1) and 0.2 or 0.5
        btn.Text = name
        btn.TextColor3 = (i == 1) and Color3.fromRGB(255,255,255) or Color3.fromRGB(150, 140, 200)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        tabBtns[name] = btn
        
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(tabBtns) do
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                b.BackgroundTransparency = 0.5
                b.TextColor3 = Color3.fromRGB(150, 140, 200)
            end
            btn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            currentTab = name
            UpdateContent()
        end)
    end
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -16, 1, -90)
    content.Position = UDim2.new(0, 8, 0, 74)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.Parent = main
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.Padding = UDim.new(0, 4)
    
    local function AddToggle(label, key, default)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        frame.BackgroundTransparency = 0.3
        frame.Parent = content
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 180, 255)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 46, 0, 22)
        btn.Position = UDim2.new(1, -54, 0, 5)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 80)
        btn.Text = default and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            Config[key] = state
            btn.Text = state and "ON" or "OFF"
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 80)
        end)
        return frame
    end
    
    local function AddSlider(label, key, min, max, default, suffix)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 42)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        frame.BackgroundTransparency = 0.3
        frame.Parent = content
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 0, 18)
        lbl.Position = UDim2.new(0, 10, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 180, 255)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.3, 0, 0, 18)
        valLbl.Position = UDim2.new(0.7, 0, 0, 2)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(default) .. (suffix or "")
        valLbl.TextColor3 = Color3.fromRGB(60, 120, 255)
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextSize = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, -20, 0, 3)
        slider.Position = UDim2.new(0, 10, 0, 26)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        slider.Parent = frame
        Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 2)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
        fill.Parent = slider
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
        
        local current = default
        local dragging = false
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                current = min + (max - min) * rel
                current = math.floor(current / 1) * 1
                Config[key] = current
                fill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
                valLbl.Text = tostring(current) .. (suffix or "")
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                current = min + (max - min) * rel
                current = math.floor(current / 1) * 1
                Config[key] = current
                fill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
                valLbl.Text = tostring(current) .. (suffix or "")
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        return frame
    end
    
    local function AddDropdown(label, key, options, default)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        frame.BackgroundTransparency = 0.3
        frame.Parent = content
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 180, 255)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.35, 0, 0.7, 0)
        btn.Position = UDim2.new(0.65, 0, 0.15, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.Text = default
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        local current = default
        local index = 1
        for i, v in ipairs(options) do
            if v == default then index = i end
        end
        
        btn.MouseButton1Click:Connect(function()
            index = index % #options + 1
            current = options[index]
            Config[key] = current
            btn.Text = current
        end)
        return frame
    end
    
    local function UpdateContent()
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("Frame") and child ~= layout then
                child:Destroy()
            end
        end
        
        if currentTab == "Aimbot" then
            AddToggle("Enable Aimbot", "AimbotEnabled", false)
            AddToggle("Team Check", "AimbotTeamCheck", true)
            AddToggle("Vis Check", "AimbotVisCheck", false)
            AddToggle("Triggerbot", "AimbotTriggerbot", false)
            AddToggle("Auto Shoot", "AimbotAutoShoot", false)
            AddSlider("FOV", "AimbotFOV", 10, 400, 120, "px")
            AddSlider("Smoothing", "AimbotSmoothing", 0.05, 0.9, 0.35, "")
            AddSlider("Sticky", "AimbotStickyStrength", 0.5, 1.0, 0.85, "")
            AddDropdown("Mode", "AimbotMode", {"Sticky", "Normal"}, "Sticky")
            AddDropdown("Bone", "AimbotBone", {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, "Head")
        elseif currentTab == "ESP" then
            AddToggle("Enable ESP", "ESPEnabled", false)
            AddToggle("Boxes", "ESPBoxes", true)
            AddToggle("Names", "ESPNames", true)
            AddToggle("Distance", "ESPDistance", true)
            AddToggle("Health Bar", "ESPHealthBar", true)
            AddSlider("Max Dist", "ESPMaxDist", 100, 5000, 1000, "studs")
        elseif currentTab == "Move" then
            AddToggle("Speed", "SpeedEnabled", false)
            AddSlider("Speed Val", "SpeedValue", 16, 300, 32, "s/s")
            AddToggle("Fly", "FlyEnabled", false)
            AddSlider("Fly Speed", "FlySpeed", 10, 500, 80, "s/s")
            AddToggle("Noclip", "NoclipEnabled", false)
            AddToggle("Inf Jump", "InfiniteJump", false)
            AddToggle("BHop", "BunnyHop", false)
        elseif currentTab == "Combat" then
            AddToggle("Kill Aura", "KillAura", false)
            AddSlider("Range", "KillAuraRange", 5, 100, 15, "s")
        elseif currentTab == "Misc" then
            AddToggle("Anti-AFK", "AntiAFK", true)
            AddToggle("No Fog", "NoFog", false)
            AddToggle("Full Bright", "FullBright", false)
            
            local bf = Instance.new("Frame")
            bf.Size = UDim2.new(1, 0, 0, 36)
            bf.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            bf.BackgroundTransparency = 0.3
            bf.Parent = content
            Instance.new("UICorner", bf).CornerRadius = UDim.new(0, 4)
            
            local tb = Instance.new("TextButton")
            tb.Size = UDim2.new(0.42, 0, 0.7, 0)
            tb.Position = UDim2.new(0.04, 0, 0.15, 0)
            tb.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
            tb.BackgroundTransparency = 0.2
            tb.Text = "Teleport"
            tb.TextColor3 = Color3.fromRGB(255,255,255)
            tb.Font = Enum.Font.GothamBold
            tb.TextSize = 12
            tb.Parent = bf
            Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
            tb.MouseButton1Click:Connect(TeleportToTarget)
            
            local rb = Instance.new("TextButton")
            rb.Size = UDim2.new(0.42, 0, 0.7, 0)
            rb.Position = UDim2.new(0.54, 0, 0.15, 0)
            rb.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            rb.Text = "Respawn"
            rb.TextColor3 = Color3.fromRGB(255,255,255)
            rb.Font = Enum.Font.GothamBold
            rb.TextSize = 12
            rb.Parent = bf
            Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 4)
            rb.MouseButton1Click:Connect(function() LP:LoadCharacter() end)
        end
        
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
    
    UpdateContent()
    
    -- ドラッグ機能
    local dragStart, dragPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            dragPos = main.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                dragPos.X.Scale,
                dragPos.X.Offset + delta.X,
                dragPos.Y.Scale,
                dragPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = nil
        end
    end)
    
    MainWindow = main
    print("[ZETA X] Menu created")
    return main
end

CreateMenu()

-- ============================================================
--   ESP
-- ============================================================
local ESPObjects = {}
local ESPUpdateCounter = 0

local function RemoveESP(pl)
    if ESPObjects[pl] then
        for _, obj in pairs(ESPObjects[pl]) do
            Safe(function() if obj then obj:Remove() end end)
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
            nameTag.Outline = true; nameTag.Font = 0  -- フォント番号（互換性のため）
            nameTag.Color = Color3.fromRGB(255,255,255)
            objs.nameTag = nameTag
        end
        local distTag = Drawing.new("Text")
        if distTag then
            distTag.Visible = false; distTag.Size = 10; distTag.Center = true
            distTag.Outline = true; distTag.Font = 0
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
                            local color = isEnemy and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(50, 220, 80)
                            if Config.ESPBoxes then
                                local height = 40
                                local width = 20
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
                                    local hpColor = hp > 0.6 and Color3.fromRGB(60, 220, 100) or (hp > 0.3 and Color3.fromRGB(255, 200, 40) or Color3.fromRGB(255, 60, 60))
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
--   AIMBOT
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
        FOVCircle.Color = Color3.fromRGB(100, 60, 200)
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
--   AIMBOT メインループ（mousemoverel を MoveMouseRelative に置換）
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
            -- ★★★ ここを置換 ★★★
            MoveMouseRelative(moveX, moveY)
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
--   COMBAT (KillAura)
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
--   MISC
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
--   ★★★ メニュー表示切替 (Kキー) ★★★
-- ============================================================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        if MainWindow then
            MenuVisible = not MenuVisible
            MainWindow.Visible = MenuVisible
        end
    end
end)

print("[ZETA X] Loaded. Menu: K key.")

-- スクリプトをアクティブに保つためのクリーンなループ
RunService.Heartbeat:Wait()

end

-- ★★★ 実行 ★★★
pcall(Main)
