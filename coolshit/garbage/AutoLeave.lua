return function(Shared)
    local Tab = Shared.PlayerTab
    local plr = Shared.LocalPlayer

    local enabled = false
    local threshold = 10
    local triggered = false

    local function bindCharacter(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        if not humanoid then return end
        triggered = false

        humanoid.HealthChanged:Connect(function(health)
            if enabled and not triggered and health > 0 and health <= threshold then
                triggered = true
                plr:Kick("AutoLeave: health reached the configured threshold.")
            end
        end)
    end

    Tab:CreateToggle({
        Name = "AutoLeave (Low Health)",
        CurrentValue = false,
        Flag = "AutoLeave",
        Callback = function(value)
            enabled = value
            if enabled and plr.Character then
                bindCharacter(plr.Character)
            end
        end
    })

    Tab:CreateSlider({
        Name = "AutoLeave Health Threshold",
        Range = {1, 100},
        Increment = 1,
        Suffix = " HP",
        CurrentValue = 10,
        Flag = "AutoLeaveHealth",
        Callback = function(value)
            threshold = value
        end
    })

    plr.CharacterAdded:Connect(function(character)
        if enabled then
            task.defer(bindCharacter, character)
        end
    end)
end
