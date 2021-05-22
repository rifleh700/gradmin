
local DROPDOWN_IMG_PATH = GUI_IMAGES_PATH.."/elements/dropdown.png"

local EditComboBox = {}

function EditComboBox.createButton(edit)

	local height = guiGetHeight(edit, false)
	local button = guiCreateButton(0, 0, height, height, "", false, edit)
	guiSetHeight(button, 1, true)
	guiSetHorizontalAlign(button, "right")
	guiSetVerticalAlign(button, "center")
	guiSetInheritsAlpha(button, false)

	return button
end

function EditComboBox.onListItemSelected(row)
	
	local itemText = row > -1 and guiGridListGetItemText(this, row) or nil
	local edit = getElementParent(this)
	guiSetText(edit, itemText or "")

end

function EditComboBox.onListDoubleClick(key, state)
	if key ~= "left" then return end

	guiSetVisible(this, false)

end

function EditComboBox.onEditBlur()

	guiSetVisible(guiGetInternalData(this, "combobox.list"), false)

end

function EditComboBox.onListButtonClick(key, state)
	if key ~= "left" then return end
	
	local edit = getElementParent(this)
	local list = guiGetInternalData(edit, "combobox.list")
	if guiGetVisible(list) then return guiSetVisible(list, false) end
	if not guiGetEnabled(edit) then return end

	guiSetVisible(list, true, true)

end

addEventHandler("onClientKey", root,
	function(key, down)
		if key ~= "enter" then return end
		if not down then return end
		--for cbb, data in pairs(cbbsData) do
		--	if guiGetVisible(data.list) then
		--		guiBlur(cbb)
		--	end
		--end
	end
)

function guiEditAddComboBox(edit)
	if not scheck("u:element:gui-edit") then return false end
	if guiGetInternalData(edit, "combobox.list") then return false end

	local listButton = EditComboBox.createButton(edit)
	guiButtonSetIcon(listButton, DROPDOWN_IMG_PATH)

	local list = guiCreateGridList(0, 1, 1, 0, true, edit)
	guiSetRawYPosition(list, 1, false) -- offset 1px

	guiSetProperty(list, "ClippedByParent", "False")
	guiGridListAdjustHeight(list, 0)
	guiGridListSetSortingEnabled(list, false)
	guiGridListAddColumn(list, "", 1)
	guiGridListAdjustColumnWidth(list)
	guiSetVisible(list, false)

	guiSetInternalData(edit, "combobox.text", guiGetText(edit))
	guiSetInternalData(edit, "combobox.edit", listButton)
	guiSetInternalData(edit, "combobox.list", list)

	addEventHandler("onClientGUIGridListItemSelected", list, EditComboBox.onListItemSelected, false)
	addEventHandler("onClientGUIDoubleClick", list, EditComboBox.onListDoubleClick, false)
	addEventHandler("onClientGUIBlur", edit, EditComboBox.onEditBlur, false)
	addEventHandler("onClientGUIClick", listButton, EditComboBox.onListButtonClick, false)

	return list
end