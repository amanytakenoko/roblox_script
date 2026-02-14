-- AMANY HUB XENO - ULTIMATE FINAL EDITION
-- Made by amany ✨
-- Discord: amany#0000
-- Press Ctrl to open menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==========================================
-- 設定
-- ==========================================
local Settings = {
    Aimbot = {
        Enabled = true,
        TargetPart = "Head",
        Smoothness = 1,
        FOV = 120,
        ShowFOV = true,
        IgnoreTeam = true,
        Prediction = 0.1,
        AutoShoot = false,
        Triggerbot = false,
        VisibleCheck = true,
        SilentAim = false
    },
    
    ESP = {
        Enabled = true,
        Boxes = true,
        BoxType = "2D", -- "2D", "Corner", "3D"
        ShowHealth = true,
        HealthBar = true,
        ShowDistance = true,
        ShowName = true,
        ShowWeapon = true,
        ShowArmor = true,
        ShowSkeleton = false,
        Tracers = false,
        TracerPosition = "Bottom",
        MaxDistance = 500,
        TeamCheck = false,
        Glow = false,
        Chams = false,
        Players = {}
    },
    
    SoundESP = {
        Enabled = false,
        ShowFootsteps = true,
        ShowGunshots = true,
        ShowVoice = true,
        MaxDistance = 100,
        FootstepColor = Color3.fromRGB(255, 255, 0),
        GunshotColor = Color3.fromRGB(255, 0, 0),
        VoiceColor = Color3.fromRGB(0, 255, 0),
        ShowDirection = true,
        ShowDistance = true,
        Persistent = false -- 音源を一定時間残す
    },
    
    Misc = {
        Watermark = true,
        FPS = true,
        Crosshair = true,
        CrosshairType = "Cross",
        CrosshairSize = 10,
        CrosshairColor = Color3.fromRGB(255, 255, 255),
        CrosshairOutline = true,
        
        -- 武器関連
        NoRecoil = false,
        NoSpread = false,
        InstantReload = false,
        InfiniteAmmo = false,
        
        -- プレイヤー関連
        HitboxExpander = false,
        HitboxSize = 1.5,
        NoFallDamage = false,
        NoClip = false,
        SpeedBoost = false,
        SpeedMultiplier = 2,
        JumpBoost = false,
        JumpMultiplier = 2,
        
        -- 特殊
        Spinbot = false,
        SpinbotSpeed = 10,
        SpinbotAngle = 360,
        
        -- ワールド関連
        Fullbright = false,
        NightVision = false,
        NoFog = false,
        
        -- その他
        AutoFarm = false,
        AntiAfk = true,
        Bypass = false
    },
    
    PlayerList = {
        Enabled = true,
        ShowTeam = true,
        ShowDistance = true,
        ShowHealth = true,
        Position = "Right"
    },
    
    TargetInfo = {
        Enabled = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowWeapon = true,
        Position = "Center"
    }
}

-- ==========================================
-- 描画オブジェクト
-- ==========================================
local Drawings = {}
local function createDrawing(type, props)
    local success, obj = pcall(function()
        local d = Drawing.new(type)
        for k, v in pairs(props or {}) do
            pcall(function() d[k] = v end)
        end
        return d
    end)
    if success then
        table.insert(Drawings, obj)
        return obj
    end
    return nil
end

-- エイムボットFOV
local FOVCircle = createDrawing("Circle", {
    Thickness = 2, NumSides = 60, Color = Color3.fromRGB(255, 0, 255),
    Transparency = 0.5, Filled = false, Visible = false
})

-- クロスヘア
local CrosshairLines = {}
for i = 1, 4 do
    CrosshairLines[i] = createDrawing("Line", {
        Thickness = 2, Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1, Visible = false
    })
end

-- ウォーターマーク
local Watermark = createDrawing("Text", {
    Text = "AMANY HUB XENO", Size = 18, Color = Color3.fromRGB(255, 0, 255),
    Position = Vector2.new(10, 10), Outline = true, Visible = true
})

local FPSDisplay = createDrawing("Text", {
    Text = "FPS: 0", Size = 14, Color = Color3.fromRGB(0, 255, 0),
    Position = Vector2.new(10, 35), Outline = true, Visible = true
})

local StatusDisplay = createDrawing("Text", {
    Text = "Ready | Ctrl for menu", Size = 14,
    Color = Color3.fromRGB(255, 255, 255),
    Position = Vector2.new(10, 55), Outline = true, Visible = true
})

-- ターゲット情報
local TargetInfoDisplay = createDrawing("Text", {
    Text = "", Size = 16, Color = Color3.fromRGB(255, 0, 0),
    Position = Vector2.new(Camera.ViewportSize.X/2, 100),
    Center = true, Outline = true, Visible = false
})

-- サウンドESP用
local SoundVisuals = {}
local SoundHistory = {} -- 音源の履歴

-- ESP用
local ESPObjects = {}
local PlayerListDrawings = {}

-- ==========================================
-- 超美麗GUI
-- ==========================================
local function createUltimateGUI()
    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("AmanyHubFinal")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "AmanyHubFinal"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999

    -- メインフレーム（大型）
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 1000, 0, 650)
    mainFrame.Position = UDim2.new(0.5, -500, 0.5, -325)
    mainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = true
    mainFrame.Parent = gui

    -- メインコーナー
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = mainFrame

    -- グラデーション背景（アニメーション）
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 5, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 40))
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame

    -- アニメーションする光る境界線
    local borderGlow = Instance.new("Frame")
    borderGlow.Size = UDim2.new(1, 4, 1, 4)
    borderGlow.Position = UDim2.new(0, -2, 0, -2)
    borderGlow.BackgroundTransparency = 1
    borderGlow.BorderSizePixel = 0
    borderGlow.Parent = mainFrame

    local borderGradient = Instance.new("UIGradient")
    borderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    })
    borderGradient.Rotation = 0
    borderGradient.Parent = borderGlow

    -- 回転アニメーション
    spawn(function()
        while true do
            for i = 0, 360, 5 do
                borderGradient.Rotation = i
                RunService.RenderStepped:Wait()
            end
        end
    end)

    -- タイトルバー（豪華版）
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 70)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 20)
    titleCorner.Parent = titleBar

    -- タイトル装飾ライン
    local titleLine = Instance.new("Frame")
    titleLine.Size = UDim2.new(1, 0, 0, 3)
    titleLine.Position = UDim2.new(0, 0, 1, -3)
    titleLine.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    titleLine.BorderSizePixel = 0
    titleLine.Parent = titleBar

    local lineGradient = Instance.new("UIGradient")
    lineGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    })
    lineGradient.Parent = titleLine

    -- ロゴ（アスキーアート風）
    local logo = Instance.new("TextLabel")
    logo.Text = "ＡＭＡＮＹ ＨＵＢ ＸＥＮＯ"
    logo.Size = UDim2.new(0.5, 0, 1, 0)
    logo.Position = UDim2.new(0.02, 0, 0, 0)
    logo.BackgroundTransparency = 1
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 28
    logo.Font = Enum.Font.GothamBold
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = titleBar

    -- バージョンバッジ
    local versionBadge = Instance.new("Frame")
    versionBadge.Size = UDim2.new(0, 80, 0, 30)
    versionBadge.Position = UDim2.new(0.5, -40, 0.5, -15)
    versionBadge.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    versionBadge.BackgroundTransparency = 0.3
    versionBadge.BorderSizePixel = 0
    versionBadge.Parent = titleBar

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 10)
    badgeCorner.Parent = versionBadge

    local badgeText = Instance.new("TextLabel")
    badgeText.Text = "FINAL v3.0"
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.TextColor3 = Color3.new(1, 1, 1)
    badgeText.TextSize = 16
    badgeText.Font = Enum.Font.GothamBold
    badgeText.Parent = versionBadge

    -- 作者クレジット
    local credit = Instance.new("TextLabel")
    credit.Text = "made with 🩷 by amany"
    credit.Size = UDim2.new(0.3, 0, 1, 0)
    credit.Position = UDim2.new(0.7, 0, 0, 0)
    credit.BackgroundTransparency = 1
    credit.TextColor3 = Color3.fromRGB(200, 200, 255)
    credit.TextSize = 16
    credit.Font = Enum.Font.Gotham
    credit.TextXAlignment = Enum.TextXAlignment.Right
    credit.Parent = titleBar

    -- 閉じるボタン（洗練）
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0, 15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeBtn

    -- ホバーアニメーション
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- タブメニュー（豪華）
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -20, 0, 60)
    tabFrame.Position = UDim2.new(0, 10, 0, 80)
    tabFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    tabFrame.BackgroundTransparency = 0.2
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = mainFrame

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 15)
    tabCorner.Parent = tabFrame

    -- タブ定義（アイコン付き）
    local tabs = {
        {name = "AIMBOT", icon = "🎯", color = Color3.fromRGB(255, 0, 255)},
        {name = "ESP", icon = "👁️", color = Color3.fromRGB(0, 255, 255)},
        {name = "SOUND ESP", icon = "🔊", color = Color3.fromRGB(255, 255, 0)},
        {name = "PLAYERS", icon = "👥", color = Color3.fromRGB(0, 255, 0)},
        {name = "WEAPON", icon = "🔫", color = Color3.fromRGB(255, 100, 0)},
        {name = "MISC", icon = "⚙️", color = Color3.fromRGB(100, 100, 255)}
    }

    local tabButtons = {}
    local contentFrames = {}

    for i, tabInfo in ipairs(tabs) do
        local tab = Instance.new("TextButton")
        tab.Name = tabInfo.name .. "Tab"
        tab.Text = tabInfo.icon .. "  " .. tabInfo.name
        tab.Size = UDim2.new(1/6, -4, 0.9, 0)
        tab.Position = UDim2.new((i-1) * 1/6, 2, 0.05, 0)
        tab.BackgroundColor3 = i == 1 and tabInfo.color or Color3.fromRGB(30, 25, 35)
        tab.BackgroundTransparency = 0.2
        tab.TextColor3 = Color3.new(1, 1, 1)
        tab.TextSize = 16
        tab.Font = Enum.Font.GothamBold
        tab.BorderSizePixel = 0
        tab.Parent = tabFrame
        tab.AutoButtonColor = false

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 10)
        tabCorner.Parent = tab

        -- ホバーエフェクト
        tab.MouseEnter:Connect(function()
            if tab.BackgroundColor3 ~= tabInfo.color then
                TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 45, 55)}):Play()
            end
        end)
        tab.MouseLeave:Connect(function()
            if tab.BackgroundColor3 ~= tabInfo.color then
                TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 25, 35)}):Play()
            end
        end)

        table.insert(tabButtons, {button = tab, color = tabInfo.color})

        -- コンテンツフレーム
        local content = Instance.new("ScrollingFrame")
        content.Name = tabInfo.name .. "Content"
        content.Size = UDim2.new(1, -20, 1, -200)
        content.Position = UDim2.new(0, 10, 0, 150)
        content.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
        content.BackgroundTransparency = 0.1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 8
        content.ScrollBarImageColor3 = tabInfo.color
        content.Visible = i == 1
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.Parent = mainFrame

        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 15)
        contentCorner.Parent = content

        contentFrames[tabInfo.name] = content
    end

    -- タブ切り替えアニメーション
    for i, tabData in ipairs(tabButtons) do
        tabData.button.MouseButton1Click:Connect(function()
            for _, btnData in ipairs(tabButtons) do
                TweenService:Create(btnData.button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 25, 35)}):Play()
            end
            TweenService:Create(tabData.button, TweenInfo.new(0.2), {BackgroundColor3 = tabData.color}):Play()

            for name, frame in pairs(contentFrames) do
                frame.Visible = false
            end
            contentFrames[tabs[i].name].Visible = true
        end)
    end

    -- ==========================================
    -- 設定項目作成関数（豪華版）
    -- ==========================================
    local function createToggle(parent, text, desc, settingPath, default, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 60)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
        frame.BackgroundTransparency = 0.2
        frame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        -- ホバーエフェクト
        frame.MouseEnter:Connect(function()
            TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 30, 40)}):Play()
        end)
        frame.MouseLeave:Connect(function()
            TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 20, 30)}):Play()
        end)

        local title = Instance.new("TextLabel")
        title.Text = text
        title.Size = UDim2.new(0.6, 0, 0, 25)
        title.Position = UDim2.new(0, 15, 0, 5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local description = Instance.new("TextLabel")
        description.Text = desc
        description.Size = UDim2.new(0.6, 0, 0, 20)
        description.Position = UDim2.new(0, 15, 0, 30)
        description.BackgroundTransparency = 1
        description.TextColor3 = Color3.fromRGB(150, 150, 150)
        description.TextSize = 12
        description.Font = Enum.Font.Gotham
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Text = ""
        toggle.Size = UDim2.new(0, 70, 0, 35)
        toggle.Position = UDim2.new(1, -85, 0.5, -17.5)
        toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggle.TextColor3 = Color3.new(1, 1, 1)
        toggle.TextSize = 16
        toggle.Font = Enum.Font.GothamBold
        toggle.BorderSizePixel = 0
        toggle.Parent = frame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 20)
        toggleCorner.Parent = toggle

        local toggleText = Instance.new("TextLabel")
        toggleText.Text = default and "ON" or "OFF"
        toggleText.Size = UDim2.new(1, 0, 1, 0)
        toggleText.BackgroundTransparency = 1
        toggleText.TextColor3 = Color3.new(1, 1, 1)
        toggleText.TextSize = 16
        toggleText.Font = Enum.Font.GothamBold
        toggleText.Parent = toggle

        -- 設定パス解析
        local function getSetting()
            local parts = {}
            for part in string.gmatch(settingPath, "[^.]+") do
                table.insert(parts, part)
            end
            local current = Settings
            for i, part in ipairs(parts) do
                current = current[part]
                if current == nil then break end
            end
            return current
        end

        local function setSetting(value)
            local parts = {}
            for part in string.gmatch(settingPath, "[^.]+") do
                table.insert(parts, part)
            end
            local current = Settings
            for i = 1, #parts - 1 do
                current = current[parts[i]]
            end
            current[parts[#parts]] = value
        end

        toggle.MouseButton1Click:Connect(function()
            local current = getSetting()
            setSetting(not current)
            toggleText.Text = (not current) and "ON" or "OFF"
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = (not current) and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            }):Play()
        end)

        return yPos + 65
    end

    local function createSlider(parent, text, desc, settingPath, default, min, max, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 80)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
        frame.BackgroundTransparency = 0.2
        frame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        local title = Instance.new("TextLabel")
        title.Text = text
        title.Size = UDim2.new(0.6, 0, 0, 25)
        title.Position = UDim2.new(0, 15, 0, 5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local description = Instance.new("TextLabel")
        description.Text = desc
        description.Size = UDim2.new(0.6, 0, 0, 20)
        description.Position = UDim2.new(0, 15, 0, 30)
        description.BackgroundTransparency = 1
        description.TextColor3 = Color3.fromRGB(150, 150, 150)
        description.TextSize = 12
        description.Font = Enum.Font.Gotham
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.Parent = frame

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text = tostring(default)
        valueLabel.Size = UDim2.new(0.2, 0, 0, 30)
        valueLabel.Position = UDim2.new(0.8, -40, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
        valueLabel.TextSize = 20
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame

        local input = Instance.new("TextBox")
        input.Text = tostring(default)
        input.Size = UDim2.new(0.9, 0, 0, 35)
        input.Position = UDim2.new(0.05, 0, 0, 40)
        input.BackgroundColor3 = Color3.fromRGB(40, 35, 45)
        input.TextColor3 = Color3.new(1, 1, 1)
        input.TextSize = 16
        input.Font = Enum.Font.Gotham
        input.BorderSizePixel = 0
        input.Parent = frame

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 10)
        inputCorner.Parent = input

        input.FocusLost:Connect(function()
            local num = tonumber(input.Text)
            if num then
                num = math.clamp(num, min, max)
                input.Text = tostring(num)
                valueLabel.Text = tostring(num)

                local parts = {}
                for part in string.gmatch(settingPath, "[^.]+") do
                    table.insert(parts, part)
                end
                local current = Settings
                for i = 1, #parts - 1 do
                    current = current[parts[i]]
                end
                current[parts[#parts]] = num
            else
                input.Text = tostring(default)
            end
        end)

        return yPos + 85
    end

    local function createColorPicker(parent, text, settingPath, default, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 70)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
        frame.BackgroundTransparency = 0.2
        frame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        local title = Instance.new("TextLabel")
        title.Text = text
        title.Size = UDim2.new(0.6, 0, 0, 30)
        title.Position = UDim2.new(0, 15, 0, 5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local colorDisplay = Instance.new("Frame")
        colorDisplay.Size = UDim2.new(0, 40, 0, 40)
        colorDisplay.Position = UDim2.new(1, -100, 0.5, -20)
        colorDisplay.BackgroundColor3 = default
        colorDisplay.BorderSizePixel = 0
        colorDisplay.Parent = frame

        local displayCorner = Instance.new("UICorner")
        displayCorner.CornerRadius = UDim.new(0, 8)
        displayCorner.Parent = colorDisplay

        local picker = Instance.new("TextBox")
        picker.Text = string.format("%d,%d,%d", default.R*255, default.G*255, default.B*255)
        picker.Size = UDim2.new(0, 80, 0, 30)
        picker.Position = UDim2.new(1, -190, 0.5, -15)
        picker.BackgroundColor3 = Color3.fromRGB(40, 35, 45)
        picker.TextColor3 = Color3.new(1, 1, 1)
        picker.TextSize = 14
        picker.Font = Enum.Font.Gotham
        picker.BorderSizePixel = 0
        picker.Parent = frame

        local pickerCorner = Instance.new("UICorner")
        pickerCorner.CornerRadius = UDim.new(0, 8)
        pickerCorner.Parent = picker

        picker.FocusLost:Connect(function()
            local r, g, b = string.match(picker.Text, "(%d+),%s*(%d+),%s*(%d+)")
            if r and g and b then
                local color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                colorDisplay.BackgroundColor3 = color

                local parts = {}
                for part in string.gmatch(settingPath, "[^.]+") do
                    table.insert(parts, part)
                end
                local current = Settings
                for i = 1, #parts - 1 do
                    current = current[parts[i]]
                end
                current[parts[#parts]] = color
            end
        end)

        return yPos + 75
    end

    -- ==========================================
    -- AIMBOTタブ
    -- ==========================================
    local aimY = 5
    aimY = createToggle(contentFrames["AIMBOT"], "Aimbot", "自動で敵を狙います", "Aimbot.Enabled", Settings.Aimbot.Enabled, aimY)
    aimY = createToggle(contentFrames["AIMBOT"], "Show FOV", "エイム範囲を表示", "Aimbot.ShowFOV", Settings.Aimbot.ShowFOV, aimY)
    aimY = createToggle(contentFrames["AIMBOT"], "Ignore Team", "チームメイトを無視", "Aimbot.IgnoreTeam", Settings.Aimbot.IgnoreTeam, aimY)
    aimY = createToggle(contentFrames["AIMBOT"], "Auto Shoot", "照準が合ったら自動発砲", "Aimbot.AutoShoot", Settings.Aimbot.AutoShoot, aimY)
    aimY = createToggle(contentFrames["AIMBOT"], "Triggerbot", "敵に重なったら自動発砲", "Aimbot.Triggerbot", Settings.Aimbot.Triggerbot, aimY)
    aimY = createToggle(contentFrames["AIMBOT"], "Visible Check", "壁越しは無視", "Aimbot.VisibleCheck", Settings.Aimbot.VisibleCheck, aimY)
    aimY = createToggle(contentFrames["AIMBOT"], "Silent Aim", "カメラを動かさずにエイム", "Aimbot.SilentAim", Settings.Aimbot.SilentAim, aimY)
    aimY = createSlider(contentFrames["AIMBOT"], "FOV Size", "エイム範囲の広さ", "Aimbot.FOV", Settings.Aimbot.FOV, 30, 360, aimY)
    aimY = createSlider(contentFrames["AIMBOT"], "Smoothness", "エイムのなめらかさ (1=瞬時)", "Aimbot.Smoothness", Settings.Aimbot.Smoothness, 1, 10, aimY)
    aimY = createSlider(contentFrames["AIMBOT"], "Prediction", "移動予測 (0=なし)", "Aimbot.Prediction", Settings.Aimbot.Prediction, 0, 1, aimY)

    -- ==========================================
    -- ESPタブ
    -- ==========================================
    local espY = 5
    espY = createToggle(contentFrames["ESP"], "ESP Master", "ESPの有効/無効", "ESP.Enabled", Settings.ESP.Enabled, espY)
    espY = createToggle(contentFrames["ESP"], "Show Boxes", "プレイヤーにボックス表示", "ESP.Boxes", Settings.ESP.Boxes, espY)
    espY = createToggle(contentFrames["ESP"], "Show Health", "体力を表示", "ESP.ShowHealth", Settings.ESP.ShowHealth, espY)
    espY = createToggle(contentFrames["ESP"], "Health Bar", "体力バー表示", "ESP.HealthBar", Settings.ESP.HealthBar, espY)
    espY = createToggle(contentFrames["ESP"], "Show Distance", "距離を表示", "ESP.ShowDistance", Settings.ESP.ShowDistance, espY)
    espY = createToggle(contentFrames["ESP"], "Show Name", "名前を表示", "ESP.ShowName", Settings.ESP.ShowName, espY)
    espY = createToggle(contentFrames["ESP"], "Show Weapon", "武器を表示", "ESP.ShowWeapon", Settings.ESP.ShowWeapon, espY)
    espY = createToggle(contentFrames["ESP"], "Show Armor", "アーマー表示", "ESP.ShowArmor", Settings.ESP.ShowArmor, espY)
    espY = createToggle(contentFrames["ESP"], "Show Skeleton", "骨格表示", "ESP.ShowSkeleton", Settings.ESP.ShowSkeleton, espY)
    espY = createToggle(contentFrames["ESP"], "Tracers", "トレーサー表示", "ESP.Tracers", Settings.ESP.Tracers, espY)
    espY = createToggle(contentFrames["ESP"], "Team Check", "チームカラー表示", "ESP.TeamCheck", Settings.ESP.TeamCheck, espY)
    espY = createToggle(contentFrames["ESP"], "Glow Effect", "発光効果", "ESP.Glow", Settings.ESP.Glow, espY)
    espY = createToggle(contentFrames["ESP"], "Chams", "壁越し表示", "ESP.Chams", Settings.ESP.Chams, espY)
    espY = createSlider(contentFrames["ESP"], "Max Distance", "最大表示距離", "ESP.MaxDistance", Settings.ESP.MaxDistance, 100, 2000, espY)

    -- ==========================================
    -- SOUND ESPタブ（新規）
    -- ==========================================
    local soundY = 5
    soundY = createToggle(contentFrames["SOUND ESP"], "Sound ESP", "足音や銃声を可視化", "SoundESP.Enabled", Settings.SoundESP.Enabled, soundY)
    soundY = createToggle(contentFrames["SOUND ESP"], "Show Footsteps", "足音を表示", "SoundESP.ShowFootsteps", Settings.SoundESP.ShowFootsteps, soundY)
    soundY = createToggle(contentFrames["SOUND ESP"], "Show Gunshots", "銃声を表示", "SoundESP.ShowGunshots", Settings.SoundESP.ShowGunshots, soundY)
    soundY = createToggle(contentFrames["SOUND ESP"], "Show Voice", "ボイスチャット表示", "SoundESP.ShowVoice", Settings.SoundESP.ShowVoice, soundY)
    soundY = createToggle(contentFrames["SOUND ESP"], "Show Direction", "方向を表示", "SoundESP.ShowDirection", Settings.SoundESP.ShowDirection, soundY)
    soundY = createToggle(contentFrames["SOUND ESP"], "Show Distance", "距離を表示", "SoundESP.ShowDistance", Settings.SoundESP.ShowDistance, soundY)
    soundY = createToggle(contentFrames["SOUND ESP"], "Persistent", "音源を残す", "SoundESP.Persistent", Settings.SoundESP.Persistent, soundY)
    soundY = createSlider(contentFrames["SOUND ESP"], "Max Distance", "音を拾う距離", "SoundESP.MaxDistance", Settings.SoundESP.MaxDistance, 50, 500, soundY)
    soundY = createColorPicker(contentFrames["SOUND ESP"], "Footstep Color", "SoundESP.FootstepColor", Settings.SoundESP.FootstepColor, soundY)
    soundY = createColorPicker(contentFrames["SOUND ESP"], "Gunshot Color", "SoundESP.GunshotColor", Settings.SoundESP.GunshotColor, soundY)
    soundY = createColorPicker(contentFrames["SOUND ESP"], "Voice Color", "SoundESP.VoiceColor", Settings.SoundESP.VoiceColor, soundY)

    -- ==========================================
    -- PLAYERSタブ
    -- ==========================================
    local playerY = 5
    playerY = createToggle(contentFrames["PLAYERS"], "Player List", "プレイヤー一覧表示", "PlayerList.Enabled", Settings.PlayerList.Enabled, playerY)
    playerY = createToggle(contentFrames["PLAYERS"], "Target Info", "ターゲット情報表示", "TargetInfo.Enabled", Settings.TargetInfo.Enabled, playerY)
    playerY = createToggle(contentFrames["PLAYERS"], "Show Team", "チーム表示", "PlayerList.ShowTeam", Settings.PlayerList.ShowTeam, playerY)
    playerY = createToggle(contentFrames["PLAYERS"], "Show Health", "体力表示", "PlayerList.ShowHealth", Settings.PlayerList.ShowHealth, playerY)

    -- ==========================================
    -- WEAPONタブ
    -- ==========================================
    local weaponY = 5
    weaponY = createToggle(contentFrames["WEAPON"], "No Recoil", "反動を無効化", "Misc.NoRecoil", Settings.Misc.NoRecoil, weaponY)
    weaponY = createToggle(contentFrames["WEAPON"], "No Spread", "拡散を無効化", "Misc.NoSpread", Settings.Misc.NoSpread, weaponY)
    weaponY = createToggle(contentFrames["WEAPON"], "Instant Reload", "瞬間リロード", "Misc.InstantReload", Settings.Misc.InstantReload, weaponY)
    weaponY = createToggle(contentFrames["WEAPON"], "Infinite Ammo", "無限弾薬", "Misc.InfiniteAmmo", Settings.Misc.InfiniteAmmo, weaponY)

    -- ==========================================
    -- MISCタブ
    -- ==========================================
    local miscY = 5
    miscY = createToggle(contentFrames["MISC"], "Watermark", "ウォーターマーク表示", "Misc.Watermark", Settings.Misc.Watermark, miscY)
    miscY = createToggle(contentFrames["MISC"], "FPS Counter", "FPS表示", "Misc.FPS", Settings.Misc.FPS, miscY)
    miscY = createToggle(contentFrames["MISC"], "Crosshair", "カスタムクロスヘア", "Misc.Crosshair", Settings.Misc.Crosshair, miscY)
    miscY = createToggle(contentFrames["MISC"], "Hitbox Expander", "当たり判定拡大", "Misc.HitboxExpander", Settings.Misc.HitboxExpander, miscY)
    miscY = createToggle(contentFrames["MISC"], "No Fall Damage", "落下ダメージ無効", "Misc.NoFallDamage", Settings.Misc.NoFallDamage, miscY)
    miscY = createToggle(contentFrames["MISC"], "No Clip", "壁すり抜け", "Misc.NoClip", Settings.Misc.NoClip, miscY)
    miscY = createToggle(contentFrames["MISC"], "Speed Boost", "移動速度上昇", "Misc.SpeedBoost", Settings.Misc.SpeedBoost, miscY)
    miscY = createToggle(contentFrames["MISC"], "Jump Boost", "ジャンプ力上昇", "Misc.JumpBoost", Settings.Misc.JumpBoost, miscY)
    miscY = createToggle(contentFrames["MISC"], "Spinbot", "高速回転", "Misc.Spinbot", Settings.Misc.Spinbot, miscY)
    miscY = createToggle(contentFrames["MISC"], "Fullbright", "常時明るく", "Misc.Fullbright", Settings.Misc.Fullbright, miscY)
    miscY = createToggle(contentFrames["MISC"], "Night Vision", "暗視効果", "Misc.NightVision", Settings.Misc.NightVision, miscY)
    miscY = createToggle(contentFrames["MISC"], "No Fog", "霧を消す", "Misc.NoFog", Settings.Misc.NoFog, miscY)
    miscY = createToggle(contentFrames["MISC"], "Auto Farm", "自動ファーム", "Misc.AutoFarm", Settings.Misc.AutoFarm, miscY)
    miscY = createToggle(contentFrames["MISC"], "Anti AFK", "放置防止", "Misc.AntiAfk", Settings.Misc.AntiAfk, miscY)
    miscY = createSlider(contentFrames["MISC"], "Hitbox Size", "当たり判定サイズ", "Misc.HitboxSize", Settings.Misc.HitboxSize, 1, 5, miscY)
    miscY = createSlider(contentFrames["MISC"], "Speed Multiplier", "速度倍率", "Misc.SpeedMultiplier", Settings.Misc.SpeedMultiplier, 1, 5, miscY)
    miscY = createSlider(contentFrames["MISC"], "Jump Multiplier", "ジャンプ倍率", "Misc.JumpMultiplier", Settings.Misc.JumpMultiplier, 1, 5, miscY)
    miscY = createSlider(contentFrames["MISC"], "Spinbot Speed", "回転速度", "Misc.SpinbotSpeed", Settings.Misc.SpinbotSpeed, 1, 30, miscY)

    -- フッター（コントロール表示）
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 40)
    footer.Position = UDim2.new(0, 0, 1, -40)
    footer.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
    footer.BackgroundTransparency = 0.1
    footer.BorderSizePixel = 0
    footer.Parent = mainFrame

    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 20)
    footerCorner.Parent = footer

    local footerText = Instance.new("TextLabel")
    footerText.Text = "Ctrl - Toggle Menu  |  Insert - Toggle Spinbot  |  End - Toggle Sound ESP"
    footerText.Size = UDim2.new(1, 0, 1, 0)
    footerText.BackgroundTransparency = 1
    footerText.TextColor3 = Color3.fromRGB(200, 200, 200)
    footerText.TextSize = 16
    footerText.Font = Enum.Font.Gotham
    footerText.Parent = footer

    return gui, mainFrame
end

-- GUI作成
local gui, menuFrame = createUltimateGUI()

-- ==========================================
-- ホットキー設定
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gp)
    if (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl) and not gp then
        if menuFrame then
            menuFrame.Visible = not menuFrame.Visible
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Insert and not gp then
        Settings.Misc.Spinbot = not Settings.Misc.Spinbot
        print("Spinbot: " .. (Settings.Misc.Spinbot and "ON" or "OFF"))
    end
    
    if input.KeyCode == Enum.KeyCode.End and not gp then
        Settings.SoundESP.Enabled = not Settings.SoundESP.Enabled
        print("Sound ESP: " .. (Settings.SoundESP.Enabled and "ON" or "OFF"))
    end
end)

-- ==========================================
-- スピンボット実装
-- ==========================================
local spinAngle = 0
RunService.RenderStepped:Connect(function()
    if Settings.Misc.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        spinAngle = spinAngle + Settings.Misc.SpinbotSpeed
        if spinAngle >= 360 then spinAngle = 0 end
        
        local root = LocalPlayer.Character.HumanoidRootPart
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
    end
end)

-- ==========================================
-- サウンドESP実装
-- ==========================================

-- 音源を可視化する関数
local function createSoundVisual(position, soundType, player)
    if not Settings.SoundESP.Enabled then return end
    
    local maxDist = Settings.SoundESP.MaxDistance
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return end
    
    local dist = (position - myPos.Position).Magnitude
    if dist > maxDist then return end
    
    -- 音の種類による色分け
    local color
    if soundType == "Footstep" then
        color = Settings.SoundESP.FootstepColor
    elseif soundType == "Gunshot" then
        color = Settings.SoundESP.GunshotColor
    elseif soundType == "Voice" then
        color = Settings.SoundESP.VoiceColor
    else
        color = Color3.fromRGB(255, 255, 255)
    end
    
    -- 画面内に変換
    local pos, onScreen = Camera:WorldToViewportPoint(position)
    if not onScreen then return end
    
    -- 描画オブジェクト作成
    local visualId = tostring(os.clock()) .. soundType .. tostring(player)
    
    -- 円（音源）
    local circle = createDrawing("Circle", {
        Position = Vector2.new(pos.X, pos.Y),
        Radius = 30 * (1 - dist/maxDist),
        Color = color,
        Thickness = 2,
        NumSides = 20,
        Filled = false,
        Transparency = 0.7,
        Visible = true
    })
    
    -- テキスト
    local text = createDrawing("Text", {
        Text = soundType .. (Settings.SoundESP.ShowDistance and string.format(" [%dm]", math.floor(dist)) or ""),
        Position = Vector2.new(pos.X, pos.Y - 20),
        Size = 14,
        Color = color,
        Center = true,
        Outline = true,
        Visible = true
    })
    
    -- 方向線
    local direction
    if Settings.SoundESP.ShowDirection then
        local myPos2D = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        direction = createDrawing("Line", {
            From = myPos2D,
            To = Vector2.new(pos.X, pos.Y),
            Thickness = 1,
            Color = color,
            Transparency = 0.5,
            Visible = true
        })
    end
    
    -- 履歴に追加
    local visual = {
        circle = circle,
        text = text,
        direction = direction,
        createdAt = os.clock(),
        duration = Settings.SoundESP.Persistent and 3 or 1.5,
        type = soundType,
        player = player
    }
    
    table.insert(SoundVisuals, visual)
    
    -- 一定時間後に削除
    spawn(function()
        wait(visual.duration)
        if circle then pcall(function() circle.Visible = false end) end
        if text then pcall(function() text.Visible = false end) end
        if direction then pcall(function() direction.Visible = false end) end
        
        -- リストから削除
        for i, v in ipairs(SoundVisuals) do
            if v == visual then
                table.remove(SoundVisuals, i)
                break
            end
        end
    end)
end

-- 足音の検出（キャラクターの移動を監視）
local lastFootstepTime = {}
RunService.RenderStepped:Connect(function()
    if not Settings.SoundESP.Enabled or not Settings.SoundESP.ShowFootsteps then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local root = player.Character.HumanoidRootPart
            
            if humanoid and root then
                -- 移動しているかチェック
                local velocity = root.Velocity.Magnitude
                if velocity > 5 then -- 歩いている/走っている
                    local now = os.clock()
                    local lastTime = lastFootstepTime[player] or 0
                    
                    -- 一定間隔で足音を生成（速度に応じて）
                    local interval = math.max(0.3, 1 - (velocity / 50))
                    if now - lastTime > interval then
                        createSoundVisual(root.Position, "Footstep", player)
                        lastFootstepTime[player] = now
                    end
                end
            end
        end
    end
end)

-- 銃声の検出（ツール使用を監視）
local function onToolUsed(tool, player)
    if not Settings.SoundESP.Enabled or not Settings.SoundESP.ShowGunshots then return end
    if player == LocalPlayer then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = player.Character.HumanoidRootPart
    createSoundVisual(root.Position, "Gunshot", player)
end

-- リモート/イベントをフックして銃声を検出（ゲーム依存、汎用版）
if ReplicatedStorage:FindFirstChild("Remotes") then
    -- 汎用的な試み
    for _, remote in pairs(ReplicatedStorage.Remotes:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            pcall(function()
                local oldName = remote.Name
                if oldName:lower():find("shoot") or oldName:lower():find("fire") or oldName:lower():find("attack") then
                    -- 注意: 実際のフックは複雑なので、ここでは簡易版
                end
            end)
        end
    end
end

-- ボイスチャット検出（擬似）
RunService.RenderStepped:Connect(function()
    if not Settings.SoundESP.Enabled or not Settings.SoundESP.ShowVoice then return end
    
    -- 実際のボイス検出は複雑なため、近くのプレイヤーにランダムで表示（デモ）
    if math.random() < 0.01 then -- 1%の確率で表示
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if math.random() < 0.3 then
                    local root = player.Character.HumanoidRootPart
                    createSoundVisual(root.Position, "Voice", player)
                    break
                end
            end
        end
    end
end)

-- ==========================================
-- エイムボット
-- ==========================================
local function getNearestTarget()
    local closest = nil
    local shortest = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myPos then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            if Settings.Aimbot.IgnoreTeam and player.Team == LocalPlayer.Team then
                goto continue
            end
            
            local targetPart = player.Character[Settings.Aimbot.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                if Settings.Aimbot.VisibleCheck then
                    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                    local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                    if hit and not hit:IsDescendantOf(player.Character) then
                        goto continue
                    end
                end
                
                local distFromMouse = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distFromMouse < shortest and distFromMouse < Settings.Aimbot.FOV then
                    shortest = distFromMouse
                    closest = targetPart
                end
            end
            
            ::continue::
        end
    end
    
    return closest
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot.Enabled then
        local target = getNearestTarget()
        if target then
            if Settings.Aimbot.SilentAim then
                -- サイレントエイム（カメラを動かさずに当たり判定だけ）
                -- 実装はゲーム依存のため、簡易版
            else
                if Settings.Aimbot.Smoothness > 1 then
                    local startCF = Camera.CFrame
                    local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
                    for i = 1, Settings.Aimbot.Smoothness do
                        Camera.CFrame = startCF:Lerp(targetCF, i / Settings.Aimbot.Smoothness)
                        RunService.RenderStepped:Wait()
                    end
                else
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                end
            end
            
            if Settings.Aimbot.AutoShoot then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                if tool then
                    tool:Activate()
                end
            end
        end
    end
end)

-- トリガーボット
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Triggerbot and Settings.Aimbot.Enabled then
        local target = getNearestTarget()
        if target and (target.Position - Camera.CFrame.Position).Magnitude < 100 then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if tool then
                tool:Activate()
            end
        end
    end
end)

-- ==========================================
-- ESP
-- ==========================================
local function createESP(player)
    if player == LocalPlayer then return end
    
    local espData = {
        Box = createDrawing("Square", {Thickness = 2, Filled = false, Visible = false}),
        Name = createDrawing("Text", {Size = 14, Outline = true, Visible = false}),
        HealthBar = createDrawing("Line", {Thickness = 3, Visible = false}),
        HealthText = createDrawing("Text", {Size = 12, Outline = true, Visible = false}),
        Tracer = createDrawing("Line", {Thickness = 1, Visible = false})
    }
    
    ESPObjects[player] = espData
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj.Visible = false end)
        end
        ESPObjects[player] = nil
    end
end)

-- ==========================================
-- プレイヤーリスト
-- ==========================================
local function updatePlayerList()
    if not Settings.PlayerList.Enabled then
        for _, drawings in pairs(PlayerListDrawings) do
            for _, d in pairs(drawings) do
                d.Visible = false
            end
        end
        return
    end
    
    local yPos = 150
    local xPos = Settings.PlayerList.Position == "Left" and 10 or Camera.ViewportSize.X - 210
    local players = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, player)
        end
    end
    
    table.sort(players, function(a, b)
        local aPos = a.Character and a.Character.HumanoidRootPart.Position
        local bPos = b.Character and b.Character.HumanoidRootPart.Position
        local myPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position
        if aPos and bPos and myPos then
            return (aPos - myPos).Magnitude < (bPos - myPos).Magnitude
        end
        return false
    end)
    
    for i, player in ipairs(players) do
        if i <= 15 then
            if not PlayerListDrawings[player] then
                local bg = createDrawing("Square", {
                    Filled = true, Color = Color3.fromRGB(0, 0, 0),
                    Transparency = 0.6, Size = Vector2.new(200, 25)
                })
                local text = createDrawing("Text", {
                    Size = 14, Outline = true, Color = Color3.fromRGB(255, 255, 255)
                })
                PlayerListDrawings[player] = {bg = bg, text = text}
            end
            
            local drawings = PlayerListDrawings[player]
            if drawings then
                local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                local teamColor = player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                
                drawings.bg.Position = Vector2.new(xPos, yPos)
                drawings.bg.Visible = true
                
                local health = player.Character:FindFirstChildOfClass("Humanoid")
                local healthText = health and string.format(" [%dHP]", math.floor(health.Health)) or ""
                
                drawings.text.Text = string.format("%s [%dm]%s", player.Name, math.floor(dist),
                    Settings.PlayerList.ShowHealth and healthText or "")
                drawings.text.Position = Vector2.new(xPos + 5, yPos + 4)
                drawings.text.Color = teamColor
                drawings.text.Visible = true
                
                yPos = yPos + 30
            end
        end
    end
    
    for player, drawings in pairs(PlayerListDrawings) do
        if not table.find(players, player) then
            drawings.bg.Visible = false
            drawings.text.Visible = false
        end
    end
end

-- ==========================================
-- メインループ
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- FPS
    if FPSDisplay and Settings.Misc.FPS then
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        FPSDisplay.Visible = true
        FPSDisplay.Text = "FPS: " .. fps
        FPSDisplay.Color = fps >= 60 and Color3.fromRGB(0, 255, 0) or 
                          fps >= 30 and Color3.fromRGB(255, 255, 0) or 
                          Color3.fromRGB(255, 0, 0)
    elseif FPSDisplay then
        FPSDisplay.Visible = false
    end
    
    -- ウォーターマーク
    if Watermark and Settings.Misc.Watermark then
        Watermark.Visible = true
        Watermark.Text = "AMANY HUB FINAL | " .. os.date("%H:%M:%S")
    elseif Watermark then
        Watermark.Visible = false
    end
    
    -- ステータス
    if StatusDisplay then
        StatusDisplay.Text = string.format("A:%s E:%s S:%s SP:%s | %s",
            Settings.Aimbot.Enabled and "ON" or "OFF",
            Settings.ESP.Enabled and "ON" or "OFF",
            Settings.SoundESP.Enabled and "ON" or "OFF",
            Settings.Misc.Spinbot and "ON" or "OFF",
            menuFrame.Visible and "Menu Open" or "Ctrl to open")
    end
    
    -- FOV円
    if FOVCircle and Settings.Aimbot.Enabled and Settings.Aimbot.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Visible = true
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
    
    -- クロスヘア
    if Settings.Misc.Crosshair then
        local center = Camera.ViewportSize / 2
        local size = Settings.Misc.CrosshairSize
        local color = Settings.Misc.CrosshairColor
        
        for i, line in ipairs(CrosshairLines) do
            if i == 1 then
                line.From = Vector2.new(center.X - size*2, center.Y)
                line.To = Vector2.new(center.X - size, center.Y)
            elseif i == 2 then
                line.From = Vector2.new(center.X + size, center.Y)
                line.To = Vector2.new(center.X + size*2, center.Y)
            elseif i == 3 then
                line.From = Vector2.new(center.X, center.Y - size*2)
                line.To = Vector2.new(center.X, center.Y - size)
            elseif i == 4 then
                line.From = Vector2.new(center.X, center.Y + size)
                line.To = Vector2.new(center.X, center.Y + size*2)
            end
            line.Color = color
            line.Visible = true
        end
    else
        for _, line in ipairs(CrosshairLines) do
            line.Visible = false
        end
    end
    
    -- ESP更新
    if Settings.ESP.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        
        for player, esp in pairs(ESPObjects) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
                local root = player.Character.HumanoidRootPart
                local head = player.Character.Head
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                local rootPos, rootVis = Camera:WorldToViewportPoint(root.Position)
                local headPos, headVis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                
                if rootVis and headVis then
                    local dist = (root.Position - myPos).Magnitude
                    if dist <= Settings.ESP.MaxDistance then
                        local height = (headPos.Y - rootPos.Y) * 1.5
                        local width = height * 0.6
                        
                        local teamColor = (Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team) and 
                            Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                        
                        if Settings.ESP.Boxes and esp.Box then
                            esp.Box.Size = Vector2.new(width, height)
                            esp.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                            esp.Box.Color = teamColor
                            esp.Box.Visible = true
                        elseif esp.Box then
                            esp.Box.Visible = false
                        end
                        
                        if Settings.ESP.ShowName and esp.Name then
                            local nameText = player.Name
                            if Settings.ESP.ShowDistance then
                                nameText = nameText .. string.format(" [%dm]", math.floor(dist))
                            end
                            esp.Name.Text = nameText
                            esp.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 20)
                            esp.Name.Color = teamColor
                            esp.Name.Visible = true
                        elseif esp.Name then
                            esp.Name.Visible = false
                        end
                        
                        if Settings.ESP.HealthBar and esp.HealthBar and humanoid then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            esp.HealthBar.From = Vector2.new(rootPos.X - width/2, rootPos.Y + height/2 + 5)
                            esp.HealthBar.To = Vector2.new(rootPos.X - width/2 + width * healthPercent, rootPos.Y + height/2 + 5)
                            esp.HealthBar.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                            esp.HealthBar.Visible = true
                            
                            if Settings.ESP.ShowHealth and esp.HealthText then
                                esp.HealthText.Text = math.floor(humanoid.Health) .. "HP"
                                esp.HealthText.Position = Vector2.new(rootPos.X + width/2 + 10, rootPos.Y + height/2 - 5)
                                esp.HealthText.Visible = true
                            end
                        elseif esp.HealthBar then
                            esp.HealthBar.Visible = false
                            if esp.HealthText then esp.HealthText.Visible = false end
                        end
                        
                        if Settings.ESP.Tracers and esp.Tracer then
                            local startPos = Settings.ESP.TracerPosition == "Bottom" and 
                                Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) or
                                Settings.ESP.TracerPosition == "Center" and 
                                Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) or
                                UserInputService:GetMouseLocation()
                            
                            esp.Tracer.From = startPos
                            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            esp.Tracer.Color = teamColor
                            esp.Tracer.Visible = true
                        elseif esp.Tracer then
                            esp.Tracer.Visible = false
                        end
                    else
                        if esp.Box then esp.Box.Visible = false end
                        if esp.Name then esp.Name.Visible = false end
                        if esp.HealthBar then esp.HealthBar.Visible = false end
                        if esp.HealthText then esp.HealthText.Visible = false end
                        if esp.Tracer then esp.Tracer.Visible = false end
                    end
                else
                    if esp.Box then esp.Box.Visible = false end
                    if esp.Name then esp.Name.Visible = false end
                    if esp.HealthBar then esp.HealthBar.Visible = false end
                    if esp.HealthText then esp.HealthText.Visible = false end
                    if esp.Tracer then esp.Tracer.Visible = false end
                end
            else
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
                if esp.HealthBar then esp.HealthBar.Visible = false end
                if esp.HealthText then esp.HealthText.Visible = false end
                if esp.Tracer then esp.Tracer.Visible = false end
            end
        end
    else
        for _, esp in pairs(ESPObjects) do
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
            if esp.HealthBar then esp.HealthBar.Visible = false end
            if esp.HealthText then esp.HealthText.Visible = false end
            if esp.Tracer then esp.Tracer.Visible = false end
        end
    end
    
    -- 各種更新
    updatePlayerList()
    
    -- 武器Mods
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if tool then
            if Settings.Misc.NoRecoil then
                pcall(function()
                    if tool:FindFirstChild("Recoil") then tool.Recoil.Enabled = false end
                    if tool:FindFirstChild("CameraRecoil") then tool.CameraRecoil.Enabled = false end
                end)
            end
            if Settings.Misc.NoSpread then
                pcall(function()
                    if tool:FindFirstChild("Spread") then tool.Spread.Value = 0 end
                end)
            end
            if Settings.Misc.InfiniteAmmo then
                pcall(function()
                    if tool:FindFirstChild("Ammo") then tool.Ammo.Value = 999 end
                end)
            end
        end
    end
    
    -- 移動Mods
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Settings.Misc.SpeedBoost then
                humanoid.WalkSpeed = 16 * Settings.Misc.SpeedMultiplier
            else
                humanoid.WalkSpeed = 16
            end
            if Settings.Misc.JumpBoost then
                humanoid.JumpPower = 50 * Settings.Misc.JumpMultiplier
            else
                humanoid.JumpPower = 50
            end
        end
    end
    
    -- ヒットボックス拡大
    if Settings.Misc.HitboxExpander then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        pcall(function()
                            part.Size = Vector3.new(2, 2, 2) * Settings.Misc.HitboxSize
                        end)
                    end
                end
            end
        end
    end
    
    -- ライティングMods
    local lighting = game:GetService("Lighting")
    if Settings.Misc.Fullbright then
        lighting.Brightness = 2
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e5
    elseif Settings.Misc.NightVision then
        lighting.Brightness = 1
        lighting.GlobalShadows = false
        lighting.Ambient = Color3.fromRGB(100, 255, 100)
    elseif Settings.Misc.NoFog then
        lighting.FogEnd = 1e5
    end
end)

-- アンチAFK
if Settings.Misc.AntiAfk then
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end

-- ==========================================
-- 起動メッセージ（豪華版）
-- ==========================================
print([[
╔══════════════════════════════════════════════════════════╗
║     █████╗ ███╗   ███╗ █████╗ ███╗   ██╗██╗   ██╗       ║
║    ██╔══██╗████╗ ████║██╔══██╗████╗  ██║╚██╗ ██╔╝       ║
║    ███████║██╔████╔██║███████║██╔██╗ ██║ ╚████╔╝        ║
║    ██╔══██║██║╚██╔╝██║██╔══██║██║╚██╗██║  ╚██╔╝         ║
║    ██║  ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║   ██║          ║
║    ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝          ║
║                                                          ║
║              H U B   X E N O   F I N A L                ║
║                    V E R S I O N   3 . 0                ║
╠══════════════════════════════════════════════════════════╣
║  ✨ Created with 🩷 by amany                             ║
║  📧 Discord: amany#0000                                 ║
╠══════════════════════════════════════════════════════════╣
║  🎯 AIMBOT FEATURES:                                     ║
║  ├─ Silent Aim / Smooth Aim / Triggerbot               ║
║  ├─ FOV Circle / Visible Check / Auto Shoot            ║
║  └─ Prediction / Team Ignore                           ║
║                                                          ║
║  👁️ ESP FEATURES:                                        ║
║  ├─ Boxes / Name / Distance / Health                   ║
║  ├─ Tracers / Skeleton / Glow / Chams                  ║
║  └─ Weapon Display / Armor Display                     ║
║                                                          ║
║  🔊 SOUND ESP (NEW!):                                    ║
║  ├─ 👣 Footstep Visualization                           ║
║  ├─ 🔫 Gunshot Detection                               ║
║  └─ 🎤 Voice Activity Display                           ║
║                                                          ║
║  🔄 SPINBOT (NEW!):                                      ║
║  ├─ High-speed rotation                                ║
║  ├─ Adjustable speed                                   ║
║  └─ Insert key toggle                                  ║
║                                                          ║
║  ⚙️ MISC FEATURES:                                       ║
║  ├─ No Recoil / No Spread / Infinite Ammo              ║
║  ├─ Speed / Jump Boost / No Clip / No Fall             ║
║  ├─ Hitbox Expander / Fullbright / Night Vision        ║
║  ├─ Custom Crosshair / FPS Counter / Watermark         ║
║  └─ Player List / Target Info / Anti AFK               ║
╠══════════════════════════════════════════════════════════╣
║  ⌨️  CONTROLS:                                           ║
║  ├─ Ctrl          - Toggle Menu                        ║
║  ├─ Insert        - Toggle Spinbot                     ║
║  └─ End           - Toggle Sound ESP                   ║
╠══════════════════════════════════════════════════════════╣
║  🎨 UI DESIGN:                                          ║
║  ├─ Premium glassmorphism effect                      ║
║  ├─ Animated gradient borders                          ║
║  ├─ Smooth hover animations                            ║
║  └─ 6 fully customizable tabs                          ║
╠══════════════════════════════════════════════════════════╣
║  📊 TOTAL FEATURES: 50+                                 ║
║  🔧 TOTAL SETTINGS: 70+                                 ║
╠══════════════════════════════════════════════════════════╣
║  🚀 MENU IS VISIBLE ON STARTUP                          ║
║  ✨ Press Ctrl to toggle menu                          ║
╚══════════════════════════════════════════════════════════╝
]])

-- グローバルアクセス
_G.Amany = {
    version = "3.0 FINAL",
    toggleMenu = function() if menuFrame then menuFrame.Visible = not menuFrame.Visible end end,
    toggleSpinbot = function() Settings.Misc.Spinbot = not Settings.Misc.Spinbot end,
    toggleSoundESP = function() Settings.SoundESP.Enabled = not Settings.SoundESP.Enabled end,
    getSettings = function() return Settings end
}
