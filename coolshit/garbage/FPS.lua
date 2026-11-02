-- Shnicker Ware - FPS counter
return function(Shared)
    local Tab = Shared.UtilityTab
    local RunService = Shared.RunService
    local Players = Shared.Players
    local player = Shared.LocalPlayer
    local enabled, connection = false, nil
    local gui, label

    local function createGui()
        local pg = player:WaitForChild("PlayerGui")
        gui = Instance.new("ScreenGui")
        gui.Name = "ShnickerFPS"
        gui.ResetOnSpawn = false
        gui.Parent = pg

        label = Instance.new("TextLabel")
        label.Name = "FPSLabel"
        label.AnchorPoint = Vector2.new(1, 0)
        label.Position = UDim2.new(1, -14, 0, 14)
        label.Size = UDim2.fromOffset(120, 30)
        label.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        label.BackgroundTransparency = 0.2
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Text = "FPS: --"
        label.Parent = gui
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
    end

    local function stop()
        enabled = false
        if connection then connection:Disconnect(); connection = nil end
        if gui then gui:Destroy(); gui = nil; label = nil end
    end

    Tab:CreateToggle({
        Name = "FPS Counter",
        CurrentValue = false,
        Flag = "UtilityFPS",
        Callback = function(value)
            if not value then stop(); return end
            stop()
            enabled = true
            createGui()
            local frames, elapsed = 0, 0
            connection = RunService.RenderStepped:Connect(function(dt)
                if not enabled or not label then return end
                frames += 1
                elapsed += dt
                if elapsed >= 0.5 then
                    label.Text = "FPS: " .. tostring(math.floor(frames / elapsed + 0.5))
                    frames, elapsed = 0, 0
                end
            end)
        end
    })

    player.CharacterRemoving:Connect(function() if enabled then stop() end end)
end
