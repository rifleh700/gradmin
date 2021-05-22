
local coroutedHandlers = {}
local function coroute(f)

	if not coroutedHandlers[f] then
		coroutedHandlers[f] = function(...) coroutine.resume(coroutine.create(f), ...) end
	end
	return coroutedHandlers[f]
end

local _addEventHandler = addEventHandler
function addEventHandler(event, element, handler, ...)
	if not scheck("s,u:element,f") then return false end

	if not _addEventHandler(event, element, coroute(handler), ...) then
		return warn("addEventHandler call failed", 2) and false
	end

   	return true
end

local _removeEventHandler = removeEventHandler
function removeEventHandler(event, element, handler)
	if not scheck("s,u:element,f") then return false end
	
	return _removeEventHandler(event, element, coroutedHandlers[handler] or handler)
end

local _addCommandHandler = addCommandHandler
function addCommandHandler(commandName, handler, ...)
	if not scheck("s,f") then return false end

	if not _addCommandHandler(commandName, coroute(handler), ...) then
		return warn("addCommandHandler call failed", 2) and false
	end

	return true
end

local _removeCommandHandler = removeCommandHandler
function removeCommandHandler(commandName, handler)
	if not scheck("s,?f") then return false end

	if not handler then return _removeCommandHandler(commandName) end

	return removeCommandHandler(commandName, coroute(handler))
end

