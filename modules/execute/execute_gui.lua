
local CODE_FONT_PATH = GUI_FONTS_PATH.."DejaVuSansMono-Bold.ttf"
local CODE_FONT_SIZE = 11
local TAB_STRING = "    "
local NEW_NAME = "[new]"

local gs = {}
gs.memo = {}
gs.memo.font = guiCreateFont(CODE_FONT_PATH, CODE_FONT_SIZE)

mExecute.gui = {}

mExecute.gui.changed = false
mExecute.gui.current = nil

function mExecute.gui.init()

	local group = cGUI.getTabGroup("dev", "Dev")
	local tab = guiCreateTab("Execute", group)
	mExecute.gui.tab = tab

	local mainHlo = guiCreateHorizontalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, nil, false, tab)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetSizeFixed(mainHlo, true)
	guiHorizontalLayoutSetVerticalAlign(mainHlo, "bottom")
	
	local vlo = guiCreateVerticalLayout(nil, nil, 1, 1, nil, true, mainHlo)
	guiSetTableProperty(vlo, "UnifiedWidth", {1, -GS.w2 - GS.mrg})
	guiVerticalLayoutSetSizeFixed(vlo, true)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")

	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mExecute.gui.nameLbl = guiCreateLabel(nil, nil, GS.w21 - GS.mrg2*2, nil, NEW_NAME, false, hlo)
	mExecute.gui.newBtn = guiCreateButton(nil, nil, GS.w, nil, "New", nil, hlo)
	mExecute.gui.openBtn = guiCreateButton(nil, nil, GS.w3, nil, "Open", false, hlo)
	mExecute.gui.openList = guiButtonAddComboBox(mExecute.gui.openBtn)
	guiGridListAdjustHeight(mExecute.gui.openList, 15)
	mExecute.gui.saveBtn = guiCreateButton(nil, nil, nil, nil, "Save", nil, hlo)
	mExecute.gui.saveAsBtn = guiCreateButton(nil, nil, nil, nil, "Save as...", nil, hlo)
	mExecute.gui.deleteBtn = guiCreateButton(nil, nil, nil, nil, "Delete", nil, hlo)

	mExecute.gui.memo = guiCreateMemo(nil, nil, 1, 1, "", true, vlo)
	guiSetTableProperty(mExecute.gui.memo, "UnifiedHeight", {1, -GS.h - GS.mrg})
	guiSetFont(mExecute.gui.memo, gs.memo.font)
	guiMemoSetWordWrap(mExecute.gui.memo, false)

	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, true, mainHlo)
	mExecute.gui.cexecuteBtn = guiCreateButton(nil, nil, nil, nil, "Execute (c)", nil, vlo, "command.cexecute")
	guiButtonSetHoverTextColor(mExecute.gui.cexecuteBtn, table.unpack(GS.clr.aqua))
	mExecute.gui.executeBtn = guiCreateButton(nil, nil, nil, nil, "Execute (s)", nil, vlo, "command.execute")
	guiButtonSetHoverTextColor(mExecute.gui.executeBtn, table.unpack(GS.clr.aqua))

	mExecute.gui.refreshScriptsList()
	mExecute.gui.setCurrent()

	guiRebuildLayouts(tab)

	---------------------------------------

	addEventHandler("onClientKey", root, mExecute.gui.onKey)

	addEventHandler("onClientGUILeftClick", tab, mExecute.gui.onClick)
	addEventHandler("onClientGUIChanged", mExecute.gui.memo, mExecute.gui.onChanged, false)

	return true
end

function mExecute.gui.term()

	removeEventHandler("onClientKey", root, mExecute.gui.onKey)
	destroyElement(mExecute.gui.tab)

	return true
end

function mExecute.gui.onKey(key, press)
	if key ~= "tab" then return end
	if not press then return end
	if sourceGUIInput ~= mExecute.gui.memo then return end

	local text = guiGetText(mExecute.gui.memo)
	local caret = guiMemoGetCaretIndex(mExecute.gui.memo)
	guiSetText(mExecute.gui.memo, utf8.insert(text, TAB_STRING, caret + 1))
	guiMemoSetCaretIndex(mExecute.gui.memo, caret + #TAB_STRING)

end

function mExecute.gui.onClick()
	
	if source == mExecute.gui.executeBtn then
		return cCommands.execute("execute", guiGetText(mExecute.gui.memo))

	elseif source == mExecute.gui.cexecuteBtn then
		return mExecute.execute(guiGetText(mExecute.gui.memo))

	elseif source == mExecute.gui.newBtn then
		if mExecute.gui.changed then
			if not guiShowMessageDialog("Current script has been modified. All changes will be lost. Are you sure?", "New script", MD_YES_NO, MD_QUESTION) then return end
		end
		guiSetText(mExecute.gui.memo, "")
		mExecute.gui.setCurrent()

	elseif source == mExecute.gui.openBtn then
		if mExecute.gui.changed then
			if not guiShowMessageDialog("Current script has been modified. All changes will be lost. Are you sure?", "New script", MD_YES_NO, MD_QUESTION) then return end
		end
		
		local name = guiGridListGetSelectedItemText(mExecute.gui.openList)
		if not name then return guiShowMessageDialog("Invalid script name", nil, MD_OK, MD_ERROR) end

		local data = mExecute.loadScript(name)
		if not data then return guiShowMessageDialog("Failed to load '"..name.."' script", nil, MD_OK, MD_ERROR) end

		guiSetText(mExecute.gui.memo, data)
		mExecute.gui.setCurrent(name)

	elseif source == mExecute.gui.saveBtn then
		if not mExecute.gui.changed then return end

		local name = mExecute.gui.current
		if not name then return guiClick(mExecute.gui.saveAsBtn) end

		if not mExecute.saveScript(name, guiGetText(mExecute.gui.memo)) then
			return guiShowMessageDialog("Saving error", nil, MD_OK, MD_ERROR)
		end
		mExecute.gui.setCurrent(name)

	elseif source == mExecute.gui.saveAsBtn then
		local name = guiShowInputDialog("Save script as", "Enter the new script name", mExecute.gui.current, guiGetInputNotEmptyParser())
		if not name then return end

		if not mExecute.saveScript(name, guiGetText(mExecute.gui.memo)) then
			return guiShowMessageDialog("Saving error", nil, MD_OK, MD_ERROR)
		end
		mExecute.gui.refreshScriptsList()
		mExecute.gui.setCurrent(name)

		guiShowMessageDialog("Script saved as '"..name.."'", nil, MD_OK, MD_INFO)

	elseif source == mExecute.gui.deleteBtn then
		local name = mExecute.gui.current
		if not name then return end

		if not guiShowMessageDialog("Script '"..name.."' will be deleted. Are you sure?", "Delete script", MD_YES_NO, MD_QUESTION) then return end

		if not mExecute.deleteScript(name) then
			return guiShowMessageDialog("Deleting error", nil, MD_OK, MD_ERROR)
		end

		guiSetText(mExecute.gui.memo, "")
		mExecute.gui.refreshScriptsList()
		mExecute.gui.setCurrent()

	end

end

function mExecute.gui.onChanged()
	if mExecute.gui.changed then return end

	mExecute.gui.changed = true
	guiSetEnabled(mExecute.gui.saveBtn, true)
	guiLabelSetColor(mExecute.gui.nameLbl, table.unpack(GS.clr.yellow))

end

function mExecute.gui.refreshScriptsList()
	
	local selected = guiGridListGetSelectedItem(mExecute.gui.openList)
	guiGridListClear(mExecute.gui.openList)
	for i, name in ipairs(mExecute.getScriptsList()) do
		guiGridListAddRow(mExecute.gui.openList, name)
	end
	guiGridListSetSelectedAnyItem(mExecute.gui.openList, selected)
	guiSetEnabled(mExecute.gui.openBtn, guiGridListGetRowCount(mExecute.gui.openList) > 0)

	return true
end

function mExecute.gui.setCurrent(current)
	
	guiSetText(mExecute.gui.nameLbl, current or NEW_NAME)
	guiLabelSetColor(mExecute.gui.nameLbl, table.unpack(GS.clr.white))
	guiSetEnabled(mExecute.gui.saveBtn, false)
	guiSetEnabled(mExecute.gui.deleteBtn, current and true or false)

	mExecute.gui.current = current
	mExecute.gui.changed = false

end