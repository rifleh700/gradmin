
--------------------------------
-- VISIBLE
--------------------------------

local _guiSetVisible = guiSetVisible
function guiSetVisible(element, state, bringToFront)
	if not scheck("u:element:gui,b,?b") then return false end

	local set = _guiSetVisible(element, state)
	if set and state and bringToFront then guiBringToFront(element) end

	return set
end

--------------------------------
-- POSITIONING
--------------------------------

local _guiGetPosition = guiGetPosition
function guiGetPosition(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	return _guiGetPosition(element, relative or false)
end

local _guiSetPosition = guiSetPosition
function guiSetPosition(element, x, y, relative)
	if not scheck("u:element:gui,n[2],?b") then return false end

	if not relative then
		-- CEGUI BUG, I think
		if x < 0 then x = x - 1 end
		if y < 0 then y = y - 1 end
	end

	return _guiSetPosition(element, x, y, relative or false)
end

local _guiGetSize = guiGetSize
function guiGetSize(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	return _guiGetSize(element, relative or false)
end

local _guiSetSize = guiSetSize
function guiSetSize(element, width, height, relative)
	if not scheck("u:element:gui,n[2],?b") then return false end

	return _guiSetSize(element, width, height, relative or false)
end

function guiGetXPosition(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local x = guiGetPosition(element, relative or false)

	return x
end

function guiSetXPosition(element, x, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedXPosition")
	value[relative and 1 or 2] = x
	value[relative and 2 or 1] = 0
	
	return guiSetTableProperty(element, "UnifiedXPosition", value)
end

function guiGetYPosition(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local _, y = guiGetPosition(element, relative or false)

	return y
end

function guiSetYPosition(element, y, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedYPosition")
	value[relative and 1 or 2] = y
	value[relative and 2 or 1] = 0
	
	return guiSetTableProperty(element, "UnifiedYPosition", value)
end

function guiGetWidth(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local width = guiGetSize(element, relative or false)

	return width
end

function guiSetWidth(element, width, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedWidth")
	value[relative and 1 or 2] = width
	value[relative and 2 or 1] = 0
	
	return guiSetTableProperty(element, "UnifiedWidth", value)
end

function guiGetHeight(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local _, height = guiGetSize(element, relative or false)

	return height
end

function guiSetHeight(element, height, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedHeight")
	value[relative and 1 or 2] = height
	value[relative and 2 or 1] = 0
	
	return guiSetTableProperty(element, "UnifiedHeight", value)
end

function guiSetMaxSize(element, width, height, relative)
	if not scheck("u:element:gui,n[2],?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedMaxSize")

	value[1][relative and 1 or 2] = width
	value[1][relative and 2 or 1] = 0
	value[2][relative and 1 or 2] = height
	value[2][relative and 2 or 1] = 0

	return guiSetTableProperty(element, "UnifiedMaxSize", value)
end

function guiSetMinSize(element, width, height, relative)
	if not scheck("u:element:gui,n[2],?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedMinSize")

	value[1][relative and 1 or 2] = width
	value[1][relative and 2 or 1] = 0
	value[2][relative and 1 or 2] = height
	value[2][relative and 2 or 1] = 0

	return guiSetTableProperty(element, "UnifiedMinSize", value)
end

function guiSetMaxWidth(element, width, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedMaxSize")
	value[1][relative and 1 or 2] = width
	value[1][relative and 2 or 1] = 0

	return guiSetTableProperty(element, "UnifiedMaxSize", value)
end

function guiSetMaxHeight(element, height, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedMaxSize")
	value[2][relative and 1 or 2] = height
	value[2][relative and 2 or 1] = 0

	return guiSetTableProperty(element, "UnifiedMaxSize", value)
end

--------------------------------
-- RAW POSITIONING
--------------------------------

function guiGetRawPosition(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedPosition")
	local x = value[1][relative and 1 or 2]
	local y = value[2][relative and 1 or 2]
	
	return x, y
end

function guiSetRawPosition(element, x, y, relative)
	if not scheck("u:element:gui,n[2],?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedPosition")
	value[1][relative and 1 or 2] = x
	value[2][relative and 1 or 2] = y
	
	return guiSetTableProperty(element, "UnifiedPosition", value)
end

function guiGetRawXPosition(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedXPosition")
	
	return value[relative and 1 or 2]
end

function guiSetRawXPosition(element, x, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedXPosition")
	value[relative and 1 or 2] = x

	return guiSetTableProperty(element, "UnifiedXPosition", value)
end

function guiGetRawYPosition(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedYPosition")
	
	return value[relative and 1 or 2]
end

function guiSetRawYPosition(element, y, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedYPosition")
	value[relative and 1 or 2] = y

	return guiSetTableProperty(element, "UnifiedYPosition", value)
end

function guiGetRawSize(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedSize")
	local width = value[1][relative and 1 or 2]
	local height = value[2][relative and 1 or 2]
	
	return width, height
end

function guiSetRawSize(element, width, height, relative)
	if not scheck("u:element:gui,n[2],?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedSize")
	value[1][relative and 1 or 2] = width
	value[2][relative and 1 or 2] = height
	
	return guiSetTableProperty(element, "UnifiedSize", value)
end

function guiGetRawWidth(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedWidth")
	
	return value[relative and 1 or 2]
end

function guiSetRawWidth(element, width, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedWidth")
	value[relative and 1 or 2] = width

	return guiSetTableProperty(element, "UnifiedWidth", value)
end

function guiGetRawHeight(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedHeight")
	
	return value[relative and 1 or 2]
end

function guiSetRawHeight(element, height, relative)
	if not scheck("u:element:gui,n,?b") then return false end

	local value = guiGetTableProperty(element, "UnifiedHeight")
	value[relative and 1 or 2] = height

	return guiSetTableProperty(element, "UnifiedHeight", value)
end

--------------------------------
-- GEOMETRY
--------------------------------

function guiCenter(element)
	if not scheck("u:element:gui") then return false end

	local w, h = guiGetSize(element, false)
	local pw, ph = GUI_SCREEN_WIDTH, GUI_SCREEN_HEIGHT
	local parent = getElementParent(element)
	if parent ~= guiRoot then
		pw, ph = guiGetSize(parent, false)
	end
	
	local x, y = (pw-w)/2, (ph-h)/2

	return guiSetPosition(element, x, y, false)
end

function guiGetAbsolutePosition(element)
	if not scheck("u:element:gui") then return false end

	local x, y = guiGetPosition(element, false)
	local parent = getElementParent(element)
	while parent ~= guiRoot do
		local px, py = guiGetPosition(parent, false)
		if getElementType(parent) == "gui-tabpanel" then
			y = y + 24
		end
		x = x + px
		y = y + py
		parent = getElementParent(parent)
	end

	return x, y
end

function guiGetCursorPosition(element, relative)
	if not scheck("u:element:gui,?b") then return false end

	local ex, ey = guiGetAbsolutePosition(element)
	local cx, cy = getCursorAbsolutePosition()
	local x, y = cx - ex, cy - ey
	if relative then
		local w, h = guiGetSize(element, false)
		x, y = x/w, y/h
	end

	return x, y
end

function guiIsCursorInside(element)
	if not scheck("u:element:gui") then return false end

	local x, y = guiGetAbsolutePosition(element)
	local w, h = guiGetSize(element, false)
	local cx, cy = getCursorAbsolutePosition()

	return isInsideRectangle(cx, cy, x, y, w, h)
end

function getCursorAbsolutePosition()

	local cx, cy = getCursorPosition()
	return GUI_SCREEN_WIDTH * cx, GUI_SCREEN_HEIGHT * cy
end

function guiGetAbsoluteFromRelative(x, y, width, height, parent)
	if not scheck("n[4],?u:element:gui") then return false end

	local pw, ph = GUI_SCREEN_WIDTH, GUI_SCREEN_HEIGHT
	if parent then
		pw, ph = guiGetSize(parent, false)
	end

	x = x * pw
	y = y * ph
	width = width * pw
	height = height * ph

	return x, y, width, height
end

--------------------------------
-- TEXT
--------------------------------

local _guiGetFont = guiGetFont
function guiGetFont(element)
	if not scheck("u:element:gui") then return false end

	local name = _guiGetFont(element)
	return name
end

function guiGetFontElement(element)
	if not scheck("u:element:gui") then return false end

	local _, element = _guiGetFont(element)
	return element
end

function guiGetFontHeight(element)
	if not scheck("u:element:gui") then return false end

	return guiFontGetHeight(guiGetFont(element))
end

function guiGetTextExtent(element)
	if not scheck("u:element:gui") then return false end

	return guiFontGetTextExtent(guiGetText(element), guiGetFont(element))
end

function guiGetTextSize(element, maxWidth)
	if not scheck("u:element:gui,?n") then return false end

	local width = guiGetSize(element, false)

	return guiFontGetTextSize(guiGetText(element), guiGetFont(element), maxWidth or width)
end

function guiIsTextClipped(element)
	if not scheck("u:element:gui") then return false end

	local w, h = guiGetSize(element, false)
	local tw, th = guiGetTextSize(element, w)

	return tw > w or th > h
end

--------------------------------
-- ALIGN
--------------------------------

function guiSetHorizontalAlign(element, alignment)
	if not scheck("u:element:gui,s") then return false end

	return guiSetAlignmentProperty(element, "HorizontalAlignment", alignment)
end

function guiSetVerticalAlign(element, alignment)
	if not scheck("u:element:gui,s") then return false end

	return guiSetAlignmentProperty(element, "VerticalAlignment", alignment)
end

function guiGetWordWrap(element)
	if not scheck("u:element:gui") then return false end

	return utf8.match(guiGetProperty(element, "HorzFormatting"), "^WordWrap") and true or false
end

--------------------------------
-- PARENT
--------------------------------

function guiSetAlwaysOnTop(element, state)
	if not scheck("u:element:gui,b") then return false end

	return guiSetBooleanProperty(element, "AlwaysOnTop", state)
end

function guiSetClippedByParent(element, state)
	if not scheck("u:element:gui,b") then return false end

	return guiSetBooleanProperty(element, "ClippedByParent", state)
end

function guiSetInheritsAlpha(element, state)
	if not scheck("u:element:gui,b") then return false end

	return guiSetBooleanProperty(element, "InheritsAlpha", state)
end

function guiIsFullyClippedByParent(element)
	if not scheck("u:element:gui") then return false end

	local pw, ph = guiGetSize(getElementParent(element), false)
	local x, y = guiGetPosition(element, false)
	local w, h = guiGetSize(element, false)

	return
		x >= pw or
		y >= ph or
		x + w <= 0 or
		y + h <= 0
end

function guiGetGreatParent(element)
	if not scheck("u:element:gui") then return false end

	local parent = element
	while parent ~= guiRoot do
		element = parent
		parent = getElementParent(element)
	end 

	return element
end

--------------------------------
-- EVENTS
--------------------------------

function guiIsGrandParentFor(element, child)
	if not scheck("u:element:gui[2]") then return false end

	local parent = child
	while parent ~= guiRoot do
		if parent == element then return true end
		parent = getElementParent(parent)
	end

	return false
end

function guiTriggerEvent(element, event, ...)
	if not scheck("u:element:gui,s") then return false end
	if not guiGetEnabled(element) then return false end
	if not guiGetVisible(element) then return false end

	return triggerEvent(event, element, ...)
end

function guiClick(element, key)
	if not scheck("u:element:gui,?s") then return false end
	if not guiGetEnabled(element) then return false end
	if guiGetBooleanProperty(element, "Disabled") then return false end

	return guiTriggerEvent(element, "onClientGUIClick", key or "left", "up", guiGetAbsolutePosition(element))
end