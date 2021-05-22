
console = getElementByIndex("console", 0)

function getPlayerAccountName(player)
	if not scheck("u:element:player|u:element:root|u:element:console") then return false end

	if player == root or player == console then return "Console" end

	local account = getPlayerAccount(player)
	if not account or isGuestAccount(account) then return nil end

	return getAccountName(account)
end

function getPlayerBySerial(serial)
	if not scheck("s") then return false end
	if not isValidSerial(serial) then return warn("invalid serial", 2) and false end

	for i, player in ipairs(getElementsByType("player")) do
		if getPlayerSerial(player) == serial then return player end
	end
	return nil
end

function getPlayerByIP(ip)
	if not scheck("s") then return false end
	if not isValidIP(ip) then return warn("invalid IP", 2) and false end

	for i, player in ipairs(getElementsByType("player")) do
		if getPlayerIP(player) == ip then return player end
	end
	return nil
end

function getBanBySerial(serial)
	if not scheck("s") then return false end
	if not isValidSerial(serial) then return warn("invalid serial", 2) and false end

	for i, ban in ipairs(getBans()) do
		if getBanSerial(ban) == serial then return ban end
	end
	return nil
end

function getBanByIP(ip)
	if not scheck("s") then return false end
	if not isValidIP(ip) then return warn("invalid IP", 2) and false end

	for i, ban in ipairs(getBans()) do
		if getBanIP(ban) == ip then return ban end
	end
	return nil
end

function getBan(serialIP)
	if not scheck("s") then return false end
	if not (isValidSerial(serialIP) or isValidIP(serialIP)) then return warn("invalid serial or IP", 2) and false end
	
	for i, ban in ipairs(getBans()) do
		if getBanSerial(ban) == serialIP or getBanIP(ban) == serialIP then return ban end
	end
	return nil
end

function getBanDuration(ban)
	if not scheck("u:ban") then return false end

	local time = getBanTime(ban)
	local unban = getUnbanTime(ban)
	if (not unban) or (not time) or (unban <= time) then return 0 end

	return unban - time
end

function setBanDuration(ban, seconds)
	if not scheck("u:ban,n") then return false end
	if seconds < 0 then return warn("invalid duration", 2) and false end

	seconds = math.floor(seconds)
	if seconds == 0 then return setUnbanTime(ban, 0) end
	
	return setUnbanTime(ban, (getBanTime(ban) or 0) + seconds)
end