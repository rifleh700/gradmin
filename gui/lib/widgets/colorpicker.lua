
addEvent("onClientGUIColorPickerAccepted", false)

local gs = {
	bg = {0, 0, 0, 255},
	alpha = 0.8,
	mrg = 10,
	mrg2 = 5,
	btn = {w = 80, h = 20},
	edit = {w = 50},
	lbl = {w = guiFontGetTextExtent("H:")},
	bar = {w = 128}
}

local ColorPicker = {}

ColorPicker.elements = {}
ColorPicker.thread = nil
ColorPicker.accepted = false
ColorPicker.gui = {}
ColorPicker.color = {
	r = 0, g = 0, b = 0,
	h = 0, s = 0, v = 0
}

function ColorPicker.init()

	ColorPicker.gui.window = guiCreateStaticImage(0, 0, 0, 0, GUI_WHITE_IMAGE_PATH, false)
	guiStaticImageSetColor(ColorPicker.gui.window, table.unpack(gs.bg))
	guiSetAlpha(ColorPicker.gui.window, gs.alpha)
	guiSetEnabled(ColorPicker.gui.window, false)
	guiSetVisible(ColorPicker.gui.window, false)

	local mainHlo = guiCreateHorizontalLayout(gs.mrg, gs.mrg, 0, 0, gs.mrg, false, ColorPicker.gui.window)

	ColorPicker.gui.colors = {}

	local btnsVlo = guiCreateVerticalLayout(0, 0, 0, 0, gs.mrg2, false, mainHlo)
	local container = guiCreateContainer(0, 0, gs.btn.w, gs.btn.h, false, btnsVlo)
	ColorPicker.gui.currentImg = guiCreateStaticImage(0, 0, 1, 1, GUI_WHITE_IMAGE_PATH, true, container)
	guiStaticImageSetColor(ColorPicker.gui.currentImg, 255, 0, 0)
	guiSetProperty(ColorPicker.gui.currentImg, "InheritsAlpha", "False")

	ColorPicker.gui.colors.hex = {}
	ColorPicker.gui.colors.hex.lbl = guiCreateLabel(0, 0, 1, 1, "", true, ColorPicker.gui.currentImg)
	guiSetEnabled(ColorPicker.gui.colors.hex.lbl, false)
	guiLabelSetVerticalAlign(ColorPicker.gui.colors.hex.lbl, "center")
	guiLabelSetHorizontalAlign(ColorPicker.gui.colors.hex.lbl, "center")

	ColorPicker.gui.colors.hex.edit = guiCreateEdit(0, 0, 1, 1, "", true, container)
	guiSetProperty(ColorPicker.gui.colors.hex.edit, "ValidationString", "[0-9A-Fa-f]*")
	guiSetVisible(ColorPicker.gui.colors.hex.edit, false)
	guiSetInternalData(ColorPicker.gui.colors.hex.edit, "type", "hex")
	addEventHandler("onClientGUIChanged", ColorPicker.gui.colors.hex.edit, ColorPicker.onHexEditChanged, false)
	
	ColorPicker.gui.ok = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Ok", false, btnsVlo)
	ColorPicker.gui.cancel = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Cancel", false, btnsVlo)

	local rgbVlo = guiCreateVerticalLayout(0, 0, 0, 0, gs.mrg2, false, mainHlo)
	for i, clr in ipairs({"r", "g", "b"}) do
		
		ColorPicker.gui.colors[clr] = {}
		local hlo = guiCreateHorizontalLayout(0, 0, 0, 0, 0, false, rgbVlo)
		
		ColorPicker.gui.colors[clr].lbl = guiCreateLabel(0, 0, gs.lbl.w, gs.btn.h, utf8.upper(clr)..":", false, hlo)
		guiLabelSetVerticalAlign(ColorPicker.gui.colors[clr].lbl, "center")
		
		ColorPicker.gui.colors[clr].edit = guiCreateEdit(0, 0, gs.edit.w, gs.btn.h, "0", false, hlo)
		guiEditSetMatcher(ColorPicker.gui.colors[clr].edit, guiGetInputNumericMatcher(true, 0, 255, 0))
		guiEditSetParser(ColorPicker.gui.colors[clr].edit, guiGetInputNumericParser(true, 0, 255))
		guiSetInternalData(ColorPicker.gui.colors[clr].edit, "type", clr)
		addEventHandler("onClientGUIChanged", ColorPicker.gui.colors[clr].edit, ColorPicker.onRGBEditChanged, false)
	end

	local hsvVlo = guiCreateVerticalLayout(0, 0, 0, 0, gs.mrg2, false, mainHlo)
	for i, clr in ipairs({"h", "s", "v"}) do
		
		ColorPicker.gui.colors[clr] = {}
		local hlo = guiCreateHorizontalLayout(0, 0, 0, 0, 0, false, hsvVlo)
		
		ColorPicker.gui.colors[clr].lbl = guiCreateLabel(0, 0, gs.lbl.w, gs.btn.h, utf8.upper(clr)..":", false, hlo)
		guiLabelSetVerticalAlign(ColorPicker.gui.colors[clr].lbl, "center")
		
		ColorPicker.gui.colors[clr].edit = guiCreateEdit(0, 0, gs.edit.w, gs.btn.h, "0", false, hlo)
		guiEditSetMatcher(ColorPicker.gui.colors[clr].edit, guiGetInputNumericMatcher(true, 0, clr == "h" and 360 or 100, 0))
		guiEditSetParser(ColorPicker.gui.colors[clr].edit, guiGetInputNumericParser(true, 0, clr == "h" and 360 or 100))
		guiSetInternalData(ColorPicker.gui.colors[clr].edit, "type", clr)
		addEventHandler("onClientGUIChanged", ColorPicker.gui.colors[clr].edit, ColorPicker.onHSVEditChanged, false)
	end

	local barVlo = guiCreateVerticalLayout(0, 0, 0, 0, gs.mrg2, false, mainHlo)
	for i, clr in ipairs({"h", "s", "v"}) do

		ColorPicker.gui.colors[clr].barImg = guiCreateStaticImage(0, 0, gs.bar.w, gs.btn.h, GUI_IMAGES_PATH..(clr == "h" and "colorpicker/hue" or "util/white")..".png", false, barVlo)
		guiSetProperty(ColorPicker.gui.colors[clr].barImg, "InheritsAlpha", "False")
		
		ColorPicker.gui.colors[clr].cursorImg = guiCreateStaticImage(0, 0, 0, 0, GUI_IMAGES_PATH.."colorpicker/hsvcursor.png", false, ColorPicker.gui.colors[clr].barImg)
		guiStaticImageSetSizeNative(ColorPicker.gui.colors[clr].cursorImg)
		guiSetVerticalAlign(ColorPicker.gui.colors[clr].cursorImg, "center")
		guiSetHorizontalAlign(ColorPicker.gui.colors[clr].cursorImg, "center")
		guiSetProperty(ColorPicker.gui.colors[clr].cursorImg, "ClippedByParent", "False")
		guiSetEnabled(ColorPicker.gui.colors[clr].cursorImg, false)
	end

	guiRebuildLayouts(ColorPicker.gui.window)
	local w, h = guiGetSize(mainHlo, false)
	guiSetSize(ColorPicker.gui.window, w + gs.mrg*2, h + gs.mrg*2, false)

	---------------------------------------------------------------------

	guiBindKey(ColorPicker.gui.ok, "enter")
	guiBindKey(ColorPicker.gui.cancel, "c")

	addEventHandler("onClientGUIMouseDown", ColorPicker.gui.window, ColorPicker.onMouseDown)
	addEventHandler("onClientClick", root, ColorPicker.onMouseUp)
	addEventHandler("onClientCursorMove", root, ColorPicker.onMouseMove)

	addEventHandler("onClientGUILeftClick", ColorPicker.gui.currentImg, ColorPicker.showHexEdit, false)
	addEventHandler("onClientGUIBlur", ColorPicker.gui.colors.hex.edit, ColorPicker.hideHexEdit)
	
	addEventHandler("onClientGUIBlur", ColorPicker.gui.window, ColorPicker.onBlur, false)
	addEventHandler("onClientGUILeftClick", ColorPicker.gui.cancel, ColorPicker.cancel, false)
	addEventHandler("onClientGUILeftClick", ColorPicker.gui.ok, ColorPicker.accept, false)

	return true
end

function ColorPicker.update()

	local color = ColorPicker.color
	color.r, color.g, color.b = hsv2rgb(color.h, color.s, color.v)
	color.hex = rgb2hexs(color.r, color.g, color.b)
	
	ColorPicker.editAntiRecursion = true

	guiSetText(ColorPicker.gui.colors.h.edit, tostring(math.round(color.h*360)))
	guiSetText(ColorPicker.gui.colors.s.edit, tostring(math.round(color.s*100)))
	guiSetText(ColorPicker.gui.colors.v.edit, tostring(math.round(color.v*100)))
	guiSetText(ColorPicker.gui.colors.r.edit, tostring(color.r))
	guiSetText(ColorPicker.gui.colors.g.edit, tostring(color.g))
	guiSetText(ColorPicker.gui.colors.b.edit, tostring(color.b))
	guiSetText(ColorPicker.gui.colors.hex.edit, utf8.gsub(color.hex, "#", ""))

	guiSetXPosition(ColorPicker.gui.colors.h.cursorImg, color.h-0.5, true)
	guiSetXPosition(ColorPicker.gui.colors.s.cursorImg, color.s-0.5, true)
	guiSetXPosition(ColorPicker.gui.colors.v.cursorImg, color.v-0.5, true)

	local ceguihex = guiToCEGUIColor(hsv2rgb(color.h, 1, color.v))
	local ceguihex2 = guiToCEGUIColor(hsv2rgb(color.h, 0, color.v))
	guiSetProperty(ColorPicker.gui.colors.s.barImg, "ImageColours", "tl:"..ceguihex2.." tr:"..ceguihex.." bl:"..ceguihex2.." br:"..ceguihex)
	
	ceguihex = guiToCEGUIColor(hsv2rgb(color.h, color.s, 1))
	guiSetProperty(ColorPicker.gui.colors.v.barImg, "ImageColours", "tl:FF000000 tr:"..ceguihex.." bl:FF000000 br:"..ceguihex)

	guiSetText(ColorPicker.gui.colors.hex.lbl, color.hex)
	guiStaticImageSetColor(ColorPicker.gui.currentImg, color.r, color.g, color.b)

	if color.v < 0.5 then
		guiLabelSetColor(ColorPicker.gui.colors.hex.lbl, 255, 255, 255)
	else
		guiLabelSetColor(ColorPicker.gui.colors.hex.lbl, 0, 0, 0)
	end

	ColorPicker.color = color
	ColorPicker.editAntiRecursion = false

	return true
end

function ColorPicker.prepare(element, r, g, b)

	local x, y = guiGetAbsolutePosition(element)
	local sx, sy = guiGetSize(element, false)

	x = x + sx + 2
	y = y - 10

	guiSetPosition(ColorPicker.gui.window, x, y, false)

	ColorPicker.color.r, ColorPicker.color.g, ColorPicker.color.b = r, g, b
	ColorPicker.color.h, ColorPicker.color.s, ColorPicker.color.v = rgb2hsv(r, g ,b)
	
	ColorPicker.editAntiRecursion = false
	ColorPicker.update()
	
	return true		
end

function ColorPicker.resume()
	if not ColorPicker.thread then return false end

	guiSetEnabled(ColorPicker.gui.window, false)
	guiSetVisible(ColorPicker.gui.window, false)

	coroutine.resume(ColorPicker.thread)
end

function ColorPicker.cancel()
	ColorPicker.accepted = false
	ColorPicker.resume()
end

function ColorPicker.accept()
	ColorPicker.accepted = true
	ColorPicker.resume()
end

function ColorPicker.showHexEdit()
	guiSetVisible(ColorPicker.gui.currentImg, false)
	guiSetVisible(ColorPicker.gui.colors.hex.edit, true)
	guiFocus(ColorPicker.gui.colors.hex.edit)
end

function ColorPicker.hideHexEdit()
	guiSetVisible(ColorPicker.gui.colors.hex.edit, false)
	guiSetVisible(ColorPicker.gui.currentImg, true)
end

function ColorPicker.onMouseDown(button)
	if button ~= "left" then return end

	for i, clr in ipairs({"h", "s", "v"}) do		
		if ColorPicker.gui.colors[clr].barImg == source then
			ColorPicker.picking = clr
			ColorPicker.onMouseMove()
			break
		end
	end
end

function ColorPicker.onMouseUp(button, state)
	if button ~= "left" then return end
	if state ~= "up" then return end

	ColorPicker.picking = false
end

function ColorPicker.onBlur()
	if not guiGetEnabled(ColorPicker.gui.window) then return false end

	ColorPicker.cancel()
end

function ColorPicker.onMouseMove()
	if not ColorPicker.picking then return end

	local cx = getCursorAbsolutePosition()
	local x = guiGetAbsolutePosition(ColorPicker.gui.colors[ColorPicker.picking].barImg)
	local w = guiGetSize(ColorPicker.gui.colors[ColorPicker.picking].barImg, false)
	ColorPicker.color[ColorPicker.picking] = (math.clamp(cx, x, x + w) - x)/w
	ColorPicker.update()
end

function ColorPicker.onRGBEditChanged()
	if ColorPicker.editAntiRecursion then return end

	local value = guiEditGetParsedValue(source)
	if not value then return end

	local color = guiGetInternalData(source, "type")
	ColorPicker.color[color] = value
	
	ColorPicker.color.h, ColorPicker.color.s, ColorPicker.color.v =
		rgb2hsv(ColorPicker.color.r, ColorPicker.color.g, ColorPicker.color.b)
	
	ColorPicker.update()

end

function ColorPicker.onHSVEditChanged()
	if ColorPicker.editAntiRecursion then return end

	local value = guiEditGetParsedValue(source)
	if not value then return end

	local color = guiGetInternalData(source, "type")
	value = value/(color == "h" and 360 or 100)

	ColorPicker.color[color] = value
	
	ColorPicker.update()

end

function ColorPicker.onHexEditChanged()
	if ColorPicker.editAntiRecursion then return end

	local text = guiGetText(source)
	if #text > 6 then
		text = utf8.sub(text, 1, 6)
	end
	while #text < 6 do
		text = text.."0"
	end
	guiSetText(source, text)

	ColorPicker.color.h, ColorPicker.color.s, ColorPicker.color.v = rgb2hsv(hexs2rgb("#"..text))
	ColorPicker.update()
end

ColorPicker.init()

function ColorPicker.onElementClick()

	local element = this

	if ColorPicker.thread then ColorPicker.cancel() end

	ColorPicker.thread = coroutine.running()
	ColorPicker.accepted = false

	local r, g, b = unpack(ColorPicker.elements[element].color)
	ColorPicker.prepare(element, r, g, b)
	guiSetVisible(ColorPicker.gui.window, true, true)
	guiSetEnabled(ColorPicker.gui.window, true)
	coroutine.yield()

	ColorPicker.thread = nil

	if not ColorPicker.accepted then return end

	r, g, b = ColorPicker.color.r, ColorPicker.color.g, ColorPicker.color.b
	guiColorPickerSetColor(element, r, g, b)
	triggerEvent("onClientGUIColorPickerAccepted", element, r, g, b)
end

function ColorPicker.onElementDestroy()
	ColorPicker.elements[source] = nil
end

function guiCreateColorPicker(x, y, width, height, r, g, b, relative, parent)
	if not scheck("n[4],?byte[3],b,?u:element:gui") then return false end

	local edit = guiCreateEdit(x, y, width, height, "", relative, parent)
	if not edit then return false end

	guiEditSetReadOnly(edit, true)

	ColorPicker.elements[edit] = {}
	guiColorPickerSetColor(edit, r, g, b)

	addEventHandler("onClientGUILeftClick", edit, ColorPicker.onElementClick, false)
	addEventHandler("onClientElementDestroy", edit, ColorPicker.onElementDestroy, false)

	return edit
end

function guiColorPickerSetColor(picker, r, g, b)
	if not scheck("u:element:gui-edit,?byte[3]") then return false end
	if not ColorPicker.elements[picker] then return false end

	local empty = not r and true or false

	r = r or 255
	g = g or 255
	b = b or 255

	guiEditSetReadOnlyBackGroundColor(picker, r, g, b)
	guiSetText(picker, empty and "N/A" or rgb2hexs(r, g, b))
	local h, s, v = rgb2hsv(r, g, b)
	guiSetColorProperty(picker, "NormalTextColour", unpack((v < 0.5) and {255,255,255} or {0,0,0}))

	ColorPicker.elements[picker].color = {r, g, b}
	ColorPicker.elements[picker].empty = empty

	return true
end

function guiColorPickerGetColor(picker)
	if not scheck("u:element:gui-edit") then return false end
	if not ColorPicker.elements[picker] then return false end

	if ColorPicker.elements[picker].empty then return nil end

	return unpack(ColorPicker.elements[picker].color)
end