
local ZOOM_SPEED = 0.1

local gs = {}
gs.mrgT = 20
gs.mrg = 10
gs.btn = {}
gs.btn.w = 80
gs.btn.h = 20
gs.maxw = GUI_SCREEN_WIDTH - 80 - gs.mrg*2
gs.maxh = GUI_SCREEN_HEIGHT - 80 - (gs.mrg*3 + gs.mrgT + gs.btn.h)

local ImageViewer = {}

ImageViewer.gui = {}
ImageViewer.big = false
ImageViewer.moving = false

function ImageViewer.init()

	ImageViewer.gui.window = guiCreateWindow(0, 0, gs.maxw, gs.maxh, "Image viewer", false)
	guiSetVisible(ImageViewer.gui.window, false)
	ImageViewer.gui.layout = guiCreateVerticalLayout(gs.mrg, gs.mrg + gs.mrgT, 0, 0, gs.mrg, false, ImageViewer.gui.window)
	guiVerticalLayoutSetHorizontalAlign(ImageViewer.gui.layout, "center")

	ImageViewer.gui.container = guiCreateContainer(0, 0, 0, 0, false, ImageViewer.gui.layout)
	ImageViewer.gui.img = guiCreateStaticImage(0, 0, 1, 1, GUI_EMPTY_IMAGE_PATH, true, ImageViewer.gui.container)
	ImageViewer.gui.okBtn = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Ok", false, ImageViewer.gui.layout)

	guiBindKey(ImageViewer.gui.okBtn, "enter")

	addEventHandler("onClientGUILeftClick", ImageViewer.gui.okBtn, ImageViewer.hide, false)
	addEventHandler("onClientMouseWheel", ImageViewer.gui.img, ImageViewer.onScroll, false)
	addEventHandler("onClientGUIMouseDown", ImageViewer.gui.img, ImageViewer.onMouseDown, false)
	addEventHandler("onClientClick", root, ImageViewer.onMouseUp)
	addEventHandler("onClientCursorMove", root, ImageViewer.onMouseMove)

	return true
end

function ImageViewer.show(path)
	
	if not guiStaticImageLoadImage(ImageViewer.gui.img, path) then return false end

	local w, h = guiStaticImageGetNativeSize(ImageViewer.gui.img)
	guiSetMaxSize(ImageViewer.gui.img, w, h, false)

	ImageViewer.big = false
	if w > gs.maxw then
		h = h * (gs.maxw/w)
		w = gs.maxw
		ImageViewer.big = true
	end
	if h > gs.maxh then
		w = w * (gs.maxh/h)
		h = gs.maxh
		ImageViewer.big = true
	end
	ImageViewer.maxw = w
	ImageViewer.maxh = h

	guiSetSize(ImageViewer.gui.container, w, h, false)
	guiSetPosition(ImageViewer.gui.img, 0, 0, false)
	guiSetSize(ImageViewer.gui.img, w, h, false)
	guiVerticalLayoutRebuild(ImageViewer.gui.layout)
	local lw, lh = guiGetSize(ImageViewer.gui.layout, false)
	guiSetSize(ImageViewer.gui.window, lw + gs.mrg*2, lh + gs.mrg*2 + gs.mrgT, false)
	guiCenter(ImageViewer.gui.window)
	guiSetVisible(ImageViewer.gui.window, true, true)
	showCursor(true)

end

function ImageViewer.hide()
	
	return guiSetVisible(ImageViewer.gui.window, false)
end

function ImageViewer.onScroll(vector)
	if not ImageViewer.big then return false end

	local nw, nh = guiStaticImageGetNativeSize(ImageViewer.gui.img)
	local w, h = guiGetSize(ImageViewer.gui.img, false)
	local w2 = math.clamp(w * (1 + ZOOM_SPEED * vector), ImageViewer.maxw, nw)
	local h2 = math.clamp(h * (1 + ZOOM_SPEED * vector), ImageViewer.maxh, nh)
	
	local wscale = w2/w
	local hscale = h2/h
	if wscale == 1 and hscale == 1 then return end

	guiSetSize(ImageViewer.gui.img, w2, h2, false)
	
	local cx, cy = getCursorAbsolutePosition()
	local ax, ay = guiGetAbsolutePosition(ImageViewer.gui.img)
	local x, y = guiGetPosition(ImageViewer.gui.img, false)
	local x2 = math.clamp(x - ((cx - ax) * (wscale - 1)), ImageViewer.maxw - w2, 0)
    local y2 = math.clamp(y - ((cy - ay) * (hscale - 1)), ImageViewer.maxh - h2, 0)
	guiSetPosition(ImageViewer.gui.img, x2, y2, false)

end

function ImageViewer.onMouseDown(button, x, y)
	if button ~= "left" then return end
	if not ImageViewer.big then return end
	
	ImageViewer.cursorX = x
	ImageViewer.cursorY = y	
	ImageViewer.moving = true

end

function ImageViewer.onMouseUp(button, state)
	if state ~= "up" then return end
	if button ~= "left" then return end
	
	ImageViewer.moving = false

end

function ImageViewer.onMouseMove(_, _, cx, cy)
	if not ImageViewer.big then return end
	if not ImageViewer.moving then return end

	local x, y = guiGetPosition(ImageViewer.gui.img, false)
	local w, h = guiGetSize(ImageViewer.gui.img, false)
	local x2 = math.clamp(x + (cx - ImageViewer.cursorX), ImageViewer.maxw - w, 0)
	local y2 = math.clamp(y + (cy - ImageViewer.cursorY), ImageViewer.maxh - h, 0)
	guiSetPosition(ImageViewer.gui.img, x2, y2, false)
		
	ImageViewer.cursorX = cx
	ImageViewer.cursorY = cy	

end

ImageViewer.init()

function guiShowImageViewer(path)
	if not scheck("s") then return false end
	if not fileExists(path) then return false end

	return ImageViewer.show(path)
end