
mPlayers.gui.Mute = {}

mPlayers.gui.Mute.player = nil

function mPlayers.gui.Mute.init()

	mPlayers.gui.Mute.window = guiCreateWindow(nil, nil, nil, nil, "Mute player")
	local mainVlo = guiCreateVerticalLayout(nil, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, mPlayers.gui.Mute.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, false, mainVlo)
	mPlayers.gui.Mute.serialLbl, mPlayers.gui.Mute.serialVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Serial:", nil, nil, vlo)
	
	guiCreateHorizontalSeparator(nil, nil, nil, nil, vlo)

	mPlayers.gui.Mute.nickLbl, mPlayers.gui.Mute.nickVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Name:", nil, nil, vlo)
	mPlayers.gui.Mute.durationLbl, mPlayers.gui.Mute.durationEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "* Duration:", nil, nil, vlo)
	guiEditSetParser(mPlayers.gui.Mute.durationEdit, guiGetInputNotEmptyParser())
	
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mPlayers.gui.Mute.reasonLbl = guiCreateLabel(nil, nil, nil, nil, "Reason:", nil, hlo)
	guiLabelSetHorizontalAlign(mPlayers.gui.Mute.reasonLbl, "right")
	mPlayers.gui.Mute.reasonEdit = guiCreateMemo(nil, nil, GS.w32, GS.h2, nil, false, hlo)
	guiMemoSetParser(mPlayers.gui.Mute.reasonEdit, guiGetInputNotEmptyParser())

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	mPlayers.gui.Mute.okBtn = guiCreateButton(nil, nil, nil, nil, "Mute!", nil, hlo)
	guiButtonSetHoverTextColor(mPlayers.gui.Mute.okBtn, table.unpack(GS.clr.red))
	mPlayers.gui.Mute.cancelBtn = guiCreateButton(nil, nil, nil, nil, "Cancel", nil, hlo)

	guiRebuildLayouts(mPlayers.gui.Mute.window)

	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(mPlayers.gui.Mute.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)

	---------------------------------

	addEventHandler("onClientGUILeftClick", mPlayers.gui.Mute.okBtn, mPlayers.gui.Mute.onAccept, false) 
	addEventHandler("onClientGUILeftClick", mPlayers.gui.Mute.cancelBtn, mPlayers.gui.Mute.onCancel, false) 

	return true
end

function mPlayers.gui.Mute.term()
	
	destroyElement(mPlayers.gui.Mute.window)

	return true
end

function mPlayers.gui.Mute.show(player, serial)
	
	mPlayers.gui.Mute.player = player

	guiSetText(mPlayers.gui.Mute.window, "Mute player "..getPlayerName(player, true))
	guiSetText(mPlayers.gui.Mute.serialVLbl, serial)
	guiSetText(mPlayers.gui.Mute.nickVLbl, getPlayerName(player))
	guiSetText(mPlayers.gui.Mute.durationEdit, "")
	guiSetText(mPlayers.gui.Mute.reasonEdit, "")

	return guiSetVisible(mPlayers.gui.Mute.window, true, true)
end

function mPlayers.gui.Mute.hide()
	
	return guiSetVisible(mPlayers.gui.Mute.window, false)
end

function mPlayers.gui.Mute.onAccept()
	
	local reason = guiMemoGetParsedValue(mPlayers.gui.Mute.reasonEdit)
	local duration = guiEditGetParsedValue(mPlayers.gui.Mute.durationEdit)
	duration = duration and parseDuration(duration)
	if not duration then return guiShowMessageDialog("Invalid duration! Format examples: perm / 20d / 5 days 1 hour / 10 secs", nil, MD_OK, MD_ERROR) end

	if not guiShowMessageDialog("Player "..getPlayerName(mPlayers.gui.Mute.player, true).." will be mutened for "..formatDuration(duration)..". Continue?", nil, MD_YES_NO, MD_QUESTION) then return end

	mPlayers.gui.Mute.hide()

	cCommands.execute("mute", mPlayers.gui.Mute.player, duration, reason)

end

function mPlayers.gui.Mute.onCancel()
	
	mPlayers.gui.Mute.hide()

end

