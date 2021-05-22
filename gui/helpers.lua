
local gs = {}

gs.header = {}
gs.header.normalColor = GS.clr.red
gs.header.font = "default-bold-small"

gs.clickablelbl = {}
gs.clickablelbl.hoverColor = {118, 143, 246}

gs.searchedit = {}
gs.searchedit.icon = GUI_IMAGES_PATH.."elements/search.png"

gs.helpbutton = {}
gs.helpbutton.size = GS.h
gs.helpbutton.icon = GUI_IMAGES_PATH.."elements/info.png"
gs.helpbutton.hoverTextColor = GS.clr.aqua

gs.acb = {}
gs.acb.color = GS.clr.white

gs.glsearchedit = {}
gs.glsearchedit.mrg = 3
gs.glsearchedit.h = 18

gs.glowbutton = {}
gs.glowbutton.normalTextColor = {255, 255, 0}
gs.glowbutton.hoverTextColor = {255, 255, 127}

gs.glbutton = {}
gs.glbutton.mrg = 3
gs.glbutton.h = 18

gs.glcreatebtn = {}
gs.glcreatebtn.w = 30
gs.glcreatebtn.icon = GUI_IMAGES_PATH.."elements/plus.png"
gs.glcreatebtn.hoverTextColor = GS.clr.green

gs.gldestroybtn = {}
gs.gldestroybtn.w = 30
gs.gldestroybtn.icon = GUI_IMAGES_PATH.."elements/minus.png"
gs.gldestroybtn.hoverTextColor = GS.clr.red


function guiCreateHeader(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local element = guiCreateLabel(x, y, width, height, text, relative, parent)
	if not element then return element end

	guiSetFont(element, gs.header.font)
	guiLabelSetNormalTextColor(element, table.unpack(gs.header.normalColor))

	return element
end

function guiCreateClickableLabel(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local element = guiCreateLabel(x, y, width, height, text, relative, parent)
	if not element then return element end

	guiLabelSetHoverColor(label, table.unpack(gs.clickablelbl.hoverColor))

	return true
end


function guiLabelSetClickableStyle(label)
	if not scheck("u:element:gui-label") then return false end

	guiLabelSetHoverColor(label, table.unpack(gs.clickablelbl.hoverColor))

	return true
end

function guiCreateSearchEdit(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local element = guiCreateEdit(x, y, width, height, text, relative, parent)
	if not element then return element end

	guiEditSetIcon(element, gs.searchedit.icon)

	return element
end

function guiButtonSetGlowStyle(button)
	if not scheck("u:element:gui-button") then return false end

	return guiButtonSetStyle(button, gs.glowbutton)
end

function guiCreateHelpButton(x, y, size, relative, parent)
	if not scheck("?n[3],?b,?u:element:gui") then return false end

	size = size or gs.helpbutton.size

	local element = guiCreateButton(x, y, size, size, "", relative, parent)
	if not element then return element end

	guiSetWidth(element, guiGetHeight(element, false), false)
	guiButtonSetIcon(element, gs.helpbutton.icon)
	guiButtonSetHoverTextColor(element, table.unpack(gs.helpbutton.hoverTextColor))
	
	return element
end

function guiCreateAdvancedComboBox(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local element = guiCreateEdit(x, y, width, height, text, relative, parent)
	if not element then return element end
	
	guiEditSetReadOnly(element, true)
	guiEditSetReadOnlyBackGroundColor(element, table.unpack(gs.acb.color))
	
	return element, guiEditAddComboBox(element)
end

function guiCreateComboBoxButton(x, y, width, height, text, relative, parent, ...)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local element = guiCreateButton(x, y, width, height, text, relative, parent, ...)
	if not element then return element end
	
	return element, guiButtonAddComboBox(element)
end

function guiCreateKeyValueLabels(x, y, keyWidth, valueWidth, height, keyText, valueText, relative, parent)
	if not scheck("?n[5],?s[2],?b,?u:element:gui") then return false end

	local hlo = guiCreateHorizontalLayout(x, y, 0, 0, nil, relative, parent)
	
	local keyLabel = guiCreateLabel(0, 0, keyWidth, height, keyText, false, hlo)
	guiLabelSetHorizontalAlign(keyLabel, "right")
	
	local valueLabel = guiCreateLabel(0, 0, valueWidth, height, valueText, false, hlo)
	guiHorizontalLayoutRebuild(hlo)

	return keyLabel, valueLabel, hlo
end

function guiCreateKeyValueEdit(x, y, keyWidth, valueWidth, height, keyText, valueText, relative, parent)
	if not scheck("?n[5],?s[2],?b,?u:element:gui") then return false end

	local hlo = guiCreateHorizontalLayout(x, y, 0, 0, nil, relative, parent)
	
	local keyLabel = guiCreateLabel(0, 0, keyWidth, height, keyText, false, hlo)
	guiLabelSetHorizontalAlign(keyLabel, "right")
	
	local valueEdit = guiCreateEdit(0, 0, valueWidth, height, valueText, false, hlo)
	guiHorizontalLayoutRebuild(hlo)
	
	return keyLabel, valueEdit, hlo
end

function guiCreateKeyValueCheckBox(x, y, keyWidth, valueWidth, height, keyText, valueText, relative, parent)
	if not scheck("?n[5],?s[2],?b,?u:element:gui") then return false end

	local hlo = guiCreateHorizontalLayout(x, y, 0, 0, nil, relative, parent)
	
	local keyLabel = guiCreateLabel(0, 0, keyWidth, height, keyText, false, hlo)
	guiLabelSetHorizontalAlign(keyLabel, "right")
	
	local checkbox = guiCreateCheckBox(0, 0, valueWidth, height, valueText, false, false, hlo)
	guiHorizontalLayoutRebuild(hlo)
	
	return keyLabel, checkbox, hlo
end

function guiCreateKeyValueColorPicker(x, y, keyWidth, valueWidth, height, keyText, r, g, b, relative, parent)
	if not scheck("?n[5],?s,?byte[3],?b,?u:element:gui") then return false end

	local hlo = guiCreateHorizontalLayout(x, y, 0, 0, nil, relative, parent)
	
	local keyLabel = guiCreateLabel(0, 0, keyWidth, height, keyText, false, hlo)
	guiLabelSetHorizontalAlign(keyLabel, "right")
	
	local valueColorPicker = guiCreateColorPicker(0, 0, valueWidth, height, r, g, b, false, hlo)
	guiHorizontalLayoutRebuild(hlo)
	
	return keyLabel, valueColorPicker, hlo
end

function guiGridListCreateSearchEdit(list)
	if not scheck("u:element:gui-gridlist") then return false end

	local edit = guiCreateSearchEdit(gs.glsearchedit.mrg, gs.glsearchedit.mrg, -GS.scroll.size - gs.glsearchedit.mrg, gs.glsearchedit.h, "", false, list)
	if not edit then return edit end

	guiSetRawWidth(edit, 1, true)
	guiSetAlwaysOnTop(edit, true)

	return edit
end

function guiGridListAddButton(list, text, width)
	if not scheck("u:element:gui-gridlist,s,?n") then return false end

	local hlo = guiGetData(list, "buttonsLayout")
	if not hlo then
		hlo = guiCreateHorizontalLayout(-GS.scroll.size - gs.glbutton.mrg, gs.glbutton.mrg, nil, nil, GS.mrg, false, list)
		guiSetAlwaysOnTop(hlo, true)
		guiSetHorizontalAlign(hlo, "right")
		guiSetData(list, "buttonsLayout", hlo)
	end

	local button = guiCreateButton(nil, nil, 0, gs.glbutton.h, text, false, hlo)
	if not button then return button end

	width = width or (guiGetTextExtent(button) + 20)
	guiSetWidth(button, width, false)
	guiHorizontalLayoutRebuild(hlo)

	return button
end

function guiGridListAddCreateButton(list)
	if not scheck("u:element:gui-gridlist") then return false end

	local button = guiGridListAddButton(list, "", gs.glcreatebtn.w)
	if not button then return button end

	guiButtonSetIcon(button, gs.glcreatebtn.icon)
	guiButtonSetHoverTextColor(button, unpack(gs.glcreatebtn.hoverTextColor))

	return button
end

function guiGridListAddDestroyButton(list)
	if not scheck("u:element:gui-gridlist") then return false end

	local button = guiGridListAddButton(list, "", gs.gldestroybtn.w)
	if not button then return button end

	guiButtonSetIcon(button, gs.gldestroybtn.icon)
	guiButtonSetHoverTextColor(button, table.unpack(gs.gldestroybtn.hoverTextColor))

	return button
end

function guiCreateScrollableLabel(x, y, width, height, text, relative, parent)
	if not scheck("?n[4],?s,?b,?u:element:gui") then return false end

	local pane = guiCreateScrollPane(x, y, width, height, relative or false, parent)
	if not pane then return pane end

	text = text and tostring(text) or GS.nilText

	local label = guiCreateLabel(0, 0, 1, 1, text, true, pane)
	guiSetRawWidth(label, -GS.scroll.size, false)
	guiLabelSetHorizontalAlign(label, "left", true)
	guiLabelSetVerticalAlign(label, "top")

	return label
end