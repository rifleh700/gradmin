
local gridPlayersList = {}

gridPlayersList.lists = {}

function gridPlayersList.refresh(list)
	
	local selected = guiGridListGetSelectedItemData(list)
	local selectedRow = guiGridListGetSelectedItem(list)

	guiGridListClear(list)
	for i, player in ipairs(getElementsByType("player")) do
		local row = guiGridListAddRow(list, getPlayerName(player, true))
		guiGridListSetItemData(list, row, 1, player)
	end

	if guiGridListGetAutoSearchEdit(list) then guiGridListAutoSearchEditReloadItems(list) end

	selectedRow = selected and guiGridListGetItemByData(list, selected) or selectedRow
	guiGridListSetSelectedAnyItem(list, selectedRow)

	return true
end

function gridPlayersList.onJoin()
	
	for i, list in ipairs(gridPlayersList.lists) do
		local row = guiGridListAddRow(list, getPlayerName(source, true))
		guiGridListSetItemData(list, row, 1, source)
		if guiGridListGetAutoSearchEdit(list) then guiGridListAutoSearchEditReloadItems(list) end
	end

end

function gridPlayersList.onQuit()
	
	for i, list in ipairs(gridPlayersList.lists) do
		local row = guiGridListGetItemByData(list, source)
		if row then
			guiGridListRemoveRow(list, row)
			if guiGridListGetAutoSearchEdit(list) then guiGridListAutoSearchEditReloadItems(list) end
		end
	end

end

function gridPlayersList.onChangeNick()
	
	for i, list in ipairs(gridPlayersList.lists) do
		local row = guiGridListGetItemByData(list, source)
		if row then
			guiGridListSetItemText(list, row, 1, getPlayerName(source, true))
			if guiGridListGetAutoSearchEdit(list) then guiGridListAutoSearchEditReloadItems(list) end
		end
	end

end

function gridPlayersList.onDestroy()
	if source ~= this then return end

	table.removevalue(gridPlayersList.lists, this)

	return true
end

addEventHandler("onClientPlayerJoin", root, gridPlayersList.onJoin)
addEventHandler("onClientPlayerQuit", root, gridPlayersList.onQuit)
addEventHandler("onClientPlayerChangeNick", root, gridPlayersList.onChangeNick)

function guiGridListSetContentPlayers(list)
	if not scheck("u:element:gui-gridlist") then return false end
	if table.index(gridPlayersList.lists, list) then return false end

	guiGridListClear(list)
	guiGridListClearColumns(list)
	guiGridListAddColumn(list, "")

	table.insert(gridPlayersList.lists, list)
	gridPlayersList.refresh(list)

	addEventHandler("onClientElementDestroy", list, gridPlayersList.onDestroy)

	return true
end