
addEvent("gra.cGUI.onRefresh", false)
addEvent("gra.cGUI.onSwitch", false)
addEvent("gra.cGUI.messageDialog", true)

local HEADER = "gradmin "..VERSION
local REFRESH_INTERVAL_TICKS = 500
local SHOW_INFO_INTERVAL = 5 * 10^3
local DATE_FORMAT = "%d/%m/%Y %A %X"

local gs = {}
gs.w = 760
gs.h = 600
gs.bar = {}
gs.bar.h = 20

local gui = {}
local refreshTicks = getTickCount()

local function onRender()
	if getTickCount() < refreshTicks then return end

	triggerEvent("gra.cGUI.onRefresh", this)
	refreshTicks = getTickCount() + REFRESH_INTERVAL_TICKS

end

local function onRefresh()

	guiSetText(gui.timeLbl, os.date(DATE_FORMAT, cTime.get()))

end

local function onSettingClick()

	cSettings.set("silent", guiCheckBoxGetSelected(gui.silentChk))
	cSettings.set("anonymous", guiCheckBoxGetSelected(gui.anonChk))

end

cGUI = {}

function cGUI.init()
	
	gui.window = guiCreateWindow(0, 0, gs.w, gs.h, HEADER, false)
	
	gui.tpnl = guiCreateTabPanel(GS.mrg2, 20 + GS.mrg, gs.w - GS.mrg2*2, gs.h - 20 - gs.bar.h - GS.mrg*2 - GS.mrg2, false, gui.window)
	gui.groups = {}

	gui.bar = guiCreateContainer(GS.mrg2*2, gs.h - GS.mrg2 - gs.bar.h, gs.w - GS.mrg2*4, gs.bar.h, false, gui.window)
	
	gui.infoLbl = guiCreateLabel(0, 0, 0.5, 1, "", true, gui.bar)
	guiLabelSetVerticalAlign(gui.infoLbl, "center")
	guiSetEnabled(gui.infoLbl, false)
	guiLabelSetColor(gui.infoLbl, unpack(GS.clr.yellow))

	gui.settingsHlo = guiCreateHorizontalLayout(0.5, 0, 0.2, 1, nil, true, gui.bar)
	guiHorizontalLayoutSetVerticalAlign(gui.settingsHlo, "center")
	guiHorizontalLayoutSetSizeFixed(gui.settingsHlo, true)
	gui.silentChk = guiCreateCheckBox(nil, nil, nil, nil, "Silent", cSettings.get("silent") == true, nil, gui.settingsHlo)
	guiSetToolTip(gui.silentChk, "Silent mode disables global messages for commands that you execute")
	guiCheckBoxAdjustWidth(gui.silentChk)
	gui.anonChk = guiCreateCheckBox(nil, nil, nil, nil, "Anonymous", cSettings.get("anonymous") == true, nil, gui.settingsHlo)
	guiSetToolTip(gui.anonChk, "Anonymous mode hides your name for commands that you execute")
	guiCheckBoxAdjustWidth(gui.silentChk)
	
	gui.timeLbl = guiCreateLabel(0.7, 0, 0.3, 1, "", true, gui.bar)
	guiSetEnabled(gui.timeLbl, false)
	guiLabelSetColor(gui.timeLbl, table.unpack(GS.clr.white))
	guiLabelSetVerticalAlign(gui.timeLbl, "center")
	guiLabelSetHorizontalAlign(gui.timeLbl, "right")

	guiRebuildLayouts(gui.window)
	
	--------------------------------------------

	addEventHandler("onClientGUIRender", gui.window, onRender, false)

	addEventHandler("gra.cGUI.messageDialog", localPlayer, guiShowMessageDialog)
	addEventHandler("gra.cGUI.onRefresh", gui.window, onRefresh, false)

	addEventHandler("onClientGUIClick", gui.settingsHlo, onSettingClick)

	return true
end

function cGUI.term()

	cGUI.hide()

	removeEventHandler("gra.cGUI.messageDialog", localPlayer, guiShowMessageDialog)
	removeEventHandler("onClientGUIClick", gui.settingsHlo, onSettingClick)

	destroyElement(gui.window)

	return true
end

function cGUI.show()
	if guiGetVisible(gui.window) then return false end

	guiSetVisible(gui.window, true, true)
	showCursor(true)
	triggerEvent("gra.cGUI.onSwitch", gui.window, true)

	return true
end

function cGUI.hide()
	if not guiGetVisible(gui.window) then return false end

	for i, element in ipairs(getElementChildren(guiRoot)) do
		if not guiGetData(element, "steady") then guiSetVisible(element, false) end
	end
	showCursor(false)
	triggerEvent("gra.cGUI.onSwitch", gui.window, false)

	return true
end

function cGUI.switch()
	
	return guiGetVisible(gui.window) and cGUI.hide() or cGUI.show()
end

function cGUI.setSteady(element, state)
	if not scheck("u:element:gui,b") then return false end
	if getElementParent(element) ~= guiRoot then return warn("element can not be steady", 2) and false end

	return guiSetData(element, "steady", state or nil)
end

function cGUI.getVisible()
	if not gui.window then return false end

	return guiGetVisible(gui.window)
end

function cGUI.addTab(name)
	if not gui.window then return false end

	return guiCreateTab(name, gui.tpnl)
end

function cGUI.getTabGroup(group, name)
	if not gui.window then return false end

	if gui.groups[group] then return guiGetData(gui.groups[group], "panel") end

	local tab = guiCreateTab(name, gui.tpnl)
	local panel = guiCreateTabPanel(0, 0, 1, 1, true, tab)
	guiSetRawPosition(panel, GS.mrg2, GS.mrg2, false)
	guiSetRawSize(panel, -GS.mrg2*2, -GS.mrg2*2, false)
	guiSetData(tab, "panel", panel)
	gui.groups[group] = tab

	return panel
end

function cGUI.setBarText(text)
	if not gui.window then return false end
	
	return guiSetTempText(gui.infoLbl, text or "", SHOW_INFO_INTERVAL)
end

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		showCursor(false)
	end
)

addEventHandler("onClientMouseEnter", guiRoot,
	function()
		if getElementType(source) ~= "gui-label" then return end
		if not guiIsTextClipped(source) then return end

		cGUI.setBarText(guiGetText(source))
	end
)

addEventHandler("onClientMouseLeave", guiRoot,
	function()
		if getElementType(source) ~= "gui-label" then return end
		if guiGetText(source) ~= guiGetText(gui.infoLbl) then return end

		cGUI.setBarText()
	end
)

addEventHandler("onClientGUIDoubleClick", guiRoot,
	function()
		if getElementType(source) ~= "gui-label" then return end
		
		local text = guiGetText(source)
		if text == "" then return end

		setClipboard(text)
		cGUI.setBarText("Text has been copied to the clipboard")
	end
)