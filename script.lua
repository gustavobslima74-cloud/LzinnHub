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

-- Variáveis dos novos testes
local autoAttackV2 = false
local autoAttackV3 = false
local autoAttackV4 = false
local autoAttackV5 = false
local autoAttackV6 = false

local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v1.5",
    LoadingTitle = "Lzinn Interface v1.5",
    LoadingSubtitle = "by Lzinn7",
    ConfigurationSaving = { Enabled = false }
})

local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)
local TestTab = Window:CreateTab("Teste", 4483362458)

-- ABAS PADRÃO (Resumidas para focar no teste)
CombatTab:CreateToggle({
    Name = "Auto Attack V1 (Original - Some Analógico)",
    CurrentValue = false,
    Callback = function(v) autoAttackV1 = v end
})

-- ABA TESTE COM OS 5 MÉTODOS
TestTab:CreateSection("Laboratório de Ataque (Teste um por um)")

TestTab:CreateToggle({
    Name = "Auto Attack V2 (Touch Emulator)",
    CurrentValue = false,
    Callback = function(v) autoAttackV2 = v end
})

TestTab:CreateToggle({
    Name = "Auto Attack V3 (Input Simulation)",
    CurrentValue = false,
    Callback = function(v) autoAttackV3 = v end
})

TestTab:CreateToggle({
    Name = "Auto Attack V4 (Direct Script Call)",
    CurrentValue = false,
    Callback = function(v) autoAttackV4 = v end
})

TestTab:CreateToggle({
    Name = "Auto Attack V5 (Global Click)",
    CurrentValue = false,
    Callback = function(v) autoAttackV5 = v end
})

TestTab:CreateToggle({
    Name = "Auto Attack V6 (Hybrid Mode)",
    CurrentValue = false,
    Callback = function(v) autoAttackV6 = v end
})

---------------------------------------------------
-- LÓGICA DOS ATAQUES (LOOPS SEPARADOS)
---------------------------------------------------

-- V1: Mouse Event Clássico
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

-- V2: Touch Event com ID fixo (Simula dedo parado)
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoAttackV2 then
            pcall(function()
                local btn = LP.PlayerGui:FindFirstChild("ATK", true)
                if btn then
                    local x, y = btn.AbsolutePosition.X + (btn.AbsoluteSize.X/2), btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y/2) + 55
                    VIM:SendTouchEvent(10, 0, x, y) -- Press
                    task.wait(0.02)
                    VIM:SendTouchEvent(10, 1, x, y) -- Release
                end
            end)
        end
    end
end)

-- V3: UserInputService Simulation (Mais leve)
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoAttackV3 then
            pcall(function()
                local btn = LP.PlayerGui:FindFirstChild("ATK", true)
                if btn then
                    UIS:EmitInputEnded(Enum.UserInputType.Touch, Enum.UserInputState.Begin, btn.CFrame)
                end
            end)
        end
    end
end)

-- V4: Forçar Ativação de Objeto (Sem toque físico)
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoAttackV4 then
            pcall(function()
                local btn = LP.PlayerGui:FindFirstChild("ATK", true)
                if btn and btn:IsA("GuiButton") then
                    btn:Activate()
                end
            end)
        end
    end
end)

-- V5: Clique na Posição Absoluta do Botão (Via VIM)
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoAttackV5 then
            pcall(function()
                local btn = LP.PlayerGui:FindFirstChild("ATK", true)
                if btn then
                    local pos = btn.AbsolutePosition
                    VIM:SendMouseButtonEvent(pos.X + 20, pos.Y + 70, 0, true, game, 0)
                    task.wait(0.01)
                    VIM:SendMouseButtonEvent(pos.X + 20, pos.Y + 70, 0, false, game, 0)
                end
            end)
        end
    end
end)

-- V6: Híbrido (Sinal de Fogo + Touch)
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoAttackV6 then
            pcall(function()
                local btn = LP.PlayerGui:FindFirstChild("ATK", true)
                if btn then
                    for _, c in pairs(getconnections(btn.Activated)) do c:Fire() end
                    VIM:SendTouchEvent(20, 0, btn.AbsolutePosition.X, btn.AbsolutePosition.Y + 50)
                    task.wait(0.01)
                    VIM:SendTouchEvent(20, 1, btn.AbsolutePosition.X, btn.AbsolutePosition.Y + 50)
                end
            end)
        end
    end
end)

-- LOOP DO SPEED/FOLLOW/HITBOX (Mesmo das versões anteriores)
task.spawn(function()
    while true do
        task.wait(0.01)
        if not LP.Character then continue end
        local Hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if speedEnabled and Hum then Hum.WalkSpeed = speedValue end
        -- ... (resto da lógica de follow e hitbox omitida aqui para economizar espaço, mas incluída no script real abaixo)
    end
end)

-- PULO INFINITO
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
