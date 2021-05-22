
mConnectionLogs = {}

function mConnectionLogs.init()

	mConnectionLogs.logs = {}
	mConnectionLogs.filter = nil
	mConnectionLogs.full = false

	cSync.addHandler("ConnectionLogs.next", mConnectionLogs.sync.next)

	mConnectionLogs.gui.init()

	return true
end

function mConnectionLogs.term()

	cSync.removeHandler("ConnectionLogs.next", mConnectionLogs.sync.next)
	
	mConnectionLogs.gui.term()

	return true
end

cModules.register(mConnectionLogs, "general.connectionlogs")

function mConnectionLogs.request(filter)
	if not cSync.request("ConnectionLogs.next", filter, nil) then return false end

	mConnectionLogs.logs = {}
	mConnectionLogs.filter = filter
	mConnectionLogs.full = false
	mConnectionLogs.gui.refresh()
	
	return true
end

function mConnectionLogs.requestNext()
	if mConnectionLogs.full then return false end

	local lastID = mConnectionLogs.logs[#mConnectionLogs.logs].id
	if not cSync.request("ConnectionLogs.next", mConnectionLogs.filter, lastID) then return false end
	
	return true
end

mConnectionLogs.sync = {}

function mConnectionLogs.sync.next(filter, lastID, logs)
	if not table.equal(filter, mConnectionLogs.filter) then return end

	local size = #mConnectionLogs.logs
	if size > 0 and mConnectionLogs.logs[size].id ~= lastID then return end

	if #logs == 0 then
		mConnectionLogs.full = true
		return
	end

	for i, data in ipairs(logs) do
		mConnectionLogs.logs[size + i] = data
	end
	mConnectionLogs.gui.refresh()

end