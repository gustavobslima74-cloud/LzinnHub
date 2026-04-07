local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
local hitboxTransparency = 1.0
local comboEnabled = false

-- FUNÇÃO PARA SOLTAR O MOUSE (CORREÇÃO DO BUG)
local function ForceRelease()
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Criar Highlight Global RGB
local highlight = Instance.new("Highlight")
highlight.Name = "LzinnHighlight"
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0

local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v1.9",
    LoadingTitle = "Lzinn Interface v1.9",
    LoadingSubtitle = "by Lzinn7",
    ConfigurationSaving = { Enabled = false }
})

local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)
local TestTab = Window:CreateTab("Teste", 4483362458)

---------------------------------------------------
-- ABA COMBATE (COM CORREÇÃO DE STOP)
---------------------------------------------------
CombatTab:CreateToggle({
    Name = "Auto Attack V1 (VIM Mode)",
    CurrentValue = false,
    Callback = function(v) 
        autoAttackV1 = v 
        if v == false then ForceRelease() end -- Força o soltar do clique ao desligar
    end
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

---------------------------------------------------
-- ABA TESTE (COMBO SINCRONIZADO)
---------------------------------------------------
TestTab:CreateSection("Sincronização Especial")

TestTab:CreateToggle({
    Name = "Combo: Grudar + Atacar (0.5s Delay)",
    CurrentValue = false,
    Callback = function(v) 
        comboEnabled = v
        autoSelect = v
        followEnabled = v
        autoAttackV1 = v
        
        if v == false then ForceRelease() end -- Garante que o combo pare de bater
        
        Rayfield:Notify({
            Title = "Modo Combo",
            Content = v and "Ativado com delay de 500ms!" or "Desativado!",
            Duration = 3
        })
    end
})

---------------------------------------------------
-- LOOPS DE EXECUÇÃO
---------------------------------------------------

-- Loop de Ataque VIM (AJUSTADO)
task.spawn(function
