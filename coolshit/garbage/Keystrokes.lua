-- Shnicker Ware - movement keystrokes overlay
return function(Shared)
    local Tab = Shared.UtilityTab
    local UIS = Shared.UserInputService
    local player = Shared.LocalPlayer
    local enabled = false
    local beganConnection, endedConnection
    local gui, keyFrames = nil, {}

    local keyInfo = {
        {code = Enum.KeyCode.W, text = "W", x = 38, y = 0},
        {code = Enum.KeyCode.A, text = "A", x = 0, y = 38},
        {code = Enum.KeyCode.S, text = "S", x = 38, y = 38},
        {code = Enum.KeyCode.D, text = "D", x = 76, y = 38},
        {code = Enum.KeyCode.Space, text = "SPACE", x = 0, y = 76, width = 110}
    }

    local function setPressed(code, pressed)
        local frame = keyFrames[code]
        if not frame then return end
        frame.BackgroundColor3 = pressed and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(25, 25, 30)
        frame.TextColor3 = pressed and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(255, 255, 255)
    end

    local function stop()
        enabled = false
        if beganConnection then beganConnection:Disconnect(); beganConnection = nil end
        if endedConnection then endedConnection:Disconnect(); endedConnection = nil end
        if gui then gui:Destroy(); gui = nil end
        table.clear(keyFrames)
    end

    local function start()
        stop()
        enabled = true
        gui = Instance.new("ScreenGui")
        gui.Name = "ShnickerKeystrokes"
        gui.ResetOnSpawn = false
        gui.Parent = player:WaitForChild("PlayerGui")

        local holder = Instance.new("Frame")
        holder.Name = "Keys"
        holder.Size = UDim2.fromOffset(110, 110)
        holder.Position = UDim2.new(0, 16, 1, -126)
        holder.BackgroundTransparency = 1
        holder.Parent = gui

        for _, info in ipairs(keyInfo) do
            local frame = Instance.new("TextLabel")
            frame.Name = info.text
            frame.Size = UDim2.fromOffset(info.width or 34, 34)
            frame.Position = UDim2.fromOffset(info.x, info.y)
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            frame.BackgroundTransparency = 0.15
            frame.TextColor3 = Color3.fromRGB(255, 255, 255)
            frame.Font = Enum.Font.GothamBold
            frame.TextSize = info.code == Enum.KeyCode.Space and 11 or 15
            frame.Text = info.text
            frame.Parent = holder
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
            keyFrames[info.code] = frame
        end

        beganConnection = UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            setPressed(input.KeyCode, true)
        end)
        endedConnection = UIS.InputEnded:Connect(function(input)
            setPressed(input.KeyCode, false)
        end)
    end

    Tab:CreateToggle({
        Name = "Keystrokes",
        CurrentValue = false,
        Flag = "UtilityKeystrokes",
        Callback = function(value)
            if value then start() else stop() end
        end
    })

    player.CharacterRemoving:Connect(function() if enabled then stop() end end)
end
