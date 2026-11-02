--[[
    Shnicker Ware
    Hitbox.lua (Hitbox Extender)
    Requires MainScript.lua module loader
]]

return function(Shared)

    local Tab = Shared.BlatantTab
    local Players = Shared.Players
    local plr = Shared.LocalPlayer
    local RunService = Shared.RunService

    local state = {
        enabled = false,
        size = 5, -- Default extended size
        transparency = 0.5 -- Semi-transparent so you can see them
    }

    local connection
    local originalSizes = {}

    local function cleanup()
        if connection then
            connection:Disconnect()
            connection = nil
        end

        -- Reset player hitboxes back to normal when disabled
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= plr and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and originalSizes[player] then
                    rootPart.Size = originalSizes[player].Size
                    rootPart.Transparency = originalSizes[player].Transparency
                    rootPart.CanCollide = originalSizes[player].CanCollide
                end
            end
        end
        originalSizes = {}
    end

    local function start()
        cleanup()
        state.enabled = true

        connection = RunService.Heartbeat:Connect(function()
            if not state.enabled then return end

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= plr and player.Team ~= plr.Team then
                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                    if character and humanoid and humanoid.Health > 0 and rootPart then
                        -- Save original size/properties once
                        if not originalSizes[player] then
                            originalSizes[player] = {
                                Size = rootPart.Size,
                                Transparency = rootPart.Transparency,
                                CanCollide = rootPart.CanCollide
                            }
                        end

                        -- Expand the HumanoidRootPart hitbox size
                        rootPart.Size = Vector3.new(state.size, state.size, state.size)
                        rootPart.Transparency = state.transparency
                        rootPart.CanCollide = false
                    end
                end
            end
        end)
    end

    local function stop()
        state.enabled = false
        cleanup()
    end

    -- UI Integration via Rayfield Tab APIs
    Tab:CreateToggle({
        Name = "Hitbox Extender",
        CurrentValue = false,
        Flag = "ShnickerHitbox",

        Callback = function(value)
            if value then
                start()
            else
                stop()
            end
        end
    })

    Tab:CreateSlider({
        Name = "Hitbox Size",
        Range = {2, 15},
        Increment = 1,
        Suffix = " studs",
        CurrentValue = 5,
        Flag = "ShnickerHitboxSize",

        Callback = function(value)
            state.size = value
        end
    })

    print("[Shnicker Ware] Hitbox.lua initialized")

end
