-- =============================================
--  アバタースナップショット自動適用スクリプト
--  実行するだけで指定された外見に変わります
-- =============================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ★★★ ここにあなたのJSONデータをそのまま貼り付け ★★★
local SNAPSHOT_JSON = [[
{"bodyData":[{"Transparency":1,"Name":"HumanoidRootPart","Reflectance":0,"Color":[0.6392157077789307,0.6352941393852234,0.6470588445663452],"Material":"Plastic","CastShadow":true,"Size":[2,2,1]},{"Transparency":0,"Name":"LeftHand","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,0.30010032653808596,1]},{"Transparency":0,"Name":"RightHand","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,0.30010032653808596,1]},{"Transparency":0,"Name":"LeftLowerArm","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,1.0518989562988282,1]},{"Transparency":0,"Name":"RightLowerArm","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,1.0518989562988282,1]},{"Transparency":0,"Name":"LeftUpperArm","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,1.1686992645263672,1]},{"Transparency":0,"Name":"RightUpperArm","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,1.1686992645263672,1]},{"Transparency":0,"Name":"LeftFoot","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,0.2999992370605469,1]},{"Transparency":0,"Name":"LeftLowerLeg","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,1.1930999755859376,1]},{"Transparency":0,"Name":"UpperTorso","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[2,1.6000003814697266,1]},{"Transparency":0,"Name":"LeftUpperLeg","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,1.2166004180908204,0.9998989105224609]},{"Transparency":0,"Name":"RightFoot","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,0.2999992370605469,1]},{"Transparency":0,"Name":"RightLowerLeg","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,1.1930999755859376,1]},{"Transparency":0,"Name":"LowerTorso","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[2,0.4001007080078125,1]},{"Transparency":0,"Name":"RightUpperLeg","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1,1.2166004180908204,0.9998989105224609]},{"Transparency":0,"Name":"Head","Reflectance":0,"Color":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Material":"Plastic","CastShadow":true,"Size":[1.196195125579834,1.2029438018798829,1.1979091167449952]}],"accData":[{"Offset":[0,0,0],"WeldC1":[-5.960464477539063e-8,-0.19998568296432496,0.5,1,0,0,0,1,0,0,0,1],"Name":"AngleDevilWings","Scale":[12.050902366638184,5.282670021057129,8.598469734191895],"WeldC0":[-9.094947017729282e-13,-0.5000002384185791,0.9997276067733765,1,-6.834403148901155e-31,0,6.834403148901155e-31,1,-0,0,0,1],"Transparency":0},{"Offset":[0,0,0],"WeldC1":[0,0.6000000238418579,0,1,-1.499759904157988e-32,0,1.499759904157988e-32,1,-0,0,0,1],"Name":"TrafficCone","Scale":[1.8845200538635255,2.134700059890747,1.8845200538635255],"WeldC0":[8.658389560878277e-9,-0.8019953370094299,-0.01987861841917038,1,7.871378215895675e-9,-5.0182080713057078e-14,-7.718511163545827e-9,0.9805806875228882,0.1961161196231842,1.5437532363549167e-9,-0.1961161196231842,0.9805806875228882],"Transparency":0},{"Offset":[0,0,0],"WeldC1":[0,-0.09399999678134918,0,1,-1.499759904157988e-32,0,1.499759904157988e-32,1,-0,0,0,1],"Name":"New Accessory (08/24/24 02:30:45)","Scale":[1.220639944076538,1.2261199951171876,1.3136379718780518],"WeldC0":[0.00011825560795841739,-0.012000083923339844,-0.00006890296936035156,0.9999256134033203,0,-0.012195480987429619,0,1,0,0.012195480987429619,0,0.9999256134033203],"Transparency":0}],"userId":11385086391,"displayName":"4PH","overheadsData":[],"isHeadless":false,"version":8,"hideVFX":false,"name":"4PH","descData":{"SwimAnimation":0,"MoodAnimation":0,"Face":0,"ProportionScale":0,"ClimbAnimation":0,"Shirt":11275376818,"FaceAccessory":"128722117416948","RightArmColor":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"HairAccessory":"","RightArm":0,"Head":0,"FallAnimation":0,"TorsoColor":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"DepthScale":1,"RightLeg":0,"HeightScale":1,"WaistAccessory":"","RightLegColor":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"LeftLegColor":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"JumpAnimation":0,"BodyTypeScale":0,"ShouldersAccessory":"","LeftArmColor":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"Pants":5043452820,"Torso":0,"HeadColor":[0.06666667014360428,0.06666667014360428,0.06666667014360428],"HatAccessory":"1609390589","_LayeredAccessories":[{"Rotation":[0,0,0],"AccessoryType":7,"Position":[0,0,0],"Scale":[1,1,1],"IsLayered":false,"AssetId":493489765},{"Rotation":[0,0,0],"AccessoryType":1,"Position":[0,0,0],"Scale":[1,1,1],"IsLayered":false,"AssetId":1609390589},{"Rotation":[0,0,0],"AccessoryType":3,"Position":[0,0,0],"Scale":[1,1,1],"IsLayered":false,"AssetId":128722117416948}],"WidthScale":1,"LeftLeg":0,"BackAccessory":"493489765","NeckAccessory":"","FrontAccessory":"","IdleAnimation":0,"GraphicTShirt":0,"HeadScale":1,"WalkAnimation":0,"RunAnimation":0,"LeftArm":0},"thumbnail":"rbxthumb://type=AvatarBust&id=11385086391&w=100&h=100","overheadMapData":[]}
]]

-- =============================================
--  適用処理（完全再現）
-- =============================================
local function applySnapshotToCharacter(char, snapshot)
    if not char or not snapshot then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- 1. 既存のアパレル・アクセサリーを削除
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            child:Destroy()
        end
    end

    -- 2. descData から基本アバターを適用（服・パンツ・顔・アクセサリーIDなど）
    local descData = snapshot.descData
    if descData then
        -- HumanoidDescription を作成して適用
        local desc = Instance.new("HumanoidDescription")
        for key, value in pairs(descData) do
            if key ~= "_LayeredAccessories" then
                pcall(function()
                    desc[key] = value
                end)
            end
        end
        hum:ApplyDescription(desc)

        -- 追加で _LayeredAccessories に含まれるアクセサリーも個別に読み込む
        local layered = descData._LayeredAccessories or {}
        for _, info in ipairs(layered) do
            if info.AssetId and info.AssetId ~= "" then
                local success, objs = pcall(function()
                    return game:GetObjects("rbxassetid://" .. info.AssetId)
                end)
                if success and objs and objs[1] then
                    local obj = objs[1]
                    if obj:IsA("Accessory") then
                        obj.Parent = char
                    elseif obj:IsA("Model") or obj:IsA("Folder") then
                        local acc = obj:FindFirstChildOfClass("Accessory")
                        if acc then acc.Parent = char end
                    end
                end
            end
        end
    end

    -- 3. bodyData で各パーツの詳細プロパティを上書き
    for _, partData in ipairs(snapshot.bodyData or {}) do
        local part = char:FindFirstChild(partData.Name)
        if part and part:IsA("BasePart") then
            pcall(function()
                part.Transparency = partData.Transparency or 0
                part.Reflectance = partData.Reflectance or 0
                part.Material = Enum.Material[partData.Material] or Enum.Material.Plastic
                part.CastShadow = partData.CastShadow
                if partData.Size then
                    part.Size = Vector3.new(unpack(partData.Size))
                end
                if partData.Color then
                    part.Color = Color3.new(unpack(partData.Color))
                end
            end)
        end
    end

    -- 4. accData でアクセサリーの位置・回転・スケールを調整
    for _, accInfo in ipairs(snapshot.accData or {}) do
        local acc = char:FindFirstChild(accInfo.Name)
        if acc then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                pcall(function()
                    -- スケール
                    if accInfo.Scale then
                        local mesh = handle:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", handle)
                        mesh.Scale = Vector3.new(unpack(accInfo.Scale))
                    end
                    -- 透明度
                    if accInfo.Transparency ~= nil then
                        handle.Transparency = accInfo.Transparency
                    end
                    -- オフセット
                    if accInfo.Offset then
                        handle.Position = handle.Position + Vector3.new(unpack(accInfo.Offset))
                    end
                    -- WeldC0/C1 を適用
                    local weld = handle:FindFirstChildOfClass("Weld")
                    if weld then
                        if accInfo.WeldC0 then
                            weld.C0 = CFrame.new(unpack(accInfo.WeldC0))
                        end
                        if accInfo.WeldC1 then
                            weld.C1 = CFrame.new(unpack(accInfo.WeldC1))
                        end
                    end
                end)
            end
        end
    end

    -- 5. ヘッドレスフラグがあれば適用
    if snapshot.isHeadless then
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            local face = head:FindFirstChildOfClass("Decal")
            if face then face.Transparency = 1 end
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if mesh then mesh.Scale = Vector3.new(0, 0, 0) end
        end
    end

    print("[✅] スナップショット適用完了！")
end

-- =============================================
--  実行部分（自動適用＋再スポーン時も適用）
-- =============================================
local snapshotData = HttpService:JSONDecode(SNAPSHOT_JSON)

local function onCharacterAdded(char)
    task.wait(0.5) -- 読み込み完了を待つ
    applySnapshotToCharacter(char, snapshotData)
end

-- 既にキャラが存在する場合
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- 再スポーン時にも適用
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

print("[🚀] スナップショット自動適用スクリプト起動完了")
