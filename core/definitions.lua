
VERSION = "0.1"

RESOURCE = getThisResource()
RESOURCE_NAME = getResourceName(RESOURCE)

GENERAL_PERMISSION = "general.adminpanel"
SWITCH_COMMAND = "gradmin"

DATA_PATH = "@data/"

NIL_TEXT = "[none]"

local _iprint = iprint
function iprint(...)
	return _iprint("tick:"..getTickCount(), tostring(coroutine.running()), ...)
end