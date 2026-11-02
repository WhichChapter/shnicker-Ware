--[[
    Shnicker Ware
    KillAura.lua (Integrated with AlSploit / Shnicker Ware schema)
    Requires MainScript.lua module loader
]]

return function(Shared)

    local Tab = Shared.BlatantTab
    local Players = Shared.Players
    local plr = Shared.LocalPlayer
    local ReplicatedStorage = Shared.ReplicatedStorage
    local RunService = Shared.RunService

    local state = {
        enabled = false,
        range = 20,
        toolCheck = false,
        strafe = false
    }

    local connection

    -- Remote setup for sword hitting matching your framework remotes
    local SwordHitRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SwordHit")

    local function getCharacter()
        local character = plr.Character
        if not character then return end

        local tool = character:FindFirstChildWhichIsA("Tool")
        if not tool then return end

        local touch = tool:FindFirstChildWhichIsA("TouchTransmitter", true)
        if not touch then return end

        local part = touch.Parent
        if not part:IsA("BasePart") then return end

        return character, tool, part
    end

    local function getTargets()
        local targets = {}

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= plr and player.Team ~= plr.Team then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if character and humanoid and humanoid.Health > 0 and character.PrimaryPart then
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

        connection = RunService.Heartbeat:Connect(function()
            if not state.enabled then return end

            local character, tool, part = getCharacter()
            if not character or not part then 
                if state.toolCheck then return end
            end

            local targets = getTargets()
            if #targets == 0 then return end

            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end

            for _, targetChar in ipairs(targets) do
                local targetRoot = targetChar.PrimaryPart
                if targetRoot then
                    local distance = (rootPart.Position - targetRoot.Position).Magnitude

                    if distance <= state.range then
                        -- Optional Strafe behavior logic
                        if state.strafe and distance < 12 then
                            rootPart.CFrame = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 5 + Vector3.new(0, 0, 5))
                        end

                        -- Fire hit payload via framework remote
                        if tool then
                            pcall(function()
                                SwordHitRemote:FireServer({
                                    weapon = tool,
                                    chargedAttack = {chargeRatio = 0},
                                    entityInstance = targetChar,
                                    validate = {
                                        raycast = {
                                            cameraPosition = {value = rootPart.Position}, 
                                            cursorDirection = {value = CFrame.new(rootPart.Position, targetRoot.Position).lookVector}
                                        },
                                        targetPosition = {value = targetRoot.Position},
                                        selfPosition = {value = rootPart.Position}
                                    }
                                })
                            end)
                        end
                    end
                end
            end
        end)
    end

    -- UI Integration via Rayfield/Shnicker Ware Tab APIs
    Tab:CreateToggle({
        Name = "KillAura",
        CurrentValue = false,
        Flag = "ShnickerKillAura",

        Callback = function(value)
            if value then
                start()
            else
                stop()
            end
        end
    })

    Tab:CreateSlider({
        Name = "KillAura Range",
        Range = {1, 30},
        Increment = 1,
        Suffix = " studs",
        CurrentValue = 20,
        Flag = "ShnickerKillAuraRange",

        Callback = function(value)
            state.range = value
        end
    })

    Tab:CreateToggle({
        Name = "KillAura Strafe",
        CurrentValue = false,
        Flag = "ShnickerKillAuraStrafe",

        Callback = function(value)
            state.strafe = value
        end
    })

    print("[Shnicker Ware] KillAura submodule initialized successfully[cite: 1]")

end
