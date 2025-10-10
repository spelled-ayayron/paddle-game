local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = ReplicatedStorage.Common.Components
for _, comp in Components:GetChildren() do
	local _c = require(comp) :: any
end
