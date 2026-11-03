--[[
    Shnicker Ware - Auto Toxic Module
]]

return function(Shared)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = Shared.Players
	local LocalPlayer = Shared.LocalPlayer

	local SendMessageRemote = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")

	local function SendChatMessage(Message)
		local Arguments = {
			[1] = Message,
			[2] = "All"
		}
		SendMessageRemote:FireServer(unpack(Arguments))
	end

	local mod = Shared.CurrentTab:CreateModule({
		Name = "Auto Toxic",
		Callback = function(enabled)
			if enabled then
				-- Listen to player deaths or character removals to trigger toxic messages
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer then
						player.CharacterAdded:Connect(function(char)
							local hum = char:WaitForChild("Humanoid", 5)
							if hum then
								hum.Died:Connect(function()
									if mod.Enabled then
										local randomized = math.random(0, 5)
										local killMessage = ""

										if randomized == 0 then
											killMessage = "You are so bad u died. L " .. player.Name .. " | Shnicker Ware on top"
										elseif randomized == 1 then
											killMessage = "I could probably win without cheats. L " .. player.Name .. " | Shnicker Ware on top"
										elseif randomized == 2 then
											killMessage = "Clowns are the only ones we kill. L " .. player.Name .. " | Shnicker Ware on top"
										elseif randomized == 3 then
											killMessage = "Rats. Imagine dying in a block game. L " .. player.Name .. " | Shnicker Ware on top"
										elseif randomized == 4 then
											killMessage = "I hack for fun. Too bad your fun is ruined. L " .. player.Name .. " | Shnicker Ware on top"
										else
											killMessage = "I ruined a good day for a good reason. L " .. player.Name .. " | Shnicker Ware on top"
										end

										SendChatMessage(killMessage)
									end
								end)
							end
						end)
					end
				end
			end
		end
	})
end
