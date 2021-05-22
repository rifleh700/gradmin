
addEvent("gra.cSession.onUpdate", false)
addEvent("gra.cSession.update", true)

local permissions = {}

cSession = {}

addEventHandler("gra.cSession.update", localPlayer,
	function(newPermissions)

		local wasadmin = permissions[GENERAL_PERMISSION]
		local nowadmin = newPermissions[GENERAL_PERMISSION]
		permissions = newPermissions

		triggerEvent("gra.cSession.onUpdate", localPlayer, wasadmin, nowadmin)

	end
)

function cSession.hasPermissionTo(right)
	if not scheck("s") then return false end

	return permissions[right] == true
end