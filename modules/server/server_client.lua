
mServer = {}

function mServer.init()

	mServer.data = {}
	
	cSync.addHandler("Server.data", mServer.sync.data)
	cSync.addHandler("Server.list", mServer.sync.list)

	mServer.gui.init()

	cSync.request("Server.list")

	return true
end

function mServer.term()
	
	cSync.removeHandler("Server.data", mServer.sync.data)
	cSync.removeHandler("Server.list", mServer.sync.list)
	
	mServer.gui.term()
	
	return true
end

cModules.register(mServer, "general.server")

mServer.sync = {}

function mServer.sync.data(setting, data)
	mServer.data[setting] = data
	mServer.gui.refresh()
end

function mServer.sync.list(data)
	mServer.data = data
	mServer.gui.refresh()
end
