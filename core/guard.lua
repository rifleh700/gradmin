
local protectedEvents = {}
local protectedHandlers = {}

local function wrap(handler)

	if not protectedHandlers[handler] then
		protectedHandlers[handler] = function(...)
			if sourceResource and sourceResource ~= getThisResource() then
				return cMessages.outputSecurity("resource $v tried to get access event $v (access denied)", getResourceName(sourceResource), eventName) and false
			end
			
			handler(...)

		end
	end

	return protectedHandlers[handler]
end

local _addEvent = addEvent
function addEvent(event, ...)
	if not _addEvent(event, ...) then return false end

	table.insert(protectedEvents, event)

	return true
end

local _addEventHandler = addEventHandler
function addEventHandler(event, element, handler, ...)
	if not scheck("s,u:element,f") then return false end

	handler = table.index(protectedEvents, event) and wrap(handler) or handler

	if not _addEventHandler(event, element, handler, ...) then
		return warn("addEventHandler call failed", 2) and false
	end

   	return true
end

local _removeEventHandler = removeEventHandler
function removeEventHandler(event, element, handler)
	if not scheck("s,u:element,f") then return false end

	handler = table.index(protectedEvents, event) and wrap(handler) or handler
	
	return _removeEventHandler(event, element, handler)
end
