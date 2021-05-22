
mPenaltyLogs = {}

function mPenaltyLogs.init()

	mPenaltyLogs.logs = {}
	mPenaltyLogs.filter = nil
	mPenaltyLogs.full = false

	cSync.addHandler("PenaltyLogs.next", mPenaltyLogs.sync.next)

	mPenaltyLogs.gui.init()

	return true
end

function mPenaltyLogs.term()

	cSync.removeHandler("PenaltyLogs.next", mPenaltyLogs.sync.next)
	
	mPenaltyLogs.gui.term()

	return true
end

cModules.register(mPenaltyLogs, "general.penaltylogs")

function mPenaltyLogs.request(filter)
	if not cSync.request("PenaltyLogs.next", filter, nil) then return false end

	mPenaltyLogs.logs = {}
	mPenaltyLogs.filter = filter
	mPenaltyLogs.full = false
	mPenaltyLogs.gui.refresh()
	
	return true
end

function mPenaltyLogs.requestNext()
	if mPenaltyLogs.full then return false end

	local lastID = mPenaltyLogs.logs[#mPenaltyLogs.logs].id
	if not cSync.request("PenaltyLogs.next", mPenaltyLogs.filter, lastID) then return false end
	
	return true
end

mPenaltyLogs.sync = {}

function mPenaltyLogs.sync.next(filter, lastID, logs)
	if not table.equal(filter, mPenaltyLogs.filter) then return end

	local size = #mPenaltyLogs.logs
	if size > 0 and mPenaltyLogs.logs[size].id ~= lastID then return end

	if #logs == 0 then
		mPenaltyLogs.full = true
		return
	end

	for i, data in ipairs(logs) do
		mPenaltyLogs.logs[size + i] = data
	end
	mPenaltyLogs.gui.refresh()

end