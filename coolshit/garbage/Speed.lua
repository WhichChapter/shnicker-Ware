
return function(Shared)
    local Tab = Shared.PlayerTab
    local plr = Shared.LocalPlayer

    local enabled = false
    local speed = 32
    local originalSpeed = {}

    local function apply()
        local character = plr.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if not humanoid then return end

        if enabled then
            if originalSpeed[humanoid] == nil then
                originalSpeed[humanoid] = humanoid.WalkSpeed
            end

            humanoid.WalkSpeed = speed
        else
            if originalSpeed[humanoid] ~= nil then
                humanoid.WalkSpeed = originalSpeed[humanoid]
                originalSpeed[humanoid] = nil
            end
        end
    end

    Tab:CreateToggle({
        Name = "Speed",
        CurrentValue = false,
        Flag = "Speed",
        Callback = function(v)
            enabled = v
            apply()
        end
    })

    Tab:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 150},
        Increment = 1,
        Suffix = " studs/s",
        CurrentValue = 32,
        Flag = "WalkSpeed",
        Callback = function(v)
            speed = v
            if enabled then apply() end
        end
    })

    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if enabled then apply() end
    end)
end
