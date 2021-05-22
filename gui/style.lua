
-- GLOBAL STYLE
GS = {}

GS.nilText = "N/A"

GS.clr = {}
GS.clr.red = {255, 127, 127}
GS.clr.orange = {255, 127, 63}
GS.clr.yellow = {255, 255, 127}
GS.clr.green = {127, 255, 127}
GS.clr.blue = {127, 127, 255}
GS.clr.aqua = {127, 255, 255}
GS.clr.white = {255, 255, 255}
GS.clr.grey = {127, 127, 127}
GS.clr.black = {0, 0, 0}

GS.mrgT = 20 -- top margin of window
GS.mrg = 5
GS.mrg2 = GS.mrg * 2
GS.mrg3 = GS.mrg2 * 2

GS.w = 40
GS.w2 = GS.w * 2 + GS.mrg
GS.w21 = GS.w2 + GS.mrg + GS.w
GS.w3 = GS.w2 * 2 + GS.mrg
GS.w31 = GS.w3 + GS.mrg + GS.w
GS.w32 = GS.w3 + GS.mrg + GS.w2
GS.w4 = GS.w3 * 2 + GS.mrg

GS.h = 20
GS.h2 = GS.h * 2 + GS.mrg
GS.h21 = GS.h2 + GS.h + GS.mrg
GS.h3 = GS.h2 * 2 + GS.mrg
GS.h31 = GS.h3 + GS.h + GS.mrg
GS.h32 = GS.h3 + GS.h2 + GS.mrg
GS.h4 = GS.h3 * 2 + GS.mrg

GS.scroll = {}
GS.scroll.size = 20

GS.button = {}
GS.button.w = GS.w2
GS.button.h = GS.h
GS.button.font = "default-bold-small"
GS.button.normalTextColor = {guiButtonGetNormalTextColor(GUI_DEFAULT_BUTTON)}
GS.button.hoverTextColor = {guiButtonGetHoverTextColor(GUI_DEFAULT_BUTTON)}
GS.button.disabledTextColor = {guiButtonGetDisabledTextColor(GUI_DEFAULT_BUTTON)}

GS.checkbox = {}
GS.checkbox.w = GS.w2
GS.checkbox.h = GS.h

GS.edit = {}
GS.edit.w = GS.w2
GS.edit.h = GS.h

GS.gridlist = {}
GS.gridlist.w = GS.w3
GS.gridlist.item = {}
GS.gridlist.item.color = {guiGridListGetItemColor(GUI_DEFAULT_GRIDLIST, 0, 1)}

GS.memo = {}
GS.memo.w = GS.w32
GS.memo.h = GS.h2

GS.scrollpane = {}
GS.scrollpane.w = GS.w3
GS.scrollpane.h = GS.h2

GS.label = {}
GS.label.w = GS.w2
GS.label.h = GS.h
GS.label.verticalAlign = "center"
GS.label.disabledColor = GS.clr.grey

GS.window = {}
GS.window.visible = false
GS.window.sizable = false
GS.window.center = true

GS.separator = {}
GS.separator.color = {guiSeparatorGetColor(GUI_DEFAULT_HORIZONTALSEPARATOR)}

GS.hlo = {}
GS.hlo.spacing = GS.mrg 

GS.vlo = {}
GS.vlo.spacing = GS.mrg

GS.colorpicker = {}
GS.colorpicker.w = GS.w2
GS.colorpicker.h = GS.h
GS.colorpicker.color = GS.clr.white


local _guiSetText = guiSetText
function guiSetText(element, text)
	if not scheck("u:element:gui") then return false end

	return _guiSetText(
		element,
		text and tostring(text) or (getElementType(element) == "gui-edit" and "" or GS.nilText)
	)
end

local function prepareArguments(style, x, y, width, height, text, relative, parent)
	
	x = x or ((not relative) and style.x or 0)
	y = y or ((not relative) and style.y or 0)
	width = width or ((not relative) and style.w or 0)
	height = height or ((not relative) and style.h or 0)
	text = text and tostring(text) or GS.nilText

	return x, y, width, height, text, relative or false, parent
end

local function applyStyle(element, style)
	
	if style.font then guiSetFont(element, style.font) end
	if style.visible == false then guiSetVisible(element, false) end
	if style.center then guiCenter(element) end

	return true
end

function guiButtonSetStyle(button, style)
	if not scheck("u:element:gui-button,?t") then return false end

	style = style or GS.button
	
	applyStyle(button, style)
	if style.normalTextColor then guiButtonSetNormalTextColor(button, table.unpack(style.normalTextColor)) end
	if style.hoverTextColor then guiButtonSetHoverTextColor(button, table.unpack(style.hoverTextColor)) end
	if style.disabledTextColor then guiButtonSetDisabledTextColor(button, table.unpack(style.disabledTextColor)) end

	return true
end

local _guiCreateButton = guiCreateButton
function guiCreateButton(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local style = GS.button or {}
	local element = _guiCreateButton(prepareArguments(style, x, y, width, height, text, relative, parent))
	if not element then return element end

	guiButtonSetStyle(element, style)

	return element
end

local _guiCreateCheckBox = guiCreateCheckBox
function guiCreateCheckBox(x, y, width, height, text, selected, relative, parent)
	if not scheck("?n[4],?s,?b[2],?u:element:gui") then return false end

	local style = GS.checkbox or {}
	x, y, width, height, text, relative = prepareArguments(style, x, y, width, height, text, relative)
	local element = _guiCreateCheckBox(x, y, width, height, text, selected, relative, parent)
	if not element then return element end

	applyStyle(element, style)

	return element
end

local _guiCreateEdit = guiCreateEdit
function guiCreateEdit(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local style = GS.edit or {}
	local element = _guiCreateEdit(prepareArguments(style, x, y, width, height, text, relative, parent))
	if not element then return element end

	applyStyle(element, style)

	return element
end

local _guiCreateMemo = guiCreateMemo
function guiCreateMemo(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local style = GS.memo or {}
	local element = _guiCreateMemo(prepareArguments(style, x, y, width, height, text, relative, parent))
	if not element then return element end

	applyStyle(element, style)

	return element
end

local _guiCreateScrollPane = guiCreateScrollPane
function guiCreateScrollPane(x, y, width, height, relative, parent)
	if not scheck("?n[4],?b,?u:element:gui") then return false end

	local style = GS.scrollpane or {}
	x, y, width, height, _, relative = prepareArguments(style, x, y, width, height, nil, relative) 
	local element = _guiCreateScrollPane(x, y, width, height, relative, parent)
	if not element then return element end

	applyStyle(element, style)

	return element
end

local _guiCreateGridList = guiCreateGridList
function guiCreateGridList(x, y, width, height, relative, parent)
	if not scheck("?n[4],?b,?u:element:gui") then return false end

	local style = GS.gridlist or {}
	x, y, width, height, _, relative = prepareArguments(style, x, y, width, height, nil, relative) 
	local element = _guiCreateGridList(x, y, width, height, relative, parent)
	if not element then return element end

	applyStyle(element, style)

	return element
end

local _guiGridListSetItemText = guiGridListSetItemText
function guiGridListSetItemText(list, row, column, text, isSection, isNumber)
	if not scheck("u:element:gui-gridlist,n,n,?s|n|b,?b[2]") then return false end

	local set = _guiGridListSetItemText(list, row, column, text == nil and GS.nilText or tostring(text), isSection, isNumber)
	if not set then return set end
	
	guiGridListSetItemColor(list, row, column, table.unpack(text == nil and GS.clr.grey or GS.gridlist.item.color))

	return set
end

local _guiCreateLabel = guiCreateLabel
function guiCreateLabel(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local style = GS.label or {}
	local element = _guiCreateLabel(prepareArguments(style, x, y, width, height, text, relative, parent))
	if not element then return element end

	applyStyle(element, style)
	guiLabelSetVerticalAlign(element, style.verticalAlign)
	guiLabelSetDisabledColor(element, table.unpack(style.disabledColor))

	return element
end


local _guiCreateWindow = guiCreateWindow
function guiCreateWindow(x, y, width, height, text, relative)
	if not scheck("?n[4],?s,?b") then return false end

	local style = GS.window or {}
	local element = _guiCreateWindow(prepareArguments(style, x, y, width, height, text, relative))
	if not element then return element end

	applyStyle(element, style)
	guiWindowSetSizable(element, style.sizable)

	return element
end

local _guiCreateTabPanel = guiCreateTabPanel
function guiCreateTabPanel(x, y, width, height, relative, parent)
	if not scheck("?n[4],?b,?u:element:gui") then return false end

	local style = GS.tabpanel or {}
	x, y, width, height, _, relative = prepareArguments(style, x, y, width, height, nil, relative) 
	local element = _guiCreateTabPanel(x, y, width, height, relative, parent)
	if not element then return element end

	applyStyle(element, style)

	return element
end

local _guiCreateHorizontalSeparator = guiCreateHorizontalSeparator
function guiCreateHorizontalSeparator(x, y, length, relative, parent)
	if not scheck("?n[3],?b,?u:element:gui") then return false end
	
	local style = GS.separator or {}
	x, y, length, _, _, relative = prepareArguments(style, x, y, length, nil, nil, relative) 
	local element = _guiCreateHorizontalSeparator(x, y, length, relative, parent)
	if not element then return element end

	applyStyle(element, style)
	guiSeparatorSetColor(element, table.unpack(style.color))
	
	return element
end

local _guiCreateVerticalSeparator = guiCreateVerticalSeparator
function guiCreateVerticalSeparator(x, y, length, relative, parent)
	if not scheck("?n[3],?b,?u:element:gui") then return false end
	
	local style = GS.separator or {}
	x, y, _, length, _, relative = prepareArguments(style, x, y, nil, length, nil, relative) 
	local element = _guiCreateVerticalSeparator(x, y, length, relative, parent)
	if not element then return element end

	applyStyle(element, style)
	guiSeparatorSetColor(element, table.unpack(style.color))
	
	return element
end

local _guiCreateHorizontalLayout = guiCreateHorizontalLayout
function guiCreateHorizontalLayout(x, y, width, height, spacing, relative, parent)
	if not scheck("?n[5],?b,?u:element:gui") then return false end
	
	local style = GS.hlo or {}
	x, y, width, height, _, relative = prepareArguments(style, x, y, width, height, nil, relative)
	spacing = spacing or style.spacing or 0

	local element = _guiCreateHorizontalLayout(x, y, width, height, spacing, relative, parent)
	if not element then return element end

	applyStyle(element, style)
	
	return element
end

local _guiCreateVerticalLayout = guiCreateVerticalLayout
function guiCreateVerticalLayout(x, y, width, height, spacing, relative, parent)
	if not scheck("?n[5],?b,?u:element:gui") then return false end
	
	local style = GS.vlo or {}
	x, y, width, height, _, relative = prepareArguments(style, x, y, width, height, nil, relative)
	spacing = spacing or style.spacing or 0

	local element = _guiCreateVerticalLayout(x, y, width, height, spacing, relative, parent)
	if not element then return element end

	applyStyle(element, style)
	
	return element
end

local _guiCreateColorPicker = guiCreateColorPicker
function guiCreateColorPicker(x, y, width, height, r, g, b, relative, parent)
	if not scheck("?n[4],?byte[3],?b,?u:element:gui") then return false end
	
	local style = GS.colorpicker or {}
	x, y, width, height, _, relative = prepareArguments(style, x, y, width, height, nil, relative)
	r = r or style.color[1]
	g = g or style.color[2]
	b = b or style.color[3]

	local element = _guiCreateColorPicker(x, y, width, height, r, g, b, relative, parent)
	if not element then return element end

	applyStyle(element, style)

	return element
end