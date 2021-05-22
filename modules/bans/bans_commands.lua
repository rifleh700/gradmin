
cCommands.add("banserial",
	function(admin, serial, ip, nick, seconds, reason)
		
		if getBanBySerial(serial) then return false, "serial is already banned" end
		if ip and getBanByIP(ip) then return false, "IP is already banned" end

		local player = ip and getPlayerByIP(ip) or getPlayerBySerial(serial)
		local playerName = player and getPlayerName(player)

		local ban = addBan(ip or nil, nil, serial, admin, reason, seconds)
		if not ban then return false end

		nick = nick or playerName
		if nick then
			setBanNick(ban, nick)
			triggerEvent("gra.mBans.onNickChange", root, ban)
		end

		cPenaltyLogs.output(admin, "ban", serial, {reason = reason, duration = seconds or 0})

		local durationReasonInfo = formatDuration(seconds or 0)..(reason and " ("..reason..")" or "")
		return true,
			"serial "..serial.." has been banned for "..durationReasonInfo,
			player and stripColorCodes(playerName).." has been banned for "..durationReasonInfo.." by $admin" or nil
	end,
	"serial:se,[IP:ip|none:nil,nick:s,duration:du,reason:s-", "ban offline player's serial", COLORS.red
)

cCommands.add("unban",
	function(admin, serialIP, reason)
		-- we can't use commands parsing for ban userdata(like 'banSerial/IP:ban' instead 'serial:se|IP:ip') due to client side command execute api ("gra.cCommands.execute") 
		local ban = getBan(serialIP)
		if not ban then return false, "serial/IP is not banned" end

		local serial = getBanSerial(ban)
		local ip = getBanIP(ban)
		if not removeBan(ban, admin) then return false end

		if serial then
			cPenaltyLogs.output(admin, "unban", serial, {reason = reason})
		end

		local reasonInfo = reason and " ("..reason..")" or ""
		return true,
			(serial and "serial" or "IP").." "..(serial or ip).." has been unbanned"..reasonInfo
	end,
	"serial:se|IP:ip,[reason:s", "unban serial or IP", COLORS.green
)

cCommands.add("setbanduration",
	function(admin, serialIP, seconds)
		local ban = getBan(serialIP)
		if not ban then return false, "serial/IP is not banned" end

		local oldSeconds = getBanDuration(ban)
		if oldSeconds == seconds then return false, "ban duration is already "..formatDuration(seconds) end

		local serial = getBanSerial(ban)
		if not setBanDuration(ban, seconds) then return false end
		triggerEvent("gra.mBans.onUnbanTimeChange", root, ban)
		
		if serial then
			cPenaltyLogs.output(admin, "updateban", serial, {duration = seconds or 0})
		end

		local msg = string.format(
			"ban (%s) duration has been changed from [%s] to [%s]",
			serialIP, formatDuration(oldSeconds), formatDuration(seconds)
		)
		return true, msg
	end,
	"serial:se|IP:ip,duration:du", "set ban new duration"
)

cCommands.add("setbannick",
	function(admin, serialIP, nick)
		local ban = getBan(serialIP)
		if not ban then return false, "serial/IP is not banned" end

		local oldNick = getBanNick(ban)
		if oldNick == nick then return false, "ban nick is already '"..(nick or NIL_TEXT).."'" end

		if not setBanNick(ban, nick) then return false end
		triggerEvent("gra.mBans.onNickChange", root, ban)
		
		local msg = string.format(
			"ban (%s) nick has been changed from '%s' to '%s'",
			serialIP, oldNick or NIL_TEXT, nick or NIL_TEXT
		)
		return true, msg
	end,
	"serial:se|IP:ip,[nick:s", "set ban new nick"
)

cCommands.add("setbanreason",
	function(admin, serialIP, reason)
		local ban = getBan(serialIP)
		if not ban then return false, "serial/IP is not banned" end

		local oldReason = getBanReason(ban)
		if oldReason == reason then return false, "ban reason is already '"..(reason or NIL_TEXT).."'" end

		if not setBanReason(ban, reason) then return false end
		triggerEvent("gra.mBans.onReasonChange", root, ban)

		local serial = getBanSerial(ban)
		if serial then
			cPenaltyLogs.output(admin, "updateban", serial, {reason = reason})	
		end
		
		local msg = string.format(
			"ban (%s) reason has been changed from '%s' to '%s'",
			serialIP, oldReason or NIL_TEXT, reason or NIL_TEXT
		)
		return true, msg
	end,
	"serial:se|IP:ip,[reason:s-", "set ban new reason"
)

cCommands.add("setbanadmin",
	function(admin, serialIP, bannedBy)
		local ban = getBan(serialIP)
		if not ban then return false, "serial/IP is not banned" end

		local oldBannedBy = getBanAdmin(ban)
		if oldBannedBy == bannedBy then return false, "ban admin is already '"..(bannedBy or NIL_TEXT).."'" end

		if not setBanAdmin(ban, bannedBy) then return false end
		triggerEvent("gra.mBans.onAdminChange", root, ban)

		local serial = getBanSerial(ban)
		if serial then
			cPenaltyLogs.output(admin, "updateban", serial, {admin = bannedBy})	
		end
	   
		local msg = string.format(
			"ban (%s) admin has been changed from '%s' to '%s'",
			serialIP, oldBannedBy or NIL_TEXT, bannedBy or NIL_TEXT
		)
		return true, msg
	end,
	"serial:se|IP:ip,[admin:s-", "set ban new admin (banned by)"
)