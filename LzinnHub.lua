-- NOVO LINK ESTÁVEL (CORRIGE O ERRO 404)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

-- VARIÁVEIS
local selectedPlayer = nil
local autoSelect = false
local followEnabled = false
local distance = 3
local mode = "Behind"
local speedEnabled = false
local speedValue = 16
local infJump = false
local autoAttackV1 = false
local hitboxEnabled = false
local hitboxSize = 5
local comboEnabled = false

-- FUNÇÃO PARA FORÇAR PARADA DO ATAQUE (CORRIGE O BUG DE FICAR BATENDO)
local function StopAttack()
    VIM:SendMouseButtonEvent(0,0,0,false,game,0)
end

local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v1.8 FIXED",
    LoadingTitle = "Carregando Interface...",
    LoadingSubtitle = "by Lzinn7",
    ConfigurationSaving = { Enabled = false }
})

local TeleportTab = Window:CreateTab("Teleporte")
local PlayerTab = Window:CreateTab("Jogador")
local CombatTab = Window:CreateTab("Combate")
local TestTab = Window:CreateTab("Teste")

-- [ABAS MANTIDAS COM A LOGICA DA SUA VERSÃO 1.8]

TeleportTab:CreateToggle({
    Name = "Auto Select (Mais Próximo)",
    CurrentValue = false,
    Callback = function(v) autoSelect = v end
})

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Selecionar Jogador",
    Options = {"Nenhum"},
    CurrentOption = {"Nenhum"},
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value[1])
    end,
})

TeleportTab:CreateButton({
    Name = "Atualizar Lista",
    Callback = function()
        local names = {}
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP then table.insert(names, p.Name) end
        end
        PlayerDropdown:Refresh(names)
    end
})

TeleportTab:CreateToggle({
    Name = "Grudar no Player",
    CurrentValue = false,
    Callback = function(v) followEnabled = v end
})

PlayerTab:CreateToggle({
    Name = "Speed (Ligado/Desligado)",
    CurrentValue = false,
    Callback = function(v) speedEnabled = v end
})

PlayerTab:CreateSlider({
    Name = "Velocidade",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) speedValue = v end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v) infJump = v end
})

-- ABA COMBATE (COM TRAVA DE SEGURANÇA)
CombatTab:CreateToggle({
    Name = "Auto Attack V1 (VIM Mode)",
    CurrentValue = false,
    Callback = function(v) 
        autoAttackV1 = v 
        if not v then StopAttack() end -- Para o ataque na hora ao desligar
    end
})

CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v) hitboxEnabled = v end
})

TestTab:CreateToggle({
    Name = "Combo: Grudar + Atacar",
    CurrentValue = false,
    Callback = function(v) 
        comboEnabled = v
        autoSelect = v
        followEnabled = v
        autoAttackV1 = v
        if not v then StopAttack() end
    end
})

---------------------------------------------------
-- LOOPS DE EXECUÇÃO (MELHORADOS)
---------------------------------------------------

-- Loop de Ataque (Ajustado para não "engasgar")
task.spawn(function()
    while true do
        if autoAttackV1 or comboEnabled then
            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
            task.wait(0.48) -- Delay total de 0.5s
        else
            task.wait(0.5)
        end
    end
end)

-- Loop Principal (Movimento e Hitbox)
task.spawn(function()
    while true do
        task.wait(0.01)
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then continue end
        
        local Hum = LP.Character:FindFirstChildOfClass("Humanoid")
        local HRP = LP.Character.HumanoidRootPart

        if autoSelect or comboEnabled then
            local closest = nil
            local dist = math.huge
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (HRP.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d closest = p end
                end
            end
            if closest then selectedPlayer = closest end
        end

        if speedEnabled and Hum then Hum.WalkSpeed = speedValue end

        if (followEnabled or comboEnabled) and selectedPlayer and selectedPlayer.Character then
            local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                HRP.CFrame = CFrame.new(tHRP.Position + (tHRP.CFrame.LookVector * -distance), tHRP.Position)
            end
        end

        if hitboxEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    p.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
