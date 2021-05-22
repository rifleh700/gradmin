
function guiEditSetIcon(edit, path, r, g, b, a)
	if not scheck("u:element:gui-edit,s,?n[4]") then return false end

	r = r and math.clamp(r, 0, 255) or 0
	g = g and math.clamp(g, 0, 255) or 0
	b = b and math.clamp(b, 0, 255) or 0
	a = a and math.clamp(a, 0, 255) or 255

	local height = guiGetHeight(edit, false)
	local img = guiCreateStaticImage(-height * 0.25, 0, 0, 0, path, false, edit)
	guiSetEnabled(img, false)
	guiStaticImageSetSizeNative(img)
	guiSetVerticalAlign(img, "center")
	guiSetHorizontalAlign(img, "right")
	guiStaticImageSetColor(img, r, g, b, a)
	guiSetInternalData(edit, "icon", img)

	return img
end