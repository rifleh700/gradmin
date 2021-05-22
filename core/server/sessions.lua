
addEvent("gra.onPlayerReady", true)
addEvent("gra.cSessions.onPlayerUpdate", false)

local readyPlayers = {}
local currentSessions = {}
local sessionsPermissions = {}

cSessions = {}

function cSessions.getPermissions(player)
	
	local permissions = {}
	for gi, group in ipairs(getObjectACLGroups(player)) do
		for ai, acl in ipairs(aclGroupListACL(group)) do
			for irt, rightType in ipairs({"general", "command"}) do
				for ri, right in ipairs(aclListRights(acl, rightType)) do
					if aclGetRight(acl, right) then permissions[right] = true end
				end
			end
		end
	end
	return permissions
end

function cSessions.init()

	addEventHandler("gra.onInitialize", resourceRoot, cSessions.onInitialize)
	addEventHandler("gra.onPlayerReady", root, cSessions.onPlayerReady)
	
	addEventHandler("onPlayerLogin", root, cSessions.onRelogin)
	addEventHandler("onPlayerLogout", root, cSessions.onRelogin)
	addEventHandler("onPlayerQuit", root, cSessions.onQuit)

	addEventHandler("gra.onAclDestroy", root, cSessions.updateCurrent, false)
	addEventHandler("gra.onAclGroupDestroy", root, cSessions.updateCurrent, false)
	addEventHandler("gra.onAclGroupACLAdd", root, cSessions.updateAll, false)
	addEventHandler("gra.onAclGroupACLRemove", root, cSessions.updateCurrent, false)
	addEventHandler("gra.onAclGroupObjectAdd", root, cSessions.updateAll, false)
	addEventHandler("gra.onAclGroupObjectRemove", root, cSessions.updateCurrent, false)
	addEventHandler("gra.onAclRightChange", root, cSessions.updateAll, false)
	addEventHandler("gra.onAclRightRemove", root, cSessions.updateCurrent, false)
	addEventHandler("gra.onAclChange", root, cSessions.updateAll, false)

	return true
end

function cSessions.update(player)
	
	local oldPermissions = sessionsPermissions[player] or {}
	local newPermissions = cSessions.getPermissions(player)
	
	local wasadmin = oldPermissions[GENERAL_PERMISSION]
	local nowadmin = newPermissions[GENERAL_PERMISSION]

	if not wasadmin and not nowadmin then return end
	if table.equal(oldPermissions, newPermissions) then return end

	if nowadmin then
		currentSessions[player] = true
		sessionsPermissions[player] = newPermissions
	else
		currentSessions[player] = nil
		sessionsPermissions[player] = nil
	end

	triggerEvent("gra.cSessions.onPlayerUpdate", player, newPermissions)
	triggerClientEvent(player, "gra.cSession.update", player, newPermissions)

	return true
end

function cSessions.updateCurrent()

	for player in pairs(currentSessions) do
		cSessions.update(player)
	end

	return true
end

function cSessions.updateAll()

	for player in pairs(readyPlayers) do
		cSessions.update(player)
	end

	return true
end

function cSessions.onInitialize()
	
	cSessions.updateAll()

end

function cSessions.onPlayerReady()
	local client = client
	if not client then return warn(eventName..": client not found", 0) and false end
	if source ~= client then return warn(eventName..": source element is not equal client", 0) and false end
	
	readyPlayers[source] = true
	
	if not cMain.isInitialized() then return end

	cSessions.update(source)

end

function cSessions.onRelogin()
	if not readyPlayers[source] then return end

	cSessions.update(source)

end

function cSessions.onQuit()

	currentSessions[source] = nil
	readyPlayers[source] = nil
	sessionsPermissions[source] = nil
	
end

function cSessions.isAdmin(player)
	if not scheck("u:element:player") then return false end

	return currentSessions[player] == true
end

function cSessions.getAdmins(permission)
	if not scheck("?s") then return false end

	local admins = {}
	for admin in pairs(currentSessions) do
		if not permission or permission and sessionsPermissions[admin][permission] then
			table.insert(admins, admin)
		end
	end

	return admins
end

function cSessions.getReady()
	
	local players = {}
	for i, player in ipairs(getElementsByType("player")) do
		if readyPlayers[player] then players[#players + 1] = player end
	end
	return players
end