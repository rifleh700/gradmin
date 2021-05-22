
function guiComboBoxAdjustHeight(comboBox, itemCount)
	if not scheck("u:element:gui-combobox,?n") then return false end

	if not itemCount then itemCount = 1 end
	local width = guiGetSize(comboBox, false)

	return guiSetSize(comboBox, width, itemCount * 14 + 38, false)
end