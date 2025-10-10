-- track cooldowns, get proper ability info etc.
local DASH_TIME = 0.15
local DASH_DISTANCE = 8
local COOLDOWN = 3
local CONSECUTIVE_LIMIT = 2

local consecutiveDashes = 0

-- TODO: listen to data changes to change "constants"

return function()
	if consecutiveDashes >= CONSECUTIVE_LIMIT then
		return
	end

	local player = game.Players.LocalPlayer
	local character = player.Character

	if not character then
		return
	end

	if character:GetAttribute("State") == "Dashing" then
		return
	end

	local manager: ControllerManager? = character:FindFirstChild("ControllerManager")
	if not manager then
		return
	end

	local moveVectorValue = character:FindFirstChild("MoveVector")
	if not moveVectorValue then
		return
	end

	character:SetAttribute("State", "Dashing")
	character:SetAttribute("MovementLocked", true)
	local moveVector = moveVectorValue.Value
	manager.FacingDirection = moveVector
	manager.MovingDirection = moveVector
	manager.BaseMoveSpeed = DASH_DISTANCE / DASH_TIME

	consecutiveDashes += 1
	if consecutiveDashes == CONSECUTIVE_LIMIT then
		task.delay(COOLDOWN, function()
			consecutiveDashes = 0
		end)
	end

	task.delay(DASH_TIME + 0.05, function()
		character:SetAttribute("State", nil)
		manager.BaseMoveSpeed = 16
		character:SetAttribute("MovementLocked", false)
	end)
end
