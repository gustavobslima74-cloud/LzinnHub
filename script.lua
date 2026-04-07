--[[
    Lzinn Hub - Linha de Versões:
    v1.0: Base (Teleporte, Jogador, Combate V1, Hitbox)
    v1.1: Adicionada Aba Teste e Auto Attack V2 (Mobile Position Fix)
]]

-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

-- VARIÁVEIS DE CONTROLE
local selectedPlayer = nil
local autoSelect = false
local followEnabled = false
local distance = 3
local mode = "Behind"

-- PLAYER VARS
local speedEnabled = false
local speedValue = 16
local infJump = false

-- COMBAT VARS
local autoAttackV1 = false
local hitboxEnabled = false
local hitboxSize = 5
local hitboxTransparency = 1.0

-- TEST VARS (Para v1.1)
local autoAttackV2 = false

---------------------------------------------------
-- JANELA PRINCIPAL
---------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v1.1", 
    LoadingTitle = "Lzinn Interface v1.1",
    LoadingSubtitle = "by Lzinn7",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- ABAS
local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)
local TestTab = Window:CreateTab("Teste", 4483362458)

---------------------------------------------------
-- FUNÇÕES SUPORTE
---------------------------------------------------
local function getClosestPlayer()
    local closest = nil
    local dist = math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = p
            end
        end
    end
    return closest
end

---------------------------------------------------
-- ABA TELEPORTE
---------------------------------------------------
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

TeleportTab:CreateDropdown({
    Name = "Posição",
    Options = {"Behind", "Front", "Above"},
    CurrentOption = {"Behind"},
    Callback = function(v) mode = v[1] end
})

TeleportTab:CreateToggle({
    Name = "Grudar no Player",
    CurrentValue = false,
    Callback = function(v) followEnabled = v end
})

---------------------------------------------------
-- ABA JOGADOR
---------------------------------------------------
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

---------------------------------------------------
-- ABA COMBATE
---------------------------------------------------
CombatTab:CreateSection("Ataque Atual")

CombatTab:CreateToggle({
    Name = "Auto Attack V1 (VIM Mode)",
    CurrentValue = false,
    Callback = function(v) autoAttackV1 = v end
})

CombatTab:CreateSection("Hitbox")

CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v) hitboxEnabled = v end
})

CombatTab:CreateSlider({
    Name = "Tamanho Hitbox",
    Range = {2, 50},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) hitboxSize = v end
})

CombatTab:CreateSlider({
    Name = "Transparência",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 1.0,
    Callback = function(v) hitboxTransparency = v end
})

---------------------------------------------------
-- ABA TESTE (FUTURA v1.2)
---------------------------------------------------
TestTab:CreateSection("Laboratório Mobile")

TestTab:CreateToggle({
    Name = "Auto Attack V2 (Botão ATK)",
    CurrentValue = false,
    Callback = function(v) autoAttackV2 = v end
})

TestTab:CreateSection("Se o V2 funcionar, ele vira oficial na v1.2")

---------------------------------------------------
-- LOOPS
---------------------------------------------------

-- LOOP V1
task.spawn(function()
    while true do
        if autoAttackV1 then
            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
            task.wait(0.04) 
        else
            task.wait(0.1)
        end
    end
end)

-- LOOP V2
task.spawn(function()
    while true do
        if autoAttackV2 then
            pcall(function()
                local atkButton = LP.PlayerGui:FindFirstChild("ATK", true)
                if atkButton then
                    local pos = atkButton.AbsolutePosition
                    local size = atkButton.AbsoluteSize
                    VIM:SendMouseButtonEvent(pos.X + (size.X/2), pos.Y + (size.Y/2) + 50, 0, true, game, 0)
                    task.wait(0.01)
                    VIM:SendMouseButtonEvent(pos.X + (size.X/2), pos.Y + (size.Y/2) + 50, 0, false, game, 0)
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.1)
        end
    end
end)

-- LOOP PRINCIPAL
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        if not LP.Character then continue end
        local Hum = LP.Character:FindFirstChildOfClass("Human
