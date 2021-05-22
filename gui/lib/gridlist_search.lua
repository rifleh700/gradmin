
local GridListSearch = {}

function GridListSearch.getRowData(list, row)

	local data = {}
	for column = 1, guiGridListGetColumnCount(list) do
		local itemData = {
			text = guiGridListGetItemText(list, row, column),
			data = guiGridListGetItemData(list, row, column)
		}
		table.insert(data, itemData)
	end
	return data
end

function GridListSearch.getItemsData(list)
	
	local data = {}
	for row = 0, guiGridListGetRowCount(list) - 1 do
		table.insert(data, GridListSearch.getRowData(list, row))
	end
	return data
end

function GridListSearch.onChanged(edit)

	local list = guiGetInternalData(edit, "search.list")
	local selected = guiGridListGetSelectedItem(list)
	if selected == -1 then selected = 0 end

	local selectedData = GridListSearch.getRowData(list, selected)
	guiGridListClear(list)

	local text = utf8.trim(guiGetText(edit))
	if text == "" then text = false end

	for _, rowData in ipairs(guiGetInternalData(list, "search.items")) do
		local found = false
		for column, data in ipairs(rowData) do
			if (not text) or utf8.find(data.text, text, nil, true, true) then
				found = true
				break
			end
		end
		if found then
			local row = guiGridListAddRow(list)
			for column, data in ipairs(rowData) do
				guiGridListSetItemText(list, row, column, data.text, false, false)
				guiGridListSetItemData(list, row, column, data.data)
			end
		end
	end

	if guiGridListGetRowCount(list) == 0 then
		local row = guiGridListAddRow(list)
		for column, data in ipairs(selectedData) do
			guiGridListSetItemText(list, row, column, data.text, false, false)
			guiGridListSetItemData(list, row, column, data.data)
		end
	end
	guiGridListSetSelectedItem(list, 0, 1)

end

function GridListSearch.onListDestroy()
	if source ~= this then return end
	
	GridListSearch.reset(this)

end

function GridListSearch.onEditDestroy()
	if source ~= this then return end
	
	GridListSearch.reset(guiGetInternalData(this, "search.list"))

end

function GridListSearch.reset(list)

	local edit = guiGetInternalData(list, "search.edit")
	if edit and isElement(edit) then
		removeEventHandler("onClientGUIChanged", edit, GridListSearch.onChanged)
		removeEventHandler("onClientElementDestroy", edit, GridListSearch.onEditDestroy)
		guiSetInternalData(edit, "search.list", nil)
	end

	if isElement(list) then
		removeEventHandler("onClientElementDestroy", list, GridListSearch.onListDestroy)
		guiSetInternalData(list, "search.edit", nil)
		guiSetInternalData(list, "search.items", nil)
	end
	
	return true
end

function guiGridListSetAutoSearchEdit(list, edit)
	if not scheck("u:element:gui-gridlist,?u:element:gui-edit") then return false end
	if guiGetInternalData(list, "search.edit") == edit then return false end

	GridListSearch.reset(list)

	guiSetInternalData(list, "search.items", GridListSearch.getItemsData(list))
	guiSetInternalData(list, "search.edit", edit)
	guiSetInternalData(edit, "search.list", list)

	addEventHandler("onClientGUIChanged", edit, GridListSearch.onChanged, false)
	addEventHandler("onClientElementDestroy", list, GridListSearch.onListDestroy, false)
	addEventHandler("onClientElementDestroy", edit, GridListSearch.onEditDestroy, false)
	GridListSearch.onChanged(edit)

	return true
end

function guiGridListGetAutoSearchEdit(list)
	if not scheck("u:element:gui-gridlist") then return false end

	return guiGetInternalData(list, "search.edit")
end

function guiGridListAutoSearchEditReloadItems(list)
	if not scheck("u:element:gui-gridlist") then return false end
	if not guiGetInternalData(list, "search.edit") then return false end
	
	guiSetInternalData(list, "search.items", GridListSearch.getItemsData(list))
	GridListSearch.onChanged(guiGetInternalData(list, "search.edit"))

	return true
end