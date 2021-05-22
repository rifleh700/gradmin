
local WARP_DEFAULT_Z = 12
local SAYASADM_COLOR = COLORS.orange
local GIVE_VEHICLE_LIMIT = 5

--------- temporary code -------------
local staffVehicles = {}

addEventHandler("onPlayerQuit", root,
	function()
		if not staffVehicles[source] then return end

		local vehicles = staffVehicles[source]
		staffVehicles[source] = nil

		for i, v in ipairs(vehicles) do
			if isElement(v) then destroyElement(v) end
		end
	end
)

function registerStaffVehicle(admin, vehicle)
	
	if not staffVehicles[admin] then staffVehicles[admin] = {} end

	local vehicles = staffVehicles[admin]
	table.insert(vehicles, vehicle)
	addEventHandler("onElementDestroy", vehicle, onStaffVehicleDestroy, false)

	while #vehicles > GIVE_VEHICLE_LIMIT do
		destroyElement(vehicles[1])
	end

	return true
end

function onStaffVehicleDestroy()
	
	for admin, vehicles in pairs(staffVehicles) do
		for i, vehicle in ipairs(vehicles) do
			if vehicle == source then
				return table.remove(vehicles, i)
			end
		end
	end

end
--------------------------------------

local function setPlayerVehicleInterior(player, interior)
	if not setElementInterior(player, interior) then return false end
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			setElementInterior(occupant, interior)
		end
		setElementInterior(vehicle, interior)
	end
	return true
end

local function setPlayerVehicleDimension(player, dimension)
	if not setElementDimension(player, dimension) then return false end
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			setElementDimension(occupant, dimension)
		end
		setElementDimension(vehicle, dimension)
	end
	return true
end

local function warpPlayerToPoint(player, x, y, z, rot, dim, int)
	local vehicle = getPedOccupiedVehicle(player)
	local isDriver = vehicle and (getVehicleOccupant(vehicle) == player)
	local element = (isDriver and vehicle) or player

	if isDriver then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			setElementDimension(occupant, dim)
			setElementInterior(occupant, int)
		end
	else
		removePedFromVehicle(player)
	end

	setElementDimension(element, dim)
	setElementInterior(element, int)
	setElementPosition(element, x, y, z or WARP_DEFAULT_Z)
	setElementRotation(element, 0, 0, rot)

	if not z then triggerClientEvent(player, "gra.mPlayers.onWarpedToUndefinedZ", player, element, x, y) end

	return true
end

local function warpPlayerToPlayer(player, toPlayer)

	local toVehicle = getPedOccupiedVehicle(toPlayer)
	local toSeat = toVehicle and getVehicleFreePassengerSeat(toVehicle)

	local vehicle = getPedOccupiedVehicle(player)
	local isDriver = vehicle and (getVehicleOccupant(vehicle) == player)

	local element = (isDriver and vehicle) or player
	local toElement = toVehicle or toPlayer
	local int, dim = getElementInterior(toElement), getElementDimension(toElement)

	if isDriver then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			setElementDimension(occupant, dim)
			setElementInterior(occupant, int)
		end
	else
		removePedFromVehicle(player)
	end
	setElementDimension(element, dim)
	setElementInterior(element, int)

	if toSeat and (not isDriver) then
		return warpPedIntoVehicle(player, toVehicle, toSeat)
	end

	local offX, offY, offZ = 2, 0, 0.2
	if isDriver then
		offX, offZ = 3, 0.5
	end
	local x, y, z = getPositionFromElementOffset(toElement, offX, offY, offZ)
	local rx, ry, rz = getElementRotation(toElement)
	setElementRotation(element, rx, ry, rz)
	setElementPosition(element, x, y, z)

	return true
end

local function givePlayerVehicle(player, vehicleID)
	local pvehicle = getPedOccupiedVehicle(player)
	local element = pvehicle or player

	local x, y, z = getElementPosition(element)
	local rx, ry, rz = getElementRotation(element)
	local vx, vy, vz = getElementVelocity(element)
	
	if pvehicle then
		removePedFromVehicle(player)
		setElementVelocity(pvehicle, 0, 0, 0)
		z = z+2
	end

	vehicle = createVehicle(vehicleID, x, y, z, rx, ry, rz)
	setElementDimension(vehicle, getElementDimension(player))
	setElementInterior(vehicle, getElementInterior(player))
	warpPedIntoVehicle(player, vehicle)
	setElementVelocity(vehicle, vx, vy, vz)

	return vehicle
end

local function shoutPlayer(admin, player, text)
	local textDisplay = textCreateDisplay()
	if not textDisplay then return false end
	local r, g, b = unpack(COLORS.orange)
	local textItem =
		textCreateTextItem(
		getPlayerName(admin, true)..":\n\n" .. text,
		0.5, 0.5,
		2,
		r, g, b, 255,
		4,
		"center", "center",
		255
	)
	textDisplayAddText(textDisplay, textItem)
	textDisplayAddObserver(textDisplay, player)
	setTimer(
		function()
			textDestroyTextItem(textItem)
			textDestroyDisplay(textDisplay)
		end,
		5000, 1
	)
	return true
end

local function flipVehicle(vehicle)
	local rx, ry, rz = getVehicleRotation(vehicle)
	if not ((rx > 110) and (rx < 250)) then return false end
	local x, y, z = getElementPosition(vehicle)
	setVehicleRotation(vehicle, rx + 180, ry, rz)
	setElementPosition(vehicle, x, y, z + 2)
	return true
end

cCommands.add("kick",
	function(admin, player, reason)
		
		local serial = getPlayerSerial(player)
		local playerName = getPlayerName(player)
		if not kickPlayer(player, admin, reason) then return false end

		cPenaltyLogs.output(admin, "kick", serial, {reason = reason})	

		local reasonInfo = reason and " ("..reason..")" or ""
		return true,
			playerName.." has been kicked"..reasonInfo,
			playerName.." has been kicked"..reasonInfo.." by $admin"
	end,
	"player:P,[reason:s-", "kick player from the server", COLORS.red
)

cCommands.add("ban",
	function(admin, player, includeIP, seconds, reason)

		local playerName = getPlayerName(player)
		local serial = getPlayerSerial(player)
		local ip = includeIP and getPlayerIP(player)
		if not banPlayer(player, includeIP, false, true, admin, reason, seconds) then return false end

		cPenaltyLogs.output(admin, "ban", serial, {reason = reason, duration = seconds or 0})	

		local durationReasonInfo = formatDuration(seconds or 0)..(reason and " ("..reason..")" or "")
		return true,
			playerName.." has been banned for "..durationReasonInfo,
			playerName.." has been banned for "..durationReasonInfo.." by $admin"
	end,
	"player:P,[include-IP(yes/no):b,duration:du,reason:s-", "ban player by either serial", COLORS.red
)

cCommands.add("mute",
	function(admin, player, seconds, reason)
		if isPlayerMuted(player) then return false, "player is already muted" end

		if not mutePlayer(player, admin, reason, seconds) then return false end

		cPenaltyLogs.output(admin, "mute", getPlayerSerial(player), {reason = reason, duration = seconds or 0})	

		local durationReasonInfo = formatDuration(seconds or 0)..(reason and " ("..reason..")" or "")
		return true,
			"$player has been muted for "..durationReasonInfo,
			"$player has been muted for "..durationReasonInfo.." by $admin",
			"You have been muted for "..durationReasonInfo.." by $admin"
	end,
	"player:P,[duration:du,reason:s-", "mute player", COLORS.red
)

cCommands.add("unmute",
	function(admin, player, reason)
		if not isPlayerMuted(player) then return false, "player is already unmuted" end

		if not unmutePlayer(player, admin, reason) then return false end

		cPenaltyLogs.output(admin, "unmute", getPlayerSerial(player), {reason = reason})

		local reasonInfo = reason and " ("..reason..")" or ""
		return true,
			"$player has been unmuted"..reasonInfo,
			"$player has been unmuted"..reasonInfo.." by $admin",
			"You have been unmuted"..reasonInfo.." by $admin"
	end,
	"player:P,[reason:s-", "unmute player", COLORS.green
)

cCommands.add("freeze",
	function(admin, player)
		if isElementFrozen(player) then return false, "player is already frozen" end

		if not setElementFrozen(player, true) then return false end

		local vehicle = getPedOccupiedVehicle(player)
		if vehicle then setElementFrozen(vehicle, true) end

		return true,
			"$player has been frozen",
			nil,
			"You have been frozen by $admin"
	end,
	"player:P", "freeze player", COLORS.red
)

cCommands.add("unfreeze",
	function(admin, player)
		if not isElementFrozen(player) then return false, "player is already unfrozen" end

		if not setElementFrozen(player, false) then return false end

		local vehicle = getPedOccupiedVehicle(player)
		if vehicle then setElementFrozen(vehicle, false) end

		return true,
			"$player has been unfrozen",
			nil,
			"You have been unfrozen by $admin"
	end,
	"player:P", "unfreeze player", COLORS.green
)

cCommands.add("shout",
	function(admin, player, msg)

		if not shoutPlayer(admin, player, msg) then return false end

		cPenaltyLogs.output(admin, "shout", getPlayerSerial(player), {reason = msg})	

		return true,
			"$player has been shouted: "..msg,
			nil,
			"You have been shouted by $admin"
	end,
	"player:P,message:s-", "shout player", COLORS.orange
)

cCommands.add("slap",
	function(admin, player, slap, reason)
		if isPedDead(player) or getElementHealth(player) == 0 then return false, "player is dead" end
		if slap < 0 then return false end
		
		if slap >= getElementHealth(player) then
			if not killPed(player) then return false end
		else
			if not setElementHealth(player, getElementHealth(player) - slap) then return false end
		end

		cPenaltyLogs.output(admin, "slap", getPlayerSerial(player), {reason = reason})	

		local x, y, z = getElementVelocity(player)
		setElementVelocity(player, x, y, z + 0.2)

		local reasonInfo = reason and " ("..reason..")" or ""
		return true,
			"$player has been slapped ("..slap.." HP)"..reasonInfo,
			"$player has been slapped ("..slap.." HP)"..reasonInfo.." by $admin",
			"You have been slapped ("..slap.." HP)"..reasonInfo.." by $admin"
	end,
	"player:P,health:n,[reason:s-", "slap player", COLORS.red
)

cCommands.add("killplayer",
	function(admin, player, reason)
		if isPedDead(player) or getElementHealth(player) == 0 then return false, "player is dead" end
		
		if not killPed(player) then return false end
		
		cPenaltyLogs.output(admin, "kill", getPlayerSerial(player), {reason = reason})	

		local reasonInfo = reason and " ("..reason..")" or ""
		return true,
			"$player has been killed"..reasonInfo,
			"$player has been killed"..reasonInfo.." by $admin",
			"You have been killed"..reasonInfo.." by $admin"
	end,
	"player:P,[reason:s-", "kill player", COLORS.red
)

cCommands.add("setplayerpassword",
	function(admin, player, newPassword)
		local account = getPlayerAccount(player)
		if isGuestAccount(account) then return false, "player is not logged in" end

		if not setAccountPassword(account, newPassword) then return false end

		local accountName = getAccountName(account)
		return true,
			"$player's account '"..accountName.."' password has been changed",
			nil,
			"Your account '"..accountName.."' password has been changed by $admin"
	end,
	"player:P,password:s", "set player's account new password", COLORS.orange
)

cCommands.add("logoutplayer",
	function(admin, player)
		local account = getPlayerAccount(player)
		if isGuestAccount(account) then return false, "player is not logged in" end

		local accountName = getAccountName(account)
		if not logOut(player) then return false end

		return true,
			"$player has been logged out from '"..accountName.."' account",
			nil,
			"You have been logged out from '"..accountName.."' account by $admin"
	end,
	"player:P", "logout player from account", COLORS.orange
)

cCommands.add("loginplayer",
	function(admin, player, accountName, password)
		local currentAccount = getPlayerAccount(player)
		if not isGuestAccount(current) then return false, "player is already logged in, logout first" end

		local account = getAccount(accountName)
		if not account then return false, "account '"..accountName.."' not found" end

		account = getAccount(accountName, password)
		if not account then return false, "invalid password for '"..accountName.."' account" end

		if not logIn(player, account, password) then return false end
		
		return true,
			"$player has been logged in to '"..accountName.."' account",
			nil,
			"You have been logged in to '"..accountName.."' account by $admin"
	end,
	"player:P,account-name:s,password:s", "log in player to account", COLORS.orange
)

cCommands.add("setplayeraclgroup",
	function(admin, player, groupName)
		local account = getPlayerAccount(player)
		if isGuestAccount(account) then return false, "player is not logged in" end

		local newGroup = aclGetGroup(groupName)
		if not newGroup then return false, "group doesn't exist" end
		if not hasGroupPermissionTo(newGroup, GENERAL_PERMISSION) then return false, "group doesn't have admin panel permission" end

		local accountName = getAccountName(account)
		local object = "user."..accountName
		if isObjectInACLGroup(object, newGroup) then return false, "player is already in '"..groupName.."' ACL group" end

		for i, group in ipairs(mPlayers.getGradminACLGroups()) do
			if isObjectInACLGroup(object, group) then
				if not aclGroupRemoveObject(group, object) then return false, "can't remove player from '"..group.."' ACL group" end
			end
		end
		if not aclGroupAddObject(newGroup, object) then return false end

		triggerEvent("gra.onAclChange", root)
		
		return true,
			"$player has been given '"..groupName.."' admin rights"
	end,
	"player:P,aclgroup-name:s", "set player admin panel acl group (only admin panel groups)", COLORS.orange
)

cCommands.add("resetplayeraclgroup",
	function(admin, player)
		local account = getPlayerAccount(player)
		if isGuestAccount(account) then return false, "player is not logged in" end

		local accountName = getAccountName(account)
		local object = "user."..accountName

		local removed = false
		for i, group in ipairs(mPlayers.getGradminACLGroups()) do
			if isObjectInACLGroup(object, group) then
				if not aclGroupRemoveObject(group, object) then return false, "can't remove player from '"..group.."' ACL group" end
				removed = true
			end
		end
		if not removed then return false, "player doesn't have admin rights" end

		triggerEvent("gra.onAclChange", root)

		return true,
			"$player's admin rights have been revoked"
	end,
	"player:P", "remove player from all admin panel acl groups (only admin panel groups)", COLORS.red
)

cCommands.add("setplayerhealth",
	function(admin, player, health)
		if isPedDead(player) or getElementHealth(player) == 0 then return false, "too late, he is dead :(" end
		
		health = math.clamp(health or 200, 0, 200)
		if not setElementHealth(player, health) then return false end
		
		return true,
			"$player's health has been set to "..health,
			nil,
			"Your health has been set to "..health.." by $admin"
	end,
	"player:P,[health:n", "set player health", COLORS.yellow
)

cCommands.add("setplayerarmour",
	function(admin, player, armour)
		if isPedDead(player) or getElementHealth(player) == 0 then return false, "player is dead" end

		armour = math.clamp(armour, 0, 200)
		if not setPedArmor(player, armour) then return false end

		return true,
			"$player's armour has been set to "..armour,
			nil,
			"Your armour has been set to "..armour.." by $admin"
	end,
	"player:P,armour:n", "set player armour", COLORS.yellow
)

cCommands.add("healplayer",
	function(admin, player)
		if isPedDead(player) or getElementHealth(player) == 0 then return false, "too late, he is dead :(" end
		
		if not setElementHealth(player, 200) then return false end
		if not setPedArmor(player, 200) then return false end
		
		return true,
			"$player has been healed",
			nil,
			"You have been healed by $admin"
	end,
	"player:P", "heal player", COLORS.green
)

cCommands.add("setplayerskin",
	function(admin, player, skin, walking)
		if not isValidPedModel(skin) then return false, "invalid model" end
		if getElementModel(player) == skin then return false, "player skin is already "..formatNameID(getPedModelName(skin), skin) end
		
		if not setElementModel(player, skin) then return false end
		if walking then setPedWalkingStyle(player, getPedModelWalkingStyle(skin)) end
		
		local skinInfo = formatNameID(getPedModelName(skin), skin)
		return true,
			"$player's skin has been set to "..skinInfo,
			nil,
			"Your skin has been set to "..skinInfo.." by $admin"
	end,
	"player:P,skinID:n|skin-name:skn,[walking-style(yes/no):b", "set player skin", COLORS.purple
)

cCommands.add("setplayerfighting",
	function(admin, player, style)
		if not isValidFightingStyle(style) then return false, "invalid fighting style" end
		if getPedFightingStyle(player) == style then return false, "player fighting style is already "..formatNameID(getFightingStyleName(style), style) end
		
		if not setPedFightingStyle(player, style) then return false end
		
		local styleInfo = formatNameID(getFightingStyleName(style), style)
		return true,
			"$player's fighting style has been set to "..styleInfo,
			nil,
			"Your fighting style has been set to "..styleInfo.." by $admin"
	end,
	"player:P,styleID:n|style-name:fin", "set player fighting style", COLORS.purple
)

cCommands.add("setplayerwalking",
	function(admin, player, style)
		if not isValidWalkingStyle(style) then return false, "invalid walking style" end
		if getPedWalkingStyle(player) == style then return false, "player fighting style is already "..formatNameID(getWalkingStyleName(style), style) end
		
		if not setPedWalkingStyle(player, style) then return false end
		
		local styleInfo = formatNameID(getWalkingStyleName(style), style)
		return true,
			"$player's walking style has been set to "..styleInfo,
			nil,
			"Your walking style has been set to "..styleInfo.." by $admin"
	end,
	"player:P,styleID:n|style-name:wan", "set player walking style", COLORS.purple
)

cCommands.add("setplayerstat",
	function(admin, player, stat, value)
		if not isValidPedStat(stat) then return false, "invalid stat" end
		if (stat == 21 or stat == 23) and getElementModel(player) ~= 0 then return false, "stats 21 and 23 can only be used on the CJ skin" end 
		
		value = math.clamp(value, 0, 1000)
		if not setPedStat(player, stat, value) then return false end
		
		local statInfo = formatNameID(getPedStatName(stat), stat)
		return true,
			"$player's "..statInfo.." has been set to "..value,
			nil,
			"Your "..statInfo.." has been set to "..value.." by $admin"
	end,
	"player:P,statID:n|stat-name:stn,value:n", "set player stat (weapon or body skills)", COLORS.purple
)

cCommands.add("setplayerweaponstats",
	function(admin, player, value)

		value = math.clamp(value, 0, 1000)		
		for i, stat in ipairs(getValidPedStatsByGroup("weapon")) do
			setPedStat(player, stat, value)
		end
		
		return true,
			"$player's weapon stats have been set to "..value,
			nil,
			"Your weapon stats have been set to "..value.." by $admin"
	end,
	"player:P,value:n", "set player weapon stats", COLORS.purple
)

cCommands.add("setplayername",
	function(admin, player, name)
		local oldName = getPlayerName(player)
		if oldName == name then return false, "player already has nick '"..name.."'" end
		
		if not setPlayerName(player, name) then return false end
		
		return true,
			oldName.."'s name has been set to "..name,
			oldName.."'s name has been set to "..name.." by $admin",
			"Your name has been set to "..name.." by $admin"
	end,
	"player:P,new-nick:s", "set player new name", COLORS.orange
)

cCommands.add("setplayerteam",
	function(admin, player, team)
		local teamName = team and getTeamName(team) or NIL_TEXT
		local currentTeam = getPlayerTeam(player)
		if currentTeam == team or (not currentTeam) and (not team) then 
			return false, "player team is already '"..teamName.."'"
		end
		
		if not setPlayerTeam(player, team) then return false end
		
		return true,
			"$player has been moved to the '"..teamName.."' team",
			nil,
			"You have been moved to the '"..teamName.."' team by $admin"
	end,
	"player:P,[team-name:T", "set player team", COLORS.yellow
)

cCommands.add("giveplayerjetpack",
	function(admin, player)
		if doesPedHaveJetPack(player) then return false, "player already has jetpack" end
		if getPedOccupiedVehicle(player) then return false, "player has a vehicle" end

		if not givePedJetPack(player) then return false end

		return true,
			"$player has been given a jetpack",
			nil,
			"You have been given a jetpack by $admin"
	end,
	"player:P", "give player jetpack", COLORS.green
)

cCommands.add("removeplayerjetpack",
	function(admin, player)
		if not doesPedHaveJetPack(player) then return false, "player doesn't have jetpack" end
		
		if not removePedJetPack(player) then return false end

		return true,
			"$player's jetpack has been removed",
			nil,
			"Your jetpack has been removed by $admin"
	end,
	"player:P", "remove player's jetpack", COLORS.red
)

cCommands.add("giveplayervehicle",
	function(admin, player, vehicleID)
		if not isValidVehicleModel(vehicleID) then return false, "invalid vehicle model" end
		
		local vehicle = givePlayerVehicle(player, vehicleID)
		if not vehicle then return false end

		registerStaffVehicle(admin, vehicle) 
		
		local vehicleInfo = formatNameID(getVehicleNameFromModel(vehicleID), vehicleID)
		return true,
			"$player has been given a "..vehicleInfo,
			nil,
			"You have been given a "..vehicleInfo.." by $admin"
	end,
	"player:P,vehicleID:n|vehicle-name:ven", "give player a new vehicle", COLORS.green
)

cCommands.add("setplayervehicle",
	function(admin, player, vehicleID)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if not isValidVehicleModel(vehicleID) then return false, "invalid vehicle model" end
		if getElementModel(vehicle) == vehicleID then return false, "player's vehicle model already is "..formatNameID(getVehicleNameFromModel(vehicleID), vehicleID) end

		if not setElementModel(vehicle, vehicleID) then return false end

		local vehicleInfo = formatNameID(getVehicleNameFromModel(vehicleID), vehicleID)
		return true,
			"$player's vehicle model has been set to "..vehicleInfo,
			nil,
			"Your vehicle model has been set to "..vehicleInfo.." by $admin"
	end,
	"player:P,vehicleID:n|vehicle-name:ven", "change player's vehicle model", COLORS.purple
)

cCommands.add("giveplayerweapon",
	function(admin, player, weapon, ammo)
		if not isValidWeaponID(weapon) then return false, "invalid weapon" end
		
		if not giveWeapon(player, weapon, ammo, true) then return false end
		
		local weaponInfo = formatNameID(getWeaponNameFromID(weapon), weapon).." ("..ammo..")"
		return true,
			"$player has been given a "..weaponInfo,
			nil,
			"You have been given a "..weaponInfo.." by $admin"
	end,
	"player:P,weaponID:n|weapon-name:wen,ammo:n", "give player weapon", COLORS.green
)

cCommands.add("takeplayerweapon",
	function(admin, player, weapon)
		if not isValidWeaponID(weapon) then return false, "invalid weapon" end
		
		if not takeWeapon(player, weapon) then return false end
		
		local weaponInfo = formatNameID(getWeaponNameFromID(weapon), weapon)
		return true,
			"$player's "..weaponInfo.." has been removed",
			nil,
			"Your "..weaponInfo.." has been removed by $admin"
	end,
	"player:P,weaponID:n|weapon-name:wen", "take player weapon", COLORS.red
)

cCommands.add("takeplayerallweapon",
	function(admin, player)

		if not takeAllWeapons(player) then return false end

		return true,
			"$player's all weapons have been removed",
			nil,
			"Your all weapons have been removed by $admin"
	end,
	"player:P", "take player all weapons", COLORS.red
)

cCommands.add("warpplayertopoint",
	function(admin, player, x, y, z, int, dim)
		int = int or getElementInterior(player)
		dim = dim or getElementDimension(player)
		if dim < 0 or dim > 65535 then return false, "dimension must be between 0 and 65535" end

		if not warpPlayerToPoint(player, x, y, z, 0, dim, int) then return false end

		return true,
			"$player has been warped to "..formatPosition(x, y, z).." point",
			nil,
			"You have been warped to "..formatPosition(x, y, z).." point by $admin"
	end,
	"player:P,X:n,Y:n,[Z:n,interior:byte,dimension:n", "warp player to point", COLORS.yellow
)


cCommands.add("warpplayertoplayer",
	function(admin, player, toPlayer)

		if not warpPlayerToPlayer(player, toPlayer) then return false end

		local playerName = getPlayerName(toPlayer)
		return true,
			"$player has been warped to "..playerName,
			nil,
			"You have been warped to "..playerName.." by $admin"
	end,
	"player:P,to-player:P", "warp player to player", COLORS.yellow
)

cCommands.add("warpplayertointerior",
	function(admin, player, id)
		if not isValidInteriorLocation(id) then return false, "invalid interior location ID" end
		
		local int = getInteriorLocationInterior(id)
		local x, y, z, rot = getInteriorLocationPosition(id)
		if not warpPlayerToPoint(player, x, y, z, rot, 0, int) then return false end
		
		local interiorInfo = formatNameID(getInteriorLocationName(id), id)
		return true,
			"$player has been warped to "..interiorInfo.." interior",
			nil,
			"You have been warped to "..interiorInfo.." interior by $admin"
	end,
	"player:P,interiorID:n|interior-name:inn", "warp player to interior location", COLORS.yellow
)

cCommands.add("setplayerinterior",
	function(admin, player, interior)
		if getElementInterior(player) == interior then return false, "player interior is already "..interior end
		
		if not setPlayerVehicleInterior(player, interior) then return false end
		
		return true,
			"$player has been moved to the "..interior.." interior",
			nil,
			"You have been moved to the "..interior.." interior by $admin"
	end,
	"player:P,interior:byte", "set player interior", COLORS.yellow
)

cCommands.add("setplayerdimension",
	function(admin, player, dimension)
		if dimension < 0 or dimension > 65535 then return false, "dimension must be between 0 and 65535" end
		if getElementDimension(player) == dimension then return false, "player dimension is already "..dimension end
		
		if not setPlayerVehicleDimension(player, dimension) then return false end
		
		return true,
			"$player has been moved to the "..dimension.." dimension",
			nil,
			"You have been moved to the "..dimension.." dimension by $admin"
	end,
	"player:P,dimension:n", "set player dimension", COLORS.yellow
)

cCommands.add("setplayervehiclehealth",
	function(admin, player, health)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		
		if isVehicleBlown(vehicle) then return false, "player's vehicle is blown" end
		
		health = math.clamp(health or 1000, 0, 1000)
		if not setElementHealth(vehicle, health) then return false end
		
		return true,
			"$player's vehicle health has been set to "..health,
			nil,
			"Your vehicle health has been set to "..health.." by $admin"
	end,
	"player:P,[health:n", "repair player's vehicle", COLORS.yellow
)

cCommands.add("repairplayervehicle",
	function(admin, player)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		
		if not fixVehicle(vehicle) then return false end
		flipVehicle(vehicle)
		
		return true,
			"$player's vehicle has been fixed",
			nil,
			"Your vehicle has been fixed by $admin"
	end,
	"player:P", "repair player's vehicle", COLORS.green
)

cCommands.add("addplayerupgrades",
	function(admin, player, upgrades)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		
		for i, upgrade in ipairs(upgrades) do
			if not isValidVehicleUpgrade(upgrade) then return false, "invalid upgrade ID: "..upgrade end
		end
		local added = {}
		local addedNames = {}
		for i, upgrade in ipairs(upgrades) do
			local add = addVehicleUpgrade(vehicle, upgrade)
			if add then
				table.insert(added, upgrade)
				table.insert(addedNames, getVehicleUpgradeName(upgrade))
			end
		end
		if #added == 0 then return false, "incompatible upgrades" end
		
		local upgradesInfo = "("..table.concat(addedNames, ", ")..")"
		return true,
			"$player's vehicle has been upgraded "..upgradesInfo,
			nil,
			"Your vehicle has been upgraded "..upgradesInfo.." by $admin"
	end,
	"player:P,upgradeIDs:tn-", "upgrade player's vehicle", COLORS.green
)

cCommands.add("removeplayerupgrades",
	function(admin, player, upgrades)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		
		if not upgrades then
			upgrades = getVehicleUpgrades(vehicle)
			if #upgrades == 0 then return false, "vehicle doesn't have upgrades" end
		end
		
		for i, upgrade in ipairs(upgrades) do
			if not isValidVehicleUpgrade(upgrade) then return false, "invalid upgrade ID: "..upgrade end
		end
		local removed = {}
		local removedNames = {}
		for i, upgrade in ipairs(upgrades) do
			local remove = removeVehicleUpgrade(vehicle, upgrade)
			if remove then
				table.insert(removed, upgrade)
				table.insert(removedNames, getVehicleUpgradeName(upgrade))
			end
		end
		if #removed == 0 then return false, "vehicle doesn't have these upgrades" end
		
		local upgradesInfo = "("..table.concat(removedNames, ", ")..")"
		return true,
			"$player's vehicle upgrades "..upgradesInfo.." have been removed",
			nil,
			"Your vehicle upgrades "..upgradesInfo.." have been removed by $admin"
	end,
	"player:P,[upgradeIDs:tn-", "remove player's vehicle upgrades", COLORS.red
)

cCommands.add("setplayerpaintjob",
	function(admin, player, id)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if id < 0 or id > 3 then return false, "paint job ID must be between 0 and 3" end
		if getVehiclePaintjob(vehicle) == id then return false, "player's vehicle paintjob is already "..id end
		
		if not setVehiclePaintjob(vehicle, id) then return false end
		
		local paintjobInfo = id == 3 and NIL_TEXT or id
		return true,
			"$player's vehicle paint job set to "..paintjobInfo,
			nil,
			"Your vehicle paint job set to "..paintjobInfo.." by $admin"
	end,
	"player:P,paintjob-ID:n", "set player's vehicle paintjob", COLORS.green
)

cCommands.add("setplayervehiclecolor",
	function(admin, player, number, r, g, b)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if number < 1 or number > 4 then return false, "color number must be between 1 and 4" end
		
		if not setVehicleOneColor(vehicle, number, r, g, b) then return false end
		
		return true,
			"$player's vehicle color #"..number.." changed to "..formatColor(r, g, b),
			nil,
			"Your vehicle color #"..number.." changed to "..formatColor(r, g, b).." by $admin"
	end,
	"player:P,color-number:n,R:byte,G:byte,B:byte", "set player's vehicle color", COLORS.purple
)

cCommands.add("setplayervehiclelightcolor",
	function(admin, player, r, g, b)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		
		if not setVehicleHeadLightColor(vehicle, r, g, b) then return false end
		
		return true,
			"$player's vehicle lights color changed to "..formatColor(r, g, b),
			nil,
			"Your vehicle lights color changed to "..formatColor(r, g, b).." by $admin"
	end,
	"player:P,R:byte,G:byte,B:byte", "set player's vehicle lights color", COLORS.purple
)

cCommands.add("blowplayervehicle",
	function(admin, player)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if isVehicleBlown(vehicle) then return false, "vehicle is already blown" end
		
		if not blowVehicle(vehicle) then return false end
		
		return true,
			"$player's vehicle has been blown",
			nil,
			"Your vehicle has been blown by $admin"
	end,
	"player:P", "blow player's vehicle", COLORS.red
)

cCommands.add("destroyplayervehicle",
	function(admin, player)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		
		if not destroyElement(vehicle) then return false end
		
		return true,
			"$player's vehicle has been destroyed",
			nil,
			"Your vehicle has been destroyed by $admin"
	end,
	"player:P", "destroy player's vehicle", COLORS.red
)

cCommands.add("ejectplayer",
	function(admin, player)
		if not getPedOccupiedVehicle(player) then return false, "player doesn't have vehicle" end
		
		if not removePedFromVehicle(player) then return false end
		local x, y, z = getElementPosition(player)
		setElementPosition(player, x, y, z + 2)
		
		return true,
			"$player has been ejected from vehicle",
			nil,
			"You have been ejected from vehicle by $admin"
	end,
	"player:P", "eject player from vehicle", COLORS.red
)

cCommands.add("sayasadm",
	function(admin, message)

		local isAnonymous = cPersonalSettings.get(admin, "anonymous")
		local name = getPlayerName(admin)

		return cMessages.outputPublic((isAnonymous and "Admin" or name)..": "..message, root, SAYASADM_COLOR)
	end,
	"message:s-", "output global message as staff"
)

cCommands.add("pmasadm",
	function(admin, player, message)

		local anonymous = cPersonalSettings.get(admin, "anonymous")
		local adminName = getPlayerName(admin)

		return cMessages.outputPublic(
			"PM from Admin"..(anonymous and "" or " "..adminName)..": "..message,
			player,
			SAYASADM_COLOR
		)
	end,
	"player:P,message:s-", "send personal message to player as staff"
)