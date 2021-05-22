
local gradminModules = {}
local modulePermissions = {}
local initializedModules = {}

cModules = {}

function cModules.register(mdl, permission)
	check("t,s")
	if type(mdl.init) ~= "function" then return error("module init function not found", 2) end
	if type(mdl.term) ~= "function" then return error("module term function not found", 2) end
	if table.index(gradminModules, mdl) then return warn("module is already registered", 2) and false end

	table.insert(gradminModules, mdl)
	modulePermissions[mdl] = permission
	
	return true
end

function cModules.init()

	for i, mdl in ipairs(gradminModules) do
		if cSession.hasPermissionTo(modulePermissions[mdl]) then
			if initializedModules[mdl] then
				warn("module is already initialized", 2)
			else
				mdl.init()
				initializedModules[mdl] = true
			end
		end
	end

	return true
end

function cModules.term()

	for i = #gradminModules, 1, -1 do
		local mdl = gradminModules[i]
		if initializedModules[mdl] then
			mdl.term()
			initializedModules[mdl] = nil
		end
	end
	
	return true
end