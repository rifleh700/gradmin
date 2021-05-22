
local DATE_FORMAT = "%d/%m/%Y  %H:%M:%S"
local PERM_COLOR = GS.clr.orange

mMutes.gui = {}

function mMutes.gui.init()

	local tab = cGUI.addTab("Mutes")
	mMutes.gui.tab = tab
	
	local mainVlo = guiCreateVerticalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, nil, false, tab)
	guiSetRawSize(mainVlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(mainVlo, true)

	local srchHlo = guiCreateHorizontalLayout(nil, nil, -GS.w2 - GS.mrg, nil, nil, false, mainVlo)
	guiSetRawWidth(srchHlo, 1, true)
	guiHorizontalLayoutSetWidthFixed(srchHlo, true)

	mMutes.gui.srch = guiCreateSearchEdit(nil, nil, -GS.h - GS.mrg - 1, nil, "", false, srchHlo)
	guiSetRawWidth(mMutes.gui.srch, 1, true)
	guiEditSetParser(mMutes.gui.srch, guiGetInputMapParser())
	mMutes.gui.infoBtn = guiCreateHelpButton(nil, nil, nil, nil, srchHlo)

	local mainHlo = guiCreateHorizontalLayout(nil, nil, nil, -GS.h - GS.mrg, nil, false, mainVlo)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetSizeFixed(mainHlo, true)
	
	mMutes.gui.list = guiCreateGridList(nil, nil, -GS.w2 - GS.mrg - 1, 0, false, mainHlo)
	guiSetRawSize(mMutes.gui.list, 1, 1, true)
	guiGridListSetSortingEnabled(mMutes.gui.list, false)
	guiGridListSetSelectionMode(mMutes.gui.list, 2)
	mMutes.gui.numClm = guiGridListAddColumn(mMutes.gui.list, "#", 0.07)
	mMutes.gui.timeClm = guiGridListAddColumn(mMutes.gui.list, "Date", 0.22)
	mMutes.gui.nickClm = guiGridListAddColumn(mMutes.gui.list, "Name", 0.15)
	mMutes.gui.serialClm = guiGridListAddColumn(mMutes.gui.list, "Serial", 0.08)
	mMutes.gui.durationClm = guiGridListAddColumn(mMutes.gui.list, "Duration", 0.12)
	mMutes.gui.unmuteClm = guiGridListAddColumn(mMutes.gui.list, "Unmute", 0.12)
	mMutes.gui.adminClm = guiGridListAddColumn(mMutes.gui.list, "Admin", 0.2)
	mMutes.gui.reasonClm = guiGridListAddColumn(mMutes.gui.list, "Reason", 0.8)

	mMutes.gui.cmenu = guiCreateContextMenu()
	mMutes.gui.copyRowCItem = guiContextMenuAddItem(mMutes.gui.cmenu, "Copy row")
	mMutes.gui.copySerialCItem = guiContextMenuAddItem(mMutes.gui.cmenu, "Copy serial")
	guiSetContextMenu(mMutes.gui.list, mMutes.gui.cmenu)

	local btnsVlo = guiCreateVerticalLayout(nil, nil, GS.w2, 0, nil, nil, mainHlo)
	guiSetRawHeight(btnsVlo, 1, true)
	guiVerticalLayoutSetSizeFixed(btnsVlo, true)

	mMutes.gui.unmuteBtn = guiCreateButton(nil, nil, nil, nil, "Unmute", nil, btnsVlo, "command.unmuteserial")
	guiButtonSetHoverTextColor(mMutes.gui.unmuteBtn, table.unpack(GS.clr.green))
	mMutes.gui.setNickBtn = guiCreateButton(nil, nil, nil, nil, "Set nick", nil, btnsVlo, "command.setmutenick")
	mMutes.gui.setDurBtn = guiCreateButton(nil, nil, nil, nil, "Set duration", nil, btnsVlo, "command.setmuteduration")
	mMutes.gui.setReasonBtn = guiCreateButton(nil, nil, nil, nil, "Set reason", nil, btnsVlo, "command.setmutereason")
	mMutes.gui.setAdminBtn = guiCreateButton(nil, nil, nil, nil, "Set admin", nil, btnsVlo, "command.setmuteadmin")
	guiCreateHorizontalSeparator(nil, nil, 1, true, btnsVlo)
	mMutes.gui.addMuteBtn = guiCreateButton(nil, nil, nil, nil, "Add mute", nil, btnsVlo, "command.muteserial")
	
	guiRebuildLayouts(tab)
	---------------------------------	

	addEventHandler("onClientGUILeftClick", mMutes.gui.tab, mMutes.gui.onClick)
	addEventHandler("onClientGUILeftClick", mMutes.gui.cmenu, mMutes.gui.onClickContext)
	addEventHandler("onClientGUIGridListItemSelected", mMutes.gui.list, mMutes.gui.onItemSelected, false)
	addEventHandler("onClientGUIDoubleLeftClick", mMutes.gui.list, mMutes.gui.onListDoubleClick, false)
	addEventHandler("onClientGUIGridListItemDeleteKey", mMutes.gui.list, function() guiClick(mMutes.gui.unmuteBtn) end, false)
	addEventHandler("onClientGUIAccepted", mMutes.gui.srch, mMutes.gui.onSearchAccepted, false)

	addEventHandler("gra.cGUI.onRefresh", mMutes.gui.tab, mMutes.gui.onRefresh)

	----------------------------------

	mMutes.gui.refresh()
	mMutes.gui.addMute.init()
	
	return true
end

function mMutes.gui.term()

	mMutes.gui.addMute.term()

	destroyElement(mMutes.gui.tab)

	return true
end

function mMutes.gui.onClick()

	local selectedID = mMutes.gui.getSelected()
	local selectedData = selectedID and mMutes.getData(selectedID)
	local serial = selectedID and selectedData.serial

	if source == mMutes.gui.infoBtn then
		guiShowMessageDialog(
			"Available search filter options: since, before, serial, admin, reason, nick.\nSearch by partial value is available.\nDate format: Y[n]M[n]D[n]h[n]m[n]s[n] (at least one value required). M5.D3 means 3 May, current year, 00:00:00.\nExample: since:Y2020.M1.D15.h23.m58.s45 before:M5 serial:abc admin:adminDude nick:dude reason:some",
			"Information",
			MD_OK, MD_INFO
		)

	elseif source == mMutes.gui.unmuteBtn then
		local reason = guiShowInputDialog("Unmute", "Enter the unmute ("..serial..") reason", nil, guiGetInputNotEmptyParser(), true)
		if reason == false then return end
		cCommands.execute("unmuteserial", serial, reason)

	elseif source == mMutes.gui.setDurBtn then
		local duration = formatDuration((not selectedData.unmute or selectedData.unmute == 0) and 0 or (selectedData.unmute - selectedData.time))
		duration = guiShowInputDialog("Change mute duration", "Enter new duration for mute (i.e. 20days 2hours 5m 30s or permanent)", duration, parseDuration)
		if not duration then return end

		cCommands.execute("setmuteduration", serial, duration)

	elseif source == mMutes.gui.setNickBtn then
		local nick = guiShowInputDialog("Change mute nick", "Enter new nick for mute", selectedData.nick, guiGetInputNotEmptyParser(), true)
		if nick == false then return end

		cCommands.execute("setmutenick", serial, nick)

	elseif source == mMutes.gui.setReasonBtn then
		local reason = guiShowInputDialog("Change mute reason", "Enter new reason for mute", selectedData.reason, guiGetInputNotEmptyParser(), true)
		if reason == false then return end

		cCommands.execute("setmutereason", serial, reason)

	elseif source == mMutes.gui.setAdminBtn then
		local admin = guiShowInputDialog("Change mute admin", "Enter new admin (mutened by) name for mute", selectedData.admin, guiGetInputNotEmptyParser(), true)
		if admin == false then return end

		cCommands.execute("setmuteadmin", serial, admin)

	elseif source == mMutes.gui.addMuteBtn then
		mMutes.gui.addMute.show()

	end
end

function mMutes.gui.onClickContext()

	local row = guiGridListGetSelectedItem(mMutes.gui.list)
	if row == -1 then return end

	if source == mMutes.gui.copyRowCItem then
		local text = ""
		for col = 1, guiGridListGetColumnCount(mMutes.gui.list) do
			text = text..guiGridListGetItemText(mMutes.gui.list, row, col).." "
		end
		setClipboard(text)
	
	elseif source == mMutes.gui.copySerialCItem then
		setClipboard(guiGridListGetItemText(mMutes.gui.list, row, mMutes.gui.serialClm))

	end

end

function mMutes.gui.onItemSelected(row)
	
	local enabled = row ~= -1
	guiSetEnabled(mMutes.gui.unmuteBtn, enabled)
	guiSetEnabled(mMutes.gui.setDurBtn, enabled)
	guiSetEnabled(mMutes.gui.setNickBtn, enabled)
	guiSetEnabled(mMutes.gui.setReasonBtn, enabled)
	guiSetEnabled(mMutes.gui.setAdminBtn, enabled)

end

function mMutes.gui.onListDoubleClick()
	
	local row, column = guiGridListGetSelectedItem(mMutes.gui.list)
	if row == -1 or column == 0 then return end

	if column == mMutes.gui.nickClm then
		guiClick(mMutes.gui.setNickBtn)

	elseif column == mMutes.gui.durationClm then
		guiClick(mMutes.gui.setDurBtn)

	elseif column == mMutes.gui.reasonClm then
		guiClick(mMutes.gui.setReasonBtn)

	elseif column == mMutes.gui.adminClm then
		guiClick(mMutes.gui.setAdminBtn)

	end

end

function mMutes.gui.onRefresh()
	if guiGridListGetVerticalScrollPosition(mMutes.gui.list) < 95 then return end
	
	mMutes.requestNext()

end

function mMutes.gui.onSearchAccepted()
	
	guiFocus(source)

	local filter = guiEditGetParsedValue(source)
	filter.since = filter.since and parseDate(filter.since)
	filter.before = filter.before and parseDate(filter.before)
	mMutes.request(filter)

end

function mMutes.gui.getSelected()
	return guiGridListGetSelectedItemData(mMutes.gui.list, nil, 1)
end

function mMutes.gui.refresh()

	local list = mMutes.gui.list
	local selected = mMutes.gui.getSelected()
	local selectedRow, selectedColumn = guiGridListGetSelectedItem(list)
	guiGridListClear(list)

	for i, data in ipairs(mMutes.mutes) do
		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, mMutes.gui.numClm, i)
		guiGridListSetItemText(list, row, mMutes.gui.nickClm, data.nick)
		guiGridListSetItemText(list, row, mMutes.gui.serialClm, data.serial)
		guiGridListSetItemText(list, row, mMutes.gui.timeClm, os.date(DATE_FORMAT, data.time))
		guiGridListSetItemText(list, row, mMutes.gui.adminClm, data.admin)
		guiGridListSetItemText(list, row, mMutes.gui.reasonClm, data.reason)
		if not data.unmute or data.unmute == 0 then
			guiGridListSetItemText(list, row, mMutes.gui.durationClm, "permanent")
			guiGridListSetItemText(list, row, mMutes.gui.unmuteClm, "never")
			guiGridListSetRowColor(list, row, table.unpack(PERM_COLOR))
		else
			guiGridListSetItemText(list, row, mMutes.gui.durationClm, formatDuration(data.unmute - data.time))
			guiGridListSetItemText(list, row, mMutes.gui.unmuteClm, os.date(DATE_FORMAT, data.unmute))
		end
		guiGridListSetItemData(list, row, 1, data.id)
	end

	selectedRow = selected and guiGridListGetItemByData(list, selected) or selectedRow 
	guiGridListSetSelectedAnyItem(list, selectedRow, selectedColumn)
	
	return true
end