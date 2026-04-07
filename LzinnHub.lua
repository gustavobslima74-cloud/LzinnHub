local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local selectedPlayer = nil
local autoSelect = false
local followEnabled = false
local distance = 3
local mode = "Behind"
local speedEnabled = false
local speedValue = 16
local infJump = false
local autoAttackV1 = false

-- Variáveis de Teste v1.6
local autoAttackV6 = false
local autoAttackV7 = false
local hitboxEnabled = false
local hitboxSize = 5
local hitboxTransparency = 1.0

local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v1.6",
    LoadingTitle = "Lzinn Interface v1.6",
    LoadingSubtitle = "by Lzinn7",
    ConfigurationSaving = { Enabled = false }
})

local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)
local TestTab = Window:CreateTab("Teste", 4483362458)

-- COMBATE
CombatTab:CreateToggle({
    Name = "Auto Attack V1 (VIM - Bug Analogico)",
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
    Name = "Tamanho",
    Range = {2, 50},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v) hitboxSize = v end
})

-- TESTE v1.6
TestTab:CreateSection("Novos Métodos (Foco: Salvar Analógico)")

TestTab:CreateToggle({
    Name = "Auto Attack V6 (Signal Fire)",
    CurrentValue = false,
    Callback = function(v) autoAttackV6 = v end
})

TestTab:CreateToggle({
    Name = "Auto Attack V7 (Object Call)",
    CurrentValue = false,
    Callback = function(v) autoAttackV7 = v end
})

TestTab:CreateSection("V6 e V7 não usam coordenadas de clique.")

---------------------------------------------------
-- LOOPS DE ATAQUE
---------------------------------------------------

-- V1 (O que você já usa)
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoAttackV1 then
            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
        end
    end
end)

-- V6 (Disparo de Sinais Internos)
-- Tenta 'puxar o gatilho' do botão sem simular toque
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoAttackV6 then
            pcall(function()
                local btn = LP.PlayerGui:FindFirstChild("ATK", true)
                if btn then
                    -- Dispara os eventos de clique sem o mouse estar lá
                    btn:Activate()
                    for _, connection in pairs(getconnections(btn.MouseButton1Click)) do
                        connection:Fire()
                    end
                    for _, connection in pairs(getconnections(btn.Activated)) do
                        connection:Fire()
                    end
                end
            end)
        end
    end
end)

-- V7 (Simulação de Tecla Virtual)
-- Alguns botões mobile respondem a teclas fantasmas
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoAttackV7 then
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.01)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            -- Também tenta o clique da ferramenta
            local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)

---------------------------------------------------
-- LÓGICA PRINCIPAL (SPEED / FOLLOW / HITBOX)
---------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.01)
        if not LP.Character then continue end
        local Hum = LP.Character:FindFirstChildOfClass("Humanoid")
        local HRP = LP.Character:FindFirstChild("HumanoidRootPart")

        if autoSelect then
            local closest = nil
            local dist = math.huge
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d closest = p end
                end
            end
            if closest then selectedPlayer = closest end
        end

        if speedEnabled and Hum then Hum.WalkSpeed = speedValue end

        if followEnabled and selectedPlayer and selectedPlayer.Character then
            local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHRP and HRP then
                local offset = (mode == "Behind" and tHRP.CFrame.LookVector * -distance) or (mode == "Front" and tHRP.CFrame.LookVector * distance) or Vector3.new(0, distance, 0)
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

UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
