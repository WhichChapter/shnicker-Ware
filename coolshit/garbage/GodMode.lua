--[[
    Shnicker Ware - Godmode Module
]]

return function(Shared)
	local Players = Shared.Players
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LocalPlayer = Shared.LocalPlayer

	local WandBubbleProtectionRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("WandBubbleProtection")
	local WandHealPlayerRemote = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("WandHealPlayer")

	local function IsAlive(plr)
		return plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.PrimaryPart and plr.Character:GetAttribute("Health") > 0
	end

	Shared.CurrentTab:CreateModule({
		Name = "God Mode",
		Callback = function(enabled)
			task.spawn(function()
				while enabled and task.wait(0.5) do
					if IsAlive(LocalPlayer) then
						pcall(function()
							WandBubbleProtectionRemote:InvokeServer({
								["targetPlayerUserId"] = LocalPlayer.UserId,
								["handItem"] = {
									["itemSkin"] = "",
									["itemType"] = "villain_protector_wand",
									["amount"] = 9999,
									["addedToBackpackTime"] = 0,
									["tool"] = ReplicatedStorage.Items.villain_protector_wand,
								},
							})
							if LocalPlayer.Character:GetAttribute("Health") < 95 then
								WandHealPlayerRemote:InvokeServer({
									["targetPlayerUserId"] = LocalPlayer.UserId,
									["handItem"] = {
										["itemSkin"] = "",
										["itemType"] = "villain_protector_wand",
										["amount"] = 9999,
										["addedToBackpackTime"] = 0,
										["tool"] = ReplicatedStorage.Items.villain_protector_wand,
									},
								})
							end
						end)
					end
				end
			end)
		end
	})
end
