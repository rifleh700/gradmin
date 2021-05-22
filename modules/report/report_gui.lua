
local SHOW_SCREENSHOTS_LIMIT = 40
local MESSAGE_MIN_LENGTH = 5
local MESSAGE_MAX_LENGTH = 1000

local gs = {}
gs.attach = {}
gs.attach.w = 640
gs.attach.h = 480

mReport.gui = {}
mReport.gui.attached = {}

function mReport.gui.init()

	mReport.gui.window = guiCreateWindow(nil, nil, nil, nil, "mReport")
	local mainVlo = guiCreateVerticalLayout(nil, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, mReport.gui.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")
	guiSetTableProperty(mainVlo, "UnifiedSize", {{1, -GS.mrg2*2}, {1, -GS.mrg2*2}})

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")
	mReport.gui.messageMemo = guiCreateMemo(nil, nil, GS.w4, GS.h3, "", false, vlo)
	mReport.gui.attachBtn = guiCreateButton(nil, nil, GS.w3, nil, "Attach screenshots...", false, vlo)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	mReport.gui.sendBtn = guiCreateButton(nil, nil, nil, nil, "Send", nil, hlo)
	mReport.gui.cancelBtn = guiCreateButton(nil, nil, nil, nil, "Cancel", nil, hlo)

	guiRebuildLayouts(mReport.gui.window)

	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(mReport.gui.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)

	----------------------------------------

	mReport.gui.Attach = {}

	mReport.gui.Attach.window = guiCreateWindow(nil, nil, nil, nil, "Attach screenshots")
	local mainVlo = guiCreateVerticalLayout(nil, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, mReport.gui.Attach.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")
	guiSetTableProperty(mainVlo, "UnifiedSize", {{1, -GS.mrg2*2}, {1, -GS.mrg2*2}})

	mReport.gui.Attach.imageList = guiCreateImageGridList(0, 0, gs.attach.w, gs.attach.h, false, mainVlo)
	guiImageGridListSetColumns(mReport.gui.Attach.imageList, 3)
	guiImageGridListSetViewEnabled(mReport.gui.Attach.imageList, true)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	mReport.gui.Attach.sendBtn = guiCreateButton(nil, nil, nil, nil, "Attach", nil, hlo)
	mReport.gui.Attach.cancelBtn = guiCreateButton(nil, nil, nil, nil, "Cancel", nil, hlo)

	guiRebuildLayouts(mReport.gui.Attach.window)

	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(mReport.gui.Attach.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)
	guiCenter(mReport.gui.Attach.window)

	----------------------------------------

	addEventHandler("onClientGUILeftClick", mReport.gui.attachBtn, mReport.gui.onClickAttach, false)
	addEventHandler("onClientGUILeftClick", mReport.gui.sendBtn, mReport.gui.onClickSend, false)
	addEventHandler("onClientGUILeftClick", mReport.gui.cancelBtn, mReport.gui.hide, false)

	return true
end

function mReport.gui.show(message)

	mReport.attached = {}
	local screenshotsLimit = mReport.getScreenshotsLimit()
	local screenshotIDs = mScreenshotSaver.getValidIDs(SHOW_SCREENSHOTS_LIMIT)

	guiSetText(mReport.gui.messageMemo, message or "")
	guiSetText(mReport.gui.attachBtn, "Attach screenshots...")
	guiSetEnabled(mReport.gui.attachBtn, (screenshotsLimit > 0) and (#screenshotIDs > 0))
	guiSetVisible(mReport.gui.attachBtn, screenshotsLimit > 0)

	guiCenter(mReport.gui.window)
	guiSetVisible(mReport.gui.window, true, true)
	showCursor(true)

	return true
end

function mReport.gui.hide()

	guiSetVisible(mReport.gui.Attach.window, false)
	guiSetVisible(mReport.gui.window, false)
	showCursor(false)

	return true
end

function mReport.gui.onClickAttach()
	
	local data = {}
	for i, id in ipairs(mScreenshotSaver.getValidIDs(SHOW_SCREENSHOTS_LIMIT)) do
		data[i] = {
			path = mScreenshotSaver.getPath(id),
			data = id,
			selected = table.index(mReport.attached, id) and true or false
		}
	end

	local selected = guiShowImageDialog("Attach screenshots", data, mReport.getScreenshotsLimit(), true)
	if not selected then return false end

	mReport.attached = {}
	for i, itemData in ipairs(selected) do
		table.insert(mReport.attached, itemData.data)
	end
	guiSetText(mReport.gui.attachBtn, #mReport.attached > 0 and "Attached screenshots("..#mReport.attached..")..." or "Attach screenshots...")

end

function mReport.gui.onClickSend()
	
	local message = utf8.trim(guiGetText(mReport.gui.messageMemo))
	if utf8.len(message) < MESSAGE_MIN_LENGTH then return guiShowMessageDialog("Message too short. Minimum is "..MESSAGE_MIN_LENGTH.." symbols", nil, MD_OK, MD_ERROR) end
	if utf8.len(message) > MESSAGE_MAX_LENGTH then return guiShowMessageDialog("Message too long. Maximum is "..MESSAGE_MAX_LENGTH.." symbols", nil, MD_OK, MD_ERROR) end

	mReport.gui.hide()
	mReport.send(message, mReport.attached)
	
	guiShowMessageDialog("Your message has been submited and will be processed as soon as possible", "Report", MD_OK, MD_INFO)
	
end