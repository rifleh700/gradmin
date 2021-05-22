
mMutes.gui.addMute = {}

function mMutes.gui.addMute.init()

	mMutes.gui.addMute.window = guiCreateWindow(nil, nil, nil, nil, "Add mute")
	local mainVlo = guiCreateVerticalLayout(nil, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, mMutes.gui.addMute.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, false, mainVlo)
	mMutes.gui.addMute.serialLbl, mMutes.gui.addMute.serialEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "* Serial:", nil, nil, vlo)
	guiEditSetParser(mMutes.gui.addMute.serialEdit, guiGetInputNotEmptyParser())

	guiCreateHorizontalSeparator(nil, nil, nil, nil, vlo)

	mMutes.gui.addMute.nickLbl, mMutes.gui.addMute.nickEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "Name:", nil, nil, vlo)
	guiEditSetParser(mMutes.gui.addMute.nickEdit, guiGetInputNotEmptyParser())
	mMutes.gui.addMute.durationLbl, mMutes.gui.addMute.durationEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "* Duration:", nil, nil, vlo)
	guiEditSetParser(mMutes.gui.addMute.durationEdit, guiGetInputNotEmptyParser())

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mMutes.gui.addMute.reasonLbl = guiCreateLabel(nil, nil, nil, nil, "Reason:", nil, hlo)
	guiLabelSetHorizontalAlign(mMutes.gui.addMute.reasonLbl, "right")
	mMutes.gui.addMute.reasonEdit = guiCreateMemo(nil, nil, GS.w32, GS.h2, nil, false, hlo)
	guiMemoSetParser(mMutes.gui.addMute.reasonEdit, guiGetInputNotEmptyParser())

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	mMutes.gui.addMute.okBtn = guiCreateButton(nil, nil, nil, nil, "Mute!", nil, hlo)
	guiButtonSetHoverTextColor(mMutes.gui.addMute.okBtn, table.unpack(GS.clr.red))
	mMutes.gui.addMute.cancelBtn = guiCreateButton(nil, nil, nil, nil, "Cancel", nil, hlo)

	guiRebuildLayouts(mMutes.gui.addMute.window)

	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(mMutes.gui.addMute.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)

	---------------------------------

	addEventHandler("onClientGUILeftClick", mMutes.gui.addMute.okBtn, mMutes.gui.addMute.onAccept, false) 
	addEventHandler("onClientGUILeftClick", mMutes.gui.addMute.cancelBtn, mMutes.gui.addMute.onCancel, false) 

	return true
end

function mMutes.gui.addMute.term()
	
	destroyElement(mMutes.gui.addMute.window)

	return true
end

function mMutes.gui.addMute.show()
	
	guiSetText(mMutes.gui.addMute.serialEdit, "")
	guiSetText(mMutes.gui.addMute.nickEdit, "")
	guiSetText(mMutes.gui.addMute.durationEdit, "")
	guiSetText(mMutes.gui.addMute.reasonEdit, "")

	return guiSetVisible(mMutes.gui.addMute.window, true, true)
end

function mMutes.gui.addMute.hide()
	
	return guiSetVisible(mMutes.gui.addMute.window, false)
end

function mMutes.gui.addMute.onAccept()
	
	local serial = guiEditGetParsedValue(mMutes.gui.addMute.serialEdit)
	if not serial or not isValidSerial(serial) then return guiShowMessageDialog("Invalid serial!", nil, MD_OK, MD_ERROR) end

	local name = guiEditGetParsedValue(mMutes.gui.addMute.nickEdit)
	local reason = guiMemoGetParsedValue(mMutes.gui.addMute.reasonEdit)

	local duration = guiEditGetParsedValue(mMutes.gui.addMute.durationEdit)
	duration = duration and parseDuration(duration)
	if not duration then return guiShowMessageDialog("Invalid duration! Format examples: perm / 20d / 5 days 1 hour / 10 secs", nil, MD_OK, MD_ERROR) end

	if not guiShowMessageDialog("Serial "..serial.." will be muted for "..formatDuration(duration)..". Continue?", nil, MD_YES_NO, MD_QUESTION) then return end

	mMutes.gui.addMute.hide()

	cCommands.execute("muteserial", serial, name, duration, reason)

end

function mMutes.gui.addMute.onCancel()
	
	mMutes.gui.addMute.hide()

end

