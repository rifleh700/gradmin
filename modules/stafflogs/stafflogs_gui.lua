
local DATE_FORMAT = "%d/%m/%Y  %H:%M:%S"

local gs = {}
gs.colors = {}
gs.colors.ban = GS.clr.red
gs.colors.mute = GS.clr.red
gs.colors.kick = GS.clr.red
gs.colors.shout = GS.clr.orange
gs.colors.kill = GS.clr.red
gs.colors.slap = GS.clr.orange
gs.colors.updateban = GS.clr.yellow
gs.colors.updatemute = GS.clr.yellow
gs.colors.unban = GS.clr.green
gs.colors.unmute = GS.clr.green

mStaffLogs.gui = {}

function mStaffLogs.gui.init()

	local group = cGUI.getTabGroup("logs", "Logs")
	local tab = guiCreateTab("Staff", group)
	local tw, th = guiGetSize(tab, false)

	mStaffLogs.gui.tab = tab

	local mainVlo = guiCreateVerticalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, nil, false, tab)
	guiSetRawSize(mainVlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(mainVlo, true)

	local srchHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, false, mainVlo)
	guiSetRawWidth(srchHlo, 1, true)
	guiHorizontalLayoutSetWidthFixed(srchHlo, true)

	mStaffLogs.gui.srch = guiCreateSearchEdit(nil, nil, -GS.h - GS.mrg - 1, nil, "", false, srchHlo)
	guiSetRawWidth(mStaffLogs.gui.srch, 1, true)
	guiEditSetParser(mStaffLogs.gui.srch, guiGetInputMapParser())
	mStaffLogs.gui.infoBtn = guiCreateHelpButton(nil, nil, nil, nil, srchHlo)


	mStaffLogs.gui.list = guiCreateGridList(nil, nil, 1, 1, true, mainVlo)
	guiSetRawHeight(mStaffLogs.gui.list, -GS.h - GS.mrg, false)
	guiGridListSetSortingEnabled(mStaffLogs.gui.list, false)
	guiGridListSetSelectionMode(mStaffLogs.gui.list, 2)
	mStaffLogs.gui.numClm = guiGridListAddColumn(mStaffLogs.gui.list, "#", 0.07)
	mStaffLogs.gui.dateClm = guiGridListAddColumn(mStaffLogs.gui.list, "Date", 0.19)
	mStaffLogs.gui.accountClm = guiGridListAddColumn(mStaffLogs.gui.list, "Account", 0.1)
	mStaffLogs.gui.commandClm = guiGridListAddColumn(mStaffLogs.gui.list, "Command", 0.12)
	mStaffLogs.gui.descriptionClm = guiGridListAddColumn(mStaffLogs.gui.list, "Description", 0.3)
	mStaffLogs.gui.nameClm = guiGridListAddColumn(mStaffLogs.gui.list, "Name", 0.1)
	mStaffLogs.gui.plainNameClm = guiGridListAddColumn(mStaffLogs.gui.list, "Plain name", 0.2)
	mStaffLogs.gui.groupsClm = guiGridListAddColumn(mStaffLogs.gui.list, "Groups", 0.2)
	mStaffLogs.gui.serialClm = guiGridListAddColumn(mStaffLogs.gui.list, "Serial", 0.5)
	
	guiRebuildLayouts(tab)
	---------------------------------	

	addEventHandler("onClientGUILeftClick", mStaffLogs.gui.infoBtn, mStaffLogs.gui.onClickInfo, false)
	addEventHandler("onClientGUIAccepted", mStaffLogs.gui.srch, mStaffLogs.gui.onSearchAccepted, false)
	addEventHandler("gra.cGUI.onRefresh", mStaffLogs.gui.tab, mStaffLogs.gui.onRefresh)
	
	return true
end

function mStaffLogs.gui.term()

	destroyElement(mStaffLogs.gui.tab)

	return true
end

function mStaffLogs.gui.onRefresh()
	if guiGridListGetVerticalScrollPosition(mStaffLogs.gui.list) < 95 then return end
	
	mStaffLogs.requestNext()

end

function mStaffLogs.gui.onClickInfo()
	
	guiShowMessageDialog(
		"Available search filter options: since, before, account, command, name, serial, group.\nSearch by partial value is available.\nDate format: Y[n]M[n]D[n]h[n]m[n]s[n] (at least one value required). M5.D3 means 3 May, current year, 00:00:00.\nExample: since:Y2020.M1.D15.h23.m58.s45 before:M5 account:dude123 command:giveplayerweapon name:dude group:admin serial:abc",
		"Information",
		MD_OK, MD_INFO
	)

end

function mStaffLogs.gui.onSearchAccepted()
	
	guiFocus(source)

	local filter = guiEditGetParsedValue(source)
	filter.since = filter.since and parseDate(filter.since)
	filter.before = filter.before and parseDate(filter.before)
	mStaffLogs.request(filter)

end

function mStaffLogs.gui.refresh()

	local list = mStaffLogs.gui.list
	local selectedRow, selectedColumn = guiGridListGetSelectedItem(list)
	guiGridListClear(list)

	for i, data in ipairs(mStaffLogs.logs) do
		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, mStaffLogs.gui.numClm, tostring(i))
		guiGridListSetItemText(list, row, mStaffLogs.gui.dateClm, os.date(DATE_FORMAT, data.timestamp))
		guiGridListSetItemText(list, row, mStaffLogs.gui.commandClm, data.command)
		guiGridListSetItemText(list, row, mStaffLogs.gui.descriptionClm, data.description)
		guiGridListSetItemText(list, row, mStaffLogs.gui.accountClm, data.account)
		guiGridListSetItemText(list, row, mStaffLogs.gui.nameClm, data.name)
		guiGridListSetItemText(list, row, mStaffLogs.gui.plainNameClm, stripColorCodes(data.name))
		guiGridListSetItemText(list, row, mStaffLogs.gui.groupsClm, table.concat(data.groups, ", "))
		guiGridListSetItemText(list, row, mStaffLogs.gui.serialClm, data.serial)
	end
	guiGridListSetSelectedAnyItem(list, selectedRow, selectedColumn)
	
	return true
end