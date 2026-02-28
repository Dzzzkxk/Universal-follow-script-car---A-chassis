local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lP = Players.LocalPlayer

-- Remove antigo
local old = lP.PlayerGui:FindFirstChild("FollowMenu")
if old then old:Destroy() end

-- ================= GUI =================

local gui = Instance.new("ScreenGui")
gui.Name = "FollowMenu"
gui.ResetOnSpawn = false
gui.Parent = lP.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 260)
main.Position = UDim2.new(0.5, -170, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(15,15,18)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,18)

local gradient = Instance.new("UIGradient", main)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,30)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(15,15,18))
}
gradient.Rotation = 90

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0,200,255)
stroke.Thickness = 2

main.BackgroundTransparency = 1
stroke.Transparency = 1

TweenService:Create(main, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 0}):Play()

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "A-chassi follow"
title.TextColor3 = Color3.fromRGB(0,200,255)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Parent = main

local line = Instance.new("Frame")
line.Size = UDim2.new(0.8,0,0,2)
line.Position = UDim2.new(0.1,0,0,48)
line.BackgroundColor3 = Color3.fromRGB(0,200,255)
line.BorderSizePixel = 0
line.Parent = main

local nomeBox = Instance.new("TextBox")
nomeBox.Size = UDim2.new(0.85,0,0,40)
nomeBox.Position = UDim2.new(0.075,0,0.3,0)
nomeBox.PlaceholderText = "Player Name"
nomeBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
nomeBox.TextColor3 = Color3.new(1,1,1)
nomeBox.Font = Enum.Font.Gotham
nomeBox.TextSize = 16
nomeBox.BorderSizePixel = 0
nomeBox.Parent = main
Instance.new("UICorner", nomeBox).CornerRadius = UDim.new(0,12)

local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(0.85,0,0,40)
delayBox.Position = UDim2.new(0.075,0,0.5,0)
delayBox.PlaceholderText = "Delay (0.2)"
delayBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
delayBox.TextColor3 = Color3.new(1,1,1)
delayBox.Font = Enum.Font.Gotham
delayBox.TextSize = 16
delayBox.BorderSizePixel = 0
delayBox.Parent = main
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0,12)

local function criarBotao(texto, posX, cor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.4,0,0,42)
	btn.Position = UDim2.new(posX,0,0.75,0)
	btn.Text = texto
	btn.BackgroundColor3 = cor
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	btn.Parent = main
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,14)
	
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {Size = UDim2.new(0.42,0,0,44)}):Play()
	end)
	
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {Size = UDim2.new(0.4,0,0,42)}):Play()
	end)
	
	return btn
end

local iniciarBtn = criarBotao("START", 0.08, Color3.fromRGB(0,200,255))
local pararBtn = criarBotao("STOP", 0.52, Color3.fromRGB(200,60,60))

-- ================= FOLLOW =================

local seguindo = false
local connection
local linear
local angular
local attach

local MAX_SPEED = 330 -- LIMITADOR AQUI

local function acharModelo(obj)
	while obj and obj ~= workspace do
		if obj:IsA("Model") then
			return obj
		end
		obj = obj.Parent
	end
end

local function pegarMeuVeiculo()
	local char = lP.Character or lP.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	if not hum.SeatPart then return end
	return acharModelo(hum.SeatPart)
end

local function pararSistema()
	seguindo = false
	if connection then connection:Disconnect() connection = nil end
	if linear then linear:Destroy() linear = nil end
	if angular then angular:Destroy() angular = nil end
	if attach then attach:Destroy() attach = nil end
end

pararBtn.MouseButton1Click:Connect(pararSistema)

iniciarBtn.MouseButton1Click:Connect(function()

	if seguindo then return end

	local alvoNome = nomeBox.Text
	local delayTempo = tonumber(delayBox.Text) or 0.2
	if alvoNome == "" then return end

	local meuVeiculo = pegarMeuVeiculo()
	if not meuVeiculo or not meuVeiculo.PrimaryPart then return end

	local alvoPlayer = Players:FindFirstChild(alvoNome)
	if not alvoPlayer then return end

	local function esperarAlvo()
		while true do
			if alvoPlayer.Character then
				local hum = alvoPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.SeatPart then
					local modelo = acharModelo(hum.SeatPart)
					if modelo and modelo.PrimaryPart then
						return modelo
					end
				end
			end
			RunService.Heartbeat:Wait()
		end
	end

	local modeloAlvo = esperarAlvo()
	local primaryMeu = meuVeiculo.PrimaryPart
	local primaryAlvo = modeloAlvo.PrimaryPart

	attach = Instance.new("Attachment", primaryMeu)

	linear = Instance.new("LinearVelocity")
	linear.Attachment0 = attach
	linear.MaxForce = math.huge
	linear.Parent = primaryMeu

	angular = Instance.new("AngularVelocity")
	angular.Attachment0 = attach
	angular.MaxTorque = math.huge
	angular.Parent = primaryMeu

	meuVeiculo:PivotTo(primaryAlvo.CFrame)

	local buffer = {}
	seguindo = true

	connection = RunService.Heartbeat:Connect(function()

		table.insert(buffer,{
			time = tick(),
			cf = primaryAlvo.CFrame,
			linearVel = primaryAlvo.AssemblyLinearVelocity,
			angularVel = primaryAlvo.AssemblyAngularVelocity
		})

		while #buffer > 0 and tick() - buffer[1].time > delayTempo do
			local data = table.remove(buffer,1)

			local erroPos = data.cf.Position - primaryMeu.Position
			local velocidade = data.linearVel + erroPos * 8

			-- ===== LIMITADOR DE VELOCIDADE =====
			if velocidade.Magnitude > MAX_SPEED then
				velocidade = velocidade.Unit * MAX_SPEED
			end

			linear.VectorVelocity = velocidade

			local erroCF = data.cf * primaryMeu.CFrame:Inverse()
			local axis, angle = erroCF:ToAxisAngle()
			angular.AngularVelocity = data.angularVel + axis * angle * 10

			if erroPos.Magnitude > 20 then
				meuVeiculo:PivotTo(data.cf)
			end
		end
	end)

end)
