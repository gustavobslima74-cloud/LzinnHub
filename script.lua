-- LOAD RAYFIELD (caso não tenha carregado antes)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- VARIÁVEIS
local selectedPlayer = nil
local followEnabled = false
local distance = 3
local highlight = nil

-- WINDOW
local Window = Rayfield:CreateWindow({
   Name = "ShereckinhaGames Menu",
   LoadingTitle = "ShereckinhaGames",
   LoadingSubtitle = "by Luiz",
   ConfigurationSaving = {
      Enabled = true,
      FileName = "ShereckinhaHub"
   }
})

-- TAB
local Tab = Window:CreateTab("Main", 4483362458)

-- SECTION
local Section = Tab:CreateSection("Player Control")

---------------------------------------------------
-- DROPDOWN (LISTA DE PLAYERS)
---------------------------------------------------
local playerNames = {}

local function updatePlayers()
    playerNames = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(playerNames, p.Name)
        end
    end
end

updatePlayers()

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

local Dropdown = Tab:CreateDropdown({
   Name = "Selecionar Player",
   Options = playerNames,
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "PlayerSelect",
   Callback = function(Value)
        local targetName = Value[1]
        selectedPlayer = Players:FindFirstChild(targetName)

        -- HIGHLIGHT RGB
        if highlight then highlight:Destroy() end

        if selectedPlayer and selectedPlayer.Character then
            highlight = Instance.new("Highlight")
            highlight.Parent = selectedPlayer.Character

            task.spawn(function()
                local r,g,b = 255,0,0
                while highlight and highlight.Parent do
                    task.wait(0.03)
                    r = (r + 3)%256
                    g = (g + 5)%256
                    b = (b + 7)%256
                    highlight.FillColor = Color3.fromRGB(r,g,b)
                end
            end)
        end
   end,
})

---------------------------------------------------
-- TOGGLE GRUDAR
---------------------------------------------------
local Toggle = Tab:CreateToggle({
   Name = "Grudar no Player",
   CurrentValue = false,
   Flag = "FollowToggle",
   Callback = function(Value)
        followEnabled = Value
   end,
})

---------------------------------------------------
-- SLIDER DISTÂNCIA
---------------------------------------------------
local Slider = Tab:CreateSlider({
   Name = "Distância",
   Range = {1, 10},
   Increment = 1,
   CurrentValue = 3,
   Flag = "DistanceSlider",
   Callback = function(Value)
        distance = Value
   end,
})

---------------------------------------------------
-- LOOP DE TELEPORTE
---------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.05)

        if followEnabled
        and selectedPlayer
        and selectedPlayer.Character
        and LP.Character
        and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        and LP.Character:FindFirstChild("HumanoidRootPart") then

            local myHRP = LP.Character.HumanoidRootPart
            local targetHRP = selectedPlayer.Character.HumanoidRootPart

            local behind = targetHRP.CFrame.LookVector * -distance
            local newPos = targetHRP.Position + behind

            myHRP.CFrame = CFrame.new(newPos, targetHRP.Position)
        end
    end
end)
