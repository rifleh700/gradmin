
local CHECK_SETTINGS_INTERVAL = 2 * 10^3

addEvent("gra.mEnv.onSettingChange", false)

local mEnv = {}

mEnv.settings = {}

function mEnv.init()

	cSync.register("Env.data", "general.environment", {irregular = true})
	cSync.register("Env.list", "general.environment", {irregular = true})

	cSync.registerResponder("Env.data", mEnv.sync.data)
	cSync.registerResponder("Env.list", mEnv.sync.list, {auto = true})

	addEventHandler("gra.mEnv.onSettingChange", resourceRoot, function(setting, value) cSync.send(root, "Env.data", setting, value) end)

	mEnv.settings = mEnv.getSettings()
	setTimer(mEnv.checkSettings, CHECK_SETTINGS_INTERVAL, 0)

	return true
end

cModules.register(mEnv)

function mEnv.getSettings()

	local settings = {}

	settings.occlusions = getOcclusionsEnabled()
	settings.farClipDistanse = getFarClipDistance()
	settings.fogDistance = getFogDistance()

	settings.time = table.pack(getTime())
	settings.weather = getWeather()
	settings.minuteDuration = getMinuteDuration()
	settings.clouds = getCloudsEnabled()
	settings.rainLevel = getRainLevel()
	settings.blur = getBlurLevel()

	settings.skyGradient = table.pack(getSkyGradient())

	settings.moonSize = getMoonSize()
	settings.sunSize = getSunSize()
	settings.sunColor = table.pack(getSunColor())

	settings.heatHaze = getHeatHaze()
	settings.waveHeight = getWaveHeight()

	settings.waterColor = table.pack(getWaterColor())
	
	settings.trafficLights = areTrafficLightsLocked()
	settings.trafficLightsState = getTrafficLightState()
	
	return settings
end

function mEnv.getSetting(setting)
	return mEnv.getSettings()[setting]
end

function mEnv.checkSettings()
	for setting, value in pairs(mEnv.getSettings()) do
		if not table.equal(value, mEnv.settings[setting]) then
			mEnv.settings[setting] = value
			triggerEvent("gra.mEnv.onSettingChange", resourceRoot, setting, value)
		end
	end
end

mEnv.sync = {}

function mEnv.sync.data(setting)

	return mEnv.settings[setting]
end

function mEnv.sync.list()
	
	return mEnv.settings
end