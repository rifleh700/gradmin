
mPlayers = {}

function mPlayers.init()

	mPlayers.gradminACLGroups = mPlayers.getGradminACLGroups()
	mPlayers.data = {}
	for i, player in ipairs(getElementsByType("player")) do
		mPlayers.data[player] = mPlayers.getData(player)
	end

	addEventHandler("onPlayerJoin", root, mPlayers.onJoin)
	addEventHandler("onPlayerQuit", root, mPlayers.onQuit)
	addEventHandler("onPlayerLogin", root, mPlayers.onRelogin)
	addEventHandler("onPlayerLogout", root, mPlayers.onRelogin)
	addEventHandler("onPlayerMute", root, mPlayers.onMute)
	addEventHandler("onPlayerUnmute", root, mPlayers.onUnmute)
	addEventHandler("onPlayerCountryDetect", root, mPlayers.onCountryDetect)
	addEventHandler("gra.onAclAnyChange", root, mPlayers.onAclAnyChange)

	cSync.register("Players.data", "general.players")
	cSync.register("Players.list", "general.players")
	cSync.register("Players.groups", "general.players")

	cSync.registerResponder("Players.data", mPlayers.sync.data)
	cSync.registerResponder("Players.list", mPlayers.sync.list)
	cSync.registerResponder("Players.groups", mPlayers.sync.groups)

	return true
end

cModules.register(mPlayers)

function mPlayers.onJoin()

	local data = mPlayers.getData(source)
	mPlayers.data[source] = data
	cSync.send(root, "Players.data", source, data)

end

function mPlayers.onQuit()
	
	mPlayers.data[source] = nil

end

function mPlayers.onRelogin(previousAccount, currentAccount)

	local account = getPlayerAccountName(source) or false
	local groups = mPlayers.getACLGroups(source)
	mPlayers.data[source].account = account
	mPlayers.data[source].groups = groups
	cSync.send(root, "Players.data", source, {account = account, groups = groups})

end

function mPlayers.onMute()
	
	mPlayers.data[source].mute = true
	cSync.send(root, "Players.data", source, {mute = true})

end

function mPlayers.onUnmute()
	
	mPlayers.data[source].mute = false
	cSync.send(root, "Players.data", source, {mute = false})

end

function mPlayers.onCountryDetect(iso, name)

	mPlayers.data[source].country = iso
	mPlayers.data[source].countryname = name
	cSync.send(root, "Players.data", source, {country = iso, countryname = name})

end

function mPlayers.onAclAnyChange()

	local newGroups = mPlayers.getGradminACLGroups()
	if not table.equal(newGroups, mPlayers.gradminACLGroups) then
		mPlayers.gradminACLGroups = newGroups
		cSync.send(root, "Players.groups", newGroups)
	end

	for player, data in pairs(mPlayers.data) do
		local newGroups = mPlayers.getACLGroups(player)
		if not table.equal(data.groups, newGroups) then
			data.groups = newGroups
			cSync.send(root, "Players.data", player, {groups = newGroups})
		end
	end

end

function mPlayers.getGradminACLGroups()
	
	local groups = {}
	for i, group in ipairs(aclGroupList()) do
		if not aclGroupIsAuto(group) and hasGroupPermissionTo(group, GENERAL_PERMISSION) then
			table.insert(groups, group)
		end
	end
	return groups
end

function mPlayers.getACLGroups(player)
	
	local groups = {}
	for i, group in ipairs(getObjectACLGroups(player)) do
		groups[i] = aclGroupGetName(group)
	end
	return groups
end

function mPlayers.getData(player)
	
	local data = {}
	data.ip = getPlayerIP(player)
	data.serial = getPlayerSerial(player)
	data.version = getPlayerVersion(player)
	data.account = getPlayerAccountName(player)
	data.groups = mPlayers.getACLGroups(player)
	data.mute = isPlayerMuted(player)
	data.country, data.countryname = getPlayerCountry(player)

	return data
end

mPlayers.sync = {}

function mPlayers.sync.data(player)

	return mPlayers.data[player]
end

function mPlayers.sync.list()
	
	local list = {}
	for i, player in ipairs(getElementsByType("player")) do
		list[player] = mPlayers.sync.data(player)
	end
	return list
end

function mPlayers.sync.groups()
	
	local groups = {}
	for i, group in ipairs(mPlayers.gradminACLGroups) do
		groups[i] = aclGroupGetName(group)
	end
	return groups
end