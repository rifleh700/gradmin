
local DROPDOWN_IMG_PATH = GUI_IMAGES_PATH.."/elements/dropdown.png"

local ButtonComboBox = {}

function ButtonComboBox.createButton(button)
	
	local height = guiGetHeight(button, false)
	local specialButton = guiCreateButton(0, 0, height, height, "", false, button)
	guiSetHeight(specialButton, 1, true)
	guiSetHorizontalAlign(specialButton, "right")
	guiSetVerticalAlign(specialButton, "center")

	return specialButton
end

function ButtonComboBox.onListItemSelected(row)

	local itemText = row > -1 and guiGridListGetItemText(this, row) or NIL_TEXT
	local button = getElementParent(this)
	guiSetText(button, guiGetInternalData(button, "combobox.prefix")..itemText)

end

function ButtonComboBox.onListAccept()

	guiSetVisible(this, false)

end

function ButtonComboBox.onButtonBlur()
	
	guiSetVisible(guiGetInternalData(this, "combobox.list"), false)

end

function ButtonComboBox.onListButtonClick(key)
	if key ~= "left" then return end

	local button = getElementParent(this)
	local list = guiGetInternalData(button, "combobox.list")
	if guiGetVisible(list) then return guiSetVisible(list, false) end
	if not guiGetEnabled(button) then return end

	guiSetVisible(list, true, true)

end

function guiButtonAddComboBox(button)
	if not scheck("u:element:gui-button") then return false end
	if guiGetInternalData(button, "combobox.list") then return false end

	local listButton = ButtonComboBox.createButton(button)
	guiButtonSetIcon(listButton, DROPDOWN_IMG_PATH)

	local list = guiCreateGridList(0, 1, 1, 0, true, button)
	guiSetRawYPosition(list, 1, false) -- offset 1px

	guiSetProperty(list, "ClippedByParent", "False")
	guiGridListAdjustHeight(list, 0)
	guiGridListSetSortingEnabled(list, false)
	guiGridListAddColumn(list, "", 1)
	guiGridListAdjustColumnWidth(list)
	guiSetVisible(list, false)

	local text = utf8.trim(guiGetText(button))
	guiSetInternalData(button, "combobox.prefix", text ~= "" and text..": " or "")
	guiSetInternalData(button, "combobox.button", listButton)
	guiSetInternalData(button, "combobox.list", list)

	addEventHandler("onClientGUIGridListItemSelected", list, ButtonComboBox.onListItemSelected, false)
	addEventHandler("onClientGUIDoubleLeftClick", list, ButtonComboBox.onListAccept, false)
	addEventHandler("onClientGUIGridListItemEnterKey", list, ButtonComboBox.onListAccept, false)
	addEventHandler("onClientGUIBlur", button, ButtonComboBox.onButtonBlur, false)
	addEventHandler("onClientGUIClick", listButton, ButtonComboBox.onListButtonClick, false)

	return list
end