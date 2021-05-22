
mBans.gui.addBan = {}

function mBans.gui.addBan.init()

	mBans.gui.addBan.window = guiCreateWindow(nil, nil, nil, nil, "Add ban")
	local mainVlo = guiCreateVerticalLayout(nil, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, mBans.gui.addBan.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, false, mainVlo)
	mBans.gui.addBan.serialLbl, mBans.gui.addBan.serialEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "* Serial:", nil, nil, vlo)
	guiEditSetParser(mBans.gui.addBan.serialEdit, guiGetInputNotEmptyParser())
	mBans.gui.addBan.ipLbl, mBans.gui.addBan.ipEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "IP:", nil, nil, vlo)
	guiEditSetParser(mBans.gui.addBan.ipEdit, guiGetInputNotEmptyParser())

	guiCreateHorizontalSeparator(nil, nil, nil, nil, vlo)

	mBans.gui.addBan.nickLbl, mBans.gui.addBan.nickEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "Name:", nil, nil, vlo)
	guiEditSetParser(mBans.gui.addBan.nickEdit, guiGetInputNotEmptyParser())
	mBans.gui.addBan.durationLbl, mBans.gui.addBan.durationEdit =
		guiCreateKeyValueEdit(nil, nil, nil, GS.w32, nil, "* Duration:", nil, nil, vlo)
	guiEditSetParser(mBans.gui.addBan.durationEdit, guiGetInputNotEmptyParser())

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mBans.gui.addBan.reasonLbl = guiCreateLabel(nil, nil, nil, nil, "Reason:", nil, hlo)
	guiLabelSetHorizontalAlign(mBans.gui.addBan.reasonLbl, "right")
	mBans.gui.addBan.reasonEdit = guiCreateMemo(nil, nil, GS.w32, GS.h2, nil, false, hlo)
	guiMemoSetParser(mBans.gui.addBan.reasonEdit, guiGetInputNotEmptyParser())

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	mBans.gui.addBan.okBtn = guiCreateButton(nil, nil, nil, nil, "Ban!", nil, hlo)
	guiButtonSetHoverTextColor(mBans.gui.addBan.okBtn, table.unpack(GS.clr.red))
	mBans.gui.addBan.cancelBtn = guiCreateButton(nil, nil, nil, nil, "Cancel", nil, hlo)

	guiRebuildLayouts(mBans.gui.addBan.window)

	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(mBans.gui.addBan.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)

	---------------------------------

	addEventHandler("onClientGUILeftClick", mBans.gui.addBan.okBtn, mBans.gui.addBan.onAccept, false) 
	addEventHandler("onClientGUILeftClick", mBans.gui.addBan.cancelBtn, mBans.gui.addBan.onCancel, false) 

	return true
end

function mBans.gui.addBan.term()
	
	destroyElement(mBans.gui.addBan.window)

	return true
end

function mBans.gui.addBan.show()
	
	guiSetText(mBans.gui.addBan.serialEdit, "")
	guiSetText(mBans.gui.addBan.ipEdit, "")
	guiSetText(mBans.gui.addBan.nickEdit, "")
	guiSetText(mBans.gui.addBan.durationEdit, "")
	guiSetText(mBans.gui.addBan.reasonEdit, "")

	return guiSetVisible(mBans.gui.addBan.window, true, true)
end

function mBans.gui.addBan.hide()
	
	return guiSetVisible(mBans.gui.addBan.window, false)
end

function mBans.gui.addBan.onAccept()
	
	local serial = guiEditGetParsedValue(mBans.gui.addBan.serialEdit)
	if not serial or not isValidSerial(serial) then return guiShowMessageDialog("Invalid serial!", nil, MD_OK, MD_ERROR) end

	local ip = guiEditGetParsedValue(mBans.gui.addBan.ipEdit)
	if ip and not isValidIP(ip) then return guiShowMessageDialog("Invalid IP!", nil, MD_OK, MD_ERROR) end

	local name = guiEditGetParsedValue(mBans.gui.addBan.nickEdit)
	local reason = guiMemoGetParsedValue(mBans.gui.addBan.reasonEdit)

	local duration = guiEditGetParsedValue(mBans.gui.addBan.durationEdit)
	duration = duration and parseDuration(duration)
	if not duration then return guiShowMessageDialog("Invalid duration! Format examples: perm / 20d / 5 days 1 hour / 10 secs", nil, MD_OK, MD_ERROR) end

	if not guiShowMessageDialog("Serial "..serial.." will be banned for "..formatDuration(duration)..". Continue?", nil, MD_YES_NO, MD_QUESTION) then return end

	mBans.gui.addBan.hide()

	cCommands.execute("banserial", serial, ip, name, duration, reason)

end

function mBans.gui.addBan.onCancel()
	
	mBans.gui.addBan.hide()

end

