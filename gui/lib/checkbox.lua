
function guiCheckBoxAdjustWidth(checkbox)
	if not scheck("u:element:gui-checkbox") then return false end
	
	local width = guiGetTextExtent(checkbox)
	
	return guiSetWidth(checkbox, width + 18, false)
end