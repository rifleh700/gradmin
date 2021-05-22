
function guiButtonSetHoverTextColor(button, r, g, b)
	if not scheck("u:element:gui-button,byte[3]") then return false end

	return guiSetColorProperty(button, "HoverTextColour", r, g, b)
end

function guiButtonGetHoverTextColor(button)
	if not scheck("u:element:gui-button") then return false end

	return guiGetColorProperty(button, "HoverTextColour")
end

function guiButtonSetNormalTextColor(button, r, g, b)
	if not scheck("u:element:gui-button,byte[3]") then return false end

	return guiSetColorProperty(button, "NormalTextColour", r, g, b)
end

function guiButtonGetNormalTextColor(button)
	if not scheck("u:element:gui-button") then return false end

	return guiGetColorProperty(button, "NormalTextColour")
end

function guiButtonSetDisabledTextColor(button, r, g, b)
	if not scheck("u:element:gui-button,byte[3]") then return false end

	return guiSetColorProperty(button, "DisabledTextColour", r, g, b)
end

function guiButtonGetDisabledTextColor(button)
	if not scheck("u:element:gui-button") then return false end

	return guiGetColorProperty(button, "DisabledTextColour")
end

function guiButtonGetCurrentTextColor(button)
	if not scheck("u:element:gui-button") then return false end

	return guiGetColorProperty(button, guiGetEnabled(button) and "NormalTextColour" or "DisabledTextColour")
end