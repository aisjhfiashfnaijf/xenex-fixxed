-- ============================================================
-- XANAX.WTF — XENO-OPTIMIZED EDITION
-- Version-e7d81637d42c4b23 — FULLY COMPATIBLE
-- ============================================================

print("[XANAX] 🚀 Injecting into Xeno...")

-- ============================================================
-- CONFIGURATION (USING _G FOR XENO COMPATIBILITY)
-- ============================================================
_G.Xanax = {
    ['Settings'] = {
        ['Target Aim'] = true,
        ['Knock Check'] = true,
        ['Visible Check'] = false,
    },
    ['Keybinds'] = {
        ['Target Lock'] = { ['Key'] = 'E', ['Mode'] = 'Toggle' },
        ['Trigger Bot'] = { ['Key'] = 'T', ['Mode'] = 'Toggle' },
        ['Speed'] = 'Q',
        ['ESP'] = 'Y',
        ['Super Jump'] = 'V',
        ['Camera Lock'] = 'C',
    },
    ['UI'] = { ['Enabled'] = true },
    ['Silent Aim FOV'] = {
        ['Enabled'] = false,
        ['Visible'] = false,
        ['Radius'] = 100,
        ['Thickness'] = 2,
        ['Color'] = Color3.fromRGB(255, 0, 255),
    },
    ['Camera Lock FOV'] = {
        ['Enabled'] = true,
        ['Visible'] = true,
        ['Radius'] = 100,
        ['Thickness'] = 2,
        ['Color'] = Color3.fromRGB(255, 255, 0),
    },
    ['Silent Aim'] = {
        ['Enabled'] = false,
        ['Hit Part'] = 'uppertorso',
        ['Use Prediction'] = false,
        ['Prediction'] = { X = 0, Y = 0, Z = 0 },
    },
    ['Camera Lock'] = {
        ['Enabled'] = true,
        ['Smoothing'] = 30,
        ['Use Prediction'] = false,
        ['Prediction'] = 0.133,
    },
    ['Trigger Bot'] = {
        ['Enabled'] = false,
        ['Delay'] = 0.01,
        ['Specific Weapons'] = {
            ['Enabled'] = false,
            ['Weapons'] = {},
        },
    },
    ['Spread'] = {
        ['Enabled'] = true,  -- Xeno doesn't handle spread hooks well
        ['Amount'] = 0,
        ['Specific Weapons'] = { ['Enabled'] = false, ['Weapons'] = {} },
    },
    ['Speed'] = {
        ['Enabled'] = false,
        ['Multiplier'] = 15,  -- Lowered for Xeno stability
        ['Anti Fling'] = false,
    },
    ['Hitbox Expander'] = {
        ['Enabled'] = true,
        ['Size'] = 5,
        ['Visualize'] = false,
    },
    ['Spiderman'] = { ['Enabled'] = false },
    ['Visual Awareness'] = {
        ['Enabled'] = true,
        ['Color'] = Color3.fromRGB(255, 255, 255),
        ['Target Color'] = Color3.fromRGB(102, 178, 255),
    },
    ['Super Jump'] = {
        ['Enabled'] = false,
        ['Power'] = 200,
        ['Cooldown'] = 0.1,
    },
    ['Infinite Range'] = {
        ['Enabled'] = true,
        ['Key'] = 'N',
        ['Max Range'] = 7777777777,
    },
    ['Snapline'] = {
        ['Enabled'] = true,
        ['Color'] = Color3.fromRGB(255, 255, 255),
        ['Thickness'] = 2,
        ['MouseOffsetY'] = 58,
        ['TargetPart'] = 'Head',
    },
    ['Rapid Fire'] = {
        ['Enabled'] = false,
        ['Delay'] = 0.01,
        ['Specific Weapons'] = { ['Enabled'] = false, ['Weapons'] = {} },
    },
}

print("[XANAX] ✅ Config loaded!")

-- ============================================================
-- MAIN SCRIPT (XENO-COMPATIBLE)
-- ============================================================
local Config = _G.Xanax
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local currentTarget = nil
local isLocking = false
local triggerEnabled = false
local espLabels = {}
local SpeedEnabled = false
local BaseSpeed = 16
local lastTriggerClick = 0
local camlockEnabled = false
local camlockTarget = nil
local rapidFireActive = false
local infRangeActive = false
local lastJumpTime = 0
local deltaTime = 0.016

-- ============================================================
-- DRAWING (XENO-SAFE)
-- ============================================================
local silentFovCircle = nil
local camlockFovCircle = nil
local snaplineDrawing = nil

pcall(function()
    silentFovCircle = Drawing.new("Circle")
    silentFovCircle.Visible = false
    silentFovCircle.Thickness = Config['Silent Aim FOV']['Thickness'] or 2
    silentFovCircle.Color = Config['Silent Aim FOV']['Color'] or Color3.fromRGB(255, 0, 255)
    silentFovCircle.Filled = false
    silentFovCircle.NumSides = 60
    silentFovCircle.Radius = Config['Silent Aim FOV']['Radius'] or 150
    silentFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    silentFovCircle.ZIndex = 999
end)

pcall(function()
    camlockFovCircle = Drawing.new("Circle")
    camlockFovCircle.Visible = false
    camlockFovCircle.Thickness = Config['Camera Lock FOV']['Thickness'] or 2
    camlockFovCircle.Color = Config['Camera Lock FOV']['Color'] or Color3.fromRGB(255, 255, 0)
    camlockFovCircle.Filled = false
    camlockFovCircle.NumSides = 60
    camlockFovCircle.Radius = Config['Camera Lock FOV']['Radius'] or 150
    camlockFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    camlockFovCircle.ZIndex = 999
end)

pcall(function()
    snaplineDrawing = Drawing.new("Line")
    snaplineDrawing.Visible = false
    snaplineDrawing.Thickness = Config['Snapline']['Thickness'] or 2
    snaplineDrawing.Color = Config['Snapline']['Color'] or Color3.fromRGB(255, 255, 255)
    snaplineDrawing.ZIndex = 500
end)

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function isPlayerKnockedOrKO(player)
    if not Config['Settings']['Knock Check'] then return false end
    local char = player.Character
    if char then
        local bodyEffects = char:FindFirstChild("BodyEffects")
        if bodyEffects then
            local ko = bodyEffects:FindFirstChild("K.O")
            if ko and ko.Value == true then return true end
            local knocked = bodyEffects:FindFirstChild("Knocked")
            if knocked and knocked.Value == true then return true end
        end
    end
    return false
end

local function isSelfKnocked()
    local char = LocalPlayer.Character
    if char then
        local bodyEffects = char:FindFirstChild("BodyEffects")
        if bodyEffects then
            local ko = bodyEffects:FindFirstChild("K.O")
            if ko and ko.Value == true then return true end
            local knocked = bodyEffects:FindFirstChild("Knocked")
            if knocked and knocked.Value == true then return true end
        end
    end
    return false
end

local function canSeeTarget(part)
    if not Config['Settings']['Visible Check'] then return true end
    if not part or not part.Parent then return false end
    local character = part.Parent
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local rayResult = Workspace:Raycast(origin, direction, raycastParams)
    return rayResult == nil or rayResult.Instance:IsDescendantOf(character)
end

local function getClosestBodyPart(character)
    local closestPart = nil
    local shortestDist = math.huge
    local bodyParts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("UpperTorso"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("LowerTorso"),
        character:FindFirstChild("LeftUpperArm"),
        character:FindFirstChild("RightUpperArm"),
        character:FindFirstChild("LeftLowerArm"),
        character:FindFirstChild("RightLowerArm"),
        character:FindFirstChild("LeftHand"),
        character:FindFirstChild("RightHand"),
        character:FindFirstChild("LeftUpperLeg"),
        character:FindFirstChild("RightUpperLeg"),
        character:FindFirstChild("LeftLowerLeg"),
        character:FindFirstChild("RightLowerLeg"),
        character:FindFirstChild("LeftFoot"),
        character:FindFirstChild("RightFoot"),
    }
    for _, part in pairs(bodyParts) do
        if part then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and pos.Z > 0 then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPart = part
                end
            end
        end
    end
    return closestPart
end

local function isMouseInCircleFOV(radius)
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (mousePos - screenCenter).Magnitude <= radius
end

local function findClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    local fovConfig = Config['Silent Aim FOV']
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not isPlayerKnockedOrKO(player) then
                local targetPart = nil
                if Config['Silent Aim']['Hit Part'] == 'Closest Part' then
                    targetPart = getClosestBodyPart(player.Character)
                else
                    targetPart = player.Character:FindFirstChild(Config['Silent Aim']['Hit Part'])
                end
                if targetPart and canSeeTarget(targetPart) then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen and pos.Z > 0 then
                        if fovConfig.Enabled and not isMouseInCircleFOV(fovConfig.Radius) then
                            -- skip
                        else
                            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            if dist < shortestDistance then
                                shortestDistance = dist
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

local function findCamlockTarget()
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local bestPlayer, bestDist = nil, math.huge
    local fovConfig = Config['Camera Lock FOV']
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not isPlayerKnockedOrKO(player) then
                local part = player.Character:FindFirstChild("HumanoidRootPart")
                if part and canSeeTarget(part) then
                    if fovConfig.Enabled and not isMouseInCircleFOV(fovConfig.Radius) then
                        -- skip
                    else
                        local screenPos = Camera:WorldToViewportPoint(part.Position)
                        if screenPos and screenPos.Z > 0 then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < bestDist then
                                bestDist = dist
                                bestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPlayer
end

local function getPredictedPosition(part, config)
    if not config['Use Prediction'] then return part.Position end
    local velocity = part.AssemblyLinearVelocity or part.Velocity or Vector3.new(0, 0, 0)
    local prediction = config['Prediction']
    if type(prediction) == "table" then
        local predX = prediction['X'] or 0.133
        local predY = prediction['Y'] or 0.133
        local predZ = prediction['Z'] or 0.133
        return part.Position + Vector3.new(velocity.X * predX, velocity.Y * predY, velocity.Z * predZ)
    else
        if prediction == 0 then prediction = 0.1245 end
        return part.Position + (velocity * prediction)
    end
end

-- ============================================================
-- SILENT AIM (XENO-SAFE METATABLE HOOK)
-- ============================================================
pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = function(self, key)
        if self:IsA("Mouse") then
            if key == "Hit" or key == "Target" then
                if Config['Silent Aim']['Enabled'] and currentTarget then
                    local char = currentTarget.Parent
                    if char then
                        local player = Players:GetPlayerFromCharacter(char)
                        if player and not isPlayerKnockedOrKO(player) and canSeeTarget(currentTarget) then
                            if Config['Silent Aim FOV']['Enabled'] and not isMouseInCircleFOV(Config['Silent Aim FOV']['Radius']) then
                                -- outside FOV
                            else
                                if key == "Hit" then
                                    local hitPos = getPredictedPosition(currentTarget, Config['Silent Aim'])
                                    return CFrame.new(hitPos)
                                else
                                    return currentTarget
                                end
                            end
                        end
                    end
                end
            end
        end
        return oldIndex(self, key)
    end
    setreadonly(mt, true)
    print("[XANAX] ✅ Silent Aim hooked!")
end)

-- ============================================================
-- ESP (USES BILLBOARDGUI FOR XENO COMPATIBILITY)
-- ============================================================
local function addESPToPlayer(player)
    if player == LocalPlayer then return end
    local esp = Instance.new("BillboardGui")
    esp.Name = "XanaxESP"
    esp.Size = UDim2.new(0, 200, 0, 30)
    esp.StudsOffset = Vector3.new(0, 3, 0)
    esp.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel", esp)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.DisplayName or player.Name
    label.TextColor3 = Config['Visual Awareness']['Color'] or Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Arial
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.ZIndex = 1000
    
    espLabels[player.UserId] = { esp = esp, label = label, player = player }
    
    -- Attach to character
    if player.Character and player.Character:FindFirstChild("Head") then
        esp.Adornee = player.Character.Head
        esp.Parent = player.Character.Head
    end
end

local function removeESPFromPlayer(player)
    local data = espLabels[player.UserId]
    if data then
        data.esp:Destroy()
        espLabels[player.UserId] = nil
    end
end

local function refreshESP()
    for userId, data in pairs(espLabels) do
        local player = data.player
        if not player or not player.Parent then
            removeESPFromPlayer(player)
            continue
        end
        if player.Character and player.Character:FindFirstChild("Head") then
            data.esp.Adornee = player.Character.Head
            data.esp.Parent = player.Character.Head
            data.esp.Enabled = Config['Visual Awareness']['Enabled']
            
            -- Update color if targeted
            if currentTarget and currentTarget.Parent == player.Character then
                data.label.TextColor3 = Config['Visual Awareness']['Target Color'] or Color3.fromRGB(102, 178, 255)
            else
                data.label.TextColor3 = Config['Visual Awareness']['Color'] or Color3.fromRGB(255, 255, 255)
            end
        else
            data.esp.Enabled = false
        end
    end
end

-- Initialize ESP
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        addESPToPlayer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            addESPToPlayer(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESPFromPlayer(player)
end)

-- ============================================================
-- TRIGGERBOT
-- ============================================================
local function TriggerBot()
    if not Config['Trigger Bot']['Enabled'] then return end
    if not triggerEnabled then return end
    if tick() - lastTriggerClick < Config['Trigger Bot']['Delay'] then return end
    if not currentTarget then return end
    local character = currentTarget.Parent
    if not character then return end
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end
    if isPlayerKnockedOrKO(player) then return end
    if not canSeeTarget(currentTarget) then return end
    if Config['Silent Aim FOV']['Enabled'] and not isMouseInCircleFOV(Config['Silent Aim FOV']['Radius']) then
        return
    end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    if Config['Trigger Bot']['Specific Weapons']['Enabled'] then
        local weaponValid = false
        for _, weaponName in pairs(Config['Trigger Bot']['Specific Weapons']['Weapons']) do
            if tool.Name == weaponName then
                weaponValid = true
                break
            end
        end
        if not weaponValid then return end
    end
    tool:Activate()
    lastTriggerClick = tick()
end

-- ============================================================
-- CAMERA LOCK
-- ============================================================
local function applyCameraLock()
    if not camlockEnabled then return end
    if not Config['Camera Lock']['Enabled'] then return end
    if isSelfKnocked() then
        camlockTarget = nil
        return
    end
    if camlockTarget then
        local char = camlockTarget.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 or isPlayerKnockedOrKO(camlockTarget) then
            camlockTarget = nil
        end
    end
    if not camlockTarget then
        camlockTarget = findCamlockTarget()
    end
    if not camlockTarget then return end

    local part = camlockTarget.Character:FindFirstChild("HumanoidRootPart")
    if not part then return end

    local targetPos = getPredictedPosition(part, Config['Camera Lock'])
    local camCF = Camera.CFrame
    local targetCF = CFrame.new(camCF.Position, targetPos)
    local smooth = Config['Camera Lock']['Smoothing'] or 30
    local alpha = 1 - math.exp(-deltaTime * smooth)
    Camera.CFrame = camCF:Lerp(targetCF, math.min(alpha, 1))
end

-- ============================================================
-- UPDATE FOV CIRCLES
-- ============================================================
local function updateFOVCircles()
    if silentFovCircle then
        local silentCfg = Config['Silent Aim FOV']
        if silentCfg.Enabled and silentCfg.Visible then
            silentFovCircle.Visible = true
            silentFovCircle.Radius = silentCfg.Radius or 150
            silentFovCircle.Color = silentCfg.Color or Color3.fromRGB(255, 0, 255)
            silentFovCircle.Thickness = silentCfg.Thickness or 2
            silentFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else
            silentFovCircle.Visible = false
        end
    end

    if camlockFovCircle then
        local camCfg = Config['Camera Lock FOV']
        if camCfg.Enabled and camCfg.Visible then
            camlockFovCircle.Visible = true
            camlockFovCircle.Radius = camCfg.Radius or 150
            camlockFovCircle.Color = camCfg.Color or Color3.fromRGB(255, 255, 0)
            camlockFovCircle.Thickness = camCfg.Thickness or 2
            camlockFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else
            camlockFovCircle.Visible = false
        end
    end
end

-- ============================================================
-- UPDATE SNAPLINE
-- ============================================================
local function updateSnapline()
    if snaplineDrawing and Config['Snapline']['Enabled'] and currentTarget then
        local targetPart = nil
        local targetChar = currentTarget.Parent
        if targetChar then
            targetPart = targetChar:FindFirstChild(Config['Snapline']['TargetPart'] or 'Head')
        end
        if targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen and screenPos.Z > 0 then
                local startPos = Vector2.new(Mouse.X, Mouse.Y + (Config['Snapline']['MouseOffsetY'] or 58))
                snaplineDrawing.From = startPos
                snaplineDrawing.To = Vector2.new(screenPos.X, screenPos.Y)
                snaplineDrawing.Visible = true
            else
                snaplineDrawing.Visible = false
            end
        else
            snaplineDrawing.Visible = false
        end
    elseif snaplineDrawing then
        snaplineDrawing.Visible = false
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    deltaTime = dt

    if isSelfKnocked() and isLocking then
        currentTarget = nil
        isLocking = false
    end

    TriggerBot()

    -- Speed
    if SpeedEnabled and Config['Speed']['Enabled'] then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local targetSpeed = BaseSpeed * Config['Speed']['Multiplier']
            if humanoid.WalkSpeed ~= targetSpeed then
                humanoid.WalkSpeed = targetSpeed
            end
        end
        if Config['Speed']['Anti Fling'] then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity
                if vel.Y > 50 or vel.Y < -50 then
                    hrp.Velocity = Vector3.new(vel.X, 0, vel.Z)
                end
            end
        end
    end

    -- Hitbox Expander
    if Config['Hitbox Expander']['Enabled'] then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(Config['Hitbox Expander']['Size'] or 5, Config['Hitbox Expander']['Size'] or 5, Config['Hitbox Expander']['Size'] or 5)
                    if Config['Hitbox Expander']['Visualize'] then
                        hrp.Transparency = 0.7
                        hrp.BrickColor = BrickColor.new("Really blue")
                        hrp.Material = "Neon"
                        hrp.CanCollide = false
                    else
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end

    updateFOVCircles()
    refreshESP()
    updateSnapline()
    applyCameraLock()
end)

-- ============================================================
-- SUPER JUMP
-- ============================================================
RunService.Stepped:Connect(function()
    if not Config['Super Jump']['Enabled'] then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    local holdingV = UserInputService:IsKeyDown(Enum.KeyCode[Config['Keybinds']['Super Jump']])
    if holdingV and (humanoid:GetState() == Enum.HumanoidStateType.Landed or humanoid.FloorMaterial ~= Enum.Material.Air) then
        if tick() - lastJumpTime >= Config['Super Jump']['Cooldown'] then
            rootPart.Velocity = Vector3.new(
                rootPart.Velocity.X,
                Config['Super Jump']['Power'] or 200,
                rootPart.Velocity.Z
            )
            lastJumpTime = tick()
        end
    end
end)

-- ============================================================
-- INFINITE RANGE
-- ============================================================
RunService.Stepped:Connect(function()
    if not Config['Infinite Range']['Enabled'] or not infRangeActive then return end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local rangeProps = {"Range", "MaxRange", "FireRange", "Distance", "MaxDistance"}
    for _, propName in pairs(rangeProps) do
        local rangeValue = tool:FindFirstChild(propName)
        if rangeValue and rangeValue:IsA("NumberValue") then
            rangeValue.Value = Config['Infinite Range']['Max Range'] or 77777
        end
        local config = tool:FindFirstChild("Configuration") or tool:FindFirstChild("GunConfig")
        if config then
            local r = config:FindFirstChild(propName)
            if r and r:IsA("NumberValue") then
                r.Value = Config['Infinite Range']['Max Range'] or 77777
            end
        end
    end
end)

-- ============================================================
-- RAPID FIRE
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        rapidFireActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        rapidFireActive = false
    end
end)

RunService.Heartbeat:Connect(function()
    if not Config['Rapid Fire']['Enabled'] or not rapidFireActive then return end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    if Config['Rapid Fire']['Specific Weapons']['Enabled'] then
        local valid = false
        for _, wName in pairs(Config['Rapid Fire']['Specific Weapons']['Weapons']) do
            if tool.Name == wName then
                valid = true
                break
            end
        end
        if not valid then return end
    end
    tool:Activate()
    task.wait(Config['Rapid Fire']['Delay'] or 0.1)
end)

-- ============================================================
-- INPUT HANDLING
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode[Config['Keybinds']['Target Lock']['Key']] then
        local mode = Config['Keybinds']['Target Lock']['Mode']
        if mode == 'Toggle' then
            if Config['Settings']['Target Aim'] then
                if isLocking then
                    isLocking = false
                    currentTarget = nil
                else
                    local target = findClosestTarget()
                    if target then
                        currentTarget = target
                        isLocking = true
                    end
                end
            else
                isLocking = not isLocking
            end
        elseif mode == 'Hold' then
            if Config['Settings']['Target Aim'] then
                local target = findClosestTarget()
                if target then
                    currentTarget = target
                    isLocking = true
                end
            else
                isLocking = true
            end
        end
    end

    if input.KeyCode == Enum.KeyCode[Config['Keybinds']['Trigger Bot']['Key']] then
        local mode = Config['Keybinds']['Trigger Bot']['Mode']
        if mode == 'Toggle' then
            triggerEnabled = not triggerEnabled
            print("[XANAX] Triggerbot: " .. (triggerEnabled and "ON" or "OFF"))
        elseif mode == 'Hold' then
            triggerEnabled = true
        end
    end

    if input.KeyCode == Enum.KeyCode[Config['Keybinds']['Speed']] then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            if not SpeedEnabled then
                BaseSpeed = 16
                SpeedEnabled = true
                print("[XANAX] Speed: ON")
            else
                humanoid.WalkSpeed = BaseSpeed
                SpeedEnabled = false
                print("[XANAX] Speed: OFF")
            end
        end
    end

    if input.KeyCode == Enum.KeyCode[Config['Keybinds']['ESP']] then
        Config['Visual Awareness']['Enabled'] = not Config['Visual Awareness']['Enabled']
        print("[XANAX] ESP: " .. (Config['Visual Awareness']['Enabled'] and "ON" or "OFF"))
    end

    if input.KeyCode == Enum.KeyCode[Config['Keybinds']['Camera Lock']] then
        if Config['Camera Lock']['Enabled'] then
            camlockEnabled = not camlockEnabled
            camlockTarget = nil
            print("[XANAX] Camlock: " .. (camlockEnabled and "ON" or "OFF"))
        end
    end

    if input.KeyCode == Enum.KeyCode[Config['Infinite Range']['Key']] then
        infRangeActive = not infRangeActive
        print("[XANAX] Infinite Range: " .. (infRangeActive and "ON" or "OFF"))
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode[Config['Keybinds']['Target Lock']['Key']] then
        if Config['Keybinds']['Target Lock']['Mode'] == 'Hold' then
            isLocking = false
            currentTarget = nil
        end
    end
    if input.KeyCode == Enum.KeyCode[Config['Keybinds']['Trigger Bot']['Key']] then
        if Config['Keybinds']['Trigger Bot']['Mode'] == 'Hold' then
            triggerEnabled = false
        end
    end
end)

-- ============================================================
-- GUI STATUS
-- ============================================================
if Config['UI'] and Config['UI']['Enabled'] then
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.CoreGui
    gui.IgnoreGuiInset = true

    local text = Instance.new("TextLabel")
    text.Parent = gui
    text.AnchorPoint = Vector2.new(0.5, 1)
    text.Position = UDim2.new(0.5, 0, 1, -110)
    text.Size = UDim2.new(0, 260, 0, 180)
    text.BackgroundTransparency = 1
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Bottom
    text.Font = Enum.Font.Arial
    text.TextSize = 19
    text.RichText = true
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    RunService.RenderStepped:Connect(function()
        local lines = {}
        table.insert(lines, '<b><font color="rgb(102,178,255)">Xanax.wtf</font></b>')

        if SpeedEnabled then
            table.insert(lines, '<font color="rgb(255,255,255)">speed-walk</font><font color="rgb(102,178,255)"> [ON]</font>')
        else
            table.insert(lines, '<font color="rgb(255,255,255)">speed-walk</font>')
        end

        if Config["Silent Aim"]["Enabled"] and currentTarget then
            local targetName = ""
            local targetChar = currentTarget.Parent
            if targetChar then
                local player = Players:GetPlayerFromCharacter(targetChar)
                if player then
                    targetName = player.DisplayName ~= "" and player.DisplayName or player.Name
                end
            end
            table.insert(lines, '<font color="rgb(255,255,255)">silent-aim</font><font color="rgb(102,178,255)"> [ ' .. targetName .. ' ]</font>')
        else
            table.insert(lines, '<font color="rgb(255,255,255)">silent-aim</font>')
        end

        if Config["Trigger Bot"]["Enabled"] and triggerEnabled then
            table.insert(lines, '<font color="rgb(255,255,255)">trigger-bot</font><font color="rgb(102,178,255)"> [ON]</font>')
        else
            table.insert(lines, '<font color="rgb(255,255,255)">trigger-bot</font>')
        end

        if infRangeActive then
            table.insert(lines, '<font color="rgb(255,255,255)">infinite-range</font><font color="rgb(102,178,255)"> [ON]</font>')
        else
            table.insert(lines, '<font color="rgb(255,255,255)">infinite-range</font>')
        end

        if camlockEnabled then
            local name = camlockTarget and (camlockTarget.DisplayName ~= "" and camlockTarget.DisplayName or camlockTarget.Name) or "none"
            table.insert(lines, '<font color="rgb(255,255,255)">camlock</font><font color="rgb(102,178,255)"> [' .. name .. ']</font>')
        else
            table.insert(lines, '<font color="rgb(255,255,255)">camlock</font>')
        end

        text.Text = table.concat(lines, "\n")
    end)
end

print("[XANAX] 🚀 All systems go! Ready to dominate.")
print("[XANAX] Keybinds: E=Lock | T=Trigger | Q=Speed | Y=ESP | V=SuperJump | C=CamLock | N=InfiniteRange")
print("[XANAX] 💡 If you see this, Xeno injection was successful!")
