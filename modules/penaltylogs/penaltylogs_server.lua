
local mPenaltyLogs = {}

function mPenaltyLogs.init()

	cSync.register("PenaltyLogs.next", "general.penalties", {heavy = true})
	
	cSync.registerResponder("PenaltyLogs.next", mPenaltyLogs.sync.next)

	return true
end

cModules.register(mPenaltyLogs)

mPenaltyLogs.sync = {}

function mPenaltyLogs.sync.next(filter, lastID)

	return cPenaltyLogs.find(filter, lastID)
end