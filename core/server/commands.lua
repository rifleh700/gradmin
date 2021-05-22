
local ANONYMOUS_NAME = "Admin"
local PUBLIC_MESSAGE_DEFAULT_COLOR = COLORS.yellow
local FIND_LOGS_LIMIT = 50

addEvent("gra.cCommands.execute", true)

local commandsData = {}
local hcCommandsData = {}

local function getAdminGroups(element)

	local groups = {}
	for i, group in ipairs(getObjectACLGroups(element)) do
		groups[i] = aclGroupGetName(group)
	end
	return groups
end

local function formatMessage(message, admin, player)
	
	local anonymous = cPersonalSettings.get(admin, "anonymous")
	local adminName = anonymous and ANONYMOUS_NAME or getPlayerName(admin)
	local playerName = player and getPlayerName(player) or "player"

	message = message
		:gsub("%$player", playerName)
		:gsub("%$admin", adminName)

	return message
end

local function outputConsoleLog(admin, commandName, description)
	
	local message = string.format(
		"COMMANDS: %s: %s BY (%s) %s (Account: '%s'  Serial: %s)",
		commandName, description,
		table.concat(getAdminGroups(admin), ", "), getPlayerName(admin),
		getPlayerAccountName(admin) or NIL_TEXT, admin == console and NIL_TEXT or getPlayerSerial(admin)
	)
	
	return cMessages.outputConsole(message)
end

local function outputDBLog(admin, commandName, description)

	return cDB.exec(
		[[
		INSERT INTO command_logs (
			timestamp, command,
			serial, account, name, plain_name, groups,
			description
		) VALUES (?,?,?,?,?,?,?,?)
		]],
		getRealTime().timestamp, commandName,
		admin == console and "0" or getPlayerSerial(admin),
		getPlayerAccountName(admin) or nil,
		getPlayerName(admin), getPlayerName(admin, true),
		toJSON(getAdminGroups(admin)),
		description
	)
end

local argParsers = {

	["s"] = function(arg) return arg end,
	["n"] = function(arg) return tonumber(arg) end,
	["b"] = function(arg) return arg == "yes" end,
	["nil"] = function(arg) return arg == "none" end,
	["s-"] = function(args) return table.concat(args, " ") end,
	["ts-"] = function(args) return args end,
	["tn-"] = function(args)
		for i, arg in ipairs(args) do
			args[i] = tonumber(arg)
			if not args[i] then return false end
		end
		return args
	end,

	["se"] = function(arg) return isValidSerial(arg) and utf8.upper(arg) end,
	["ip"] = function(arg) return isValidIP(arg) and arg end,
	["du"] = function(arg) return parseDuration(arg) end,
	["byte"] = function(arg)
		arg = tonumber(arg)
		if not arg then return false end
		return arg >= 0 and arg <= 255 and arg
	end,

	["P"] = function(arg)
		local players = getPlayersByPartialName(arg)
		if not players then return false end
		if #players == 0 then return false end
		if #players > 1 then
			return false, #players.." players found"
		end
		return players[1]
	end,
	["T"] = function(arg) return getTeamFromName(arg) end,
	["R"] = function(arg) return getResourceFromName(arg) end,
	
	["ven"] = function(arg) return getVehicleModelFromPartialName(utf8.gsub(arg, "_", " ")) end,
	["wen"] = function(arg) return getWeaponIDFromPartialName(utf8.gsub(arg, "_", " ")) end,
	["skn"] = function(arg) return getPedModelFromPartialName(utf8.gsub(arg, "_", " ")) end,
	["fin"] = function(arg) return getFightingStyleFromPartialName(utf8.gsub(arg, "_", " ")) end,
	["wan"] = function(arg) return getWalkingStyleFromPartialName(utf8.gsub(arg, "_", " ")) end,
	["stn"] = function(arg) return getPedStatFromPartialName(utf8.gsub(arg, "_", " ")) end,
	["inn"] = function(arg) return getInteriorLocationFromPartialName(utf8.gsub(arg, "_", " ")) end,

	["wrn"] = function(arg) return getWeatherFromPartialName(utf8.gsub(arg, "_", " ")) end,
}

local function parseArgs(commandName, ...)

	local args = table.pack(...)
	local commandData = commandsData[commandName]
	local result = {}

	for i, variants in ipairs(commandData.types) do
		local arg = args[i]
		if not arg then
			if i >= commandData.opt then return result end
			return false, string.format("* Syntax: %s %s", commandName, commandData.syntax)
		end

		if utf8.match(variants[1], "-$") then
			arg = {}
			for ia = i, args.n do
				table.insert(arg, args[ia])
			end
		end

		local parsed, msg = false, nil
		local isFalse, isNil = false, false
		for iv, variant in ipairs(variants) do
			if variant == "b" and arg == "no" then
				isFalse = true
				parsed = false
			elseif variant == "nil" and arg == "none" then
				isNil = true
				parsed = nil
			else
				parsed, msg = argParsers[variant](arg)
			end
			if parsed or isNil or isFalse then break end
		end

		if not (parsed or isFalse or isNil) then
			msg = string.format("%s: invalid %s (arg #%d)", commandName, table.concat(commandData.names[i], "/")..(msg and " ("..msg..")" or ""), i)
			return false, msg
		end
		result[i] = parsed
	end

	return result
end

local function parseSyntax(pattern)

	local argTypes = {}
	local argNames = {}
	local optionalPos = 1
	local syntax = ""

	if not pattern then return argTypes, argNames, optionalPos, syntax end

	local args = split(pattern, ",")
	optionalPos = #args + 1
	for i, one in ipairs(args) do
		if utf8.match(one, "^%[") then
			one = utf8.gsub(one, "^%[", "")
			args[i] = one
			optionalPos = i
			syntax = syntax.."["
		end
		argTypes[i] = {}
		argNames[i] = {}
		syntax = syntax.."<"
		for iv, variant in ipairs(split(one, "|")) do
			local variantType = utf8.match(variant, ":(.+)$")
			if not argParsers[variantType] then error(string.format("parse syntax error: %s type not found", variantType), 3) end
			
			argTypes[i][iv] = variantType
			argNames[i][iv] = utf8.match(variant, "^(.+):")
		end
		syntax = syntax..table.concat(argNames[i], "/")..">"
		if i < #args then syntax = syntax.." " end
	end
	if optionalPos <= #args then
		syntax = syntax.."]"
	end

	return argTypes, argNames, optionalPos, syntax
end

local function mainHandler(admin, commandName, args)
	
	local commandData = commandsData[commandName] or hcCommandsData[commandName]
	if not commandData then return warn("command '"..commandName.."' handler not found", 1) and false end
 
	local result, resultMessage, publicMessage, playerMessage = commandData.handler(admin, table.unpack(args))
	if result == false then return cMessages.outputAdmin(commandName..": "..(resultMessage or "command failed"), admin, COLORS.red) and false end

	local player = args[1] and type(args[1]) == "userdata" and isElement(args[1]) and getElementType(args[1]) == "player" and args[1] or nil
	local outputResultMessage = resultMessage and true or false
	local logMessage = formatMessage(resultMessage or commandName.." executed successfully", admin, player)

	outputConsoleLog(admin, commandName, logMessage)
	outputDBLog(admin, commandName, logMessage)

	if resultMessage then
		cMessages.outputAdmin(formatMessage(resultMessage, admin, player), admin, COLORS.green)
	end
	if publicMessage and not cPersonalSettings.get(admin, "silent") then
		cMessages.outputPublic(formatMessage(publicMessage, admin, player), root, commandData.color or PUBLIC_MESSAGE_DEFAULT_COLOR)
	end
	if playerMessage and player then
		cMessages.outputPublic(formatMessage(playerMessage, admin, player), player, commandData.color or PUBLIC_MESSAGE_DEFAULT_COLOR)
	end

	return true
end

local function onServerCommand(admin, commandName, ...)
	if not hasObjectPermissionTo(admin, GENERAL_PERMISSION, false) then
		return cMessages.outputSecurity("COMMANDS: client $v doesn't have permission $v", admin, GENERAL_PERMISSION) and false
	end
	if not hasObjectPermissionTo(admin, "command."..commandName, false) then
		return cMessages.outputSecurity("COMMANDS: client $v doesn't have permission $v", admin, "command."..commandName) and false
	end
	if not commandsData[commandName] then return warn("command '"..commandName.."' handler not found", 1) and false end
	
	local args, msg = parseArgs(commandName, ...)
	if not args then return cMessages.outputAdmin(msg, admin, COLORS.red) and false end
	
	return mainHandler(admin, commandName, args)
end

local function onClientRequest(commandName, ...)
	local client = client
	if not client then return cMessages.outputSecurity("COMMANDS: client not found") and false end
	if source ~= client then return cMessages.outputSecurity("COMMANDS: source $v element is not equal client $v", source, client) and false end
	if not hasObjectPermissionTo(client, GENERAL_PERMISSION, false) then
		return cMessages.outputSecurity("COMMANDS: client $v doesn't have permission $v", client, GENERAL_PERMISSION) and false
	end
	if not hasObjectPermissionTo(client, "command."..commandName, false) then
		return cMessages.outputSecurity("COMMANDS: client $v doesn't have permission $v", client, "command."..commandName) and false
	end
	
	return mainHandler(client, commandName, table.pack(...))
end

cCommands = {}

function cCommands.init()

	cDB.exec([[
		CREATE TABLE IF NOT EXISTS command_logs (
			id          INTEGER PRIMARY KEY AUTOINCREMENT,
			timestamp   INTEGER NOT NULL,
			command     TEXT    NOT NULL,
			serial      TEXT    NOT NULL,
			account     TEXT    NOT NULL,
			name        TEXT    NOT NULL,
			plain_name  TEXT    NOT NULL,
			groups      TEXT    NOT NULL,
			description TEXT
		)
	]])

	local publicPermissions = getObjectPermissions("user.*", "command")

	for commandName, commandData in pairs(commandsData) do
		if table.index(publicPermissions, "command."..commandName) then
			cMessages.outputSecurity("COMMANDS: all users have permission to command $v (fix your ACL)", commandName)
		end
		addCommandHandler(commandName, onServerCommand, true, true)
	end
	for commandName, commandData in pairs(hcCommandsData) do
		if table.index(publicPermissions, "command."..commandName) then
			cMessages.outputSecurity("COMMANDS: all users have permission to hardcoded command $v (fix your ACL)", commandName)
		end
	end

	addEventHandler("gra.cCommands.execute", root, onClientRequest)

	return true
end

function cCommands.add(commandName, handlerFunction, pattern, description, color, aliases)
	if not scheck("s,f,?s[2],?t") then return false end
	if commandsData[commandName] then return warn("command '"..commandName.."' handler is already added", 2) and false end
	if hcCommandsData[commandName] then return warn("hardcoded command '"..commandName.."' handler is already added", 2) and false end

	local argTypes, argNames, optionalPos, syntax = parseSyntax(pattern)
	commandsData[commandName] = {
		handler = handlerFunction,
		types = argTypes,
		names = argNames,
		opt = optionalPos,
		syntax = syntax,
		desc = description,
		color = color,
		aliases = aliases
	}

	return true
end

-- need for client execute requests (see "gra.cCommands.execute" event)
function cCommands.addHardCoded(commandName, handlerFunction, color)
	if not scheck("s,f,?t") then return false end
	if hcCommandsData[commandName] then return warn("hardcoded command '"..commandName.."' handler is already added", 2) and false end
	if commandsData[commandName] then return warn("command '"..commandName.."' handler is already added", 2) and false end

	hcCommandsData[commandName] = {
		handler = handlerFunction,
		color = color,
	}

	return true
end

function cCommands.findLogs(filter, lastID)
	if not scheck("?t,?n") then return false end
	
	filter = filter or {}

	local query = cDB.prepare("SELECT * FROM command_logs WHERE id > ?", lastID or 0)
	if filter.since then query = query..cDB.prepare(" AND timestamp > ?", filter.since) end
	if filter.before then query = query..cDB.prepare(" AND timestamp < ?", filter.before) end
	if filter.command then query = query..cDB.prepare(" AND command LIKE ?", "%"..filter.command.."%") end
	if filter.serial then query = query..cDB.prepare(" AND serial LIKE ?", "%"..filter.serial.."%") end
	if filter.account then query = query..cDB.prepare(" AND account LIKE ?", "%"..filter.account.."%") end
	if filter.name then query = query..cDB.prepare(" AND plain_name LIKE ?", "%"..filter.name.."%") end
	if filter.group then query = query..cDB.prepare(" AND groups LIKE ?", "%"..filter.group.."%") end
	query = query..cDB.prepare(" LIMIT ?", FIND_LOGS_LIMIT)

	local result = cDB.query(query)
	if not result then return result end

	for i, row in ipairs(result) do
		row.groups = row.groups and fromJSON(row.groups) or nil
	end

	return result
end