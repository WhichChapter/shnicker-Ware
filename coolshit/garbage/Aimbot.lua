--[[
    Shnicker Ware - Aimbot Module (Bow & Projectile Aimbot)
]]

return function(Shared)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = Shared.UserInputService
	local RunService = Shared.RunService
	local Players = Shared.Players
	local LocalPlayer = Shared.LocalPlayer
	local WorkSpace = workspace
	local Camera = WorkSpace.CurrentCamera

	local ProjectileRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("ProjectileFire")
	local ProjectileMeta = require(ReplicatedStorage.TS.projectile["projectile-meta"]).ProjectileMeta
	local InventoryUtil = require(ReplicatedStorage.TS.inventory["inventory-util"]).InventoryUtil
	local ItemTable = debug.getupvalue(require(ReplicatedStorage.TS.item["item-meta"]).getItemMeta, 1)

	local function GetInventory(player)
		return InventoryUtil.getInventory(player)
	end

	local function IsAlive(player)
		return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.PrimaryPart and player.Character:GetAttribute("Health") > 0
	end

	local function FindNearestEntity(maxDistance)
		local maxDist = maxDistance or math.huge
		local nearestEntity = nil
		local nearestDist = maxDist

		for _, v in ipairs(Players:GetPlayers()) do
			if IsAlive(v) and v ~= LocalPlayer and v.Team ~= LocalPlayer.Team then
				local dist = (v.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearestEntity = v.Character
				end
			end
		end
		return nearestEntity, nearestDist
	end

	local function GetBow()
		local bestBow, bestDamage = nil, 0
		for _, v in ipairs(GetInventory(LocalPlayer).items) do
			if v.itemType:find("bow") then
				local item = ItemTable[v.itemType].projectileSource
				local arrow = item.projectileType("arrow")
				local damage = ProjectileMeta[arrow].combat.damage
				if damage > bestDamage then
					bestDamage = damage
					bestBow = v
				end
			end
		end
		return bestBow
	end

	local function GetItem(name)
		for _, v in ipairs(GetInventory(LocalPlayer).items) do
			if v.itemType:find(name) then
				return v
			end
		end
		return nil
	end

	local function ShootProjectile(item, projectile)
		local nearestEntity = FindNearestEntity(math.huge)
		if nearestEntity and not nearestEntity:FindFirstChildOfClass("ForceField") then
			local args = {
				[1] = item,
				[2] = projectile,
				[3] = projectile,
				[4] = nearestEntity.PrimaryPart.Position,
				[5] = nearestEntity.PrimaryPart.Position,
				[6] = Vector3.new(0, -25, 0),
				[7] = HttpService:GenerateGUID(true),
				[8] = {["drawDurationSeconds"] = 0.96, ["shotId"] = HttpService:GenerateGUID(false)},
				[9] = (WorkSpace:GetServerTimeNow() - 0.11)
			}
			ProjectileRemote:InvokeServer(unpack(args))
		end
	end

	local HttpService = game:GetService("HttpService")
	local toolCheckValue = false

	local mod = Shared.CurrentTab:CreateModule({
		Name = "Aimbot",
		Callback = function(enabled)
			if enabled then
				task.spawn(function()
					while mod.Enabled and task.wait(0.1) do
						if IsAlive(LocalPlayer) then
							local nearestEntity, nearestDist = FindNearestEntity(math.huge)
							if nearestEntity and not nearestEntity:FindFirstChildOfClass("ForceField") then
								local bestBow = GetBow()
								if bestBow and nearestDist > 18 then
									local bowItem = GetItem(bestBow.itemType)
									if bowItem and GetItem("arrow") then
										ShootProjectile(ReplicatedStorage.Inventories:FindFirstChild(LocalPlayer.Name):FindFirstChild(bestBow.itemType), "arrow")
									end
								elseif not bestBow then
									if GetItem("fireball") then
										ShootProjectile(ReplicatedStorage.Inventories:FindFirstChild(LocalPlayer.Name):FindFirstChild("fireball"), "fireball")
									elseif GetItem("snowball") then
										ShootProjectile(ReplicatedStorage.Inventories:FindFirstChild(LocalPlayer.Name):FindFirstChild("snowball"), "snowball")
									end
								end
							end
						end
					end
				end)
			end
		end
	})

	mod:CreateToggle({
		Name = "Tool Check",
		Default = false,
		Callback = function(v)
			toolCheckValue = v
		end
	})
end
