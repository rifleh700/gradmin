
mMutes = {}

function mMutes.init()

	mMutes.mutes = {}
	mMutes.filter = nil
	mMutes.full = false

	cSync.addHandler("Mutes.next", mMutes.sync.next)
	cSync.addHandler("Mutes.change", mMutes.sync.change)
	cSync.addHandler("Mutes.mute", mMutes.sync.mute)
	cSync.addHandler("Mutes.unmute", mMutes.sync.unmute)

	mMutes.gui.init()

	return true
end

function mMutes.term()

	cSync.removeHandler("Mutes.next", mMutes.sync.next)
	cSync.removeHandler("Mutes.change", mMutes.sync.change)
	cSync.removeHandler("Mutes.mute", mMutes.sync.mute)
	cSync.removeHandler("Mutes.unmute", mMutes.sync.unmute)

	mMutes.gui.term()

	return true
end

cModules.register(mMutes, "general.mutes")

function mMutes.getData(id)
	
	for i, data in ipairs(mMutes.mutes) do
		if data.id == id then return data end
	end
	return nil
end

function mMutes.request(filter)
	if not cSync.request("Mutes.next", filter, nil) then return false end

	mMutes.mutes = {}
	mMutes.filter = filter
	mMutes.full = false
	mMutes.gui.refresh()
	
	return true
end

function mMutes.requestNext()
	if mMutes.full then return false end
	if not cSync.request("Mutes.next", mMutes.filter, mMutes.mutes[#mMutes.mutes].id) then return false end

	return true
end

mMutes.sync = {}

function mMutes.sync.next(filter, lastID, mutes)
	if not table.equal(filter, mMutes.filter) then return end

	local size = #mMutes.mutes
	if size > 0 and mMutes.mutes[size].id ~= lastID then return end

	if #mutes == 0 then
		mMutes.full = true
		return
	end

	for i, data in ipairs(mutes) do
		mMutes.mutes[size + i] = data
	end
	mMutes.gui.refresh()

end

function mMutes.sync.filter(data)

	local filter = mMutes.filter
	if not filter then return true end

	if filter.since and data.time < filter.since then return false end
	if filter.before and data.time > filter.before then return false end
	if filter.serial and not utf8.find(data.serial, filter.serial, nil, true, true) then return false end
	if filter.admin and (not data.admin or (not utf8.find(stripColorCodes(data.admin), filter.admin, nil, true, true))) then return false end
	if filter.reason and (not data.reason or (not utf8.find(data.reason, filter.reason, nil, true, true))) then return false end
	if filter.nick and (not data.nick or (not utf8.find(stripColorCodes(data.nick), filter.nick, nil, true, true))) then return false end

	return true
end

function mMutes.sync.change(data)

	for i, d in ipairs(mMutes.mutes) do
		if d.id == data.id then
			mMutes.mutes[i] = data
			mMutes.gui.refresh()
			break
		end
	end
	
end

function mMutes.sync.mute(data)
	if not mMutes.sync.filter(data) then return end

	table.insert(mMutes.mutes, data)
	mMutes.gui.refresh()

end

function mMutes.sync.unmute(id)

	for i, data in ipairs(mMutes.mutes) do
		if data.id == id then
			table.remove(mMutes.mutes, i)
			mMutes.gui.refresh()
			break
		end
	end
	
end