-- Amany Hub v2.0 - Ultimate Edition
-- Made by amany ✨
-- Discord: amany#0000
-- Press RightShift to open menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local Config = {
    -- Silent Aim / Aimbot
    Aimbot = {
        Enabled = true,
        TargetPart = "Head",
        AimKey = "MouseButton1",
        Smoothness = 1,
        FOV = 120,
        ShowFOV = true,
        IgnoreTeam = true,
        WallCheck = false,
        Prediction = 0.1 -- For moving targets
    },
    
    -- Visuals
    ESP = {
        Enabled = true,
        ShowHealth = true,
        ShowDistance = true,
        MaxDistance = 500,
        TeamCheck = false,
        Boxes = true,
        Tracers = false,
        ShowName = true,
        ShowWeapon = false,
        CornerBox = false,
        Glow = false,
        Players = {}
    },
    
    -- Misc
    Misc = {
        Watermark = true,
        FPS = true,
        Crosshair = true,
        NoRecoil = false,
        HitboxExpander = false,
        HitboxSize = 1.5
    },
    
    -- Player List
    PlayerList = {
        Enabled = true,
        ShowTeam = true,
        ShowDistance = true
    }
}

-- Create FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Color = Color3.fromRGB(255, 100, 255) -- Pink
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false

-- Create Crosshair
local Crosshair = Drawing.new("Line")
Crosshair.Visible = false
Crosshair.Thickness = 1
Crosshair.Color = Color3.fromRGB(255, 255, 255)
Crosshair.Transparency = 1

local Crosshair2 = Drawing.new("Line")
Crosshair2.Visible = false
Crosshair2.Thickness = 1
Crosshair2.Color = Color3.fromRGB(255, 255, 255)
Crosshair2.Transparency = 1

-- FPS Counter
local FPSCounter = Drawing.new("Text")
FPSCounter.Visible = false
FPSCounter.Size = 16
FPSCounter.Color = Color3.fromRGB(0, 255, 0)
FPSCounter.Position = Vector2.new(10, 40)
FPSCounter.Center = false
FPSCounter.Outline = true

-- Watermark
local Watermark = Drawing.new("Text")
Watermark.Visible = true
Watermark.Size = 18
Watermark.Color = Color3.fromRGB(255, 100, 255)
Watermark.Position = Vector2.new(10, 10)
Watermark.Text = "Amany Hub v2.0 | Press RightShift"
Watermark.Center = false
Watermark.Outline = true

-- Player List Drawings
local PlayerListDrawings = {}

-- Advanced GUI with Animations
local function CreateAmanyGUI()
    if game:GetService("CoreGui"):FindFirstChild("AmanyHub") then
        return game:GetService("CoreGui").AmanyHub
    end
    
    local GUI = Instance.new("ScreenGui")
    GUI.Name = "AmanyHub"
    GUI.Parent = game:GetService("CoreGui")
    GUI.ResetOnSpawn = false
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.DisplayOrder = 999
    
    -- Main Frame with glassmorphism effect
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 380, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = GUI
    
    -- Modern corner radius
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Glass effect overlay
    local GlassOverlay = Instance.new("Frame")
    GlassOverlay.Size = UDim2.new(1, 0, 1, 0)
    GlassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassOverlay.BackgroundTransparency = 0.95
    GlassOverlay.BorderSizePixel = 0
    GlassOverlay.Parent = MainFrame
    
    local GlassCorner = Instance.new("UICorner")
    GlassCorner.CornerRadius = UDim.new(0, 12)
    GlassCorner.Parent = GlassOverlay
    
    -- Gradient border effect
    local BorderGradient = Instance.new("UIGradient")
    BorderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 255))
    })
    BorderGradient.Rotation = 45
    
    -- Top Bar with gradient
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 12)
    TopBarCorner.Parent = TopBar
    
    -- Fix corner overlap
    local TopBarMask = Instance.new("Frame")
    TopBarMask.Size = UDim2.new(1, 0, 0, 12)
    TopBarMask.Position = UDim2.new(0, 0, 1, -12)
    TopBarMask.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    TopBarMask.BorderSizePixel = 0
    TopBarMask.Parent = TopBar
    
    -- Title with amany branding
    local Title = Instance.new("TextLabel")
    Title.Text = "ＡＭＡＮＹ ＨＵＢ"
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Version with gradient text
    local Version = Instance.new("TextLabel")
    Version.Text = "v2.0"
    Version.Size = UDim2.new(0.2, 0, 1, 0)
    Version.Position = UDim2.new(0.75, 0, 0, 0)
    Version.BackgroundTransparency = 1
    Version.TextColor3 = Color3.fromRGB(255, 100, 255)
    Version.TextSize = 16
    Version.Font = Enum.Font.GothamBold
    Version.TextXAlignment = Enum.TextXAlignment.Right
    Version.Parent = TopBar
    
    -- Close button with animation
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn
    
    -- Hover animation
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 30, 30)}):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}):Play()
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 380, 0, 520)
        MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
    end)
    
    -- Modern Tabs
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = "Tabs"
    TabFrame.Size = UDim2.new(1, -20, 0, 45)
    TabFrame.Position = UDim2.new(0, 10, 0, 60)
    TabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TabFrame.BackgroundTransparency = 0.3
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabFrame
    
    -- Tab buttons with icons (using text as icons)
    local tabs = {
        {name = "AIMBOT", icon = "🎯", pos = 0},
        {name = "ESP", icon = "👁️", pos = 0.25},
        {name = "PLAYERS", icon = "👥", pos = 0.5},
        {name = "MISC", icon = "⚙️", pos = 0.75}
    }
    
    local TabButtons = {}
    
    for _, tabInfo in ipairs(tabs) do
        local tab = Instance.new("TextButton")
        tab.Name = tabInfo.name .. "Tab"
        tab.Text = tabInfo.icon .. "  " .. tabInfo.name
        tab.Size = UDim2.new(0.25, -5, 0.9, 0)
        tab.Position = UDim2.new(tabInfo.pos, 5, 0.05, 0)
        tab.BackgroundColor3 = tabInfo.pos == 0 and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(40, 40, 50)
        tab.BackgroundTransparency = 0.3
        tab.TextColor3 = Color3.new(1, 1, 1)
        tab.TextSize = 14
        tab.Font = Enum.Font.GothamBold
        tab.BorderSizePixel = 0
        tab.Parent = TabFrame
        tab.AutoButtonColor = false
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tab
        
        -- Hover effect
        tab.MouseEnter:Connect(function()
            if tab.BackgroundColor3 ~= Color3.fromRGB(255, 100, 255) then
                TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
            end
        end)
        
        tab.MouseLeave:Connect(function()
            if tab.BackgroundColor3 ~= Color3.fromRGB(255, 100, 255) then
                TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            end
        end)
        
        table.insert(TabButtons, tab)
    end
    
    -- Content Frames
    local function CreateContentFrame(name, visible)
        local frame = Instance.new("ScrollingFrame")
        frame.Name = name .. "Frame"
        frame.Size = UDim2.new(1, -20, 1, -160)
        frame.Position = UDim2.new(0, 10, 0, 115)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 255)
        frame.Visible = visible
        frame.CanvasSize = UDim2.new(0, 0, 0, 0)
        frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        frame.Parent = MainFrame
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame
        
        return frame
    end
    
    local AimbotFrame = CreateContentFrame("Aimbot", true)
    local ESPFrame = CreateContentFrame("ESP", false)
    local PlayersFrame = CreateContentFrame("Players", false)
    local MiscFrame = CreateContentFrame("Misc", false)
    
    -- Tab switching with animation
    for i, tab in ipairs(TabButtons) do
        tab.MouseButton1Click:Connect(function()
            -- Hide all frames
            AimbotFrame.Visible = false
            ESPFrame.Visible = false
            PlayersFrame.Visible = false
            MiscFrame.Visible = false
            
            -- Show selected frame
            if i == 1 then AimbotFrame.Visible = true
            elseif i == 2 then ESPFrame.Visible = true
            elseif i == 3 then PlayersFrame.Visible = true
            elseif i == 4 then MiscFrame.Visible = true
            end
            
            -- Update tab colors
            for _, btn in ipairs(TabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            end
            TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 255)}):Play()
        end)
    end
    
    -- Creator credit
    local Credit = Instance.new("TextLabel")
    Credit.Text = "made with 🩷 by amany"
    Credit.Size = UDim2.new(1, 0, 0, 30)
    Credit.Position = UDim2.new(0, 0, 1, -30)
    Credit.BackgroundColor3 = Color3.fromRGB(255, 100, 255)
    Credit.BackgroundTransparency = 0.7
    Credit.TextColor3 = Color3.new(1, 1, 1)
    Credit.TextSize = 14
    Credit.Font = Enum.Font.Gotham
    Credit.Parent = MainFrame
    
    return GUI, MainFrame, AimbotFrame, ESPFrame, PlayersFrame, MiscFrame
end

-- Create GUI
local GUI, MenuFrame, AimbotFrame, ESPFrame, PlayersFrame, MiscFrame = CreateAmanyGUI()

-- Toggle Menu with animation
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift and not gameProcessed and MenuFrame then
        MenuFrame.Visible = not MenuFrame.Visible
        if MenuFrame.Visible then
            MenuFrame.Size = UDim2.new(0, 0, 0, 0)
            MenuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            TweenService:Create(MenuFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 380, 0, 520), Position = UDim2.new(0.5, -190, 0.5, -260)}):Play()
        end
    end
end)

-- Modern toggle creator
local function CreateModernToggle(parent, text, desc, configPath, defaultValue, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Text = text
    title.Size = UDim2.new(1, -60, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local description = Instance.new("TextLabel")
    description.Text = desc
    description.Size = UDim2.new(1, -60, 0, 20)
    description.Position = UDim2.new(0, 10, 0, 30)
    description.BackgroundTransparency = 1
    description.TextColor3 = Color3.fromRGB(150, 150, 150)
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextSize = 12
    description.Font = Enum.Font.Gotham
    description.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Text = ""
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -60, 0, 17.5)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(80, 80, 90)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggle
    
    local toggleText = Instance.new("TextLabel")
    toggleText.Text = defaultValue and "ON" or "OFF"
    toggleText.Size = UDim2.new(1, 0, 1, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.TextColor3 = Color3.new(1, 1, 1)
    toggleText.TextSize = 12
    toggleText.Font = Enum.Font.GothamBold
    toggleText.Parent = toggle
    
    local function updateToggle()
        toggleText.Text = defaultValue and "ON" or "OFF"
        TweenService:Create(toggle, TweenInfo.new(0.2), 
            {BackgroundColor3 = defaultValue and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(80, 80, 90)}):Play()
    end
    
    toggle.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        -- Update config (simplified - you'll need proper path handling)
        if configPath == "Aimbot.Enabled" then Config.Aimbot.Enabled = defaultValue
        elseif configPath == "Aimbot.ShowFOV" then Config.Aimbot.ShowFOV = defaultValue
        elseif configPath == "Aimbot.WallCheck" then Config.Aimbot.WallCheck = defaultValue
        elseif configPath == "Misc.HitboxExpander" then Config.Misc.HitboxExpander = defaultValue
        elseif configPath == "Misc.NoRecoil" then Config.Misc.NoRecoil = defaultValue
        elseif configPath == "Misc.Crosshair" then Config.Misc.Crosshair = defaultValue
        elseif configPath == "PlayerList.Enabled" then Config.PlayerList.Enabled = defaultValue
        end
        updateToggle()
    end)
    
    return frame
end

-- Populate Aimbot tab
local aimY = 5
CreateModernToggle(AimbotFrame, "Aimbot", "Automatically aim at enemies", "Aimbot.Enabled", Config.Aimbot.Enabled, aimY)
aimY = aimY + 65
CreateModernToggle(AimbotFrame, "Show FOV", "Display aimbot field of view", "Aimbot.ShowFOV", Config.Aimbot.ShowFOV, aimY)
aimY = aimY + 65
CreateModernToggle(AimbotFrame, "Wall Check", "Ignore enemies behind walls", "Aimbot.WallCheck", Config.Aimbot.WallCheck, aimY)

-- FOV Slider
local fovFrame = Instance.new("Frame")
fovFrame.Size = UDim2.new(1, -10, 0, 60)
fovFrame.Position = UDim2.new(0, 5, 0, aimY + 65)
fovFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
fovFrame.BackgroundTransparency = 0.3
fovFrame.Parent = AimbotFrame

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(0, 8)
fovCorner.Parent = fovFrame

local fovTitle = Instance.new("TextLabel")
fovTitle.Text = "FOV Size"
fovTitle.Size = UDim2.new(1, -20, 0, 25)
fovTitle.Position = UDim2.new(0, 10, 0, 5)
fovTitle.BackgroundTransparency = 1
fovTitle.TextColor3 = Color3.new(1, 1, 1)
fovTitle.TextXAlignment = Enum.TextXAlignment.Left
fovTitle.TextSize = 16
fovTitle.Font = Enum.Font.GothamBold
fovTitle.Parent = fovFrame

local fovValue = Instance.new("TextLabel")
fovValue.Text = Config.Aimbot.FOV .. "°"
fovValue.Size = UDim2.new(0, 50, 0, 25)
fovValue.Position = UDim2.new(1, -60, 0, 5)
fovValue.BackgroundTransparency = 1
fovValue.TextColor3 = Color3.fromRGB(255, 100, 255)
fovValue.TextXAlignment = Enum.TextXAlignment.Right
fovValue.TextSize = 16
fovValue.Font = Enum.Font.GothamBold
fovValue.Parent = fovFrame

local fovSlider = Instance.new("TextBox")
fovSlider.Text = tostring(Config.Aimbot.FOV)
fovSlider.Size = UDim2.new(1, -20, 0, 25)
fovSlider.Position = UDim2.new(0, 10, 0, 30)
fovSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
fovSlider.TextColor3 = Color3.new(1, 1, 1)
fovSlider.TextSize = 14
fovSlider.Font = Enum.Font.Gotham
fovSlider.BorderSizePixel = 0
fovSlider.Parent = fovFrame

local fovSliderCorner = Instance.new("UICorner")
fovSliderCorner.CornerRadius = UDim.new(0, 6)
fovSliderCorner.Parent = fovSlider

fovSlider.FocusLost:Connect(function()
    local num = tonumber(fovSlider.Text)
    if num then
        Config.Aimbot.FOV = math.clamp(num, 30, 360)
        fovValue.Text = Config.Aimbot.FOV .. "°"
        FOVCircle.Radius = Config.Aimbot.FOV
    end
    fovSlider.Text = tostring(Config.Aimbot.FOV)
end)

-- Populate Misc tab
local miscY = 5
CreateModernToggle(MiscFrame, "Hitbox Expander", "Increase hitbox size", "Misc.HitboxExpander", Config.Misc.HitboxExpander, miscY)
miscY = miscY + 65
CreateModernToggle(MiscFrame, "No Recoil", "Remove weapon recoil", "Misc.NoRecoil", Config.Misc.NoRecoil, miscY)
miscY = miscY + 65
CreateModernToggle(MiscFrame, "Crosshair", "Display custom crosshair", "Misc.Crosshair", Config.Misc.Crosshair, miscY)

-- Hitbox Size Slider
local hitboxFrame = Instance.new("Frame")
hitboxFrame.Size = UDim2.new(1, -10, 0, 60)
hitboxFrame.Position = UDim2.new(0, 5, 0, miscY + 65)
hitboxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
hitboxFrame.BackgroundTransparency = 0.3
hitboxFrame.Parent = MiscFrame

local hitboxCorner = Instance.new("UICorner")
hitboxCorner.CornerRadius = UDim.new(0, 8)
hitboxCorner.Parent = hitboxFrame

local hitboxTitle = Instance.new("TextLabel")
hitboxTitle.Text = "Hitbox Size"
hitboxTitle.Size = UDim2.new(1, -20, 0, 25)
hitboxTitle.Position = UDim2.new(0, 10, 0, 5)
hitboxTitle.BackgroundTransparency = 1
hitboxTitle.TextColor3 = Color3.new(1, 1, 1)
hitboxTitle.TextXAlignment = Enum.TextXAlignment.Left
hitboxTitle.TextSize = 16
hitboxTitle.Font = Enum.Font.GothamBold
hitboxTitle.Parent = hitboxFrame

local hitboxValue = Instance.new("TextLabel")
hitboxValue.Text = Config.Misc.HitboxSize .. "x"
hitboxValue.Size = UDim2.new(0, 50, 0, 25)
hitboxValue.Position = UDim2.new(1, -60, 0, 5)
hitboxValue.BackgroundTransparency = 1
hitboxValue.TextColor3 = Color3.fromRGB(255, 100, 255)
hitboxValue.TextXAlignment = Enum.TextXAlignment.Right
hitboxValue.TextSize = 16
hitboxValue.Font = Enum.Font.GothamBold
hitboxValue.Parent = hitboxFrame

local hitboxSlider = Instance.new("TextBox")
hitboxSlider.Text = tostring(Config.Misc.HitboxSize)
hitboxSlider.Size = UDim2.new(1, -20, 0, 25)
hitboxSlider.Position = UDim2.new(0, 10, 0, 30)
hitboxSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
hitboxSlider.TextColor3 = Color3.new(1, 1, 1)
hitboxSlider.TextSize = 14
hitboxSlider.Font = Enum.Font.Gotham
hitboxSlider.BorderSizePixel = 0
hitboxSlider.Parent = hitboxFrame

local hitboxSliderCorner = Instance.new("UICorner")
hitboxSliderCorner.CornerRadius = UDim.new(0, 6)
hitboxSliderCorner.Parent = hitboxSlider

hitboxSlider.FocusLost:Connect(function()
    local num = tonumber(hitboxSlider.Text)
    if num then
        Config.Misc.HitboxSize = math.clamp(num, 1, 5)
        hitboxValue.Text = Config.Misc.HitboxSize .. "x"
    end
    hitboxSlider.Text = tostring(Config.Misc.HitboxSize)
end)

-- Populate Players tab
local playerY = 5
CreateModernToggle(PlayersFrame, "Player List", "Display player list on screen", "PlayerList.Enabled", Config.PlayerList.Enabled, playerY)

-- Player List Function
local function UpdatePlayerList()
    if not Config.PlayerList.Enabled then
        for _, drawing in pairs(PlayerListDrawings) do
            drawing.Visible = false
        end
        return
    end
    
    local yPos = 100
    local players = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, player)
        end
    end
    
    -- Sort by distance
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
        if not PlayerListDrawings[player] then
            local bg = Drawing.new("Square")
            bg.Filled = true
            bg.Color = Color3.fromRGB(0, 0, 0)
            bg.Transparency = 0.7
            bg.Thickness = 0
            bg.Size = Vector2.new(200, 25)
            bg.Position = Vector2.new(10, yPos)
            bg.Visible = true
            
            local text = Drawing.new("Text")
            text.Size = 14
            text.Color = Color3.fromRGB(255, 255, 255)
            text.Position = Vector2.new(15, yPos + 4)
            text.Center = false
            text.Outline = true
            
            PlayerListDrawings[player] = {bg = bg, text = text}
        end
        
        local drawings = PlayerListDrawings[player]
        if drawings then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            local teamColor = player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            
            drawings.bg.Position = Vector2.new(10, yPos)
            drawings.bg.Visible = true
            
            drawings.text.Text = string.format("%s [%dm] %s", 
                player.Name, 
                math.floor(distance),
                player.Team == LocalPlayer.Team and "⚪" or "⚫")
            drawings.text.Position = Vector2.new(15, yPos + 4)
            drawings.text.Color = teamColor
            drawings.text.Visible = true
            
            yPos = yPos + 30
        end
    end
    
    -- Hide unused drawings
    for player, drawings in pairs(PlayerListDrawings) do
        if not table.find(players, player) then
            drawings.bg.Visible = false
            drawings.text.Visible = false
        end
    end
end

-- Aimbot Functions
local function getNearestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myPos then return nil end
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Config.Aimbot.IgnoreTeam and player.Team == LocalPlayer.Team then
                goto continue
            end
            
            local targetPart = player.Character:FindFirstChild(Config.Aimbot.TargetPart) or player.Character:FindFirstChild("Head")
            if not targetPart then goto continue end
            
            local targetPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then goto continue end
            
            -- FOV check
            local distanceFromMouse = (Vector2.new(targetPos.X, targetPos.Y) - mousePos).Magnitude
            if distanceFromMouse < shortestDistance and distanceFromMouse <= Config.Aimbot.FOV then
                shortestDistance = distanceFromMouse
                closestTarget = targetPart
            end
            
            ::continue::
        end
    end
    
    return closestTarget
end

-- Hitbox Expander (simplified - actual implementation depends on game)
local function ApplyHitboxExpander()
    if not Config.Misc.HitboxExpander then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Size = part.Size * Config.Misc.HitboxSize
                end
            end
        end
    end
end

-- No Recoil (simplified - actual implementation depends on game)
local function ApplyNoRecoil()
    if not Config.Misc.NoRecoil or not LocalPlayer.Character then return end
    
    local gun = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    if gun then
        -- This is game-specific, you'd need to find the recoil property
        -- Example: gun.Recoil.Enabled = false
    end
end

-- Update FOV Circle
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
    FOVCircle.Position = mousePos
    
    -- Update crosshair
    if Config.Misc.Crosshair then
        local center = Camera.ViewportSize / 2
        Crosshair.Visible = true
        Crosshair2.Visible = true
        Crosshair.From = Vector2.new(center.X - 10, center.Y)
        Crosshair.To = Vector2.new(center.X + 10, center.Y)
        Crosshair2.From = Vector2.new(center.X, center.Y - 10)
        Crosshair2.To = Vector2.new(center.X, center.Y + 10)
    else
        Crosshair.Visible = false
        Crosshair2.Visible = false
    end
    
    -- Update FPS counter
    if Config.Misc.FPS then
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        FPSCounter.Visible = true
        FPSCounter.Text = "FPS: " .. fps
        FPSCounter.Color = fps >= 60 and Color3.fromRGB(0, 255, 0) or 
                          fps >= 30 and Color3.fromRGB(255, 255, 0) or 
                          Color3.fromRGB(255, 0, 0)
    else
        FPSCounter.Visible = false
    end
    
    -- Update watermark
    Watermark.Visible = Config.Misc.Watermark
    if Config.Misc.Watermark then
        Watermark.Text = "Amany Hub v2.0 | " .. os.date("%H:%M:%S")
    end
    
    -- Update player list
    UpdatePlayerList()
    
    -- Apply hitbox expander periodically
    ApplyHitboxExpander()
end)

-- Aimbot input handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Config.Aimbot.Enabled then
        local target = getNearestTarget()
        if target then
            -- Smooth aim
            if Config.Aimbot.Smoothness > 1 then
                -- Smooth aiming (you can implement easing here)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1/Config.Aimbot.Smoothness)
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
            
            -- Fire remote if exists
            local attackRemote = ReplicatedStorage:FindFirstChild("Remotes") and 
                                ReplicatedStorage.Remotes:FindFirstChild("Attack")
            if attackRemote then
                attackRemote:FireServer(target)
            end
        end
    end
end)

print([[
✨ AMANY HUB v2.0 ✨
━━━━━━━━━━━━━━━━━━━━━━
Made with 🩷 by amany
Discord: amany#0000
━━━━━━━━━━━━━━━━━━━━━━
Press RightShift to open menu
]])
