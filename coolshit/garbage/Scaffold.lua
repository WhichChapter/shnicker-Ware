--[[
    Shnicker Ware - Scaffold Module
]]

return function(Shared)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LocalPlayer = Shared.LocalPlayer
	local expandDist = 2

	local BlockPlacingRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@easy-games"):WaitForChild("block-engine"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("PlaceBlock")
	local InventoryUtil = require(ReplicatedStorage.TS.inventory["inventory-util"]).InventoryUtil
	local ItemTable = debug.getupvalue(require(ReplicatedStorage.TS.item["item-meta"]).getItemMeta, 1)

	local function GetInventory(player)
		return InventoryUtil.getInventory(player)
	end

	local function GetBlock()
		for _, v in next, GetInventory(LocalPlayer).items do
			if ItemTable[v.itemType].block ~= nil and v.itemType:find("wool") then
				return v.itemType
			end
		end
	end

	local function GetServerPosition(pos)
		return Vector3.new(math.round(pos.X / 3), math.round(pos.Y / 3), math.round(pos.Z / 3))
	end

	local mod = Shared.CurrentTab:CreateModule({
		Name = "Scaffold",
		Callback = function(enabled)
			if enabled then
				task.spawn(function()
					while mod.Enabled and task.wait(0.05) do
						local char = LocalPlayer.Character
						if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
							for i = 1, expandDist do
								local targetPos = char.HumanoidRootPart.Position + (char.Humanoid.MoveDirection * (i * 3.3)) - Vector3.new(0, (char.HumanoidRootPart.Size.Y / 2) + (char.Humanoid.HipHeight + 1.5), 0)
								local blockType = GetBlock()
								if blockType then
									pcall(function()
										BlockPlacingRemote:InvokeServer({
											["blockType"] = blockType,
											["blockData"] = 0,
											["position"] = GetServerPosition(targetPos)
										})
									end)
								end
							end
						end
					end
				end)
			end
		end
	})

	mod:CreateSlider({
		Name = "Expand Distance",
		Min = 1,
		Max = 4,
		Default = 2,
		Decimals = 0,
		Callback = function(v)
			expandDist = v
		end
	})
end
