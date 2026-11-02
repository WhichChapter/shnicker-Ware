-- Shnicker Ware - Bed ESP
-- Adapted from the Bed ESP implementation in WhichChapter/test/bedwarz.luau.
-- Uses the same workspace.Map.Beds collection and Mattress-based bed colouring,
-- but is rewritten for Shnicker Ware's Rayfield/Shared module interface.

return function(Shared)
    local Tab = Shared.VisualTab
    local RunService = Shared.RunService

    local enabled = false
    local connection
    local highlights = {}

    local function getBeds()
        local map = workspace:FindFirstChild("Map")
        local bedsFolder = map and map:FindFirstChild("Beds")
        if not bedsFolder then
            return {}
        end

        return bedsFolder:GetChildren()
    end

    local function removeHighlight(bed)
        local highlight = highlights[bed]
        if highlight then
            highlights[bed] = nil
            if highlight.Parent then
                highlight:Destroy()
            end
        end
    end

    local function clearHighlights()
        for bed in pairs(highlights) do
            removeHighlight(bed)
        end
    end

    local function updateBeds()
        local currentBeds = {}

        for _, bed in ipairs(getBeds()) do
            if bed:IsA("Model") then
                currentBeds[bed] = true

                local mattress = bed:FindFirstChild("Mattress")
                if mattress and mattress:IsA("BasePart") then
                    local highlight = highlights[bed]

                    if not highlight or not highlight.Parent then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ShnickerBedESP"
                        highlight.Adornee = bed
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = bed
                        highlights[bed] = highlight
                    end

                    -- Bedwarz identifies each bed using its Mattress colour.
                    highlight.FillColor = mattress.Color
                    highlight.OutlineColor = mattress.Color
                    highlight.FillTransparency = 0.35
                    highlight.OutlineTransparency = 0
                end
            end
        end

        -- Remove highlights for beds that have been removed from the map.
        for bed in pairs(highlights) do
            if not currentBeds[bed] then
                removeHighlight(bed)
            end
        end
    end

    local function stop()
        enabled = false
        if connection then
            connection:Disconnect()
            connection = nil
        end
        clearHighlights()
    end

    Tab:CreateToggle({
        Name = "Bed ESP",
        CurrentValue = false,
        Flag = "VisualBedESP",
        Callback = function(value)
            if not value then
                stop()
                return
            end

            stop()
            enabled = true
            updateBeds()

            local elapsed = 0
            connection = RunService.Heartbeat:Connect(function(dt)
                if not enabled then
                    return
                end

                elapsed += dt
                if elapsed >= 0.2 then
                    elapsed = 0
                    updateBeds()
                end
            end)
        end
    })

    -- Ensure our Highlight instances are cleaned up if the module's UI is removed.
    Shared.LocalPlayer.CharacterRemoving:Connect(function()
        if enabled then
            stop()
        end
    end)
end
