-- Shnicker Ware - inspect the player currently under the mouse cursor
-- Informational only: does not lock, aim at, or modify other players.
return function(Shared)
    local Tab = Shared.UtilityTab
    local RunService = Shared.RunService
    local player = Shared.LocalPlayer
    local mouse = player:GetMouse()
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
        gui.Name = "ShnickerTargetInfo"
        gui.ResetOnSpawn = false
        gui.Parent = player:WaitForChild("PlayerGui")
        label = Instance.new("TextLabel")
        label.Name = "TargetInfo"
        label.AnchorPoint = Vector2.new(1, 0)
        label.Position = UDim2.new(1, -14, 0, 14)
        label.Size = UDim2.fromOffset(210, 68)
        label.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
        label.BackgroundTransparency = 0.15
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.Text = "Target: none"
        label.Parent = gui
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 7)

        local elapsed = 0
        connection = RunService.Heartbeat:Connect(function(dt)
            elapsed += dt
            if elapsed < 0.1 or not label then return end
            elapsed = 0
            local part = mouse.Target
            local model = part and part:FindFirstAncestorOfClass("Model")
            local targetPlayer = model and Shared.Players:GetPlayerFromCharacter(model)
            local hum = model and model:FindFirstChildOfClass("Humanoid")
            local root = model and model:FindFirstChild("HumanoidRootPart")
            local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if targetPlayer and targetPlayer ~= player and hum and root then
                local distance = localRoot and (localRoot.Position - root.Position).Magnitude or 0
                label.Text = string.format("%s\nHP: %d / %d\nDistance: %.1f studs",
                    targetPlayer.DisplayName, math.floor(hum.Health + 0.5),
                    math.floor(hum.MaxHealth + 0.5), distance)
            else
                label.Text = "Target: none"
            end
        end)
    end

    Tab:CreateToggle({Name = "Target Info (Mouseover)", CurrentValue = false, Flag = "TargetInfo", Callback = function(v)
        if v then start() else stop() end
    end})
end
