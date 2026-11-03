--[[
    Shnicker Ware - Speed Module
]]

return function(Shared)
	local RunService = Shared.RunService
	local LocalPlayer = Shared.LocalPlayer
	local speedValue = 23

	local mod = Shared.CurrentTab:CreateModule({
		Name = "Speed",
		Callback = function(enabled)
			if enabled then
				task.spawn(function()
					while mod.Enabled and task.wait() do
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
							if hum and hum.MoveDirection.Magnitude > 0 then
								LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (hum.MoveDirection * (speedValue * 0.05))
							end
						end
					end
				end)
			end
		end
	})

	mod:CreateSlider({
		Name = "Speed Value",
		Min = 16,
		Max = 35,
		Default = 23,
		Decimals = 1,
		Callback = function(v)
			speedValue = v
		end
	})
end
