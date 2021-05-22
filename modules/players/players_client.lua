
mPlayers = {}

function mPlayers.init()

	mPlayers.data = {}
	mPlayers.aclGroups = {}

	addEventHandler("onClientPlayerQuit", root, mPlayers.onQuit)

	cSync.addHandler("Players.data", mPlayers.sync.data)
	cSync.addHandler("Players.list", mPlayers.sync.list)
	cSync.addHandler("Players.groups", mPlayers.sync.groups)
	
	mPlayers.gui.init()

	cSync.request("Players.list")
	cSync.request("Players.groups")

	return true
end

function mPlayers.term()

	removeEventHandler("onClientPlayerQuit", root, mPlayers.onQuit)

	cSync.removeHandler("Players.data", mPlayers.sync.data)
	cSync.removeHandler("Players.list", mPlayers.sync.list)
	cSync.removeHandler("Players.groups", mPlayers.sync.groups)

	mPlayers.gui.term()
	
	return true
end

cModules.register(mPlayers, "general.players")

function mPlayers.onQuit()

	mPlayers.data[source] = nil

end

function mPlayers.getBySerial(serial)

	for i, player in ipairs(getElementsByType("player")) do
		if mPlayers.data[player].serial == serial then return player  end
	end
	return nil
end

mPlayers.sync = {}

function mPlayers.sync.data(player, data)
	if not isElement(player) then return end

	if not mPlayers.data[player] then mPlayers.data[player] = {} end

	table.merge(mPlayers.data[player], data)
	mPlayers.gui.refreshPlayer(player)

end

function mPlayers.sync.list(data)

	mPlayers.data = data
	mPlayers.gui.refreshPlayer()

end

function mPlayers.sync.groups(groups)

	mPlayers.aclGroups = groups
	mPlayers.gui.refreshGroups()

end