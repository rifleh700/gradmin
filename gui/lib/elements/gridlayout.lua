
local GridLayout = {}

GridLayout.layouts = {}

function GridLayout.onDestroy()
	
	table.removevalue(GridLayout.layouts, this)

end

function GridLayout.create(x, y, width, height, columns, spacing, relative, parent)
	
	local layout = guiCreateContainer(x, y, width, height, relative, parent)

	guiSetInternalData(layout, "columns", columns)
	guiSetInternalData(layout, "spacing", spacing)
	guiSetInternalData(layout, "horizontalAlign", "center")
	guiSetInternalData(layout, "verticalAlign", "center")
	table.insert(GridLayout.layouts, layout)

	addEventHandler("onClientElementDestroy", layout, GridLayout.onDestroy, false)

	return layout
end

function GridLayout.rebuild(layout)

	local columns = guiGetInternalData(layout, "columns")
	local spacing = guiGetInternalData(layout, "spacing")
	local horizontalAlign = guiGetInternalData(layout, "horizontalAlign")
	local verticalAlign = guiGetInternalData(layout, "verticalAlign")
	
	local components = getElementChildren(layout)
	if #components == 0 then
		guiSetWidth(layout, 0, false)
		guiSetHeight(layout, 0, false)
		return true
	end

	local maxw, maxh = 0, 0
	for i, element in ipairs(components) do
		maxw = math.max(maxw, guiGetWidth(element, false))
		maxh = math.max(maxh, guiGetHeight(element, false))
	end
	local lw = (maxw + spacing) * (columns - 1) + maxw
	local lh = (maxh + spacing) * (math.ceil(#components/columns) - 1) + maxh

	local x, y = 0, 0
	local row, column = 1, 1
	for i, element in ipairs(components) do
		
		local w, h = guiGetWidth(element, false), guiGetHeight(element, false)
		local ax =
			horizontalAlign == "right" and (x + maxw - w) or
			horizontalAlign == "center" and (x + (maxw - w)*0.5) or
			x
		local ay =
			verticalAlign == "bottom" and (y + maxh - h) or
			verticalAlign == "center" and (y + (maxh - h)*0.5) or
			y
		guiSetXPosition(element, ax, false)
		guiSetYPosition(element, ay, false)
		guiSetHorizontalAlign(element, "left")
		guiSetVerticalAlign(element, "top")

		if column + 1 > columns then
			column = 1
			row = row + 1
			x = 0
			y = y + maxh + spacing
		else
			column = column + 1
			x = x + maxw + spacing
		end
	end

	guiSetMaxSize(layout, lw, lh, false)
	guiSetSize(layout, lw, lh, false)

	return true
end

function guiCreateGridLayout(x, y, width, height, columns, spacing, relative, parent)
	if not scheck("n[6],b,?u:element:gui") then return false end

	return GridLayout.create(x, y, width, height, columns, spacing, relative, parent)
end

function guiIsGridLayout(element)
	if not scheck("u:element:gui") then return false end

	return table.index(GridLayout.layouts, element) and true or false
end

function guiGridLayoutRebuild(layout)
	if not scheck("u:element:gui") then return false end
	if not table.index(GridLayout.layouts, layout) then return false end

	return GridLayout.rebuild(layout)
end

function guiGridLayoutSetColumns(layout, columns)
	if not scheck("u:element:gui,n") then return false end
	if not table.index(GridLayout.layouts, layout) then return false end

	columns = math.floor(columns)
	if columns < 1 then return false end

	guiSetInternalData(layout, "columns", columns)
	GridLayout.rebuild(layout)

	return true
end

function guiGridLayoutSetHorizontalAlign(layout, align)
	if not scheck("u:element:gui,s") then return false end
	if not table.index(GridLayout.layouts, layout) then return false end

	guiSetInternalData(layout, "horizontalAlign", align)
	GridLayout.rebuild(layout)

	return true
end

function guiGridLayoutSetVerticalAlign(layout, align)
	if not scheck("u:element:gui,s") then return false end
	if not table.index(GridLayout.layouts, layout) then return false end

	guiSetInternalData(layout, "verticalAlign", align)
	GridLayout.rebuild(layout)

	return true
end