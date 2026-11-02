
--[[
    Shnicker Ware
    Fly.lua
    Requires MainScript.lua module loader
]]

return function(Shared)

    local Tab = Shared.PlayerTab
    local UIS = Shared.UserInputService
    local RunService = Shared.RunService
    local Players = Shared.Players
    local plr = Shared.LocalPlayer
    local Rayfield = Shared.Rayfield

    local state = {
        enabled = false,
        speed = 60
    }

    local velocity
    local gyro
    local flyConnection
    local characterConnection

    local function getCharacter()
        local character = plr.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")

        return character, humanoid, root
    end

    local function cleanup()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end

        if velocity then
            velocity:Destroy()
            velocity = nil
        end

        if gyro then
            gyro:Destroy()
            gyro = nil
        end

        local _, humanoid = getCharacter()

        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    local function stopFly()
        state.enabled = false
        cleanup()
    end

    local function startFly()
        cleanup()

        local _, humanoid, root = getCharacter()

        if not humanoid or not root then
            Rayfield:Notify({
                Title = "Fly",
                Content = "Character not ready",
                Duration = 3
            })
            return
        end

        state.enabled = true
        humanoid.PlatformStand = true

        velocity = Instance.new("BodyVelocity")
        velocity.MaxForce = Vector3.new(100000, 100000, 100000)
        velocity.Velocity = Vector3.zero
        velocity.Parent = root

        gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(100000, 100000, 100000)
        gyro.P = 10000
        gyro.CFrame = workspace.CurrentCamera.CFrame
        gyro.Parent = root

        flyConnection = RunService.RenderStepped:Connect(function()
            if not state.enabled then return end
            if not velocity or not gyro then return end

            local camera = workspace.CurrentCamera
            if not camera then return end

            local movement = Vector3.zero

            if UIS:IsKeyDown(Enum.KeyCode.W) then
                movement += camera.CFrame.LookVector
            end

            if UIS:IsKeyDown(Enum.KeyCode.S) then
                movement -= camera.CFrame.LookVector
            end

            if UIS:IsKeyDown(Enum.KeyCode.D) then
                movement += camera.CFrame.RightVector
            end

            if UIS:IsKeyDown(Enum.KeyCode.A) then
                movement -= camera.CFrame.RightVector
            end

            if UIS:IsKeyDown(Enum.KeyCode.E) then
                movement += Vector3.yAxis
            end

            if UIS:IsKeyDown(Enum.KeyCode.Q) then
                movement -= Vector3.yAxis
            end

            if movement.Magnitude > 0 then
                velocity.Velocity = movement.Unit * state.speed
            else
                velocity.Velocity = Vector3.zero
            end

            gyro.CFrame = camera.CFrame
        end)
    end

    -- Fly toggle
    Tab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Flag = "Fly",

        Callback = function(value)
            if value then
                startFly()
            else
                stopFly()
            end
        end
    })

    -- Fly speed slider
    Tab:CreateSlider({
        Name = "Fly Speed",
        Range = {20, 200},
        Increment = 5,
        Suffix = " studs/s",
        CurrentValue = 60,
        Flag = "FlySpeed",

        Callback = function(value)
            state.speed = value
        end
    })

    -- Respawn handling
    characterConnection = plr.CharacterAdded:Connect(function()
        if state.enabled then
            task.wait(0.5)

            if state.enabled then
                startFly()
            end
        end
    end)

    print("[Shnicker Ware] Fly module initialized")

end
