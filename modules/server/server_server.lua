
addEvent("gra.mServer.onPasswordChange", false)
addEvent("gra.mServer.onGameTypeChange", false)
addEvent("gra.mServer.onFPSLimitChange", false)
addEvent("gra.mServer.onGlitchChange", false)

mServer = {}

function mServer.init()

	cSync.register("Server.data", "general.server")
	cSync.register("Server.list", "general.server")

	cSync.registerResponder("Server.data", mServer.getSetting)
	cSync.registerResponder("Server.list", mServer.getSettings)

	addEventHandler("gra.mServer.onPasswordChange", root, function () cSync.callResponder(root, "Server.data", "password") end)
	addEventHandler("gra.mServer.onGameTypeChange", root, function() cSync.callResponder(root, "Server.data", "game") end)
	addEventHandler("gra.mServer.onFPSLimitChange", root, function() cSync.callResponder(root, "Server.data", "fps") end)
	addEventHandler("gra.mServer.onGlitchChange", root, function() cSync.callResponder(root, "Server.data", "glitches") end)
	
	return true
end

cModules.register(mServer)

function mServer.getSettings()
	local settings = {}
	settings.name = getServerName()
	settings.players = getMaxPlayers()
	settings.version = getVersion()
	settings.ip = getServerConfigSetting("serverip")
	settings.port = getServerPort()
	settings.httpPort = getServerHttpPort()
	settings.minClientVersion = getServerConfigSetting("minclientversion")
	settings.password = getServerPassword()
	settings.game = getGameType()
	settings.fps = getFPSLimit() 
	settings.glitches = {}
	for i, glitch in ipairs(getValidGlitches()) do
		settings.glitches[glitch] = isGlitchEnabled(glitch)
	end
	return settings
end

function mServer.getSetting(setting)
	return mServer.getSettings()[setting]
end