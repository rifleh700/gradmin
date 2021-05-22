
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

mPenaltyLogs.gui = {}

function mPenaltyLogs.gui.init()

	local group = cGUI.getTabGroup("logs", "Logs")
	local tab = guiCreateTab("Penalties", group)
	local tw, th = guiGetSize(tab, false)

	mPenaltyLogs.gui.tab = tab

	local mainVlo = guiCreateVerticalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, nil, false, tab)
	guiSetRawSize(mainVlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(mainVlo, true)

	local srchHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, false, mainVlo)
	guiSetRawWidth(srchHlo, 1, true)
	guiHorizontalLayoutSetWidthFixed(srchHlo, true)

	mPenaltyLogs.gui.srch = guiCreateSearchEdit(nil, nil, -GS.h - GS.mrg - 1, nil, "", false, srchHlo)
	guiSetRawWidth(mPenaltyLogs.gui.srch, 1, true)
	guiEditSetParser(mPenaltyLogs.gui.srch, guiGetInputMapParser())
	mPenaltyLogs.gui.infoBtn = guiCreateHelpButton(nil, nil, nil, nil, srchHlo)

	mPenaltyLogs.gui.list = guiCreateGridList(0, 0, 1, 1, true, mainVlo)
	guiSetRawHeight(mPenaltyLogs.gui.list, -GS.h - GS.mrg, false)
	guiGridListSetSortingEnabled(mPenaltyLogs.gui.list, false)
	guiGridListSetSelectionMode(mPenaltyLogs.gui.list, 0)
	mPenaltyLogs.gui.numClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "#", 0.05)
	mPenaltyLogs.gui.dateClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "Date", 0.2)
	mPenaltyLogs.gui.adminClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "Admin", 0.1)
	mPenaltyLogs.gui.actionClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "Action", 0.1)
	mPenaltyLogs.gui.serialClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "Serial", 0.1)
	mPenaltyLogs.gui.reasonClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "Reason", 0.1)
	mPenaltyLogs.gui.durationClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "Duration", 0.1)
	mPenaltyLogs.gui.updateClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "Update", 0.1)
	mPenaltyLogs.gui.valueClm = guiGridListAddColumn(mPenaltyLogs.gui.list, "Value", 0.1)

	guiRebuildLayouts(tab)
	---------------------------------	

	addEventHandler("onClientGUILeftClick", mPenaltyLogs.gui.infoBtn, mPenaltyLogs.gui.onClickInfo, false)
	addEventHandler("onClientGUIAccepted", mPenaltyLogs.gui.srch, mPenaltyLogs.gui.onSearchAccepted, false)
	addEventHandler("gra.cGUI.onRefresh", mPenaltyLogs.gui.tab, mPenaltyLogs.gui.onRefresh)
	
	return true
end

function mPenaltyLogs.gui.term()

	destroyElement(mPenaltyLogs.gui.tab)

	return true
end

function mPenaltyLogs.gui.onRefresh()
	if guiGridListGetVerticalScrollPosition(mPenaltyLogs.gui.list) < 95 then return end
	
	mPenaltyLogs.requestNext()

end

function mPenaltyLogs.gui.onClickInfo()
	
	guiShowMessageDialog(
		"Available search filter options: since, before, admin, action, serial.\nSearch by partial value is available.\nDate format: Y[n]M[n]D[n]h[n]m[n]s[n] (at least one value required). M5.D3 means 3 May, current year, 00:00:00.\nExample: since:Y2020.M1.D15.h23.m58.s45 before:M5 admin:dude action:ban serial:abc",
		"Information",
		MD_OK, MD_INFO
	)

end

function mPenaltyLogs.gui.onSearchAccepted()
	
	guiFocus(source)

	local filter = guiEditGetParsedValue(source)
	filter.since = filter.since and parseDate(filter.since)
	filter.before = filter.before and parseDate(filter.before)
	mPenaltyLogs.request(filter)

end

function mPenaltyLogs.gui.refresh()

	local list = mPenaltyLogs.gui.list
	local selectedRow, selectedColumn = guiGridListGetSelectedItem(list)
	guiGridListClear(list)

	for i, data in ipairs(mPenaltyLogs.logs) do
		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, mPenaltyLogs.gui.numClm, tostring(i))
		guiGridListSetItemText(list, row, mPenaltyLogs.gui.dateClm, os.date(DATE_FORMAT, data.timestamp))
		guiGridListSetItemText(list, row, mPenaltyLogs.gui.serialClm, data.serial)
		guiGridListSetItemText(list, row, mPenaltyLogs.gui.actionClm, data.action)
		guiGridListSetItemText(list, row, mPenaltyLogs.gui.adminClm, data.admin_account)
		guiGridListSetItemData(list, row, 1, data.id)
		guiGridListSetRowColor(list, row, table.unpack(gs.colors[data.action] or GS.clr.white))

		for column = mPenaltyLogs.gui.reasonClm, mPenaltyLogs.gui.valueClm do
			guiGridListSetItemText(list, row, column)
		end

		local info = data.data or {}

		if utf8.match(data.action, "^update") then
			local key, value = pairs(info)(info)
			if key and value then
				guiGridListSetItemText(list, row, mPenaltyLogs.gui.updateClm, key)				
				value = key == "duration" and formatDuration(value) or value
				guiGridListSetItemText(list, row, mPenaltyLogs.gui.valueClm, value)
			end
		else
			guiGridListSetItemText(list, row, mPenaltyLogs.gui.reasonClm, info.reason)
			guiGridListSetItemText(list, row, mPenaltyLogs.gui.durationClm, info.duration and formatDuration(info.duration))
		end
	end
	guiGridListSetSelectedAnyItem(list, selectedRow, selectedColumn)
	
	return true
end