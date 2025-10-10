local function initPlayer(player: Player)
	local function initCharacter(character: Model)
		character:AddTag("Character")
	end

	if player.Character then
		initCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		initCharacter(character)
	end)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
do
	local Components = ReplicatedStorage.Common.Components
	for _, comp in Components:GetChildren() do
		local _c = require(comp) :: any
	end

	game.Players.PlayerAdded:Connect(initPlayer)
	for _, player in game.Players:GetPlayers() do
		initPlayer(player)
	end
end
