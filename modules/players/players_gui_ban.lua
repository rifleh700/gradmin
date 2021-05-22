
mPlayers.gui.Ban = {}

mPlayers.gui.Ban.player = nil

function mPlayers.gui.Ban.init()

	mPlayers.gui.Ban.window = guiCreateWindow(nil, nil, nil, nil, "Ban player")
	local mainVlo = guiCreateVerticalLayout(nil, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, mPlayers.gui.Ban.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, false, mainVlo)
	mPlayers.gui.Ban.serialLbl, mPlayers.gui.Ban.serialVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Serial:", nil, nil, vlo)
	mPlayers.gui.Ban.ipLbl, mPlayers.gui.Ban.ipVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "IP:", nil, nil, vlo)
	mPlayers.gui.Ban.ipChk = guiCreateCheckBox(-guiGetTextExtent(mPlayers.gui.Ban.ipLbl), 0, GS.h, GS.h, "", false, false, mPlayers.gui.Ban.ipLbl)
	guiSetHorizontalAlign(mPlayers.gui.Ban.ipChk, "right")

	guiCreateHorizontalSeparator(nil, nil, nil, nil, vlo)

	mPlayers.gui.Ban.nickLbl, mPlayers.gui.Ban.nickVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Name:", nil, nil, vlo)
	mPlayers.gui.Ban.durationLbl, mPlayers.gui.Ban.durationEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "* Duration:", nil, nil, vlo)
	guiEditSetParser(mPlayers.gui.Ban.durationEdit, guiGetInputNotEmptyParser())
	
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mPlayers.gui.Ban.reasonLbl = guiCreateLabel(nil, nil, nil, nil, "Reason:", nil, hlo)
	guiLabelSetHorizontalAlign(mPlayers.gui.Ban.reasonLbl, "right")
	mPlayers.gui.Ban.reasonEdit = guiCreateMemo(nil, nil, GS.w32, GS.h2, nil, false, hlo)
	guiMemoSetParser(mPlayers.gui.Ban.reasonEdit, guiGetInputNotEmptyParser())

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	mPlayers.gui.Ban.okBtn = guiCreateButton(nil, nil, nil, nil, "Ban!", nil, hlo)
	guiButtonSetHoverTextColor(mPlayers.gui.Ban.okBtn, table.unpack(GS.clr.red))
	mPlayers.gui.Ban.cancelBtn = guiCreateButton(nil, nil, nil, nil, "Cancel", nil, hlo)

	guiRebuildLayouts(mPlayers.gui.Ban.window)

	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(mPlayers.gui.Ban.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)

	---------------------------------

	addEventHandler("onClientGUILeftClick", mPlayers.gui.Ban.okBtn, mPlayers.gui.Ban.onAccept, false) 
	addEventHandler("onClientGUILeftClick", mPlayers.gui.Ban.cancelBtn, mPlayers.gui.Ban.onCancel, false) 

	return true
end

function mPlayers.gui.Ban.term()
	
	destroyElement(mPlayers.gui.Ban.window)

	return true
end

function mPlayers.gui.Ban.show(player, serial, ip)
	
	mPlayers.gui.Ban.player = player

	guiSetText(mPlayers.gui.Ban.window, "Ban player "..getPlayerName(player, true))
	guiSetText(mPlayers.gui.Ban.serialVLbl, serial)
	guiSetText(mPlayers.gui.Ban.ipVLbl, ip)
	guiSetText(mPlayers.gui.Ban.nickVLbl, getPlayerName(player))
	guiSetText(mPlayers.gui.Ban.durationEdit, "")
	guiSetText(mPlayers.gui.Ban.reasonEdit, "")

	return guiSetVisible(mPlayers.gui.Ban.window, true, true)
end

function mPlayers.gui.Ban.hide()
	
	return guiSetVisible(mPlayers.gui.Ban.window, false)
end

function mPlayers.gui.Ban.onAccept()
	
	local ip = guiCheckBoxGetSelected(mPlayers.gui.Ban.ipChk)
	local reason = guiMemoGetParsedValue(mPlayers.gui.Ban.reasonEdit)
	local duration = guiEditGetParsedValue(mPlayers.gui.Ban.durationEdit)
	duration = duration and parseDuration(duration)
	if not duration then return guiShowMessageDialog("Invalid duration! Format examples: perm / 20d / 5 days 1 hour / 10 secs", nil, MD_OK, MD_ERROR) end

	if not guiShowMessageDialog("Player "..getPlayerName(mPlayers.gui.Ban.player, true).." will be banned for "..formatDuration(duration)..". Continue?", nil, MD_YES_NO, MD_QUESTION) then return end

	mPlayers.gui.Ban.hide()

	cCommands.execute("ban", mPlayers.gui.Ban.player, ip, duration, reason)

end

function mPlayers.gui.Ban.onCancel()
	
	mPlayers.gui.Ban.hide()

end

