
local gs = {}
gs.w = 640
gs.h = 480
gs.columns = 3
gs.mrgT = 20
gs.mrg = 5
gs.mrg2 = gs.mrg * 2
gs.btn = {}
gs.btn.w = 80
gs.btn.h = 20

local ImageDialog = {}

ImageDialog.gui = {}
ImageDialog.thread = nil
ImageDialog.focused = nil
ImageDialog.result = nil
ImageDialog.accepted = nil

function ImageDialog.init()

	ImageDialog.gui.window = guiCreateWindow(0, 0, 1, 1, "", true)
	guiSetVisible(ImageDialog.gui.window, false)
	guiWindowSetSizable(ImageDialog.gui.window, false)

	ImageDialog.gui.vlo = guiCreateVerticalLayout(gs.mrg2, gs.mrgT + gs.mrg2, GUI_SCREEN_WIDTH, GUI_SCREEN_HEIGHT, gs.mrg2, false, ImageDialog.gui.window)
	guiVerticalLayoutSetHorizontalAlign(ImageDialog.gui.vlo, "center")

	ImageDialog.gui.list = guiCreateImageGridList(0, 0, gs.w, gs.h, false, ImageDialog.gui.vlo)
	guiImageGridListSetColumns(ImageDialog.gui.list, gs.columns)
	
	local hlo = guiCreateHorizontalLayout(0, 0, 0, 0, gs.mrg, false, ImageDialog.gui.vlo)
	ImageDialog.gui.ok = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Ok", false, hlo)
	ImageDialog.gui.cancel = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Cancel", false, hlo)
	
	guiRebuildLayouts(ImageDialog.gui.window)
	local w, h = guiGetSize(ImageDialog.gui.vlo, false)
	guiSetSize(ImageDialog.gui.window, w + gs.mrg2*2, h + gs.mrg2*2 + gs.mrgT)

	guiSetEnabled(ImageDialog.gui.window, false)

	guiBindKey(ImageDialog.gui.ok, "enter")
	guiBindKey(ImageDialog.gui.cancel, "c")
	guiBindKey(ImageDialog.gui.cancel, "n")

	addEventHandler("onClientGUILeftClick", ImageDialog.gui.ok, ImageDialog.accept, false) 
	addEventHandler("onClientGUILeftClick", ImageDialog.gui.cancel, ImageDialog.cancel, false) 

	return true
end

function ImageDialog.prepare(title, data, limit, viewEnabled, columns)

	guiSetText(ImageDialog.gui.window, title or "")

	guiSetEnabled(ImageDialog.gui.window, true)
	
	local list = ImageDialog.gui.list
	guiImageGridListClear(list)
	guiImageGridListSetColumns(list, columns or gs.columns)
	guiImageGridListSetSelectionLimit(list, limit or -1)
	guiImageGridListSetViewEnabled(list, viewEnabled == nil and true or viewEnabled)

	for i, itemData in ipairs(data) do
		local item = guiImageGridListAddItem(list, itemData.path)
		if item then
			if itemData.selected then guiImageGridListSetItemSelected(list, item, true) end
			if itemData.data then guiImageGridListSetItemData(list, item, itemData.data) end
		end
	end

	guiCenter(ImageDialog.gui.window)
	guiSetEnabled(ImageDialog.gui.window, false)

	return true
end

function ImageDialog.resume()
	if not ImageDialog.thread then return end

	guiSetEnabled(ImageDialog.gui.window, false)
	guiSetVisible(ImageDialog.gui.window, false)

	coroutine.resume(ImageDialog.thread)
end

function ImageDialog.getResult()
	
	local result = {}
	for i, item in ipairs(guiImageGridListGetSelectedItems(ImageDialog.gui.list)) do
		result[i] = {
			item = item,
			data = guiImageGridListGetItemData(ImageDialog.gui.list, item)
		}
	end

	return result
end

function ImageDialog.accept()

	ImageDialog.result = ImageDialog.getResult()
	ImageDialog.accepted = true
	ImageDialog.resume()

	return true
end

function ImageDialog.cancel()

	ImageDialog.accepted = false
	ImageDialog.resume()

	return true
end

ImageDialog.init()

function guiShowImageDialog(title, data, limit, viewEnabled, columns)
	if not scheck("?s,t,?n,?b,?n") then return false end

	if ImageDialog.thread then ImageDialog.cancel() end

	coroutine.sleep(10)

	ImageDialog.thread = coroutine.running()
	ImageDialog.accepted = false
	ImageDialog.focused = guiGetFocused()
	
	ImageDialog.prepare(title, data, limit, viewEnabled, columns)
	guiSetEnabled(ImageDialog.gui.window, true)
	guiSetVisible(ImageDialog.gui.window, true, true)
	coroutine.yield()

	local accepted = ImageDialog.accepted
	local result = ImageDialog.result
	ImageDialog.thread = nil
	coroutine.sleep(10)

	guiFocus(ImageDialog.focused)

	return accepted and result or false
end
