
addEvent("gra.onInitialize", false)

cMain = {}

cMain.initialized = false

function cMain.init()
	
	if not cMain.hasPermissions() then return cMessages.outputDebug("resource has no rights, please use command and restart resource: /aclrequest allow "..RESOURCE_NAME.." all", COLORS.yellow) and false end

	if not cAcl.init() then return cMessages.outputDebug("ACL component initializing failed", COLORS.yellow) and false end
	if not cCommands.init() then return cMessages.outputDebug("Commands component initializing failed", COLORS.yellow) and false end
	if not cSessions.init() then return cModules.outputDebug("Sessions component initializing failed", COLORS.yellow) and false end
	if not cModules.init() then return cModules.outputDebug("Modules component initializing failed", COLORS.yellow) and false end

	addCommandHandler(SWITCH_COMMAND, cMain.onCommand, true)

	cMain.initialized = true
	
	triggerEvent("gra.onInitialize", resourceRoot)

	return true
end

function cMain.hasPermissions()
	
	local requests = getResourceACLRequests(RESOURCE)
	for i, request in ipairs(requests) do
		if not hasObjectPermissionTo("resource."..RESOURCE_NAME, request.name) then return false end
	end
	return true
end

function cMain.onCommand(player)
	if not hasObjectPermissionTo(player, GENERAL_PERMISSION) then return end

	triggerClientEvent(player, "gra.switch", player)

end

function cMain.isInitialized()
	
	return cMain.initialized
end

addEventHandler("onResourceStart", resourceRoot,
	function()

		if not cMain.init() then cMessages.outputDebug("initializing failed", COLORS.yellow) end
	
	end,
	false
)