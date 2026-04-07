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
local comboEnabled = false

-- Highlight RGB
local highlight = Instance.new("Highlight")
highlight.Name = "LzinnHighlight"
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0

local Window = Rayfield:CreateWindow({
    Name = "Lzinn Hub | v2.0",
    LoadingTitle = "Lzinn Interface v2.0",
    LoadingSubtitle = "by Lzinn7",
    ConfigurationSaving = { Enabled = false }
})

local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)
local TestTab = Window:CreateTab("Teste", 4483362458)

---------------------------------------------------
-- LÓGICA RGB HIGHLIGHT
---------------------------------------------------
task.spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            if highlight then
                local color = Color3.fromHSV(i, 1, 1)
                highlight.FillColor = color
                highlight.OutlineColor = color
            end
            task.wait(0.05)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if selectedPlayer and selectedPlayer.Character then
            highlight.Parent = selectedPlayer.Character
        else
            highlight.Parent = nil
        end
    end
end)

---------------------------------------------------
-- ABAS PADRÃO
---------------------------------------------------

-- TELEPORTE
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
        for _,
