
mBans = {}

function mBans.init()

	mBans.bans = {}
	mBans.filter = nil
	mBans.full = false

	cSync.addHandler("Bans.next", mBans.sync.next)
	cSync.addHandler("Bans.change", mBans.sync.change)
	cSync.addHandler("Bans.ban", mBans.sync.ban)
	cSync.addHandler("Bans.unban", mBans.sync.unban)

	mBans.gui.init()

	return true
end

function mBans.term()

	cSync.removeHandler("Bans.next", mBans.sync.next)
	cSync.removeHandler("Bans.change", mBans.sync.change)
	cSync.removeHandler("Bans.ban", mBans.sync.ban)
	cSync.removeHandler("Bans.unban", mBans.sync.unban)

	mBans.gui.term()

	return true
end

cModules.register(mBans, "general.bans")

function mBans.getData(id)
	
	for i, data in ipairs(mBans.bans) do
		if data.id == id then return data end
	end
	return nil
end

function mBans.request(filter)
	if not cSync.request("Bans.next", filter, nil) then return false end

	mBans.bans = {}
	mBans.filter = filter
	mBans.full = false
	mBans.gui.refresh()
	
	return true
end

function mBans.requestNext()
	if mBans.full then return false end
	if not cSync.request("Bans.next", mBans.filter, mBans.bans[#mBans.bans].id) then return false end

	return true
end

mBans.sync = {}

function mBans.sync.next(filter, lastID, bans)
	if not table.equal(filter, mBans.filter) then return end

	local size = #mBans.bans
	if size > 0 and mBans.bans[size].id ~= lastID then return end

	if #bans == 0 then
		mBans.full = true
		return
	end

	for i, data in ipairs(bans) do
		mBans.bans[size + i] = data
	end
	mBans.gui.refresh()

end

function mBans.sync.filter(data)

	local filter = mBans.filter
	if not filter then return true end

	if filter.since and data.time < filter.since then return false end
	if filter.before and data.time > filter.before then return false end
	if filter.serial and not utf8.find(data.serial, filter.serial, nil, true, true) then return false end
	if filter.admin and (not data.admin or (not utf8.find(stripColorCodes(data.admin), filter.admin, nil, true, true))) then return false end
	if filter.reason and (not data.reason or (not utf8.find(data.reason, filter.reason, nil, true, true))) then return false end
	if filter.nick and (not data.nick or (not utf8.find(stripColorCodes(data.nick), filter.nick, nil, true, true))) then return false end

	return true
end

function mBans.sync.change(data)

	for i, d in ipairs(mBans.bans) do
		if d.id == data.id then
			mBans.bans[i] = data
			mBans.gui.refresh()
			break
		end
	end
	
end

function mBans.sync.ban(data)
	if not mBans.sync.filter(data) then return end

	table.insert(mBans.bans, data)
	mBans.gui.refresh()

end

function mBans.sync.unban(id)

	for i, data in ipairs(mBans.bans) do
		if data.id == id then
			table.remove(mBans.bans, i)
			mBans.gui.refresh()
			break
		end
	end
	
end