-- Serviços
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Variáveis de Controle
local coletaAtivada = false
local tesouroAtivo = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--============================--
--== COLETA DE ITENS (EGGS) ==--
--============================--

local coletaButton = Instance.new("TextButton")
coletaButton.Name = "ToggleColeta"
coletaButton.Size = UDim2.new(0, 160, 0, 40)
coletaButton.Position = UDim2.new(0, 20, 0, 100)
coletaButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
coletaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
coletaButton.Font = Enum.Font.SourceSansBold
coletaButton.TextSize = 18
coletaButton.Text = "Auto-Coleta 🟦"
coletaButton.Parent = gui

coletaButton.MouseButton1Click:Connect(function()
	coletaAtivada = not coletaAtivada
	if coletaAtivada then
		coletaButton.Text = "Coleta Ativa ✅"
		coletaButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
	else
		coletaButton.Text = "Auto-Coleta 🟦"
		coletaButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
	end
end)

local function teleportToItem(item)
	if item and item:IsA("BasePart") then
		hrp.CFrame = item.CFrame + Vector3.new(0, 6, 0) -- 6 studs acima
		print("✔️ Teleportado para o item:", item.Name)
		task.wait(0.3)
	end
end

task.spawn(function()
	while true do
		if coletaAtivada then
			local folder = workspace:FindFirstChild("CollectItemEntity")
			if folder then
				for _, item in pairs(folder:GetChildren()) do
					if item:IsA("Model") then
						local itemPart = item:FindFirstChild("Item")
						if itemPart and itemPart:IsA("BasePart") then
							teleportToItem(itemPart)
						else
							print("❌ Parte 'Item' não encontrada no modelo:", item.Name)
						end
					end
				end
			else
				print("❌ Pasta CollectItemEntity não encontrada!")
			end
		end
		task.wait(3)
	end
end)

--============================--
--====== AUTO TESOURO 💰 =====--
--============================--

local tesouroButton = Instance.new("TextButton")
tesouroButton.Name = "ToggleTesouro"
tesouroButton.Size = UDim2.new(0, 160, 0, 40)
tesouroButton.Position = UDim2.new(0, 20, 0, 150)
tesouroButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
tesouroButton.TextColor3 = Color3.new(1, 1, 1)
tesouroButton.Font = Enum.Font.SourceSansBold
tesouroButton.TextSize = 18
tesouroButton.Text = "Auto-Tesouro 🟢"
tesouroButton.Parent = gui

tesouroButton.MouseButton1Click:Connect(function()
	tesouroAtivo = not tesouroAtivo
	if tesouroAtivo then
		tesouroButton.Text = "Auto-Tesouro 🟢"
		tesouroButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		tesouroButton.Text = "Desativado 🔴"
		tesouroButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	end
end)

local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(part)
	local hrp = getHRP()
	if hrp and part and part:IsA("BasePart") then
		hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0) -- 6 studs acima
		print("💰 Teleportado para:", part:GetFullName())
		wait(2) -- Espera de 2 segundos após o teleporte, para garantir que o jogador tenha tempo de coletar
	else
		print("❌ Erro ao teleportar. HRP ou parte não encontrados.")
	end
end

-- Simular tecla F automaticamente
task.spawn(function()
	while true do
		if tesouroAtivo then
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
			wait(0.05)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
		end
		wait(0.1)
	end
end)

-- Loop de teleporte em tesouros (com delay de 2 segundos após cada teleporte)
task.spawn(function()
	while true do
		if tesouroAtivo then
			local treasureFolder = workspace:FindFirstChild("TreasureEntity")
			if treasureFolder then
				for _, treasure in ipairs(treasureFolder:GetChildren()) do
					if treasure:IsA("Model") then
						local teleportado = false -- Garantir que só teleportamos uma vez por baú
						-- Vamos percorrer as partes dentro do baú
						for _, part in ipairs(treasure:GetDescendants()) do
							if part:IsA("Part") or part:IsA("MeshPart") then
								if not teleportado then
									teleportTo(part)  -- Teleporta para o baú
									teleportado = true  -- Garantir que só teleportamos uma vez
									wait(2)  -- Espera de 2 segundos para permitir a coleta antes de continuar
								end
							end
						end
					end
				end
			else
				print("❌ TreasureEntity não encontrada.")
			end
		end
		wait(5)
	end
end)
