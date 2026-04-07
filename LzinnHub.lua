-- Carregamento corrigido para evitar o Erro 404
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local V1M = game:GetService("VirtualInputManager")

-- VARIÁVEIS 1.8
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

-- FUNÇÃO PARA MATAR O BUG DO ATAQUE INFINITO
local function ForceStop()
    V1M:SendMouseButtonEvent(0,0,0,false,game,0)
end

local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v1.8",
    LoadingTitle = "Lzinn Interface v1.8",
    LoadingSubtitle = "by Lzinn7",
    ConfigurationSaving = { Enabled = false }
})

local TeleportTab = Window:CreateTab("Teleporte")
local PlayerTab = Window:CreateTab("Jogador")
local CombatTab = Window:CreateTab("Combate")
local TestTab = Window:CreateTab("Teste")

-- ABA COMBATE (COM CORREÇÃO)
CombatTab:CreateToggle({
    Name = "Auto Attack V1 (VIM Mode)",
    CurrentValue = false,
    Callback = function(v) 
        autoAttackV1 = v 
        if not v then ForceStop() end -- SE DESLIGAR, ELE SOLTA O MOUSE NA HORA
    end
})

CombatTab:CreateSection("Hitbox")
CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v) hitboxEnabled = v end
})

-- ABA TESTE (COMBO)
TestTab:CreateToggle({
    Name = "Combo: Grudar + Atacar (0.5s Delay)",
    CurrentValue = false,
    Callback = function(v) 
        comboEnabled = v
        autoSelect = v
        followEnabled = v
        autoAttackV1 = v
        if not v then ForceStop() end -- RESET TOTAL AO DESLIGAR
    end
})

---------------------------------------------------
-- LOOPS DE EXECUÇÃO (VERSÃO 1.8)
---------------------------------------------------

-- Loop de Ataque VIM (CORRIGIDO PARA PARAR)
task.spawn(function()
    while true do
        if autoAttackV1 or comboEnabled then
            V1M:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.01) 
            V1M:SendMouseButtonEvent(0,0,0,false,game,0)
            task.wait(0.49) -- Delay de 500ms
        else
            task.wait(0.2)
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

        -- Auto Select
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

        -- Follow
        if (followEnabled or comboEnabled) and selectedPlayer and selectedPlayer.Character then
            local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local offset = (mode == "Behind" and tHRP.CFrame.LookVector * -distance) or (mode == "Front" and tHRP.CFrame.LookVector * distance) or Vector3.new(0, distance, 0)
                HRP.CFrame = CFrame.new(tHRP.Position + offset, tHRP.Position)
            end
        end

        -- Hitbox
        if hitboxEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    p.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end
        
        -- Speed
        if speedEnabled and Hum then Hum.WalkSpeed = speedValue end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
