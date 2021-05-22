
cCommands.add("muteserial",
	function(admin, serial, nick, seconds, reason)
		if getMuteBySerial(serial) then return false, "serial is already muted" end

		local player = getPlayerBySerial(serial)
		local playerName = player and getPlayerName(player)

		local mute = addMute(serial, admin, reason, seconds, nick or playerName)
		if not mute then return false end

		cPenaltyLogs.output(admin, "mute", serial, {reason = reason, duration = seconds or 0, nick = nick})

		local durationReasonInfo = formatDuration(seconds or 0)..(reason and " ("..reason..")" or "")
		return true,
			"serial "..serial.." has been muted for "..durationReasonInfo,
			player and playerName.." has been muted for "..durationReasonInfo.." by $admin" or nil
	end,
	"serial:se,[nick:s,duration:du,reason:s-", "mute player by serial", COLORS.red
)

cCommands.add("unmuteserial",
	function(admin, serial, reason)
		local mute = getMuteBySerial(serial)
		if not mute then return false, "serial is not muted" end

		local player = getPlayerBySerial(serial)
		local playerName = player and getPlayerName(player)
		
		if not removeMute(mute, admin) then return false end

		cPenaltyLogs.output(admin, "unmute", serial, {reason = reason})

		local reasonInfo = reason and " ("..reason..")" or ""
		return true,
			"serial "..serial.." has been unmuted"..reasonInfo,
			player and playerName.." has been unmuted"..reasonInfo.." by $admin" or nil
	end,
	"serial:se,[reason:s", "unmute player by serial", COLORS.green
)

cCommands.add("setmuteduration",
	function(admin, serial, seconds)
		local mute = getMuteBySerial(serial)
		if not mute then return false, "serial is not muted" end

		local oldSeconds = getMuteDuration(mute)
		if oldSeconds == seconds then return false, "mute duration is already "..formatDuration(seconds) end

		if not setMuteDuration(mute, seconds) then return false end

		cPenaltyLogs.output(admin, "updatemute", serial, {duration = seconds or 0})

		local msg = string.format(
			"mute (%s) duration has been changed from [%s] to [%s]",
			serial, formatDuration(oldSeconds), formatDuration(seconds)
		)
		return true, msg
	end,
	"serial:se,duration:du", "set mute new duration"
)

cCommands.add("setmutenick",
	function(admin, serial, nick)
		local mute = getMuteBySerial(serial)
		if not mute then return false, "serial is not muted" end

		local oldNick = getMuteNick(mute)
		if oldNick == nick then return false, "mute nick is already '"..(nick or NIL_TEXT).."'" end

		if not setMuteNick(mute, nick) then return false end
	
		local msg = string.format(
			"mute (%s) nick has been changed from '%s' to '%s'",
			serial, oldNick or NIL_TEXT, nick or NIL_TEXT
		)
		return true, msg
	end,
	"serial:se,[nick:s", "set mute new nick"
)

cCommands.add("setmutereason",
	function(admin, serial, reason)
		local mute = getMuteBySerial(serial)
		if not mute then return false, "serial is not muted" end

		local oldReason = getMuteReason(mute)
		if oldReason == reason then return false, "mute reason is already '"..(reason or NIL_TEXT).."'" end

		if not setMuteReason(mute, reason) then return false end

		cPenaltyLogs.output(admin, "updatemute", serial, {reason = reason})

		local msg = string.format(
			"mute (%s) reason has been changed from '%s' to '%s'",
			serial, oldReason or NIL_TEXT, reason or NIL_TEXT
		)
		return true, msg
	end,
	"serial:se,[reason:s-", "set mute new reason"
)

cCommands.add("setmuteadmin",
	function(admin, serial, mutedBy)
		local mute = getMuteBySerial(serial)
		if not mute then return false, "serial is not muted" end

		local oldMutedBy = getMuteAdmin(mute)
		if oldMutedBy == mutedBy then return false, "mute admin is already '"..(mutedBy or NIL_TEXT).."'" end

		if not setMuteAdmin(mute, mutedBy) then return false end

		cPenaltyLogs.output(admin, "updatemute", serial, {admin = mutedBy})
	   
		local msg = string.format(
			"mute (%s) admin has been changed from '%s' to '%s'",
			serial, oldMutedBy or NIL_TEXT, mutedBy or NIL_TEXT
		)
		return true, msg
	end,
	"serial:se,[admin:s-", "set mute new admin (muted by)"
)