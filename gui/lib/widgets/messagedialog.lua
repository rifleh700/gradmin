
enum({
	"MD_OK",
	"MD_OK_CANCEL",
	"MD_YES_NO",
	"MD_YES_NO_CANCEL"
})

enum({
	"MD_ERROR",
	"MD_WARNING",
	"MD_QUESTION",
	"MD_INFO",
	"MD_PLAIN"
})

local gs = {}
gs.ratio = 3/2
gs.w = 400
gs.mrg = 10
gs.btn = {}
gs.btn.w = 80
gs.btn.h = 20
gs.img = {}
gs.img.w = 42
gs.img.h = 42
gs.headers = {
	[MD_ERROR] = "Error",
	[MD_WARNING] = "Warning",
	[MD_QUESTION] = "Question",
	[MD_INFO] = "Information"
}
gs.btn.text = {
	[MD_OK] = {"ok"},
	[MD_OK_CANCEL] = {"ok", "cancel"},
	[MD_YES_NO] = {"yes", "no"},
	[MD_YES_NO_CANCEL] = {"yes", "no", "cancel"}
}

local MessageDialog = {}

MessageDialog.gui = {}
MessageDialog.thread = nil
MessageDialog.focused = nil
MessageDialog.options = {}
MessageDialog.result = nil

function MessageDialog.init()

	MessageDialog.gui.window = guiCreateWindow(0, 0, gs.w, 20 + gs.img.h + gs.mrg * 5, "", false)
	guiSetEnabled(MessageDialog.gui.window, false)
	guiSetVisible(MessageDialog.gui.window, false)
	guiWindowSetSizable(MessageDialog.gui.window, false)
	guiSetAlwaysOnTop(MessageDialog.gui.window, true)

	MessageDialog.gui.img = guiCreateStaticImage(0, 0, gs.img.w, gs.img.h, GUI_EMPTY_IMAGE_PATH, false, MessageDialog.gui.window)
	MessageDialog.gui.infoImg = guiCreateStaticImage(0, 0, 1, 1, GUI_IMAGES_PATH.."dialog/info.png", true, MessageDialog.gui.img)
	MessageDialog.gui.questionImg = guiCreateStaticImage(0, 0, 1, 1, GUI_IMAGES_PATH.."dialog/question.png", true, MessageDialog.gui.img)
	MessageDialog.gui.warningImg = guiCreateStaticImage(0, 0, 1, 1, GUI_IMAGES_PATH.."dialog/warning.png", true, MessageDialog.gui.img)
	MessageDialog.gui.errorImg = guiCreateStaticImage(0, 0, 1, 1, GUI_IMAGES_PATH.."dialog/error.png", true, MessageDialog.gui.img)
	
	MessageDialog.gui.lbl = guiCreateLabel(0, 0, gs.w, gs.img.h, "", false, MessageDialog.gui.window)
	guiLabelSetHorizontalAlign(MessageDialog.gui.lbl, "center", true)
	guiLabelSetVerticalAlign(MessageDialog.gui.lbl, "center")
	
	MessageDialog.gui.btns = {}
	MessageDialog.gui.btns.yes = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Yes", false, MessageDialog.gui.window)
	MessageDialog.gui.btns.no = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "No", false, MessageDialog.gui.window)
	MessageDialog.gui.btns.ok = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Ok", false, MessageDialog.gui.window)
	MessageDialog.gui.btns.cancel = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Cancel", false, MessageDialog.gui.window)

	guiBindKey(MessageDialog.gui.btns.yes, "enter")
	guiBindKey(MessageDialog.gui.btns.no, "n")
	guiBindKey(MessageDialog.gui.btns.ok, "enter")
	guiBindKey(MessageDialog.gui.btns.cancel, "c")

	addEventHandler("onClientGUILeftClick", MessageDialog.gui.btns.yes, MessageDialog.yes, false)
	addEventHandler("onClientGUILeftClick", MessageDialog.gui.btns.no, MessageDialog.no, false)
	addEventHandler("onClientGUILeftClick", MessageDialog.gui.btns.ok, MessageDialog.yes, false)
	addEventHandler("onClientGUILeftClick", MessageDialog.gui.btns.cancel, MessageDialog.cancel, false)

	return true
end

function MessageDialog.prepare(message, header, optionType, iconType)
	if not optionType then optionType = MD_OK end
	if not iconType then iconType = MD_INFO end

	guiSetText(MessageDialog.gui.window, header or gs.headers[iconType] or "")
	guiSetText(MessageDialog.gui.lbl, message)
	
	guiSetVisible(MessageDialog.gui.warningImg, iconType == MD_WARNING)
	guiSetVisible(MessageDialog.gui.questionImg, iconType == MD_QUESTION)
	guiSetVisible(MessageDialog.gui.errorImg, iconType == MD_ERROR)
	guiSetVisible(MessageDialog.gui.infoImg, iconType == MD_INFO)

	local btns = gs.btn.text[optionType]
	local btnsw = (gs.btn.w + gs.mrg) * #btns - gs.mrg
	local lblw, lblh = guiGetTextSize(MessageDialog.gui.lbl, gs.w)
	lblw = math.max(lblw, btnsw, gs.w)
	lblh = math.max(lblh, gs.img.h + gs.mrg*2)

	local winw = gs.img.w + lblw + gs.mrg*6
	local winh = 20 + lblh + gs.btn.h + gs.mrg*3
	guiSetSize(MessageDialog.gui.window, winw, winh, false)
	guiCenter(MessageDialog.gui.window)

	local x = gs.mrg*2
	local y = 20 + gs.mrg + (lblh - gs.img.h) / 2
	guiSetPosition(MessageDialog.gui.img, x, y, false)

	x = x + gs.img.w + gs.mrg*2
	y = 20 + gs.mrg
	guiSetPosition(MessageDialog.gui.lbl, x, y, false)
	guiSetSize(MessageDialog.gui.lbl, lblw, lblh, false)

	for name, btn in pairs(MessageDialog.gui.btns) do
		guiSetEnabled(btn, false)
		guiSetVisible(btn, false)
	end

	x = gs.img.w + gs.mrg*4 + (lblw - btnsw)/2
	y = winh - gs.mrg - gs.btn.h
	for i, name in ipairs(btns) do
		guiSetVisible(MessageDialog.gui.btns[name], true)
		guiSetEnabled(MessageDialog.gui.btns[name], true)
		guiSetPosition(MessageDialog.gui.btns[name], x, y, false)
		x = x + gs.btn.w + gs.mrg
	end

	return true
end

function MessageDialog.resume()
	if not MessageDialog.thread then return end

	guiSetEnabled(MessageDialog.gui.window, false)
	guiSetVisible(MessageDialog.gui.window, false)

	coroutine.resume(MessageDialog.thread)
end

function MessageDialog.yes()
	MessageDialog.result = true
	MessageDialog.resume()
end

function MessageDialog.no()
	MessageDialog.result = false
	MessageDialog.resume()
end

function MessageDialog.cancel()
	MessageDialog.result = nil
	MessageDialog.resume()
end

MessageDialog.init()

function guiShowMessageDialog(message, header, optionType, iconType)
	if not scheck("s,?s") then return false end

	if MessageDialog.thread then MessageDialog.cancel() end

	coroutine.sleep(10)

	MessageDialog.thread = coroutine.running()
	MessageDialog.result = false
	MessageDialog.focused = guiGetFocused()

	MessageDialog.prepare(message, header, optionType, iconType)
	guiSetVisible(MessageDialog.gui.window, true, true)
	guiSetEnabled(MessageDialog.gui.window, true)
	guiFocus(MessageDialog.gui.window)

	coroutine.yield()

	MessageDialog.thread = nil

	coroutine.sleep(10)
	guiFocus(MessageDialog.focused)

	return MessageDialog.result
end