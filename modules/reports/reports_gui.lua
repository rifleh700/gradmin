
local DATE_FORMAT = "%d/%m/%Y  %H:%M:%S"

local gs = {}
gs.clr = {}
gs.clr.accepted = GS.clr.grey
gs.clr.new = GS.clr.yellow

mReports.gui = {}

function mReports.gui.init()

	local tab = cGUI.addTab("Reports")
	mReports.gui.tab = tab

	local mainHlo = guiCreateHorizontalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, GS.mrg2, false, tab)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetSizeFixed(mainHlo, true)

	local listVlo = guiCreateVerticalLayout(nil, nil, nil, 1, nil, true, mainHlo)
	guiVerticalLayoutSetHeightFixed(listVlo, true)

	local srchHlo = guiCreateHorizontalLayout(nil, nil, GS.w32, nil, nil, false, listVlo)
	guiHorizontalLayoutSetWidthFixed(srchHlo, true)
	mReports.gui.srch = guiCreateSearchEdit(nil, nil, -GS.h - GS.mrg - 1, nil, "", false, srchHlo)
	guiSetRawWidth(mReports.gui.srch, 1, true)
	guiEditSetParser(mReports.gui.srch, guiGetInputMapParser())
	mReports.gui.infoBtn = guiCreateHelpButton(nil, nil, nil, nil, srchHlo)

	mReports.gui.list = guiCreateGridList(nil, nil, GS.w32, -GS.h - GS.mrg, false, listVlo)
	guiSetRawHeight(mReports.gui.list, 1, true)
	guiGridListSetSortingEnabled(mReports.gui.list, false)
	mReports.gui.numClm = guiGridListAddColumn(mReports.gui.list, "#", 0.2)
	mReports.gui.nameClm = guiGridListAddColumn(mReports.gui.list, "Name", 0.4)
	mReports.gui.ageClm = guiGridListAddColumn(mReports.gui.list, "Age", 0.4)
	
	local infoVlo = guiCreateVerticalLayout(nil, nil, -GS.w32 - GS.mrg2, 1, nil, false, mainHlo)
	guiSetRawSize(infoVlo, 1, 1, true)
	mReports.gui.infoLayout = infoVlo
	guiVerticalLayoutSetHeightFixed(infoVlo, true)
	
	local infoHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, infoHlo)
	_, mReports.gui.timeVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Date:", nil, nil, vlo)
	_, mReports.gui.adminVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Admin:", nil, nil, vlo)
	guiLabelSetColor(mReports.gui.adminVLbl, table.unpack(GS.clr.green))
	_, mReports.gui.nameVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Name:", nil, nil, vlo)
	_, mReports.gui.accountVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Account:", nil, nil, vlo)
	_, mReports.gui.serialVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w32, nil, "Serial:", nil, nil, vlo)

	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mReports.gui.msgLbl = guiCreateLabel(nil, nil, nil, nil, "Message: ", nil, hlo)
	guiLabelSetHorizontalAlign(mReports.gui.msgLbl, "right")
	guiLabelSetVerticalAlign(mReports.gui.msgLbl, "top")
	mReports.gui.msgVLbl = guiCreateScrollableLabel(nil, nil, GS.w32, GS.h3, nil, false, hlo)

	mReports.gui.acceptBtn = guiCreateButton(nil, nil, nil, nil, "Accept", nil, infoHlo, "command.acceptreport")
	guiButtonSetHoverTextColor(mReports.gui.acceptBtn, table.unpack(GS.clr.green))
	guiCreateHorizontalSeparator(0, 0, 1, true, infoVlo)

	mReports.gui.screenshotsList = guiCreateImageGridList(0, 0, 1, 1, true, infoVlo)
	guiSetRawHeight(mReports.gui.screenshotsList, -(GS.h + GS.mrg)*9 - GS.mrg, false)
	guiImageGridListSetSelectionMode(mReports.gui.screenshotsList, 0)
	guiImageGridListSetColumns(mReports.gui.screenshotsList, 3)
	guiImageGridListSetViewEnabled(mReports.gui.screenshotsList, true)
	mReports.gui.screenshotsLbl = guiCreateLabel(0, 0, 1, 1, nil, true, mReports.gui.screenshotsList)
	guiLabelSetHorizontalAlign(mReports.gui.screenshotsLbl, "center")
	guiLabelSetVerticalAlign(mReports.gui.screenshotsLbl, "center")
	guiSetEnabled(mReports.gui.screenshotsLbl, false)
	mReports.gui.screenshotsBtn = guiCreateButton(0, 0, GS.w3, nil, nil, false, mReports.gui.screenshotsList)
	guiSetHorizontalAlign(mReports.gui.screenshotsBtn, "center")
	guiSetVerticalAlign(mReports.gui.screenshotsBtn, "center")
	guiSetEnabled(mReports.gui.screenshotsBtn, false)
	guiSetVisible(mReports.gui.screenshotsBtn, false)
	
	guiRebuildLayouts(tab)
	---------------------------------	

	addEventHandler("onClientGUILeftClick", mReports.gui.tab, mReports.gui.onClick)
	addEventHandler("onClientGUIGridListItemSelected", mReports.gui.list, function() mReports.gui.refreshReport() end, false)
	addEventHandler("onClientGUIGridListItemDeleteKey", mReports.gui.list, function() guiClick(mReports.gui.removeBtn) end, false)
	addEventHandler("onClientGUIAccepted", mReports.gui.srch, mReports.gui.onSearchAccepted, false)

	addEventHandler("gra.cGUI.onRefresh", mReports.gui.tab, mReports.gui.onRefresh)

	return true
end

function mReports.gui.term()

	destroyElement(mReports.gui.tab)

	return true
end

function mReports.gui.onClick()

	local selectedID = guiGridListGetSelectedItemData(mReports.gui.list)
	if not selectedID then return end
	
	if source == mReports.gui.infoBtn then
		guiShowMessageDialog(
			"Available search filter options: since, before, serial, account, name, admin, message.\nSearch by partial value is available.\nDate format: Y[n]M[n]D[n]h[n]m[n]s[n] (at least one value required). M5.D3 means 3 May, current year, 00:00:00.\nExample: since:Y2020.M1.D15.h23.m58.s45 before:M5 serial:abc admin:adminDude name:dude",
			"Information",
			MD_OK, MD_INFO
		)

	elseif source == mReports.gui.acceptBtn then
		return cCommands.execute("acceptreport", selectedID)

	elseif source == mReports.gui.screenshotsBtn then
		return mReports.requestScreenshots(selectedID)

	end
end

function mReports.gui.onRefresh()
	
	mReports.gui.loadNext()
	mReports.gui.refreshAge()
	
end

function mReports.gui.onSearchAccepted()
	
	guiFocus(source)

	local filter = guiEditGetParsedValue(source)
	filter.since = filter.since and parseDate(filter.since)
	filter.before = filter.before and parseDate(filter.before)
	mReports.request(filter)

end

function mReports.gui.loadNext()
	if guiGridListGetVerticalScrollPosition(mReports.gui.list) < 95 then return false end
	
	return mReports.requestNext()
end

function mReports.gui.refreshReportAccepted(reportID)
	
	local list = mReports.gui.list
	local row = guiGridListGetItemByData(list, reportID)
	if not row then return false end

	local data = mReports.getData(reportID)
	local color = data.admin and gs.clr.accepted or gs.clr.new
	guiGridListSetItemColor(list, row, mReports.gui.numClm, table.unpack(color))
	guiGridListSetItemColor(list, row, mReports.gui.nameClm, table.unpack(color))

	return true
end

function mReports.gui.refreshFresh(fresh)
	
	guiSetText(mReports.gui.tab, "Reports"..(fresh > 0 and string.format(" (%d)", fresh) or ""))

end

function mReports.gui.refreshReport(reportID)

	if reportID then mReports.gui.refreshReportAccepted(reportID) end
	
	local selectedID = guiGridListGetSelectedItemData(mReports.gui.list)
	if reportID and reportID ~= selectedID then return true end

	guiSetText(mReports.gui.timeVLbl)
	guiSetText(mReports.gui.adminVLbl)
	guiSetText(mReports.gui.nameVLbl)
	guiSetText(mReports.gui.accountVLbl)
	guiSetText(mReports.gui.serialVLbl)
	guiSetText(mReports.gui.msgVLbl)
	guiLabelAdjustHeight(mReports.gui.msgVLbl)
	guiImageGridListClear(mReports.gui.screenshotsList)
	guiSetText(mReports.gui.screenshotsLbl)
	guiSetVisible(mReports.gui.screenshotsLbl, true)
	guiSetEnabled(mReports.gui.screenshotsBtn, false)
	guiSetVisible(mReports.gui.screenshotsBtn, false)
	guiSetEnabled(mReports.gui.infoLayout, false)

	if not selectedID then return true end

	local data = mReports.getData(selectedID)
	guiSetEnabled(mReports.gui.infoLayout, true)
	guiSetText(mReports.gui.timeVLbl,
		string.format("%s  (%s ago)", os.date(DATE_FORMAT, data.time), formatDuration(cTime.get() - data.time, true))
	)
	guiSetText(mReports.gui.adminVLbl, data.admin and stripColorCodes(data.admin))
	guiSetEnabled(mReports.gui.adminVLbl, data.admin and true or false)
	guiSetText(mReports.gui.nameVLbl, stripColorCodes(data.name))
	guiSetText(mReports.gui.accountVLbl, data.account)
	guiSetText(mReports.gui.serialVLbl, data.serial)
	guiSetText(mReports.gui.msgVLbl, data.message)
	guiLabelAdjustHeight(mReports.gui.msgVLbl)
	guiSetEnabled(mReports.gui.acceptBtn, not data.admin)

	if data.screenshots > 0 then
		guiSetVisible(mReports.gui.screenshotsLbl, false)
		if mReports.screenshots[selectedID] then
			for number = 1, data.screenshots do
				local path = mReports.getScreenshotPath(selectedID, number)
				if path then
					local item = guiImageGridListAddItem(mReports.gui.screenshotsList, path)
					guiImageGridListSetItemData(mReports.gui.screenshotsList, item, number)
				end
			end
		else
			if mReports.requested[selectedID] then
				guiSetVisible(mReports.gui.screenshotsLbl, true)
				guiSetText(mReports.gui.screenshotsLbl, "Loading "..data.screenshots.." screenshots...")
			else
				guiSetVisible(mReports.gui.screenshotsBtn, true)
				guiSetEnabled(mReports.gui.screenshotsBtn, true)
				guiSetText(mReports.gui.screenshotsBtn, "Load "..data.screenshots.." screenshots")
			end
		end
	end

	return true
end

function mReports.gui.refreshAge()
	
	local list = mReports.gui.list
	for row = 0, guiGridListGetRowCount(list) - 1 do
		local time = guiGridListGetItemData(list, row, mReports.gui.ageClm)
		guiGridListSetItemText(list, row, mReports.gui.ageClm, formatDuration(cTime.get() - time, true))
	end

	local selected = guiGridListGetSelectedItem(list)
	if selected == -1 then return true end

	local time = guiGridListGetItemData(list, selected, mReports.gui.ageClm)
	guiSetText(mReports.gui.timeVLbl,
		string.format("%s  (%s ago)", os.date(DATE_FORMAT, time), formatDuration(cTime.get() - time, true))
	)

	return true
end

function mReports.gui.refresh()

	local list = mReports.gui.list
	local selected = guiGridListGetSelectedItemData(list)
	local selectedRow = guiGridListGetSelectedItem(list)
	guiGridListClear(list)

	for i, data in ipairs(mReports.reports) do
		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, mReports.gui.numClm, data.id)
		guiGridListSetItemText(list, row, mReports.gui.nameClm, stripColorCodes(data.name))
		guiGridListSetItemText(list, row, mReports.gui.ageClm, formatDuration(cTime.get() - data.time, true))
		guiGridListSetItemData(list, row, 1, data.id)
		guiGridListSetItemData(list, row, mReports.gui.ageClm, data.time)
		
		local color = data.admin and gs.clr.accepted or gs.clr.new
		guiGridListSetItemColor(list, row, mReports.gui.numClm, table.unpack(color))
		guiGridListSetItemColor(list, row, mReports.gui.nameClm, table.unpack(color))
	end

	selectedRow = selected and guiGridListGetItemByData(list, selected) or selectedRow
	guiGridListSetSelectedAnyItem(list, selectedRow)
	
	return true
end