
addEvent("gra.cPersonalSettings.set", true, true)

local playersSettings = {}

cPersonalSettings = {}

addEventHandler("onResourceStart", resourceRoot,
	function()
		for i, player in ipairs(getElementsByType("player")) do
			playersSettings[player] = {}
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function()
		playersSettings[source] = {}
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		playersSettings[source] = nil
	end
)

addEventHandler("gra.cPersonalSettings.set", root,
	function(setting, value)
		local client = client
		if not playersSettings[client] then return warn(eventName..": client '"..getPlayerName(client).."' not found in table", 0) and false end
		if not setting then return warn(eventName..": invalid setting '"..tostring(setting).."'", 0) and false end

		playersSettings[client][setting] = value
	end
)

function cPersonalSettings.get(player, setting)
	if not scheck("u:element:player|u:element:root|u:element:console,s") then return false end
	if not playersSettings[player] then return nil end

	return playersSettings[player][setting]
end
