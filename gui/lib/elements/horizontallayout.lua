
local HorizontalLayout = {}

HorizontalLayout.layouts = {}

function HorizontalLayout.onDestroy()
	
	table.removevalue(HorizontalLayout.layouts, this)

end

function HorizontalLayout.create(x, y, width, height, spacing, relative, parent)
	
	local layout = guiCreateContainer(x, y, width, height, relative, parent)

	guiSetInternalData(layout, "spacing", spacing)
	guiSetInternalData(layout, "verticalAlign", "top")
	table.insert(HorizontalLayout.layouts, layout)
	addEventHandler("onClientElementDestroy", layout, HorizontalLayout.onDestroy, false)

	return layout
end

function HorizontalLayout.rebuild(layout)
	
	local verticalAlign = guiGetInternalData(layout, "verticalAlign")
	local spacing = guiGetInternalData(layout, "spacing")

	local x, rx = 0, 0
	local maxh = 0

	local components = getElementChildren(layout)
	if #components > 0 then
		for i, element in ipairs(components) do
			
			guiSetRawPosition(element, x, 0, false)
			guiSetRawPosition(element, rx, 0, true)

			guiSetHorizontalAlign(element, "left")
			guiSetVerticalAlign(element, verticalAlign)
	
			x = x + guiGetRawWidth(element, false) + spacing
			rx = rx + guiGetRawWidth(element, true)
			maxh = math.max(maxh, guiGetHeight(element, false))
		end
		x = x - spacing
	end

	if not guiGetInternalData(layout, "fixedWidth") then guiSetWidth(layout, x, false) end
	if not guiGetInternalData(layout, "fixedHeight") then guiSetHeight(layout, maxh, false) end

	return true
end

function guiCreateHorizontalLayout(x, y, width, height, spacing, relative, parent)
	if not scheck("n[5],b,?u:element:gui") then return false end

	return HorizontalLayout.create(x, y, width, height, spacing, relative, parent)
end

function guiIsHorizontalLayout(element)
	if not scheck("u:element:gui") then return false end

	return table.index(HorizontalLayout.layouts, element) and true or false
end

function guiHorizontalLayoutRebuild(layout)
	if not scheck("u:element:gui") then return false end
	if not table.index(HorizontalLayout.layouts, layout) then return false end

	return HorizontalLayout.rebuild(layout)
end

function guiHorizontalLayoutSetVerticalAlign(layout, align)
	if not scheck("u:element:gui,s") then return false end
	if not table.index(HorizontalLayout.layouts, layout) then return false end

	return guiSetInternalData(layout, "verticalAlign", align)
end

function guiHorizontalLayoutSetWidthFixed(layout, state)
	if not scheck("u:element:gui,b") then return false end
	if not table.index(HorizontalLayout.layouts, layout) then return false end

	return guiSetInternalData(layout, "fixedWidth", state)
end

function guiHorizontalLayoutSetHeightFixed(layout, state)
	if not scheck("u:element:gui,b") then return false end
	if not table.index(HorizontalLayout.layouts, layout) then return false end

	return guiSetInternalData(layout, "fixedHeight", state)
end

function guiHorizontalLayoutSetSizeFixed(layout, state)
	if not scheck("u:element:gui,b") then return false end
	if not table.index(HorizontalLayout.layouts, layout) then return false end

	guiSetInternalData(layout, "fixedWidth", state)
	guiSetInternalData(layout, "fixedHeight", state)
	return true
end