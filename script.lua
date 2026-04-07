-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- VARIÁVEIS
local selectedPlayer = nil
local autoSelect = false
local followEnabled = false
local distance = 3
local mode = "Behind"

-- COMBAT VARS
local speedEnabled = false
local speedValue = 16
local infJump = false
local hitboxSize = 5
local hitboxTransparency = 0.5
local aimbot = false
local autoAttack = false
local autoFarm = false

-- VISUAL
local highlight = nil

---------------------------------------------------
-- WINDOW
---------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "Lzinn Hub",
LoadingTitle = "Lzinn Interface",
LoadingSubtitle = "by Luiz"
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)

---------------------------------------------------
-- FUNÇÕES
---------------------------------------------------
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

local function applyHighlight(player)
    if highlight then highlight:Destroy() end

    if player and player.Character then
        highlight = Instance.new("Highlight")
        highlight.Parent = player.Character

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
end

---------------------------------------------------
-- COMBAT
---------------------------------------------------

-- AUTO SELECT
CombatTab:CreateToggle({
   Name = "Auto Select Player",
   CurrentValue = false,
   Callback = function(v)
      autoSelect = v
   end
})

-- GRUDAR
CombatTab:CreateToggle({
   Name = "Grudar",
   CurrentValue = false,
   Callback = function(v)
      followEnabled = v
   end
})

-- POSIÇÃO
CombatTab:CreateDropdown({
   Name = "Posição",
   Options = {"Behind","Front"},
   CurrentOption = {"Behind"},
   Callback = function(v)
      mode = v[1]
   end
})

-- SPEED
CombatTab:CreateToggle({
   Name = "Speed",
   CurrentValue = false,
   Callback = function(v)
      speedEnabled = v
   end
})

CombatTab:CreateSlider({
   Name = "Velocidade",
   Range = {16,100},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v)
      speedValue = v
   end
})

-- INFINITE JUMP
CombatTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v)
      infJump = v
   end
})

-- HITBOX
CombatTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {2,20},
   Increment = 1,
   CurrentValue = 5,
   Callback = function(v)
      hitboxSize = v
   end
})

CombatTab:CreateSlider({
   Name = "Hitbox Transparência",
   Range = {0.1,1},
   Increment = 0.1,
   CurrentValue = 0.5,
   Callback = function(v)
      hitboxTransparency = v
   end
})

-- AIMBOT
CombatTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(v)
      aimbot = v
   end
})

-- AUTO ATTACK
CombatTab:CreateToggle({
   Name = "Auto Attack",
   CurrentValue = false,
   Callback = function(v)
      autoAttack = v
   end
})

-- AUTO FARM
CombatTab:CreateToggle({
   Name = "Auto Farm",
   CurrentValue = false,
   Callback = function(v)
      autoFarm = v
   end
})

---------------------------------------------------
-- VISUAL
---------------------------------------------------

VisualTab:CreateButton({
   Name = "Aplicar Highlight RGB",
   Callback = function()
      if selectedPlayer then
         applyHighlight(selectedPlayer)
      end
   end
})

---------------------------------------------------
-- INFINITE JUMP
---------------------------------------------------
UIS.JumpRequest:Connect(function()
    if infJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState("Jumping")
    end
end)

---------------------------------------------------
-- LOOP PRINCIPAL
---------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.05)

        if not LP.Character then continue end

        local HRP = LP.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LP.Character:FindFirstChild("Humanoid")

        -- AUTO SELECT
        if autoSelect then
            local closest = getClosestPlayer()
            if closest ~= selectedPlayer then
                selectedPlayer = closest
                applyHighlight(selectedPlayer)
            end
        end

        -- SPEED
        if speedEnabled and humanoid then
            humanoid.WalkSpeed = speedValue
        end

        -- FOLLOW
        if followEnabled and selectedPlayer and selectedPlayer.Character then
            local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and HRP then
                local dir = targetHRP.CFrame.LookVector
                local offset = (mode == "Behind") and (dir * -distance) or (dir * distance)
                HRP.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
            end
        end

        -- AIMBOT
        if aimbot and selectedPlayer and selectedPlayer.Character then
            local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and HRP then
                HRP.CFrame = CFrame.new(HRP.Position, targetHRP.Position)
            end
        end

        -- AUTO ATTACK / FARM
        if (autoAttack or autoFarm) then
            local tool = LP.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end

        -- HITBOX
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local part = p.Character.HumanoidRootPart
                part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                part.Transparency = hitboxTransparency
                part.Material = Enum.Material.Neon
                part.CanCollide = false
            end
        end
    end
end)
