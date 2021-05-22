
local mStaffLogs = {}

function mStaffLogs.init()

	cSync.register("StaffLogs.next", "general.penalties", {heavy = true})
	
	cSync.registerResponder("StaffLogs.next", mStaffLogs.sync.next)

	return true
end

cModules.register(mStaffLogs)

mStaffLogs.sync = {}

function mStaffLogs.sync.next(filter, lastID)

	return cCommands.findLogs(filter, lastID)
end