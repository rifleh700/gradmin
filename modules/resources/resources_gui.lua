
local gs = {}
gs.colors = {
	["running"] = GS.clr.green,
	["loaded"] = GS.clr.grey,
	["failed to load"] = GS.clr.red
}

mResources.gui = {}

function mResources.gui.init()

	local group = cGUI.getTabGroup("dev", "Dev")
	local tab = guiCreateTab("Resources", group)
	mResources.gui.tab = tab

	local mainHlo = guiCreateHorizontalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, GS.mrg2, false, tab)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetSizeFixed(mainHlo, true)
	
	local listVlo = guiCreateVerticalLayout(nil, nil, nil, 1, nil, true, mainHlo)
	guiVerticalLayoutSetHeightFixed(listVlo, true)

	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, listVlo)
	mResources.gui.srch = guiCreateSearchEdit(nil, nil, nil, nil, "", nil, hlo)
	mResources.gui.viewCmb, mResources.gui.viewList =
		guiCreateAdvancedComboBox(nil, nil, nil, nil, "all", nil, hlo)
	guiGridListAddRow(mResources.gui.viewList, "all")
	mResources.gui.list = guiCreateGridList(nil, nil, nil, nil, false, listVlo)
	guiSetTableProperty(mResources.gui.list, "UnifiedHeight", {1, -(GS.h + GS.mrg)*2})
	mResources.gui.nameClm = guiGridListAddColumn(mResources.gui.list, "Resource", 0.60)
	mResources.gui.stateClm = guiGridListAddColumn(mResources.gui.list, "State", 0.28)
	mResources.gui.refreshListBtn = guiCreateButton(nil, nil, GS.w3, nil, "Refresh", nil, listVlo)
	
	local infoVlo = guiCreateVerticalLayout(nil, nil, nil, 1, nil, true, mainHlo)
	guiSetRawWidth(infoVlo, -GS.w3 - GS.mrg*2, false)
	guiVerticalLayoutSetHeightFixed(infoVlo, true)
	mResources.gui.infoVlo = infoVlo

	local mainInfoHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, false, mainInfoHlo)
	
	mResources.gui.nameLbl, mResources.gui.nameVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Name:", nil, nil, vlo)
	mResources.gui.authorLbl, mResources.gui.authorVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Author:", nil, nil, vlo)
	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mResources.gui.typeLbl, mResources.gui.typeVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Type:", nil, nil, hlo)
	mResources.gui.versionLbl, mResources.gui.versionVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Version:", nil, nil, hlo)
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mResources.gui.descriptionLbl = guiCreateLabel(nil, nil, nil, nil, "Description:", nil, hlo)
	guiLabelSetHorizontalAlign(mResources.gui.descriptionLbl, "right")
	guiLabelSetVerticalAlign(mResources.gui.descriptionLbl, "top")
	mResources.gui.descriptionVLbl = guiCreateScrollableLabel(nil, nil, GS.w4 - GS.mrg2*2, GS.h3, nil, false, hlo)

	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainInfoHlo)

	mResources.gui.startBtn = guiCreateButton(nil, nil, nil, nil, "Start", nil, vlo, "command.start")
	mResources.gui.restartBtn = guiCreateButton(nil, nil, nil, nil, "Restart", nil, vlo, "command.restart")
	mResources.gui.stopBtn = guiCreateButton(nil, nil, nil, nil, "Stop", nil, vlo, "command.stop")
	mResources.gui.refreshBtn = guiCreateButton(nil, nil, nil, nil, "Refresh", nil, vlo, "command.refresh")

	mResources.gui.tpnl = guiCreateTabPanel(nil, nil, 1, 1, true, infoVlo)
	guiSetTableProperty(mResources.gui.tpnl, "UnifiedHeight", {1, -(GS.h + GS.mrg)*7})
	
	guiRebuildLayouts(tab)
	
	mResources.gui.settingsTab = guiCreateTab("Settings", mResources.gui.tpnl)
	vlo = guiCreateVerticalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, nil, false, mResources.gui.settingsTab)
	guiSetRawSize(vlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(vlo, true)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")

	local btnHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mResources.gui.settingsResetBtn = guiCreateButton(nil, nil, nil, nil, "Reset all", nil, btnHlo, "command.setsetting")
	
	mResources.gui.settingsList = guiCreateGridList(nil, nil, 1, 1, true, vlo)
	guiSetRawHeight(mResources.gui.settingsList, -GS.h - GS.mrg, false)
	mResources.gui.settingsNameClm = guiGridListAddColumn(mResources.gui.settingsList, "Name", 0.44)
	mResources.gui.settingsCurrClm = guiGridListAddColumn(mResources.gui.settingsList, "Current", 0.24)
	mResources.gui.settingsDefClm = guiGridListAddColumn(mResources.gui.settingsList, "Default", 0.20)
	guiGridListSetSortingEnabled(mResources.gui.settingsList, false)

	mResources.gui.requestsTab = guiCreateTab("Rights requests", mResources.gui.tpnl)
	vlo = guiCreateVerticalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, nil, false, mResources.gui.requestsTab)
	guiSetRawSize(vlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(vlo, true)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")
	
	btnHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mResources.gui.requestsDenyAllBtn = guiCreateButton(nil, nil, nil, nil, "Deny all", false, btnHlo, "command.aclrequest")
	mResources.gui.requestsAllowAllBtn = guiCreateButton(nil, nil, nil, nil, "Allow all", false, btnHlo, "command.aclrequest")

	mResources.gui.requestsList = guiCreateGridList(nil, nil, 1, 1, true, vlo)
	guiSetRawHeight(mResources.gui.requestsList, -GS.h - GS.mrg, false)
	mResources.gui.requestsRightClm = guiGridListAddColumn(mResources.gui.requestsList, "Right", 0.4)
	mResources.gui.requestsAccessClm = guiGridListAddColumn(mResources.gui.requestsList, "Access", 0.1)
	mResources.gui.requestsPendingClm = guiGridListAddColumn(mResources.gui.requestsList, "Pending", 0.15)
	mResources.gui.requestsWhoClm = guiGridListAddColumn(mResources.gui.requestsList, "Who", 0.3)
	mResources.gui.requestsDateClm = guiGridListAddColumn(mResources.gui.requestsList, "Date", 0.4)
	guiGridListSetSortingEnabled(mResources.gui.requestsList, false)

	guiRebuildLayouts(tab)

	---------------------------------
	
	addEventHandler("onClientGUILeftClick", tab, mResources.gui.onClick)
	addEventHandler("onClientGUIDoubleLeftClick", tab, mResources.gui.onDoubleClick)
	addEventHandler("onClientGUIGridListItemSelected", mResources.gui.list, function() mResources.gui.refreshResource() end, false)
	addEventHandler("onClientGUIGridListItemSelected", mResources.gui.viewList, mResources.gui.refreshList, false)
	addEventHandler("onClientGUIChanged", mResources.gui.srch, mResources.gui.refreshList, false)

	return true
end

function mResources.gui.term()

	destroyElement(mResources.gui.tab)

	return true
end

function mResources.gui.onClick()
	if getElementType(source) ~= "gui-button" then return end

	if source == mResources.gui.refreshListBtn then return mResources.refresh() end

	local resourceName = mResources.gui.getSelected()
	if not resourceName then return end

	if source == mResources.gui.startBtn then return cCommands.execute("start", resourceName) end
	if source == mResources.gui.restartBtn then return cCommands.execute("restart", resourceName) end
	if source == mResources.gui.stopBtn then return cCommands.execute("stop", resourceName) end
	if source == mResources.gui.refreshBtn then return cCommands.execute("refresh", resourceName) end

	if source == mResources.gui.settingsResetBtn then
		if not guiShowMessageDialog("All resource '"..resourceName.."' setting will be set to default values. Continue?", "Reset settings", MD_OK_CANCEL, MD_QUESTION) then return end
		local settings = mResources.data[resourceName].settings
		for name, data in pairs(settings) do
			if data.current ~= data.default then
				cCommands.execute("setsetting", resourceName, name, data.default)
			end
		end
	
	elseif source == mResources.gui.requestsAllowAllBtn or
	source == mResources.gui.requestsDenyAllBtn then
		local access = source == mResources.gui.requestsAllowAllBtn
		if not guiShowMessageDialog("All requested permission will be set to '"..tostring(access).."'. Continue?", "Rights requests", MD_OK_CANCEL, MD_QUESTION) then return end

		local requests = mResources.data[resourceName].requests
		for i, data in ipairs(requests) do
			if data.access ~= access then
				cCommands.execute("aclrequest", resourceName, data.name, access)
			end
		end

	end
end

function mResources.gui.onDoubleClick()

	if source == mResources.gui.settingsList then
		if not cSession.hasPermissionTo("command.setsetting") then return end

		local resourceName = mResources.gui.getSelected()
		if not resourceName then return end
	
		local setting = mResources.gui.getSelectedSetting()
		if not setting then return end
	
		local data = mResources.data[resourceName].settings[setting]
		local name = data.friendlyname or setting
		
		local value = guiShowInputDialog("Change setting", "Enter new value for '"..name.."'", tostring(data.current), guiGetInputNotEmptyParser(), true)
		if value == false then return end
		if value == nil then value = data.default end

		cCommands.execute("setsetting", resourceName, setting, value)
	
	elseif source == mResources.gui.requestsList then
		if not cSession.hasPermissionTo("command.aclrequest") then return end

		local resourceName = mResources.gui.getSelected()
		if not resourceName then return end
	
		local right, access = mResources.gui.getSelectedRight()
		if not right then return end
	
		access = not access
		if not guiShowMessageDialog("Permission '"..right.."' for '"..resourceName.."' resource will be set to '"..tostring(access).."'. Continue?", "Right request", MD_OK_CANCEL, MD_QUESTION) then return end
		
		cCommands.execute("aclrequest", resourceName, right, access)

	end
end

function mResources.gui.getSelected()
	return guiGridListGetSelectedItemText(mResources.gui.list)
end

function mResources.gui.getSelectedSetting()
	return guiGridListGetSelectedItemData(mResources.gui.settingsList)
end

function mResources.gui.getSelectedRight()
	
	local row = guiGridListGetSelectedItem(mResources.gui.requestsList)
	if row == -1 then return end

	return guiGridListGetItemText(mResources.gui.requestsList, row, mResources.gui.requestsRightClm), guiGridListGetItemText(mResources.gui.requestsList, row, mResources.gui.requestsAccessClm) == "true"
end

function mResources.gui.refreshResourceState(resourceName)
	
	local row = guiGridListGetRowByText(mResources.gui.list, resourceName)
	if not row then return false end
	
	local state = mResources.getState(resourceName)
	guiGridListSetItemText(mResources.gui.list, row, mResources.gui.stateClm, state, false, false)
	row = guiGridListGetRowByText(mResources.gui.list, resourceName)
	guiGridListSetItemColor(mResources.gui.list, row, mResources.gui.stateClm, unpack(gs.colors[state] or COLORS.yellow))
	
	return true
end

function mResources.gui.refreshResourceInfo(resourceName)
	
	guiSetText(mResources.gui.nameVLbl)
	guiSetText(mResources.gui.typeVLbl)
	guiSetText(mResources.gui.authorVLbl)
	guiSetText(mResources.gui.versionVLbl)
	guiSetText(mResources.gui.descriptionVLbl)
	guiLabelAdjustHeight(mResources.gui.descriptionVLbl)
	guiSetEnabled(mResources.gui.startBtn, false)
	guiSetEnabled(mResources.gui.restartBtn, false)
	guiSetEnabled(mResources.gui.stopBtn, false)
	
	if not resourceName then return true end

	local state = mResources.getState(resourceName)
	guiSetEnabled(mResources.gui.startBtn, state == "loaded")
	guiSetEnabled(mResources.gui.restartBtn, state == "running")
	guiSetEnabled(mResources.gui.stopBtn, state == "running")

	local info = mResources.data[resourceName]
	if not info then return false end

	guiSetText(mResources.gui.nameVLbl, info.name or resourceName)
	guiSetText(mResources.gui.typeVLbl, info.type)
	guiSetText(mResources.gui.authorVLbl, info.author)
	guiSetText(mResources.gui.versionVLbl, info.version)

	guiSetText(mResources.gui.descriptionVLbl, info.description)
	guiLabelAdjustHeight(mResources.gui.descriptionVLbl)

	return true
end

function mResources.gui.refreshResourceSettings(resourceName)

	local list = mResources.gui.settingsList
	local selected = guiGridListGetSelectedItem(list)
	guiGridListClear(list)
	guiSetEnabled(list, false)
	guiSetStatusText(list, "N/A")
	guiSetEnabled(mResources.gui.settingsResetBtn, false)

	if not resourceName then return true end
	if not mResources.data[resourceName] then return false end
	if not mResources.data[resourceName].settings then return false end

	guiSetStatusText(list, NIL_TEXT)

	local anychanged = false
	local settings = mResources.data[resourceName].settings

	local misc = {}
	local groups = {}
	local bygroups = {}
	for name, data in pairs(settings) do
		if data.group then
			if not bygroups[data.group] then
				groups[#groups + 1] = data.group
				bygroups[data.group] = {}
			end
			bygroups[data.group][#bygroups[data.group] + 1] = name
		else
			misc[#misc + 1] = name
		end
		anychanged = anychanged or data.current ~= data.default
	end
	
	table.sort(groups, function(a, b) return (a < b) end)
	if #misc > 0 then
		groups[#groups + 1] = "Misc"
		bygroups["Misc"] = misc
	end
	if #groups == 0 then return end 

	for i, group in ipairs(groups) do
		local names = bygroups[group]
		table.sort(names, function(a, b) return (a < b) end)

		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, 1, group, true, false)
		for is, name in ipairs(names) do
			local value = settings[name]
			row = guiGridListAddRow(list)
			guiGridListSetItemText(list, row, mResources.gui.settingsNameClm, tostring(value.friendlyname or name), false, false)
			guiGridListSetItemText(list, row, mResources.gui.settingsCurrClm, tostring(value.current), false, false)
			guiGridListSetItemText(list, row, mResources.gui.settingsDefClm, tostring(value.default), false, false)
			guiGridListSetItemData(list, row, mResources.gui.settingsNameClm, tostring(name))
			
			if value.current ~= value.default then
				guiGridListSetItemColor(list, row, mResources.gui.settingsNameClm, unpack(COLORS.yellow))
				guiGridListSetItemColor(list, row, mResources.gui.settingsCurrClm, unpack(COLORS.yellow))
			end
		end
	end

	if guiGridListGetRowCount(list) > 0 then
		guiSetEnabled(list, true)
		guiSetStatusText(list)
		guiGridListSetSelectedItem(list, selected)
		guiSetEnabled(mResources.gui.settingsResetBtn, anychanged)
	end

	return true
end

function mResources.gui.refreshResourceRequests(resourceName)
	
	local list = mResources.gui.requestsList
	guiGridListClear(list)
	guiSetEnabled(list, false)
	guiSetStatusText(list, "N/A")
	guiSetEnabled(mResources.gui.requestsAllowAllBtn, false)
	guiSetEnabled(mResources.gui.requestsDenyAllBtn, false)

	if not resourceName then return true end
	if not mResources.data[resourceName] then return false end
	if not mResources.data[resourceName].requests then return false end

	guiSetStatusText(list, NIL_TEXT)

	local requests = mResources.data[resourceName].requests
	if #requests == 0 then return true end

	guiSetEnabled(list, true)
	guiSetStatusText(list)

	local anydenied = false
	local anyallowed = false

	for i, request in ipairs(requests) do

		anyallowed = anyallowed or request.access == true
		anydenied = anydenied or request.access == false

		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, mResources.gui.requestsRightClm, request.name, false, false)
		guiGridListSetItemText(list, row, mResources.gui.requestsAccessClm, tostring(request.access), false, false)
		guiGridListSetItemText(list, row, mResources.gui.requestsPendingClm, tostring(request.pending), false, false)
		guiGridListSetItemText(list, row, mResources.gui.requestsWhoClm, tostring(request.who), false, false)
		guiGridListSetItemText(list, row, mResources.gui.requestsDateClm, tostring(request.date), false, false)
		
		local clr = request.pending == true and COLORS.yellow or COLORS.green
		guiGridListSetItemColor(list, row, mResources.gui.requestsPendingClm, unpack(clr))

		clr = request.access == true and COLORS.white or COLORS.grey
		guiGridListSetItemColor(list, row, mResources.gui.requestsRightClm, unpack(clr))
		guiGridListSetItemColor(list, row, mResources.gui.requestsAccessClm, unpack(clr))
	end

	guiSetEnabled(mResources.gui.requestsAllowAllBtn, anydenied)
	guiSetEnabled(mResources.gui.requestsDenyAllBtn, anyallowed)

	return true
end

function mResources.gui.refreshResource(resourceName)

	local selected = mResources.gui.getSelected()
	if resourceName and resourceName ~= selected then return true end

	guiSetEnabled(mResources.gui.infoVlo, false)
	if not selected then return false end
	
	guiSetEnabled(mResources.gui.infoVlo, true)
	resourceName = selected
	mResources.gui.refreshResourceInfo(resourceName)
	mResources.gui.refreshResourceSettings(resourceName)
	mResources.gui.refreshResourceRequests(resourceName)

	if resourceName and not mResources.data[resourceName] then
		mResources.request(resourceName)
	end

	return true
end

function mResources.gui.refreshList()

	local selected = mResources.gui.getSelected()
	local list = mResources.gui.list
	guiGridListClear(list)
	guiSetStatusText(list, "N/A")

	if #mResources.list == 0 then return false end

	guiSetStatusText(list)

	local view = guiGetText(mResources.gui.viewCmb)
	local search = guiGetText(mResources.gui.srch)

	for i, data in ipairs(mResources.list) do
		if (view == "all" or data.group == view) and utf8.find(data.name, search, 1, true, true) then
			local row = guiGridListAddRow(list, data.name, data.state)
			guiGridListSetItemColor(list, row, mResources.gui.stateClm, table.unpack(gs.colors[data.state] or GS.clr.yellow))
			if selected == data.name then guiGridListSetSelectedItem(list, row, 1) end
		end
	end

	if guiGridListGetSelectedItem(list) == -1 and guiGridListGetRowCount(list) > 0 then
		guiGridListSetSelectedItem(list, 0, 1)
	end

	return true
end

function mResources.gui.refreshView()

	local selected = guiGridListGetSelectedItemText(mResources.gui.viewList)

	guiGridListClear(mResources.gui.viewList)
	guiGridListAddRow(mResources.gui.viewList, "all")
	guiGridListSetSelectedItem(mResources.gui.viewList, 0)

	if #mResources.list == 0 then return false end

	local groups = {}
	for i, data in ipairs(mResources.list) do
		if not table.index(groups, data.group) then table.insert(groups, data.group) end
	end
	for i, group in ipairs(groups) do
		local row = guiGridListAddRow(mResources.gui.viewList, group)
		if selected == group then
			guiGridListSetSelectedItem(mResources.gui.viewList, row)
		end
	end
	guiGridListAdjustHeight(mResources.gui.viewList)

	return true
end

function mResources.gui.refresh()

	mResources.gui.refreshView()
	mResources.gui.refreshList()
	mResources.gui.refreshResource()

	return true
end