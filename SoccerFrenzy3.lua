local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local existingFolder = camera:FindFirstChild("PredictionVisual")
if existingFolder then
    existingFolder:Destroy()
end

local folder = Instance.new("Folder")
folder.Name = "PredictionVisual"
folder.Parent = camera

local pointsCount = 15
local attachments = {}
local beams = {}

for i = 1, pointsCount do
    local att = Instance.new("Attachment")
    att.Parent = workspace.Terrain
    table.insert(attachments, att)
    
    if i > 1 then
        local beam = Instance.new("Beam")
        beam.Attachment0 = attachments[i - 1]
        beam.Attachment1 = att
        beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 128))
        beam.Width0 = 0.15
        beam.Width1 = 0.15
        beam.FaceCamera = true
        beam.Transparency = NumberSequence.new(0, 0.5)
        beam.Enabled = false
        beam.Parent = folder
        table.insert(beams, beam)
    end
end

local espHighlight = Instance.new("Highlight")
espHighlight.Name = "BallESPHighlight"
espHighlight.FillColor = Color3.fromRGB(0, 255, 128)
espHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
espHighlight.FillTransparency = 0.4
espHighlight.OutlineTransparency = 0
espHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
espHighlight.Enabled = false
espHighlight.Parent = folder

local espBillboard = Instance.new("BillboardGui")
espBillboard.Name = "BallESPBillboard"
espBillboard.Size = UDim2.new(0, 160, 0, 50)
espBillboard.StudsOffset = Vector3.new(0, 3, 0)
espBillboard.AlwaysOnTop = true
espBillboard.Enabled = false
espBillboard.Parent = folder

local espText = Instance.new("TextLabel")
espText.Size = UDim2.new(1, 0, 1, 0)
espText.BackgroundTransparency = 1
espText.TextColor3 = Color3.fromRGB(0, 255, 128)
espText.TextStrokeTransparency = 0.2
espText.TextScaled = true
espText.Font = Enum.Font.GothamBold
espText.Text = "BALL [0m]"
espText.Parent = espBillboard

local predictionEnabled = false
local espEnabled = false
local hitboxEnabled = false
local hitboxSize = 5
local tpWalkEnabled = false
local tpWalkSpeed = 1
local autoDribbleEnabled = false
local autoStealEnabled = false
local autoGoalEnabled = false
local teleToBallEnabled = false
local aimbotShootEnabled = false
local aimbotBallDirEnabled = false
local aimbotOpponentEnabled = false
local infiniteStaminaEnabled = false
local speedBoostEnabled = false
local speedMultiplier = 16
local noClipEnabled = false
local visualColor = Color3.fromRGB(0, 255, 128)

local originalSizes = {}
local originalCollide = {}
local cachedBall = nil
local cachedGoal = nil
local lastVelMag = 0

local function getActiveBall()
    if cachedBall and cachedBall.Parent then return cachedBall end
    local ball = Workspace:FindFirstChild("TestBall")
    if ball then
        cachedBall = ball
        return ball
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("ball") or n:find("football") or n:find("soccer") then
                cachedBall = obj
                return obj
            end
        end
    end
    cachedBall = nil
    return nil
end

local function getOpponentGoal()
    if cachedGoal and cachedGoal.Parent then return cachedGoal end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local bestGoal = nil
    local maxDist = -math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("goal") or n:find("net") or n:find("post") then
                if root then
                    local dist = (root.Position - obj.Position).Magnitude
                    if dist > maxDist then
                        maxDist = dist
                        bestGoal = obj
                    end
                else
                    bestGoal = obj
                end
            end
        end
    end
    if bestGoal then cachedGoal = bestGoal end
    return bestGoal
end

local function getNearestOpponent()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local shortestDist = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local oppRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if oppRoot then
                local dist = (root.Position - oppRoot.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearest = oppRoot
                end
            end
        end
    end
    return nearest
end

local function restoreNoClip()
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCollide[part] ~= nil then
                    part.CanCollide = originalCollide[part]
                else
                    part.CanCollide = true
                end
            end
        end
    end
    originalCollide = {}
end

local Window = WindUI:CreateWindow({
    Title = "super larping frenzy",
    Icon = "book",
    Author = "soccer frenzy 3",
    Folder = "SuperLarpingFrenzyUI",
    Size = UDim2.fromOffset(500, 580),
    Transparent = true,
    Theme = "Dark"
})

pcall(function()
    local uiMain = Window.Root or Window.UI or Window.Container or (Window.Holder and Window.Holder.Parent)
    if uiMain then
        local bgImage = Instance.new("ImageLabel")
        bgImage.Name = "CustomBackgroundImage"
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.Position = UDim2.new(0, 0, 0, 0)
        bgImage.BackgroundTransparency = 1
        bgImage.Image = "rbxassetid://7112218123"
        bgImage.ScaleType = Enum.ScaleType.Slice
        bgImage.ZIndex = -999
        bgImage.Parent = uiMain
    end
end)

task.spawn(function()
    while true do
        cachedBall = getActiveBall()
        cachedGoal = getOpponentGoal()
        task.wait(0.3)
    end
end)

local MainTab = Window:Tab({
    Title = "Main Features",
    Icon = "home"
})

MainTab:Toggle({
    Title = "Enable Ball Prediction",
    Value = false,
    Callback = function(state)
        predictionEnabled = state
        for _, beam in ipairs(beams) do
            beam.Enabled = state
        end
    end
})

MainTab:Toggle({
    Title = "Enable Advanced Ball ESP",
    Value = false,
    Callback = function(state)
        espEnabled = state
        espHighlight.Enabled = state
        espBillboard.Enabled = state
    end
})

MainTab:Toggle({
    Title = "Enable Ball Hitbox Extender",
    Value = false,
    Callback = function(state)
        hitboxEnabled = state
        local ball = getActiveBall()
        if ball then
            if not originalSizes[ball] then
                originalSizes[ball] = ball.Size
            end
            if state then
                ball.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                ball.CanCollide = false
                ball.Transparency = 0.5
            else
                ball.Size = originalSizes[ball] or Vector3.new(1, 1, 1)
                ball.Transparency = 0
            end
        end
    end
})

MainTab:Slider({
    Title = "Hitbox Size",
    Step = 1,
    Value = { Min = 2, Max = 20, Default = 5 },
    Callback = function(val)
        hitboxSize = val
        if hitboxEnabled then
            local ball = getActiveBall()
            if ball then ball.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize) end
        end
    end
})

MainTab:Toggle({
    Title = "Enable Auto Dribble (Magnet)",
    Value = false,
    Callback = function(state) autoDribbleEnabled = state end
})

MainTab:Toggle({
    Title = "Enable Auto Steal Ball (Steal from others)",
    Value = false,
    Callback = function(state) autoStealEnabled = state end
})

MainTab:Toggle({
    Title = "Enable Auto Goal (Opponent Net)",
    Value = false,
    Callback = function(state) autoGoalEnabled = state end
})

MainTab:Toggle({
    Title = "Enable Teleport to Ball",
    Value = false,
    Callback = function(state) teleToBallEnabled = state end
})

MainTab:Toggle({
    Title = "Aimbot Shoot (Smooth Real Physics)",
    Value = false,
    Callback = function(state) aimbotShootEnabled = state end
})

MainTab:Toggle({
    Title = "Aimbot Ball Direction",
    Value = false,
    Callback = function(state) aimbotBallDirEnabled = state end
})

MainTab:Toggle({
    Title = "Aimbot Opponent Lock",
    Value = false,
    Callback = function(state) aimbotOpponentEnabled = state end
})

MainTab:Toggle({
    Title = "Infinite Stamina",
    Value = false,
    Callback = function(state) infiniteStaminaEnabled = state end
})

MainTab:Toggle({
    Title = "Speed Boost",
    Value = false,
    Callback = function(state)
        speedBoostEnabled = state
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = state and speedMultiplier or 16 end
    end
})

MainTab:Slider({
    Title = "Speed Multiplier",
    Step = 1,
    Value = { Min = 16, Max = 100, Default = 16 },
    Callback = function(val)
        speedMultiplier = val
        if speedBoostEnabled then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
})

MainTab:Toggle({
    Title = "NoClip (Walk through walls)",
    Value = false,
    Callback = function(state)
        noClipEnabled = state
        if not state then restoreNoClip() end
    end
})

MainTab:Colorpicker({
    Title = "Visual & ESP Color",
    Default = visualColor,
    Callback = function(color)
        visualColor = color
        for _, beam in ipairs(beams) do beam.Color = ColorSequence.new(color) end
        espHighlight.FillColor = color
        espText.TextColor3 = color
    end
})

MainTab:Toggle({
    Title = "Enable TPWalk",
    Value = false,
    Callback = function(state) tpWalkEnabled = state end
})

MainTab:Slider({
    Title = "TPWalk Speed",
    Step = 0.1,
    Value = { Min = 0, Max = 10, Default = 1 },
    Callback = function(val) tpWalkSpeed = val end
})

RunService.Stepped:Connect(function()
    local char = player.Character
    if noClipEnabled and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCollide[part] == nil then
                    originalCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if speedBoostEnabled and hum then
        hum.WalkSpeed = speedMultiplier
    end
    
    if tpWalkEnabled and root and hum and hum.MoveDirection.Magnitude > 0 then
        char:TranslateBy(hum.MoveDirection * tpWalkSpeed * dt * 10)
    end
    
    if infiniteStaminaEnabled and char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj.Name:lower():find("stamina") or obj.Name:lower():find("energy") then
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then obj.Value = 100 end
            end
        end
    end
    
    local ball = cachedBall
    local goal = cachedGoal
    
    if ball and root then
        if autoDribbleEnabled then
            local dist = (root.Position - ball.Position).Magnitude
            if dist < 18 then
                ball.CFrame = root.CFrame + (root.CFrame.LookVector * 2.5) + Vector3.new(0, -0.5, 0)
                ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
        
        if autoStealEnabled then
            local opp = getNearestOpponent()
            if opp then
                local ballDist = (ball.Position - opp.Position).Magnitude
                if ballDist < 12 then
                    ball.CFrame = root.CFrame + (root.CFrame.LookVector * 2)
                    ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
        
        if teleToBallEnabled then
            root.CFrame = ball.CFrame + Vector3.new(0, 3, 0)
        end
        
        if autoGoalEnabled and goal then
            ball.CFrame = goal.CFrame
            ball.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        
        if aimbotShootEnabled and goal then
            local currentVelMag = ball.AssemblyLinearVelocity.Magnitude
            if currentVelMag > 12 and currentVelMag > (lastVelMag + 3) then
                local shootDir = (goal.Position - ball.Position).Unit
                ball.AssemblyLinearVelocity = shootDir * 320
            end
            lastVelMag = currentVelMag
        end
        
        if aimbotBallDirEnabled and goal then
            local dir = (goal.Position - root.Position).Unit
            root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(dir.X, 0, dir.Z))
        end
        
        if aimbotOpponentEnabled then
            local opp = getNearestOpponent()
            if opp then
                local dir = (opp.Position - root.Position).Unit
                root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(dir.X, 0, dir.Z))
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local ball = cachedBall
    if not ball then
        for _, beam in ipairs(beams) do beam.Enabled = false end
        espHighlight.Enabled = false
        espBillboard.Enabled = false
        return
    end
    
    if hitboxEnabled then
        if not originalSizes[ball] then originalSizes[ball] = ball.Size end
        ball.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        ball.CanCollide = false
        ball.Transparency = 0.5
    end
    
    if espEnabled then
        espHighlight.Adornee = ball
        espBillboard.Adornee = ball
        espHighlight.Enabled = true
        espBillboard.Enabled = true
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = math.floor((root.Position - ball.Position).Magnitude)
            espText.Text = string.format("BALL [%dm]", dist)
        else
            espText.Text = "BALL"
        end
    else
        espHighlight.Enabled = false
        espBillboard.Enabled = false
    end
    
    if predictionEnabled then
        for _, beam in ipairs(beams) do beam.Enabled = true end
        local p0 = ball.Position
        local v0 = ball.AssemblyLinearVelocity
        local g = Vector3.new(0, -Workspace.Gravity, 0)
        for i, att in ipairs(attachments) do
            local t = (i - 1) * 0.04
            local pos = p0 + (v0 * t) + (0.5 * g * t^2)
            att.WorldPosition = pos
        end
    else
        for _, beam in ipairs(beams) do beam.Enabled = false end
    end
end)
