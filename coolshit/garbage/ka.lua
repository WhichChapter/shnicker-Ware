--[[
    Shnicker Ware
    KillAura.lua (Extracted literally from AlSploit source)
    Requires MainScript.lua module loader
]]

return function(Shared)

    local Players = Shared.Players
    local LocalPlayer = Shared.LocalPlayer
    local ReplicatedStorage = Shared.ReplicatedStorage
    local RunService = Shared.RunService
    local CollectionService = game:GetService("CollectionService")
    local TweenService = game:GetService("TweenService")
    local Tab = Shared.BlatantTab

    local Camera = workspace.CurrentCamera
    local OrigC0 = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Viewmodel"):WaitForChild("RightHand"):WaitForChild("RightWrist"):WaitForChild("C0")

    local SwordHitRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SwordHit")
    local ClientHandlerStore = require(LocalPlayer.PlayerScripts.TS.ui.store).ClientStore
    local InventoryUtil = require(ReplicatedStorage.TS.inventory["inventory-util"]).InventoryUtil
    local ItemTable = debug.getupvalue(require(ReplicatedStorage.TS.item["item-meta"]).getItemMeta, 1)

    local Settings = {
        KillAura = {Value = false, Range = 20, CustomAnimation = true, ToolCheck = false, Strafe = false, KeyBind = "..."},
        Sigma = {Value = false}
    }

    local KillAuraAnimationCooldown = true
    local AnticheatDisabled = false
    local LoopWaitTime = 0

    local Animations = {
        KillAura = {
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(220), math.rad(100), math.rad(100)), Time = 0.25},
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.25}
        },
        Sigma = {
            {CFrame = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.16},
            {CFrame = CFrame.new(0, -0.2, -1.7) * CFrame.Angles(math.rad(30), math.rad(111), math.rad(190)), Time = 0.16},
        },
        Neutral = {
            {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
        }
    }

    local function IsAlive(Player)
        Player = Player or LocalPlayer
        if not Player.Character then return false end
        if not Player.Character:FindFirstChild("Humanoid") then return false end
        if Player.Character:GetAttribute("Health") <= 0 then return false end
        if not Player.Character.PrimaryPart then return false end	
        return true
    end

    local function GetMatchState()
        return ClientHandlerStore:getState().Game.matchState
    end

    local function GetInventory(Player)
        local Player = Player or LocalPlayer
        return InventoryUtil.getInventory(Player)
    end

    local function GetSword()
        local HighestDamage, Sword = -math.huge, nil
        for i, v in next, GetInventory(LocalPlayer).items do 
            local SwordMetaGame = ItemTable[v.itemType].sword
            if SwordMetaGame then
                local SwordDamage = SwordMetaGame.damage / SwordMetaGame.attackSpeed
                if SwordDamage > HighestDamage then
                    HighestDamage = SwordDamage
                    Sword = v
                end
            end
        end
        return Sword
    end

    local function HasItem(Name)
        for i, v in next, GetInventory(LocalPlayer).items do
            if v.itemType:find(Name) then
                return v 
            end
        end	
        return nil
    end

    local function SwitchItem(Item)
        local EquipItemRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetInvItem")
        if LocalPlayer.Character.HandInvItem.Value ~= Item then
            local InventoryItem = ReplicatedStorage.Inventories:FindFirstChild(LocalPlayer.Name):FindFirstChild(Item)
            EquipItemRemote:InvokeServer({hand = InventoryItem})
        end	
    end

    local function FindNearestEntity(MaxDistance)
        local MaxDistance = MaxDistance or math.huge
        local NearestEntityDistance = MaxDistance
        local NearestEntity = nil
        local IsNotAPlayer = true

        task.spawn(function()
            for i, v in next, CollectionService:GetTagged("DiamondGuardian") do
                if v.PrimaryPart then
                    local Distance = (v.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                    if Distance < NearestEntityDistance and Distance <= MaxDistance then
                        NearestEntityDistance = Distance
                        NearestEntity = v
                    end
                end 
            end
        end)

        task.spawn(function()
            for i, v in next, CollectionService:GetTagged("GolemBoss") do
                if v.PrimaryPart then
                    local Distance = (v.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                    if Distance < NearestEntityDistance and Distance <= MaxDistance then
                        NearestEntityDistance = Distance
                        NearestEntity = v
                    end
                end
            end
        end)	

        task.spawn(function()
            for i, v in next, CollectionService:GetTagged("Monster") do
                if v.PrimaryPart then
                    local Distance = (v.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                    if Distance < NearestEntityDistance and Distance <= MaxDistance then
                        NearestEntityDistance = Distance
                        NearestEntity = v
                    end
                end
            end
        end)

        task.spawn(function()
            for i, v in next, Players:GetPlayers() do
                if IsAlive(v) and v ~= LocalPlayer and v.Team ~= LocalPlayer.Team then
                    local Distance = (v.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                    if Distance < NearestEntityDistance and Distance <= MaxDistance then
                        NearestEntityDistance = Distance
                        NearestEntity = v
                        IsNotAPlayer = false
                    end
                end
            end
        end)

        if NearestEntity then	
            return (IsNotAPlayer and NearestEntity or NearestEntity.Character), NearestEntityDistance
        end

        return nil
    end

    local function PlayAnimation(Animation)
        for i, v in next, Animation do
            local TweenInformation = TweenInfo.new(v.Time)
            local AnimationTween = TweenService:Create(Camera.Viewmodel.RightHand.RightWrist, TweenInformation, {C0 = OrigC0 * v.CFrame})
            AnimationTween:Play()
            task.wait(v.Time - 0.01)
        end
    end

    local function HashFunction(Value)
        return {value = Value}
    end

    local function SwordHit(Entity, Weapon, NearestEntityDistance)
        local LocalPlayerHumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
        local EntityPrimaryPart = Entity.PrimaryPart

        local SelfPosition = LocalPlayerHumanoidRootPart.Position + (20 > 14 and (LocalPlayerHumanoidRootPart.Position - EntityPrimaryPart.Position).Magnitude > 14.4 and (CFrame.lookAt(LocalPlayerHumanoidRootPart.Position, EntityPrimaryPart.Position).lookVector * ((LocalPlayerHumanoidRootPart.Position - EntityPrimaryPart.Position).Magnitude - 14)) or Vector3.zero)

        task.spawn(function()
            if KillAuraAnimationCooldown and Settings.KillAura.CustomAnimation == true then
                KillAuraAnimationCooldown = false

                if Settings.Sigma.Value == false then
                    PlayAnimation(Animations.KillAura)
                    KillAuraAnimationCooldown = true
                end

                if Settings.Sigma.Value == true then
                    PlayAnimation(Animations.Sigma)
                    KillAuraAnimationCooldown = true
                end
            end
        end)

        task.spawn(function()
            if Settings.KillAura.Strafe == true and NearestEntityDistance < (AnticheatDisabled and 16 or 12) then
                LocalPlayerHumanoidRootPart.CFrame = CFrame.new(EntityPrimaryPart.Position - EntityPrimaryPart.CFrame.LookVector * 5 + Vector3.new(0, 0, 5))
            end
        end)

        task.spawn(function()
            if Settings.KillAura.ToolCheck == false then
                task.spawn(function()
                    SwitchItem(Weapon.itemType)
                end)

                SelfPosition = LocalPlayerHumanoidRootPart.Position + (20 > 14 and (LocalPlayerHumanoidRootPart.Position - EntityPrimaryPart.Position).Magnitude > 14.4 and (CFrame.lookAt(LocalPlayerHumanoidRootPart.Position, EntityPrimaryPart.Position).lookVector * ((LocalPlayerHumanoidRootPart.Position - EntityPrimaryPart.Position).Magnitude - 14)) or Vector3.zero)

                SwordHitRemote:FireServer({
                    weapon = Weapon.tool,
                    chargedAttack = {chargeRatio = 0},
                    entityInstance = Entity,
                    validate = {
                        raycast = {
                            cameraPosition = HashFunction(LocalPlayerHumanoidRootPart.Position), 
                            cursorDirection = HashFunction(CFrame.new(SelfPosition, EntityPrimaryPart.Position).lookVector)
                        },
                        targetPosition = HashFunction(EntityPrimaryPart.Position),
                        selfPosition = HashFunction(SelfPosition)
                    }
                })
            end

            if Settings.KillAura.ToolCheck == true then
                if HasItem(Weapon.itemType) then
                    SelfPosition = LocalPlayerHumanoidRootPart.Position + (20 > 14 and (LocalPlayerHumanoidRootPart.Position - EntityPrimaryPart.Position).Magnitude > 14.4 and (CFrame.lookAt(LocalPlayerHumanoidRootPart.Position, EntityPrimaryPart.Position).lookVector * ((LocalPlayerHumanoidRootPart.Position - EntityPrimaryPart.Position).Magnitude - 14)) or Vector3.zero)

                    SwordHitRemote:FireServer({
                        weapon = Weapon.tool,
                        chargedAttack = {chargeRatio = 0},
                        entityInstance = Entity,
                        validate = {
                            raycast = {
                                cameraPosition = HashFunction(LocalPlayerHumanoidRootPart.Position), 
                                cursorDirection = HashFunction(CFrame.new(SelfPosition, EntityPrimaryPart.Position).lookVector)
                            },
                            targetPosition = HashFunction(EntityPrimaryPart.Position),
                            selfPosition = HashFunction(SelfPosition)
                        }
                    })
                end
            end
        end)
    end

    -- Execution loop
    task.spawn(function()
        repeat
            task.wait(LoopWaitTime)

            if Settings.KillAura.Value == true and IsAlive(LocalPlayer) and GetMatchState() ~= 0 then
                local NearestEntity, NearestEntityDistance = FindNearestEntity(Settings.KillAura.Range)
                local Sword = GetSword()

                task.spawn(function()
                    if not NearestEntity then
                        PlayAnimation(Animations.Neutral)
                    end
                end)

                task.spawn(function()
                    if NearestEntity and Sword then
                        SwordHit(NearestEntity, Sword, NearestEntityDistance)
                    end
                end)
            end
        until not game	
    end)

    -- UI Integration
    Tab:CreateToggle({
        Name = "Kill Aura",
        CurrentValue = Settings.KillAura.Value,
        Flag = "ShnickerKillAura",
        Callback = function(value)
            Settings.KillAura.Value = value
        end
    })

    Tab:CreateSlider({
        Name = "Kill Aura Range",
        Range = {1, 30},
        Increment = 1,
        Suffix = " studs",
        CurrentValue = Settings.KillAura.Range,
        Flag = "ShnickerKillAuraRange",
        Callback = function(value)
            Settings.KillAura.Range = value
        end
    })

    print("[Shnicker Ware] KillAura.lua loaded successfully")

end
