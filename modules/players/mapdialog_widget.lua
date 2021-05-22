
local CATALOG_PATH = "modules/players/images/"
local MAP_PATH = CATALOG_PATH.."map.png"
local ME_BLIP_PATH = CATALOG_PATH.."me.png"
local POINT_BLIP_PATH = CATALOG_PATH.."point.png"

local MAP_WORLD_WIDTH = 6000
local MAP_WORLD_HEIGHT = 6000

local ME_BLIP_COLOR = {255, 255-32, 0}
local BLIP_SIZE = 32

local SCREEN_MIN_MARGIN = 20
local ZOOM_SPEED = 0.1
local DEFAULT_POSITION = {0, 0, 11}

local Map = {}
Map.thread = nil
Map.accepted = nil
Map.gui = {}
Map.moving = false
Map.pointMoving = false

function Map.init()
	
	Map.gui.window = guiCreateWindow(nil, nil, 0, 0, "Map")

	local mainVlo = guiCreateVerticalLayout(0, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, Map.gui.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	Map.gui.container = guiCreateContainer(0, 0, 0, 0, false, vlo)
	Map.gui.img = guiCreateStaticImage(0, 0, 1, 1, MAP_PATH, true, Map.gui.container)
	guiStaticImageAdjustMaxSize(Map.gui.img)

	Map.gui.meBlipImg = guiCreateStaticImage(0, 0, 0, 0, ME_BLIP_PATH, false, Map.gui.img)
	guiStaticImageSetColor(Map.gui.meBlipImg, table.unpack(ME_BLIP_COLOR))
	guiSetInheritsAlpha(Map.gui.meBlipImg, false)
	guiSetSize(Map.gui.meBlipImg, BLIP_SIZE, BLIP_SIZE, false)
	guiSetMinSize(Map.gui.meBlipImg, BLIP_SIZE, BLIP_SIZE, false)
	guiSetMaxSize(Map.gui.meBlipImg, BLIP_SIZE, BLIP_SIZE, false)
	guiSetHorizontalAlign(Map.gui.meBlipImg, "center")
	guiSetVerticalAlign(Map.gui.meBlipImg, "center")
	guiSetEnabled(Map.gui.meBlipImg, false)

	Map.gui.pointBlipImg = guiCreateStaticImage(0, 0, 0, 0, POINT_BLIP_PATH, false, Map.gui.img)
	guiSetSize(Map.gui.pointBlipImg, BLIP_SIZE, BLIP_SIZE, false)
	guiSetMinSize(Map.gui.pointBlipImg, BLIP_SIZE, BLIP_SIZE, false)
	guiSetMaxSize(Map.gui.pointBlipImg, BLIP_SIZE, BLIP_SIZE, false)
	guiSetHorizontalAlign(Map.gui.pointBlipImg, "center")
	guiSetVerticalAlign(Map.gui.pointBlipImg, "center")
	guiSetEnabled(Map.gui.pointBlipImg, false)

	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	local editw = guiFontGetTextExtent("Z:")
	_, Map.gui.xEdit = guiCreateKeyValueEdit(nil, nil, editw, nil, nil, "X:", "", false, hlo)
	guiEditSetMatcher(Map.gui.xEdit, guiGetInputNumericMatcher(false, -50000, 50000, 0))
	guiEditSetParser(Map.gui.xEdit, guiGetInputNumericParser(false, -50000, 50000))

	_, Map.gui.yEdit = guiCreateKeyValueEdit(nil, nil, editw, nil, nil, "Y:", "", false, hlo)
	guiEditSetMatcher(Map.gui.yEdit, guiGetInputNumericMatcher(false, -50000, 50000, 0))
	guiEditSetParser(Map.gui.yEdit, guiGetInputNumericParser(false, -50000, 50000))

	_, Map.gui.zEdit = guiCreateKeyValueEdit(nil, nil, editw, nil, nil, "Z:", "", false, hlo)
	guiEditSetMatcher(Map.gui.zEdit, guiGetInputNumericMatcher(false, -50000, 50000, 0))
	guiEditSetParser(Map.gui.zEdit, guiGetInputNumericParser(false, -50000, 50000))
	
	Map.gui.autoZChk = guiCreateCheckBox(nil, nil, nil, nil, "Auto", true, nil, hlo)
	guiSetToolTip(Map.gui.autoZChk, "Detect Z position automatically")
	guiSetEnabled(Map.gui.autoZChk, false)
	guiSetVisible(Map.gui.autoZChk, false)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	Map.gui.cancelBtn = guiCreateButton(nil, nil, nil, nil, "Cancel", nil, hlo)
	Map.gui.okBtn = guiCreateButton(nil, nil, nil, nil, "Ok", nil, hlo)
	
	guiRebuildLayouts(Map.gui.window)
	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(Map.gui.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)

	local ww, wh = guiGetSize(Map.gui.window, false)
	local cmaxw = GUI_SCREEN_WIDTH - SCREEN_MIN_MARGIN*2 - ww
	local cmaxh = GUI_SCREEN_HEIGHT - SCREEN_MIN_MARGIN*2 - wh
	local w, h = guiStaticImageGetNativeSize(Map.gui.img)
	if w > cmaxw then
		h = h * (cmaxw/w)
		w = cmaxw
	end
	if h > cmaxh then
		w = w * (cmaxh/h)
		h = cmaxh
	end
	guiSetSize(Map.gui.container, w, h, false)

	guiRebuildLayouts(Map.gui.window)
	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(Map.gui.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)
	guiCenter(Map.gui.window)

	guiBindKey(Map.gui.okBtn, "enter")
	guiBindKey(Map.gui.cancelBtn, "c")
	guiBindKey(Map.gui.cancelBtn, "n")

	----------------------------------------

	addEventHandler("onClientGUIRender", Map.gui.window, Map.refreshMeBlip, false)
	addEventHandler("onClientMouseWheel", Map.gui.img, Map.onScroll, false)
	addEventHandler("onClientGUIMouseDown", Map.gui.img, Map.onMouseDown, false)
	addEventHandler("onClientClick", root, Map.onMouseUp)
	addEventHandler("onClientCursorMove", root, Map.onMouseMove)
	addEventHandler("onClientGUIChanged", Map.gui.window, Map.onEditChanged)
	addEventHandler("onClientGUILeftClick", Map.gui.autoZChk, Map.switchAutoZ, false) 
	addEventHandler("onClientGUILeftClick", Map.gui.okBtn, Map.accept, false) 
	addEventHandler("onClientGUILeftClick", Map.gui.cancelBtn, Map.cancel, false) 
	
	return true
end

function Map.refreshMeBlip()
	
	local px, py = getElementPosition(localPlayer)
	guiSetPosition(Map.gui.meBlipImg, px/MAP_WORLD_WIDTH, -py/MAP_WORLD_HEIGHT, true)

end

function Map.onScroll(vector)
	
	local cw, ch = guiGetSize(Map.gui.container, false)
	local nw, nh = guiStaticImageGetNativeSize(Map.gui.img)
	local w, h = guiGetSize(Map.gui.img, false)
	local w2 = math.clamp(w * (1 + ZOOM_SPEED * vector), cw, nw)
	local h2 = math.clamp(h * (1 + ZOOM_SPEED * vector), ch, nh)
	
	local wscale = w2/w
	local hscale = h2/h
	if wscale == 1 and hscale == 1 then return end

	guiSetSize(Map.gui.img, w2, h2, false)
	
	local cx, cy = getCursorAbsolutePosition()
	local ax, ay = guiGetAbsolutePosition(Map.gui.img)
	local x, y = guiGetPosition(Map.gui.img, false)
	local x2 = math.clamp(x - ((cx - ax) * (wscale - 1)), cw - w2, 0)
    local y2 = math.clamp(y - ((cy - ay) * (hscale - 1)), ch - h2, 0)
	guiSetPosition(Map.gui.img, x2, y2, false)

end

function Map.onPointMove()
	
	local x, y = guiGetCursorPosition(Map.gui.img, true)
	x, y = math.clamp(x, 0, 1) - 0.5, math.clamp(y, 0, 1) - 0.5
	guiSetPosition(Map.gui.pointBlipImg, x, y, true)
	guiSetVisible(Map.gui.pointBlipImg, true)
	
	local wx, wy = x * MAP_WORLD_WIDTH, -y * MAP_WORLD_HEIGHT
	guiSetText(Map.gui.xEdit, string.format("%.3f", wx))
	guiSetText(Map.gui.yEdit, string.format("%.3f", wy))

end

function Map.onMouseDown(button, x, y)
	
	Map.cursorX = x
	Map.cursorY = y

	if button == "left" then
		Map.moving = true

	elseif button == "right" then
		Map.pointMoving = true
		Map.onPointMove()

	end

end

function Map.onMouseUp(button, state)
	if state ~= "up" then return end

	if button == "left" then
		Map.moving = false

	elseif button == "right" then
		Map.pointMoving = false

	end

end

function Map.onMouseMove(_, _, cx, cy)
	
	if not (Map.moving or Map.pointMoving) then return end

	if Map.moving then
		local x, y = guiGetPosition(Map.gui.img, false)
		local w, h = guiGetSize(Map.gui.img, false)
		local cw, ch = guiGetSize(Map.gui.container, false)
		local x2 = math.clamp(x + (cx - Map.cursorX), cw - w, 0)
		local y2 = math.clamp(y + (cy - Map.cursorY), ch - h, 0)
		guiSetPosition(Map.gui.img, x2, y2, false)
		
	elseif Map.pointMoving then
		Map.onPointMove()

	end

	Map.cursorX = cx
	Map.cursorY = cy	

end

function Map.onEditChanged()
	
	local x = (guiEditGetParsedValue(Map.gui.xEdit) or 0)/MAP_WORLD_WIDTH
	local y = -(guiEditGetParsedValue(Map.gui.yEdit) or 0)/MAP_WORLD_HEIGHT
	guiSetPosition(Map.gui.pointBlipImg, x, y, true)

end

function Map.switchAutoZ()
	
	guiSetEnabled(Map.gui.zEdit, not guiCheckBoxGetSelected(Map.gui.autoZChk))

end

function Map.accept()
	
	Map.accepted = true
	coroutine.resume(Map.thread)

end

function Map.cancel()
	
	Map.accepted = false
	coroutine.resume(Map.thread)

end

function Map.getPosition()
	
	return
		guiEditGetParsedValue(Map.gui.xEdit),
		guiEditGetParsedValue(Map.gui.yEdit),
		not guiCheckBoxGetSelected(Map.gui.autoZChk) and guiEditGetParsedValue(Map.gui.zEdit) or nil	
end

function Map.setPosition(x, y, z)
	
	guiSetText(Map.gui.xEdit, x or DEFAULT_POSITION[1])
	guiSetText(Map.gui.yEdit, y or DEFAULT_POSITION[2])
	guiSetText(Map.gui.zEdit, z or DEFAULT_POSITION[3])

	return true
end

Map.init()

function guiShowMapDialog(x, y, z, autoZAllowed)
	if not scheck("?n[3],?b") then return end
	
	if Map.thread then Map.cancel() end

	autoZAllowed = autoZAllowed or false

	coroutine.sleep(10)
	Map.thread = coroutine.running()
	Map.accepted = false

	Map.setPosition(x, y, z)
	Map.refreshMeBlip()

	local autoZEnabled = autoZAllowed and guiCheckBoxGetSelected(Map.gui.autoZChk)
	guiSetEnabled(Map.gui.autoZChk, autoZAllowed)
	guiCheckBoxSetSelected(Map.gui.autoZChk, autoZEnabled)
	guiSetVisible(Map.gui.autoZChk, autoZAllowed)
	guiSetEnabled(Map.gui.zEdit, not autoZEnabled)
	guiSetVisible(Map.gui.window, true, true)
	coroutine.yield()

	Map.thread = nil
	guiSetVisible(Map.gui.window, false, true)
	coroutine.sleep(10)

	if not Map.accepted then return nil end
	return Map.getPosition()
end