
addEventHandler("onClientKey", root,
	function(key, press)
		if key ~= "tab" then return end
		if not press then return end
		if not sourceGUIInput then return end
		if getElementType(sourceGUIInput) ~= "gui-edit" then return end
		
		guiBlur(sourceGUIInput)
	end
)

local _guiCreateEdit = guiCreateEdit
function guiCreateEdit(x, y, w, h, text, relative, parent)
	if not scheck("n[4],s,b,?u:element:gui") then return false end

	local edit = _guiCreateEdit(x, y, w, h, text, relative, parent)
	if not edit then return edit end

	addEventHandler("onClientGUIAccepted", edit, function() guiBlur(edit) end, true, "high") -- or false?
	
	return edit
end

local _guiEditSetCaretIndex = guiEditSetCaretIndex
function guiEditSetCaretIndex(edit, index)
	if not scheck("u:element:gui-edit,?n") then return false end

	return _guiEditSetCaretIndex(edit, index or #(guiGetText(edit)))
end

function guiEditSetValidationString(edit, str)
	if not scheck("u:element:gui-edit,s") then return false end

	return guiSetProperty(edit, "ValidationString", str)
end

function guiEditSetReadOnlyBackGroundColor(edit, r, g, b, a)
	if not scheck("u:element:gui-edit,n[3],?n") then return false end

	guiSetColorProperty(edit, "ReadOnlyBGColour", r, g, b, a)
	
	-- NEEDED (CEGUI bug maybe)
	if guiEditIsReadOnly(edit) then guiBlur(edit) end

	return true
end

