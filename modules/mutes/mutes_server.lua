
local FIND_MUTES_LIMIT = 40

local mMutes = {}

function mMutes.init()

	addEventHandler("onMute", root, mMutes.onMute)
	addEventHandler("onUnmute", root, mMutes.onUnmute)
	addEventHandler("gra.mMute.onAdminChange", root, mMutes.onChange)
	addEventHandler("gra.mMute.onNickChange", root, mMutes.onChange)
	addEventHandler("gra.mMute.onReasonChange", root, mMutes.onChange)
	addEventHandler("gra.mMute.onTimeChange", root, mMutes.onChange)
	addEventHandler("onPlayerJoin", root, mMutes.onJoin, true, "low")

	cSync.register("Mutes.next", "general.mutes", {heavy = true})
	cSync.register("Mutes.change", "general.mutes")
	cSync.register("Mutes.mute", "general.mutes")
	cSync.register("Mutes.unmute", "general.mutes")

	cSync.registerResponder("Mutes.next", mMutes.sync.next)

	return true
end

cModules.register(mMutes)

function mMutes.onMute(id)
	
	cSync.send(root, "Mutes.mute", mMutes.sync.getData(id))

end

function mMutes.onUnmute(id, expired)

	if expired then
		local player = getMutePlayer(id)
		if player then
			cMessages.outputPublic(getPlayerName(player).."'s mute has expired", root, COLORS.green)
			cMessages.outputPublic("Your mute has expired", player, COLORS.green)
		end
	end

	cSync.send(root, "Mutes.unmute", id)

end

function mMutes.onJoin()
	
	local id = getPlayerMute(source)
	if not id then return end

	local reason = getMuteReason(id)
	local reasonInfo = reason and string.format(" (%s)", reason) or ""
	cMessages.outputPublic(getPlayerName(source).." has been muted"..reasonInfo, root, COLORS.red)
	cMessages.outputPublic("You have been muted"..reasonInfo, source, COLORS.red)

end

function mMutes.onChange(id)

	cSync.send(root, "Mutes.change", mMutes.sync.getData(id))

end

mMutes.sync = {}

function mMutes.sync.getData(id)

	local data = getMuteData(id)
	data.id = id

	return data
end

function mMutes.sync.filter(data, filter)
	if not filter then return true end

	if filter.since and data.time < filter.since then return false end
	if filter.before and data.time > filter.before then return false end
	if filter.serial and not utf8.find(data.serial, filter.serial, nil, true, true) then return false end
	if filter.admin and (not data.admin or (not utf8.find(stripColorCodes(data.admin), filter.admin, nil, true, true))) then return false end
	if filter.reason and (not data.reason or (not utf8.find(data.reason, filter.reason, nil, true, true))) then return false end
	if filter.nick and (not data.nick or (not utf8.find(stripColorCodes(data.nick), filter.nick, nil, true, true))) then return false end

	return true
end

function mMutes.sync.next(filter, lastID)

	local list = {}
	local size = 0

	local found = not lastID and true
	for i, id in ipairs(getMutes()) do
		if found then
			local data = getMuteData(id)
			if mMutes.sync.filter(data, filter) then
				size = size + 1
				data.id = id
				list[size] = data
				if size == FIND_MUTES_LIMIT then break end 
			end
		else
			if id == lastID then found = true end
		end
	end

	return list
end