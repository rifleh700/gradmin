
local SWITCH_KEY = "p"

addEvent("gra.switch", true)

cMain = {}

cMain.initialized = false

function cMain.init()
	
	cGUI.init()
	cModules.init()

	bindKey(SWITCH_KEY, "down", SWITCH_COMMAND)
	
	addEventHandler("onClientResourceStop", resourceRoot, cMain.term)

	cMain.initialized = true

	return true
end

function cMain.term()
	
	cMain.initialized = false

	removeEventHandler("onClientResourceStop", resourceRoot, cMain.term)

	unbindKey(SWITCH_KEY, "down", SWITCH_COMMAND)
	
	cModules.term()
	cGUI.term()

	return true
end

function cMain.isInitialized()
	
	return cMain.initialized
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()

		triggerServerEvent("gra.onPlayerReady", localPlayer)
	
	end
)

addEventHandler("gra.switch", localPlayer,
	function()
		if not cMain.initialized then return end

		cGUI.switch()

	end
)

addEventHandler("gra.cSession.onUpdate", localPlayer,
	function(wasadmin, nowadmin)
		if not wasadmin and not nowadmin then return end

		local wasopen = false
		if wasadmin then
			wasopen = cGUI.getVisible()
		end

		if cMain.initialized then cMain.term() end

		if not nowadmin then return cMessages.outputAdmin("your administration rights have been revoked", COLORS.red) end

		cMain.init()

		if wasadmin then
			cMessages.outputAdmin("your administration rights have been updated", COLORS.orange)
			if wasopen then cGUI.show() end
		else
			cMessages.outputAdmin("press "..utf8.upper(SWITCH_KEY).." to open gradmin panel", COLORS.green)
		end

	end
)