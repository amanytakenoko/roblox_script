-- Amany Hub v2.0 - Xeno Edition
-- Made by amany ✨
-- Discord: amany#0000
-- Press RightShift to open menu

-- Xeno compatibility fixes
local function safeRequire()
    local success, result = pcall(function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local Workspace = game:GetService("Workspace")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local TweenService = game:GetService("TweenService")
        local LocalPlayer = Players.LocalPlayer
        local Camera = Workspace.CurrentCamera
        local Mouse = LocalPlayer:GetMouse()
        
        -- Configuration
        local Config = {
            Aimbot = {
                Enabled = true,
                TargetPart = "Head",
                AimKey = "MouseButton1",
                Smoothness = 1,
                FOV = 120,
                ShowFOV = true,
                IgnoreTeam = true,
                WallCheck = false,
                Prediction = 0.1
            },
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
            Misc = {
                Watermark = true,
                FPS = true,
                Crosshair = true,
                NoRecoil = false,
                HitboxExpander = false,
                HitboxSize = 1.5
            },
            PlayerList = {
                Enabled = true,
                ShowTeam = true,
                ShowDistance = true
            }
        }

        -- Safe Drawing creation with error handling
        local function createDrawing(drawingType, properties)
            local success, drawing = pcall(function()
                local obj = Drawing.new(drawingType)
                for prop, value in pairs(properties or {}) do
                    pcall(function() obj[prop] = value end)
                end
                return obj
            end)
            return success and drawing or nil
        end

        -- Create drawings safely
        local FOVCircle = createDrawing("Circle", {
            Visible = false,
            Radius = Config.Aimbot.FOV,
            Thickness = 1,
            NumSides = 60,
            Color = Color3.fromRGB(255, 100, 255),
            Transparency = 0.7,
            Filled = false
        })

        local Crosshair = createDrawing("Line", {
            Visible = false,
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1
        })

        local Crosshair2 = createDrawing("Line", {
            Visible = false,
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1
        })

        local FPSCounter = createDrawing("Text", {
            Visible = false,
            Size = 16,
            Color = Color3.fromRGB(0, 255, 0),
            Position = Vector2.new(10, 40),
            Center = false,
            Outline = true
        })

        local Watermark = createDrawing("Text", {
            Visible = true,
            Size = 18,
            Color = Color3.fromRGB(255, 100, 255),
            Position = Vector2.new(10, 10),
            Text = "Amany Hub v2.0 | Press RightShift",
            Center = false,
            Outline = true
        })

        local PlayerListDrawings = {}

        -- GUI Creation with Xeno compatibility
        local function CreateAmanyGUI()
            local success, gui = pcall(function()
                local CoreGui = game:GetService("CoreGui")
                if CoreGui:FindFirstChild("AmanyHub") then
                    CoreGui.AmanyHub:Destroy()
                end

                local GUI = Instance.new("ScreenGui")
                GUI.Name = "AmanyHub"
                GUI.Parent = CoreGui
                GUI.ResetOnSpawn = false
                GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                GUI.DisplayOrder = 999

                -- Main Frame
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

                -- Rest of GUI creation (simplified for Xeno)
                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 12)
                UICorner.Parent = MainFrame

                -- Top Bar
                local TopBar = Instance.new("Frame")
                TopBar.Name = "TopBar"
                TopBar.Size = UDim2.new(1, 0, 0, 50)
                TopBar.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
                TopBar.BorderSizePixel = 0
                TopBar.Parent = MainFrame

                local TopBarCorner = Instance.new("UICorner")
                TopBarCorner.CornerRadius = UDim.new(0, 12)
                TopBarCorner.Parent = TopBar

                local Title = Instance.new("TextLabel")
                Title.Text = "AMANY HUB XENO"
                Title.Size = UDim2.new(0.6, 0, 1, 0)
                Title.Position = UDim2.new(0.05, 0, 0, 0)
                Title.BackgroundTransparency = 1
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.TextSize = 18
                Title.Font = Enum.Font.GothamBold
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = TopBar

                local CloseBtn = Instance.new("TextButton")
                CloseBtn.Text = "X"
                CloseBtn.Size = UDim2.new(0, 30, 0, 30)
                CloseBtn.Position = UDim2.new(1, -40, 0, 10)
                CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                CloseBtn.TextColor3 = Color3.new(1, 1, 1)
                CloseBtn.TextSize = 16
                CloseBtn.Font = Enum.Font.GothamBold
                CloseBtn.BorderSizePixel = 0
                CloseBtn.Parent = TopBar

                CloseBtn.MouseButton1Click:Connect(function()
                    MainFrame.Visible = false
                end)

                -- Simple tabs
                local TabFrame = Instance.new("Frame")
                TabFrame.Size = UDim2.new(1, -20, 0, 40)
                TabFrame.Position = UDim2.new(0, 10, 0, 60)
                TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                TabFrame.BackgroundTransparency = 0.3
                TabFrame.BorderSizePixel = 0
                TabFrame.Parent = MainFrame

                local TabCorner = Instance.new("UICorner")
                TabCorner.CornerRadius = UDim.new(0, 8)
                TabCorner.Parent = TabFrame

                -- Create simple text for now
                local InfoText = Instance.new("TextLabel")
                InfoText.Text = "Xeno Edition - Settings in console"
                InfoText.Size = UDim2.new(1, -20, 0, 30)
                InfoText.Position = UDim2.new(0, 10, 0, 110)
                InfoText.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                InfoText.BackgroundTransparency = 0.3
                InfoText.TextColor3 = Color3.new(1, 1, 1)
                InfoText.TextSize = 14
                InfoText.Font = Enum.Font.Gotham
                InfoText.Parent = MainFrame

                local InfoCorner = Instance.new("UICorner")
                InfoCorner.CornerRadius = UDim.new(0, 8)
                InfoCorner.Parent = InfoText

                return GUI, MainFrame
            end)
            
            return success and gui or nil, nil
        end

        -- Create GUI
        local GUI, MenuFrame = CreateAmanyGUI()

        if not GUI then
            warn("GUI creation failed, using console controls only")
        end

        -- Toggle Menu with RightShift
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == Enum.KeyCode.RightShift and not gameProcessed and MenuFrame then
                MenuFrame.Visible = not MenuFrame.Visible
            end
        end)

        -- Simple console commands for Xeno
        print([[
╔══════════════════════════════════╗
║    AMANY HUB XENO EDITION        ║
╠══════════════════════════════════╣
║ Commands (in console):           ║
║  aimbot_toggle()                 ║
║  esp_toggle()                    ║
║  fov_toggle()                    ║
║  set_fov(value)                  ║
║  hitbox_toggle()                 ║
║  crosshair_toggle()              ║
╚══════════════════════════════════╝
        ]])

        -- Console control functions
        _G.aimbot_toggle = function()
            Config.Aimbot.Enabled = not Config.Aimbot.Enabled
            print("Aimbot: " .. (Config.Aimbot.Enabled and "ON" or "OFF"))
        end

        _G.esp_toggle = function()
            Config.ESP.Enabled = not Config.ESP.Enabled
            print("ESP: " .. (Config.ESP.Enabled and "ON" or "OFF"))
        end

        _G.fov_toggle = function()
            Config.Aimbot.ShowFOV = not Config.Aimbot.ShowFOV
            print("FOV Circle: " .. (Config.Aimbot.ShowFOV and "ON" or "OFF"))
        end

        _G.set_fov = function(value)
            Config.Aimbot.FOV = tonumber(value) or 120
            print("FOV set to: " .. Config.Aimbot.FOV)
        end

        _G.hitbox_toggle = function()
            Config.Misc.HitboxExpander = not Config.Misc.HitboxExpander
            print("Hitbox Expander: " .. (Config.Misc.HitboxExpander and "ON" or "OFF"))
        end

        _G.crosshair_toggle = function()
            Config.Misc.Crosshair = not Config.Misc.Crosshair
            print("Crosshair: " .. (Config.Misc.Crosshair and "ON" or "OFF"))
        end

        -- Main loop
        RunService.RenderStepped:Connect(function()
            -- Update FOV Circle
            if FOVCircle and Config.Aimbot.ShowFOV and Config.Aimbot.Enabled then
                local mousePos = UserInputService:GetMouseLocation()
                FOVCircle.Position = mousePos
                FOVCircle.Visible = true
                FOVCircle.Radius = Config.Aimbot.FOV
            elseif FOVCircle then
                FOVCircle.Visible = false
            end

            -- Update crosshair
            if Crosshair and Crosshair2 and Config.Misc.Crosshair then
                local center = Camera.ViewportSize / 2
                Crosshair.Visible = true
                Crosshair2.Visible = true
                Crosshair.From = Vector2.new(center.X - 10, center.Y)
                Crosshair.To = Vector2.new(center.X + 10, center.Y)
                Crosshair2.From = Vector2.new(center.X, center.Y - 10)
                Crosshair2.To = Vector2.new(center.X, center.Y + 10)
            elseif Crosshair and Crosshair2 then
                Crosshair.Visible = false
                Crosshair2.Visible = false
            end

            -- Update FPS
            if FPSCounter and Config.Misc.FPS then
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                FPSCounter.Visible = true
                FPSCounter.Text = "FPS: " .. fps
            elseif FPSCounter then
                FPSCounter.Visible = false
            end

            -- Update watermark
            if Watermark and Config.Misc.Watermark then
                Watermark.Visible = true
                Watermark.Text = "Amany Xeno | " .. os.date("%H:%M")
            elseif Watermark then
                Watermark.Visible = false
            end
        end)

        -- Aimbot
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and Config.Aimbot.Enabled then
                -- Simple aimbot logic
                local closest = nil
                local shortest = math.huge
                local mousePos = UserInputService:GetMouseLocation()

                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local head = player.Character.Head
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < shortest and dist < Config.Aimbot.FOV then
                                shortest = dist
                                closest = head
                            end
                        end
                    end
                end

                if closest then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
                end
            end
        end)

        print("✅ Amany Hub Xeno Edition loaded successfully!")
    end)
    
    if not success then
        warn("❌ Amany Hub failed to load: " .. tostring(result))
    end
end

-- Execute with protection
safeRequire()
