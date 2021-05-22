
mServer.gui = {}

function mServer.gui.init()

	local tab = cGUI.addTab("Server")
	mServer.gui.tab = tab

	local mainHlo = guiCreateHorizontalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, GS.mrg2, false, tab)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetHeightFixed(mainHlo, true)

	local leftVlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainHlo)
	
	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	_, mServer.gui.serverVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Server:", nil, nil, hlo)
	mServer.gui.shutdownBtn = guiCreateButton(nil, nil, GS.w3, nil, "Shutdown", false, hlo)
	cGuiGuard.setPermission(mServer.gui.shutdownBtn, "command.shutdown")
	guiButtonSetHoverTextColor(mServer.gui.shutdownBtn, unpack(COLORS.orange))
	
	_, mServer.gui.playersVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Players:", nil, nil, leftVlo)
	_, mServer.gui.versionVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Version:", nil, nil, leftVlo)
	_, mServer.gui.ipVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "IP:", nil, nil, leftVlo)

	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, leftVlo)
	_, mServer.gui.portVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "MTA port:", nil, nil, hlo)
	_, mServer.gui.httpPortVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "HTTP port:", nil, nil, hlo)

	_, mServer.gui.mcvVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Min client ver:", nil, nil, leftVlo)

	guiCreateHorizontalSeparator(0, 0, 1, true, leftVlo)

	_, mServer.gui.passVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Password:", nil, nil, leftVlo)
	cGuiGuard.setPermission(mServer.gui.passVLbl, "command.setserverpassword")
	guiLabelSetClickableStyle(mServer.gui.passVLbl, true)

	_, mServer.gui.fpsVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "FPS limit:", nil, nil, leftVlo)
	cGuiGuard.setPermission(mServer.gui.fpsVLbl, "command.setserverfpslimit")
	guiLabelSetClickableStyle(mServer.gui.fpsVLbl, true)

	_, mServer.gui.gameTypeVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Game type:", nil, nil, leftVlo)
	cGuiGuard.setPermission(mServer.gui.gameTypeVLbl, "command.setservergametype")
	guiLabelSetClickableStyle(mServer.gui.gameTypeVLbl, true)

	guiCreateHorizontalSeparator(0, 0, 1, true, leftVlo)

	local rightVlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainHlo)
	
	mServer.gui.glitchChks = {}
	for i, glitch in ipairs(getValidGlitches()) do
		local chk = guiCreateCheckBox(nil, nil, GS.w3, nil, getGlitchName(glitch), false, false, rightVlo)
		cGuiGuard.setPermission(chk, "command.setserverglitch")
		guiSetData(chk, "glitch", glitch)
		addEventHandler("onClientGUILeftClick", chk, mServer.gui.onClickGlitch, false)
		mServer.gui.glitchChks[glitch] = chk
	end

	guiRebuildLayouts(tab)

	---------------------------------

	addEventHandler("gra.cGUI.onRefresh", mServer.gui.tab, mServer.gui.onRefresh)
	addEventHandler("onClientGUILeftClick", mServer.gui.tab, mServer.gui.onClick)

	return true
end

function mServer.gui.term()
		
	destroyElement(mServer.gui.tab)

	return true
end

function mServer.gui.onClick()

	if source == mServer.gui.shutdownBtn then
		local reason = guiShowInputDialog("Shutdown", "Enter shut down reason", nil, guiGetInputNotEmptyParser(), true)
		if reason == false then return end

		if not guiShowMessageDialog("Server will be shut down. Continue?", "Shutdown", MD_YES_NO, MD_WARNING) then return end
		
		if reason == "" then reason = nil end
		cCommands.execute("shutdown", reason)

	elseif source == mServer.gui.passVLbl then
		local pass = guiShowInputDialog("Server password", "Enter new server password", mServer.data.password, guiGetInputNotEmptyParser(), true)
		if pass == false then return end
		cCommands.execute("setserverpassword", pass)

	elseif source == mServer.gui.fpsVLbl then
		local fps = guiShowInputDialog("Server FPS limit", "Enter new server FPS limit", mServer.data.fps, guiGetInputNumericParser(true, 25, 100), true, guiGetInputNumericMatcher(true, 25, 100))
		if fps == false then return end
		cCommands.execute("setserverfpslimit", fps)

	elseif source == mServer.gui.gameTypeVLbl then
		local gameType = guiShowInputDialog("Server game type", "Enter new server game type", mServer.data.gameType, guiGetInputNotEmptyParser(), true)
		if gameType == false then return end
		cCommands.execute("setservergametype", gameType)

	end

end

function mServer.gui.onClickGlitch()
	
	cCommands.execute(
		"setserverglitch",
		guiGetData(source, "glitch"),
		guiCheckBoxGetSelected(source)
	)

end

function mServer.gui.onRefresh()

	if mServer.data.players then
		guiSetText(mServer.gui.playersVLbl, #getElementsByType("player").."/"..mServer.data.players)
	else
		guiSetText(mServer.gui.playersVLbl, #getElementsByType("player"))
	end

end

function mServer.gui.refresh()
	
	guiSetText(mServer.gui.serverVLbl, mServer.data.name or "N/A")
	guiSetText(mServer.gui.versionVLbl, mServer.data.version and mServer.data.version.tag or "N/A")
	guiSetText(mServer.gui.ipVLbl, mServer.data.ip or "N/A")
	guiSetText(mServer.gui.portVLbl, mServer.data.port or "N/A")
	guiSetText(mServer.gui.httpPortVLbl, mServer.data.httpPort or "N/A")
	guiSetText(mServer.gui.mcvVLbl, mServer.data.minClientVersion or "N/A")
	guiSetText(mServer.gui.passVLbl, mServer.data.password or "N/A")

	local clr = mServer.data.password and COLORS.orange or COLORS.white
	guiLabelSetColor(mServer.gui.passVLbl, unpack(clr))

	guiSetText(mServer.gui.gameTypeVLbl, mServer.data.game or "N/A")
	guiSetText(mServer.gui.fpsVLbl, mServer.data.fps or "N/A")

	for glitch, chk in pairs(mServer.gui.glitchChks) do
		guiCheckBoxSetSelected(chk, mServer.data.glitches[glitch])
	end

	mServer.gui.onRefresh()

	return true
end

