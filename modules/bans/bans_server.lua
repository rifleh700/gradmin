
local FIND_BANS_LIMIT = 50

addEvent("gra.mBans.onUnbanTimeChange", false)
addEvent("gra.mBans.onNickChange", false)
addEvent("gra.mBans.onReasonChange", false)
addEvent("gra.mBans.onAdminChange", false)

mBans = {}

mBans.bans = {}

function mBans.init()

	mBans.bans = getBans()

	addEventHandler("onBan", root, mBans.onBan)
	addEventHandler("onUnban", root, mBans.onUnban)
	addEventHandler("gra.mBans.onUnbanTimeChange", root, mBans.onChange)
	addEventHandler("gra.mBans.onNickChange", root, mBans.onChange)
	addEventHandler("gra.mBans.onReasonChange", root, mBans.onChange)
	addEventHandler("gra.mBans.onAdminChange", root, mBans.onChange)

	cSync.register("Bans.next", "general.bans", {heavy = true})
	cSync.register("Bans.change", "general.bans")
	cSync.register("Bans.ban", "general.bans")
	cSync.register("Bans.unban", "general.bans")

	cSync.registerResponder("Bans.next", mBans.sync.next)

	return true
end

cModules.register(mBans)

function mBans.onBan(ban)

	table.insert(mBans.bans, ban)
	cSync.send(root, "Bans.ban", mBans.sync.getData(ban))

end

function mBans.onUnban(ban)

	table.removevalue(mBans.bans, ban)
	cSync.send(root, "Bans.unban", mBans.getID(ban))

end

function mBans.onChange(ban)

	cSync.send(root, "Bans.change", mBans.sync.getData(ban))

end

function mBans.getID(ban)

	return address(ban)
end

function mBans.getFromID(id)
	
	for i, ban in ipairs(mBans.bans) do
		if mBans.getID(ban) == id then return ban end
	end
	return nil
end

function mBans.getData(ban)
	
	data = {}
	data.nick = getBanNick(ban) or nil
	data.ip = getBanIP(ban) or nil
	data.serial = getBanSerial(ban) or nil
	data.admin = getBanAdmin(ban) or nil
	data.reason = getBanReason(ban) or nil
	data.time = getBanTime(ban) or nil
	data.unban = getUnbanTime(ban) or nil
	
	return data
end

mBans.sync = {}

function mBans.sync.getData(ban)

	local data = mBans.getData(ban)
	data.id = mBans.getID(ban)

	return data
end

function mBans.sync.filter(data, filter)
	if not filter then return true end

	if filter.since and data.time < filter.since then return false end
	if filter.before and data.time > filter.before then return false end
	if filter.serial and not utf8.find(data.serial, filter.serial, nil, true, true) then return false end
	if filter.admin and (not data.admin or (not utf8.find(stripColorCodes(data.admin), filter.admin, nil, true, true))) then return false end
	if filter.reason and (not data.reason or (not utf8.find(data.reason, filter.reason, nil, true, true))) then return false end
	if filter.nick and (not data.nick or (not utf8.find(stripColorCodes(data.nick), filter.nick, nil, true, true))) then return false end

	return true
end

function mBans.sync.next(filter, lastID)

	local list = {}
	local size = 0

	local found = not lastID and true
	for i, ban in ipairs(mBans.bans) do
		local id = mBans.getID(ban)
		if found then
			local data = mBans.getData(ban)
			if mBans.sync.filter(data, filter) then
				size = size + 1
				data.id = id
				list[size] = data
				if size == FIND_BANS_LIMIT then break end 
			end
		else
			if id == lastID then found = true end
		end
	end

	return list
end