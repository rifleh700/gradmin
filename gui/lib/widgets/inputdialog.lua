
local gs = {}
gs.w = 300
gs.mrg = 10
gs.mrg2 = 5
gs.btn = {}
gs.btn.w = 80
gs.btn.h = 20
gs.edit = {}
gs.edit.h = 25

local InputDialog = {}

InputDialog.gui = {}
InputDialog.thread = nil
InputDialog.focused = nil
InputDialog.result = nil
InputDialog.accepted = nil
InputDialog.allowInvalid = false

function InputDialog.init()
	InputDialog.gui.window = guiCreateWindow(0, 0, gs.w, 20 + gs.edit.h * 2 + gs.btn.h + gs.mrg * 4, "", false)
	guiSetEnabled(InputDialog.gui.window, false)
	guiSetVisible(InputDialog.gui.window, false)
	guiWindowSetSizable(InputDialog.gui.window, false)
	guiSetAlwaysOnTop(InputDialog.gui.window, true)

	InputDialog.gui.lbl = guiCreateLabel(0, 0, 0, 0, "", false, InputDialog.gui.window)
	guiLabelSetHorizontalAlign(InputDialog.gui.lbl, "left", true)
	
	InputDialog.gui.edit = guiCreateEdit(0, 0, gs.w - gs.mrg*2, gs.edit.h, "", false, InputDialog.gui.window)
	
	InputDialog.gui.ok = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Ok", false, InputDialog.gui.window)
	InputDialog.gui.cancel = guiCreateButton(0, 0, gs.btn.w, gs.btn.h, "Cancel", false, InputDialog.gui.window)
	
	guiBindKey(InputDialog.gui.ok, "enter")
	guiBindKey(InputDialog.gui.cancel, "c")
	guiBindKey(InputDialog.gui.cancel, "n")

	addEventHandler("onClientGUIAccepted", InputDialog.gui.edit, InputDialog.accept, false)
	addEventHandler("onClientGUILeftClick", InputDialog.gui.ok, InputDialog.accept, false) 
	addEventHandler("onClientGUILeftClick", InputDialog.gui.cancel, InputDialog.cancel, false) 
end

function InputDialog.prepare(title, message, value, parser, matcher)

	guiSetText(InputDialog.gui.window, title or "")
	guiSetText(InputDialog.gui.lbl, (message or "Enter the value")..":")
	guiSetText(InputDialog.gui.edit, value ~= nil and tostring(value) or "")
	guiEditSetCaretIndex(InputDialog.gui.edit)
	guiEditSetParser(InputDialog.gui.edit, parser)
	guiEditSetMatcher(InputDialog.gui.edit, matcher)

	local lblw, lblh = guiGetTextSize(InputDialog.gui.lbl, gs.w - gs.mrg * 2 - gs.mrg2)
	lblw = gs.w - gs.mrg * 2 - gs.mrg2

	local winh = 20 + lblh + gs.edit.h + gs.btn.h + gs.mrg * 3 + gs.mrg2
	guiSetSize(InputDialog.gui.window, gs.w, winh, false)
	guiCenter(InputDialog.gui.window)

	local x = gs.mrg
	local y = 20 + gs.mrg
	guiSetPosition(InputDialog.gui.lbl, x + gs.mrg2, y, false)
	guiSetSize(InputDialog.gui.lbl, lblw, lblh, false)

	y = y + lblh + gs.mrg2
	guiSetPosition(InputDialog.gui.edit, x, y, false)

	x = (gs.w - gs.btn.w*2 - gs.mrg)/2
	y = y + gs.edit.h + gs.mrg
	guiSetPosition(InputDialog.gui.ok, x, y, false)

	x = x + gs.btn.w + gs.mrg
	guiSetPosition(InputDialog.gui.cancel, x, y, false)

	return true
end

function InputDialog.resume()
	if not InputDialog.thread then return end

	guiSetEnabled(InputDialog.gui.window, false)
	guiSetVisible(InputDialog.gui.window, false)

	coroutine.resume(InputDialog.thread)
end

function InputDialog.accept()

	InputDialog.result = table.pack(guiEditGetParsedValue(InputDialog.gui.edit))
	if (not InputDialog.allowInvalid) and (not InputDialog.result[1]) then
		return guiShowMessageDialog("Invalid value", nil, MD_OK, MD_ERROR) and false
	end

	InputDialog.accepted = true
	InputDialog.resume()

	return true
end

function InputDialog.cancel()

	InputDialog.accepted = false
	InputDialog.resume()

	return true
end

InputDialog.init()

function guiShowInputDialog(title, message, value, parser, allowInvalid, matcher)
	if not scheck("?s[2],?s|n|b,?f,?b,?f") then return false end

	if InputDialog.thread then InputDialog.cancel() end

	coroutine.sleep(10)

	InputDialog.thread = coroutine.running()
	InputDialog.accepted = false
	InputDialog.focused = guiGetFocused()
	InputDialog.allowInvalid = allowInvalid

	InputDialog.prepare(title, message, value, parser, matcher)
	guiSetVisible(InputDialog.gui.window, true, true)
	guiSetEnabled(InputDialog.gui.window, true)
	guiFocus(InputDialog.gui.edit)
	coroutine.yield()

	local accepted = InputDialog.accepted
	local data = InputDialog.result
	InputDialog.thread = nil
	coroutine.sleep(10)

	guiFocus(InputDialog.focused)

	if not accepted then return false end

	return table.unpack(data)
end
