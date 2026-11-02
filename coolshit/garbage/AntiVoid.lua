--[[
    Shnicker Ware
    AntiVoid.lua (Extracted literally from AlSploit source)
    Requires MainScript.lua module loader
]]

return function(Shared)

    local Players = Shared.Players
    local LocalPlayer = Shared.LocalPlayer
    local ReplicatedStorage = Shared.ReplicatedStorage
    local RunService = Shared.RunService
    local CollectionService = game:GetService("CollectionService")
    local WorkSpace = game:GetService("Workspace") or workspace
    local Tab = Shared.WorldTab -- Usually placed in World or Blatant tab

    local ClientHandlerStore = require(LocalPlayer.PlayerScripts.TS.ui.store).ClientStore

    local Settings = {
        AntiVoid = {Value = false, Transparency = 0.65, KeyBind = "..."}
    }

    local AntiVoidPart = nil

    local function GetMatchState()
        return ClientHandlerStore:getState().Game.matchState
    end

    local function IsAlive(Player)
        Player = Player or LocalPlayer
        if not Player.Character then return false end
        if not Player.Character:FindFirstChild("Humanoid") then return false end
        if Player.Character:GetAttribute("Health") <= 0 then return false end
        if not Player.Character.PrimaryPart then return false end	
        return true
    end

    local function StartAntiVoid()
        task.spawn(function()
            repeat task.wait() until GetMatchState() ~= 0

            task.wait(0.3)

            local OldLowestPosition = math.huge
            local LowestPosition = 99999

            local BlockRaycastParameters = RaycastParams.new()
            BlockRaycastParameters.FilterType = Enum.RaycastFilterType.Include
            BlockRaycastParameters.FilterDescendantsInstances = CollectionService:GetTagged("block")

            AntiVoidPart = Instance.new("Part")
            AntiVoidPart.Parent = WorkSpace
            AntiVoidPart.Material = Enum.Material.Neon
            AntiVoidPart.Name = "AntiVoidPart"
            AntiVoidPart.Size = Vector3.new(99999, 1, 99999)
            AntiVoidPart.Position = Vector3.new(0, 99999, 0)
            AntiVoidPart.Transparency = Settings.AntiVoid.Transparency
            AntiVoidPart.Color = Color3.new(0.666667, 0, 1)
            AntiVoidPart.CanCollide = false
            AntiVoidPart.Anchored = true

            for i, v in next, CollectionService:GetTagged("block") do
                local NewRay = WorkSpace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), BlockRaycastParameters)

                if NewRay then
                    LowestPosition = NewRay.Position.Y
                    if LowestPosition < OldLowestPosition then
                        OldLowestPosition = LowestPosition
                        AntiVoidPart.Position = Vector3.new(0, LowestPosition - 4, 0)
                    end
                end					
            end

            AntiVoidPart.Touched:Connect(function()
                if IsAlive(LocalPlayer) and AntiVoidPart and LocalPlayer.Character.PrimaryPart.Position.Y <= WorkSpace.AntiVoidPart.Position.Y then
                    for i = 1, 3 do
                        if IsAlive(LocalPlayer) then
                            LocalPlayer.Character.PrimaryPart.Velocity = Vector3.new(LocalPlayer.Character.PrimaryPart.Velocity.X, 100, LocalPlayer.Character.PrimaryPart.Velocity.Z)
                        end
                    end
                end
            end)
        end)
    end

    local function StopAntiVoid()
        if AntiVoidPart then
            AntiVoidPart:Destroy()
            AntiVoidPart = nil
        end
    end

    -- UI Integration
    Tab:CreateToggle({
        Name = "Anti Void",
        CurrentValue = Settings.AntiVoid.Value,
        Flag = "ShnickerAntiVoid",
        Callback = function(value)
            Settings.AntiVoid.Value = value
            if value then
                StartAntiVoid()
            else
                StopAntiVoid()
            end
        end
    })

    Tab:CreateSlider({
        Name = "AntiVoid Transparency",
        Range = {0, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = Settings.AntiVoid.Transparency * 100,
        Flag = "ShnickerAntiVoidTransparency",
        Callback = function(value)
            Settings.AntiVoid.Transparency = value / 100
            task.spawn(function()
                if AntiVoidPart then
                    AntiVoidPart.Transparency = Settings.AntiVoid.Transparency
                end
            end)
        end
    })

    print("[Shnicker Ware] AntiVoid.lua loaded successfully[cite: 1]")

end
