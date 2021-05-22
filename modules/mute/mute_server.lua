
local CHECK_INTERVAL = 2 * 10^3

addEvent("onMute", false)
addEvent("onUnmute", false)
addEvent("gra.mMute.onAdminChange", false)
addEvent("gra.mMute.onNickChange", false)
addEvent("gra.mMute.onReasonChange", false)
addEvent("gra.mMute.onTimeChange", false)

mMute = {}

mMute.mutes = {}

function mMute.init()
	
	cDB.exec([[
		CREATE TABLE IF NOT EXISTS mutes (
    		id               INTEGER PRIMARY KEY AUTOINCREMENT,
    		time             INTEGER NOT NULL,
    		serial           TEXT    NOT NULL,
    		unmute           INTEGER NOT NULL,
    		nick             TEXT,
    		reason           TEXT,
    		admin            TEXT
		)
	]])

	cDB.exec("DELETE FROM mutes WHERE unmute > 0 AND unmute < ?", getRealTime().timestamp)

	mMute.mutes = cDB.query("SELECT * FROM mutes")
	for i, data in ipairs(mMute.mutes) do
		local player = getPlayerBySerial(data.serial)
		if player then setPlayerMuted(player, true) end
	end

	addEventHandler("onPlayerJoin", root, mMute.onJoin, true, "high")

	setTimer(mMute.check, CHECK_INTERVAL, 0)

	return true
end

cModules.register(mMute)

function mMute.onJoin()
	
	local mute = mMute.getBySerial(getPlayerSerial(source))
	if not mute then return end
		
	setPlayerMuted(source, true)

end

function mMute.check()
	
	local timestamp = getRealTime().timestamp

	for i = #mMute.mutes, 1, -1 do
		local mute = mMute.mutes[i]
		if mute.unmute and mute.unmute > 0 and mute.unmute - timestamp <= 0 then
			triggerEvent("onUnmute", root, mute.id, true)
			mMute.remove(mute)
		end
	end

	return true
end

function mMute.isMute(mute)

	for i, m in ipairs(mMute.mutes) do
		if m == mute then return true end
	end
	return false
end

function mMute.getFromID(id)

	for i, mute in ipairs(mMute.mutes) do
		if mute.id == id then return mute end
	end
	return nil
end

function mMute.getData(mute)

	return {
		serial = mute.serial,
		nick = mute.nick,
		admin = mute.admin,
		reason = mute.reason,
		time = mute.time,
		unmute = mute.unmute
	}
end

function mMute.getBySerial(serial)

	for i, mute in ipairs(mMute.mutes) do
		if mute.serial == serial then return mute end
	end
	return nil
end

function mMute.add(time, serial, unmute, nick, reason, admin)
	
	local result, _, id = cDB.query(
		[[
		INSERT INTO mutes (
			time, serial, unmute, nick, reason, admin
		) VALUES (?,?,?,?,?,?)
		]],
		time, serial, unmute, nick, reason, admin
	)

	if not result and id then return false end

	mMute.mutes[#mMute.mutes + 1] = {
		id = id,
		time = time,
		serial = serial,
		unmute = unmute,
		nick = nick,
		reason = reason,
		admin = admin
	}

	local player = getPlayerBySerial(serial)
	if player then setPlayerMuted(player, true) end

	return id
end

function mMute.remove(mute)
	if not mMute.isMute(mute) then return false end

	local player = getPlayerBySerial(mute.serial)
	if player then setPlayerMuted(player, false) end

	table.removevalue(mMute.mutes, mute)
	cDB.exec("DELETE FROM mutes WHERE id = ?", mute.id)

	return true
end

function mMute.setData(mute, key, value)
	if not mMute.isMute(mute) then return false end

	mute[key] = value
	cDB.exec("UPDATE mutes SET ?? = ? WHERE id = ?", key, value, mute.id)

	return true
end

---------------  API  ---------------

function getMutes()
	
	local mutes = {}
	for i, mute in ipairs(mMute.mutes) do
		mutes[i] = mute.id
	end
	return mutes
end

function isMute(id)
	if not scheck("n") then return false end

	return mMute.getFromID(id) and true or false
end

function mutePlayer(player, responsibleElement, reason, seconds)
	if not scheck("u:element:player,?u:element:root|u:element:player|u:element:console,?s,?n") then return false end
	if isPlayerMuted(player) then return false end
	
	return addMute(getPlayerSerial(player), responsibleElement, reason, seconds, getPlayerName(player))
end

function unmutePlayer(player, responsibleElement, reason)
	if not scheck("u:element:player,?u:element:root|u:element:player|u:element:console,?s") then return false end
	if not isPlayerMuted(player) then return false end

	local id = getPlayerMute(player)
	if not id then return setPlayerMuted(player, false) end

	return removeMute(id, responsibleElement, reason)
end

function addMute(serial, responsibleElement, reason, seconds, nick)
	if not scheck("s,?u:element:root|u:element:player|u:element:console,?s,?n,?s") then return false end
	if not isValidSerial(serial) then return false end
	if seconds and seconds < 0 then return false end
	if mMute.getBySerial(serial) then return false end

	responsibleElement = responsibleElement or root
	seconds = math.floor(seconds or 0)

	local time = getRealTime().timestamp
	local unmute = (seconds > 0 and (time + seconds)) or 0
	local id = mMute.add(time, serial, unmute, nick, reason, getPlayerName(responsibleElement))

	triggerEvent("onMute", responsibleElement, id)

	return id
end

function removeMute(id, responsibleElement, reason)
	if not scheck("n,?u:element:root|u:element:player|u:element:console,?s") then return false end
	
	local mute = mMute.getFromID(id)
	if not mute then return false end

	responsibleElement = responsibleElement or root

	triggerEvent("onUnmute", responsibleElement, id)

	return mMute.remove(mute)
end

function getMuteBySerial(serial)
	if not scheck("s") then return false end
	if not isValidSerial(serial) then return false end

	local mute = mMute.getBySerial(serial)
	if not mute then return nil end

	return mute.id
end

function getPlayerMute(player)
	if not scheck("u:element:player") then return false end

	return getMuteBySerial(getPlayerSerial(player))
end

function getMutePlayer(id)
	if not scheck("n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	return getPlayerBySerial(mute.serial)
end

function getMuteSerial(id)
	if not scheck("n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	return mute.serial
end

function getMuteAdmin(id)
	if not scheck("n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	return mute.admin
end

function setMuteAdmin(id, admin)
	if not scheck("n,?s") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	mMute.setData(mute, "admin", admin)
	triggerEvent("gra.mMute.onAdminChange", root, id)

	return true
end

function getMuteNick(id)
	if not scheck("n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	return mute.nick
end

function setMuteNick(id, nick)
	if not scheck("n,?s") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	mMute.setData(mute, "nick", nick)
	triggerEvent("gra.mMute.onNickChange", root, id)

	return true
end

function getMuteReason(id)
	if not scheck("n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	return mute.reason
end

function setMuteReason(id, reason)
	if not scheck("n,?s") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	mMute.setData(mute, "reason", reason)
	triggerEvent("gra.mMute.onReasonChange", root, id)

	return true
end

function getUnmuteTime(id)
	if not scheck("n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	return mute.unmute
end

function setUnmuteTime(id, timestamp)
	if not scheck("n,n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end
	if timestamp < 0 then return false end

	mMute.setData(mute, "unmute", timestamp)
	triggerEvent("gra.mMute.onTimeChange", root, id)

	return true
end

function getMuteDuration(id)
	if not scheck("n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	if mute.unmute == 0 then return 0 end
	if mute.unmute <= mute.time then return 0 end

	return mute.unmute - mute.time
end

function setMuteDuration(id, seconds)
	if not scheck("n,n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end
	if seconds < 0 then return false end

	local timestamp = seconds == 0 and 0 or mute.time + seconds
	return setUnmuteTime(id, timestamp)
end

function getMuteData(id)
	if not scheck("n") then return false end

	local mute = mMute.getFromID(id)
	if not mute then return false end

	return mMute.getData(mute)
end