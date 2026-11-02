--[added module start]
run(function()
	local NoKnockback = {Enabled = false}
	local NoKnockbackHorizontal = {Value = 0}
	local NoKnockbackVertical = {Value = 0}
	local oldvelocitymethod

	NoKnockback = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "NoKnockback",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("NoKnockback", function()
					if entityLibrary.isAlive then
						local rootPart = entityLibrary.character.HumanoidRootPart
						local currentVel = rootPart.Velocity
						local horizVal = NoKnockbackHorizontal.Value / 100
						local vertVal = NoKnockbackVertical.Value / 100
						
						-- If you want custom hook/velocity manipulation or standard zeroing/scaling:
						if currentVel.Y < 0 then
							-- Keeps regular fall velocity, scales horizontal/vertical push
							rootPart.Velocity = Vector3.new(currentVel.X * horizVal, currentVel.Y * vertVal, currentVel.Z * horizVal)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("NoKnockback")
			end
		end,
		HoverText = "Prevents you from taking knockback."
	})

	NoKnockbackHorizontal = NoKnockback.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 100,
		Default = 0,
		Function = function() end
	})

	NoKnockbackVertical = NoKnockback.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 100,
		Default = 0,
		Function = function() end
	})
end)
--[added module end]
