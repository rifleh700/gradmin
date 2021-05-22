
local gradminModules = {}
local initializedModules = {}

cModules = {}

function cModules.register(mdl)
	check("t")
	if type(mdl.init) ~= "function" then return error("module init function not found", 2) end
	if table.index(gradminModules, mdl) then return warn("module is already registered", 2) and false end

	table.insert(gradminModules, mdl)
	
	return true
end

function cModules.init()

	for i, mdl in ipairs(gradminModules) do
		if initializedModules[mdl] then
			warn("module is already initialized", 2)
		else
			mdl.init()
			initializedModules[mdl] = true
		end
	end

	return true
end