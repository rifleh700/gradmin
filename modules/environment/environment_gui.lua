
mEnv.gui = {}

function mEnv.gui.timeMatcher(text)
	
	text = utf8.match(text, "%d?%d?:?%d?%d?")
	return text
end

function mEnv.gui.init()

	local tab = cGUI.addTab("Environment")
	mEnv.gui.tab = tab

	local mainHlo = guiCreateHorizontalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, GS.mrg2, false, tab)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetHeightFixed(mainHlo, true)

	local leftVlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainHlo)

	mEnv.gui.occlLbl, mEnv.gui.occlChk = 
		guiCreateKeyValueCheckBox(nil, nil, nil, nil, nil, "Occlusions:", "Enable", nil, leftVlo)
	cGuiGuard.setPermission(mEnv.gui.occlChk, "command.setserverocclusions")

	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	mEnv.gui.fcdLbl, mEnv.gui.fcdVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Far clip dist:", nil, nil, hlo)
	guiLabelSetClickableStyle(mEnv.gui.fcdVLbl, true)
	cGuiGuard.setPermission(mEnv.gui.fcdVLbl, "command.setserverfarclipdistance")

	mEnv.gui.fdLbl, mEnv.gui.fdVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Fog distance:", nil, nil, hlo)
	guiLabelSetClickableStyle(mEnv.gui.fdVLbl, true)
	cGuiGuard.setPermission(mEnv.gui.fdVLbl, "command.setserverfogdistance")

	guiCreateHorizontalSeparator(0, 0, 1, true, leftVlo)
	
	mEnv.gui.weatherLbl, mEnv.gui.weatherVLbl, hlo =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Weather:", nil, nil, leftVlo)
	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	mEnv.gui.weatherEdit, mEnv.gui.weatherList = 
		guiCreateAdvancedComboBox(nil, nil, GS.w3, nil, "", false, vlo)
	for i, id in ipairs(getValidWeathers()) do
		local row = guiGridListAddRow(mEnv.gui.weatherList, formatNameID(getWeatherName(id), id))
		guiGridListSetItemData(mEnv.gui.weatherList, row, 1, id)
	end
	guiGridListAdjustHeight(mEnv.gui.weatherList, 15)
	guiGridListSetSelectedItem(mEnv.gui.weatherList, 0)
	guiGridListSetAutoSearchEdit(mEnv.gui.weatherList, guiGridListCreateSearchEdit(mEnv.gui.weatherList))
	cGuiGuard.setPermission(mEnv.gui.weatherEdit, "command.setserverweather")
	
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mEnv.gui.weatherBlendBtn = guiCreateButton(nil, nil, nil, nil, "Blend", nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.weatherBlendBtn, "command.blendserverweather")
	mEnv.gui.weatherSetBtn = guiCreateButton(nil, nil, nil, nil, "Set", nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.weatherSetBtn, "command.setserverweather")

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	mEnv.gui.timeLbl, mEnv.gui.timeVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Time:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.timeVLbl, "command.setservertime")
	guiLabelSetClickableStyle(mEnv.gui.timeVLbl, true)
	mEnv.gui.mdLbl, mEnv.gui.mdVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Minute dur:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.mdVLbl, "command.setserverminuteduration")
	guiLabelSetClickableStyle(mEnv.gui.mdVLbl, true)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	mEnv.gui.cloudsLbl, mEnv.gui.cloudsChk =
		guiCreateKeyValueCheckBox(nil, nil, nil, nil, nil, "Clouds:", "Enable", nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.cloudsChk, "command.setserverclouds")
	mEnv.gui.rainLbl, mEnv.gui.rainVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Rain level:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.rainVLbl, "command.setserverrainlevel")
	guiLabelSetClickableStyle(mEnv.gui.rainVLbl, true)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	mEnv.gui.blurLbl, mEnv.gui.blurVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Blur level:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.blurVLbl, "command.setserverblurlevel")
	guiLabelSetClickableStyle(mEnv.gui.blurVLbl, true)
	mEnv.gui.heatHazeLbl, mEnv.gui.heatHazeVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Heat haze:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.heatHazeVLbl, "command.setserverheathaze")
	guiLabelSetClickableStyle(mEnv.gui.heatHazeVLbl, true)

	guiCreateHorizontalSeparator(0, 0, 1, true, leftVlo)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	mEnv.gui.skyGradLbl = guiCreateLabel(nil, nil, nil, nil, "Sky gradient:", nil, hlo)
	guiLabelSetHorizontalAlign(mEnv.gui.skyGradLbl, "right")
	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	mEnv.gui.skyGradClrp1 = guiCreateColorPicker(nil, nil, nil, nil, nil, nil, nil, false, vlo)
	mEnv.gui.skyGradClrp2 = guiCreateColorPicker(nil, nil, nil, nil, nil, nil, nil, false, vlo)
	cGuiGuard.setPermission(vlo, "command.setserverskygradient")
	
	mEnv.gui.sunClrLbl = guiCreateLabel(nil, nil, nil, nil, "Sun color:", nil, hlo)
	guiLabelSetHorizontalAlign(mEnv.gui.sunClrLbl, "right")
	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	mEnv.gui.sunClrClrp1 = guiCreateColorPicker(nil, nil, nil, nil, nil, nil, nil, false, vlo)
	mEnv.gui.sunClrClrp2 = guiCreateColorPicker(nil, nil, nil, nil, nil, nil, nil, false, vlo)
	cGuiGuard.setPermission(vlo, "command.setserversuncolor")
	
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	mEnv.gui.sunSizeLbl, mEnv.gui.sunSizeVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Sun size:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.sunSizeVLbl, "command.setserversunsize")
	guiLabelSetClickableStyle(mEnv.gui.sunSizeVLbl, true)
	mEnv.gui.moonSizeLbl, mEnv.gui.moonSizeVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Moon size:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.moonSizeVLbl, "command.setservermoonsize")
	guiLabelSetClickableStyle(mEnv.gui.moonSizeVLbl, true)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	mEnv.gui.waterClrLbl, mEnv.gui.waterClrClrp = 
		guiCreateKeyValueColorPicker(nil, nil, nil, nil, nil, "Water color:", nil, nil, nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.waterClrClrp, "command.setserverwatercolor")
	mEnv.gui.waveHeightLbl, mEnv.gui.waveHeightVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Wave height:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.waveHeightVLbl, "command.setserverwaveheight")
	guiLabelSetClickableStyle(mEnv.gui.waveHeightVLbl, true)

	guiCreateHorizontalSeparator(0, 0, 1, true, leftVlo)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	mEnv.gui.trafficLbl, mEnv.gui.trafficChk = 
		guiCreateKeyValueCheckBox(nil, nil, nil, nil, nil, "Traffic lights:", "Lock", nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.trafficChk, "command.lockservertrafficlights")
	mEnv.gui.trafficStateLbl, mEnv.gui.trafficStateVLbl = 
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Lights state:", nil, nil, hlo)
	cGuiGuard.setPermission(mEnv.gui.trafficStateVLbl, "command.setservertrafficlightstate")
	guiLabelSetClickableStyle(mEnv.gui.trafficStateVLbl, true)

	guiRebuildLayouts(tab)

	---------------------------------

	addEventHandler("onClientGUILeftClick", tab, mEnv.gui.onClick)
	addEventHandler("onClientGUIRightClick", tab, mEnv.gui.onRightClick)
	addEventHandler("onClientGUIColorPickerAccepted", tab, mEnv.gui.onColorAccepted)

	return true
end

function mEnv.gui.term()
		
	destroyElement(mEnv.gui.tab)

	return true
end

function mEnv.gui.onClick()

	if source == mEnv.gui.occlChk then
		cCommands.execute("setserverocclusions", guiCheckBoxGetSelected(mEnv.gui.occlChk))

	elseif source == mEnv.gui.fcdVLbl then
		local fcd = guiShowInputDialog("Far clip distance", "Enter new far clip distance (0 - 10000)", mEnv.data.farClipDistanse, guiGetInputNumericParser(false, 0, 10000), true, guiGetInputNumericMatcher(false, 0, 10000))
		if fcd == false then return end
		cCommands.execute("setserverfarclipdistance", fcd)

	elseif source == mEnv.gui.fdVLbl then
		local fd = guiShowInputDialog("Fog distance", "Enter new fog distance", mEnv.data.fogDistance, guiGetInputNumericParser(), true, guiGetInputNumericMatcher())
		if fd == false then return end
		cCommands.execute("setserverfogdistance", fd)

	elseif source == mEnv.gui.weatherSetBtn then
		cCommands.execute("setserverweather", guiGridListGetSelectedItemData(mEnv.gui.weatherList))

	elseif source == mEnv.gui.weatherBlendBtn then
		cCommands.execute("blendserverweather", guiGridListGetSelectedItemData(mEnv.gui.weatherList))

	elseif source == mEnv.gui.timeVLbl then
		local h, m = table.unpack(mEnv.data.time)
		h, m = guiShowInputDialog("Time", "Enter new time (HH:MM)", h and formatGameTime(h, m) or nil, parseGameTime, true, mEnv.gui.timeMatcher)
		if h == false then return end
		cCommands.execute("setservertime", h, m)

	elseif source == mEnv.gui.mdVLbl then
		local md = guiShowInputDialog("Minute duration", "Enter new minute duration (i.e. 1min, 1s, 10ms) (1hour max)", mEnv.data.minuteDuration and formatDuration(mEnv.data.minuteDuration/1000) or nil, parseDuration, true)
		if md == false then return end

		cCommands.execute("setserverminuteduration", md)

	elseif source == mEnv.gui.cloudsChk then
		cCommands.execute("setserverclouds", guiCheckBoxGetSelected(mEnv.gui.cloudsChk))

	elseif source == mEnv.gui.rainVLbl then
		local level = guiShowInputDialog("Rain level", "Enter new rain level (0 - 10)", mEnv.data.rainLevel or nil, guiGetInputNumericParser(false, 0, 10), true, guiGetInputNumericMatcher(false, 0, 10))
		if level == false then return end
		cCommands.execute("setserverrainlevel", level)

	elseif source == mEnv.gui.blurVLbl then
		local level = guiShowInputDialog("Blur level", "Enter new blur level (0 - 255)", mEnv.data.blur or nil, guiGetInputNumericParser(true, 0, 255), true, guiGetInputNumericMatcher(true, 0, 255))
		if level == false then return end
		cCommands.execute("setserverblurlevel", level)

	elseif source == mEnv.gui.heatHazeVLbl then
		local level = guiShowInputDialog("Heat haze level", "Enter new heat haze level (0 - 255)", mEnv.data.heatHaze or nil, guiGetInputNumericParser(true, 0, 255), true, guiGetInputNumericMatcher(true, 0, 255))
		if level == false then return end
		cCommands.execute("setserverheathaze", level)

	elseif source == mEnv.gui.sunSizeVLbl then
		local size = guiShowInputDialog("Sun size", "Enter new sun size", mEnv.data.sunSize or nil, guiGetInputNumericParser(false, 0), true, guiGetInputNumericMatcher(false, 0))
		if size == false then return end
		cCommands.execute("setserversunsize", size)

	elseif source == mEnv.gui.moonSizeVLbl then
		local size = guiShowInputDialog("Moon size", "Enter new moon size", mEnv.data.sunSize or nil, guiGetInputNumericParser(false, 0), true, guiGetInputNumericMatcher(false, 0))
		if size == false then return end
		cCommands.execute("setservermoonsize", size)

	elseif source == mEnv.gui.waveHeightVLbl then
		local height = guiShowInputDialog("Wave height", "Enter new wave height (0 - 100)", mEnv.data.waveHeight or nil, guiGetInputNumericParser(false, 0, 100), true, guiGetInputNumericMatcher(false, 0, 100))
		if height == false then return end
		cCommands.execute("setserverwaveheight", height)

	elseif source == mEnv.gui.trafficChk then
		cCommands.execute("lockservertrafficlights", guiCheckBoxGetSelected(mEnv.gui.trafficChk))

	elseif source == mEnv.gui.trafficStateVLbl then
		local state = guiShowInputDialog("Traffic lights state", "Enter new traffic lights state (0 - 9)", mEnv.data.trafficLightsState or nil, guiGetInputNumericParser(true, 0, 9), true, guiGetInputNumericMatcher(true, 0, 9))
		if state == false then return end
		cCommands.execute("setservertrafficlightstate", state)

	end
end

function mEnv.gui.onRightClick()

	if source == mEnv.gui.skyGradClrp1 or source == mEnv.gui.skyGradClrp2 then
		cCommands.execute("setserverskygradient")

	elseif source == mEnv.gui.sunClrClrp1 or source == mEnv.gui.sunClrClrp2 then
		cCommands.execute("setserversuncolor")

	elseif source == mEnv.gui.waterClrClrp then
		cCommands.execute("setserverwatercolor")

	end

end

function mEnv.gui.onColorAccepted(r, g, b)
	
	if source == mEnv.gui.skyGradClrp1 or source == mEnv.gui.skyGradClrp2 then
		local r1, g1, b1 = guiColorPickerGetColor(mEnv.gui.skyGradClrp1)
		local r2, g2, b2 = guiColorPickerGetColor(mEnv.gui.skyGradClrp2)
		cCommands.execute("setserverskygradient", r1, g1, b1, r2, g2, b2)

	elseif source == mEnv.gui.sunClrClrp1 or source == mEnv.gui.sunClrClrp2 then
		local r1, g1, b1 = guiColorPickerGetColor(mEnv.gui.sunClrClrp1)
		local r2, g2, b2 = guiColorPickerGetColor(mEnv.gui.sunClrClrp2)
		cCommands.execute("setserversuncolor", r1, g1, b1, r2, g2, b2)

	elseif source == mEnv.gui.waterClrClrp then
		cCommands.execute("setserverwatercolor", r, g, b)

	end

end

function mEnv.gui.refresh()
	
	if mEnv.data.occlusions ~= nil then
		guiCheckBoxSetSelected(mEnv.gui.occlChk, mEnv.data.occlusions)
	end

	guiSetText(mEnv.gui.fcdVLbl, mEnv.data.farClipDistanse)
	guiSetText(mEnv.gui.fdVLbl, mEnv.data.fogDistance)

	local h, m = table.unpack(mEnv.data.time)
	guiSetText(mEnv.gui.timeVLbl, h and formatGameTime(h, m) or nil)

	local weather = mEnv.data.weather
	if weather then
		guiSetText(mEnv.gui.weatherVLbl, formatNameID(getWeatherName(weather), weather))
	else
		guiSetText(mEnv.gui.weatherVLbl)
	end

	if mEnv.data.minuteDuration then
		guiSetText(mEnv.gui.mdVLbl, formatDuration(mEnv.data.minuteDuration/1000))
	else
		guiSetText(mEnv.gui.mdVLbl)
	end

	if mEnv.data.clouds ~= nil then
		guiCheckBoxSetSelected(mEnv.gui.cloudsChk, mEnv.data.clouds)
	end

	guiSetText(mEnv.gui.heatHazeVLbl, mEnv.data.heatHaze)

	local r1, g1, b1, r2, g2, b2 = unpack(mEnv.data.skyGradient)
	if r1 then
		guiColorPickerSetColor(mEnv.gui.skyGradClrp1, r1, g1, b1)
		guiColorPickerSetColor(mEnv.gui.skyGradClrp2, r2, g2, b2)
	else
		guiColorPickerSetColor(mEnv.gui.skyGradClrp1, nil)
		guiColorPickerSetColor(mEnv.gui.skyGradClrp2, nil)
	end

	r1, g1, b1, r2, g2, b2 = unpack(mEnv.data.sunColor)
	if r1 then
		guiColorPickerSetColor(mEnv.gui.sunClrClrp1, r1, g1, b1)
		guiColorPickerSetColor(mEnv.gui.sunClrClrp2, r2, g2, b2)
	else
		guiColorPickerSetColor(mEnv.gui.sunClrClrp1, nil)
		guiColorPickerSetColor(mEnv.gui.sunClrClrp2, nil)
	end

	r1, g1, b1 = unpack(mEnv.data.waterColor)
	if r1 then
		guiColorPickerSetColor(mEnv.gui.waterClrClrp, r1, g1, b1)
	else
		guiColorPickerSetColor(mEnv.gui.waterClrClrp, nil)
	end

	guiSetText(mEnv.gui.rainVLbl, mEnv.data.rainLevel)
	guiSetText(mEnv.gui.blurVLbl, mEnv.data.blur)
	guiSetText(mEnv.gui.moonSizeVLbl, mEnv.data.moonSize)
	guiSetText(mEnv.gui.sunSizeVLbl, mEnv.data.sunSize)
	guiSetText(mEnv.gui.waveHeightVLbl, mEnv.data.waveHeight)

	if mEnv.data.trafficLights ~= nil then
		guiCheckBoxSetSelected(mEnv.gui.trafficChk, mEnv.data.trafficLights)
	end

	guiSetText(mEnv.gui.trafficStateVLbl, mEnv.data.trafficLightsState)
	
	return true
end