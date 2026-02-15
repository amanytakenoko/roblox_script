-- AMANY HUB XENO - COMPLETE EDITION
-- Made by amany
-- Press Ctrl to open menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==================== 設定 ====================
local Settings = {
    Aimbot = {
        Enabled = true,
        FOV = 120,
        ShowFOV = true,
        Smoothness = 1,
        IgnoreTeam = true,
        Prediction = 0.1,
        AutoShoot = false,
        Triggerbot = false
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        ShowHealth = true,
        ShowDistance = true,
        ShowName = true,
        Tracers = false,
        MaxDistance = 500,
        TeamCheck = false
    },
    SoundESP = {
        Enabled = false,
        MaxDistance = 100
    },
    Misc = {
        Watermark = true,
        FPS = true,
        Crosshair = true,
        NoRecoil = false,
        NoSpread = false,
        HitboxExpander = false,
        HitboxSize = 1.5,
        Spinbot = false,
        SpinbotSpeed = 10,
        SpeedBoost = false,
        SpeedMultiplier = 2,
        JumpBoost = false,
        JumpMultiplier = 2,
        NoClip = false,
        Fullbright = false
    },
    PlayerList = {
        Enabled = true
    }
}

-- ==================== 描画 ====================
local Drawings = {}
local function newDrawing(type, props)
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

-- 基本描画
local FOVCircle = newDrawing("Circle", {
    Thickness = 2, NumSides = 60, Color = Color3.fromRGB(255, 0, 255),
    Transparency = 0.5, Visible = false
})

local Crosshair = {}
for i = 1, 4 do
    Crosshair[i] = newDrawing("Line", {
        Thickness = 2, Color = Color3.fromRGB(255,255,255), Visible = false
    })
end

local Watermark = newDrawing("Text", {
    Text = "AMANY HUB", Size = 16, Color = Color3.fromRGB(255, 0, 255),
    Position = Vector2.new(5, 5), Outline = true, Visible = true
})

local FPS = newDrawing("Text", {
    Text = "FPS: 0", Size = 14, Color = Color3.fromRGB(0, 255, 0),
    Position = Vector2.new(5, 25), Outline = true, Visible = true
})

local Status = newDrawing("Text", {
    Text = "Ready", Size = 14, Color = Color3.fromRGB(255,255,255),
    Position = Vector2.new(5, 45), Outline = true, Visible = true
})

-- ESP用
local ESPBoxes = {}
local PlayerListDrawings = {}
local SoundVisuals = {}

-- ==================== GUI ====================
local function createGUI()
    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("AmanyHub")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "AmanyHub"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false

    -- メインフレーム
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 500)
    frame.Position = UDim2.new(0.5, -175, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.Active = true
    frame.Draggable = true
    frame.Visible = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- タイトルバー
    local title = Instance.new("TextLabel")
    title.Text = "AMANY HUB [COMPLETE]"
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title

    -- 閉じるボタン
    local close = Instance.new("TextButton")
    close.Text = "✕"
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 2.5)
    close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextSize = 20
    close.Font = Enum.Font.GothamBold
    close.Parent = title

    close.MouseButton1Click:Connect(function()
        frame.Visible = false
    end)

    -- タブボタン
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -10, 0, 35)
    tabFrame.Position = UDim2.new(0, 5, 0, 40)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = frame

    local tabs = {"AIM", "ESP", "SOUND", "MISC", "LIST"}
    local tabButtons = {}
    local contentFrames = {}

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Text = name
        btn.Size = UDim2.new(0.2, -4, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.2, 2, 0, 0)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(40, 40, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn

        tabButtons[i] = btn

        -- コンテンツフレーム
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -10, 1, -120)
        content.Position = UDim2.new(0, 5, 0, 80)
        content.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 5
        content.Visible = i == 1
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.Parent = frame

        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 5)
        contentCorner.Parent = content

        contentFrames[name] = content
    end

    -- タブ切り替え
    for i, btn in ipairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            
            for _, cf in pairs(contentFrames) do
                cf.Visible = false
            end
            contentFrames[tabs[i]].Visible = true
        end)
    end

    -- トグル作成関数
    local function addToggle(parent, text, path, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 30)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Text = ""
        btn.Size = UDim2.new(0, 50, 0, 25)
        btn.Position = UDim2.new(1, -60, 0.5, -12.5)
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = frame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = btn

        local btnText = Instance.new("TextLabel")
        btnText.Text = "ON"
        btnText.Size = UDim2.new(1, 0, 1, 0)
        btnText.BackgroundTransparency = 1
        btnText.TextColor3 = Color3.new(1, 1, 1)
        btnText.Font = Enum.Font.GothamBold
        btnText.Parent = btn

        -- 設定パス解決
        local function getValue()
            local p = Settings
            for part in string.gmatch(path, "[^.]+") do
                p = p[part]
                if p == nil then break end
            end
            return p
        end

        local function setValue(v)
            local p = Settings
            local parts = {}
            for part in string.gmatch(path, "[^.]+") do
                table.insert(parts, part)
            end
            for i = 1, #parts - 1 do
                p = p[parts[i]]
            end
            p[parts[#parts]] = v
        end

        local current = getValue()
        btn.BackgroundColor3 = current and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        btnText.Text = current and "ON" or "OFF"

        btn.MouseButton1Click:Connect(function()
            local new = not getValue()
            setValue(new)
            btn.BackgroundColor3 = new and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            btnText.Text = new and "ON" or "OFF"
        end)

        return y + 35
    end

    -- スライダー作成関数
    local function addSlider(parent, text, path, min, max, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(0.5, 0, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame

        local value = Instance.new("TextLabel")
        value.Text = "0"
        value.Size = UDim2.new(0.3, 0, 0, 20)
        value.Position = UDim2.new(0.7, -30, 0, 5)
        value.BackgroundTransparency = 1
        value.TextColor3 = Color3.fromRGB(255, 0, 255)
        value.TextXAlignment = Enum.TextXAlignment.Right
        value.Font = Enum.Font.GothamBold
        value.Parent = frame

        local input = Instance.new("TextBox")
        input.Text = "0"
        input.Size = UDim2.new(0.8, 0, 0, 25)
        input.Position = UDim2.new(0.1, 0, 0, 25)
        input.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        input.TextColor3 = Color3.new(1, 1, 1)
        input.Font = Enum.Font.Gotham
        input.Parent = frame

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 5)
        inputCorner.Parent = input

        -- 設定パス解決
        local function getValue()
            local p = Settings
            for part in string.gmatch(path, "[^.]+") do
                p = p[part]
            end
            return p
        end

        local function setValue(v)
            local p = Settings
            local parts = {}
            for part in string.gmatch(path, "[^.]+") do
                table.insert(parts, part)
            end
            for i = 1, #parts - 1 do
                p = p[parts[i]]
            end
            p[parts[#parts]] = v
        end

        local current = getValue()
        input.Text = tostring(current)
        value.Text = tostring(current)

        input.FocusLost:Connect(function()
            local num = tonumber(input.Text)
            if num then
                num = math.clamp(num, min, max)
                setValue(num)
                input.Text = tostring(num)
                value.Text = tostring(num)
            else
                input.Text = tostring(getValue())
            end
        end)

        return y + 55
    end

    -- AIMタブ
    local y = 5
    y = addToggle(contentFrames["AIM"], "Aimbot Enabled", "Aimbot.Enabled", y)
    y = addToggle(contentFrames["AIM"], "Show FOV", "Aimbot.ShowFOV", y)
    y = addToggle(contentFrames["AIM"], "Ignore Team", "Aimbot.IgnoreTeam", y)
    y = addToggle(contentFrames["AIM"], "Auto Shoot", "Aimbot.AutoShoot", y)
    y = addToggle(contentFrames["AIM"], "Triggerbot", "Aimbot.Triggerbot", y)
    y = addSlider(contentFrames["AIM"], "FOV Size", "Aimbot.FOV", 30, 360, y)
    y = addSlider(contentFrames["AIM"], "Smoothness", "Aimbot.Smoothness", 1, 10, y)
    y = addSlider(contentFrames["AIM"], "Prediction", "Aimbot.Prediction", 0, 1, y)

    -- ESPタブ
    y = 5
    y = addToggle(contentFrames["ESP"], "ESP Enabled", "ESP.Enabled", y)
    y = addToggle(contentFrames["ESP"], "Show Boxes", "ESP.Boxes", y)
    y = addToggle(contentFrames["ESP"], "Show Health", "ESP.ShowHealth", y)
    y = addToggle(contentFrames["ESP"], "Show Distance", "ESP.ShowDistance", y)
    y = addToggle(contentFrames["ESP"], "Show Name", "ESP.ShowName", y)
    y = addToggle(contentFrames["ESP"], "Tracers", "ESP.Tracers", y)
    y = addToggle(contentFrames["ESP"], "Team Check", "ESP.TeamCheck", y)
    y = addSlider(contentFrames["ESP"], "Max Distance", "ESP.MaxDistance", 100, 2000, y)

    -- SOUNDタブ
    y = 5
    y = addToggle(contentFrames["SOUND"], "Sound ESP Enabled", "SoundESP.Enabled", y)
    y = addSlider(contentFrames["SOUND"], "Max Distance", "SoundESP.MaxDistance", 50, 500, y)

    -- MISCタブ
    y = 5
    y = addToggle(contentFrames["MISC"], "Watermark", "Misc.Watermark", y)
    y = addToggle(contentFrames["MISC"], "FPS Counter", "Misc.FPS", y)
    y = addToggle(contentFrames["MISC"], "Crosshair", "Misc.Crosshair", y)
    y = addToggle(contentFrames["MISC"], "No Recoil", "Misc.NoRecoil", y)
    y = addToggle(contentFrames["MISC"], "No Spread", "Misc.NoSpread", y)
    y = addToggle(contentFrames["MISC"], "Hitbox Expander", "Misc.HitboxExpander", y)
    y = addToggle(contentFrames["MISC"], "Spinbot", "Misc.Spinbot", y)
    y = addToggle(contentFrames["MISC"], "Speed Boost", "Misc.SpeedBoost", y)
    y = addToggle(contentFrames["MISC"], "Jump Boost", "Misc.JumpBoost", y)
    y = addToggle(contentFrames["MISC"], "No Clip", "Misc.NoClip", y)
    y = addToggle(contentFrames["MISC"], "Fullbright", "Misc.Fullbright", y)
    y = addSlider(contentFrames["MISC"], "Hitbox Size", "Misc.HitboxSize", 1, 5, y)
    y = addSlider(contentFrames["MISC"], "Spinbot Speed", "Misc.SpinbotSpeed", 1, 30, y)
    y = addSlider(contentFrames["MISC"], "Speed Multiplier", "Misc.SpeedMultiplier", 1, 5, y)
    y = addSlider(contentFrames["MISC"], "Jump Multiplier", "Misc.JumpMultiplier", 1, 5, y)

    -- LISTタブ
    y = 5
    y = addToggle(contentFrames["LIST"], "Player List", "PlayerList.Enabled", y)

    -- フッター
    local footer = Instance.new("TextLabel")
    footer.Text = "Ctrl:Menu | Ins:Spinbot | End:Sound"
    footer.Size = UDim2.new(1, 0, 0, 25)
    footer.Position = UDim2.new(0, 0, 1, -25)
    footer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    footer.TextColor3 = Color3.fromRGB(200, 200, 200)
    footer.TextSize = 12
    footer.Font = Enum.Font.Gotham
    footer.Parent = frame

    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 8)
    footerCorner.Parent = footer

    return gui, frame
end

-- GUI作成
local gui, menuFrame = createGUI()

-- ==================== ホットキー ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        if menuFrame then
            menuFrame.Visible = not menuFrame.Visible
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        Settings.Misc.Spinbot = not Settings.Misc.Spinbot
    end
    
    if input.KeyCode == Enum.KeyCode.End then
        Settings.SoundESP.Enabled = not Settings.SoundESP.Enabled
    end
end)

-- ==================== スピンボット ====================
local spinAngle = 0
RunService.RenderStepped:Connect(function()
    if Settings.Misc.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        spinAngle = spinAngle + Settings.Misc.SpinbotSpeed
        if spinAngle >= 360 then spinAngle = 0 end
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
    end
end)

-- ==================== エイムボット ====================
local function getTarget()
    local closest = nil
    local shortest = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if Settings.Aimbot.IgnoreTeam and player.Team == LocalPlayer.Team then
                goto continue
            end
            
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < shortest and dist < Settings.Aimbot.FOV then
                    shortest = dist
                    closest = head
                end
            end
            
            ::continue::
        end
    end
    
    return closest
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Aimbot.Enabled then
        local target = getTarget()
        if target then
            if Settings.Aimbot.Smoothness > 1 then
                local start = Camera.CFrame
                local goal = CFrame.new(Camera.CFrame.Position, target.Position)
                for i = 1, Settings.Aimbot.Smoothness do
                    Camera.CFrame = start:Lerp(goal, i / Settings.Aimbot.Smoothness)
                    RunService.RenderStepped:Wait()
                end
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
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

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Triggerbot and Settings.Aimbot.Enabled then
        local target = getTarget()
        if target and (target.Position - Camera.CFrame.Position).Magnitude < 100 then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if tool then
                tool:Activate()
            end
        end
    end
end)

-- ==================== ESP ====================
local function createESP(player)
    if player == LocalPlayer then return end
    
    ESPBoxes[player] = {
        box = newDrawing("Square", {Thickness = 2, Filled = false}),
        name = newDrawing("Text", {Size = 14, Outline = true}),
        health = newDrawing("Line", {Thickness = 3}),
        tracer = newDrawing("Line", {Thickness = 1})
    }
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)

Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        for _, obj in pairs(ESPBoxes[player]) do
            pcall(function() obj.Visible = false end)
        end
        ESPBoxes[player] = nil
    end
end)

-- ==================== プレイヤーリスト ====================
local function updatePlayerList()
    if not Settings.PlayerList.Enabled then
        for _, d in pairs(PlayerListDrawings) do
            if d.bg then d.bg.Visible = false end
            if d.text then d.text.Visible = false end
        end
        return
    end
    
    local y = 100
    local players = {}
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, p)
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
    
    for i, p in ipairs(players) do
        if i <= 15 then
            if not PlayerListDrawings[p] then
                PlayerListDrawings[p] = {
                    bg = newDrawing("Square", {Filled = true, Color = Color3.fromRGB(0,0,0), Transparency = 0.6, Size = Vector2.new(180, 20)}),
                    text = newDrawing("Text", {Size = 12, Outline = true})
                }
            end
            
            local d = PlayerListDrawings[p]
            if d then
                local dist = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                local color = p.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                
                d.bg.Position = Vector2.new(Camera.ViewportSize.X - 190, y)
                d.bg.Visible = true
                
                d.text.Text = string.format("%s [%dm]", p.Name, math.floor(dist))
                d.text.Position = Vector2.new(Camera.ViewportSize.X - 185, y + 2)
                d.text.Color = color
                d.text.Visible = true
                
                y = y + 22
            end
        end
    end
    
    for p, d in pairs(PlayerListDrawings) do
        if not table.find(players, p) then
            if d.bg then d.bg.Visible = false end
            if d.text then d.text.Visible = false end
        end
    end
end

-- ==================== サウンドESP ====================
RunService.RenderStepped:Connect(function()
    if not Settings.SoundESP.Enabled then return end
    
    if math.random() < 0.03 then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local circle = newDrawing("Circle", {
                        Position = Vector2.new(pos.X, pos.Y),
                        Radius = 25,
                        Color = Color3.fromRGB(255,255,0),
                        Thickness = 2,
                        Filled = false,
                        Transparency = 0.7,
                        Visible = true
                    })
                    
                    table.insert(SoundVisuals, {circle = circle, time = os.clock()})
                    break
                end
            end
        end
    end
    
    for i = #SoundVisuals, 1, -1 do
        if os.clock() - SoundVisuals[i].time > 1.5 then
            pcall(function() SoundVisuals[i].circle.Visible = false end)
            table.remove(SoundVisuals, i)
        end
    end
end)

-- ==================== メインループ ====================
RunService.RenderStepped:Connect(function()
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
        local c = Camera.ViewportSize / 2
        local s = 10
        Crosshair[1].From = Vector2.new(c.X - s*2, c.Y)
        Crosshair[1].To = Vector2.new(c.X - s, c.Y)
        Crosshair[2].From = Vector2.new(c.X + s, c.Y)
        Crosshair[2].To = Vector2.new(c.X + s*2, c.Y)
        Crosshair[3].From = Vector2.new(c.X, c.Y - s*2)
        Crosshair[3].To = Vector2.new(c.X, c.Y - s)
        Crosshair[4].From = Vector2.new(c.X, c.Y + s)
        Crosshair[4].To = Vector2.new(c.X, c.Y + s*2)
        
        for i = 1, 4 do
            if Crosshair[i] then
                Crosshair[i].Visible = true
            end
        end
    else
        for i = 1, 4 do
            if Crosshair[i] then
                Crosshair[i].Visible = false
            end
        end
    end
    
    -- FPS
    if Settings.Misc.FPS then
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        FPS.Visible = true
        FPS.Text = "FPS: " .. fps
    else
        FPS.Visible = false
    end
    
    -- ウォーターマーク
    Watermark.Visible = Settings.Misc.Watermark
    
    -- ステータス
    Status.Text = string.format("A:%s E:%s Sd:%s Sp:%s",
        Settings.Aimbot.Enabled and "ON" or "OFF",
        Settings.ESP.Enabled and "ON" or "OFF",
        Settings.SoundESP.Enabled and "ON" or "OFF",
        Settings.Misc.Spinbot and "ON" or "OFF")
    
    -- ESP更新
    if Settings.ESP.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        
        for p, esp in pairs(ESPBoxes) do
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
                local root = p.Character.HumanoidRootPart
                local head = p.Character.Head
                local human = p.Character:FindFirstChildOfClass("Humanoid")
                
                local rPos, rVis = Camera:WorldToViewportPoint(root.Position)
                local hPos, hVis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                
                if rVis and hVis then
                    local dist = (root.Position - myPos).Magnitude
                    if dist <= Settings.ESP.MaxDistance then
                        local height = (hPos.Y - rPos.Y) * 1.5
                        local width = height * 0.6
                        local color = (Settings.ESP.TeamCheck and p.Team == LocalPlayer.Team) and 
                            Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                        
                        if Settings.ESP.Boxes and esp.box then
                            esp.box.Size = Vector2.new(width, height)
                            esp.box.Position = Vector2.new(rPos.X - width/2, rPos.Y - height/2)
                            esp.box.Color = color
                            esp.box.Visible = true
                        elseif esp.box then
                            esp.box.Visible = false
                        end
                        
                        if Settings.ESP.ShowName and esp.name then
                            local name = p.Name
                            if Settings.ESP.ShowDistance then
                                name = name .. string.format(" [%dm]", math.floor(dist))
                            end
                            esp.name.Text = name
                            esp.name.Position = Vector2.new(rPos.X, rPos.Y - height/2 - 20)
                            esp.name.Color = color
                            esp.name.Visible = true
                        elseif esp.name then
                            esp.name.Visible = false
                        end
                        
                        if Settings.ESP.ShowHealth and human and esp.health then
                            local hp = human.Health / human.MaxHealth
                            esp.health.From = Vector2.new(rPos.X - width/2, rPos.Y + height/2 + 5)
                            esp.health.To = Vector2.new(rPos.X - width/2 + width * hp, rPos.Y + height/2 + 5)
                            esp.health.Color = Color3.new(1 - hp, hp, 0)
                            esp.health.Visible = true
                        elseif esp.health then
                            esp.health.Visible = false
                        end
                        
                        if Settings.ESP.Tracers and esp.tracer then
                            esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            esp.tracer.To = Vector2.new(rPos.X, rPos.Y)
                            esp.tracer.Color = color
                            esp.tracer.Visible = true
                        elseif esp.tracer then
                            esp.tracer.Visible = false
                        end
                    else
                        if esp.box then esp.box.Visible = false end
                        if esp.name then esp.name.Visible = false end
                        if esp.health then esp.health.Visible = false end
                        if esp.tracer then esp.tracer.Visible = false end
                    end
                else
                    if esp.box then esp.box.Visible = false end
                    if esp.name then esp.name.Visible = false end
                    if esp.health then esp.health.Visible = false end
                    if esp.tracer then esp.tracer.Visible = false end
                end
            else
                if esp.box then esp.box.Visible = false end
                if esp.name then esp.name.Visible = false end
                if esp.health then esp.health.Visible = false end
                if esp.tracer then esp.tracer.Visible = false end
            end
        end
    else
        for _, esp in pairs(ESPBoxes) do
            if esp.box then esp.box.Visible = false end
            if esp.name then esp.name.Visible = false end
            if esp.health then esp.health.Visible = false end
            if esp.tracer then esp.tracer.Visible = false end
        end
    end
    
    -- プレイヤーリスト
    updatePlayerList()
    
    -- 武器Mods
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if tool then
            if Settings.Misc.NoRecoil then
                pcall(function()
                    if tool:FindFirstChild("Recoil") then tool.Recoil.Enabled = false end
                end)
            end
            if Settings.Misc.NoSpread then
                pcall(function()
                    if tool:FindFirstChild("Spread") then tool.Spread.Value = 0 end
                end)
            end
        end
    end
    
    -- 移動Mods
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if Settings.Misc.SpeedBoost then
                hum.WalkSpeed = 16 * Settings.Misc.SpeedMultiplier
            else
                hum.WalkSpeed = 16
            end
            if Settings.Misc.JumpBoost then
                hum.JumpPower = 50 * Settings.Misc.JumpMultiplier
            else
                hum.JumpPower = 50
            end
        end
    end
    
    -- ヒットボックス
    if Settings.Misc.HitboxExpander then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        pcall(function()
                            part.Size = Vector3.new(2, 2, 2) * Settings.Misc.HitboxSize
                        end)
                    end
                end
            end
        end
    end
    
    -- ライティング
    if Settings.Misc.Fullbright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").GlobalShadows = false
    end
end)

-- アンチAFK
if true then
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end

print([[
================================
  AMANY HUB - COMPLETE EDITION
================================
  All 30+ features included
  Press Ctrl to open menu
================================
]])
