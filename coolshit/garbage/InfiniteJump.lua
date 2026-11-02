
return function(Shared)
    local Tab = Shared.PlayerTab
    local UIS = Shared.UserInputService
    local plr = Shared.LocalPlayer

    local enabled = false

    Tab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Flag = "InfJump",
        Callback = function(v)
            enabled = v
        end
    })

    UIS.JumpRequest:Connect(function()
        if not enabled then return end

        local character = plr.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
