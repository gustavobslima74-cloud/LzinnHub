local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- VARIÁVEIS LIMPAS (Sem comandos de ataque)
local selectedPlayer = nil
local autoSelect = false
local followEnabled = false
local distance = 3
local mode = "Behind"
local speedEnabled = false
local speedValue = 16
local infJump = false
local hitboxEnabled = false
local hitboxSize = 5

-- Highlight RGB
local highlight = Instance.new("Highlight")
highlight.Name = "LzinnHighlight_v2"
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0

local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v2.0 Oficial",
    LoadingTitle = "Lzinn Interface v2.0",
    LoadingSubtitle = "by Lzinn7 - Estável",
    ConfigurationSaving = { Enabled = false }
})

local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)

---------------------------------------------------
-- LÓGICA VISUAL (HIGHLIGHT)
---------------------------------------------------
task.spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            local color = Color3.fromHSV(i, 1, 1)
            highlight.FillColor = color
            highlight.OutlineColor = color
            task.wait(0.05)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if selectedPlayer and selectedPlayer.Character then
            highlight.Parent = selectedPlayer.Character
        else
            highlight.Parent = nil
        end
    end
end)

---------------------------------------------------
-- ABA TELEPORTE
---------------------------------------------------
TeleportTab:CreateToggle({
    Name = "Auto Select (Mais Próximo)",
    CurrentValue = false,
    Callback = function(v) autoSelect = v end
})

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Selecionar Jogador manualmente",
    Options = {"Nenhum"},
    CurrentOption = {"Nenhum"},
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value[1])
    end,
})

TeleportTab:CreateButton({
    Name = "Atualizar Lista de Jogadores",
    Callback = function()
        local names = {}
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP then table.insert(names, p.Name) end
        end
        PlayerDropdown:Refresh(names)
    end
})

TeleportTab:CreateDropdown({
    Name = "Posição do Grudar",
    Options = {"Behind", "Front", "Above"},
    CurrentOption = {"Behind"},
    Callback = function(v) mode = v[1] end
})

TeleportTab:CreateToggle({
    Name = "Grudar no Player (Follow)",
    CurrentValue = false,
    Callback = function(v) followEnabled = v end
})

---------------------------------------------------
-- ABA JOGADOR
---------------------------------------------------
PlayerTab:CreateToggle({
    Name = "Ativar Speed",
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
CombatTab:CreateSection("Hitbox")
CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v) hitboxEnabled = v end
})

CombatTab:CreateSlider({
    Name = "Tamanho da Hitbox",
    Range = {2, 50},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) hitboxSize = v end
})

---------------------------------------------------
-- LOOP ÚNICO DE EXECUÇÃO (OTIMIZADO)
---------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.01)
        
        local Character = LP.Character
        if not Character then continue end
        
        local Hum = Character:FindFirstChildOfClass("Humanoid")
        local HRP = Character:FindFirstChild("HumanoidRootPart")
        if not HRP or not Hum then continue end

        -- 1. Lógica de Seleção Automática
        if autoSelect then
            local closest = nil
            local dist = math.huge
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (HRP.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then 
                        dist = d 
                        closest = p 
                    end
                end
            end
            selectedPlayer = closest
        end

        -- 2. Lógica de Speed
        if speedEnabled then 
            Hum.WalkSpeed = speedValue 
        end

        -- 3. Lógica de Follow (Grudar) - APENAS MOVIMENTO
        if followEnabled and selectedPlayer and selectedPlayer.Character then
            local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local offset = (mode == "Behind" and tHRP.CFrame.LookVector * -distance) or 
                               (mode == "Front" and tHRP.CFrame.LookVector * distance) or 
                               Vector3.new(0, distance, 0)
                
                -- Movendo o personagem sem disparar cliques
                HRP.CFrame = CFrame.new(tHRP.Position + offset, tHRP.Position)
            end
        end

        -- 4. Lógica de Hitbox
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

-- Jump Request
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Rayfield:Notify({
    Title = "Lzinn Hub v2.0",
    Content = "Scripts de ataque removidos com sucesso!",
    Duration = 5
})
