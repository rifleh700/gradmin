
local GridListFocus = {}

GridListFocus.focused = nil

function GridListFocus.onFocus()

	GridListFocus.focused = this

end

function GridListFocus.onBlur()
	if this ~= GridListFocus.focused then return end
	if not guiIsGrandParentFor(source, this) then return end

	GridListFocus.focused = nil
	
end

function GridListFocus.onDestroy()
	if this ~= GridListFocus.focused then return end

	GridListFocus.focused = nil 

end

local _guiCreateGridList = guiCreateGridList
function guiCreateGridList(x, y, width, height, relative, parent)
	if not scheck("n[4],b,?u:element:gui") then return false end

	local list = _guiCreateGridList(x, y, width, height, relative, parent)
	addEventHandler("onClientGUIFocus", list, GridListFocus.onFocus, false)
	addEventHandler("onClientGUIBlur", list, GridListFocus.onBlur)
	addEventHandler("onClientElementDestroy", list, GridListFocus.onDestroy, false)

	return list
end

function guiGetFocusedGridList()

	return GridListFocus.focused
end