local commands = {}

for _, v in script:GetChildren() do
	commands[v.Name] = require(v) :: any
end

return commands
