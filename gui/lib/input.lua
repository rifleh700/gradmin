
guiSetInputMode("no_binds_when_editing")

sourceGUIInput = nil

local Focus = {}

function Focus.onFocus()

	sourceGUIInput = source

end

function Focus.onBlur()
	if sourceGUIInput ~= this then return end
	
	sourceGUIInput = nil

end

local _guiCreateEdit = guiCreateEdit
function guiCreateEdit(x, y, w, h, text, relative, parent)
	if not scheck("n[4],s,b,?u:element:gui") then return false end

	local edit = _guiCreateEdit(x, y, w, h, text, relative, parent)
	if not edit then return edit end

	addEventHandler("onClientGUIFocus", edit, Focus.onFocus, false)
	addEventHandler("onClientGUIBlur", edit, Focus.onBlur)
	
	return edit
end

local _guiCreateMemo = guiCreateMemo
function guiCreateMemo(x, y, w, h, text, relative, parent)
	if not scheck("n[4],s,b,?u:element:gui") then return false end

	local memo = _guiCreateMemo(x, y, w, h, text, relative, parent)
	if not memo then return memo end

	addEventHandler("onClientGUIFocus", memo, Focus.onFocus, false)
	addEventHandler("onClientGUIBlur", memo, Focus.onBlur)
	
	return memo
end

function guiGetFocusedInput()
	
	return sourceGUIInput
end