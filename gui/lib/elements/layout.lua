
local Layout = {}

function Layout.rebuild(layout)
	
	if guiIsHorizontalLayout(layout) then return guiHorizontalLayoutRebuild(layout) end
	if guiIsVerticalLayout(layout) then return guiVerticalLayoutRebuild(layout) end
	if guiIsGridLayout(layout) then return guiGridLayoutRebuild(layout) end

	return false
end

function Layout.rebuildAll(element)
	
	for i, child in ipairs(getElementChildren(element)) do
		Layout.rebuildAll(child)
	end

	return Layout.rebuild(element)
end

function guiRebuildLayouts(element)
	if not scheck("u:element:gui") then return false end

	return Layout.rebuildAll(element)
end