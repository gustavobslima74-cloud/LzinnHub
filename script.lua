-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- VARIÁVEIS
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
local hitboxEnabled = false
local hitboxSize = 5
local hitboxTransparency = 1.0
local aimbot = false
local autoAttack = false
local autoFarm = false

---------------------------------------------------
-- WINDOW
---------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | Mobile Optimized",
    LoadingTitle = "Lzinn Interface",
    LoadingSubtitle = "by Luiz"
})

-- ABAS REORGANIZADAS
local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)

---------------------------------------------------
-- FUNÇÕES AUXILIARES
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
    Name = "Posição do Teleporte",
    Options = {"Behind", "Front", "Above"},
    CurrentOption = {"Behind"},
    Callback = function(v) mode = v[1] end
})

TeleportTab:CreateToggle({
    Name = "Grudar no Player (Teleport Loop)",
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
    Range = {16, 200},
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
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(v) aimbot = v end
})

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

CombatTab:CreateToggle({
    Name = "Auto Atack",
    CurrentValue = false,
    Callback = function(v) autoAttack = v end
})

CombatTab:CreateToggle({
    Name = "Auto Farm (Gruda + Ataca)",
    CurrentValue = false,
    Callback = function(v) autoFarm = v end
})

---------------------------------------------------
-- LÓGICA DE EXECUÇÃO (LOOPS)
---------------------------------------------------

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01) -- Loop mais rápido para precisão
        
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then continue end
        local HRP = LP.Character.HumanoidRootPart
        local Hum = LP.Character:FindFirstChildOfClass("Humanoid")

        -- Auto Select Logic
        if autoSelect or autoFarm then
            selectedPlayer = getClosestPlayer()
        end

        -- Speed Logic
        if speedEnabled and Hum then
            Hum.WalkSpeed = speedValue
        end

        -- Follow / Auto Farm Movement
        if (followEnabled or autoFarm) and selectedPlayer and selectedPlayer.Character then
            local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local offset
                if mode == "Behind" then offset = targetHRP.CFrame.LookVector * -distance
                elseif mode == "Front" then offset = targetHRP.CFrame.LookVector * distance
                else offset = Vector3.new(0, distance, 0) end
                
                HRP.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
            end
        end

        -- Aimbot Logic
        if aimbot and selectedPlayer and selectedPlayer.Character then
            local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(targetHRP.Position.X, HRP.Position.Y, targetHRP.Position.Z))
            end
        end

        -- Auto Attack / Farm Logic (Correção de Ferramenta)
        if (autoAttack or autoFarm) then
            local tool = LP.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end

        -- Hitbox Expander Logic
        if hitboxEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.Transparency = hitboxTransparency
                    hrp.CanCollide = false
                end
            end
        end
    end
end)
