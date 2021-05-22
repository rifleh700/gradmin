
addEvent("gra.cGlobalSettings.load", true, true)
addEvent("gra.cGlobalSettings.set", true, true)

local cache = {}

cGlobalSettings = {}

addEventHandler("gra.cGlobalSettings.load", localPlayer,
	function(settings)
		cache = settings
	end
)

addEventHandler("gra.cGlobalSettings.set", localPlayer,
	function(setting, value)
		cache[setting] = value
	end
)

function cGlobalSettings.get(setting)
	if not scheck("s") then return false end

	return cache[setting]
end