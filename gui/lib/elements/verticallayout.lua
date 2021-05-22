
local VerticalLayout = {}

VerticalLayout.layouts = {}

function VerticalLayout.onDestroy()
	
	table.removevalue(VerticalLayout.layouts, this)

end

function VerticalLayout.create(x, y, width, height, spacing, relative, parent)
	
	local layout = guiCreateContainer(x, y, width, height, relative, parent)

	guiSetInternalData(layout, "spacing", spacing)
	guiSetInternalData(layout, "horizontalAlign", "left")
	table.insert(VerticalLayout.layouts, layout)
	addEventHandler("onClientElementDestroy", layout, VerticalLayout.onDestroy, false)

	return layout
end

function VerticalLayout.rebuild(layout)
	
	local horizontalAlign = guiGetInternalData(layout, "horizontalAlign")
	local spacing = guiGetInternalData(layout, "spacing")

	local y, ry = 0, 0
	local maxw = 0

	local components = getElementChildren(layout)
	if #components > 0 then
		for i, element in ipairs(components) do
		
			guiSetRawPosition(element, 0, y, false)
			guiSetRawPosition(element, 0, ry, true)
	
			guiSetHorizontalAlign(element, horizontalAlign)
			guiSetVerticalAlign(element, "top")
	
			y = y + guiGetRawHeight(element, false) + spacing
			ry = ry + guiGetRawHeight(element, true)
			maxw = math.max(maxw, guiGetWidth(element, false))
		end
		y = y - spacing
	end

	if not guiGetInternalData(layout, "fixedWidth") then guiSetWidth(layout, maxw, false) end
	if not guiGetInternalData(layout, "fixedHeight") then guiSetHeight(layout, y, false) end

	return true
end

function guiCreateVerticalLayout(x, y, width, height, spacing, relative, parent)
	if not scheck("n[5],b,?u:element:gui") then return false end

	return VerticalLayout.create(x, y, width, height, spacing, relative, parent)
end

function guiIsVerticalLayout(element)
	if not scheck("u:element:gui") then return false end

	return table.index(VerticalLayout.layouts, element) and true or false
end

function guiVerticalLayoutRebuild(layout)
	if not scheck("u:element:gui") then return false end
	if not table.index(VerticalLayout.layouts, layout) then return false end

	return VerticalLayout.rebuild(layout)
end

function guiVerticalLayoutSetHorizontalAlign(layout, align)
	if not scheck("u:element:gui,s") then return false end
	if not table.index(VerticalLayout.layouts, layout) then return false end

	return guiSetInternalData(layout, "horizontalAlign", align)
end

function guiVerticalLayoutSetWidthFixed(layout, state)
	if not scheck("u:element:gui,b") then return false end
	if not table.index(VerticalLayout.layouts, layout) then return false end

	return guiSetInternalData(layout, "fixedWidth", state)
end

function guiVerticalLayoutSetHeightFixed(layout, state)
	if not scheck("u:element:gui,b") then return false end
	if not table.index(VerticalLayout.layouts, layout) then return false end

	return guiSetInternalData(layout, "fixedHeight", state)
end

function guiVerticalLayoutSetSizeFixed(layout, fixed)
	if not scheck("u:element:gui,b") then return false end
	if not table.index(VerticalLayout.layouts, layout) then return false end

	guiSetInternalData(layout, "fixedWidth", true)
	guiSetInternalData(layout, "fixedHeight", true)
	return true
end