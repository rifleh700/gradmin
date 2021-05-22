
cGuiGuard = {}

local elementsPermissions = {}

addEventHandler("onClientElementDestroy", guiRoot,
	function()
		elementsPermissions[source] = nil
	end
)

function cGuiGuard.setPermission(element, permission)
	check("u:element:gui,s")
	if elementsPermissions[element] then return warn("permission is already set", 2) and false end

	elementsPermissions[element] = permission
	if not cSession.hasPermissionTo(permission) then
		_guiSetEnabled(element, false)
	end

	return true
end

local _guiSetEnabled = guiSetEnabled
function guiSetEnabled(element, enabled)
	if not scheck("u:element:gui,b") then return false end

	if not elementsPermissions[element] then return _guiSetEnabled(element, enabled) end

	enabled = enabled and cSession.hasPermissionTo(elementsPermissions[element])
	return _guiSetEnabled(element, enabled)
end

local _guiCreateButton = guiCreateButton
function guiCreateButton(x, y, w, h, text, relative, parent, permission)
	local button = _guiCreateButton(x, y, w, h, text, relative, parent)
	if not button then return false end
	
	if permission then cGuiGuard.setPermission(button, permission) end

	return button
end

local _guiCreateEdit = guiCreateEdit
function guiCreateEdit(x, y, w, h, text, relative, parent, permission)
	local edit = _guiCreateEdit(x, y, w, h, text, relative, parent)
	if not edit then return false end
	
	if permission then cGuiGuard.setPermission(edit, permission) end

	return edit
end