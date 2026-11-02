return function(Shared)
    local Tab = Shared.PlayerTab
    local RunService = Shared.RunService
    local plr = Shared.LocalPlayer

    local enabled = false
    local connection

    local function step()
        if not enabled then return end
        local character = plr.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0
            and humanoid.FloorMaterial ~= Enum.Material.Air
            and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            humanoid.Jump = true
        end
    end

    Tab:CreateToggle({
        Name = "AutoJump",
        CurrentValue = false,
        Flag = "AutoJump",
        Callback = function(value)
            enabled = value
            if enabled and not connection then
                connection = RunService.Heartbeat:Connect(step)
            elseif not enabled and connection then
                connection:Disconnect()
                connection = nil
            end
        end
    })
end
