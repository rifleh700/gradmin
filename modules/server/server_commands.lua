
cCommands.add("setserverpassword",
	function(admin, password)
		if password == "" then return false, "1 character min" end
		if password and utf8.len(password) > 32 then return false, "32 characters max" end
		
		if not setServerPassword(password) then return false end
		triggerEvent("gra.mServer.onPasswordChange", root)

		if not password then return true, "server password has been reset" end
		return true,
			"server password now is '"..password.."'"
	end,
	"[password:s", "set server password"
)

cCommands.add("setservergametype",
	function(admin, gameType)

		gameType = gameType or false
		if not setGameType(gameType) then return false end
		triggerEvent("gra.mServer.onGameTypeChange", root, gameType)

		return true,
			"ASE gamemode info has been changed to "..(gameType or "default")
	end,
	"[game-type:s", "set ASE gamemode info"
)

cCommands.add("setserverfpslimit",
	function(admin, fps)

		fps = fps and math.clamp(math.floor(fps), 25, 100) or 36
		if not setFPSLimit(fps) then return false end
		triggerEvent("gra.mServer.onFPSLimitChange", root, fps)
		
		return true,
			"server FPS limit now is "..fps,
			"Server FPS limit has been set to "..fps.." by $admin"
	end,
	"[fps:n", "set server fps limit", COLORS.orange
)

cCommands.add("setserverglitch",
	function(admin, glitch, enabled)
		if isGlitchEnabled(glitch) == enabled then return false, "glitch is already "..(enabled and "enabled" or "disabled") end
		
		if not setGlitchEnabled(glitch, enabled) then return false end
		triggerEvent("gra.mServer.onGlitchChange", root, glitch, enabled)
		
		local stateInfo = enabled and "enabled" or "disabled"
		return true,
			"glitch "..getGlitchName(glitch).." has been "..stateInfo,
			"Glitch "..getGlitchName(glitch).." has been "..stateInfo.." by $admin"
	end,
	"glitch:s,enabled(yes/no):b", "enable or disable glitches that are found in the original Single Player game", COLORS.orange
)

cCommands.addHardCoded("shutdown",
	function(admin, reason)
		setTimer(shutdown, 500, 1, reason)
		return true, "server has been shutdown"..(reason and " ("..reason..")" or "")
	end,
	COLORS.orange
)