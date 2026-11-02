return function(Shared)
    local Tab = Shared.UtilityTab
    local Players = Shared.Players
    local GuiService = game:GetService("GuiService")

    local selectedName = nil
    local options = {}

    local function refresh()
        table.clear(options)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Shared.LocalPlayer then
                table.insert(options, player.Name)
            end
        end
        table.sort(options)
    end

    refresh()

    local dropdown = Tab:CreateDropdown({
        Name = "Select Player to Report",
        Options = options,
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "ReportPlayer",
        Callback = function(value)
            if type(value) == "table" then
                selectedName = value[1]
            else
                selectedName = value
            end
        end
    })

    Tab:CreateButton({
        Name = "Open Roblox Report Menu",
        Callback = function()
            local target = selectedName and Players:FindFirstChild(selectedName)
            if not target then
                Shared.Rayfield:Notify({
                    Title = "Report",
                    Content = "Select an available player first.",
                    Duration = 3
                })
                return
            end

            local ok = pcall(function()
                GuiService:OpenReportAbuseMenu(target)
            end)

            if not ok then
                Shared.Rayfield:Notify({
                    Title = "Report",
                    Content = "Roblox could not open the report menu. Use the in-game player menu instead.",
                    Duration = 4
                })
            end
        end
    })

    Players.PlayerAdded:Connect(function()
        refresh()
        if dropdown and dropdown.Refresh then
            pcall(function() dropdown:Refresh(options) end)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if selectedName == player.Name then
            selectedName = nil
        end
        refresh()
        if dropdown and dropdown.Refresh then
            pcall(function() dropdown:Refresh(options) end)
        end
    end)
end
