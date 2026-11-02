-- Shnicker Ware - network ping display
return function(Shared)
    local Tab = Shared.UtilityTab
    local Players = Shared.Players
    local player = Shared.LocalPlayer
    local Stats = game:GetService("Stats")
    local enabled, connection = false, nil
    local gui, label

    local function createGui()
        gui = Instance.new("ScreenGui")
        gui.Name = "ShnickerPing"
        gui.ResetOnSpawn = false
        gui.Parent = player:WaitForChild("PlayerGui")

        label = Instance.new("TextLabel")
        label.Name = "PingLabel"
        label.AnchorPoint = Vector2.new(1, 0)
        label.Position = UDim2.new(1, -14, 0, 50)
        label.Size = UDim2.fromOffset(120, 30)
        label.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        label.BackgroundTransparency = 0.2
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Text = "Ping: --"
        label.Parent = gui
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
    end

    local function readPing()
        local ok, value = pcall(function()
            local item = Stats.Network.ServerStatsItem["Data Ping"]
            return item:GetValueString()
        end)
        if ok and value then return tostring(value) end

        ok, value = pcall(function()
            return tostring(math.floor(Stats.PerformanceStats.Ping:GetValue() + 0.5)) .. " ms"
        end)
        return ok and value or "Unavailable"
    end

    local function stop()
        enabled = false
        if connection then connection:Disconnect(); connection = nil end
        if gui then gui:Destroy(); gui = nil; label = nil end
    end

    Tab:CreateToggle({
        Name = "Ping Display",
        CurrentValue = false,
        Flag = "UtilityPing",
        Callback = function(value)
            if not value then stop(); return end
            stop()
            enabled = true
            createGui()
            local elapsed = 0
            connection = Shared.RunService.Heartbeat:Connect(function(dt)
                elapsed += dt
                if elapsed >= 1 then
                    elapsed = 0
                    if label then label.Text = "Ping: " .. readPing() end
                end
            end)
        end
    })

    player.CharacterRemoving:Connect(function() if enabled then stop() end end)
end
