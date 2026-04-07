-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

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

-- COMBAT/TEST VARS
local newAutoAttack = false
local hitboxEnabled = false
local hitboxSize = 5
local hitboxTransparency = 1.0

---------------------------------------------------
-- JANELA PRINCIPAL
---------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub",
    LoadingTitle = "Carregando Interface...",
    LoadingSubtitle = "by Lzinn7"
})

-- ABAS
local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)
local TestTab = Window:CreateTab("Teste", 4483362458) -- Aba temporária para o novo código

---------------------------------------------------
-- FUNÇÕES SUPORTE
---------------------------------------------------
local function getPlayerNames()
    local list = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    return list
end

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
    Options = getPlayerNames(),
    CurrentOption = {},
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value[1])
    end,
})

TeleportTab:CreateButton({
    Name = "Atualizar Lista",
    Callback = function() PlayerDropdown:Refresh(getPlayerNames()) end
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
CombatTab:CreateSection("Configurações de Hitbox")

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
    Name = "Transparência (1.0 = Invisível)",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 1.0,
    Callback = function(v) hitboxTransparency = v end
})

---------------------------------------------------
-- ABA TESTE (NOVO AUTO ATAQUE)
---------------------------------------------------
TestTab:CreateToggle({
    Name = "Novo Auto Attack (VIM)",
    CurrentValue = false,
    Callback = function(v)
        newAutoAttack = v
    end
})

---------------------------------------------------
-- LOOPS DE EXECUÇÃO
---------------------------------------------------

-- NOVO AUTO ATAQUE (Código que você enviou)
task.spawn(function()
    while true do
        if newAutoAttack then
            -- Simula o clique do mouse no centro da tela
            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
            task.wait(0.04) -- velocidade do spam
        else
            task.wait(0.1)
        end
    end
end)

-- Pulo Infinito
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then continue end
        local HRP = LP.Character.HumanoidRootPart
        local Hum = LP.Character:FindFirstChildOfClass("Humanoid")

        -- Auto Select
        if autoSelect then
            local closest = getClosestPlayer()
            if closest then selectedPlayer = closest end
        end

        -- Speed
        if speedEnabled and Hum then
            Hum.WalkSpeed = speedValue
        end

        -- Follow (Grudar)
        if followEnabled and selectedPlayer and selectedPlayer.Character then
            local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local offset
                if mode == "Behind" then offset = tHRP.CFrame.LookVector * -distance
                elseif mode == "Front" then offset = tHRP.CFrame.LookVector * distance
                else offset = Vector3.new(0, distance, 0) end
                
                HRP.CFrame = CFrame.new(tHRP.Position + offset, tHRP.Position)
            end
        end

        -- Hitbox
        if hitboxEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pRoot = p.Character.HumanoidRootPart
                    pRoot.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    pRoot.Transparency = hitboxTransparency
                    pRoot.CanCollide = false
                end
            end
        end
    end
end)

Rayfield:Notify({
    Title = "Lzinn Hub",
    Content = "Aba Teste Adicionada!",
    Duration = 5
})
