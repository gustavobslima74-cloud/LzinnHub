-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")

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
local autoAttackV1 = false
local autoAttackV2 = false
local autoAttackV3 = false
local autoAttackV4 = false
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
    Options = {},
    CurrentOption = {},
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
-- ABA TESTE (VERSÕES DE AUTO ATAQUE)
---------------------------------------------------
TestTab:CreateSection("Laboratório de Ataque")

TestTab:CreateToggle({
    Name = "V1: Original (VIM Mode)",
    CurrentValue = false,
    Callback = function(v) autoAttackV1 = v end
})

TestTab:CreateToggle({
    Name = "V2: VU Click",
    CurrentValue = false,
    Callback = function(v) autoAttackV2 = v end
})

TestTab:CreateToggle({
    Name = "V3: Activate Internal",
    CurrentValue = false,
    Callback = function(v) autoAttackV3 = v end
})

TestTab:CreateToggle({
    Name = "V4: Remote Sniper (Novo)",
    CurrentValue = false,
    Callback = function(v) autoAttackV4 = v end
})

TestTab:CreateSection("O V4 tenta 'caçar' o evento da arma.")

---------------------------------------------------
-- LOOPS DE EXECUÇÃO
---------------------------------------------------

-- LOOP V1 (Original VIM)
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

-- LOOP V2 (VU)
task.spawn(function()
    while true do
        if autoAttackV2 then
            VU:Button1Down(Vector2.new(0,0))
            task.wait(0.01)
            VU:Button1Up(Vector2.new(0,0))
            task.wait(0.04)
        else
            task.wait(0.1)
        end
    end
end)

-- LOOP V3 (Internal)
task.spawn(function()
    while true do
        if autoAttackV3 then
            local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
            task.wait(0.1)
        else
            task.wait(0.1)
        end
    end
end)

-- LOOP V4 (Remote Event Sniper)
task.spawn(function()
    while true do
        if autoAttackV4 then
            local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        obj:FireServer()
                    end
                end
            end
            task.wait(0.1)
        else
            task.wait(0.1)
        end
    end
end)

-- LOOP PULO INFINITO
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- LOOP PRINCIPAL
task.spawn(function()
    while true do
        task.wait(0.01)
        if not LP.Character then continue end
        
        local Hum = LP.Character:FindFirstChildOfClass("Humanoid")
        local HRP = LP.Character:FindFirstChild("HumanoidRootPart")

        if autoSelect then
            local closest = getClosestPlayer()
            if closest then selectedPlayer = closest end
        end

        if speedEnabled and Hum then Hum.WalkSpeed = speedValue end

        if followEnabled and selectedPlayer and selectedPlayer.Character then
            local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHRP and HRP then
                local offset = (mode == "Behind" and tHRP.CFrame.LookVector * -distance) or 
                               (mode == "Front" and tHRP.CFrame.LookVector * distance) or 
                               Vector3.new(0, distance, 0)
                HRP.CFrame = CFrame.new(tHRP.Position + offset, tHRP.Position)
            end
        end

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
    Content = "Menu Completo com V1 até V4!",
    Duration = 5
})
