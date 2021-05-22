
local EditMatcher = {}

function EditMatcher.onChanged()
	
	local matcher = guiGetInternalData(this, "matcher")
	if not matcher then return end

	guiSetText(this, matcher(guiGetText(this)) or "")

end

function EditMatcher.onBlur()
	
	local matcher = guiGetInternalData(this, "matcher")
	if not matcher then return end

	guiSetText(this, matcher(guiGetText(this), true) or "")

end

local _guiCreateEdit = guiCreateEdit
function guiCreateEdit(x, y, w, h, text, relative, parent)
	if not scheck("n[4],s,b,?u:element:gui") then return false end

	local edit = _guiCreateEdit(x, y, w, h, text, relative, parent)
	if not edit then return edit end

	addEventHandler("onClientGUIChanged", edit, EditMatcher.onChanged, false, "high")
	addEventHandler("onClientGUIBlur", edit, EditMatcher.onBlur, false, "high+1")
	
	return edit
end

function guiEditSetMatcher(edit, matcher)
	if not scheck("u:element:gui-edit,?f") then return false end

	return guiSetInternalData(edit, "matcher", matcher)
end

function guiEditGetMatcher(edit)
	if not scheck("u:element:gui-edit") then return false end

	return guiGetInternalData(edit, "matcher")
end