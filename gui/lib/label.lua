
local _guiLabelGetFontHeight = guiLabelGetFontHeight
function guiLabelGetFontHeight(label)
	if not scheck("u:element:gui-label") then return false end

	return _guiLabelGetFontHeight(label) - 1
end

function guiLabelGetColor(label)
	if not scheck("u:element:gui-label") then return false end

	return guiGetColorsProperty(label, "TextColours")
end

function guiLabelSetColor(label, r, g, b, a)
	if not scheck("u:element:gui-label,byte[3],?byte") then return false end

	return guiSetColorsProperty(label, "TextColours", r, g, b, a)
end

local _guiLabelGetColor = guiLabelGetColor
function guiLabelGetColor(label)
	if not scheck("u:element:gui-label") then return false end

	local normal = guiGetCustomProperty(label, "NormalTextColor")
	if normal then return table.unpack(normal) end

	return _guiLabelGetColor(label)
end

local _guiLabelSetColor = guiLabelSetColor
function guiLabelSetColor(label, r, g, b, a)
	if not scheck("u:element:gui-label,byte[3],?byte") then return false end

	guiSetCustomProperty(label, "NormalTextColor", {r, g, b, a})
	return _guiLabelSetColor(label, r, g, b, a)
end

function guiLabelSetHoverColor(label, r, g, b, a)
	if not scheck("u:element:gui-label,?byte[4]") then return false end

	if not guiGetCustomProperty(label, "NormalTextColor") then
		guiSetCustomProperty(label, "NormalTextColor", {_guiLabelGetColor(label)})
	end

	if not r then return guiSetCustomProperty(label, "HoverTextColor", nil) end
	return guiSetCustomProperty(label, "HoverTextColor", {r, g, b, a})
end

function guiLabelSetDisabledColor(label, r, g, b, a)
	if not scheck("u:element:gui-label,?byte[4]") then return false end

	if not guiGetCustomProperty(label, "NormalTextColor") then
		guiSetCustomProperty(label, "NormalTextColor", {_guiLabelGetColor(label)})
	end

	if not r then return guiSetCustomProperty(label, "DisabledTextColor", nil) end
	return guiSetCustomProperty(label, "DisabledTextColor", {r, g, b, a})
end

function guiLabelSetHoverFont(label, font)
	if not scheck("u:element:gui-label,?s|u:element:gui-font") then return false end
	
	if not font then return guiSetCustomProperty(label, "HoverTextFont", nil) end

	if not guiGetCustomProperty(label, "NormalTextFont") then
		guiSetCustomProperty(label, "NormalTextFont", guiGetFont(label))
	end

	return guiSetCustomProperty(label, "HoverTextFont", font)
end

function guiLabelAdjustWidth(label)
	if not scheck("u:element:gui-label") then return false end
	
	local width = guiGetTextExtent(label)
	
	return guiSetWidth(label, width, false)
end

function guiLabelAdjustHeight(label)
	if not scheck("u:element:gui-label") then return false end
	
	local _, height = guiGetTextSize(label)
	
	return guiSetHeight(label, height, false)
end

function guiLabelAdjustSize(label)
	if not scheck("u:element:gui-label") then return false end

	local w, h = guiFontGetTextSize(guiGetText(label), guiGetFont(label))
	return guiSetSize(label, w, h, false)
end

local Label = {}

function Label.onMouseEnter()
	
	local color = guiGetCustomProperty(this, "HoverTextColor")
	if color then _guiLabelSetColor(this, table.unpack(color)) end

	local font = guiGetCustomProperty(this, "HoverTextFont")
	if font then guiSetFont(this, font) end

end

function Label.onMouseLeave()
	
	local color = guiGetCustomProperty(this, "NormalTextColor")
	if color then _guiLabelSetColor(this, table.unpack(color)) end
	
	local font = guiGetCustomProperty(this, "NormalTextFont")
	if font then guiSetFont(this, font) end

end

function Label.onDisabled()
	if not guiIsGrandParentFor(source, this) then return end

	local color = guiGetCustomProperty(this, "DisabledTextColor")
	if color then _guiLabelSetColor(this, table.unpack(color)) end

end

function Label.onEnabled()
	if not guiIsGrandParentFor(source, this) then return end
	if not guiGetEnabled(this) then return end

	local color = guiGetCustomProperty(this, "NormalTextColor")
	if color then _guiLabelSetColor(this, table.unpack(color)) end

end

local _guiCreateLabel = guiCreateLabel
function guiCreateLabel(x, y, width, height, text, relative, parent)
	if not scheck("n[4],s,b,?u:element:gui") then return false end

	local label = _guiCreateLabel(x, y, width, height, text, relative, parent)
	if not label then return label end

	addEventHandler("onClientMouseEnter", label, Label.onMouseEnter, false)
	addEventHandler("onClientMouseLeave", label, Label.onMouseLeave, false)
	addEventHandler("onClientGUIEnabled", label, Label.onEnabled)
	addEventHandler("onClientGUIDisabled", label, Label.onDisabled)

	return label
end