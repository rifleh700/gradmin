
addEvent("gra.Sync.send", true)

local handlers = {}
local requested = {}

cSync = {}

function cSync.addHandler(key, f)
	if not scheck("s,f") then return false end
	
	if not handlers[key] then handlers[key] = {} end
	if table.index(handlers[key], f) then return warn("handler for '"..key.."' is already added", 2) and false end

	table.insert(handlers[key], f)

	return true  
end

function cSync.removeHandler(key, f)
	if not scheck("s,f") then return false end
	if not (handlers[key] and table.index(handlers[key], f)) then
		return warn("handler for '"..key.."' not found", 2) and false
	end

	return table.removevalue(handlers[key], f) and true or false
end

addEventHandler("gra.cGUI.onSwitch", guiRoot,
	function(state)
		triggerServerEvent("gra.cSync.gui", localPlayer, state)
	end
)

addEventHandler("gra.Sync.send", localPlayer,
	function(tag, key, data)
		if sourceResource then return warn(eventName..": invalid source resource for '"..tostring(key).."'", 0) and false end
		
		if not cMain.isInitialized() then return end
		if not handlers[key] then return warn(eventName..": handlers for '"..tostring(key).."' not found", 0) and false end

		if tag then requested[tag] = nil end

		for i, f in ipairs(handlers[key]) do
			f(table.unpack(data))
		end

	end
)

function cSync.request(key, ...)
	if not scheck("s") then return false end
	if not handlers[key] then return warn("handlers for '"..key.."'' not found", 2) and false end

	local tag = crc32(key, ...)
	if requested[tag] then return false end

	requested[tag] = true

	return triggerServerEvent("gra.cSync.request", localPlayer, tag, key, table.pack(...))
end