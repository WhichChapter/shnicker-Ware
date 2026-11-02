--[[
    Shnicker Ware
    wow.lua
    Requires MainScript.lua module loader
]]

return function(Shared)

    local Tab = Shared.BlatantTab
    local Players = Shared.Players
    local plr = Shared.LocalPlayer
    local Rayfield = Shared.Rayfield

    local state = {
        enabled = false,
        range = 1
    }

    local connection

    local function getCharacter()
        local character = plr.Character
        if not character then return end

        local tool = character:FindFirstChildWhichIsA("Tool")
        if not tool then return end

        local touch = tool:FindFirstChildWhichIsA(
            "TouchTransmitter",
            true
        )

        if not touch then return end

        local part = touch.Parent

        if not part:IsA("BasePart") then
            return
        end

        return character, tool, part
    end

    local function getTargets()
        local targets = {}

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= plr then
                local character = player.Character
                local humanoid = character
                    and character:FindFirstChildOfClass("Humanoid")

                if character and humanoid and humanoid.Health > 0 then
                    table.insert(targets, character)
                end
            end
        end

        return targets
    end

    local function cleanup()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end

    local function stop()
        state.enabled = false
        cleanup()
    end

    local function start()
        cleanup()
        state.enabled = true

        connection = Shared.RunService.Heartbeat:Connect(function()
            if not state.enabled then return end

            local character, tool, part = getCharacter()
            if not character or not part then return end

            local targets = getTargets()
            if #targets == 0 then return end

            local overlap = OverlapParams.new()
            overlap.FilterType = Enum.RaycastFilterType.Include
            overlap.FilterDescendantsInstances = targets

            -- Get parts inside the bounding box modified by range
            local parts = workspace:GetPartBoundsInBox(
                part.CFrame,
                part.Size + Vector3.new(state.range, state.range, state.range),
                overlap
            )

            for _, v in ipairs(parts) do
                if firetouchinterest then
                    firetouchinterest(part, v, 1)
                    firetouchinterest(part, v, 0)
                end
            end
        end)
    end

    Tab:CreateToggle({
        Name = "Reach",
        CurrentValue = false,
        Flag = "WowReach",

        Callback = function(value)
            if value then
                start()
            else
                stop()
            end
        end
    })

    Tab:CreateSlider({
        Name = "Reach Range",
        Range = {1, 20},
        Increment = 1,
        Suffix = " studs",
        CurrentValue = 1,
        Flag = "WowReachRange",

        Callback = function(value)
            getCharacter() -- safety refresh
            state.range = value
        end
    })

    print("[Shnicker Ware] wow.lua initialized")

end
