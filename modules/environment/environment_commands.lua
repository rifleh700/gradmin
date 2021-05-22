
cCommands.add("setserverocclusions",
	function(admin, enabled)
		enabled = enabled == nil and true or enabled
		if not setOcclusionsEnabled(enabled) then return false end
		
		return true,
			"occlusions have been "..(enabled and "enabled" or "disabled")
	end,
	"[enabled(yes/no):b", "enable or disable occlusions", COLORS.blue
)

cCommands.add("setserverfarclipdistance",
	function(admin, distance)
		if distance then
			if distance < 0 or distance > 10000 then return false, "distance must be between 0 and 10000" end
			if not setFarClipDistance(distance) then return false end
		else
			if not resetFarClipDistance() then return false end
		end

		return true,
			"server far clip distance now is "..(distance or "default"),
			"Server far clip distance has been set to "..(distance or "default").." by $admin"
	end,
	"[distance:n", "set the distance of render", COLORS.blue
)

cCommands.add("setserverfogdistance",
	function(admin, distance)
		if distance then
			if not setFogDistance(distance) then return false end
		else
			if not resetFogDistance() then return false end
		end

		return true,
			"server fog distance now is "..(distance or "default"),
			"Server fog distance has been set to "..(distance or "default").." by $admin"

	end,
	"[distance:n", "set the distance at which fog appears", COLORS.blue
)

cCommands.add("setserverweather",
	function(admin, id)
		id = id or math.random(0, 255)
		if not setWeather(id) then return false end

		return true,
			"weather now is "..formatNameID(getWeatherName(id), id),
			"Weather has been set to "..formatNameID(getWeatherName(id), id).." by $admin"
	end,
	"[weatherID:byte|weather-name:wrn", "set the current weather", COLORS.blue
)

cCommands.add("blendserverweather",
	function(admin, id)
		id = id or math.random(0, 255)
		if not setWeatherBlended(id) then return false end

		return true,
			"blending weather to "..formatNameID(getWeatherName(id), id),
			"Weather has been blended to "..formatNameID(getWeatherName(id), id).." by $admin"
	end,
	"[weatherID:byte|weather-name:wrn", "change the current weather to another in a smooth manner, over the period of 1-2 in-game hours", COLORS.blue
)

cCommands.add("setservertime",
	function(admin, hours, minutes)
		hours = hours or 12
		minutes = minutes or 0
		if hours > 23 or hours < 0 then hours = 0 end
		if minutes > 59 or minutes < 0 then minutes = 0 end
		if not setTime(hours, minutes) then return false end

		iprint(getTime())

		return true,
			"game time now is "..formatGameTime(hours, minutes),
			"Game time has been set to "..formatGameTime(hours, minutes).." by $admin" 
	end,
	"[hours:n,minutes:n", "set the current GTA time", COLORS.blue
)

cCommands.add("setserverminuteduration",
	function(admin, seconds)
		seconds = math.clamp(seconds or 1, 0.001, parseDuration("1hour"))

		if not setMinuteDuration(math.round(seconds*1000)) then return false end

		return true,
			"minute duration now is "..formatDuration(seconds),
			"Minute duration has been set to "..formatDuration(seconds).." by $admin"
	end,
	"[seconds-in-minute:n", "set the real-world duration of an ingame minute", COLORS.blue
)

cCommands.add("setserverclouds",
	function(admin, enabled)
		enabled = enabled == nil and true or enabled
		if not setCloudsEnabled(enabled) then return false end

		local stateInfo = enabled and "enabled" or "disabled"
		return true,
			"clouds have been "..stateInfo,
			"Clouds have been "..stateInfo.." by $admin"
	end,
	"[enabled(yes/no):b", "enable or disable clouds", COLORS.blue
)

cCommands.add("setserverrainlevel",
	function(admin, level)
		if not level then
			if not resetRainLevel() then return false end
		else
			if level < 0 or level > 10 then return false, "level must be between 0 and 10" end
			if not setRainLevel(level) then return false end
		end

		return true,
			"rain level now is "..(level or "default"),
			"Rain level has been set to "..(level or "default").." by $admin"
	end,
	"[level(0-10):n", "sets the rain level", COLORS.blue
)

cCommands.add("setserverskygradient",
	function(admin, topR, topG, topB, botR, botG, botB)
		if not topR then
			if not resetSkyGradient() then return false end
		else
			if not setSkyGradient(topR, topG, topB, botR, botG, botB) then return false end
		end

		local colorInfo = topR and "changed" or "restored" 
		return true,
			"sky gradient has been "..colorInfo,
			"Sky gradient has been "..colorInfo.." by $admin"
	end,
	"[top-R:byte,top-G:byte,top-B:byte,bottom-R:byte,bottom-G:byte,bottom-B:byte", "sets the sky color to a two-color gradient", COLORS.blue
)

cCommands.add("setservermoonsize",
	function(admin, size)
		if not size then
			if not resetMoonSize() then return false end
		else
			if size < 0 then return false, "size must be positive" end
			if not setMoonSize(size) then return false end
		end

		return true,
			"moon size now is "..(size or "default"),
			"Moon size has been set to "..(size or "default").." by $admin"
	end,
	"[size:n", "sets the moon size", COLORS.blue
)

cCommands.add("setserversunsize",
	function(admin, size)
		if not size then
			if not resetSunSize() then return false end
		else
			if not setSunSize(size) then return false end
		end

		return true,
			"sun size now is "..(size or "default"),
			"Sun size has been set to "..(size or "default").." by $admin"
	end,
	"[size:n", "sets the sun size", COLORS.blue
)

cCommands.add("setserversuncolor",
	function(admin, r1, g1, b1, r2, g2, b2)
		if not r1 then
			if not resetSunColor() then return false end
		else
			if not setSunColor(r1, g1, b1, r2, g2, b2) then return false end
		end

		local stateInfo = r1 and "changed" or "restored"
		return true,
			"sun color was "..stateInfo,
			"Sun color has been "..stateInfo.." by $admin"
	end,
	"[R:byte,G:byte,B:byte,R2:byte,G2:byte,B2:byte", "sets the color of the sun", COLORS.blue
)

cCommands.add("setserverblurlevel",
	function(admin, level)
		if not level then
			if not resetBlurLevel() then return false end
		else
			if not setBlurLevel(level) then return false end
		end

		return true,
			"blur level now is "..(level or "default"),
			"Blur level has been set to "..(level or "default").." by $admin"
	end,
	"[level:byte", "sets the motion blur level on the clients screen", COLORS.blue
)

cCommands.add("setserverheathaze",
	function(admin, level)
		if not level then
			if not resetHeatHaze() then return false end
		else
			if not setHeatHaze(level) then return false end
		end

		return true,
			"heat haze level now is "..(level or "default"),
			"Heat haze level has been set to "..(level or "default").." by $admin"
	end,
	"[level:byte", "sets the heat haze effect level", COLORS.blue
)

cCommands.add("setserverwaveheight",
	function(admin, height)
		height = height or 0
		if height < 0 or height > 100 then return false, "height must be between 0 and 100" end
		
		if not setWaveHeight(height) then return false end
		
		return true,
			"waves height now is "..height,
			"Waves height has been set to "..height.." by $admin"
	end,
	"[height:n", "sets the wave height", COLORS.blue
)

cCommands.add("setserverwatercolor",
	function(admin, r, g, b, a)
		if not r then
			if not resetWaterColor() then return false end
		else
			if not g then g = 255 end
			if not b then b = 255 end
			if not setWaterColor(r, g, b, a) then return false end
		end

		local stateInfo = r and "changed" or "restored"
		return true,
			"water color was "..stateInfo,
			"Water color has been "..stateInfo.." by $admin"
	end,
	"[R:byte,G:byte,B:byte,A:byte", "sets the water color", COLORS.blue
)

cCommands.add("lockservertrafficlights",
	function(admin, locked)
		if locked == nil then locked = false end
		if not setTrafficLightsLocked(locked) then return false end

		local stateInfo = locked and "locked" or "unlocked"
		return true,
			"traffic lights now are "..stateInfo,
			"Traffic lights have been "..stateInfo.." by $admin"
	end,
	"[locked(yes/no):b", "toggles whether you want the traffic lights to be locked", COLORS.blue
)

cCommands.add("setservertrafficlightstate",
	function(admin, state)
		if not state then
			if not setTrafficLightState("auto") then return false end
		else
			if state < 0 or state > 9 then return false, "state must be between 0 and 9" end
			if not setTrafficLightState(state) then return false end
		end

		return true,
			"traffic lights state now is "..(state or "auto"),
			"Traffic lights state has been set to "..(state or "auto").." by $admin"
	end,
	"[state(0-9):n", "sets the current traffic light state", COLORS.blue
)