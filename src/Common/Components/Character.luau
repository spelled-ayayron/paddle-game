local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)

local CharacterComponent = Component.new({
	Tag = "Character",
	Ancestors = { workspace },
})

function CharacterComponent:Construct() end

function CharacterComponent:Start()
	local character = self.Instance :: Model
	if RunService:IsServer() then
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		humanoid.EvaluateStateMachine = false

		-- create ControllerManager
		local manager = Instance.new("ControllerManager")

		local groundSensor = Instance.new("ControllerPartSensor")
		groundSensor.SearchDistance = humanoid.HipHeight + 1
		groundSensor.Parent = character.PrimaryPart
		manager.GroundSensor = groundSensor

		local groundController = Instance.new("GroundController")
		groundController.GroundOffset = humanoid.HipHeight
		groundController.Parent = manager

		local airController = Instance.new("AirController")
		airController.Parent = manager

		manager.BaseTurnSpeed = 16
		manager.ActiveController = groundController
		manager.RootPart = character.PrimaryPart
		manager.Parent = character

		local paddle = ReplicatedStorage.Assets.Paddles.Base:Clone()
		local rigid = Instance.new("RigidConstraint")
		rigid.Attachment0 = character:FindFirstChild("RightGripAttachment", true) :: Attachment
		rigid.Attachment1 = paddle:FindFirstChild("RightGripAttachment", true) :: Attachment
		rigid.Parent = paddle
		paddle.Parent = character
	else
		-- setup input bindings instead
		local LocalPlayer = game.Players.LocalPlayer
		local Commands = require(ReplicatedStorage.Client.Commands)

		local manager = character:WaitForChild("ControllerManager") :: ControllerManager
		local playContext = LocalPlayer:WaitForChild("PlayerGui").PlayContext

		local moveDir = Vector3.zero
		local movementAction: InputAction = playContext:WaitForChild("Movement")
		movementAction.StateChanged:Connect(function(vec: Vector2)
			local input = Vector3.new(vec.X, 0, -vec.Y)
			moveDir = input
		end)

		local moveVectorValue = Instance.new("Vector3Value")
		moveVectorValue.Name = "MoveVector"
		moveVectorValue.Value = Vector3.zero
		moveVectorValue.Parent = character

		RunService.PostSimulation:Connect(function(a0: number)
			local camera = workspace.CurrentCamera
			if not camera then
				return
			end

			local _, cameraY, _ = camera.CFrame:ToOrientation()
			local rotatedMoveVector = CFrame.fromOrientation(0, cameraY, 0):VectorToWorldSpace(moveDir)
			moveVectorValue.Value = rotatedMoveVector
			local locked = character:GetAttribute("MovementLocked")
			if locked then
				return
			end

			manager.MovingDirection = rotatedMoveVector
			manager.FacingDirection = rotatedMoveVector
		end)

		local dashAction: InputAction = playContext:WaitForChild("Dash")
		dashAction.Pressed:Connect(Commands.Dash)
	end

	print("CharacterComponent initialized")
end

return CharacterComponent
