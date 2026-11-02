-- Shnicker Ware - local combat/status HUD (no automated combat actions)
return function(Shared)
    local Tab = Shared.UtilityTab
    local RunService = Shared.RunService
    local player = Shared.LocalPlayer
    local enabled, connection, gui, label = false, nil, nil, nil

    local function stop()
        enabled = false
        if connection then connection:Disconnect(); connection = nil end
        if gui then gui:Destroy(); gui = nil; label = nil end
    end

    local function start()
        stop()
        enabled = true
        gui = Instance.new("ScreenGui")
        gui.Name = "ShnickerCombatHUD"
        gui.ResetOnSpawn = false
        gui.Parent = player:WaitForChild("PlayerGui")

        label = Instance.new("TextLabel")
        label.Name = "Status"
        label.Position = UDim2.new(0, 14, 0, 14)
        label.Size = UDim2.fromOffset(235, 112)
        label.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
        label.BackgroundTransparency = 0.15
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.Text = "  SHNICKER WARE"
        label.Parent = gui
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 7)
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingLeft = UDim.new(0, 4)
        padding.Parent = label

        local elapsed = 0
        connection = RunService.Heartbeat:Connect(function(dt)
            elapsed += dt
            if elapsed < 0.15 or not label then return end
            elapsed = 0
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then
                label.Text = "  SHNICKER WARE\n  Character unavailable"
                return
            end
            local p = root.Position
            local speed = root.AssemblyLinearVelocity.Magnitude
            label.Text = string.format(
                "  SHNICKER WARE\n  HP: %d / %d\n  Speed: %.1f studs/s\n  XYZ: %.0f, %.0f, %.0f\n  State: %s",
                math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5),
                speed, p.X, p.Y, p.Z, hum:GetState().Name
            )
        end)
    end

    Tab:CreateToggle({Name = "Combat Status HUD", CurrentValue = false, Flag = "CombatStatusHUD", Callback = function(v)
        if v then start() else stop() end
    end})
end
