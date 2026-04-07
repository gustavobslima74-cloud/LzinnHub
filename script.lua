-- LOAD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- SERVICES
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- VARS
local selectedPlayer = nil
local autoSelect = false
local followEnabled = false
local distance = 3
local mode = "Behind"

local speedEnabled = false
local speedValue = 16
local infJump = false

local aimbot = false
local autoAttack = false
local autoFarm = false
local attackDelay = 0.6

local hitboxSize = 5
local hitboxTransparency = 1

local highlight = nil

---------------------------------------------------
-- WINDOW
---------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "Lzinn Hub",
   LoadingTitle = "Lzinn Hub",
   LoadingSubtitle = "by Luiz"
})

local TeleportTab = Window:CreateTab("Teleporte", 4483362458)
local PlayerTab = Window:CreateTab("Jogador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)

---------------------------------------------------
-- FUNÇÕES
---------------------------------------------------
local function getPlayers()
    local t = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(t, p.Name) end
    end
    return t
end

local function getClosestPlayer()
    local closest, dist = nil, math.huge
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end

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
    end
end

---------------------------------------------------
-- TELEPORTE (PRINCIPAL)
---------------------------------------------------

local dropdown = TeleportTab:CreateDropdown({
   Name = "Selecionar Player",
   Options = getPlayers(),
   CurrentOption = {},
   Callback = function(v)
      autoSelect = false
      selectedPlayer = Players:FindFirstChild(v[1])
      applyHighlight(selectedPlayer)
   end
})

TeleportTab:CreateButton({
   Name = "Atualizar Lista",
   Callback = function()
      dropdown:Refresh(getPlayers())
   end
})

TeleportTab:CreateToggle({
   Name = "Auto Select",
   CurrentValue = false,
   Callback = function(v)
      autoSelect = v
   end
})

TeleportTab:CreateDropdown({
   Name = "Posição",
   Options = {"Behind","Front"},
   CurrentOption = {"Behind"},
   Callback = function(v)
      mode = v[1]
   end
})

TeleportTab:CreateToggle({
   Name = "Grudar",
   CurrentValue = false,
   Callback = function(v)
      followEnabled = v
   end
})

---------------------------------------------------
-- JOGADOR
---------------------------------------------------

PlayerTab:CreateToggle({
   Name = "Speed",
   CurrentValue = false,
   Callback = function(v)
      speedEnabled = v
   end
})

PlayerTab:CreateSlider({
   Name = "Velocidade",
   Range = {16,100},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v)
      speedValue = v
   end
})

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v)
      infJump = v
   end
})

---------------------------------------------------
-- COMBATE
---------------------------------------------------

CombatTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(v)
      aimbot = v
   end
})

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
   CurrentValue = 1,
   Callback = function(v)
      hitboxTransparency = v
   end
})

CombatTab:CreateToggle({
   Name = "Auto Attack",
   CurrentValue = false,
   Callback = function(v)
      autoAttack = v
   end
})

CombatTab:CreateSlider({
   Name = "Velocidade do Attack",
   Range = {0.2,0.6},
   Increment = 0.1,
   CurrentValue = 0.6,
   Callback = function(v)
      attackDelay = v
   end
})

CombatTab:CreateToggle({
   Name = "Auto Farm",
   CurrentValue = false,
   Callback = function(v)
      autoFarm = v
      if v then followEnabled = true end
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
-- AUTO ATTACK LOOP (CORRIGIDO)
---------------------------------------------------
task.spawn(function()
    while true do
        if autoAttack or autoFarm then
            if LP.Character then
                local tool = LP.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
            task.wait(attackDelay)
        else
            task.wait(0.1)
        end
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

        -- AUTO SELECT / FARM
        if autoSelect or autoFarm then
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

        -- HITBOX
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local part = p.Character.HumanoidRootPart
                part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                part.Transparency = hitboxTransparency
                part.CanCollide = false
            end
        end
    end
end)
