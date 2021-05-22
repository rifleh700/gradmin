
local DEFAULT_BANDWIDTH = 100 * 10^3
local LATENT_BANDWIDTH = 50 * 10^3

addEvent("gra.cSync.request", true)
addEvent("gra.cSync.gui", true)

local activeClients = {}
local keyPermissions = {}
local keyResponders = {}
local keyOptions = {}

cSync = {}

function cSync.register(key, permission, options)
	check("s,?s,?t")
	if permission and not aclIsValidRight(permission) then error("invalid permission format", 2) end
	if keyPermissions[key] then return warn("key '"..key.."' is already registered", 2) and false end

	keyPermissions[key] = permission or GENERAL_PERMISSION

	options = options or {}
	keyOptions[key] = {}
	keyOptions[key].heavy = options.heavy and true or nil
	keyOptions[key].irregular = options.irregular and true or nil

	return true
end

function cSync.registerResponder(key, responder, options)
	if not scheck("s,f,?t") then return false end
	if not keyPermissions[key] then return warn("permission for '"..key.."' not found", 2) and false end
	if keyResponders[key] then return warn("responder for '"..key.."' is already registered", 2) and false end
	
	keyResponders[key] = responder

	options = options or {}
	keyOptions[key].auto = options.auto and true or nil
	
	return true
end

function cSync.send(element, key, ...)
	if not scheck("u:element:player|u:element:root,s") then return false end
	if not keyPermissions[key] then return warn("permission for '"..key.."' not found", 2) and false end

	if element ~= root and not hasObjectPermissionTo(element, keyPermissions[key]) then
		return warn(
			string.format(
				"client '%s' doesn't have permission '%s' for '%s'",
				getPlayerName(element), keyPermissions[key], key
			), 2
		) and false
	end

	local irregular = keyOptions[key].irregular
	local bandwidth = keyOptions[key].heavy and LATENT_BANDWIDTH or DEFAULT_BANDWIDTH
	local data = table.pack(...)

	local players = element == root and cSessions.getAdmins(keyPermissions[key]) or {element}
	for i, player in ipairs(players) do
		if irregular and activeClients[player] or (not irregular) then 
			triggerLatentClientEvent(player, "gra.Sync.send", bandwidth, player, false, key, data)
		end
	end

	return true
end

function cSync.callResponder(element, key, ...)
	if not scheck("u:element:player|u:element:root,s") then return false end
	if not keyResponders[key] then return warn("responder for '"..key.."' not found", 2) and false end
	
	return
		select("#", ...) == 0 and
		cSync.send(element, key, keyResponders[key]()) or
		cSync.send(element, key, ..., keyResponders[key](...))
end

local function getResult(args, f)
	if args.n == 0 then return table.pack(f()) end

	local result = table.pack(f(table.unpack(table.copydeep(args))))
	
	for i = 1, result.n do
		args[args.n + i] = result[i]
	end
	args.n = args.n + result.n

	return args
end

addEventHandler("gra.cSync.gui", root,
	function(state)
		local client = client
		if not client then return cMessages.outputSecurity("SYNC: client not found") and false end
		if source ~= client then return cMessages.outputSecurity("SYNC: source $v element is not equal client $v", source, client) and false end

		activeClients[client] = state or nil
		
		if not state then return end

		for key, options in pairs(keyOptions) do
			if options.auto and hasObjectPermissionTo(client, keyPermissions[key]) then
				cSync.send(client, key, keyResponders[key]())
			end
		end

	end
)

addEventHandler("gra.cSync.request", root,
	function(tag, key, data)
		local client = client
		if not client then return cMessages.outputSecurity("SYNC: client not found") and false end
		if source ~= client then return cMessages.outputSecurity("SYNC: source $v element is not equal client $v", source, client) and false end
		if not keyPermissions[key] then return cMessages.outputSecurity("SYNC: permission for $v not found (client: $v)", key, client) and false end
		if not hasObjectPermissionTo(client, keyPermissions[key]) then
			return cMessages.outputSecurity("SYNC: client $v doesn't have permission $v for $v", client, keyPermissions[key], key) and false
		end

		if not keyResponders[key] then return warn(eventName..": responder for '"..key.."'' not found", 0) and false end
	
		triggerLatentClientEvent(
			client, "gra.Sync.send",
			keyOptions[key].heavy and LATENT_BANDWIDTH or DEFAULT_BANDWIDTH,
			client,
			tag, key, getResult(data, keyResponders[key])
		)

	end
)

addEventHandler("onPlayerQuit", root,
	function()

		activeClients[source] = nil
	
	end
)