local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Script Fix - v2", "DarkTheme")

-- Configurações Iniciais
local Config = {
    AutoAttack = false,
    AttackSpeed = 0.5
}

local Tab = Window:NewTab("Combate")
local Section = Tab:NewSection("Ataque Automático")

Section:NewToggle("Auto Ataque", "Liga/Desliga o ataque", function(state)
    Config.AutoAttack = state
    
    if state then
        print("Auto Ataque Ativado")
        -- Loop de Segurança
        spawn(function()
            while Config.AutoAttack do
                -- Substitua 'AttackFunction' pela função real do seu jogo
                -- pcall evita que o script quebre se a função do jogo mudar
                pcall(function()
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                end)
                wait(Config.AttackSpeed)
            end
        end)
    else
        print("Auto Ataque Desativado")
    end
end)

-- Botão de Emergência (Caso o Hub suma ou o ataque trave)
Section:NewButton("STOP TOTAL", "Para todos os ataques imediatamente", function()
    Config.AutoAttack = false
    print("Comandos resetados.")
end)
