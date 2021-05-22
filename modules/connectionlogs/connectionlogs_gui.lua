
local DATE_FORMAT = "%d/%m/%Y  %H:%M:%S"

mConnectionLogs.gui = {}

function mConnectionLogs.gui.init()

	local group = cGUI.getTabGroup("logs", "Logs")
	local tab = guiCreateTab("Connections", group)
	mConnectionLogs.gui.tab = tab

	local mainVlo = guiCreateVerticalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, nil, false, tab)
	guiSetRawSize(mainVlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(mainVlo, true)

	local srchHlo = guiCreateHorizontalLayout(nil, nil, -GS.w3 - GS.mrg, nil, nil, false, mainVlo)
	guiSetRawWidth(srchHlo, 1, true)
	guiHorizontalLayoutSetWidthFixed(srchHlo, true)

	mConnectionLogs.gui.srch = guiCreateSearchEdit(nil, nil, -GS.h - GS.mrg - 1, nil, "", false, srchHlo)
	guiSetRawWidth(mConnectionLogs.gui.srch, 1, true)
	guiEditSetParser(mConnectionLogs.gui.srch, guiGetInputMapParser())
	mConnectionLogs.gui.infoBtn = guiCreateHelpButton(nil, nil, nil, nil, srchHlo)

	local mainHlo = guiCreateHorizontalLayout(nil, nil, nil, -GS.h - GS.mrg, nil, false, mainVlo)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetSizeFixed(mainHlo, true)

	mConnectionLogs.gui.list = guiCreateGridList(nil, nil, -GS.w3 - GS.mrg, 0, false, mainHlo)
	guiSetRawSize(mConnectionLogs.gui.list, 1, 1, true)
	guiGridListSetSortingEnabled(mConnectionLogs.gui.list, false)
	guiGridListSetSelectionMode(mConnectionLogs.gui.list, 0)
	mConnectionLogs.gui.numClm = guiGridListAddColumn(mConnectionLogs.gui.list, "#", 0.08)
	mConnectionLogs.gui.dateClm = guiGridListAddColumn(mConnectionLogs.gui.list, "Date", 0.25)
	mConnectionLogs.gui.actionClm = guiGridListAddColumn(mConnectionLogs.gui.list, "Action", 0.1)
	mConnectionLogs.gui.nameClm = guiGridListAddColumn(mConnectionLogs.gui.list, "Name", 0.1)
	mConnectionLogs.gui.plainNameClm = guiGridListAddColumn(mConnectionLogs.gui.list, "Plain name", 0.15)
	mConnectionLogs.gui.accountClm = guiGridListAddColumn(mConnectionLogs.gui.list, "Account", 0.15)
	mConnectionLogs.gui.serialClm = guiGridListAddColumn(mConnectionLogs.gui.list, "Serial", 0.1)
	mConnectionLogs.gui.ipClm = guiGridListAddColumn(mConnectionLogs.gui.list, "IP", 0.15)
	
	mConnectionLogs.gui.dataList = guiCreateGridList(nil, nil, GS.w3, 0, false, mainHlo)
	guiSetRawHeight(mConnectionLogs.gui.dataList, 1, true)
	guiGridListSetSortingEnabled(mConnectionLogs.gui.dataList, false)
	mConnectionLogs.gui.dataListKeyClm = guiGridListAddColumn(mConnectionLogs.gui.dataList, "Key", 0.4)
	mConnectionLogs.gui.dataListValueClm = guiGridListAddColumn(mConnectionLogs.gui.dataList, "Value", 0.4)

	guiRebuildLayouts(tab)
	---------------------------------	

	addEventHandler("onClientGUIGridListItemSelected", mConnectionLogs.gui.list, mConnectionLogs.gui.refreshData, false)
	addEventHandler("onClientGUIAccepted", mConnectionLogs.gui.srch, mConnectionLogs.gui.onSearchAccepted, false)
	addEventHandler("onClientGUILeftClick", mConnectionLogs.gui.infoBtn, mConnectionLogs.gui.onClickInfo, false)
	addEventHandler("gra.cGUI.onRefresh", mConnectionLogs.gui.tab, mConnectionLogs.gui.onRefresh)
	
	return true
end

function mConnectionLogs.gui.term()

	destroyElement(mConnectionLogs.gui.tab)

	return true
end

function mConnectionLogs.gui.onRefresh()
	if guiGridListGetVerticalScrollPosition(mConnectionLogs.gui.list) < 95 then return end
	
	mConnectionLogs.requestNext()

end

function mConnectionLogs.gui.onClickInfo()
	
	guiShowMessageDialog(
		"Available search filter options: since, before, action, serial, ip, name, account.\nSearch by partial value is available.\nDate format: Y[n]M[n]D[n]h[n]m[n]s[n] (at least one value required). M5.D3 means 3 May, current year, 00:00:00.\nExample: since:Y2020.M1.D15.h23.m58.s45 before:M5 action:quit serial:abc ip:127.0.0.1 name:randomdude account:dude123",
		"Information",
		MD_OK, MD_INFO
	)

end

function mConnectionLogs.gui.onSearchAccepted()
	
	guiFocus(source)

	local filter = guiEditGetParsedValue(source)
	filter.since = filter.since and parseDate(filter.since)
	filter.before = filter.before and parseDate(filter.before)
	mConnectionLogs.request(filter)

end

function mConnectionLogs.gui.refreshData()
	
	local list = mConnectionLogs.gui.dataList
	guiGridListClear(list)
	guiSetEnabled(list, false)

	local data = guiGridListGetSelectedItemData(mConnectionLogs.gui.list)
	if not data then return true end

	for k, v in pairs(data) do
		guiGridListAddRow(list, utf8.upperf(k), v)
	end
	guiSetEnabled(list, true)

	return true
end

function mConnectionLogs.gui.refresh()

	local list = mConnectionLogs.gui.list
	local selectedRow, selectedColumn = guiGridListGetSelectedItem(list)
	guiGridListClear(list)

	for i, data in ipairs(mConnectionLogs.logs) do
		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, mConnectionLogs.gui.numClm, tostring(i))
		guiGridListSetItemText(list, row, mConnectionLogs.gui.dateClm, os.date(DATE_FORMAT, data.timestamp))
		guiGridListSetItemText(list, row, mConnectionLogs.gui.actionClm, data.action)
		guiGridListSetItemText(list, row, mConnectionLogs.gui.serialClm, data.serial)
		guiGridListSetItemText(list, row, mConnectionLogs.gui.ipClm, data.ip)
		guiGridListSetItemText(list, row, mConnectionLogs.gui.nameClm, data.name)
		guiGridListSetItemText(list, row, mConnectionLogs.gui.plainNameClm, stripColorCodes(data.name))
		guiGridListSetItemText(list, row, mConnectionLogs.gui.accountClm, data.account or nil)
		guiGridListSetItemData(list, row, 1, data.data)
	end
	guiGridListSetSelectedAnyItem(list, selectedRow, selectedColumn)
	
	return true
end