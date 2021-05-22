
local cache = {}

addEventHandler("onResourceStart", resourceRoot,
	function()
		
		local settings = {}
		local settingsData = getResourceSettingsData()
		for setting, data in pairs(settingsData) do
			settings[setting] = data.current
		end
		
		cache = settings

	end
)

addEventHandler("gra.onPlayerReady", root,
	function()

		triggerClientEvent(source, "gra.cGlobalSettings.load", source, cache)
	
	end
)

addEventHandler("onSettingChange", root,
	function(setting, oldValue, newValue)
		
		local resourceName = getResourceNameFromSetting(setting)
		if not resourceName then return end
	
		local res = getResourceFromName(resourceName)
		if not res then return end
		if res ~= getThisResource() then return end

		local shortSetting = utf8.match(setting, "^.+%.(.+)$")
		local validValue = getResourceSetting(nil, shortSetting)
		cache[shortSetting] = validValue

		for i, player in ipairs(cSessions.getReady()) do
			triggerClientEvent(player, "gra.cGlobalSettings.set", player, shortSetting, validValue)
		end

	end
)