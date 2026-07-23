local P = game:GetService("Players")
local L = P.LocalPlayer
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local W = game:GetService("Workspace")
local G = L:WaitForChild("PlayerGui") or game:GetService("CoreGui")

-- Конфигурация
local C = {
    A = true, E = true, S = true, F = true, I = true,
    WV = 80, FV = 50,
    AH = false, JP = 50, GV = 196.2, FV2 = 70,
    WH = false,
    AimType = 1, AimFOV = 60, AimOnlyEnemy = true, ShowFOVCircle = true,
    SilentAim = false,
    AimbotOnRMB = false,
    Triggerbot = false,
    Spinbot = false,
    SpinSpeed = 360,
    BoxESP = true, SkeletonESP = true, NameESP = true, HealthBar = true, DistESP = true,
    ESPColor = Color3.fromRGB(255, 215, 0),
    LineThickness = 1.5,
    AB = Enum.KeyCode.R, EB = Enum.KeyCode.V, SB = Enum.KeyCode.C,
    FB = Enum.KeyCode.E, IB = Enum.KeyCode.G, PB = Enum.KeyCode.F,
    XB = Enum.KeyCode.X, SAB = Enum.KeyCode.U,
    TC = Color3.fromRGB(0, 0, 0),
    PC = Color3.fromRGB(255, 215, 0),
    XC = Color3.fromRGB(0, 0, 0),
    VC = Color3.fromRGB(255, 215, 0),
    -- Новые функции
    Bhop = false,
    AntiAim = false,
    AntiAimSpeed = 5,
}

local toggleRefs = {}
local sliderRefs = {}
local choiceRefs = {}
local spinBodyVelocity = nil
local antiAimGyro = nil
local lastJumpTime = 0

if G:FindFirstChild("S") then G.S:Destroy() end
local H = Instance.new("ScreenGui")
H.Name = "S"
H.ResetOnSpawn = false
H.Parent = G

local a, e, s, f, v = false, false, false, false, false
local p = false
local z
local lastTriggerTime = 0
local thirdPerson = false
local originalCameraType = Enum.CameraType.Custom

local function cr(c) return function(p) local i=Instance.new(c) for k,v in pairs(p) do i[k]=v end return i end end

-- Прицел
local X = cr"Frame"{Name="X", AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,40,0,40), Position=UDim2.new(0.5,0,0.47,0), BackgroundTransparency=1, ZIndex=20, Parent=H}
local function l(p,s) cr"Frame"{Size=s, Position=p, BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, Parent=X} end
l(UDim2.new(0,15,0.5,-1), UDim2.new(0,10,0,2))
l(UDim2.new(0.5,-1,0,15), UDim2.new(0,2,0,10))
local D = cr"Frame"{AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,4,0,4), Position=UDim2.new(0.5,0,0.5,0), BackgroundColor3=Color3.fromRGB(255,0,50), BorderSizePixel=0, Parent=X}
cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=D}

-- FOV круг
local FOVCircle = cr"Frame"{Name="FOVCircle", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.47,0), Size=UDim2.new(0,120,0,120), BackgroundColor3=C.TC, BackgroundTransparency=0.85, BorderSizePixel=0, ZIndex=19, Visible=false, Parent=H}
cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=FOVCircle}
local FOVStroke = cr"UIStroke"{Color=C.TC, Thickness=1.5, Transparency=0.5, Parent=FOVCircle}

local function getFOVRadius() local d=math.clamp(C.AimFOV*2,10,400) return d/2 end
local function updateFOVCircle()
    if FOVCircle and C.ShowFOVCircle then local size=math.clamp(C.AimFOV*2,10,400) FOVCircle.Size=UDim2.new(0,size,0,size) FOVCircle.Visible=C.ShowFOVCircle and C.A else FOVCircle.Visible=false end
end

-- Главное меню
local M = cr"Frame"{Size=UDim2.new(0,550,0,680), AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), BackgroundColor3=C.PC, BackgroundTransparency=0.65, Visible=false, Active=true, ZIndex=5, Parent=H}
cr"UICorner"{CornerRadius=UDim.new(0,12), Parent=M}
local MStroke = cr"UIStroke"{Color=C.TC, Thickness=2, Parent=M}
local TitleLabel = cr"TextLabel"{Size=UDim2.new(1,0,0,38), BackgroundTransparency=1, Font=Enum.Font.GothamBold, Text="🌸 Sakura v11", TextColor3=C.XC, TextSize=16, Parent=M}
local M_Scale = cr"UIScale"{Scale=0, Parent=M}

-- Панель вкладок
local TabBar = cr"Frame"{Size=UDim2.new(1,-20,0,28), Position=UDim2.new(0,10,0,42), BackgroundTransparency=1, Parent=M}
local TabLayout = cr"UIListLayout"{Padding=UDim.new(0,6), FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Left, VerticalAlignment=Enum.VerticalAlignment.Center, Parent=TabBar}

local Content = cr"Frame"{Size=UDim2.new(1,-20,1,-82), Position=UDim2.new(0,10,0,74), BackgroundTransparency=1, ClipsDescendants=true, Parent=M}

local tabs = {}
local tabNames = {"Основные","Боевые","Визуал","Конфиги","Кастомизация","HvH","Legit"}
for _, name in ipairs(tabNames) do
    local tabFrame = cr"Frame"{Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false, Parent=Content}
    cr"UIListLayout"{Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=tabFrame}
    tabs[name]=tabFrame
end
tabs[tabNames[1]].Visible=true

local tabButtons = {}
local function createTabButton(name)
    local btn = cr"TextButton"{Size=UDim2.new(0,70,1,0), BackgroundColor3=C.TC, BackgroundTransparency=0.3, Font=Enum.Font.GothamBold, Text=name, TextColor3=C.XC, TextSize=11, AutoButtonColor=false, Parent=TabBar}
    cr"UICorner"{CornerRadius=UDim.new(0,5), Parent=btn}
    table.insert(tabButtons, btn)
    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(tabs) do t.Visible=false end
        tabs[name].Visible=true
        T:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency=0.1}):Play()
        task.wait(0.15)
        T:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency=0.3}):Play()
    end)
end
for _, name in ipairs(tabNames) do createTabButton(name) end

-- ========== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ UI ==========
local function tg(parent, n, d, cb, key)
    local f = cr"Frame"{Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=parent}
    cr"TextLabel"{Size=UDim2.new(0.75,0,1,0), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text=n, TextColor3=C.XC, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=f}
    local b = cr"TextButton"{Size=UDim2.new(0.16,0,0.8,0), Position=UDim2.new(0.84,0,0.1,0), BackgroundColor3=d and C.TC or Color3.fromRGB(255,215,0), Font=Enum.Font.GothamBold, Text=d and "ON" or "OFF", TextColor3=Color3.new(1,1,1), TextSize=10, Parent=f}
    cr"UICorner"{CornerRadius=UDim.new(0,5), Parent=b}
    local st=d
    b.MouseButton1Click:Connect(function() st=not st; b.Text=st and "ON" or "OFF"; T:Create(b, TweenInfo.new(0.2), {BackgroundColor3=st and C.TC or Color3.fromRGB(255,215,0)}):Play(); cb(st) end)
    if key then toggleRefs[key]={button=b, setState=function(val) st=val; b.Text=val and "ON" or "OFF"; b.BackgroundColor3=val and C.TC or Color3.fromRGB(255,215,0); cb(val) end} end
end
local function bt(parent, n, cb)
    local f = cr"Frame"{Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=parent}
    cr"TextLabel"{Size=UDim2.new(0.7,0,1,0), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text=n, TextColor3=C.XC, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=f}
    local b = cr"TextButton"{Size=UDim2.new(0.25,0,0.8,0), Position=UDim2.new(0.75,0,0.1,0), BackgroundColor3=C.TC, Font=Enum.Font.GothamBold, Text="ТЕЛЕПОРТ", TextColor3=Color3.new(1,1,1), TextSize=9, Parent=f}
    cr"UICorner"{CornerRadius=UDim.new(0,5), Parent=b}
    b.MouseButton1Click:Connect(cb)
end
local function sl(parent, n, mi, ma, de, cb, key)
    local f = cr"Frame"{Size=UDim2.new(1,0,0,38), BackgroundTransparency=1, Parent=parent}
    local t = cr"TextLabel"{Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text=n..": "..de, TextColor3=C.XC, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, Parent=f}
    local ba = cr"Frame"{Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,0,22), BackgroundColor3=Color3.fromRGB(255,215,0), Parent=f}
    cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=ba}
    local fi = cr"Frame"{Size=UDim2.new((de-mi)/(ma-mi),0,1,0), BackgroundColor3=C.TC, Parent=ba}
    cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=fi}
    local btn=cr"TextButton"{Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=ba}
    local dragging=false
    local function up(inp)
        local pct=math.clamp((inp.Position.X-ba.AbsolutePosition.X)/ba.AbsoluteSize.X,0,1)
        fi.Size=UDim2.new(pct,0,1,0)
        local val=math.floor(mi+(pct*(ma-mi)))
        t.Text=n..": "..val
        cb(val)
    end
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true up(i) end end)
    U.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then up(i) end end)
    U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    if key then sliderRefs[key]={label=t, fill=fi, setValue=function(val) local pct=(val-mi)/(ma-mi); fi.Size=UDim2.new(pct,0,1,0); t.Text=n..": "..val; cb(val) end} end
end
local function choice(parent, n, items, default, cb, key)
    local f=cr"Frame"{Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=parent}
    cr"TextLabel"{Size=UDim2.new(0.5,0,1,0), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text=n, TextColor3=C.XC, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=f}
    local cur=default
    local btn=cr"TextButton"{Size=UDim2.new(0.4,0,0.8,0), Position=UDim2.new(0.6,0,0.1,0), BackgroundColor3=C.TC, Font=Enum.Font.GothamBold, Text=items[cur], TextColor3=Color3.new(1,1,1), TextSize=10, Parent=f}
    cr"UICorner"{CornerRadius=UDim.new(0,5), Parent=btn}
    btn.MouseButton1Click:Connect(function() cur=cur%#items+1; btn.Text=items[cur]; cb(cur) end)
    if key then choiceRefs[key]={button=btn, setValue=function(val) cur=val; btn.Text=items[val]; cb(val) end} end
end

-- ИСПРАВЛЕНО: добавил return btn
local function presetButton(parent, label, value, cb)
    local btn = cr"TextButton"{Size=UDim2.new(0.2,0,0,30), BackgroundColor3=C.TC, Font=Enum.Font.GothamBold, Text=label, TextColor3=Color3.new(1,1,1), TextSize=11, Parent=parent}
    cr"UICorner"{CornerRadius=UDim.new(0,5), Parent=btn}
    btn.MouseButton1Click:Connect(function() cb(value) end)
    return btn
end

-- ========== ЗАПОЛНЕНИЕ ВКЛАДОК ==========
local base=tabs["Основные"]
sl(base,"Скорость ходьбы",16,250,C.WV,function(v) C.WV=v end,"WV")
sl(base,"Скорость полёта",10,250,C.FV,function(v) C.FV=v end,"FV")
sl(base,"Сила прыжка",50,300,C.JP,function(v) C.JP=v end,"JP")
sl(base,"Гравитация",0,200,C.GV,function(v) C.GV=v; W.Gravity=v end,"GV")
tg(base,"Wallhack",C.WH,function(v) C.WH=v end,"WH")
tg(base,"Bhop",C.Bhop,function(v) C.Bhop=v end,"Bhop")

local combat=tabs["Боевые"]
tg(combat,"Aimbot [R]",C.A,function(v) C.A=v; updateFOVCircle() end,"A")
tg(combat,"Silent Aim [U]",C.SilentAim,function(v) C.SilentAim=v end,"SilentAim")
tg(combat,"Aimbot on RMB",C.AimbotOnRMB,function(v) C.AimbotOnRMB=v end,"AimbotOnRMB")
tg(combat,"Triggerbot",C.Triggerbot,function(v) C.Triggerbot=v end,"Triggerbot")
tg(combat,"Spinbot",C.Spinbot,function(v) C.Spinbot=v; updateSpinbot() end,"Spinbot")
sl(combat,"Скорость спинбота",1,2000,C.SpinSpeed,function(v) C.SpinSpeed=v; updateSpinbot() end,"SpinSpeed")
tg(combat,"Anti Aim",C.AntiAim,function(v) C.AntiAim=v end,"AntiAim")
sl(combat,"Скорость Anti Aim",1,20,C.AntiAimSpeed,function(v) C.AntiAimSpeed=v end,"AntiAimSpeed")
tg(combat,"AutoHeal",C.AH,function(v) C.AH=v end,"AH")
tg(combat,"Только враги",C.AimOnlyEnemy,function(v) C.AimOnlyEnemy=v end,"AimOnlyEnemy")
choice(combat,"Тип аимбота",{"Ближайший","По здоровью","По прицелу","Случайный","Дальний"},C.AimType,function(v) C.AimType=v end,"AimType")
sl(combat,"FOV аимбота",5,180,C.AimFOV,function(v) C.AimFOV=v; updateFOVCircle() end,"AimFOV")
tg(combat,"Показывать FOV круг",C.ShowFOVCircle,function(v) C.ShowFOVCircle=v; updateFOVCircle() end,"ShowFOVCircle")
bt(combat,"Телепорт к цели [X]",doTeleport)

local visual=tabs["Визуал"]
tg(visual,"ESP [V]",C.E,function(v) C.E=v end,"E")
tg(visual,"Box ESP",C.BoxESP,function(v) C.BoxESP=v end,"BoxESP")
tg(visual,"Skeleton ESP",C.SkeletonESP,function(v) C.SkeletonESP=v end,"SkeletonESP")
tg(visual,"Name ESP",C.NameESP,function(v) C.NameESP=v end,"NameESP")
tg(visual,"Health Bar",C.HealthBar,function(v) C.HealthBar=v end,"HealthBar")
tg(visual,"Distance",C.DistESP,function(v) C.DistESP=v end,"DistESP")
sl(visual,"Толщина линий",1,5,C.LineThickness,function(v) C.LineThickness=v end,"LineThickness")
-- Быстрые кнопки FOV камеры
local fovContainer = cr"Frame"{Size=UDim2.new(1,0,0,34), BackgroundTransparency=1, Parent=visual}
cr"TextLabel"{Size=UDim2.new(0.4,0,1,0), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text="Быстрый FOV:", TextColor3=C.XC, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=fovContainer}
local btn70 = presetButton(fovContainer, "70°", 70, function(v) C.FV2=v; if W.CurrentCamera then W.CurrentCamera.FieldOfView=v end; if sliderRefs["FV2"] then sliderRefs["FV2"].setValue(v) end end)
btn70.Position = UDim2.new(0.4,0,0.1,0)
local btn90 = presetButton(fovContainer, "90°", 90, function(v) C.FV2=v; if W.CurrentCamera then W.CurrentCamera.FieldOfView=v end; if sliderRefs["FV2"] then sliderRefs["FV2"].setValue(v) end end)
btn90.Position = UDim2.new(0.6,0,0.1,0)
local btn120 = presetButton(fovContainer, "120°", 120, function(v) C.FV2=v; if W.CurrentCamera then W.CurrentCamera.FieldOfView=v end; if sliderRefs["FV2"] then sliderRefs["FV2"].setValue(v) end end)
btn120.Position = UDim2.new(0.8,0,0.1,0)
sl(visual,"FOV камеры",70,120,C.FV2,function(v) C.FV2=v; if W.CurrentCamera then W.CurrentCamera.FieldOfView=v end end,"FV2")

-- Цвет ESP
local colorPresets={Color3.fromRGB(255,215,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,150,255),Color3.fromRGB(255,255,0)}
local function colorPicker(parent)
    local f=cr"Frame"{Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=parent}
    cr"TextLabel"{Size=UDim2.new(0.5,0,1,0), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text="Цвет ESP", TextColor3=C.XC, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=f}
    local idx=1
    local btn=cr"TextButton"{Size=UDim2.new(0.3,0,0.8,0), Position=UDim2.new(0.6,0,0.1,0), BackgroundColor3=colorPresets[idx], Font=Enum.Font.GothamBold, Text="", TextColor3=Color3.new(1,1,1), TextSize=10, Parent=f}
    cr"UICorner"{CornerRadius=UDim.new(0,5), Parent=btn}
    btn.MouseButton1Click:Connect(function()
        idx=idx%#colorPresets+1; btn.BackgroundColor3=colorPresets[idx]; C.ESPColor=colorPresets[idx]
        for _,pl in ipairs(P:GetPlayers()) do if pl.Character then for _,obj in ipairs(pl.Character:GetDescendants()) do if obj:IsA("Highlight") then obj.FillColor=C.ESPColor end if obj:IsA("TextLabel") and obj.Parent and obj.Parent:IsA("BillboardGui") then obj.TextColor3=C.ESPColor end end end end
    end)
end
colorPicker(visual)

-- Конфиги
local configTab=tabs["Конфиги"]
local configStatus=cr"TextLabel"{Size=UDim2.new(1,0,0,25), BackgroundTransparency=1, Text="Сохраните или загрузите конфиг", TextColor3=C.XC, TextSize=12, Font=Enum.Font.GothamMedium, Parent=configTab}
local saveBtn=cr"TextButton"{Size=UDim2.new(0.4,0,0,35), Position=UDim2.new(0.05,0,0.1,0), BackgroundColor3=C.TC, Font=Enum.Font.GothamBold, Text="Сохранить конфиг", TextColor3=Color3.new(1,1,1), TextSize=12, Parent=configTab}
cr"UICorner"{CornerRadius=UDim.new(0,6), Parent=saveBtn}
local loadBtn=cr"TextButton"{Size=UDim2.new(0.4,0,0,35), Position=UDim2.new(0.55,0,0.1,0), BackgroundColor3=C.TC, Font=Enum.Font.GothamBold, Text="Загрузить конфиг", TextColor3=Color3.new(1,1,1), TextSize=12, Parent=configTab}
cr"UICorner"{CornerRadius=UDim.new(0,6), Parent=loadBtn}
local configInput=cr"TextBox"{Size=UDim2.new(0.9,0,0,60), Position=UDim2.new(0.05,0,0.35,0), BackgroundColor3=Color3.fromRGB(50,50,50), BackgroundTransparency=0.6, Text="", TextColor3=Color3.new(1,1,1), TextSize=11, ClearTextOnFocus=false, MultiLine=true, Font=Enum.Font.Code, Parent=configTab}
cr"UICorner"{CornerRadius=UDim.new(0,6), Parent=configInput}

local function saveConfig()
    local data={A=C.A,E=C.E,S=C.S,F=C.F,I=C.I,WV=C.WV,FV=C.FV,AH=C.AH,JP=C.JP,GV=C.GV,FV2=C.FV2,WH=C.WH,AimType=C.AimType,AimFOV=C.AimFOV,AimOnlyEnemy=C.AimOnlyEnemy,ShowFOVCircle=C.ShowFOVCircle,SilentAim=C.SilentAim,AimbotOnRMB=C.AimbotOnRMB,Triggerbot=C.Triggerbot,Spinbot=C.Spinbot,SpinSpeed=C.SpinSpeed,BoxESP=C.BoxESP,SkeletonESP=C.SkeletonESP,NameESP=C.NameESP,HealthBar=C.HealthBar,DistESP=C.DistESP,ESPColor={C.ESPColor.R,C.ESPColor.G,C.ESPColor.B},LineThickness=C.LineThickness,TC={C.TC.R,C.TC.G,C.TC.B},PC={C.PC.R,C.PC.G,C.PC.B},XC={C.XC.R,C.XC.G,C.XC.B},VC={C.VC.R,C.VC.G,C.VC.B},Bhop=C.Bhop,AntiAim=C.AntiAim,AntiAimSpeed=C.AntiAimSpeed}
    local json=game:GetService("HttpService"):JSONEncode(data)
    configInput.Text=json
    configStatus.Text="Конфиг сохранён! Скопируйте текст"
end
local function loadConfig(json)
    local success,data=pcall(function() return game:GetService("HttpService"):JSONDecode(json) end)
    if not success then configStatus.Text="Ошибка: неверный формат" return end
    for k,v in pairs(data) do
        if k=="ESPColor" or k=="TC" or k=="PC" or k=="XC" or k=="VC" then local col=Color3.new(v[1],v[2],v[3]); C[k]=col
        elseif k=="A" then C.A=v; a=v; updateFOVCircle()
        elseif k=="E" then C.E=v; e=v
        elseif k=="S" then C.S=v; s=v
        elseif k=="F" then C.F=v; f=v
        elseif k=="I" then C.I=v
        else C[k]=v end
    end
    updateFOVCircle(); applyCustomColors()
    for _,btn in ipairs(tabButtons) do btn.BackgroundColor3=C.TC; btn.TextColor3=C.XC end
    for key,ref in pairs(toggleRefs) do if C[key]~=nil then ref.setState(C[key]) end end
    for key,ref in pairs(sliderRefs) do if C[key]~=nil then ref.setValue(C[key]) end end
    for key,ref in pairs(choiceRefs) do if C[key]~=nil then ref.setValue(C[key]) end end
    updateSpinbot()
    configStatus.Text="Конфиг загружен!"
end
saveBtn.MouseButton1Click:Connect(saveConfig)
loadBtn.MouseButton1Click:Connect(function() loadConfig(configInput.Text) end)

-- Кастомизация
local customTab=tabs["Кастомизация"]
local colorNames={"Фон окон (PC)","Акценты (TC)","Текст (XC)","Заголовок (VC)"}
local colorKeys={"PC","TC","XC","VC"}
local colorPresets2={Color3.fromRGB(255,215,0),Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255),Color3.fromRGB(255,0,0),Color3.fromRGB(0,0,255),Color3.fromRGB(0,255,0),Color3.fromRGB(128,0,128),Color3.fromRGB(255,105,180)}
local function createColorPicker(parent,label,key)
    local f=cr"Frame"{Size=UDim2.new(1,0,0,34), BackgroundTransparency=1, Parent=parent}
    cr"TextLabel"{Size=UDim2.new(0.5,0,1,0), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text=label, TextColor3=C.XC, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=f}
    local idx=1
    local btn=cr"TextButton"{Size=UDim2.new(0.4,0,0.8,0), Position=UDim2.new(0.55,0,0.1,0), BackgroundColor3=C[key], Font=Enum.Font.GothamBold, Text="", TextColor3=Color3.new(1,1,1), TextSize=10, Parent=f}
    cr"UICorner"{CornerRadius=UDim.new(0,5), Parent=btn}
    btn.MouseButton1Click:Connect(function()
        local current=C[key]; local found=false
        for i,col in ipairs(colorPresets2) do if col.R==current.R and col.G==current.G and col.B==current.B then idx=i%#colorPresets2+1; found=true; break end end
        if not found then idx=1 end
        C[key]=colorPresets2[idx]; btn.BackgroundColor3=C[key]; applyCustomColors()
    end)
end
for i,name in ipairs(colorNames) do createColorPicker(customTab,name,colorKeys[i]) end

function applyCustomColors()
    if M then M.BackgroundColor3=C.PC; if MStroke then MStroke.Color=C.TC end; if TitleLabel then TitleLabel.TextColor3=C.XC end end
    for _,btn in ipairs(tabButtons) do if btn and btn:IsA("TextButton") then btn.BackgroundColor3=C.TC; btn.TextColor3=C.XC end end
    if PingLabel then PingLabel.TextColor3=C.PC end
    if IslandTitle then IslandTitle.TextColor3=C.VC end
    if FpsLabel then FpsLabel.TextColor3=C.PC end
    if DI then DI.BackgroundColor3=C.TC; local stroke=DI:FindFirstChildWhichIsA("UIStroke"); if stroke then stroke.Color=C.PC end end
    if FOVCircle then FOVCircle.BackgroundColor3=C.TC; if FOVStroke then FOVStroke.Color=C.TC end end
    if SF then SF.BackgroundColor3=C.PC; local stroke=SF:FindFirstChildWhichIsA("UIStroke"); if stroke then stroke.Color=C.TC end; if StatText then StatText.TextColor3=C.XC end; if Avatar then local stroke2=Avatar:FindFirstChildWhichIsA("UIStroke"); if stroke2 then stroke2.Color=C.TC end end end
    if DIM then DIM.BackgroundColor3=C.TC; local stroke=DIM:FindFirstChildWhichIsA("UIStroke"); if stroke then stroke.Color=C.PC end; for _,btn in ipairs(DIM:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3=C.TC end end end
    if MB then MB.BackgroundColor3=C.TC end
    if Content then for _,tab in pairs(tabs) do for _,child in ipairs(tab:GetDescendants()) do if child:IsA("TextLabel") then child.TextColor3=C.XC end end end end
    if configStatus then configStatus.TextColor3=C.XC end
end

-- ========== НОВЫЙ СПИНБОТ ==========
function updateSpinbot()
    local char = L.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if spinBodyVelocity then
        spinBodyVelocity:Destroy()
        spinBodyVelocity = nil
    end
end

-- ========== ВКЛАДКИ HvH и Legit ==========

local hvhPresets = {
    {
        name = "Агрессивный",
        params = {A=true, AimFOV=180, Spinbot=true, SpinSpeed=500, Triggerbot=true, SilentAim=false, AimbotOnRMB=false, WH=true, BoxESP=false, SkeletonESP=false, NameESP=true, HealthBar=true, DistESP=true}
    },
    {
        name = "Средний",
        params = {A=true, AimFOV=120, Spinbot=true, SpinSpeed=300, Triggerbot=true, SilentAim=false, AimbotOnRMB=false, WH=true, BoxESP=false, SkeletonESP=false, NameESP=true, HealthBar=true, DistESP=true}
    },
    {
        name = "Снайперский",
        params = {A=true, AimFOV=60, Spinbot=true, SpinSpeed=100, Triggerbot=true, SilentAim=false, AimbotOnRMB=false, WH=true, BoxESP=false, SkeletonESP=false, NameESP=true, HealthBar=true, DistESP=true}
    },
    {
        name = "Пользовательский",
        params = {A=true, AimFOV=180, Spinbot=false, SpinSpeed=360, Triggerbot=true, SilentAim=false, AimbotOnRMB=false, WH=false, BoxESP=false, SkeletonESP=false, NameESP=true, HealthBar=true, DistESP=true}
    },
    {
        name = "HvH flick - rivals CFG",
        params = {A=true, AimFOV=180, Spinbot=false, SpinSpeed=1996, Triggerbot=true, SilentAim=false, AimbotOnRMB=false, WH=false, BoxESP=false, SkeletonESP=false, NameESP=true, HealthBar=true, DistESP=true, WV=31, FV=50, AH=false, JP=50, GV=196.2, FV2=119, ESPColor=Color3.fromRGB(255,215,0), TC=Color3.fromRGB(255,105,180), PC=Color3.fromRGB(255,105,180), XC=Color3.fromRGB(128,0,128), VC=Color3.fromRGB(0.000015294,0.000015294,0.000015294)}
    }
}

local legitPresets = {
    {
        name = "Легкий",
        params = {A=true, AimFOV=20, Spinbot=false, SpinSpeed=360, Triggerbot=false, SilentAim=true, AimbotOnRMB=true, WH=false, BoxESP=true, SkeletonESP=true, NameESP=true, HealthBar=true, DistESP=true}
    },
    {
        name = "Средний",
        params = {A=true, AimFOV=30, Spinbot=false, SpinSpeed=360, Triggerbot=false, SilentAim=true, AimbotOnRMB=true, WH=false, BoxESP=true, SkeletonESP=true, NameESP=true, HealthBar=true, DistESP=true}
    },
    {
        name = "Жесткий",
        params = {A=true, AimFOV=40, Spinbot=false, SpinSpeed=360, Triggerbot=true, SilentAim=true, AimbotOnRMB=true, WH=false, BoxESP=true, SkeletonESP=true, NameESP=true, HealthBar=true, DistESP=true}
    },
    {
        name = "Дальнобойный",
        params = {A=true, AimFOV=50, Spinbot=false, SpinSpeed=360, Triggerbot=false, SilentAim=true, AimbotOnRMB=false, WH=false, BoxESP=true, SkeletonESP=true, NameESP=true, HealthBar=true, DistESP=true}
    }
}

local function applyPreset(preset)
    for key, val in pairs(preset.params) do
        if key == "A" then C.A = val; a = val; updateFOVCircle()
        elseif key == "E" then C.E = val; e = val
        elseif key == "S" then C.S = val; s = val
        elseif key == "F" then C.F = val; f = val
        elseif key == "I" then C.I = val
        elseif key == "ESPColor" then C.ESPColor = val
        elseif key == "TC" then C.TC = val
        elseif key == "PC" then C.PC = val
        elseif key == "XC" then C.XC = val
        elseif key == "VC" then C.VC = val
        else C[key] = val end
    end
    updateFOVCircle()
    applyCustomColors()
    for key, ref in pairs(toggleRefs) do if C[key]~=nil then ref.setState(C[key]) end end
    for key, ref in pairs(sliderRefs) do if C[key]~=nil then ref.setValue(C[key]) end end
    for key, ref in pairs(choiceRefs) do if C[key]~=nil then ref.setValue(C[key]) end end
    configStatus.Text = "Применён пресет: " .. preset.name
end

-- Вкладка HvH
local hvhTab = tabs["HvH"]
cr"TextLabel"{Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Text="Выберите конфиг HvH:", TextColor3=C.XC, TextSize=14, Font=Enum.Font.GothamBold, Parent=hvhTab}
local hvhLayout = cr"UIListLayout"{Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Top, Parent=hvhTab}

for i, preset in ipairs(hvhPresets) do
    local btn = cr"TextButton"{Size=UDim2.new(0.8,0,0,35), BackgroundColor3=C.TC, Font=Enum.Font.GothamBold, Text=preset.name, TextColor3=Color3.new(1,1,1), TextSize=12, Parent=hvhTab}
    cr"UICorner"{CornerRadius=UDim.new(0,6), Parent=btn}
    btn.MouseButton1Click:Connect(function()
        applyPreset(preset)
    end)
end

-- Вкладка Legit
local legitTab = tabs["Legit"]
cr"TextLabel"{Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Text="Выберите конфиг Legit:", TextColor3=C.XC, TextSize=14, Font=Enum.Font.GothamBold, Parent=legitTab}
local legitLayout = cr"UIListLayout"{Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Top, Parent=legitTab}

for i, preset in ipairs(legitPresets) do
    local btn = cr"TextButton"{Size=UDim2.new(0.8,0,0,35), BackgroundColor3=C.TC, Font=Enum.Font.GothamBold, Text=preset.name, TextColor3=Color3.new(1,1,1), TextSize=12, Parent=legitTab}
    cr"UICorner"{CornerRadius=UDim.new(0,6), Parent=btn}
    btn.MouseButton1Click:Connect(function()
        applyPreset(preset)
    end)
end

-- ========== ДИНАМИЧЕСКИЙ ОСТРОВ ==========
local DI=cr"TextButton"{Name="DynamicIsland", AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0,12), Size=UDim2.new(0,360,0,36), BackgroundColor3=C.TC, BackgroundTransparency=0.15, Text="", AutoButtonColor=false, ZIndex=30, Parent=H}
cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=DI}
cr"UIStroke"{Color=C.PC, Thickness=1.5, Parent=DI}
local PingLabel=cr"TextLabel"{Size=UDim2.new(0.28,0,1,0), Position=UDim2.new(0,16,0,0), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text="Ping: ...", TextColor3=C.PC, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=31, Parent=DI}
local IslandTitle=cr"TextLabel"{Size=UDim2.new(0.44,0,1,0), Position=UDim2.new(0.28,0,0,0), BackgroundTransparency=1, Font=Enum.Font.GothamBold, Text="SakuraTime", TextColor3=C.VC, TextSize=14, ZIndex=31, Parent=DI}
local FpsLabel=cr"TextLabel"{Size=UDim2.new(0.28,0,1,0), Position=UDim2.new(0.72,-16,0,0), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, Text="FPS: ...", TextColor3=C.PC, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=31, Parent=DI}

local DIM=cr"Frame"{Name="IslandDropdown", AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0,54), Size=UDim2.new(0,200,0,0), BackgroundColor3=C.TC, BackgroundTransparency=0.2, Visible=false, ZIndex=25, ClipsDescendants=true, Parent=H}
cr"UICorner"{CornerRadius=UDim.new(0,12), Parent=DIM}
cr"UIStroke"{Color=C.PC, Thickness=1.5, Parent=DIM}
local DIMList=cr"UIListLayout"{Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Center, Parent=DIM}

local SF=cr"Frame"{AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0,186), Size=UDim2.new(0,280,0,120), BackgroundColor3=C.PC, BackgroundTransparency=0.65, Visible=false, Active=true, ZIndex=20, Parent=H}
cr"UICorner"{CornerRadius=UDim.new(0,10), Parent=SF}
cr"UIStroke"{Color=C.TC, Thickness=1.5, Parent=SF}
local Avatar=cr"ImageLabel"{Name="PlayerAvatar", Size=UDim2.new(0,80,0,80), Position=UDim2.new(0,15,0.5,-40), BackgroundTransparency=1, Image="rbxthumb://type=AvatarHeadShot&id="..L.UserId.."&w=150&h=150", ZIndex=21, Parent=SF}
cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=Avatar}
cr"UIStroke"{Color=C.TC, Thickness=1.5, Parent=Avatar}
local StatText=cr"TextLabel"{Size=UDim2.new(1,-120,1,-10), Position=UDim2.new(0,110,0,5), BackgroundTransparency=1, Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=C.XC, TextXAlignment=Enum.TextXAlignment.Left, TextStrokeTransparency=0.8, TextStrokeColor3=Color3.fromRGB(0,0,0), RichText=true, Parent=SF}
local SF_Scale=cr"UIScale"{Scale=0, Parent=SF}

local mOpen,sfOpen,islandOpen=false,false,false
local function toggleMain()
    mOpen=not mOpen
    if mOpen then M.Visible=true; T:Create(M_Scale, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Scale=1}):Play()
    else local tw=T:Create(M_Scale, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Scale=0}); tw:Play(); tw.Completed:Connect(function() if not mOpen then M.Visible=false end end) end
end
local function toggleStats()
    sfOpen=not sfOpen
    if sfOpen then SF.Visible=true; T:Create(SF_Scale, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Scale=1}):Play()
    else local tw=T:Create(SF_Scale, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Scale=0}); tw:Play(); tw.Completed:Connect(function() if not sfOpen then SF.Visible=false end end) end
end
local function toggleIsland()
    islandOpen=not islandOpen
    T:Create(DI, TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,345,0,33)}):Play()
    task.delay(0.08, function() T:Create(DI, TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,360,0,36)}):Play() end)
    if islandOpen then DIM.Visible=true; T:Create(DIM, TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,200,0,125)}):Play()
    else local tw=T:Create(DIM, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Size=UDim2.new(0,200,0,0)}); tw:Play(); tw.Completed:Connect(function() if not islandOpen then DIM.Visible=false end end) end
end

local function createDIMButton(text, cb)
    local btn=cr"TextButton"{Size=UDim2.new(0.9,0,0,32), BackgroundColor3=C.PC, BackgroundTransparency=0.2, Font=Enum.Font.GothamBold, Text=text, TextColor3=C.TC, TextSize=11, ZIndex=26, Parent=DIM}
    cr"UICorner"{CornerRadius=UDim.new(0,6), Parent=btn}
    cr"UIStroke"{Color=C.TC, Thickness=1, Parent=btn}
    btn.MouseButton1Click:Connect(cb)
end
createDIMButton("🏠 Главное меню", toggleMain)
createDIMButton("📊 Статистика", toggleStats)
createDIMButton("❌ Закрыть всё", function() if islandOpen then toggleIsland() end if mOpen then toggleMain() end if sfOpen then toggleStats() end end)
DI.MouseButton1Click:Connect(toggleIsland)

local MB=cr"TextButton"{Name="MobileToggle", Size=UDim2.new(0,50,0,50), Position=UDim2.new(1,-70,1,-70), BackgroundColor3=C.TC, Font=Enum.Font.GothamBold, Text="🌸", TextColor3=Color3.new(1,1,1), TextSize=22, Active=true, ZIndex=40, Parent=H}
cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=MB}
cr"UIStroke"{Color=Color3.new(1,1,1), Thickness=2, Parent=MB}
local mdr,mds,msp,mdg
MB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then mdr=true; mds=i.Position; msp=MB.Position end end)
MB.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement then mdg=i end end)
U.InputChanged:Connect(function(i) if i==mdg and mdr then local d=i.Position-mds; MB.Position=UDim2.new(msp.X.Scale, msp.X.Offset+d.X, msp.Y.Scale, msp.Y.Offset+d.Y) end end)
U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then mdr=false end end)
MB.MouseButton1Click:Connect(toggleIsland)

local fps,lastTime2,frames=0,os.clock(),0
R.RenderStepped:Connect(function() frames=frames+1; local now=os.clock(); if now-lastTime2>=0.5 then fps=math.floor(frames/(now-lastTime2)); frames=0; lastTime2=now end end)
task.spawn(function()
    while task.wait(0.4) do
        local ping=math.floor(L:GetNetworkPing()*1000)
        PingLabel.Text="Ping: "..ping.."ms"
        FpsLabel.Text="FPS: "..fps
        if SF.Visible and L.Character and L.Character:FindFirstChild("HumanoidRootPart") then
            local pos=L.Character.HumanoidRootPart.Position
            local speed=math.floor(L.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude)
            local rankTag=L.Name=="hoik_golh5" and '<font color="rgb(255,0,0)"><b>OWNER</b></font>' or '<font color="rgb(255,255,255)">Игрок</font>'
            StatText.Text=string.format("<b>User:</b> %s<br/><b>Rank:</b> %s<br/><b>Speed:</b> %d st/s<br/><b>X:</b> %.1f<br/><b>Y:</b> %.1f<br/><b>Z:</b> %.1f", L.Name, rankTag, speed, pos.X, pos.Y, pos.Z)
        end
    end
end)

-- ========== ПРОВЕРКА ВИДИМОСТИ ==========
local function isVisible(targetChar)
    local head=targetChar:FindFirstChild("Head")
    if not head then return false end
    local cameraPos=workspace.CurrentCamera.CFrame.Position
    local targetPos=head.Position
    local direction=(targetPos-cameraPos).Unit
    local distance=(targetPos-cameraPos).Magnitude
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Blacklist
    local ignoreList={}
    if L.Character then for _,part in ipairs(L.Character:GetDescendants()) do if part:IsA("BasePart") then table.insert(ignoreList,part) end end end
    for _,part in ipairs(targetChar:GetDescendants()) do if part:IsA("BasePart") then table.insert(ignoreList,part) end end
    params.FilterDescendantsInstances=ignoreList
    local result=workspace:Raycast(cameraPos, direction*distance, params)
    return result==nil
end

local Cam=W.CurrentCamera
local function getTarget()
    if not L.Character or not L.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPos=L.Character.HumanoidRootPart.Position
    local players=P:GetPlayers()
    local candidates={}
    local viewportSize=Cam.ViewportSize
    local center=Vector2.new(viewportSize.X/2, viewportSize.Y/2)
    local radius=getFOVRadius()
    for _,pl in ipairs(players) do
        if pl~=L and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and pl.Character:FindFirstChild("Humanoid") and pl.Character.Humanoid.Health>0 then
            if isVisible(pl.Character) then
                if C.AimOnlyEnemy then end
                local targetPos=pl.Character.HumanoidRootPart.Position
                local screenPos,onScreen=Cam:WorldToViewportPoint(targetPos)
                if onScreen then
                    local screenVec=Vector2.new(screenPos.X, screenPos.Y)
                    local distFromCenter=(screenVec-center).Magnitude
                    if distFromCenter<=radius then
                        local dist3D=(targetPos-myPos).Magnitude
                        table.insert(candidates, {pl=pl, dist=dist3D, health=pl.Character.Humanoid.Health, maxHealth=pl.Character.Humanoid.MaxHealth, pos=targetPos})
                    end
                end
            end
        end
    end
    if #candidates==0 then return nil end
    if C.AimType==1 then table.sort(candidates, function(a,b) return a.dist<b.dist end); return candidates[1].pl
    elseif C.AimType==2 then table.sort(candidates, function(a,b) return (a.health/a.maxHealth)<(b.health/b.maxHealth) end); return candidates[1].pl
    elseif C.AimType==3 then
        local bestCenter=math.huge; local bestPl=nil
        for _,cand in ipairs(candidates) do
            local sA,onA=Cam:WorldToViewportPoint(cand.pos)
            if onA then
                local d=(Vector2.new(sA.X,sA.Y)-center).Magnitude
                if d<bestCenter then bestCenter=d; bestPl=cand.pl end
            end
        end
        return bestPl
    elseif C.AimType==4 then return candidates[math.random(1,#candidates)].pl
    elseif C.AimType==5 then table.sort(candidates, function(a,b) return a.dist>b.dist end); return candidates[1].pl end
    return nil
end

local function doTeleport()
    local target=getTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myChar=L.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame=target.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3)
        end
    end
end

-- Перетаскивание окон
local dr,dg,ds,sp
M.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true; ds=i.Position; sp=M.Position end end)
M.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dg=i end end)
local sdr,sdg,sds,ssp
SF.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sdr=true; sds=i.Position; ssp=SF.Position end end)
SF.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then sdg=i end end)
U.InputChanged:Connect(function(i)
    if i==dg and dr then local d=i.Position-ds; M.Position=UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y) end
    if i==sdg and sdr then local d=i.Position-sds; SF.Position=UDim2.new(ssp.X.Scale, ssp.X.Offset+d.X, ssp.Y.Scale, ssp.Y.Offset+d.Y) end
end)
U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false; sdr=false end end)

-- Резкий поворот тела (для аимбота)
local aimGyro=nil
local function updateAimBody(target)
    local char=L.Character
    if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local targetPos=target.Character.Head.Position
        local rootPos=root.Position
        local lookAt=CFrame.lookAt(rootPos, targetPos)
        if hum then hum.AutoRotate=false end
        if not aimGyro or aimGyro.Parent~=root then
            if aimGyro then aimGyro:Destroy() end
            aimGyro=Instance.new("BodyGyro")
            aimGyro.Name="AimGyro"
            aimGyro.MaxTorque=Vector3.new(1e6,1e6,1e6)
            aimGyro.P=100000
            aimGyro.D=0
            aimGyro.Parent=root
        end
        aimGyro.CFrame=lookAt
    else
        if aimGyro then aimGyro:Destroy(); aimGyro=nil end
        if hum then hum.AutoRotate=true end
    end
end

-- Третье лицо
local function toggleThirdPerson()
    thirdPerson=not thirdPerson
    local cam=W.CurrentCamera
    if thirdPerson then originalCameraType=cam.CameraType; cam.CameraType=Enum.CameraType.Scriptable
    else cam.CameraType=originalCameraType end
end

-- ========== ОСНОВНОЙ ЦИКЛ ==========
R.RenderStepped:Connect(function()
    if X then X.Rotation=(tick()*60)%360 end
    -- Третье лицо
    if thirdPerson and L.Character and L.Character:FindFirstChild("HumanoidRootPart") then
        local root=L.Character.HumanoidRootPart
        local cam=W.CurrentCamera
        local distance=15
        local lookVector=cam.CFrame.LookVector
        local offset=-lookVector*distance
        local targetPos=root.Position+Vector3.new(0,2,0)+offset
        cam.CFrame=CFrame.new(targetPos, root.Position+Vector3.new(0,2,0))
    end
    -- Проверка ПКМ
    local rmbPressed=U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    local aimbotActive=false
    if a and C.A then
        if C.AimbotOnRMB then
            if rmbPressed then aimbotActive=true end
        else aimbotActive=true end
    end
    -- Аимбот
    if aimbotActive then
        local t=getTarget()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            updateAimBody(t)
            if not C.SilentAim then
                Cam.CFrame=CFrame.lookAt(Cam.CFrame.Position, t.Character.Head.Position)*CFrame.Angles(math.rad(-1.7),0,0)
            else
                _G.SilentTarget=t
            end
            if C.Triggerbot then
                local now=tick()
                if now-lastTriggerTime>0.1 then
                    local mouse=L:GetMouse()
                    if mouse then mouse1click() end
                    lastTriggerTime=now
                end
            end
        else updateAimBody(nil) end
    else updateAimBody(nil) end

    -- === УПРАВЛЕНИЕ СПИНБОТОМ ===
    local char = L.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local spinActive = C.Spinbot and not aimbotActive
            if spinActive then
                if not spinBodyVelocity or spinBodyVelocity.Parent ~= root then
                    if spinBodyVelocity then spinBodyVelocity:Destroy() end
                    spinBodyVelocity = Instance.new("BodyAngularVelocity")
                    spinBodyVelocity.Name = "SpinBotVelocity"
                    spinBodyVelocity.MaxTorque = Vector3.new(0, 4000, 0)
                    spinBodyVelocity.AngularVelocity = Vector3.new(0, math.rad(C.SpinSpeed), 0)
                    spinBodyVelocity.Parent = root
                else
                    spinBodyVelocity.AngularVelocity = Vector3.new(0, math.rad(C.SpinSpeed), 0)
                end
            else
                if spinBodyVelocity then
                    spinBodyVelocity:Destroy()
                    spinBodyVelocity = nil
                end
            end
        end
    end

    -- === ANTI AIM ===
    if C.AntiAim and char and char:FindFirstChild("HumanoidRootPart") and not aimbotActive then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = false end
        if not antiAimGyro or antiAimGyro.Parent ~= root then
            if antiAimGyro then antiAimGyro:Destroy() end
            antiAimGyro = Instance.new("BodyGyro")
            antiAimGyro.Name = "AntiAimGyro"
            antiAimGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
            antiAimGyro.P = 1000
            antiAimGyro.D = 100
            antiAimGyro.Parent = root
        end
        local angle = math.sin(tick() * C.AntiAimSpeed) * 10
        local lookAt = root.CFrame * CFrame.Angles(0, math.rad(angle), 0)
        antiAimGyro.CFrame = lookAt
    else
        if antiAimGyro then
            antiAimGyro:Destroy()
            antiAimGyro = nil
        end
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").AutoRotate = true
        end
    end

    -- === BUNNY HOP ===
    if C.Bhop and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and U:IsKeyDown(Enum.KeyCode.Space) then
            local now = tick()
            if hum.FloorMaterial ~= Enum.Material.Air and now - lastJumpTime > 0.15 then
                hum.Jump = true
                lastJumpTime = now
            end
        end
    end
end)

-- ========== КЛАВИШИ ==========
local pV, pG
U.InputBegan:Connect(function(i, pr)
    if pr then return end
    if i.KeyCode==Enum.KeyCode.Insert then toggleMain() end
    if i.KeyCode==Enum.KeyCode.B then toggleThirdPerson() end
    if i.KeyCode==C.AB then a=not a; updateFOVCircle(); if not a then updateAimBody(nil) end end
    if i.KeyCode==C.SAB then C.SilentAim=not C.SilentAim end
    if i.KeyCode==C.SB then s=not s end
    if i.KeyCode==C.XB then doTeleport() end
    if i.KeyCode==C.EB then
        e=not e
        for _,pl in ipairs(P:GetPlayers()) do if pl.Character then for _,obj in ipairs(pl.Character:GetDescendants()) do if obj:IsA("Highlight") or obj:IsA("BillboardGui") then obj:Destroy() end end end end
    end
    if i.KeyCode==C.FB then
        f=not f
        if not f then if pV then pV:Destroy() end if pG then pG:Destroy() end if L.Character and L.Character:FindFirstChild("Humanoid") then L.Character.Humanoid.PlatformStand=false end end
    end
    if i.KeyCode==C.IB and C.I then
        v=not v
        local char=L.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root=char.HumanoidRootPart
            if v then z=root.CFrame; root.CFrame=root.CFrame*CFrame.new(0,-500,0); root.Anchored=true
            else root.Anchored=false; root.CFrame=z end
        end
    end
    if i.KeyCode==C.PB then p=not p end
end)

-- Heartbeat
R.Heartbeat:Connect(function(dt)
    local c=L.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    local r=c and c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end
    if C.AH and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
    h.JumpPower=C.JP
    if Cam then Cam.FieldOfView=C.FV2 end
    if not v then
        h.WalkSpeed=(s and C.S and not f) and C.WV or 16
    else
        h.WalkSpeed=0
        local dir=Vector3.new(0,0,0)
        if U:IsKeyDown(Enum.KeyCode.W) then dir=dir+Cam.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.S) then dir=dir-Cam.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.A) then dir=dir-Cam.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.D) then dir=dir+Cam.CFrame.RightVector end
        if dir.Magnitude>0 then z=z+Vector3.new(dir.X,0,dir.Z).Unit*(C.WV/60) end
    end
    if f and C.F and not v then
        h.PlatformStand=true
        if not r:FindFirstChild("SakuraFlyVelocity") then
            pV=cr"BodyVelocity"{Name="SakuraFlyVelocity", maxForce=Vector3.new(1,1,1)*math.huge, Parent=r}
            pG=cr"BodyGyro"{Name="SakuraFlyGyro", maxTorque=Vector3.new(1,1,1)*math.huge, cframe=r.CFrame, Parent=r}
        end
        local dir=Vector3.new(0,0,0)
        if U:IsKeyDown(Enum.KeyCode.W) then dir=dir+Cam.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.S) then dir=dir-Cam.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.A) then dir=dir-Cam.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.D) then dir=dir+Cam.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if U:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        pG.cframe=Cam.CFrame
        pV.velocity=dir.Unit*C.FV
        if dir==Vector3.new(0,0,0) then pV.velocity=Vector3.new(0,0,0) end
    end
end)

-- ESP
local function esp(pl)
    if pl==L then return end
    local function setup(char)
        local root=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not root or not hum then return end
        for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Highlight") or obj:IsA("BillboardGui") then obj:Destroy() end end
        if e and C.E then
            local highlight=cr"Highlight"{Name="SakuraESP_Highlight", FillColor=C.WH and C.ESPColor or Color3.new(1,1,1), FillTransparency=C.WH and 0.5 or 0.8, OutlineColor=Color3.new(1,1,1), OutlineTransparency=0.1, Adornee=char, Parent=char}
            local bb=cr"BillboardGui"{Name="SakuraESP_BB", AlwaysOnTop=true, Size=UDim2.new(0,200,0,80), StudsOffset=Vector3.new(0,3,0), Adornee=root, Parent=char}
            local layout=cr"UIListLayout"{Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Top, Parent=bb}
            if C.BoxESP then local box=cr"Frame"{Size=UDim2.new(0,30,0,50), BackgroundColor3=C.ESPColor, BackgroundTransparency=0.6, BorderSizePixel=0, Position=UDim2.new(0.5,-15,0,0), Parent=bb}; cr"UIStroke"{Color=C.ESPColor, Thickness=C.LineThickness, Parent=box} end
            if C.SkeletonESP then cr"TextLabel"{Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="🧍", TextColor3=C.ESPColor, TextSize=20, Font=Enum.Font.GothamBold, Parent=bb} end
            if C.NameESP then cr"TextLabel"{Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=pl.Name, TextColor3=C.ESPColor, TextSize=14, Font=Enum.Font.GothamBold, Parent=bb} end
            if C.HealthBar then
                local hpFrame=cr"Frame"{Size=UDim2.new(0,60,0,6), BackgroundColor3=Color3.fromRGB(50,50,50), Parent=bb}
                cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=hpFrame}
                local hpFill=cr"Frame"{Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,255,0), Parent=hpFrame}
                cr"UICorner"{CornerRadius=UDim.new(1,0), Parent=hpFill}
                local function updateHealth() local health=hum.Health/hum.MaxHealth; hpFill.Size=UDim2.new(math.clamp(health,0,1),0,1,0); hpFill.BackgroundColor3=health>0.5 and Color3.fromRGB(0,255,0) or health>0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0) end
                updateHealth(); hum.HealthChanged:Connect(updateHealth)
            end
            if C.DistESP then
                local distLbl=cr"TextLabel"{Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="", TextColor3=C.ESPColor, TextSize=12, Font=Enum.Font.GothamMedium, Parent=bb}
                task.spawn(function()
                    while bb.Parent and e and C.E do
                        if L.Character and L.Character:FindFirstChild("HumanoidRootPart") and root then
                            local dist=(root.Position-L.Character.HumanoidRootPart.Position).Magnitude
                            distLbl.Text=string.format("%.1f м", dist)
                        end
                        task.wait(0.3)
                    end
                end)
            end
        end
    end
    if pl.Character then setup(pl.Character) end
    pl.CharacterAdded:Connect(setup)
end
for _,pl in ipairs(P:GetPlayers()) do esp(pl) end
R.RenderStepped:Connect(function()
    if e and C.E then
        for _,pl in ipairs(P:GetPlayers()) do
            if pl.Character and not pl.Character:FindFirstChild("SakuraESP_BB") then esp(pl) end
        end
    end
end)

-- Инициализация
applyCustomColors()
updateFOVCircle()
updateSpinbot()
