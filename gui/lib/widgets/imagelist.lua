
addEvent("onClientGUIImageGridListItemSelected", false)

local DEFAULT_COLUMNS = 2
local DEFAULT_SELECTION_MODE = 2
local DEFAULT_VIEW_ENABLED = false
local FORCE_VERTICAL_SCROLLBAR = true
local LOAD_IMAGE_INTERVAL = 100

local gs = {}
gs.spacing = 5
gs.clr = {}
gs.clr.selected = {118, 143, 246, 153}
gs.clr.background = {127, 127, 127, 127}
gs.scrollsize = 20
gs.btn = {}
gs.btn.x = 5
gs.btn.y = 5
gs.btn.w = 40
gs.btn.h = 20

local ImageList = {}

ImageList.data = {}

function ImageList.create(x, y, width, height, relative, parent)

	local pane = guiCreateScrollPane(x, y, width, height, relative, parent)
	if not pane then return false end

	guiSetBooleanProperty(pane, "ForceVertScrollbar", FORCE_VERTICAL_SCROLLBAR)
	local layout = guiCreateGridLayout(0, 0, 0, 0, DEFAULT_COLUMNS, gs.spacing, false, pane)

	local data = {}
	data.columns = DEFAULT_COLUMNS
	data.selection = DEFAULT_SELECTION_MODE
	data.limit = -1
	data.layout = layout
	data.containers = {}
	data.view = DEFAULT_VIEW_ENABLED
	ImageList.data[pane] = data
	ImageList.rebuild(pane)

	addEventHandler("onClientElementDestroy", pane, ImageList.onDestroy, false)
	addEventHandler("onClientGUIScrollPaneVerticalScroll", pane, ImageList.onScroll, false)

	return pane
end

function ImageList.onDestroy()
	ImageList.data[this] = nil
end

function ImageList.isContainerVisible(list, grid, container)
	
	local _, lh = guiGetSize(list, false)
	local cy = guiGetYPosition(container, false) - (guiScrollPaneGetVerticalScrollPosition(list)/100 * (guiGetHeight(grid, false) - lh)) + 100
	local ch = guiGetHeight(container, false)

	return cy < lh and cy + ch > 0
end

function ImageList.load(list)
	
	local data = ImageList.data[list]
	data.loading = true

	while data.load and data.loading do
		if not isElement(list) then return true end

		data.load = false

		local containers = {}
		for item, container in ipairs(data.containers) do
			if not guiGetInternalData(container, "loaded") and
			ImageList.isContainerVisible(list, data.layout, container) then
				containers[#containers + 1] = container
			end
		end

		for i, container in ipairs(containers) do
			if isElement(container) then
				guiSetInternalData(container, "loaded", true)
				local image = guiGetInternalData(container, "image")
				guiStaticImageLoadImage(image, guiGetInternalData(container, "path"))
				guiStaticImageScale(image, data.size, data.size)
				coroutine.sleep(LOAD_IMAGE_INTERVAL)
			end
		end
	end

	data.loading = false

	return true
end

function ImageList.requestLoad(list)
	
	local data = ImageList.data[list]
	if data.load then return end

	data.load = true
	if not data.loading then coroutine.wrap(ImageList.load)(list) end

	return true
end

function ImageList.setSelected(list, container, state)
	
	local data = ImageList.data[list]
	local mask = guiGetInternalData(container, "mask")

	if state then
		if data.selection == 1 then
			for i, c in ipairs(data.containers) do
				guiStaticImageSetColor(guiGetInternalData(c, "mask"), 0, 0, 0, 0)
				guiSetInternalData(c, "selected", false)
			end
		else
			if data.limit > -1 then
				local selectedCount = 0
				for i, c in ipairs(data.containers) do
					if guiGetInternalData(c, "selected") then selectedCount = selectedCount + 1 end
				end
				if selectedCount >= data.limit then return end
			end
		end
		guiStaticImageSetColor(mask, table.unpack(gs.clr.selected))
	else
		guiStaticImageSetColor(mask, 0, 0, 0, 0)
	end
	
	return guiSetInternalData(container, "selected", state)
end

function ImageList.onScroll()
	
	ImageList.requestLoad(this)

end

function ImageList.onClickItem()

	local list = guiGetInternalData(this, "list")
	if ImageList.data[list].selection == 0 then return end

	ImageList.setSelected(list, this, not guiGetInternalData(this, "selected"))
	
end

function ImageList.onClickView()
	
	local container = getElementParent(this)
	local path = guiGetInternalData(container, "path")
	guiShowImageViewer(path)

end

function ImageList.rebuild(list)
	
	local data = ImageList.data[list]

	data.size = math.floor((guiGetSize(list, false) - gs.spacing * (data.columns - 1) - gs.scrollsize)/data.columns)
	for item, container in ipairs(data.containers) do
		guiSetSize(container, data.size, data.size, false)
		guiStaticImageScale(guiGetInternalData(container, "image"), data.size, data.size)
	end
	guiGridLayoutSetColumns(data.layout, data.columns)

	return true
end

function ImageList.clear(list)
	
	local data = ImageList.data[list]
	for item, container in ipairs(data.containers) do
		destroyElement(container)
	end
	data.load = false
	data.loading = false
	data.containers = {}
	ImageList.rebuild(list)

	return true
end

function ImageList.add(list, path)
	
	local data = ImageList.data[list]
	local container = guiCreateContainer(0, 0, data.size, data.size, false, data.layout)
	local image = guiCreateStaticImage(0, 0, 1, 1, GUI_EMPTY_IMAGE_PATH, true, container)

	guiStaticImageSetColor(container, table.unpack(gs.clr.background))
	guiSetInternalData(container, "list", list)
	guiSetInternalData(container, "selected", false)

	guiSetHorizontalAlign(image, "center")
	guiSetVerticalAlign(image, "center")
	guiSetEnabled(image, false)
	guiSetInternalData(container, "image", image)
	guiSetInternalData(container, "path", path)

	local mask = guiCreateStaticImage(0, 0, 1, 1, GUI_WHITE_IMAGE_PATH, true, container)
	guiSetEnabled(mask, false)
	guiStaticImageSetColor(mask, 0, 0, 0, 0)
	guiSetInternalData(container, "mask", mask)
	
	local view = guiCreateButton(gs.btn.x, gs.btn.y, gs.btn.w, gs.btn.h, "View", false, container)
	guiSetEnabled(view, data.view)
	guiSetVisible(view, data.view)
	guiSetInternalData(container, "view", view)

	addEventHandler("onClientGUILeftClick", container, ImageList.onClickItem, false)
	addEventHandler("onClientGUILeftClick", view, ImageList.onClickView, false)

	local item = #data.containers + 1
	data.containers[item] = container

	guiGridLayoutRebuild(data.layout)
	ImageList.requestLoad(list)

	return item
end

function ImageList.setViewEnabled(list, state)
	
	local data = ImageList.data[list]
	data.view = state

	for item, container in ipairs(data.containers) do
		local btn = guiGetInternalData(container, "view")
		guiSetEnabled(btn, state)
		guiSetVisible(btn, state)
	end

	return true
end

----------------------------------

function guiCreateImageGridList(x, y, width, height, relative, parent)
	if not scheck("n[4],b,?u:element:gui") then return false end

	return ImageList.create(x, y, width, height, relative, parent)
end

function guiImageGridListSetColumns(list, columns)
	if not scheck("u:element:gui,?n") then return false end
	if not ImageList.data[list] then return false end

	columns = math.floor(columns)
	if columns < 1 then return false end

	ImageList.data[list].columns = columns
	ImageList.rebuild(list)

	return true
end

-- 0 - selection not allowed, 1 - single selection, 2 - multiple selection (default)
function guiImageGridListSetSelectionMode(list, selection)
	if not scheck("u:element:gui,?n") then return false end
	if not ImageList.data[list] then return false end

	selection = math.floor(selection)
	if selection < 0 or selection > 2 then return false end

	ImageList.data[list].selection = selection

	return true
end

function guiImageGridListGetSelectionMode(list)
	if not scheck("u:element:gui") then return false end
	if not ImageList.data[list] then return false end

	return ImageList.data[list].selection
end

function guiImageGridListSetSelectionLimit(list, limit)
	if not scheck("u:element:gui,?n") then return false end
	if not ImageList.data[list] then return false end

	limit = math.floor(limit)
	if limit < -1 then return false end

	ImageList.data[list].limit = limit

	return true
end

function guiImageGridListGetSelectionLimit(list)
	if not scheck("u:element:gui") then return false end
	if not ImageList.data[list] then return false end

	return ImageList.data[list].limit
end

function guiImageGridListSetViewEnabled(list, state)
	if not scheck("u:element:gui,b") then return false end
	if not ImageList.data[list] then return false end
	if ImageList.data[list].view == state then return false end

	return ImageList.setViewEnabled(list, state)
end

function guiImageGridListClear(list)
	if not scheck("u:element:gui") then return false end
	if not ImageList.data[list] then return false end

	return ImageList.clear(list)
end

function guiImageGridListAddItem(list, path)
	if not scheck("u:element:gui,s") then return false end
	if not ImageList.data[list] then return false end
	if not fileExists(path) then return false end

	return ImageList.add(list, path)
end

function guiImageGridListSetItemSelected(list, item, state)
	if not scheck("u:element:gui,n,b") then return false end
	if not ImageList.data[list] then return false end
	
	local container = ImageList.data[list].containers[item]
	if not container then return false end
	if guiGetInternalData(container, "selected") == state then return false end

	return ImageList.setSelected(list, container, state)
end

function guiImageGridListGetSelectedItem(list)
	if not scheck("u:element:gui") then return false end
	if not ImageList.data[list] then return false end
	
	for item, container in ipairs(ImageList.data[list].containers) do
		if guiGetInternalData(container, "selected") then return item end
	end
	return 0
end

function guiImageGridListGetSelectedItems(list)
	if not scheck("u:element:gui") then return false end
	if not ImageList.data[list] then return false end
	
	local selected = {}
	for item, container in ipairs(ImageList.data[list].containers) do
		if guiGetInternalData(container, "selected") then table.insert(selected, item) end
	end
	return selected
end

function guiImageGridListGetItemData(list, item)
	if not scheck("u:element:gui,n") then return false end
	if not ImageList.data[list] then return false end

	local container = ImageList.data[list].containers[item]
	if not container then return false end

	return guiGetInternalData(container, "data")
end

function guiImageGridListSetItemData(list, item, data)
	if not scheck("u:element:gui,n") then return false end
	if not ImageList.data[list] then return false end
	if not ImageList.data[list].containers[item] then return false end
	
	local container = ImageList.data[list].containers[item]
	if not container then return false end

	return guiSetInternalData(container, "data", data)
end

