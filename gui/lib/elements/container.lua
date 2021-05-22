
function guiCreateContainer(x, y, w, h, relative, parent)
	if not scheck("n[4],b,?u:element:gui") then return false end
	
	local container = guiCreateStaticImage(x, y, w, h, GUI_WHITE_IMAGE_PATH, relative, parent)
	if not container then return false end

	guiStaticImageSetColor(container, 0, 0, 0, 0)

	return container
end