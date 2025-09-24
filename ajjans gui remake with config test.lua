-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AjjansHub"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Icon Button (Circular, toggles main GUI)
local IconButton = Instance.new("TextButton")
IconButton.Size = UDim2.new(0, 60, 0, 60)
IconButton.Position = UDim2.new(0, 10, 0, 10)
IconButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
IconButton.Text = "Ajjans"
IconButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IconButton.TextSize = 14
IconButton.Font = Enum.Font.GothamBold
IconButton.Parent = ScreenGui

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0) -- Circular
IconCorner.Parent = IconButton

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Initially hidden
MainFrame.Parent = ScreenGui

-- Make Frame Draggable
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
makeDraggable(MainFrame)

-- Corner Rounding
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Close Button (Cross Mark)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0, 10, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Top Label
local TopLabel = Instance.new("TextLabel")
TopLabel.Size = UDim2.new(1, 0, 0, 50)
TopLabel.Position = UDim2.new(0, 0, 0, 0)
TopLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopLabel.Text = "Steal a Brainrot | Ajjans"
TopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TopLabel.TextSize = 24
TopLabel.Font = Enum.Font.GothamBold
TopLabel.Parent = MainFrame

local TopLabelCorner = Instance.new("UICorner")
TopLabelCorner.CornerRadius = UDim.new(0, 10)
TopLabelCorner.Parent = TopLabel

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 30)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

-- Tab Buttons
local tabs = {"Main", "Visual", "Misc", "Settings"}
local tabFrames = {}
local tabButtons = {}
local toggleButtons = {}
local toggleLabels = {}

-- Toggle State and Connections
local featureStates = {
    InfiniteJump = false,
    LockBaseReminder = false,
    GodMode = false,
    FreezePlayer = false,
    BaselockESP = false,
    SpeedBoost = false,
    MiscAjjans = false,
    SettingsAjjans = false,
    FloatV1 = false,
    FloatV2 = false,
    AntiTrap = false,
    NoCooldownBat = false,
    AutoHitNearPlayer = false,
    AntiBee = false,
    ControlPlayer = false,
    FPSBooster = false,
    DestroyTurret = false,
    FpsDevourer = false,
    TargetOwner = false,
    SemiInvisible = false,
    StealAllFloor = false,
}
local connections = {
    InfiniteJump = {},
    LockBaseReminder = {},
    GodMode = {},
    FreezePlayer = {},
    BaselockESP = {},
    SpeedBoost = {},
    FloatV1 = {},
    FloatV2 = {},
    AntiTrap = {},
    NoCooldownBat = {},
    AutoHitNearPlayer = {},
    AntiBee = {},
    ControlPlayer = {},
    FPSBooster = {},
    DestroyTurret = {},
    FpsDevourer = {},
    TargetOwner = {},
    SemiInvisible = {},
    StealAllFloor = {},
}

-- ESP Instances
local lteInstances = {}

-- Notify Function (Placeholder)
local function notify(title, description, disabled)
    print(string.format("%s: %s", title, disabled and "Disabled" or (description or "Enabled")))
    -- Replace with your actual notify function
end

-- Infinite Jump Functionality
local function infiniteJumpFunction(enabled)
    if enabled then
        local player = Players.LocalPlayer
        local jumpVelocity = 20 -- upward boost strength

        local function setupInfiniteJump()
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            local root = character:WaitForChild("HumanoidRootPart")

            local jumpConn = RunService.RenderStepped:Connect(function()
                if featureStates.InfiniteJump and humanoid.Jump then
                    root.AssemblyLinearVelocity = Vector3.new(
                        root.AssemblyLinearVelocity.X,
                        jumpVelocity,
                        root.AssemblyLinearVelocity.Z
                    )
                end
            end)
            table.insert(connections.InfiniteJump, jumpConn)
        end

        if player.Character then
            setupInfiniteJump()
        end

        local charConn = player.CharacterAdded:Connect(function()
            if featureStates.InfiniteJump then
                setupInfiniteJump()
            end
        end)
        table.insert(connections.InfiniteJump, charConn)

        notify("Infinite Jump", nil, false)
    else
        for _, conn in ipairs(connections.InfiniteJump) do
            if conn then conn:Disconnect() end
        end
        connections.InfiniteJump = {}
        notify("Infinite Jump", nil, true)
    end
end

-- Lock Base Reminder Functionality
local function lockBaseReminderFunction(enabled)
    if enabled then
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://pastebin.com/raw/GwqY2RLV"))()
        end)
        if success then
            table.insert(connections.LockBaseReminder, result)
            notify("Lock Base Reminder", nil, false)
        else
            featureStates.LockBaseReminder = false
            toggleButtons.LockBaseReminder.Position = UDim2.new(0, 5, 0, 2.5)
            toggleButtons.LockBaseReminder.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            notify("Lock Base Reminder -- Error", "Failed to load script: " .. tostring(result), true)
        end
    else
        for _, conn in ipairs(connections.LockBaseReminder) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        connections.LockBaseReminder = {}
        notify("Lock Base Reminder", nil, true)
    end
end

-- God Mode Functionality
local function godModeFunction(enabled)
    local player = Players.LocalPlayer
    if enabled then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local tag = Instance.new("BoolValue")
            tag.Name = "NoDamage"
            tag.Parent = hum
            notify("God Mode", nil, false)
        else
            notify("God Mode -- Error", "Humanoid not found", true)
        end
    else
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:FindFirstChild("NoDamage") then
                hum.NoDamage:Destroy()
            end
            notify("God Mode", nil, true)
        end
    end
end

-- Freeze Player Functionality
local function freezePlayerFunction(enabled)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local walkflinging = false

    if enabled then
        local function disablePlayerCollisions()
            local conn = RunService.Stepped:Connect(function()
                if not featureStates.FreezePlayer then
                    conn:Disconnect()
                    return
                end
                local myChar = LocalPlayer.Character
                if myChar then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            for _, part in ipairs(plr.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
            table.insert(connections.FreezePlayer, conn)
        end

        local function stopWalkFling()
            walkflinging = false
        end

        local function startWalkFling()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                local diedConn = humanoid.Died:Connect(function()
                    stopWalkFling()
                end)
                table.insert(connections.FreezePlayer, diedConn)
            end

            walkflinging = true
            local flingConn = coroutine.create(function()
                repeat
                    RunService.Heartbeat:Wait()
                    if not featureStates.FreezePlayer then
                        break
                    end
                    character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    local vel, movel = nil, 0.1

                    while not (character and character.Parent and root and root.Parent) do
                        RunService.Heartbeat:Wait()
                        if not featureStates.FreezePlayer then
                            break
                        end
                        character = LocalPlayer.Character
                        root = character and character:FindFirstChild("HumanoidRootPart")
                    end

                    if not featureStates.FreezePlayer then
                        break
                    end

                    vel = root.Velocity
                    root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

                    RunService.RenderStepped:Wait()
                    if character and character.Parent and root and root.Parent then
                        root.Velocity = vel
                    end

                    RunService.Stepped:Wait()
                    if character and character.Parent and root and root.Parent then
                        root.Velocity = vel + Vector3.new(0, movel, 0)
                        movel = movel * -1
                    end
                until walkflinging == false or not featureStates.FreezePlayer
            end)
            coroutine.resume(flingConn)
            table.insert(connections.FreezePlayer, flingConn)
        end

        disablePlayerCollisions()
        startWalkFling()
        notify("Freeze Player", "✅ Freeze Player enabled!", false)
    else
        for _, conn in ipairs(connections.FreezePlayer) do
            if conn then
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                elseif typeof(conn) == "thread" then
                    task.cancel(conn)
                end
            end
        end
        connections.FreezePlayer = {}
        walkflinging = false
        notify("Freeze Player", "⛔ Freeze Player disabled", true)
    end
end

local function speedBoostFunction(enabled)
    local player = Players.LocalPlayer
    local CONFIG = {
        Speed = 25,         -- Target horizontal speed
        JumpPower = 70     -- Jump power
    }

    if enabled then
        local function setupSpeedBoost()
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Set jump power
            humanoid.UseJumpPower = true
            humanoid.JumpPower = CONFIG.JumpPower

            -- Disable default WalkSpeed
            humanoid.WalkSpeed = 0

            -- Loop to manually apply velocity
            local speedConn = RunService.Stepped:Connect(function(_, deltaTime)
                if not featureStates.SpeedBoost then return end
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    local desiredVel = moveDir.Unit * CONFIG.Speed
                    hrp.Velocity = Vector3.new(desiredVel.X, hrp.Velocity.Y, desiredVel.Z)
                end
            end)
            table.insert(connections.SpeedBoost, speedConn)
        end

        -- Initial setup
        if player.Character then
            setupSpeedBoost()
        end

        -- Handle character respawn
        local charConn = player.CharacterAdded:Connect(function()
            if featureStates.SpeedBoost then
                setupSpeedBoost()
            end
        end)
        table.insert(connections.SpeedBoost, charConn)

        notify("Speed Boost", "✅ Speed Boost enabled!", false)
    else
        -- Disable feature
        for _, conn in ipairs(connections.SpeedBoost) do
            if conn then conn:Disconnect() end
        end
        connections.SpeedBoost = {}

        -- Reset to default
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid then
                humanoid.JumpPower = 50 -- Default Roblox jump power
                humanoid.WalkSpeed = 16 -- Default Roblox walk speed
            end
            if hrp then
                -- Reset velocity to prevent lingering effects
                hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
            end
        end

        notify("Speed Boost", "⛔ Speed Boost disabled", true)
    end
end

local function floatV1Function(enabled)
    local player = Players.LocalPlayer
    local GLIDE_SPEED = 12 -- Controls glide speed
    local GLIDE_HEIGHT_OFFSET = -2 -- Target height below current position

    if enabled then
        local function applyGlide(char)
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if not torso then
                notify("Float V1 -- Error", "Torso not found", true)
                return
            end

            if torso:FindFirstChild("GlidePos") then
                torso.GlidePos:Destroy()
            end

            local bp = Instance.new("BodyPosition")
            bp.Name = "GlidePos"
            bp.MaxForce = Vector3.new(0, math.huge, 0)
            bp.Position = torso.Position + Vector3.new(0, GLIDE_HEIGHT_OFFSET, 0)
            bp.D = 1000 -- Damping for smooth movement
            bp.P = 5000 -- Power for responsiveness
            bp.Parent = torso

            local glideThread = spawn(function()
                while featureStates.FloatV1 and torso and torso.Parent and bp.Parent do
                    bp.Position = torso.Position + Vector3.new(0, GLIDE_HEIGHT_OFFSET, 0)
                    task.wait(GLIDE_SPEED / 10)
                end
                if bp and bp.Parent then
                    bp:Destroy()
                end
            end)
            table.insert(connections.FloatV1, { Disconnect = function() task.cancel(glideThread) end })
        end

        -- Apply to current character
        if player.Character then
            applyGlide(player.Character)
        end

        -- Re-apply when respawning
        local charConn = player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid")
            task.wait(1)
            if featureStates.FloatV1 then
                applyGlide(char)
            end
        end)
        table.insert(connections.FloatV1, charConn)

        -- Create GUI
        local oldGui = player.PlayerGui:FindFirstChild("GlideToggleGUI")
        if oldGui then oldGui:Destroy() end

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "GlideToggleGUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = player:WaitForChild("PlayerGui")

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(0, 120, 0, 40)
        ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.Font = Enum.Font.SourceSansBold
        ToggleBtn.TextSize = 18
        ToggleBtn.Text = "Float V1: ON"
        ToggleBtn.Parent = ScreenGui

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = ToggleBtn

        ToggleBtn.MouseButton1Click:Connect(function()
            featureStates.FloatV1 = not featureStates.FloatV1
            toggleButtons.FloatV1.Position = UDim2.new(featureStates.FloatV1 and 0.5 or 0, 5, 0, 2.5)
            toggleButtons.FloatV1.BackgroundColor3 = featureStates.FloatV1 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            ToggleBtn.Text = featureStates.FloatV1 and "Float V1: ON" or "Float V1: OFF"
            floatV1Function(featureStates.FloatV1)
        end)

        notify("Float V1", "✅ Float V1 enabled!", false)
    else
        -- Disable feature
        for _, conn in ipairs(connections.FloatV1) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        connections.FloatV1 = {}
        if player.Character then
            local torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
            if torso and torso:FindFirstChild("GlidePos") then
                torso.GlidePos:Destroy()
            end
        end
        pcall(function()
            local oldGui = player.PlayerGui:FindFirstChild("GlideToggleGUI")
            if oldGui then oldGui:Destroy() end
        end)
        notify("Float V1", "⛔ Float V1 disabled", true)
    end
end

local function floatV2Function(enabled)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local ProximityPromptService = game:GetService("ProximityPromptService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local Net = require(ReplicatedStorage.Packages:WaitForChild("Net"))

    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local HumanoidRootPart
    local FLOAT_OFFSET = Vector3.new(0, -3, 0)
    local movedHandles = {}
    local floatOn = featureStates.FloatV2 -- Use featureStates to track state
    local dragInput
    local tracked
    local useItem = Net:RemoteEvent("UseItem")
    local holds = {}

    if enabled then
        -- GUI Setup
        local gui = Instance.new("ScreenGui", PlayerGui)
        gui.ResetOnSpawn = false
        gui.Name = "BBFloatGUI"

        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 220, 0, 120)
        frame.Position = UDim2.new(0.1, 0, 0.2, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BorderSizePixel = 0

        local uicorner = Instance.new("UICorner", frame)
        uicorner.CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Thickness = 2

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundTransparency = 1
        title.Text = "Ajjans Float UI V2"
        title.Font = Enum.Font.GothamBold
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 20

        local button = Instance.new("TextButton", frame)
        button.Size = UDim2.new(0, 160, 0, 44)
        button.Position = UDim2.new(0.5, 0, 0.5, 15)
        button.AnchorPoint = Vector2.new(0.5, 0.5)
        button.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
        button.Text = "Float Off"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 18
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

        -- Dragging Functionality
        local function drag(frame)
            local dragging, dragStart, startPos, tween
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            frame.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    local delta = input.Position - dragStart
                    local goal = { Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) }
                    if tween then tween:Cancel() end
                    tween = TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
                    tween:Play()
                end
            end)
        end
        drag(frame)

        -- Button State Management
        local function setButtonState(on)
            floatOn = on
            featureStates.FloatV2 = on -- Sync with featureStates
            if on then
                button.BackgroundColor3 = Color3.fromRGB(70, 200, 90)
                button.Text = "Float On"
            else
                button.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
                button.Text = "Float Off"
            end
        end

        -- Initialize button state
        setButtonState(floatOn)

        local buttonConn = button.MouseButton1Click:Connect(function()
            setButtonState(not floatOn)
        end)
        table.insert(connections.FloatV2, buttonConn)

        local mouseEnterConn = button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(0, 176, 0, 52) }):Play()
        end)
        table.insert(connections.FloatV2, mouseEnterConn)

        local mouseLeaveConn = button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(0, 160, 0, 44) }):Play()
        end)
        table.insert(connections.FloatV2, mouseLeaveConn)

        -- Boogie Bomb Utility Functions
        local function getBoogieBomb()
            local character = LocalPlayer.Character
            if character then
                for _, v in ipairs(character:GetChildren()) do
                    if v:IsA("Tool") and v.Name == "Boogie Bomb" then
                        return v
                    end
                end
            end
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, v in ipairs(backpack:GetChildren()) do
                    if v:IsA("Tool") and v.Name == "Boogie Bomb" then
                        return v
                    end
                end
            end
        end

        local function equipBoogieBomb()
            local tool = getBoogieBomb()
            if not tool then return false end
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                pcall(function() humanoid:EquipTool(tool) end)
                return true
            end
            return false
        end

        local function findHandle()
            for _, v in ipairs(Workspace:GetChildren()) do
                if v:IsA("BasePart") and v.Name == "Handle" then
                    return v
                end
                local model = v:FindFirstChild("Handle")
                if model and model:IsA("BasePart") and model.Parent == Workspace then
                    return model
                end
            end
        end

        local function getHumanoidRootPart()
            local character = LocalPlayer.Character
            if not character then return end
            return character:FindFirstChild("HumanoidRootPart")
        end

        -- Proximity Prompt Handling
        local function fireUseItemAndPlaceHandle()
            equipBoogieBomb()
            if useItem then
                useItem:FireServer()
            end
            tracked = findHandle()
            local hrp = getHumanoidRootPart()
            if tracked and hrp then
                pcall(function()
                    tracked.CFrame = CFrame.new(hrp.Position + FLOAT_OFFSET)
                end)
            end
        end

        local promptBeganConn = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
            if player ~= LocalPlayer then return end
            local t = {}
            holds[prompt] = t
            local duration = 0
            pcall(function() duration = prompt.HoldDuration or 0 end)
            local delaySeconds = duration > 0.2 and (duration - 0.2) or 0
            task.delay(delaySeconds, function()
                if holds[prompt] == t then
                    fireUseItemAndPlaceHandle()
                end
            end)
        end)
        table.insert(connections.FloatV2, promptBeganConn)

        local promptEndedConn = ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, player)
            if player == LocalPlayer then
                cancel(prompt)
            end
        end)
        table.insert(connections.FloatV2, promptEndedConn)

        local promptTriggeredConn = ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
            if player == LocalPlayer then
                cancel(prompt)
            end
        end)
        table.insert(connections.FloatV2, promptTriggeredConn)

        local function cancel(prompt)
            holds[prompt] = nil
        end

        -- New Floating Mechanism
        local function updateCharacter(char)
            HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
        end

        if LocalPlayer.Character then
            updateCharacter(LocalPlayer.Character)
        end
        local charConn = LocalPlayer.CharacterAdded:Connect(updateCharacter)
        table.insert(connections.FloatV2, charConn)

        local function makeInvisible(part)
            part.Transparency = 0
            for _, child in ipairs(part:GetDescendants()) do
                if child:IsA("Decal") or child:IsA("Texture") or child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("SurfaceGui") then
                    child.Enabled = false
                elseif child:IsA("BasePart") then
                    child.Transparency = 1
                end
            end
        end

        local function makeAlign(part)
            makeInvisible(part)
            local alignPos = Instance.new("AlignPosition")
            alignPos.MaxForce = 1e6
            alignPos.Responsiveness = 150
            alignPos.RigidityEnabled = true
            alignPos.ReactionForceEnabled = false
            alignPos.ApplyAtCenterOfMass = true
            alignPos.Parent = part

            local alignOri = Instance.new("AlignOrientation")
            alignOri.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            alignOri.Responsiveness = 150
            alignOri.RigidityEnabled = true
            alignOri.Parent = part

            local att0 = Instance.new("Attachment", part)
            local att1 = Instance.new("Attachment", Workspace.Terrain)
            alignPos.Attachment0 = att0
            alignPos.Attachment1 = att1
            alignOri.Attachment0 = att0
            alignOri.Attachment1 = att1

            return {
                alignPos = alignPos,
                alignOri = alignOri,
                att0 = att0,
                att1 = att1,
                part = part
            }
        end

        local heartbeatConn = RunService.Heartbeat:Connect(function()
            if not floatOn or not HumanoidRootPart then return end

            for _, part in pairs(Workspace:GetChildren()) do
                if part:IsA("BasePart") and part.Name == "Handle" then
                    local isPlayerPart = false
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character and part:IsDescendantOf(player.Character) then
                            isPlayerPart = true
                            break
                        end
                    end
                    if isPlayerPart then continue end

                    if not movedHandles[part] then
                        movedHandles[part] = makeAlign(part)
                    end

                    local alignData = movedHandles[part]
                    if alignData and alignData.att1 then
                        alignData.att1.Position = HumanoidRootPart.Position + FLOAT_OFFSET
                    end
                end
            end
        end)
        table.insert(connections.FloatV2, heartbeatConn)

        -- Button Text Change Handling
        local textConn = button:GetPropertyChangedSignal("Text"):Connect(function()
            if floatOn and not tracked then
                tracked = findHandle()
            end
        end)
        table.insert(connections.FloatV2, textConn)

        -- UI Stroke Animation
        local hue = 0
        local strokeConn = RunService.Heartbeat:Connect(function(dt)
            hue = (hue + dt * 0.2) % 1
            stroke.Color = Color3.fromHSV(hue, 1, 1)
        end)
        table.insert(connections.FloatV2, strokeConn)

        notify("Float V2", "✅ Float V2 enabled!", false)
    else
        -- Disable feature
        for _, conn in ipairs(connections.FloatV2) do
            if conn then
                conn:Disconnect()
            end
        end
        connections.FloatV2 = {}
        movedHandles = {} -- Clear movedHandles
        local oldGui = PlayerGui:FindFirstChild("BBFloatGUI")
        if oldGui then
            oldGui:Destroy()
        end
        notify("Float V2", "⛔ Float V2 disabled", true)
    end
end

local function antiTrapFunction(enabled)
    if enabled then
        local HITBOX_XZ = 4.5 -- width/length
        local HITBOX_Y = 3 -- height

        local function isPlacedTrap(trap)
            -- Ignore traps inside players' characters
            if trap.Parent:IsA("Model") and game.Players:GetPlayerFromCharacter(trap.Parent) then
                return false
            end
            -- Ignore traps inside tools
            if trap:IsDescendantOf(game.Players) or trap:IsA("Tool") then
                return false
            end
            return true
        end

        local function createHitbox(trap)
            if trap:FindFirstChild("TrapHitbox") then return end
            if not isPlacedTrap(trap) then return end

            local block = Instance.new("Part")
            block.Name = "TrapHitbox"
            block.Anchored = true
            block.CanCollide = true
            block.Transparency = 1 -- invisible
            block.Color = Color3.fromRGB(255, 0, 0)
            block.Size = Vector3.new(HITBOX_XZ, HITBOX_Y, HITBOX_XZ)

            block.CFrame = trap:GetPivot()
            block.Parent = trap

            -- Keep hitbox position synced
            local hitboxConn = task.spawn(function()
                while block.Parent == trap do
                    pcall(function()
                        if isPlacedTrap(trap) then
                            block.CFrame = trap:GetPivot()
                        else
                            block:Destroy()
                        end
                    end)
                    task.wait(0.05)
                end
            end)
            table.insert(connections.AntiTrap, hitboxConn)
        end

        -- Scan existing traps
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Trap" and obj:IsA("Model") and isPlacedTrap(obj) then
                createHitbox(obj)
            end
        end

        -- Detect new traps
        local descendantAddedConn = workspace.DescendantAdded:Connect(function(obj)
            if obj.Name == "Trap" and obj:IsA("Model") and isPlacedTrap(obj) then
                createHitbox(obj)
            end
        end)
        table.insert(connections.AntiTrap, descendantAddedConn)

        -- Remove hitbox when trap is gone
        local descendantRemovingConn = workspace.DescendantRemoving:Connect(function(obj)
            if obj.Name == "Trap" and obj:IsA("Model") then
                local hb = obj:FindFirstChild("TrapHitbox")
                if hb then hb:Destroy() end
            end
        end)
        table.insert(connections.AntiTrap, descendantRemovingConn)

        notify("Anti Trap", "✅ Anti Trap enabled!", false)
    else
        for _, conn in ipairs(connections.AntiTrap) do
            if conn then
                if typeof(conn) == "thread" then
                    task.cancel(conn)
                else
                    conn:Disconnect()
                end
            end
        end
        connections.AntiTrap = {}
        -- Clean up any existing TrapHitbox parts
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "TrapHitbox" and obj:IsA("BasePart") then
                obj:Destroy()
            end
        end
        notify("Anti Trap", "⛔ Anti Trap disabled", true)
    end
end

local function noCooldownBatFunction(enabled)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    if enabled then
        local success, Debounce = pcall(function()
            return require(Packages.Debounce)
        end)
        if success and Debounce then
            debug.setmetatable(Debounce, {
                __call = function(self, arg1, arg2)
                    return false
                end
            })
        end
        local function playAnimation(tool)
            local character = LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if not animator then
                animator = Instance.new("Animator")
                animator.Parent = humanoid
            end
            local animation = tool:FindFirstChildWhichIsA("Animation") or tool:FindFirstChild("Animation") or nil
            if animation then
                local animationTrack = animator:LoadAnimation(animation)
                animationTrack.Priority = Enum.AnimationPriority.Action4
                animationTrack:Play()
            end
        end
        local function handleTool(tool)
            if not tool or not tool:IsA("Tool") then return end
            local cooldownConn = tool:GetAttributeChangedSignal("CooldownTime"):Connect(function()
                if tool:GetAttribute("CooldownTime") then
                    tool:SetAttribute("CooldownTime", false)
                end
            end)
            table.insert(connections.NoCooldownBat, cooldownConn)
            tool:SetAttribute("CooldownTime", false)
            local activatedConn = tool.Activated:Connect(function()
                local successNet, Net = pcall(function()
                    return require(Packages.Net)
                end)
                if not successNet then return end
                for _ = 1, 5 do
                    Net:RemoteEvent("UseItem"):FireServer()
                    playAnimation(tool)
                    task.wait(0.1)
                end
            end)
            table.insert(connections.NoCooldownBat, activatedConn)
        end
        local function handleCharacter(character)
            for _, tool in ipairs(character:GetChildren()) do
                handleTool(tool)
            end
            local childAddedConn = character.ChildAdded:Connect(handleTool)
            table.insert(connections.NoCooldownBat, childAddedConn)
        end
        if LocalPlayer.Character then
            handleCharacter(LocalPlayer.Character)
        end
        local charAddedConn = LocalPlayer.CharacterAdded:Connect(handleCharacter)
        table.insert(connections.NoCooldownBat, charAddedConn)
        notify("No Cooldown (Bat)", "✅ Cooldown removal applied successfully!", false)
    else
        for _, conn in ipairs(connections.NoCooldownBat) do
            if conn then
                conn:Disconnect()
            end
        end
        connections.NoCooldownBat = {}
        -- Optionally restore original Debounce behavior (if possible)
        local success, Debounce = pcall(function()
            return require(Packages.Debounce)
        end)
        if success and Debounce then
            debug.setmetatable(Debounce, nil) -- Remove custom metatable
        end
        notify("No Cooldown (Bat)", "⛔ No Cooldown (Bat) disabled", true)
    end
end

local function autoHitNearPlayerFunction(enabled)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    local Backpack = LocalPlayer:WaitForChild("Backpack")

    if enabled then
        local NotificationModule = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("NotificationController"))
        local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
        local BuyFunction = Net:RemoteFunction("CoinsShopService/RequestBuy")

        local ITEM_NAME = "Rainbowrath Sword"
        local MAX_RAGDOLL_TIME = 3

        NotificationModule:Success("✅ Script executed successfully! -- Made by Ajjan.")

        local function hasItem()
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local character = LocalPlayer.Character
            return (backpack and backpack:FindFirstChild(ITEM_NAME)) or (character and character:FindFirstChild(ITEM_NAME))
        end

        local function equipItem()
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local character = LocalPlayer.Character
            if backpack and character then
                local tool = backpack:FindFirstChild(ITEM_NAME)
                if tool then
                    tool.Parent = character
                end
            end
        end

        local function isRagdolled(player)
            local attr = player:GetAttribute("RagdollEndTime")
            if not attr then return false end
            return (attr - workspace:GetServerTimeNow()) > 0
        end

        local function getNearestPlayer()
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

            local myPos = myChar.HumanoidRootPart.Position
            local closest, minDist = nil, math.huge

            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= LocalPlayer and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                    if not isRagdolled(other) then
                        local dist = (myPos - other.Character.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            closest = other
                            minDist = dist
                        end
                    end
                end
            end

            return closest
        end

        local function stickToPlayerOnce(target)
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            local alreadyRagdolled = false
            local start = tick()

            while featureStates.AutoHitNearPlayer and tick() - start < MAX_RAGDOLL_TIME do
                if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then break end
                if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then break end

                myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame

                if isRagdolled(target) and not alreadyRagdolled then
                    alreadyRagdolled = true
                    NotificationModule:Success("✅ " .. target.Name .. " successfully got ragdolled by you")
                    break
                end

                task.wait(0.1)
            end
        end

        local function setupSword(sword)
            local handle = sword:FindFirstChild("Handle")
            if not handle then return end

            local function onSlash()
                local target = getNearestPlayer()
                if target then
                    task.spawn(function()
                        stickToPlayerOnce(target)
                    end)
                end
            end

            if handle:FindFirstChild("Slash") then
                local slashConn = handle.Slash.Played:Connect(onSlash)
                table.insert(connections.AutoHitNearPlayer, slashConn)
            end
            if handle:FindFirstChild("SlashOld") then
                local slashOldConn = handle.SlashOld.Played:Connect(onSlash)
                table.insert(connections.AutoHitNearPlayer, slashOldConn)
            end
        end

        local function tryInit()
            local tool = Backpack:FindFirstChild(ITEM_NAME)
            if tool then
                setupSword(tool)
            end
        end

        local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            equipItem()
            task.wait(0.3)
            local sword = char:FindFirstChild(ITEM_NAME)
            if sword then
                setupSword(sword)
            end
        end)
        table.insert(connections.AutoHitNearPlayer, charAddedConn)

        local childAddedConn = Backpack.ChildAdded:Connect(function(tool)
            if tool.Name == ITEM_NAME then
                setupSword(tool)
            end
        end)
        table.insert(connections.AutoHitNearPlayer, childAddedConn)

        local success, result = pcall(function()
            return BuyFunction:InvokeServer(ITEM_NAME)
        end)

        task.wait(0.3)

        if success and hasItem() then
            equipItem()
            tryInit()

            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(ITEM_NAME)
            if tool then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local slash = handle:FindFirstChild("Slash") or handle:FindFirstChild("SlashOld")
                    if slash and slash:IsA("Sound") then
                        slash:Play()
                    end
                end
            end
        else
            NotificationModule:Error("❌ You don't have enough coins or rebirths to buy " .. ITEM_NAME .. ".")
        end

        notify("Auto Hit Nearest Player", "✅ Auto Hit Nearest Player enabled!", false)
    else
        for _, conn in ipairs(connections.AutoHitNearPlayer) do
            if conn then conn:Disconnect() end
        end
        connections.AutoHitNearPlayer = {}
        local character = LocalPlayer.Character
        if character and character:FindFirstChild(ITEM_NAME) then
            local tool = character:FindFirstChild(ITEM_NAME)
            if tool then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    if handle:FindFirstChild("Slash") then
                        handle.Slash.Played:DisconnectAll()
                    end
                    if handle:FindFirstChild("SlashOld") then
                        handle.SlashOld.Played:DisconnectAll()
                    end
                end
            end
        end
        notify("Auto Hit Nearest Player", "⛔ Auto Hit Nearest Player disabled", true)
    end
end

local function antiBeeFunction(enabled)
    local player = game:GetService("Players").LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")

    if enabled then
        local playerModule = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
        local controls = require(playerModule):GetControls()
        local defaultMoveFunction = controls.moveFunction
        local NotificationModule = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("NotificationController"))
        NotificationModule:Success("✅ Script executed successfully! -- Made by Ajjan.")

        local camera = workspace.CurrentCamera
        local antiBeeConn = RunService.RenderStepped:Connect(function()
            if featureStates.AntiBee then
                if camera and camera.FieldOfView ~= 70 then
                    camera.FieldOfView = 70
                end
                for _, effect in ipairs(Lighting:GetChildren()) do
                    if effect:IsA("ColorCorrectionEffect") and effect.Name == "ColorCorrection" then
                        effect:Destroy()
                    elseif effect:IsA("BlurEffect") and effect.Name == "BeeBlur" then
                        effect:Destroy()
                    end
                end
                if controls and controls.moveFunction then
                    local info = debug.getinfo(controls.moveFunction)
                    if info and info.short_src and string.find(info.short_src, "BeeLauncher") then
                        controls.moveFunction = defaultMoveFunction
                    end
                end
            end
        end)
        table.insert(connections.AntiBee, antiBeeConn)
        task.delay(1, function()
            if featureStates.AntiBee then
                NotificationModule:Success("🐝 Anti Bee Launcher Successfully Bypassed.")
            end
        end)

        notify("Anti Bee", "✅ Anti Bee enabled!", false)
    else
        for _, conn in ipairs(connections.AntiBee) do
            if conn then conn:Disconnect() end
        end
        connections.AntiBee = {}
        notify("Anti Bee", "⛔ Anti Bee disabled", true)
    end
end

local function controlPlayerFunction(enabled)
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local PhysicsService = game:GetService("PhysicsService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    if enabled then
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart")
        local PlotClient = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("PlotClient"))
        local Observers = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Observers"))
        local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))

        -- SETTINGS
        local CLOSE_DISTANCE = 50
        local COIL_NAME = "Speed Coil"
        local TOOL_NAME = "Web Slinger"
        local COLLISION_GROUP_NAME = "NoCollideGroup"
        local RANGE = 7

        local firedFriend = nil
        local friendUIDs = {}

        -- COLLISION GROUP SETUP
        pcall(function()
            PhysicsService:CreateCollisionGroup(COLLISION_GROUP_NAME)
            PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP_NAME, "Default", false)
        end)

        -- Function to disable collisions
        local function disableCollisions(model)
            local function setNoCollide(part)
                pcall(function()
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        PhysicsService:SetPartCollisionGroup(part, COLLISION_GROUP_NAME)
                    end
                end)
            end

            if model:IsA("BasePart") then
                setNoCollide(model)
            end
            for _, child in ipairs(model:GetDescendants()) do
                setNoCollide(child)
            end
        end

        -- Notification
        local function showNotification(message, duration)
            local notifGui = Instance.new("ScreenGui", PlayerGui)
            notifGui.Name = "AjjanNotification"
            notifGui.ResetOnSpawn = false

            local notifFrame = Instance.new("Frame", notifGui)
            notifFrame.Size = UDim2.new(0, 200, 0, 50)
            notifFrame.Position = UDim2.new(0.5, -100, 0.2, 0)
            notifFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
            notifFrame.BackgroundTransparency = 0.2
            Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)

            local notifText = Instance.new("TextLabel", notifFrame)
            notifText.Size = UDim2.new(1, 0, 1, 0)
            notifText.BackgroundTransparency = 1
            notifText.Text = message
            notifText.Font = Enum.Font.Arcade
            notifText.TextScaled = true
            notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
            notifText.TextTransparency = 1

            TweenService:Create(notifText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
            task.wait(duration)
            TweenService:Create(notifText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            task.delay(0.5, function() notifGui:Destroy() end)
        end

        -- Equip Tool Once
        local function equipToolOnce(name)
            local function hasTool()
                return LocalPlayer.Backpack:FindFirstChild(name) or Character:FindFirstChild(name)
            end
            if not hasTool() then
                pcall(function()
                    Net:RemoteFunction("CoinsShopService/RequestBuy"):InvokeServer(name)
                end)
                task.wait(0.1)
            end
            local tool = LocalPlayer.Backpack:FindFirstChild(name)
            if tool then
                local hum = Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(tool) end
            end
        end
        equipToolOnce(COIL_NAME)
        equipToolOnce(TOOL_NAME)

        -- Nearest Player Finder
        local function getNearestPlayer()
            local closest, closestDist
            local myPos = HRP.Position
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if dist <= CLOSE_DISTANCE and (not closest or dist < closestDist) then
                        closest, closestDist = plr, dist
                    end
                end
            end
            return closest
        end

        -- Shoot Nearest Player Instantly
        local function shootNearestPlayer()
            local target = getNearestPlayer()
            if not target or not target.Character then return showNotification("No nearby player!", 2) end
            local head = target.Character:FindFirstChild("Head")
            if not head then return showNotification("Target missing head!", 2) end
            equipToolOnce(TOOL_NAME)
            Net:RemoteEvent("UseItem"):FireServer(head.Position, head)
        end

        -- GUI
        pcall(function()
            local old = PlayerGui:FindFirstChild("AjjanGui")
            if old then old:Destroy() end
        end)

        local gui = Instance.new("ScreenGui", PlayerGui)
        gui.Name = "AjjanGui"
        gui.ResetOnSpawn = false

        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 200, 0, 150)
        frame.Position = UDim2.new(0, 50, 0, 100)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        frame.Active = true
        frame.Draggable = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, 0, 0, 25)
        title.Position = UDim2.new(0, 0, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "Ajjan's GUI"
        title.Font = Enum.Font.Arcade
        title.TextScaled = true
        title.TextColor3 = Color3.fromRGB(255, 255, 255)

        local function makeBtn(text, y, color, callback)
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(0.9, 0, 0, 40)
            btn.Position = UDim2.new(0.05, 0, 0, y)
            btn.Text = text
            btn.Font = Enum.Font.Arcade
            btn.TextScaled = true
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.BackgroundColor3 = color
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local btnConn = btn.MouseButton1Click:Connect(callback)
            table.insert(connections.ControlPlayer, btnConn)
        end

        -- Buttons
        makeBtn("Control Target", 35, Color3.fromRGB(0, 150, 255), function()
            local origin = LocalPlayer.Character
            if not origin then return showNotification("No character found!", 2) end
            local nearest = getNearestPlayer()
            if not nearest then return showNotification("No nearby player found!", 2) end
            local character = nearest.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                return showNotification("Target missing parts!", 2)
            end
            local sounds = LocalPlayer.PlayerScripts:FindFirstChild("RbxCharacterSounds")
            if sounds then sounds.Disabled = true end
            Net:RemoteEvent("UseItem"):FireServer(character.HumanoidRootPart.Position, character.HumanoidRootPart)
            character.HumanoidRootPart:WaitForChild("WebTargetAttch", 5)
            LocalPlayer.Character = character
            Workspace.CurrentCamera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
            if Workspace:FindFirstChild("WebRope") then Workspace.WebRope.Length = 1000 end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            humanoid.WalkSpeed = 100
            local connection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                humanoid.WalkSpeed = 34
            end)
            table.insert(connections.ControlPlayer, connection)

            -- Start collision-disabling loop
            local collisionTask = task.spawn(function()
                while true do
                    for _, plot in ipairs(Workspace.Plots:GetChildren()) do
                        local laserHitbox = plot:FindFirstChild("LaserHitbox")
                        if laserHitbox then
                            disableCollisions(laserHitbox)
                        end
                    end
                    task.wait(0.2) -- adjust speed (0.2s = 5 scans per sec)
                end
            end)
            table.insert(connections.ControlPlayer, collisionTask)

            -- Cleanup after control duration
            local cleanupTask = task.delay(10, function()
                connection:Disconnect()
                task.cancel(collisionTask) -- Stop the collision-disabling loop
                LocalPlayer.Character = origin
                Workspace.CurrentCamera.CameraSubject = origin:FindFirstChildOfClass("Humanoid")
                if sounds then sounds.Disabled = false end
                showNotification("Returned to original character!", 2)
            end)
            table.insert(connections.ControlPlayer, cleanupTask)
            showNotification("Controlling " .. nearest.Name .. "!", 2)
        end)

        makeBtn("Shoot Nearest Player", 85, Color3.fromRGB(0, 200, 100), shootNearestPlayer)

        -- Anti-stun
        local antiStunConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.Sit = false
            end
            if hrp then
                hrp.Anchored = false
            end
        end)
        table.insert(connections.ControlPlayer, antiStunConn)

        local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            Character = newChar
            HRP = newChar:WaitForChild("HumanoidRootPart")
            task.wait(0.2)
            equipToolOnce(TOOL_NAME)
        end)
        table.insert(connections.ControlPlayer, charAddedConn)

        notify("Control Player", "✅ Control Player GUI activated!", false)
    else
        -- Cleanup when disabled
        pcall(function()
            local PlayerGui = LocalPlayer.PlayerGui
            local oldGui = PlayerGui:FindFirstChild("AjjanGui")
            if oldGui then oldGui:Destroy() end
        end)
        for _, conn in ipairs(connections.ControlPlayer) do
            if conn then
                if typeof(conn) == "thread" then
                    task.cancel(conn)
                else
                    conn:Disconnect()
                end
            end
        end
        connections.ControlPlayer = {}
        notify("Control Player", "⛔ Control Player GUI deactivated!", true)
    end
end

local function fpsBoosterFunction(enabled)
    local Lighting = game:GetService("Lighting")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")

    if enabled then
        -- Remove glow effects
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
                effect:Destroy()
            end
        end

        -- FPS Killer Classes
        local badClasses = {
            ["Highlight"] = true,
            ["SurfaceAppearance"] = true,
            ["Decal"] = true,
            ["Texture"] = true,
            ["ParticleEmitter"] = true,
            ["Trail"] = true,
            ["Fire"] = true,
            ["Smoke"] = true,
            ["Sparkles"] = true
        }

        -- Optimizer Function
        local function optimize(obj)
            local plr = Players:GetPlayerFromCharacter(obj.Parent)

            if not plr then -- Ignore player characters
                if badClasses[obj.ClassName] then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                end
            else
                -- For tools in Backpack or equipped
                if obj:IsA("Tool") or obj:IsA("Accessory") then
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.SmoothPlastic
                        elseif badClasses[part.ClassName] then
                            part:Destroy()
                        end
                    end
                end
            end
        end

        -- Apply to existing objects
        for _, obj in ipairs(game:GetDescendants()) do
            optimize(obj)
        end

        -- Apply to new objects
        local descendantAddedConn = game.DescendantAdded:Connect(optimize)
        table.insert(connections.FPSBooster, descendantAddedConn)

        -- Stop Brainrot animal animations
        local animFolder = ReplicatedStorage:FindFirstChild("Animations")
        if animFolder and animFolder:FindFirstChild("Animals") then
            for _, anim in ipairs(animFolder.Animals:GetDescendants()) do
                if anim:IsA("Animation") then
                    anim:Destroy()
                end
            end

            local animAddedConn = animFolder.Animals.DescendantAdded:Connect(function(obj)
                if obj:IsA("Animation") then
                    obj:Destroy()
                end
            end)
            table.insert(connections.FPSBooster, animAddedConn)
        end

        notify("FPS Booster", "✅ FPS optimization enabled", false)
    else
        -- Disable feature and clean up connections
        for _, conn in ipairs(connections.FPSBooster) do
            if conn then
                conn:Disconnect()
            end
        end
        connections.FPSBooster = {}
        notify("FPS Booster", "⛔ FPS optimization disabled", true)
    end
end

local function destroyTurretFunction(enabled)
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")

    if enabled then
        -- Settings
        local SENTRY_SIZE = Vector3.new(60, 60, 60)
        local SENTRY_SOLID = false

        -- Resize and make sentry non-solid
        local function resizeSentry(sentry)
            if sentry and sentry:IsA("BasePart") then
                sentry.Size = SENTRY_SIZE
                sentry.CanCollide = SENTRY_SOLID
                sentry.Anchored = true
            end
        end

        -- Loop for sentries
        local sentryConn = RunService.Heartbeat:Connect(function()
            if not featureStates.DestroyTurret then return end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:match("^Sentry") and obj:IsA("BasePart") then
                    resizeSentry(obj)
                end
            end
        end)
        table.insert(connections.DestroyTurret, sentryConn)

        notify("Destroy Turret", "✅ Destroy Turret enabled!", false)
    else
        -- Cleanup connections
        for _, conn in ipairs(connections.DestroyTurret) do
            if conn then conn:Disconnect() end
        end
        connections.DestroyTurret = {}
        -- Reset sentry properties (optional, if you want to revert changes)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:match("^Sentry") and obj:IsA("BasePart") then
                obj.Size = Vector3.new(5, 5, 5) -- Adjust to game's default sentry size
                obj.CanCollide = true
                obj.Anchored = false
            end
        end
        notify("Destroy Turret", "⛔ Destroy Turret disabled", true)
    end
end

local function fpsDevourerFunction(enabled)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer

    if enabled then
        local NotificationModule = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("NotificationController"))
        local TOOL_NAME = "Bat"
        local running = true

        -- Remove all accessories/clothes
        local function removeAllAccessoriesFromCharacter()
            local character = player.Character
            if not character then return end
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Accessory")
                or item:IsA("LayeredClothing")
                or item:IsA("Shirt")
                or item:IsA("ShirtGraphic")
                or item:IsA("Pants")
                or item:IsA("BodyColors")
                or item:IsA("CharacterMesh") then
                    pcall(function() item:Destroy() end)
                end
            end
        end

        -- Equip Tung Bat
        local function equipTungBat()
            local character = player.Character
            local backpack = player:FindFirstChild("Backpack")
            if not character or not backpack then return false end
            local tool = backpack:FindFirstChild(TOOL_NAME)
            if tool then
                tool.Parent = character
                return true
            end
            return false
        end

        -- Unequip Tung Bat
        local function unequipTungBat()
            local character = player.Character
            local backpack = player:FindFirstChild("Backpack")
            if not character or not backpack then return false end
            local tool = character:FindFirstChild(TOOL_NAME)
            if tool then
                tool.Parent = backpack
                return true
            end
            return false
        end

        -- Initial setup
        if player.Character then
            removeAllAccessoriesFromCharacter()
        end

        -- Handle character respawn
        local charConn = player.CharacterAdded:Connect(function()
            if featureStates.FpsDevourer then
                task.wait(0.2)
                removeAllAccessoriesFromCharacter()
            else
                running = false
            end
        end)
        table.insert(connections.FpsDevourer, charConn)

        -- Loop spam Tung Bat
        local spamConn = task.spawn(function()
            while featureStates.FpsDevourer and running do
                equipTungBat()
                task.wait(0.035)
                unequipTungBat()
                task.wait(0.035) -- total = 0.07s
            end
        end)
        table.insert(connections.FpsDevourer, spamConn)

        notify("Fps Devourer", "✅ Fps devoure enable but required accessories to work", false)
    else
        -- Disable feature
        for _, conn in ipairs(connections.FpsDevourer) do
            if typeof(conn) == "thread" then
                task.cancel(conn)
            elseif conn then
                conn:Disconnect()
            end
        end
        connections.FpsDevourer = {}

        -- Unequip Tung Bat on disable
        if player.Character then
            local tool = player.Character:FindFirstChild(TOOL_NAME)
            if tool then
                tool.Parent = player:FindFirstChild("Backpack")
            end
        end

        notify("Fps Devourer", "⛔ Fps devoure disabled", true)
    end
end

local function targetBaseOwnerFunction(enabled)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local UseItemRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/UseItem")
    local NotificationModule = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("NotificationController"))

    if enabled then
        local clonerName = "Laser Cape"

        -- Buy Laser Cape if needed
        local function buyLaserCape()
            if backpack:FindFirstChild(clonerName) then return true end
            pcall(function()
                ReplicatedStorage.Packages.Net["RF/CoinsShopService/RequestBuy"]:InvokeServer(clonerName)
            end)
            for _ = 1, 30 do
                if backpack:FindFirstChild(clonerName) then return true end
                task.wait(0.1)
            end
            return false
        end

        -- Equip and keep Laser Cape active
        local function keepCapeEquipped()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local tool = backpack:FindFirstChild(clonerName)
            if not tool then if not buyLaserCape() then return end end
            if tool and not char:FindFirstChild(clonerName) then hum:EquipTool(tool) end
            local equipped = char:FindFirstChild(clonerName)
            if equipped then
                local evt = equipped:FindFirstChild("Activate")
                if evt and (evt:IsA("BindableEvent") or evt:IsA("RemoteEvent")) then
                    evt:Fire()
                end
            end
        end

        -- Get nearest plot owner
        local function getNearestPlotOwner()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local closestPlr, closestDist = nil, math.huge

            for _, plot in ipairs(workspace.Plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign and sign:IsA("BasePart") then
                    local gui = sign:FindFirstChild("SurfaceGui")
                    if gui and gui:FindFirstChild("Frame") and gui.Frame:FindFirstChild("TextLabel") then
                        local text = gui.Frame.TextLabel.Text -- e.g. "oggysr87's Base"
                        local username = string.gsub(text, "'s Base", "")

                        -- Check against Players list
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= player and (string.lower(plr.Name) == string.lower(username) 
                            or string.lower(plr.DisplayName) == string.lower(username)) then
                                local dist = (hrp.Position - sign.Position).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closestPlr = plr
                                end
                            end
                        end
                    end
                end
            end
            return closestPlr
        end

        -- Enable function
        local function enableSteal()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 51 end

            keepCapeEquipped()
            local keepConn = RunService.Heartbeat:Connect(keepCapeEquipped)
            table.insert(connections.TargetOwner, keepConn)

            -- Fire Laser Cape to nearest plot owner
            local stealConn = task.spawn(function()
                while featureStates.TargetOwner do
                    task.wait(0.1)
                    local target = getNearestPlotOwner()
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = target.Character.HumanoidRootPart
                        local pos = Vector3.new(targetHRP.Position.X, -10, targetHRP.Position.Z)
                        UseItemRemote:FireServer(pos, targetHRP)
                    end
                end
            end)
            table.insert(connections.TargetOwner, stealConn)

            notify("Target Owner", "✅ Target Owner enabled", false)
        end

        -- Disable function
        local function disableSteal()
            for _, conn in ipairs(connections.TargetOwner) do
                if typeof(conn) == "thread" then
                    task.cancel(conn)
                elseif conn then
                    conn:Disconnect()
                end
            end
            connections.TargetOwner = {}

            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end

            notify("Target Owner", "⛔ Target Owner disabled", true)
        end

        -- Initial setup
        if player.Character then
            enableSteal()
        end

        -- Handle character respawn
        local charConn = player.CharacterAdded:Connect(function()
            if featureStates.TargetOwner then
                enableSteal()
            end
        end)
        table.insert(connections.TargetOwner, charConn)
    else
        -- Disable feature
        for _, conn in ipairs(connections.TargetOwner) do
            if typeof(conn) == "thread" then
                task.cancel(conn)
            elseif conn then
                conn:Disconnect()
            end
        end
        connections.TargetOwner = {}

        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end

        notify("Target Owner", "⛔ Target Owner disabled", true)
    end
end

local function semiInvisibleFunction(enabled)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer

    if enabled then
        local Invisible = false
        local clone, oldRoot, hip, animTrack, connection, characterConnection
        local DEPTH_OFFSET = 0.09

        -- Remove folders (DoubleRig and Constraints) from player's folder
        local function removeFolders()
            local playerName = LocalPlayer.Name
            local playerFolder = Workspace:FindFirstChild(playerName)
            if not playerFolder then
                print("Player folder not found")
                return
            end

            local doubleRig = playerFolder:FindFirstChild("DoubleRig")
            if doubleRig then
                doubleRig:Destroy()
                print("Deleted DoubleRig for [" .. playerName .. "]")
            else
                print("DoubleRig not found for [" .. playerName .. "]")
            end

            local constraints = playerFolder:FindFirstChild("Constraints")
            if constraints then
                constraints:Destroy()
                print("Deleted Constraints for [" .. playerName .. "]")
            else
                print("Constraints not found for [" .. playerName .. "]")
            end

            local childAddedConn = playerFolder.ChildAdded:Connect(function(child)
                if child.Name == "DoubleRig" or child.Name == "Constraints" then
                    child:Destroy()
                    print("Destroyed " .. child.Name .. " for [" .. playerName .. "]")
                end
            end)
            table.insert(connections.SemiInvisible, childAddedConn)
        end

        -- Clone HumanoidRootPart for invisibility
        local function doClone()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
                hip = LocalPlayer.Character.Humanoid.HipHeight
                oldRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not oldRoot or not oldRoot.Parent then
                    return false
                end

                local tempParent = Instance.new("Model")
                tempParent.Parent = game
                LocalPlayer.Character.Parent = tempParent

                clone = oldRoot:Clone()
                clone.Parent = LocalPlayer.Character
                oldRoot.Parent = game.Workspace.CurrentCamera
                clone.CFrame = oldRoot.CFrame

                LocalPlayer.Character.PrimaryPart = clone
                LocalPlayer.Character.Parent = game.Workspace

                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("Weld") or v:IsA("Motor6D") then
                        if v.Part0 == oldRoot then
                            v.Part0 = clone
                        end
                        if v.Part1 == oldRoot then
                            v.Part1 = clone
                        end
                    end
                end

                tempParent:Destroy()
                return true
            end
            return false
        end

        -- Revert cloning to restore original state
        local function revertClone()
            if not oldRoot or not oldRoot:IsDescendantOf(game.Workspace) or not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then
                return false
            end

            local tempParent = Instance.new("Model")
            tempParent.Parent = game
            LocalPlayer.Character.Parent = tempParent

            oldRoot.Parent = LocalPlayer.Character
            LocalPlayer.Character.PrimaryPart = oldRoot
            LocalPlayer.Character.Parent = game.Workspace
            oldRoot.CanCollide = true

            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("Weld") or v:IsA("Motor6D") then
                    if v.Part0 == clone then
                        v.Part0 = oldRoot
                    end
                    if v.Part1 == clone then
                        v.Part1 = oldRoot
                    end
                end
            end

            if clone then
                local oldPos = clone.CFrame
                clone:Destroy()
                clone = nil
                oldRoot.CFrame = oldPos
            end

            oldRoot = nil
            if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
                LocalPlayer.Character.Humanoid.HipHeight = hip
            end
        end

        -- Play animation for invisibility effect
        local function animationTrickery()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
                local anim = Instance.new("Animation")
                anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
                local humanoid = LocalPlayer.Character.Humanoid
                local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
                animTrack = animator:LoadAnimation(anim)
                animTrack.Priority = Enum.AnimationPriority.Action4
                animTrack:Play(0, 1, 0)
                anim:Destroy()

                local animStoppedConn = animTrack.Stopped:Connect(function()
                    if Invisible then
                        animationTrickery()
                    end
                end)
                table.insert(connections.SemiInvisible, animStoppedConn)

                task.delay(0, function()
                    animTrack.TimePosition = 0.7
                    task.delay(1, function()
                        animTrack:AdjustSpeed(math.huge)
                    end)
                end)
            end
        end

        -- Toggle invisibility
        local function toggleInvisible()
            if not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then
                return
            end

            Invisible = not Invisible
            if Invisible then
                removeFolders()
                local success = doClone()
                if success then
                    task.wait(0.1)
                    animationTrickery()
                    connection = RunService.PreSimulation:Connect(function(dt)
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 and oldRoot then
                            local root = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local cf = root.CFrame - Vector3.new(0, LocalPlayer.Character.Humanoid.HipHeight + (root.Size.Y / 2) - 1 + DEPTH_OFFSET, 0)
                                oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)
                                oldRoot.Velocity = root.Velocity
                                oldRoot.CanCollide = false
                            end
                        end
                    end)
                    table.insert(connections.SemiInvisible, connection)

                    characterConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                        task.wait(1)
                        local newHumanoid = newChar:WaitForChild("Humanoid", 1)
                        if newHumanoid and Invisible then
                            oldRoot = nil
                            if animTrack then
                                animTrack:Stop()
                                animTrack:Destroy()
                                animTrack = nil
                            end
                            if connection then connection:Disconnect() end
                            revertClone()
                            removeFolders()
                            toggleInvisible()
                        end
                    end)
                    table.insert(connections.SemiInvisible, characterConnection)

                    print("Invisibility enabled with depth offset: " .. DEPTH_OFFSET)
                else
                    Invisible = false
                    print("Failed to enable invisibility")
                end
            else
                if animTrack then
                    animTrack:Stop()
                    animTrack:Destroy()
                    animTrack = nil
                end
                if connection then connection:Disconnect() end
                if characterConnection then characterConnection:Disconnect() end
                revertClone()
                removeFolders()
                print("Invisibility disabled")
            end
        end

        -- GUI for toggling invisibility
        local function setupGui()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "InvisibleGui"
            screenGui.Parent = playerGui

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 200, 0, 50)
            frame.Position = UDim2.new(0, 10, 0, 10)
            frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            frame.BorderSizePixel = 0
            frame.Parent = screenGui

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 1, 0)
            button.Position = UDim2.new(0, 0, 0, 0)
            button.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
            button.Text = "Invisible"
            button.TextColor3 = Color3.new(1, 1, 1)
            button.TextScaled = true
            button.Font = Enum.Font.SourceSansBold
            button.Parent = frame

            local buttonConn = button.MouseButton1Click:Connect(toggleInvisible)
            table.insert(connections.SemiInvisible, buttonConn)
        end

        -- Godmode metamethod hook
        local function setupGodmode()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local mt = getrawmetatable(game)
            local oldNC = mt.__namecall
            local oldNI = mt.__newindex

            setreadonly(mt, false)

            mt.__namecall = newcclosure(function(self, ...)
                local m = getnamecallmethod()
                if self == hum then
                    if m == "ChangeState" and select(1, ...) == Enum.HumanoidStateType.Dead then
                        return
                    end
                    if m == "SetStateEnabled" then
                        local st, en = ...
                        if st == Enum.HumanoidStateType.Dead and en == true then
                            return
                        end
                    end
                    if m == "Destroy" then
                        return
                    end
                end

                if self == char and m == "BreakJoints" then
                    return
                end

                return oldNC(self, ...)
            end)

            mt.__newindex = newcclosure(function(self, k, v)
                if self == hum then
                    if k == "Health" and type(v) == "number" and v <= 0 then
                        return
                    end
                    if k == "MaxHealth" and type(v) == "number" and v < hum.MaxHealth then
                        return
                    end
                    if k == "BreakJointsOnDeath" and v == true then
                        return
                    end
                    if k == "Parent" and v == nil then
                        return
                    end
                end

                return oldNI(self, k, v)
            end)

            setreadonly(mt, true)
        end

        -- Initialize
        removeFolders()
        setupGui()
        setupGodmode()
        print("Invisibility and godmode initialized")

        notify("Perm Invisible", "Perm Invisible activated!", false)
    else
        pcall(function()
            local oldGui = LocalPlayer.PlayerGui:FindFirstChild("InvisibleGui")
            if oldGui then oldGui:Destroy() end
        end)
        for _, conn in ipairs(connections.SemiInvisible) do
            if conn then conn:Disconnect() end
        end
        connections.SemiInvisible = {}
        notify("Perm Invisible", "Perm Invisible deactivated!", true)
    end
end

-- Baselock ESP Functionality
local function baselockESPFunction(enabled)
    if enabled then
        local conn = RunService.RenderStepped:Connect(function()
            if not featureStates.BaselockESP then
                conn:Disconnect()
                return
            end
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in pairs(plots:GetChildren()) do
                    local timeLabel = plot:FindFirstChild("Purchases", true) and 
                        plot.Purchases:FindFirstChild("PlotBlock", true) and
                        plot.Purchases.PlotBlock.Main:FindFirstChild("BillboardGui", true) and
                        plot.Purchases.PlotBlock.Main.BillboardGui:FindFirstChild("RemainingTime", true)
                    if timeLabel and timeLabel:IsA("TextLabel") then
                        local espName = "LockTimeESP_" .. plot.Name
                        local existingBillboard = plot:FindFirstChild(espName)
                        local isUnlocked = timeLabel.Text == "0s"
                        local displayText = isUnlocked and "Unlocked" or ("Lock: " .. timeLabel.Text)
                        local textColor = isUnlocked and Color3.fromRGB(220, 20, 60) or Color3.fromRGB(255, 255, 0)
                        if not existingBillboard then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = espName
                            billboard.Size = UDim2.new(0, 200, 0, 30)
                            billboard.StudsOffset = Vector3.new(0, 5, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Adornee = plot.Purchases.PlotBlock.Main
                            local label = Instance.new("TextLabel")
                            label.Text = displayText
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextScaled = true
                            label.TextColor3 = textColor
                            label.TextStrokeColor3 = Color3.new(0, 0, 0)
                            label.TextStrokeTransparency = 0
                            label.Font = Enum.Font.SourceSansBold
                            label.Parent = billboard
                            billboard.Parent = plot
                            lteInstances[plot.Name] = billboard
                        else
                            local label = existingBillboard:FindFirstChildOfClass("TextLabel")
                            if label then
                                label.Text = displayText
                                label.TextColor3 = textColor
                            end
                        end
                    end
                end
            end
        end)
        table.insert(connections.BaselockESP, conn)
        notify("Baselock ESP", "✅ Baselock ESP enabled!", false)
    else
        for _, instance in pairs(lteInstances) do
            if instance then instance:Destroy() end
        end
        lteInstances = {}
        for _, conn in ipairs(connections.BaselockESP) do
            if conn then conn:Disconnect() end
        end
        connections.BaselockESP = {}
        notify("Baselock ESP", "⛔ Baselock ESP disabled", true)
    end
end

-- Config System
local configFileName = "AjjansConfig.json"

local function saveConfig()
    local config = {}
    for feature, state in pairs(featureStates) do
        config[feature] = state
    end
    writefile(configFileName, HttpService:JSONEncode(config))
    print("Config saved to " .. configFileName)
end

local function loadConfig()
    if isfile(configFileName) then
        local success, config = pcall(function()
            return HttpService:JSONDecode(readfile(configFileName))
        end)
        if success then
            for feature, state in pairs(config) do
                if featureStates[feature] ~= nil then
                    featureStates[feature] = state
                    if toggleButtons[feature] and toggleLabels[feature] then
                        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                        local tween = TweenService:Create(toggleButtons[feature], tweenInfo, {
                            Position = UDim2.new(state and 0.5 or 0, 5, 0, 2.5),
                            BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                        })
                        tween:Play()
                        if feature == "InfiniteJump" then
                            infiniteJumpFunction(state)
                        elseif feature == "LockBaseReminder" then
                            lockBaseReminderFunction(state)
                        elseif feature == "GodMode" then
                            godModeFunction(state)
                        elseif feature == "FreezePlayer" then
                            freezePlayerFunction(state)
                        elseif feature == "BaselockESP" then
                            baselockESPFunction(state)
                            elseif feature == "SpeedBoost" then
                               speedBoostFunction(state)
                               elseif feature == "FloatV1" then
                                  floatV1Function(state)
                                  elseif feature == "FloatV2" then
                                  floatV2Function(state)
                                  elseif feature == "AntiTrap" then
                                  antiTrapFunction(state)
                                  elseif feature == "NoCooldownBat" then
                                  noCooldownBatFunction(state)
                                  elseif feature == "AutoHitNearPlayer" then
                                  autoHitNearPlayerFunction(state)
                                  elseif feature == "AntiBee" then
                                  antiBeeFunction(state)
                                  elseif feature == "ControlPlayer" then
                                  controlPlayerFunction(state)
                                  elseif feature == "FPSBooster" then
                                  fpsBoosterFunction(state)
                                  elseif feature == "DestroyTurret" then
                                  destroyTurretFunction(state)
                                  elseif feature == "FpsDevourer" then
                                  fpsDevourerFunction(state)
                                  elseif feature == "TargetOwner" then
                                  targetBaseOwnerFunction(state)
                                  elseif feature == "SemiInvisible" then
                                  semiInvisibleFunction(state)
                        end
                    end
                end
            end
            print("Config loaded from " .. configFileName)
        else
            print("Failed to load config: Invalid JSON")
        end
    else
        print("No config file found: " .. configFileName)
    end
end

-- Create Tab Button
local function createTabButton(name, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.25, 0, 1, 0)
    button.Position = UDim2.new(0.25 * (position - 1), 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = TabContainer
    return button
end

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 90)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- Create Tabs and Content
for i, tabName in ipairs(tabs) do
    -- Tab Button
    local button = createTabButton(tabName, i)
    tabButtons[tabName] = button

    -- Tab Frame
    local tabFrame
    if tabName ~= "Settings" then
        tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.ScrollBarThickness = 5
        tabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, 100)
        tabFrame.Visible = (i == 1)
        tabFrame.Parent = ContentFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 10)
        listLayout.Parent = tabFrame
    else
        tabFrame = Instance.new("Frame")
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tabFrame.Parent = ContentFrame
    end
    tabFrames[tabName] = tabFrame

    -- Add Toggles for Main Tab
    if tabName == "Main" then
        -- Infinite Jump Toggle
        local boxFrame1 = Instance.new("Frame")
        boxFrame1.Size = UDim2.new(1, -10, 0, 50)
        boxFrame1.Position = UDim2.new(0, 5, 0, 5)
        boxFrame1.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        boxFrame1.BorderSizePixel = 1
        boxFrame1.BorderColor3 = Color3.fromRGB(60, 60, 60)
        boxFrame1.Parent = tabFrame
        boxFrame1.LayoutOrder = 1

        local boxCorner1 = Instance.new("UICorner")
        boxCorner1.CornerRadius = UDim.new(0, 8)
        boxCorner1.Parent = boxFrame1

        local toggleContainer1 = Instance.new("Frame")
        toggleContainer1.Size = UDim2.new(1, -20, 0, 40)
        toggleContainer1.Position = UDim2.new(0, 10, 0, 5)
        toggleContainer1.BackgroundTransparency = 1
        toggleContainer1.Parent = boxFrame1

        local toggleLabel1 = Instance.new("TextLabel")
        toggleLabel1.Size = UDim2.new(0, 150, 1, 0)
        toggleLabel1.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel1.BackgroundTransparency = 1
        toggleLabel1.Text = "Infinite Jump"
        toggleLabel1.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel1.TextSize = 20
        toggleLabel1.Font = Enum.Font.Gotham
        toggleLabel1.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel1.Parent = toggleContainer1
        toggleLabels.InfiniteJump = toggleLabel1

        local toggleFrame1 = Instance.new("Frame")
        toggleFrame1.Size = UDim2.new(0, 60, 0, 30)
        toggleFrame1.Position = UDim2.new(1, -70, 0, 5)
        toggleFrame1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleFrame1.Parent = toggleContainer1

        local toggleCorner1 = Instance.new("UICorner")
        toggleCorner1.CornerRadius = UDim.new(0, 15)
        toggleCorner1.Parent = toggleFrame1

        local toggleButton1 = Instance.new("TextButton")
        toggleButton1.Size = UDim2.new(0.5, -5, 1, -5)
        toggleButton1.Position = UDim2.new(featureStates.InfiniteJump and 0.5 or 0, 5, 0, 2.5)
        toggleButton1.BackgroundColor3 = featureStates.InfiniteJump and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggleButton1.Text = ""
        toggleButton1.Parent = toggleFrame1
        toggleButtons.InfiniteJump = toggleButton1

        local toggleButtonCorner1 = Instance.new("UICorner")
        toggleButtonCorner1.CornerRadius = UDim.new(0, 15)
        toggleButtonCorner1.Parent = toggleButton1

        toggleButton1.MouseButton1Click:Connect(function()
            featureStates.InfiniteJump = not featureStates.InfiniteJump
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(toggleButton1, tweenInfo, {
                Position = UDim2.new(featureStates.InfiniteJump and 0.5 or 0, 5, 0, 2.5),
                BackgroundColor3 = featureStates.InfiniteJump and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
            tween:Play()
            infiniteJumpFunction(featureStates.InfiniteJump)
        end)

        -- Lock Base Reminder Toggle
        local boxFrame2 = Instance.new("Frame")
        boxFrame2.Size = UDim2.new(1, -10, 0, 50)
        boxFrame2.Position = UDim2.new(0, 5, 0, 5)
        boxFrame2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        boxFrame2.BorderSizePixel = 1
        boxFrame2.BorderColor3 = Color3.fromRGB(60, 60, 60)
        boxFrame2.Parent = tabFrame
        boxFrame2.LayoutOrder = 2

        local boxCorner2 = Instance.new("UICorner")
        boxCorner2.CornerRadius = UDim.new(0, 8)
        boxCorner2.Parent = boxFrame2

        local toggleContainer2 = Instance.new("Frame")
        toggleContainer2.Size = UDim2.new(1, -20, 0, 40)
        toggleContainer2.Position = UDim2.new(0, 10, 0, 5)
        toggleContainer2.BackgroundTransparency = 1
        toggleContainer2.Parent = boxFrame2

        local toggleLabel2 = Instance.new("TextLabel")
        toggleLabel2.Size = UDim2.new(0, 150, 1, 0)
        toggleLabel2.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel2.BackgroundTransparency = 1
        toggleLabel2.Text = "Lock Base Reminder"
        toggleLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel2.TextSize = 16
        toggleLabel2.Font = Enum.Font.Gotham
        toggleLabel2.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel2.Parent = toggleContainer2
        toggleLabels.LockBaseReminder = toggleLabel2

        local toggleFrame2 = Instance.new("Frame")
        toggleFrame2.Size = UDim2.new(0, 60, 0, 30)
        toggleFrame2.Position = UDim2.new(1, -70, 0, 5)
        toggleFrame2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleFrame2.Parent = toggleContainer2

        local toggleCorner2 = Instance.new("UICorner")
        toggleCorner2.CornerRadius = UDim.new(0, 15)
        toggleCorner2.Parent = toggleFrame2

        local toggleButton2 = Instance.new("TextButton")
        toggleButton2.Size = UDim2.new(0.5, -5, 1, -5)
        toggleButton2.Position = UDim2.new(featureStates.LockBaseReminder and 0.5 or 0, 5, 0, 2.5)
        toggleButton2.BackgroundColor3 = featureStates.LockBaseReminder and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggleButton2.Text = ""
        toggleButton2.Parent = toggleFrame2
        toggleButtons.LockBaseReminder = toggleButton2

        local toggleButtonCorner2 = Instance.new("UICorner")
        toggleButtonCorner2.CornerRadius = UDim.new(0, 15)
        toggleButtonCorner2.Parent = toggleButton2

        toggleButton2.MouseButton1Click:Connect(function()
            featureStates.LockBaseReminder = not featureStates.LockBaseReminder
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(toggleButton2, tweenInfo, {
                Position = UDim2.new(featureStates.LockBaseReminder and 0.5 or 0, 5, 0, 2.5),
                BackgroundColor3 = featureStates.LockBaseReminder and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
            tween:Play()
            lockBaseReminderFunction(featureStates.LockBaseReminder)
        end)

        -- God Mode Toggle
        local boxFrame3 = Instance.new("Frame")
        boxFrame3.Size = UDim2.new(1, -10, 0, 50)
        boxFrame3.Position = UDim2.new(0, 5, 0, 5)
        boxFrame3.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        boxFrame3.BorderSizePixel = 1
        boxFrame3.BorderColor3 = Color3.fromRGB(60, 60, 60)
        boxFrame3.Parent = tabFrame
        boxFrame3.LayoutOrder = 3

        local boxCorner3 = Instance.new("UICorner")
        boxCorner3.CornerRadius = UDim.new(0, 8)
        boxCorner3.Parent = boxFrame3

        local toggleContainer3 = Instance.new("Frame")
        toggleContainer3.Size = UDim2.new(1, -20, 0, 40)
        toggleContainer3.Position = UDim2.new(0, 10, 0, 5)
        toggleContainer3.BackgroundTransparency = 1
        toggleContainer3.Parent = boxFrame3

        local toggleLabel3 = Instance.new("TextLabel")
        toggleLabel3.Size = UDim2.new(0, 150, 1, 0)
        toggleLabel3.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel3.BackgroundTransparency = 1
        toggleLabel3.Text = "God Mode"
        toggleLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel3.TextSize = 16
        toggleLabel3.Font = Enum.Font.Gotham
        toggleLabel3.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel3.Parent = toggleContainer3
        toggleLabels.GodMode = toggleLabel3

        local toggleFrame3 = Instance.new("Frame")
        toggleFrame3.Size = UDim2.new(0, 60, 0, 30)
        toggleFrame3.Position = UDim2.new(1, -70, 0, 5)
        toggleFrame3.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleFrame3.Parent = toggleContainer3

        local toggleCorner3 = Instance.new("UICorner")
        toggleCorner3.CornerRadius = UDim.new(0, 15)
        toggleCorner3.Parent = toggleFrame3

        local toggleButton3 = Instance.new("TextButton")
        toggleButton3.Size = UDim2.new(0.5, -5, 1, -5)
        toggleButton3.Position = UDim2.new(featureStates.GodMode and 0.5 or 0, 5, 0, 2.5)
        toggleButton3.BackgroundColor3 = featureStates.GodMode and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggleButton3.Text = ""
        toggleButton3.Parent = toggleFrame3
        toggleButtons.GodMode = toggleButton3

        local toggleButtonCorner3 = Instance.new("UICorner")
        toggleButtonCorner3.CornerRadius = UDim.new(0, 15)
        toggleButtonCorner3.Parent = toggleButton3

        toggleButton3.MouseButton1Click:Connect(function()
            featureStates.GodMode = not featureStates.GodMode
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(toggleButton3, tweenInfo, {
                Position = UDim2.new(featureStates.GodMode and 0.5 or 0, 5, 0, 2.5),
                BackgroundColor3 = featureStates.GodMode and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
            tween:Play()
            godModeFunction(featureStates.GodMode)
        end)
        
        -- Speed Boost Toggle
local boxFrame5 = Instance.new("Frame")
boxFrame5.Size = UDim2.new(1, -10, 0, 50)
boxFrame5.Position = UDim2.new(0, 5, 0, 5)
boxFrame5.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame5.BorderSizePixel = 1
boxFrame5.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame5.Parent = tabFrame
boxFrame5.LayoutOrder = 5

local boxCorner5 = Instance.new("UICorner")
boxCorner5.CornerRadius = UDim.new(0, 8)
boxCorner5.Parent = boxFrame5

local toggleContainer5 = Instance.new("Frame")
toggleContainer5.Size = UDim2.new(1, -20, 0, 40)
toggleContainer5.Position = UDim2.new(0, 10, 0, 5)
toggleContainer5.BackgroundTransparency = 1
toggleContainer5.Parent = boxFrame5

local toggleLabel5 = Instance.new("TextLabel")
toggleLabel5.Size = UDim2.new(0, 150, 1, 0)
toggleLabel5.Position = UDim2.new(0, 0, 0, 0)
toggleLabel5.BackgroundTransparency = 1
toggleLabel5.Text = "Speed Boost"
toggleLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel5.TextSize = 16
toggleLabel5.Font = Enum.Font.Gotham
toggleLabel5.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel5.Parent = toggleContainer5
toggleLabels.SpeedBoost = toggleLabel5

local toggleFrame5 = Instance.new("Frame")
toggleFrame5.Size = UDim2.new(0, 60, 0, 30)
toggleFrame5.Position = UDim2.new(1, -70, 0, 5)
toggleFrame5.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame5.Parent = toggleContainer5

local toggleCorner5 = Instance.new("UICorner")
toggleCorner5.CornerRadius = UDim.new(0, 15)
toggleCorner5.Parent = toggleFrame5

local toggleButton5 = Instance.new("TextButton")
toggleButton5.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton5.Position = UDim2.new(featureStates.SpeedBoost and 0.5 or 0, 5, 0, 2.5)
toggleButton5.BackgroundColor3 = featureStates.SpeedBoost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton5.Text = ""
toggleButton5.Parent = toggleFrame5
toggleButtons.SpeedBoost = toggleButton5

local toggleButtonCorner5 = Instance.new("UICorner")
toggleButtonCorner5.CornerRadius = UDim.new(0, 15)
toggleButtonCorner5.Parent = toggleButton5

toggleButton5.MouseButton1Click:Connect(function()
    featureStates.SpeedBoost = not featureStates.SpeedBoost
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton5, tweenInfo, {
        Position = UDim2.new(featureStates.SpeedBoost and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.SpeedBoost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    speedBoostFunction(featureStates.SpeedBoost)
end)

-- Float V2 Toggle
local boxFrame7 = Instance.new("Frame")
boxFrame7.Size = UDim2.new(1, -10, 0, 50)
boxFrame7.Position = UDim2.new(0, 5, 0, 5)
boxFrame7.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame7.BorderSizePixel = 1
boxFrame7.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame7.Parent = tabFrame
boxFrame7.LayoutOrder = 7

local boxCorner7 = Instance.new("UICorner")
boxCorner7.CornerRadius = UDim.new(0, 8)
boxCorner7.Parent = boxFrame7

local toggleContainer7 = Instance.new("Frame")
toggleContainer7.Size = UDim2.new(1, -20, 0, 40)
toggleContainer7.Position = UDim2.new(0, 10, 0, 5)
toggleContainer7.BackgroundTransparency = 1
toggleContainer7.Parent = boxFrame7

local toggleLabel7 = Instance.new("TextLabel")
toggleLabel7.Size = UDim2.new(0, 150, 1, 0)
toggleLabel7.Position = UDim2.new(0, 0, 0, 0)
toggleLabel7.BackgroundTransparency = 1
toggleLabel7.Text = "Float V2"
toggleLabel7.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel7.TextSize = 16
toggleLabel7.Font = Enum.Font.Gotham
toggleLabel7.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel7.Parent = toggleContainer7
toggleLabels.FloatV2 = toggleLabel7

local toggleFrame7 = Instance.new("Frame")
toggleFrame7.Size = UDim2.new(0, 60, 0, 30)
toggleFrame7.Position = UDim2.new(1, -70, 0, 5)
toggleFrame7.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame7.Parent = toggleContainer7

local toggleCorner7 = Instance.new("UICorner")
toggleCorner7.CornerRadius = UDim.new(0, 15)
toggleCorner7.Parent = toggleFrame7

local toggleButton7 = Instance.new("TextButton")
toggleButton7.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton7.Position = UDim2.new(featureStates.FloatV2 and 0.5 or 0, 5, 0, 2.5)
toggleButton7.BackgroundColor3 = featureStates.FloatV2 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton7.Text = ""
toggleButton7.Parent = toggleFrame7
toggleButtons.FloatV2 = toggleButton7

local toggleButtonCorner7 = Instance.new("UICorner")
toggleButtonCorner7.CornerRadius = UDim.new(0, 15)
toggleButtonCorner7.Parent = toggleButton7

toggleButton7.MouseButton1Click:Connect(function()
    featureStates.FloatV2 = not featureStates.FloatV2
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton7, tweenInfo, {
        Position = UDim2.new(featureStates.FloatV2 and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.FloatV2 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    floatV2Function(featureStates.FloatV2)
end)

-- Float V1 Toggle
local boxFrame6 = Instance.new("Frame")
boxFrame6.Size = UDim2.new(1, -10, 0, 50)
boxFrame6.Position = UDim2.new(0, 5, 0, 5)
boxFrame6.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame6.BorderSizePixel = 1
boxFrame6.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame6.Parent = tabFrame
boxFrame6.LayoutOrder = 6

local boxCorner6 = Instance.new("UICorner")
boxCorner6.CornerRadius = UDim.new(0, 8)
boxCorner6.Parent = boxFrame6

local toggleContainer6 = Instance.new("Frame")
toggleContainer6.Size = UDim2.new(1, -20, 0, 40)
toggleContainer6.Position = UDim2.new(0, 10, 0, 5)
toggleContainer6.BackgroundTransparency = 1
toggleContainer6.Parent = boxFrame6

local toggleLabel6 = Instance.new("TextLabel")
toggleLabel6.Size = UDim2.new(0, 150, 1, 0)
toggleLabel6.Position = UDim2.new(0, 0, 0, 0)
toggleLabel6.BackgroundTransparency = 1
toggleLabel6.Text = "Float V1"
toggleLabel6.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel6.TextSize = 16
toggleLabel6.Font = Enum.Font.Gotham
toggleLabel6.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel6.Parent = toggleContainer6
toggleLabels.FloatV1 = toggleLabel6

local toggleFrame6 = Instance.new("Frame")
toggleFrame6.Size = UDim2.new(0, 60, 0, 30)
toggleFrame6.Position = UDim2.new(1, -70, 0, 5)
toggleFrame6.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame6.Parent = toggleContainer6

local toggleCorner6 = Instance.new("UICorner")
toggleCorner6.CornerRadius = UDim.new(0, 15)
toggleCorner6.Parent = toggleFrame6

local toggleButton6 = Instance.new("TextButton")
toggleButton6.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton6.Position = UDim2.new(featureStates.FloatV1 and 0.5 or 0, 5, 0, 2.5)
toggleButton6.BackgroundColor3 = featureStates.FloatV1 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton6.Text = ""
toggleButton6.Parent = toggleFrame6
toggleButtons.FloatV1 = toggleButton6

local toggleButtonCorner6 = Instance.new("UICorner")
toggleButtonCorner6.CornerRadius = UDim.new(0, 15)
toggleButtonCorner6.Parent = toggleButton6

toggleButton6.MouseButton1Click:Connect(function()
    featureStates.FloatV1 = not featureStates.FloatV1
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton6, tweenInfo, {
        Position = UDim2.new(featureStates.FloatV1 and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.FloatV1 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    floatV1Function(featureStates.FloatV1)
end)

-- No Cooldown (Bat) Toggle
local boxFrame9 = Instance.new("Frame")
boxFrame9.Size = UDim2.new(1, -10, 0, 50)
boxFrame9.Position = UDim2.new(0, 5, 0, 5)
boxFrame9.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame9.BorderSizePixel = 1
boxFrame9.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame9.Parent = tabFrame
boxFrame9.LayoutOrder = 9

local boxCorner9 = Instance.new("UICorner")
boxCorner9.CornerRadius = UDim.new(0, 8)
boxCorner9.Parent = boxFrame9

local toggleContainer9 = Instance.new("Frame")
toggleContainer9.Size = UDim2.new(1, -20, 0, 40)
toggleContainer9.Position = UDim2.new(0, 10, 0, 5)
toggleContainer9.BackgroundTransparency = 1
toggleContainer9.Parent = boxFrame9

local toggleLabel9 = Instance.new("TextLabel")
toggleLabel9.Size = UDim2.new(0, 150, 1, 0)
toggleLabel9.Position = UDim2.new(0, 0, 0, 0)
toggleLabel9.BackgroundTransparency = 1
toggleLabel9.Text = "No Cooldown (Bat)"
toggleLabel9.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel9.TextSize = 16
toggleLabel9.Font = Enum.Font.Gotham
toggleLabel9.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel9.Parent = toggleContainer9
toggleLabels.NoCooldownBat = toggleLabel9

local toggleFrame9 = Instance.new("Frame")
toggleFrame9.Size = UDim2.new(0, 60, 0, 30)
toggleFrame9.Position = UDim2.new(1, -70, 0, 5)
toggleFrame9.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame9.Parent = toggleContainer9

local toggleCorner9 = Instance.new("UICorner")
toggleCorner9.CornerRadius = UDim.new(0, 15)
toggleCorner9.Parent = toggleFrame9

local toggleButton9 = Instance.new("TextButton")
toggleButton9.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton9.Position = UDim2.new(featureStates.NoCooldownBat and 0.5 or 0, 5, 0, 2.5)
toggleButton9.BackgroundColor3 = featureStates.NoCooldownBat and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton9.Text = ""
toggleButton9.Parent = toggleFrame9
toggleButtons.NoCooldownBat = toggleButton9

local toggleButtonCorner9 = Instance.new("UICorner")
toggleButtonCorner9.CornerRadius = UDim.new(0, 15)
toggleButtonCorner9.Parent = toggleButton9

toggleButton9.MouseButton1Click:Connect(function()
    featureStates.NoCooldownBat = not featureStates.NoCooldownBat
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton9, tweenInfo, {
        Position = UDim2.new(featureStates.NoCooldownBat and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.NoCooldownBat and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    noCooldownBatFunction(featureStates.NoCooldownBat)
end)

-- Auto Hit Nearest Player Toggle
local boxFrame10 = Instance.new("Frame")
boxFrame10.Size = UDim2.new(1, -10, 0, 50)
boxFrame10.Position = UDim2.new(0, 5, 0, 5)
boxFrame10.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame10.BorderSizePixel = 1
boxFrame10.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame10.Parent = tabFrame
boxFrame10.LayoutOrder = 10

local boxCorner10 = Instance.new("UICorner")
boxCorner10.CornerRadius = UDim.new(0, 8)
boxCorner10.Parent = boxFrame10

local toggleContainer10 = Instance.new("Frame")
toggleContainer10.Size = UDim2.new(1, -20, 0, 40)
toggleContainer10.Position = UDim2.new(0, 10, 0, 5)
toggleContainer10.BackgroundTransparency = 1
toggleContainer10.Parent = boxFrame10

local toggleLabel10 = Instance.new("TextLabel")
toggleLabel10.Size = UDim2.new(0, 150, 1, 0)
toggleLabel10.Position = UDim2.new(0, 0, 0, 0)
toggleLabel10.BackgroundTransparency = 1
toggleLabel10.Text = "Auto Hit Nearest Player"
toggleLabel10.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel10.TextSize = 16
toggleLabel10.Font = Enum.Font.Gotham
toggleLabel10.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel10.Parent = toggleContainer10
toggleLabels.AutoHitNearPlayer = toggleLabel10

local toggleFrame10 = Instance.new("Frame")
toggleFrame10.Size = UDim2.new(0, 60, 0, 30)
toggleFrame10.Position = UDim2.new(1, -70, 0, 5)
toggleFrame10.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame10.Parent = toggleContainer10

local toggleCorner10 = Instance.new("UICorner")
toggleCorner10.CornerRadius = UDim.new(0, 15)
toggleCorner10.Parent = toggleFrame10

local toggleButton10 = Instance.new("TextButton")
toggleButton10.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton10.Position = UDim2.new(featureStates.AutoHitNearPlayer and 0.5 or 0, 5, 0, 2.5)
toggleButton10.BackgroundColor3 = featureStates.AutoHitNearPlayer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton10.Text = ""
toggleButton10.Parent = toggleFrame10
toggleButtons.AutoHitNearPlayer = toggleButton10

local toggleButtonCorner10 = Instance.new("UICorner")
toggleButtonCorner10.CornerRadius = UDim.new(0, 15)
toggleButtonCorner10.Parent = toggleButton10

toggleButton10.MouseButton1Click:Connect(function()
    featureStates.AutoHitNearPlayer = not featureStates.AutoHitNearPlayer
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton10, tweenInfo, {
        Position = UDim2.new(featureStates.AutoHitNearPlayer and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.AutoHitNearPlayer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    autoHitNearPlayerFunction(featureStates.AutoHitNearPlayer)
end)

-- Anti Trap Toggle
local boxFrame8 = Instance.new("Frame")
boxFrame8.Size = UDim2.new(1, -10, 0, 50)
boxFrame8.Position = UDim2.new(0, 5, 0, 5)
boxFrame8.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame8.BorderSizePixel = 1
boxFrame8.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame8.Parent = tabFrame
boxFrame8.LayoutOrder = 8

local boxCorner8 = Instance.new("UICorner")
boxCorner8.CornerRadius = UDim.new(0, 8)
boxCorner8.Parent = boxFrame8

local toggleContainer8 = Instance.new("Frame")
toggleContainer8.Size = UDim2.new(1, -20, 0, 40)
toggleContainer8.Position = UDim2.new(0, 10, 0, 5)
toggleContainer8.BackgroundTransparency = 1
toggleContainer8.Parent = boxFrame8

local toggleLabel8 = Instance.new("TextLabel")
toggleLabel8.Size = UDim2.new(0, 150, 1, 0)
toggleLabel8.Position = UDim2.new(0, 0, 0, 0)
toggleLabel8.BackgroundTransparency = 1
toggleLabel8.Text = "Anti Trap"
toggleLabel8.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel8.TextSize = 16
toggleLabel8.Font = Enum.Font.Gotham
toggleLabel8.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel8.Parent = toggleContainer8
toggleLabels.AntiTrap = toggleLabel8

local toggleFrame8 = Instance.new("Frame")
toggleFrame8.Size = UDim2.new(0, 60, 0, 30)
toggleFrame8.Position = UDim2.new(1, -70, 0, 5)
toggleFrame8.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame8.Parent = toggleContainer8

local toggleCorner8 = Instance.new("UICorner")
toggleCorner8.CornerRadius = UDim.new(0, 15)
toggleCorner8.Parent = toggleFrame8

local toggleButton8 = Instance.new("TextButton")
toggleButton8.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton8.Position = UDim2.new(featureStates.AntiTrap and 0.5 or 0, 5, 0, 2.5)
toggleButton8.BackgroundColor3 = featureStates.AntiTrap and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton8.Text = ""
toggleButton8.Parent = toggleFrame8
toggleButtons.AntiTrap = toggleButton8

local toggleButtonCorner8 = Instance.new("UICorner")
toggleButtonCorner8.CornerRadius = UDim.new(0, 15)
toggleButtonCorner8.Parent = toggleButton8

toggleButton8.MouseButton1Click:Connect(function()
    featureStates.AntiTrap = not featureStates.AntiTrap
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton8, tweenInfo, {
        Position = UDim2.new(featureStates.AntiTrap and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.AntiTrap and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    antiTrapFunction(featureStates.AntiTrap)
end)

-- Anti Bee Toggle
local boxFrame11 = Instance.new("Frame")
boxFrame11.Size = UDim2.new(1, -10, 0, 50)
boxFrame11.Position = UDim2.new(0, 5, 0, 5)
boxFrame11.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame11.BorderSizePixel = 1
boxFrame11.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame11.Parent = tabFrame
boxFrame11.LayoutOrder = 11

local boxCorner11 = Instance.new("UICorner")
boxCorner11.CornerRadius = UDim.new(0, 8)
boxCorner11.Parent = boxFrame11

local toggleContainer11 = Instance.new("Frame")
toggleContainer11.Size = UDim2.new(1, -20, 0, 40)
toggleContainer11.Position = UDim2.new(0, 10, 0, 5)
toggleContainer11.BackgroundTransparency = 1
toggleContainer11.Parent = boxFrame11

local toggleLabel11 = Instance.new("TextLabel")
toggleLabel11.Size = UDim2.new(0, 150, 1, 0)
toggleLabel11.Position = UDim2.new(0, 0, 0, 0)
toggleLabel11.BackgroundTransparency = 1
toggleLabel11.Text = "Anti Bee"
toggleLabel11.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel11.TextSize = 16
toggleLabel11.Font = Enum.Font.Gotham
toggleLabel11.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel11.Parent = toggleContainer11
toggleLabels.AntiBee = toggleLabel11

local toggleFrame11 = Instance.new("Frame")
toggleFrame11.Size = UDim2.new(0, 60, 0, 30)
toggleFrame11.Position = UDim2.new(1, -70, 0, 5)
toggleFrame11.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame11.Parent = toggleContainer11

local toggleCorner11 = Instance.new("UICorner")
toggleCorner11.CornerRadius = UDim.new(0, 15)
toggleCorner11.Parent = toggleFrame11

local toggleButton11 = Instance.new("TextButton")
toggleButton11.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton11.Position = UDim2.new(featureStates.AntiBee and 0.5 or 0, 5, 0, 2.5)
toggleButton11.BackgroundColor3 = featureStates.AntiBee and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton11.Text = ""
toggleButton11.Parent = toggleFrame11
toggleButtons.AntiBee = toggleButton11

local toggleButtonCorner11 = Instance.new("UICorner")
toggleButtonCorner11.CornerRadius = UDim.new(0, 15)
toggleButtonCorner11.Parent = toggleButton11

toggleButton11.MouseButton1Click:Connect(function()
    featureStates.AntiBee = not featureStates.AntiBee
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton11, tweenInfo, {
        Position = UDim2.new(featureStates.AntiBee and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.AntiBee and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    antiBeeFunction(featureStates.AntiBee)
end)

-- Control Player Toggle
local boxFrame12 = Instance.new("Frame")
boxFrame12.Size = UDim2.new(1, -10, 0, 50)
boxFrame12.Position = UDim2.new(0, 5, 0, 5)
boxFrame12.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame12.BorderSizePixel = 1
boxFrame12.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame12.Parent = tabFrame
boxFrame12.LayoutOrder = 12

local boxCorner12 = Instance.new("UICorner")
boxCorner12.CornerRadius = UDim.new(0, 8)
boxCorner12.Parent = boxFrame12

local toggleContainer12 = Instance.new("Frame")
toggleContainer12.Size = UDim2.new(1, -20, 0, 40)
toggleContainer12.Position = UDim2.new(0, 10, 0, 5)
toggleContainer12.BackgroundTransparency = 1
toggleContainer12.Parent = boxFrame12

local toggleLabel12 = Instance.new("TextLabel")
toggleLabel12.Size = UDim2.new(0, 150, 1, 0)
toggleLabel12.Position = UDim2.new(0, 0, 0, 0)
toggleLabel12.BackgroundTransparency = 1
toggleLabel12.Text = "Control Player"
toggleLabel12.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel12.TextSize = 16
toggleLabel12.Font = Enum.Font.Gotham
toggleLabel12.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel12.Parent = toggleContainer12
toggleLabels.ControlPlayer = toggleLabel12

local toggleFrame12 = Instance.new("Frame")
toggleFrame12.Size = UDim2.new(0, 60, 0, 30)
toggleFrame12.Position = UDim2.new(1, -70, 0, 5)
toggleFrame12.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame12.Parent = toggleContainer12

local toggleCorner12 = Instance.new("UICorner")
toggleCorner12.CornerRadius = UDim.new(0, 15)
toggleCorner12.Parent = toggleFrame12

local toggleButton12 = Instance.new("TextButton")
toggleButton12.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton12.Position = UDim2.new(featureStates.ControlPlayer and 0.5 or 0, 5, 0, 2.5)
toggleButton12.BackgroundColor3 = featureStates.ControlPlayer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton12.Text = ""
toggleButton12.Parent = toggleFrame12
toggleButtons.ControlPlayer = toggleButton12

local toggleButtonCorner12 = Instance.new("UICorner")
toggleButtonCorner12.CornerRadius = UDim.new(0, 15)
toggleButtonCorner12.Parent = toggleButton12

toggleButton12.MouseButton1Click:Connect(function()
    featureStates.ControlPlayer = not featureStates.ControlPlayer
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton12, tweenInfo, {
        Position = UDim2.new(featureStates.ControlPlayer and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.ControlPlayer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    controlPlayerFunction(featureStates.ControlPlayer)
end)

-- FPS Booster Toggle
local boxFrame13 = Instance.new("Frame")
boxFrame13.Size = UDim2.new(1, -10, 0, 50)
boxFrame13.Position = UDim2.new(0, 5, 0, 5)
boxFrame13.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame13.BorderSizePixel = 1
boxFrame13.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame13.Parent = tabFrame
boxFrame13.LayoutOrder = 13

local boxCorner13 = Instance.new("UICorner")
boxCorner13.CornerRadius = UDim.new(0, 8)
boxCorner13.Parent = boxFrame13

local toggleContainer13 = Instance.new("Frame")
toggleContainer13.Size = UDim2.new(1, -20, 0, 40)
toggleContainer13.Position = UDim2.new(0, 10, 0, 5)
toggleContainer13.BackgroundTransparency = 1
toggleContainer13.Parent = boxFrame13

local toggleLabel13 = Instance.new("TextLabel")
toggleLabel13.Size = UDim2.new(0, 150, 1, 0)
toggleLabel13.Position = UDim2.new(0, 0, 0, 0)
toggleLabel13.BackgroundTransparency = 1
toggleLabel13.Text = "FPS Booster"
toggleLabel13.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel13.TextSize = 16
toggleLabel13.Font = Enum.Font.Gotham
toggleLabel13.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel13.Parent = toggleContainer13
toggleLabels.FPSBooster = toggleLabel13

local toggleFrame13 = Instance.new("Frame")
toggleFrame13.Size = UDim2.new(0, 60, 0, 30)
toggleFrame13.Position = UDim2.new(1, -70, 0, 5)
toggleFrame13.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame13.Parent = toggleContainer13

local toggleCorner13 = Instance.new("UICorner")
toggleCorner13.CornerRadius = UDim.new(0, 15)
toggleCorner13.Parent = toggleFrame13

local toggleButton13 = Instance.new("TextButton")
toggleButton13.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton13.Position = UDim2.new(featureStates.FPSBooster and 0.5 or 0, 5, 0, 2.5)
toggleButton13.BackgroundColor3 = featureStates.FPSBooster and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton13.Text = ""
toggleButton13.Parent = toggleFrame13
toggleButtons.FPSBooster = toggleButton13

local toggleButtonCorner13 = Instance.new("UICorner")
toggleButtonCorner13.CornerRadius = UDim.new(0, 15)
toggleButtonCorner13.Parent = toggleButton13

toggleButton13.MouseButton1Click:Connect(function()
    featureStates.FPSBooster = not featureStates.FPSBooster
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton13, tweenInfo, {
        Position = UDim2.new(featureStates.FPSBooster and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.FPSBooster and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    fpsBoosterFunction(featureStates.FPSBooster)
end)

-- Destroy Turret Toggle
local boxFrame14 = Instance.new("Frame")
boxFrame14.Size = UDim2.new(1, -10, 0, 50)
boxFrame14.Position = UDim2.new(0, 5, 0, 5)
boxFrame14.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame14.BorderSizePixel = 1
boxFrame14.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame14.Parent = tabFrame
boxFrame14.LayoutOrder = 14

local boxCorner14 = Instance.new("UICorner")
boxCorner14.CornerRadius = UDim.new(0, 8)
boxCorner14.Parent = boxFrame14

local toggleContainer14 = Instance.new("Frame")
toggleContainer14.Size = UDim2.new(1, -20, 0, 40)
toggleContainer14.Position = UDim2.new(0, 10, 0, 5)
toggleContainer14.BackgroundTransparency = 1
toggleContainer14.Parent = boxFrame14

local toggleLabel14 = Instance.new("TextLabel")
toggleLabel14.Size = UDim2.new(0, 150, 1, 0)
toggleLabel14.Position = UDim2.new(0, 0, 0, 0)
toggleLabel14.BackgroundTransparency = 1
toggleLabel14.Text = "Destroy Turret"
toggleLabel14.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel14.TextSize = 16
toggleLabel14.Font = Enum.Font.Gotham
toggleLabel14.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel14.Parent = toggleContainer14
toggleLabels.DestroyTurret = toggleLabel14

local toggleFrame14 = Instance.new("Frame")
toggleFrame14.Size = UDim2.new(0, 60, 0, 30)
toggleFrame14.Position = UDim2.new(1, -70, 0, 5)
toggleFrame14.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame14.Parent = toggleContainer14

local toggleCorner14 = Instance.new("UICorner")
toggleCorner14.CornerRadius = UDim.new(0, 15)
toggleCorner14.Parent = toggleFrame14

local toggleButton14 = Instance.new("TextButton")
toggleButton14.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton14.Position = UDim2.new(featureStates.DestroyTurret and 0.5 or 0, 5, 0, 2.5)
toggleButton14.BackgroundColor3 = featureStates.DestroyTurret and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton14.Text = ""
toggleButton14.Parent = toggleFrame14
toggleButtons.DestroyTurret = toggleButton14

local toggleButtonCorner14 = Instance.new("UICorner")
toggleButtonCorner14.CornerRadius = UDim.new(0, 15)
toggleButtonCorner14.Parent = toggleButton14

toggleButton14.MouseButton1Click:Connect(function()
    featureStates.DestroyTurret = not featureStates.DestroyTurret
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton14, tweenInfo, {
        Position = UDim2.new(featureStates.DestroyTurret and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.DestroyTurret and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    destroyTurretFunction(featureStates.DestroyTurret)
end)

-- Fps Devoure Toggle
local boxFrame15 = Instance.new("Frame")
boxFrame15.Size = UDim2.new(1, -10, 0, 50)
boxFrame15.Position = UDim2.new(0, 5, 0, 5)
boxFrame15.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame15.BorderSizePixel = 1
boxFrame15.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame15.Parent = tabFrame
boxFrame15.LayoutOrder = 15

local boxCorner15 = Instance.new("UICorner")
boxCorner15.CornerRadius = UDim.new(0, 8)
boxCorner15.Parent = boxFrame15

local toggleContainer15 = Instance.new("Frame")
toggleContainer15.Size = UDim2.new(1, -20, 0, 40)
toggleContainer15.Position = UDim2.new(0, 10, 0, 5)
toggleContainer15.BackgroundTransparency = 1
toggleContainer15.Parent = boxFrame15

local toggleLabel15 = Instance.new("TextLabel")
toggleLabel15.Size = UDim2.new(0, 150, 1, 0)
toggleLabel15.Position = UDim2.new(0, 0, 0, 0)
toggleLabel15.BackgroundTransparency = 1
toggleLabel15.Text = "Fps Devoure"
toggleLabel15.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel15.TextSize = 16
toggleLabel15.Font = Enum.Font.Gotham
toggleLabel15.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel15.Parent = toggleContainer15
toggleLabels.FpsDevourer = toggleLabel15

local toggleFrame15 = Instance.new("Frame")
toggleFrame15.Size = UDim2.new(0, 60, 0, 30)
toggleFrame15.Position = UDim2.new(1, -70, 0, 5)
toggleFrame15.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame15.Parent = toggleContainer15

local toggleCorner15 = Instance.new("UICorner")
toggleCorner15.CornerRadius = UDim.new(0, 15)
toggleCorner15.Parent = toggleFrame15

local toggleButton15 = Instance.new("TextButton")
toggleButton15.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton15.Position = UDim2.new(featureStates.FpsDevourer and 0.5 or 0, 5, 0, 2.5)
toggleButton15.BackgroundColor3 = featureStates.FpsDevourer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton15.Text = ""
toggleButton15.Parent = toggleFrame15
toggleButtons.FpsDevourer = toggleButton15

local toggleButtonCorner15 = Instance.new("UICorner")
toggleButtonCorner15.CornerRadius = UDim.new(0, 15)
toggleButtonCorner15.Parent = toggleButton15

toggleButton15.MouseButton1Click:Connect(function()
    featureStates.FpsDevourer = not featureStates.FpsDevourer
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton15, tweenInfo, {
        Position = UDim2.new(featureStates.FpsDevourer and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.FpsDevourer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    fpsDevourerFunction(featureStates.FpsDevourer)
end)

-- Target Base Owner Toggle
local boxFrame16 = Instance.new("Frame")
boxFrame16.Size = UDim2.new(1, -10, 0, 50)
boxFrame16.Position = UDim2.new(0, 5, 0, 5)
boxFrame16.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame16.BorderSizePixel = 1
boxFrame16.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame16.Parent = tabFrame
boxFrame16.LayoutOrder = 16

local boxCorner16 = Instance.new("UICorner")
boxCorner16.CornerRadius = UDim.new(0, 8)
boxCorner16.Parent = boxFrame16

local toggleContainer16 = Instance.new("Frame")
toggleContainer16.Size = UDim2.new(1, -20, 0, 40)
toggleContainer16.Position = UDim2.new(0, 10, 0, 5)
toggleContainer16.BackgroundTransparency = 1
toggleContainer16.Parent = boxFrame16

local toggleLabel16 = Instance.new("TextLabel")
toggleLabel16.Size = UDim2.new(0, 150, 1, 0)
toggleLabel16.Position = UDim2.new(0, 0, 0, 0)
toggleLabel16.BackgroundTransparency = 1
toggleLabel16.Text = "Target Base Owner"
toggleLabel16.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel16.TextSize = 16
toggleLabel16.Font = Enum.Font.Gotham
toggleLabel16.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel16.Parent = toggleContainer16
toggleLabels.TargetOwner = toggleLabel16

local toggleFrame16 = Instance.new("Frame")
toggleFrame16.Size = UDim2.new(0, 60, 0, 30)
toggleFrame16.Position = UDim2.new(1, -70, 0, 5)
toggleFrame16.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame16.Parent = toggleContainer16

local toggleCorner16 = Instance.new("UICorner")
toggleCorner16.CornerRadius = UDim.new(0, 15)
toggleCorner16.Parent = toggleFrame16

local toggleButton16 = Instance.new("TextButton")
toggleButton16.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton16.Position = UDim2.new(featureStates.TargetOwner and 0.5 or 0, 5, 0, 2.5)
toggleButton16.BackgroundColor3 = featureStates.TargetOwner and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton16.Text = ""
toggleButton16.Parent = toggleFrame16
toggleButtons.TargetOwner = toggleButton16

local toggleButtonCorner16 = Instance.new("UICorner")
toggleButtonCorner16.CornerRadius = UDim.new(0, 15)
toggleButtonCorner16.Parent = toggleButton16

toggleButton16.MouseButton1Click:Connect(function()
    featureStates.TargetOwner = not featureStates.TargetOwner
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton16, tweenInfo, {
        Position = UDim2.new(featureStates.TargetOwner and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.TargetOwner and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    targetBaseOwnerFunction(featureStates.TargetOwner)
end)

-- Semi Invisible Toggle
local boxFrame17 = Instance.new("Frame")
boxFrame17.Size = UDim2.new(1, -10, 0, 50)
boxFrame17.Position = UDim2.new(0, 5, 0, 5)
boxFrame17.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
boxFrame17.BorderSizePixel = 1
boxFrame17.BorderColor3 = Color3.fromRGB(60, 60, 60)
boxFrame17.Parent = tabFrame
boxFrame17.LayoutOrder = 17

local boxCorner17 = Instance.new("UICorner")
boxCorner17.CornerRadius = UDim.new(0, 8)
boxCorner17.Parent = boxFrame17

local toggleContainer17 = Instance.new("Frame")
toggleContainer17.Size = UDim2.new(1, -20, 0, 40)
toggleContainer17.Position = UDim2.new(0, 10, 0, 5)
toggleContainer17.BackgroundTransparency = 1
toggleContainer17.Parent = boxFrame17

local toggleLabel17 = Instance.new("TextLabel")
toggleLabel17.Size = UDim2.new(0, 150, 1, 0)
toggleLabel17.Position = UDim2.new(0, 0, 0, 0)
toggleLabel17.BackgroundTransparency = 1
toggleLabel17.Text = "Semi Invisible"
toggleLabel17.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel17.TextSize = 16
toggleLabel17.Font = Enum.Font.Gotham
toggleLabel17.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel17.Parent = toggleContainer17
toggleLabels.SemiInvisible = toggleLabel17

local toggleFrame17 = Instance.new("Frame")
toggleFrame17.Size = UDim2.new(0, 60, 0, 30)
toggleFrame17.Position = UDim2.new(1, -70, 0, 5)
toggleFrame17.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleFrame17.Parent = toggleContainer17

local toggleCorner17 = Instance.new("UICorner")
toggleCorner17.CornerRadius = UDim.new(0, 15)
toggleCorner17.Parent = toggleFrame17

local toggleButton17 = Instance.new("TextButton")
toggleButton17.Size = UDim2.new(0.5, -5, 1, -5)
toggleButton17.Position = UDim2.new(featureStates.SemiInvisible and 0.5 or 0, 5, 0, 2.5)
toggleButton17.BackgroundColor3 = featureStates.SemiInvisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
toggleButton17.Text = ""
toggleButton17.Parent = toggleFrame17
toggleButtons.SemiInvisible = toggleButton17

local toggleButtonCorner17 = Instance.new("UICorner")
toggleButtonCorner17.CornerRadius = UDim.new(0, 15)
toggleButtonCorner17.Parent = toggleButton17

toggleButton17.MouseButton1Click:Connect(function()
    featureStates.SemiInvisible = not featureStates.SemiInvisible
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(toggleButton17, tweenInfo, {
        Position = UDim2.new(featureStates.SemiInvisible and 0.5 or 0, 5, 0, 2.5),
        BackgroundColor3 = featureStates.SemiInvisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
    tween:Play()
    semiInvisibleFunction(featureStates.SemiInvisible)
end)

        -- Freeze Player Toggle
        local boxFrame4 = Instance.new("Frame")
        boxFrame4.Size = UDim2.new(1, -10, 0, 50)
        boxFrame4.Position = UDim2.new(0, 5, 0, 5)
        boxFrame4.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        boxFrame4.BorderSizePixel = 1
        boxFrame4.BorderColor3 = Color3.fromRGB(60, 60, 60)
        boxFrame4.Parent = tabFrame
        boxFrame4.LayoutOrder = 4

        local boxCorner4 = Instance.new("UICorner")
        boxCorner4.CornerRadius = UDim.new(0, 8)
        boxCorner4.Parent = boxFrame4

        local toggleContainer4 = Instance.new("Frame")
        toggleContainer4.Size = UDim2.new(1, -20, 0, 40)
        toggleContainer4.Position = UDim2.new(0, 10, 0, 5)
        toggleContainer4.BackgroundTransparency = 1
        toggleContainer4.Parent = boxFrame4

        local toggleLabel4 = Instance.new("TextLabel")
        toggleLabel4.Size = UDim2.new(0, 150, 1, 0)
        toggleLabel4.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel4.BackgroundTransparency = 1
        toggleLabel4.Text = "Freeze Player"
        toggleLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel4.TextSize = 16
        toggleLabel4.Font = Enum.Font.Gotham
        toggleLabel4.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel4.Parent = toggleContainer4
        toggleLabels.FreezePlayer = toggleLabel4

        local toggleFrame4 = Instance.new("Frame")
        toggleFrame4.Size = UDim2.new(0, 60, 0, 30)
        toggleFrame4.Position = UDim2.new(1, -70, 0, 5)
        toggleFrame4.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleFrame4.Parent = toggleContainer4

        local toggleCorner4 = Instance.new("UICorner")
        toggleCorner4.CornerRadius = UDim.new(0, 15)
        toggleCorner4.Parent = toggleFrame4

        local toggleButton4 = Instance.new("TextButton")
        toggleButton4.Size = UDim2.new(0.5, -5, 1, -5)
        toggleButton4.Position = UDim2.new(featureStates.FreezePlayer and 0.5 or 0, 5, 0, 2.5)
        toggleButton4.BackgroundColor3 = featureStates.FreezePlayer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggleButton4.Text = ""
        toggleButton4.Parent = toggleFrame4
        toggleButtons.FreezePlayer = toggleButton4

        local toggleButtonCorner4 = Instance.new("UICorner")
        toggleButtonCorner4.CornerRadius = UDim.new(0, 15)
        toggleButtonCorner4.Parent = toggleButton4

        toggleButton4.MouseButton1Click:Connect(function()
            featureStates.FreezePlayer = not featureStates.FreezePlayer
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(toggleButton4, tweenInfo, {
                Position = UDim2.new(featureStates.FreezePlayer and 0.5 or 0, 5, 0, 2.5),
                BackgroundColor3 = featureStates.FreezePlayer and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
            tween:Play()
            freezePlayerFunction(featureStates.FreezePlayer)
        end)
    elseif tabName == "Visual" then
        -- Baselock ESP Toggle
        local boxFrame5 = Instance.new("Frame")
        boxFrame5.Size = UDim2.new(1, -10, 0, 50)
        boxFrame5.Position = UDim2.new(0, 5, 0, 5)
        boxFrame5.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        boxFrame5.BorderSizePixel = 1
        boxFrame5.BorderColor3 = Color3.fromRGB(60, 60, 60)
        boxFrame5.Parent = tabFrame
        boxFrame5.LayoutOrder = 1

        local boxCorner5 = Instance.new("UICorner")
        boxCorner5.CornerRadius = UDim.new(0, 8)
        boxCorner5.Parent = boxFrame5

        local toggleContainer5 = Instance.new("Frame")
        toggleContainer5.Size = UDim2.new(1, -20, 0, 40)
        toggleContainer5.Position = UDim2.new(0, 10, 0, 5)
        toggleContainer5.BackgroundTransparency = 1
        toggleContainer5.Parent = boxFrame5

        local toggleLabel5 = Instance.new("TextLabel")
        toggleLabel5.Size = UDim2.new(0, 150, 1, 0)
        toggleLabel5.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel5.BackgroundTransparency = 1
        toggleLabel5.Text = "Baselock ESP"
        toggleLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel5.TextSize = 16
        toggleLabel5.Font = Enum.Font.Gotham
        toggleLabel5.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel5.Parent = toggleContainer5
        toggleLabels.BaselockESP = toggleLabel5

        local toggleFrame5 = Instance.new("Frame")
        toggleFrame5.Size = UDim2.new(0, 60, 0, 30)
        toggleFrame5.Position = UDim2.new(1, -70, 0, 5)
        toggleFrame5.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleFrame5.Parent = toggleContainer5

        local toggleCorner5 = Instance.new("UICorner")
        toggleCorner5.CornerRadius = UDim.new(0, 15)
        toggleCorner5.Parent = toggleFrame5

        local toggleButton5 = Instance.new("TextButton")
        toggleButton5.Size = UDim2.new(0.5, -5, 1, -5)
        toggleButton5.Position = UDim2.new(featureStates.BaselockESP and 0.5 or 0, 5, 0, 2.5)
        toggleButton5.BackgroundColor3 = featureStates.BaselockESP and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggleButton5.Text = ""
        toggleButton5.Parent = toggleFrame5
        toggleButtons.BaselockESP = toggleButton5

        local toggleButtonCorner5 = Instance.new("UICorner")
        toggleButtonCorner5.CornerRadius = UDim.new(0, 15)
        toggleButtonCorner5.Parent = toggleButton5

        toggleButton5.MouseButton1Click:Connect(function()
            featureStates.BaselockESP = not featureStates.BaselockESP
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(toggleButton5, tweenInfo, {
                Position = UDim2.new(featureStates.BaselockESP and 0.5 or 0, 5, 0, 2.5),
                BackgroundColor3 = featureStates.BaselockESP and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            })
            tween:Play()
            baselockESPFunction(featureStates.BaselockESP)
        end)
    elseif tabName == "Settings" then
        local saveButton = Instance.new("TextButton")
        saveButton.Size = UDim2.new(0, 100, 0, 40)
        saveButton.Position = UDim2.new(0, 10, 0, 60)
        saveButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        saveButton.Text = "Save Config"
        saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        saveButton.TextSize = 16
        saveButton.Font = Enum.Font.Gotham
        saveButton.Parent = tabFrame

        local saveCorner = Instance.new("UICorner")
        saveCorner.CornerRadius = UDim.new(0, 8)
        saveCorner.Parent = saveButton

        local loadButton = Instance.new("TextButton")
        loadButton.Size = UDim2.new(0, 100, 0, 40)
        loadButton.Position = UDim2.new(0, 120, 0, 60)
        loadButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        loadButton.Text = "Load Config"
        loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadButton.TextSize = 16
        loadButton.Font = Enum.Font.Gotham
        loadButton.Parent = tabFrame

        local loadCorner = Instance.new("UICorner")
        loadCorner.CornerRadius = UDim.new(0, 8)
        loadCorner.Parent = loadButton

        saveButton.MouseButton1Click:Connect(saveConfig)
        loadButton.MouseButton1Click:Connect(loadConfig)
    end

    -- Update CanvasSize for ScrollingFrame
    if tabName ~= "Settings" then
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, tabFrame.UIListLayout.AbsoluteContentSize.Y + 10)
        tabFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabFrame.CanvasSize = UDim2.new(0, 0, 0, tabFrame.UIListLayout.AbsoluteContentSize.Y + 10)
        end)
    end
end

-- Toggle GUI Visibility
IconButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Tab Switching Logic
local function switchTab(selectedTab)
    for _, frame in pairs(tabFrames) do
        frame.Visible = false
    end
    tabFrames[selectedTab].Visible = true
    for _, button in pairs(tabButtons) do
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
    tabButtons[selectedTab].BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

-- Initialize
switchTab("Main")
loadConfig()