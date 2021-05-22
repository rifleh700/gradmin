
mStaffLogs = {}

function mStaffLogs.init()

	mStaffLogs.logs = {}
	mStaffLogs.filter = nil
	mStaffLogs.full = false

	cSync.addHandler("StaffLogs.next", mStaffLogs.sync.next)

	mStaffLogs.gui.init()

	return true
end

function mStaffLogs.term()

	cSync.removeHandler("StaffLogs.next", mStaffLogs.sync.next)
	
	mStaffLogs.gui.term()

	return true
end

cModules.register(mStaffLogs, "general.stafflogs")

function mStaffLogs.request(filter)
	if not cSync.request("StaffLogs.next", filter, nil) then return false end

	mStaffLogs.logs = {}
	mStaffLogs.filter = filter
	mStaffLogs.full = false
	mStaffLogs.gui.refresh()
	
	return true
end

function mStaffLogs.requestNext()
	if mStaffLogs.full then return false end

	local lastID = mStaffLogs.logs[#mStaffLogs.logs].id
	if not cSync.request("StaffLogs.next", mStaffLogs.filter, lastID) then return false end
	
	return true
end

mStaffLogs.sync = {}

function mStaffLogs.sync.next(filter, lastID, logs)
	if not table.equal(filter, mStaffLogs.filter) then return end

	local size = #mStaffLogs.logs
	if size > 0 and mStaffLogs.logs[size].id ~= lastID then return end

	if #logs == 0 then
		mStaffLogs.full = true
		return
	end

	for i, data in ipairs(logs) do
		mStaffLogs.logs[size + i] = data
	end
	mStaffLogs.gui.refresh()

end