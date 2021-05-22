
local DATE_FORMAT = "%d/%m/%Y  %H:%M:%S"
local PERM_COLOR = GS.clr.orange

mBans.gui = {}

function mBans.gui.init()

	local tab = cGUI.addTab("Bans")
	mBans.gui.tab = tab
	
	local mainVlo = guiCreateVerticalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, nil, false, tab)
	guiSetRawSize(mainVlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(mainVlo, true)

	local srchHlo = guiCreateHorizontalLayout(nil, nil, -GS.w2 - GS.mrg, nil, nil, false, mainVlo)
	guiSetRawWidth(srchHlo, 1, true)
	guiHorizontalLayoutSetWidthFixed(srchHlo, true)

	mBans.gui.srch = guiCreateSearchEdit(nil, nil, -GS.h - GS.mrg - 1, nil, "", false, srchHlo)
	guiSetRawWidth(mBans.gui.srch, 1, true)
	guiEditSetParser(mBans.gui.srch, guiGetInputMapParser())
	mBans.gui.infoBtn = guiCreateHelpButton(nil, nil, nil, nil, srchHlo)

	local mainHlo = guiCreateHorizontalLayout(nil, nil, nil, -GS.h - GS.mrg, nil, false, mainVlo)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetSizeFixed(mainHlo, true)
	
	mBans.gui.list = guiCreateGridList(nil, nil, -GS.w2 - GS.mrg - 1, 0, false, mainHlo)
	guiSetRawSize(mBans.gui.list, 1, 1, true)
	guiGridListSetSortingEnabled(mBans.gui.list, false)
	guiGridListSetSelectionMode(mBans.gui.list, 2)
	mBans.gui.numClm = guiGridListAddColumn(mBans.gui.list, "#", 0.07)
	mBans.gui.timeClm = guiGridListAddColumn(mBans.gui.list, "Date", 0.22)
	mBans.gui.nickClm = guiGridListAddColumn(mBans.gui.list, "Name", 0.15)
	mBans.gui.serialClm = guiGridListAddColumn(mBans.gui.list, "Serial", 0.08)
	mBans.gui.ipClm = guiGridListAddColumn(mBans.gui.list, "IP", 0.08)
	mBans.gui.durationClm = guiGridListAddColumn(mBans.gui.list, "Duration", 0.12)
	mBans.gui.unbanClm = guiGridListAddColumn(mBans.gui.list, "Unban", 0.12)
	mBans.gui.adminClm = guiGridListAddColumn(mBans.gui.list, "Admin", 0.2)
	mBans.gui.reasonClm = guiGridListAddColumn(mBans.gui.list, "Reason", 0.8)

	mBans.gui.cmenu = guiCreateContextMenu()
	mBans.gui.copyRowCItem = guiContextMenuAddItem(mBans.gui.cmenu, "Copy row")
	mBans.gui.copySerialCItem = guiContextMenuAddItem(mBans.gui.cmenu, "Copy serial")
	mBans.gui.copyIPCItem = guiContextMenuAddItem(mBans.gui.cmenu, "Copy IP")
	guiSetContextMenu(mBans.gui.list, mBans.gui.cmenu)

	local btnsVlo = guiCreateVerticalLayout(nil, nil, GS.w2, 0, nil, nil, mainHlo)
	guiSetRawHeight(btnsVlo, 1, true)
	guiVerticalLayoutSetSizeFixed(btnsVlo, true)

	mBans.gui.unbanBtn = guiCreateButton(nil, nil, nil, nil, "Unban", nil, btnsVlo, "command.unban")
	guiButtonSetHoverTextColor(mBans.gui.unbanBtn, table.unpack(GS.clr.green))
	mBans.gui.setNickBtn = guiCreateButton(nil, nil, nil, nil, "Set nick", nil, btnsVlo, "command.setbannick")
	mBans.gui.setDurBtn = guiCreateButton(nil, nil, nil, nil, "Set duration", nil, btnsVlo, "command.setbanduration")
	mBans.gui.setReasonBtn = guiCreateButton(nil, nil, nil, nil, "Set reason", nil, btnsVlo, "command.setbanreason")
	mBans.gui.setAdminBtn = guiCreateButton(nil, nil, nil, nil, "Set admin", nil, btnsVlo, "command.setbanadmin")
	guiCreateHorizontalSeparator(nil, nil, 1, true, btnsVlo)
	mBans.gui.addBanBtn = guiCreateButton(nil, nil, nil, nil, "Add ban", nil, btnsVlo, "command.banserial")
	
	guiRebuildLayouts(tab)
	---------------------------------	

	addEventHandler("onClientGUILeftClick", mBans.gui.tab, mBans.gui.onClick)
	addEventHandler("onClientGUILeftClick", mBans.gui.cmenu, mBans.gui.onClickContext)
	addEventHandler("onClientGUIGridListItemSelected", mBans.gui.list, mBans.gui.onItemSelected, false)
	addEventHandler("onClientGUIDoubleLeftClick", mBans.gui.list, mBans.gui.onListDoubleClick, false)
	addEventHandler("onClientGUIGridListItemDeleteKey", mBans.gui.list, function() guiClick(mBans.gui.unbanBtn) end, false)
	addEventHandler("onClientGUIAccepted", mBans.gui.srch, mBans.gui.onSearchAccepted, false)

	addEventHandler("gra.cGUI.onRefresh", mBans.gui.tab, mBans.gui.onRefresh)

	----------------------------------

	mBans.gui.refresh()
	mBans.gui.addBan.init()
	
	return true
end

function mBans.gui.term()

	mBans.gui.addBan.term()

	destroyElement(mBans.gui.tab)

	return true
end

function mBans.gui.onClick()

	local selectedID = mBans.gui.getSelected()
	local selectedData = selectedID and mBans.getData(selectedID)
	local serialIP = selectedID and (selectedData.serial or selectedData.ip)

	if source == mBans.gui.infoBtn then
		guiShowMessageDialog(
			"Available search filter options: since, before, serial, admin, reason, nick.\nSearch by partial value is available.\nDate format: Y[n]M[n]D[n]h[n]m[n]s[n] (at least one value required). M5.D3 means 3 May, current year, 00:00:00.\nExample: since:Y2020.M1.D15.h23.m58.s45 before:M5 serial:abc admin:adminDude nick:dude reason:some",
			"Information",
			MD_OK, MD_INFO
		)

	elseif source == mBans.gui.unbanBtn then
		local reason = guiShowInputDialog("Unban", "Enter the unban ("..serialIP..") reason", nil, guiGetInputNotEmptyParser(), true)
		if reason == false then return end
		cCommands.execute("unban", serialIP, reason)

	elseif source == mBans.gui.setDurBtn then
		local duration = formatDuration((not selectedData.unban or selectedData.unban == 0) and 0 or (selectedData.unban - selectedData.time))
		duration = guiShowInputDialog("Change ban duration", "Enter new duration for ban (i.e. 20days 2hours 5m 30s or permanent)", duration, parseDuration)
		if not duration then return end

		cCommands.execute("setbanduration", serialIP, duration)

	elseif source == mBans.gui.setNickBtn then
		local nick = guiShowInputDialog("Change ban nick", "Enter new nick for ban", selectedData.nick, guiGetInputNotEmptyParser(), true)
		if nick == false then return end

		cCommands.execute("setbannick", serialIP, nick)

	elseif source == mBans.gui.setReasonBtn then
		local reason = guiShowInputDialog("Change ban reason", "Enter new reason for ban", selectedData.reason, guiGetInputNotEmptyParser(), true)
		if reason == false then return end

		cCommands.execute("setbanreason", serialIP, reason)

	elseif source == mBans.gui.setAdminBtn then
		local admin = guiShowInputDialog("Change ban admin", "Enter new admin (banned by) name for ban", selectedData.admin, guiGetInputNotEmptyParser(), true)
		if admin == false then return end

		cCommands.execute("setbanadmin", serialIP, admin)

	elseif source == mBans.gui.addBanBtn then
		mBans.gui.addBan.show()

	end
end

function mBans.gui.onClickContext()

	local row = guiGridListGetSelectedItem(mBans.gui.list)
	if row == -1 then return end

	if source == mBans.gui.copyRowCItem then
		local text = ""
		for col = 1, guiGridListGetColumnCount(mBans.gui.list) do
			text = text..guiGridListGetItemText(mBans.gui.list, row, col).." "
		end
		setClipboard(text)
	
	elseif source == mBans.gui.copySerialCItem then
		setClipboard(guiGridListGetItemText(mBans.gui.list, row, mBans.gui.serialClm))

	elseif source == mBans.gui.copyIPCItem then
		setClipboard(guiGridListGetItemText(mBans.gui.list, row, mBans.gui.ipClm))

	end

end

function mBans.gui.onItemSelected(row)
	
	local enabled = row ~= -1
	guiSetEnabled(mBans.gui.unbanBtn, enabled)
	guiSetEnabled(mBans.gui.setDurBtn, enabled)
	guiSetEnabled(mBans.gui.setNickBtn, enabled)
	guiSetEnabled(mBans.gui.setReasonBtn, enabled)
	guiSetEnabled(mBans.gui.setAdminBtn, enabled)

end

function mBans.gui.onListDoubleClick()
	
	local row, column = guiGridListGetSelectedItem(mBans.gui.list)
	if row == -1 or column == 0 then return end

	if column == mBans.gui.nickClm then
		guiClick(mBans.gui.setNickBtn)

	elseif column == mBans.gui.durationClm then
		guiClick(mBans.gui.setDurBtn)

	elseif column == mBans.gui.reasonClm then
		guiClick(mBans.gui.setReasonBtn)

	elseif column == mBans.gui.adminClm then
		guiClick(mBans.gui.setAdminBtn)

	end

end

function mBans.gui.onRefresh()
	if guiGridListGetVerticalScrollPosition(mBans.gui.list) < 95 then return end
	
	mBans.requestNext()

end

function mBans.gui.onSearchAccepted()
	
	guiFocus(source)

	local filter = guiEditGetParsedValue(source)
	filter.since = filter.since and parseDate(filter.since)
	filter.before = filter.before and parseDate(filter.before)
	mBans.request(filter)

end

function mBans.gui.getSelected()
	return guiGridListGetSelectedItemData(mBans.gui.list, nil, 1)
end

function mBans.gui.refresh()

	local list = mBans.gui.list
	local selected = mBans.gui.getSelected()
	local selectedRow, selectedColumn = guiGridListGetSelectedItem(list)
	guiGridListClear(list)

	for i, data in ipairs(mBans.bans) do
		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, mBans.gui.numClm, i)
		guiGridListSetItemText(list, row, mBans.gui.nickClm, data.nick)
		guiGridListSetItemText(list, row, mBans.gui.ipClm, data.ip)
		guiGridListSetItemText(list, row, mBans.gui.serialClm, data.serial)
		guiGridListSetItemText(list, row, mBans.gui.timeClm, os.date(DATE_FORMAT, data.time))
		guiGridListSetItemText(list, row, mBans.gui.adminClm, data.admin)
		guiGridListSetItemText(list, row, mBans.gui.reasonClm, data.reason)
		if not data.unban or data.unban == 0 then
			guiGridListSetItemText(list, row, mBans.gui.durationClm, "permanent")
			guiGridListSetItemText(list, row, mBans.gui.unbanClm, "never")
			guiGridListSetRowColor(list, row, table.unpack(PERM_COLOR))
		else
			guiGridListSetItemText(list, row, mBans.gui.durationClm, formatDuration(data.unban - data.time))
			guiGridListSetItemText(list, row, mBans.gui.unbanClm, os.date(DATE_FORMAT, data.unban))
		end
		guiGridListSetItemData(list, row, 1, data.id)
	end

	selectedRow = selected and guiGridListGetItemByData(list, selected) or selectedRow 
	guiGridListSetSelectedAnyItem(list, selectedRow, selectedColumn)
	
	return true
end