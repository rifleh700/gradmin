
addEvent("onClientGUIGridListItemSelected", false)

local function onClick()

	local row, column = guiGridListGetSelectedItem(this)
	triggerEvent("onClientGUIGridListItemSelected", this, row, column)
	
end

local _guiCreateGridList = guiCreateGridList
function guiCreateGridList(x, y, width, height, relative, parent)
	if not scheck("n[4],b,?u:element:gui") then return false end

	local list = _guiCreateGridList(x, y, width, height, relative, parent)
	addEventHandler("onClientGUIClick", list, onClick, false)

	return list
end

local _guiGridListSetVerticalScrollPosition = guiGridListSetVerticalScrollPosition
function guiGridListSetVerticalScrollPosition(list, scroll)
	if not scheck("u:element:gui-gridlist,n") then return false end

	setTimer(
		function()
			if not isElement(list) then return end
			_guiGridListSetVerticalScrollPosition(list, scroll)	
		end,
		0, 1
	)

	return true
end

function guiGridListClearColumns(list)
	if not scheck("u:element:gui-gridlist") then return false end

	local columns = guiGridListGetColumnCount(list)
	if columns == 0 then return false end

	for column = 1, columns do
		guiGridListRemoveColumn(list, column)
	end
	return true
end

local _guiGridListSetSelectedItem = guiGridListSetSelectedItem
function guiGridListSetSelectedItem(list, row, column)
	if not scheck("u:element:gui-gridlist,?n[2]") then return false end

	row = row or 0
	column = column or 1

	local srow, scolumn = guiGridListGetSelectedItem(list)
	if srow == row and scolumn == column then return false end
	
	if not _guiGridListSetSelectedItem(list, row, column) then return false end
	
	--guiFocus(list)
	guiGridListSetVerticalScrollPosition(list, guiGridListGetVerticalScrollPositionByRow(list, row))
	guiGridListSetHorizontalScrollPosition(list, guiGridListGetHorizontalScrollPositionByColumn(list, column))

	triggerEvent("onClientGUIGridListItemSelected", list, row, column)
	
	return true
end

function guiGridListSetSelectedAnyItem(list, row, column)
	if not scheck("u:element:gui-gridlist,n,?n") then return false end

	row = math.min(math.max(row or 0, 0), guiGridListGetRowCount(list) - 1)
	column = math.min(math.max(column or 1, 1), guiGridListGetColumnCount(list))

	return guiGridListSetSelectedItem(list, row, column)
end

local _guiGridListSetItemText = guiGridListSetItemText
function guiGridListSetItemText(list, row, column, text, isSection, isNumber)
	if not scheck("u:element:gui-gridlist,n,n,s,?b[2]") then return false end

	return _guiGridListSetItemText(list, row, column, text, isSection or false, isNumber or false)
end

local _guiGridListGetItemData = guiGridListGetItemData
function guiGridListGetItemData(list, row, column)
	if not scheck("u:element:gui-gridlist,n,?n") then return false end

	return _guiGridListGetItemData(list, row, column or 1)
end

local _guiGridListGetItemText = guiGridListGetItemText
function guiGridListGetItemText(list, row, column)
	if not scheck("u:element:gui-gridlist,n,?n") then return false end

	return _guiGridListGetItemText(list, row, column or 1)
end

local _guiGridListRemoveRow = guiGridListRemoveRow
function guiGridListRemoveRow(gridList, row)
	if not scheck("u:element:gui-gridlist,?n") then return false end
	
	row = row or (guiGridListGetRowCount(gridList) - 1)

	local srow, scolumn = guiGridListGetSelectedItem(gridList)
	if not _guiGridListRemoveRow(gridList, row) then return false end
	if srow ~= row then return true end

	local rows = guiGridListGetRowCount(gridList)
	if rows == 0 then return true end

	srow = math.clamp(srow, 0, rows - 1)
	guiGridListSetSelectedItem(gridList, srow, scolumn)

	return true 
end

function  guiGridListSetRowColor(list, row, r, g, b, a)
	if not scheck("u:element:gui-gridlist,n[4],?n") then return false end
	if row < 0 then return false end
	if row > guiGridListGetRowCount(list) - 1 then return false end

	local columns = guiGridListGetColumnCount(list)
	if columns == 0 then return false end

	for column = 1, columns do
		guiGridListSetItemColor(list, row, column, r, g, b, a or 255)
	end
	return true
end

function guiGridListGetRowByText(gridList, text, column)
	if not scheck("u:element:gui-gridlist,s,?n") then return false end

	local rows = guiGridListGetRowCount(gridList)
	if rows == 0 then return nil end

	local columns = guiGridListGetColumnCount(gridList)
	if columns == 0 then return nil end

	column = column or 1

	for row = 0, rows-1 do
		if guiGridListGetItemText(gridList, row, column) == text then return row end
	end
	return nil
end

function guiGridListGetItemByData(gridList, data)
	if not scheck("u:element:gui-gridlist,!") then return false end

	local rows = guiGridListGetRowCount(gridList)
	if rows == 0 then return nil end

	local columns = guiGridListGetColumnCount(gridList)
	if columns == 0 then return nil end
	
	for row = 0, rows-1 do
		for column = 1, columns do
			if guiGridListGetItemData(gridList, row, column) == data then return row, column end
		end
	end
	return nil
end

function guiGridListGetSelectedItemText(gridList)
	if not scheck("u:element:gui-gridlist") then return false end
	
	local row, column = guiGridListGetSelectedItem(gridList)
	if row < 0 or column < 1 then return nil end
	
	return guiGridListGetItemText(gridList, row, column)
end

function guiGridListGetSelectedItemData(gridList, row, column)
	if not scheck("u:element:gui-gridlist,?n[2]") then return false end
	
	local srow, scolumn = guiGridListGetSelectedItem(gridList)
	if srow < 0 or scolumn < 1 then return nil end

	return guiGridListGetItemData(gridList, row or srow, column or scolumn)
end

function guiGridListAdjustHeight(gridList, itemCount)
	if not scheck("u:element:gui-gridlist,?n") then return false end
	
	itemCount = itemCount or guiGridListGetRowCount(gridList)
	
	return guiSetHeight(gridList, itemCount * 14 + 35 + 15, false)
end

function guiGridListAdjustColumnWidth(gridList)
	if not scheck("u:element:gui-gridlist") then return false end
	
	local width = guiGetSize(gridList, false)
	
	return guiGridListSetColumnWidth(gridList, 1, width - 30, false)
end

local _guiGridListAddColumn = guiGridListAddColumn
function guiGridListAddColumn(gridList, name, width)
	if not scheck("u:element:gui-gridlist,s,?n") then return false end

	if width then return _guiGridListAddColumn(gridList, name, width) end
	
	local add = _guiGridListAddColumn(gridList, name, 1)
	if not add then return add end
	
	guiGridListAdjustColumnWidth(gridList)
	
	return add
end

function guiGridListGetVerticalScrollRow(list)
	if not scheck("u:element:gui-gridlist") then return false end

	local rows = guiGridListGetRowCount(list)
	if rows <= 1 then return 0 end

	return math.floor(rows * (guiGridListGetVerticalScrollPosition(list)/100))
end

function guiGridListGetColumnsWidth(list, relative)
	if not scheck("u:element:gui-gridlist,b") then return false end

	local columns = guiGridListGetColumnCount(list)
	if columns == 0 then return 0 end

	local width = 0
	for column = 1, columns do
		width = width + guiGridListGetColumnWidth(list, column, relative)
	end

	return width
end

function guiGridListGetColumnPosition(list, column, relative)
	if not scheck("u:element:gui-gridlist,n,b") then return false end

	local columns = guiGridListGetColumnCount(list)
	if columns == 0 then return 0 end
	if column <= 1 then return 0 end

	local position = 0
	for number = 1, column - 1 do
		position = position + guiGridListGetColumnWidth(list, number, relative)
	end

	return position
end

function guiGridListGetVerticalScrollPositionByRow(list, row)
	if not scheck("u:element:gui-gridlist,n") then return false end

	if row == -1 then return 0 end

	local rows = guiGridListGetRowCount(list)
	if rows <= 1 then return 0 end

	row = math.clamp(row, 0, rows-1)

	return row/(rows-1) * 100
end

function guiGridListGetHorizontalScrollPositionByColumn(list, column)
	if not scheck("u:element:gui-gridlist,n") then return false end

	if column == 0 then return 0 end

	local columns = guiGridListGetColumnCount(list)
	if columns <= 1 then return 0 end

	column = math.clamp(column, 1, columns)
	
	return
		guiGridListGetColumnPosition(list, column, false)/
		guiGridListGetColumnsWidth(list, false) * 100
end