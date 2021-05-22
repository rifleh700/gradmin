
local gs = {}
gs.clr = COLORS.grey

function guiCreateHorizontalSeparator(x, y, length, relative, parent)
	if not scheck("n[3],b,?u:element:gui") then return false end

	local image = guiCreateStaticImage(x, y, length, 0, GUI_WHITE_IMAGE_PATH, relative, parent)
	guiSetHeight(image, 1, false)
	guiStaticImageSetColor(image, table.unpack(gs.clr))

	return image
end

function guiCreateVerticalSeparator(x, y, length, relative, parent)
	if not scheck("n[3],b,?u:element:gui") then return false end

	local image = guiCreateStaticImage(x, y, 0, length, GUI_WHITE_IMAGE_PATH, relative, parent)
	guiSetWidth(image, 1, false)
	guiStaticImageSetColor(image, table.unpack(gs.clr))

	return image
end

function guiSeparatorGetColor(separator)
	if not scheck("u:element:gui-staticimage") then return false end

	return guiStaticImageGetColor(separator)
end

function guiSeparatorSetColor(separator, r, g, b, a)
	if not scheck("u:element:gui-staticimage,n[3],?n") then return false end

	return guiStaticImageSetColor(separator, r, g, b, a)
end