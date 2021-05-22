
local env = {}
for k, v in pairs(_G) do
	env[k] = v
end
env._G = env

_MTA = env