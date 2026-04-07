-- Carregamento do Sirius (Link Alternativo para evitar 404)
local success, errorMessage = pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
end)

if not success then
    warn("Erro ao carregar Sirius/Rayfield: " .. tostring(errorMessage))
    return
end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")

-- VARIÁVEIS DA VERSÃO 1.8
local autoAttackV1 = false
local comboEnabled = false
local selectedPlayer = nil

-- FUNÇÃO PARA FORÇAR A PARADA (MATA O BUG DE ATACAR SOZINHO)
local function ForceStop()
    VIM:SendMouseButtonEvent(0,0,0,false,game,0)
end

local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v1.8 Fixed",
    LoadingTitle = "Lzinn7 Interface",
    LoadingSubtitle = "Corrigido",
    ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combate")
local TestTab = Window:CreateTab("Teste")

-- ABA COMBATE
CombatTab:CreateToggle({
    Name = "Auto Attack V1 (VIM Mode)",
    CurrentValue = false,
    Callback = function(v) 
        autoAttackV1 = v 
        if not v then ForceStop() end -- Para o ataque ao desligar o botão
    end
})

-- ABA TESTE (COMBO)
TestTab:CreateToggle({
    Name = "Combo: Grudar + Atacar",
    CurrentValue = false,
    Callback = function(v) 
        comboEnabled = v
        autoAttackV1 = v -- Sincroniza com o ataque
        if not v then ForceStop() end -- Garante que o ataque pare ao desligar o combo
    end
})

---------------------------------------------------
-- LOOP DE ATAQUE (AJUSTADO PARA 500ms)
---------------------------------------------------
task.spawn(function()
    while true do
        if autoAttackV1 or comboEnabled then
            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
            task.wait(0.49) -- Delay de 500ms total
        else
            task.wait(0.5)
        end
    end
end)

Rayfield:Notify({
    Title = "Lzinn Hub",
    Content = "v1.8 Executada com Sucesso!",
    Duration = 5
})
