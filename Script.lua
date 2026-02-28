local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lP = Players.LocalPlayer

-- Remove UI antiga
local old = lP.PlayerGui:FindFirstChild("FollowMenu")
if old then old:Destroy() end

-- ================= CONFIGURAÇÕES E ESTADOS =================
local Config = {
    OffsetX = 0, OffsetY = 0, OffsetZ = 0,
    Orbit = false, FaceTarget = false, Noclip = false,
    Ghost = false, AutoFlip = false, Spinbot = false,
    MatchSpeed = false, Prediction = false, BrakeOnStop = false,
    Tracer = false
}

-- ================= UI PRINCIPAL =================
local gui = Instance.new("ScreenGui")
gui.Name = "FollowMenu"
gui.ResetOnSpawn = false
gui.Parent = lP.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 400)
main.Position = UDim2.new(0.5, -170, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1
stroke.Transparency = 0.8

-- Drag System
local dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "VEHICLE FOLLOW V2"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- Top Controls (Player Select & Delay)
local topContainer = Instance.new("Frame", main)
topContainer.Size = UDim2.new(1, 0, 0, 110)
topContainer.Position = UDim2.new(0, 0, 0, 35)
topContainer.BackgroundTransparency = 1

local playerDropdown = Instance.new("TextButton", topContainer)
playerDropdown.Size = UDim2.new(0.9, 0, 0, 30)
playerDropdown.Position = UDim2.new(0.05, 0, 0, 0)
playerDropdown.Text = "Select Player"
playerDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerDropdown.TextColor3 = Color3.new(1, 1, 1)
playerDropdown.Font = Enum.Font.GothamMedium
Instance.new("UICorner", playerDropdown).CornerRadius = UDim.new(0, 8)

local searchBar = Instance.new("TextBox", topContainer)
searchBar.Size = UDim2.new(0.9, 0, 0, 30)
searchBar.Position = UDim2.new(0.05, 0, 0, 35)
searchBar.PlaceholderText = "Search player..."
searchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchBar.TextColor3 = Color3.new(1, 1, 1)
searchBar.Font = Enum.Font.Gotham
searchBar.Visible = false
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 8)

local delayBox = Instance.new("TextBox", topContainer)
delayBox.Size = UDim2.new(0.9, 0, 0, 30)
delayBox.Position = UDim2.new(0.05, 0, 0, 70)
delayBox.PlaceholderText = "Delay (ex: 0.2)"
delayBox.Text = "0.2"
delayBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
delayBox.TextColor3 = Color3.new(1, 1, 1)
delayBox.Font = Enum.Font.Gotham
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 8)

local playerList = Instance.new("ScrollingFrame", main)
playerList.Size = UDim2.new(0.9, 0, 0, 100)
playerList.Position = UDim2.new(0.05, 0, 0, 100)
playerList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
playerList.Visible = false
playerList.ZIndex = 10
Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 8)
local listLayout = Instance.new("UIListLayout", playerList)
listLayout.Padding = UDim.new(0, 2)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function atualizarLista()
    for _, child in pairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == lP then continue end
        local btn = Instance.new("TextButton", playerList)
        btn.Size = UDim2.new(0.95, 0, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham; btn.TextSize = 12
        btn.Text = plr.Name; btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            playerDropdown.Text = plr.Name
            playerList.Visible = false; searchBar.Visible = false
        end)
    end
    playerList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
end

searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local filter = searchBar.Text:lower()
    for _, btn in pairs(playerList:GetChildren()) do
        if btn:IsA("TextButton") then btn.Visible = btn.Text:lower():find(filter) ~= nil end
    end
end)

playerDropdown.MouseButton1Click:Connect(function()
    local state = not playerList.Visible
    playerList.Visible = state; searchBar.Visible = state
    if state then atualizarLista() end
end)

-- Feature Scroll List
local featuresScroll = Instance.new("ScrollingFrame", main)
featuresScroll.Size = UDim2.new(0.9, 0, 0, 190)
featuresScroll.Position = UDim2.new(0.05, 0, 0, 150)
featuresScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
featuresScroll.ScrollBarThickness = 4
Instance.new("UICorner", featuresScroll).CornerRadius = UDim.new(0, 8)
local featLayout = Instance.new("UIListLayout", featuresScroll)
featLayout.Padding = UDim.new(0, 5)
featLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper para criar botões Toggle
local function createToggle(name, text)
    local btn = Instance.new("TextButton", featuresScroll)
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham; btn.TextSize = 12
    btn.Text = text .. " [OFF]"
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        Config[name] = not Config[name]
        btn.Text = text .. (Config[name] and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = Config[name] and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(40, 40, 40)
    end)
end

local function createInput(name, placeholder)
    local box = Instance.new("TextBox", featuresScroll)
    box.Size = UDim2.new(0.95, 0, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham; box.TextSize = 12
    box.PlaceholderText = placeholder; box.Text = ""
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        Config[name] = tonumber(box.Text) or 0
    end)
end

local function createActionBtn(text, color, callback)
    local btn = Instance.new("TextButton", featuresScroll)
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

-- Criando as 15 novas funções na UI
createInput("OffsetX", "Offset X (Lados)")
createInput("OffsetY", "Offset Y (Altura)")
createInput("OffsetZ", "Offset Z (Frente/Trás)")
createToggle("Orbit", "Orbit Mode")
createToggle("FaceTarget", "Face Target")
createToggle("Noclip", "Noclip Vehicle")
createToggle("Ghost", "Ghost Mode")
createToggle("AutoFlip", "Auto Flip")
createToggle("Spinbot", "Spinbot")
createToggle("MatchSpeed", "Match Speed")
createToggle("Prediction", "Predict Movement")
createToggle("BrakeOnStop", "Brake On Target Stop")
createToggle("Tracer", "Tracer ESP (Linha)")

featuresScroll.CanvasSize = UDim2.new(0, 0, 0, featLayout.AbsoluteContentSize.Y + 10)
featLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    featuresScroll.CanvasSize = UDim2.new(0, 0, 0, featLayout.AbsoluteContentSize.Y + 10)
end)

-- Botões Inferiores Principais
local bottomFrame = Instance.new("Frame", main)
bottomFrame.Size = UDim2.new(1, 0, 0, 45)
bottomFrame.Position = UDim2.new(0, 0, 1, -45)
bottomFrame.BackgroundTransparency = 1

local iniciarBtn = Instance.new("TextButton", bottomFrame)
iniciarBtn.Size = UDim2.new(0.43, 0, 0, 35)
iniciarBtn.Position = UDim2.new(0.05, 0, 0, 5)
iniciarBtn.Text = "START"
iniciarBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
iniciarBtn.TextColor3 = Color3.new(1,1,1); iniciarBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", iniciarBtn).CornerRadius = UDim.new(0, 8)

local pararBtn = Instance.new("TextButton", bottomFrame)
pararBtn.Size = UDim2.new(0.43, 0, 0, 35)
pararBtn.Position = UDim2.new(0.52, 0, 0, 5)
pararBtn.Text = "STOP"
pararBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
pararBtn.TextColor3 = Color3.new(1,1,1); pararBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", pararBtn).CornerRadius = UDim.new(0, 8)

-- ================= LÓGICA DE SEGUIR E FUNÇÕES =================
local seguindo = false
local connection, linear, angular, attach
local tracerBeam, tracerAtt0, tracerAtt1
local MAX_SPEED = 350

local function acharModelo(obj)
    while obj and obj ~= workspace do
        if obj:IsA("Model") then return obj end
        obj = obj.Parent
    end
end

local function pegarMeuVeiculo()
    local char = lP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end
    return acharModelo(hum.SeatPart)
end

local function limparInstancias()
    if connection then connection:Disconnect() connection = nil end
    if linear then linear:Destroy() linear = nil end
    if angular then angular:Destroy() angular = nil end
    if attach then attach:Destroy() attach = nil end
    if tracerBeam then tracerBeam:Destroy() tracerAtt0:Destroy() tracerAtt1:Destroy() tracerBeam = nil end
    
    -- Restaura Ghost Mode e Noclip
    local veiculo = pegarMeuVeiculo()
    if veiculo then
        for _, part in pairs(veiculo:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = part:GetAttribute("OldTrans") or part.Transparency
                part.CanCollide = part:GetAttribute("OldCol") or part.CanCollide
            end
        end
    end
end

-- Func 14 e 15 integradas na lista
createActionBtn("Instant Teleport", Color3.fromRGB(150, 80, 200), function()
    local targetPlr = Players:FindFirstChild(playerDropdown.Text)
    local me = pegarMeuVeiculo()
    if targetPlr and targetPlr.Character and me then
        local tHum = targetPlr.Character:FindFirstChildOfClass("Humanoid")
        if tHum and tHum.SeatPart then
            me:PivotTo(tHum.SeatPart.CFrame * CFrame.new(0, 10, 0))
        end
    end
end)

createActionBtn("Destroy UI", Color3.fromRGB(100, 100, 100), function()
    seguindo = false
    limparInstancias()
    gui:Destroy()
end)

pararBtn.MouseButton1Click:Connect(function()
    seguindo = false
    limparInstancias()
end)

iniciarBtn.MouseButton1Click:Connect(function()
    if seguindo then return end
    local targetPlr = Players:FindFirstChild(playerDropdown.Text)
    if not targetPlr then return end
    local meuVeiculo = pegarMeuVeiculo()
    if not meuVeiculo or not meuVeiculo.PrimaryPart then return end

    seguindo = true
    local primaryMeu = meuVeiculo.PrimaryPart
    local delayTempo = tonumber(delayBox.Text) or 0.2
    
    attach = Instance.new("Attachment", primaryMeu)
    linear = Instance.new("LinearVelocity", primaryMeu)
    linear.Attachment0 = attach; linear.MaxForce = math.huge
    angular = Instance.new("AngularVelocity", primaryMeu)
    angular.Attachment0 = attach; angular.MaxTorque = math.huge

    local buffer = {}
    local orbitAngle = 0

    -- Setup original de transparência/colisão
    for _, part in pairs(meuVeiculo:GetDescendants()) do
        if part:IsA("BasePart") then
            part:SetAttribute("OldTrans", part.Transparency)
            part:SetAttribute("OldCol", part.CanCollide)
        end
    end

    connection = RunService.Heartbeat:Connect(function(dt)
        local tChar = targetPlr.Character
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        local tSeat = tHum and tHum.SeatPart
        local tVeiculo = tSeat and acharModelo(tSeat)

        -- Visuals (Ghost, Noclip)
        for _, part in pairs(meuVeiculo:GetDescendants()) do
            if part:IsA("BasePart") then
                if Config.Ghost then part.Transparency = 1 else part.Transparency = part:GetAttribute("OldTrans") end
                if Config.Noclip then part.CanCollide = false else part.CanCollide = part:GetAttribute("OldCol") end
            end
        end

        if tVeiculo and tVeiculo.PrimaryPart then
            local pAlvo = tVeiculo.PrimaryPart
            
            -- Tracer ESP
            if Config.Tracer then
                if not tracerBeam then
                    tracerAtt0 = Instance.new("Attachment", primaryMeu)
                    tracerAtt1 = Instance.new("Attachment", pAlvo)
                    tracerBeam = Instance.new("Beam", primaryMeu)
                    tracerBeam.Attachment0 = tracerAtt0; tracerBeam.Attachment1 = tracerAtt1
                    tracerBeam.FaceCamera = true; tracerBeam.Color = ColorSequence.new(Color3.new(1,0,0))
                    tracerBeam.Width0 = 0.5; tracerBeam.Width1 = 0.5
                end
            elseif tracerBeam then
                tracerBeam:Destroy() tracerAtt0:Destroy() tracerAtt1:Destroy() tracerBeam = nil
            end

            -- Adiciona Offset e Previsão
            local targetCF = pAlvo.CFrame
            if Config.Prediction then
                targetCF = targetCF + (pAlvo.AssemblyLinearVelocity * delayTempo)
            end
            targetCF = targetCF * CFrame.new(Config.OffsetX, Config.OffsetY, Config.OffsetZ)

            table.insert(buffer, {
                t = tick(),
                cf = targetCF,
                lv = pAlvo.AssemblyLinearVelocity,
                av = pAlvo.AssemblyAngularVelocity
            })

            if tick() - buffer[1].t >= delayTempo then
                local data = table.remove(buffer, 1)
                local finalCF = data.cf

                -- Orbit
                if Config.Orbit then
                    orbitAngle = orbitAngle + math.rad(5)
                    finalCF = finalCF * CFrame.Angles(0, orbitAngle, 0) * CFrame.new(0, 0, -20)
                end

                local diff = finalCF.Position - primaryMeu.Position
                local vel = data.lv + (diff * 7)

                -- Brake On Stop
                if Config.BrakeOnStop and data.lv.Magnitude < 2 then
                    vel = Vector3.new(0, 0, 0)
                end

                -- Match Speed
                if Config.MatchSpeed and vel.Magnitude > data.lv.Magnitude * 1.5 then
                    vel = vel.Unit * (data.lv.Magnitude * 1.5)
                end

                if vel.Magnitude > MAX_SPEED then vel = vel.Unit * MAX_SPEED end
                linear.VectorVelocity = vel

                -- Rotação Múltipla
                if Config.Spinbot then
                    angular.AngularVelocity = Vector3.new(0, 50, 0)
                elseif Config.FaceTarget then
                    local lookCF = CFrame.lookAt(primaryMeu.Position, pAlvo.Position)
                    local rotDiff = lookCF * primaryMeu.CFrame:Inverse()
                    local axis, angle = rotDiff:ToAxisAngle()
                    angular.AngularVelocity = axis * angle * 12
                elseif Config.AutoFlip then
                    local rx, ry, rz = data.cf:ToOrientation()
                    local flatCF = CFrame.new(primaryMeu.Position) * CFrame.Angles(0, ry, 0)
                    local rotDiff = flatCF * primaryMeu.CFrame:Inverse()
                    local axis, angle = rotDiff:ToAxisAngle()
                    angular.AngularVelocity = axis * angle * 12
                else
                    local rotDiff = finalCF * primaryMeu.CFrame:Inverse()
                    local axis, angle = rotDiff:ToAxisAngle()
                    angular.AngularVelocity = data.av + (axis * angle * 12)
                end

                if diff.Magnitude > 250 then meuVeiculo:PivotTo(finalCF) end
            end
        end
    end)
end)

-- Tecla para ocultar/mostrar (RightControl)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)
