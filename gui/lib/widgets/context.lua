
local gs = {}
gs.minw = 120
gs.h = 20
gs.mrg = 5
gs.clr = {}
gs.alpha = 0.8
gs.clr.normal = {0, 0, 0}
gs.clr.hover = {118, 143, 246}

local Context = {}

Context.contexts = {}

function Context.onDestroy()
	
	for i, element in ipairs(guiGetInternalData(this, "attached")) do
		Context.dettach(element)
	end

end

function Context.onClick()
	
	guiSetVisible(this, false)

end

function Context.create()
	
	local context = guiCreateStaticImage(0, 0, 0, 0, GUI_WHITE_IMAGE_PATH, false)
	guiSetVisible(context, false)
	guiSetAlpha(context, gs.alpha)
	guiStaticImageSetColor(context, table.unpack(gs.clr.normal))

	local layout = guiCreateVerticalLayout(gs.mrg, 0, 0, 0, 0, false, context)

	guiSetInternalData(context, "layout", layout)
	guiSetInternalData(context, "items", {})
	guiSetInternalData(context, "attached", {})
	table.insert(Context.contexts, context)

	addEventHandler("onClientGUILeftClick", context, Context.onClick)
	addEventHandler("onClientElementDestroy", context, Context.onDestroy)

	return context
end

function Context.onElementRightClick(cursorX, cursorY)
	if getElementType(this) == "gui-gridlist" and guiGridListGetSelectedItem(this) == -1 then return end

	local context = guiGetInternalData(this, "context")
	guiSetPosition(context, cursorX + 1, cursorY, false)
	guiSetVisible(context, true, true)

end

function Context.onElementHide()
	
	guiSetVisible(guiGetInternalData(this, "context"), false)

end

function Context.onElementDestroy()
	
	Context.dettach(this)

end

function Context.attach(context, element)
	if guiGetInternalData(element, "context") == context then return false end

	local attached = guiGetInternalData(context, "attached")
	table.insert(attached, element)
	guiSetInternalData(context, "attached", attached)
	guiSetInternalData(element, "context", context)

	addEventHandler("onClientGUIRightClick", element, Context.onElementRightClick, false, "low")
	addEventHandler("onClientGUIHide", element, Context.onElementHide)
	addEventHandler("onClientElementDestroy", element, Context.onElementDestroy)
	
	return true
end

function Context.dettach(element)

	local context = guiGetInternalData(element, "context")
	if not context then return false end

	local attached = guiGetInternalData(context, "attached")
	table.removevalue(attached, element)
	guiSetInternalData(context, "attached", attached)

	guiSetInternalData(element, "context", nil)
	removeEventHandler("onClientGUIRightClick", element, Context.onElementRightClick)
	removeEventHandler("onClientGUIHide", element, Context.onElementHide)
	removeEventHandler("onClientElementDestroy", element, Context.onElementDestroy)

	return true
end

function Context.addItem(context, text)
	
	local layout = guiGetInternalData(context, "layout")
	local item = guiCreateLabel(0, 0, 0, gs.h, text, false, layout)
	guiLabelAdjustWidth(item)
	guiLabelSetHoverColor(item, table.unpack(gs.clr.hover))
	guiLabelSetVerticalAlign(item, "center")

	guiVerticalLayoutRebuild(layout)
	local w, h = guiGetSize(layout, false)
	guiSetSize(context, math.max(gs.minw, w + gs.mrg*2), h, false)

	return item
end

------------------------------------

function guiCreateContextMenu()
	
	return Context.create()
end

function guiGetContextMenu(element)
	if not scheck("u:element:gui") then return false end

	return guiGetInternalData(element, "context")
end

function guiSetContextMenu(element, context)
	if not scheck("u:element:gui,?u:element:gui") then return false end
	if context and not table.index(Context.contexts, context) then return false end

	Context.dettach(element)

	if not context then return true end
	return Context.attach(context, element)
end

function guiContextMenuAddItem(context, text)
	if not scheck("u:element:gui,s") then return false end
	if not table.index(Context.contexts, context) then return false end

	return Context.addItem(context, text)
end