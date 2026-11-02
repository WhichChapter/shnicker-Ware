-- Shnicker Ware - customizable screen-centre crosshair
return function(Shared)
    local Tab = Shared.UtilityTab
    local player = Shared.LocalPlayer
    local enabled, gui = false, nil
    local size, gap, thickness = 18, 5, 2
    local tint = Color3.fromRGB(255, 255, 255)
    local lines = {}

    local function update()
        for _, item in ipairs(lines) do
            item.BackgroundColor3 = tint
        end
        if #lines == 4 then
            lines[1].Size = UDim2.fromOffset(thickness, size)
            lines[1].Position = UDim2.new(0.5, -thickness/2, 0.5, -gap-size)
            lines[2].Size = UDim2.fromOffset(thickness, size)
            lines[2].Position = UDim2.new(0.5, -thickness/2, 0.5, gap)
            lines[3].Size = UDim2.fromOffset(size, thickness)
            lines[3].Position = UDim2.new(0.5, -gap-size, 0.5, -thickness/2)
            lines[4].Size = UDim2.fromOffset(size, thickness)
            lines[4].Position = UDim2.new(0.5, gap, 0.5, -thickness/2)
        end
    end

    local function stop()
        enabled = false
        if gui then gui:Destroy(); gui = nil end
        table.clear(lines)
    end

    local function start()
        stop()
        enabled = true
        gui = Instance.new("ScreenGui")
        gui.Name = "ShnickerCrosshair"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.Parent = player:WaitForChild("PlayerGui")
        for i = 1, 4 do
            local line = Instance.new("Frame")
            line.BorderSizePixel = 0
            line.Parent = gui
            lines[i] = line
        end
        update()
    end

    Tab:CreateToggle({Name = "Custom Crosshair", CurrentValue = false, Flag = "UtilityCrosshair", Callback = function(v)
        if v then start() else stop() end
    end})
    Tab:CreateSlider({Name = "Crosshair Length", Range = {4, 40}, Increment = 1, CurrentValue = size, Flag = "CrosshairLength", Callback = function(v) size = v; if enabled then update() end end})
    Tab:CreateSlider({Name = "Crosshair Gap", Range = {0, 20}, Increment = 1, CurrentValue = gap, Flag = "CrosshairGap", Callback = function(v) gap = v; if enabled then update() end end})
    Tab:CreateSlider({Name = "Crosshair Thickness", Range = {1, 5}, Increment = 1, CurrentValue = thickness, Flag = "CrosshairThickness", Callback = function(v) thickness = v; if enabled then update() end end})
    Tab:CreateColorPicker({Name = "Crosshair Colour", Color = tint, Flag = "CrosshairColor", Callback = function(v) tint = v; if enabled then update() end end})
end
