
return function(Shared)
    local Tab = Shared.PlayerTab
    local plr = Shared.LocalPlayer

    local enabled = false
    local hatParts = {}

    local function removeHat()
        for _, part in ipairs(hatParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end

        table.clear(hatParts)
    end

    local function createHat()
        removeHat()

        local character = plr.Character
        local head = character and character:FindFirstChild("Head")

        if not head then return end

        local function makeLayer(diameter, height, y)
            local part = Instance.new("Part")
            part.Name = "ShnickerChinaHat"
            part.Shape = Enum.PartType.Cylinder
            part.Size = Vector3.new(height, diameter, diameter)
            part.Color = Color3.fromRGB(255, 190, 50)
            part.Material = Enum.Material.SmoothPlastic
            part.CanCollide = false
            part.Massless = true
            part.Anchored = false

            part.CFrame = head.CFrame
                * CFrame.new(0, y, 0)
                * CFrame.Angles(0, 0, math.rad(90))

            part.Parent = character

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = head
            weld.Part1 = part
            weld.Parent = part

            table.insert(hatParts, part)
        end

        makeLayer(2.8, 0.12, 0.65)

        for i = 1, 12 do
            local diameter = 2.5 * (1 - i / 13)
            makeLayer(diameter, 0.14, 0.7 + i * 0.12)
        end
    end

    Tab:CreateToggle({
        Name = "China Hat",
        CurrentValue = false,
        Flag = "ChinaHat",
        Callback = function(v)
            enabled = v

            if enabled then
                createHat()
            else
                removeHat()
            end
        end
    })

    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if enabled then createHat() end
    end)
end
