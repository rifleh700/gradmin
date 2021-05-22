
local ButtonIcon = {}

function ButtonIcon.onButtonColorChange()
	if not guiIsGrandParentFor(source, this) then return end

	local icon = guiGetInternalData(this, "icon")
	if not icon then return end

	local r, g, b, a = guiButtonGetNormalTextColor(this)
	if eventName == "onClientMouseEnter" then
		r, g, b, a = guiButtonGetHoverTextColor(this)
	elseif eventName == "onClientGUIDisabled" then
		r, g, b, a = guiButtonGetDisabledTextColor(this)
	end
	guiStaticImageSetColor(icon, r, g, b, a)

end

function guiButtonSetIcon(button, path, align)
	if not scheck("u:element:gui-button,?s,?s") then return false end

	local img = guiCreateStaticImage(0, 0, 0, 0, path, false, button)
	if not img then return false end

	guiSetEnabled(img, false)
	guiStaticImageSetSizeNative(img)
	guiSetVerticalAlign(img, "center")
	guiSetHorizontalAlign(img, align or "center")
	guiStaticImageSetColor(img, guiButtonGetCurrentTextColor(button))
	guiSetInternalData(button, "icon", img)

	addEventHandler("onClientMouseEnter", button, ButtonIcon.onButtonColorChange, false)
	addEventHandler("onClientMouseLeave", button, ButtonIcon.onButtonColorChange, false)
	addEventHandler("onClientGUIEnabled", button, ButtonIcon.onButtonColorChange)
	addEventHandler("onClientGUIDisabled", button, ButtonIcon.onButtonColorChange)

	return true
end