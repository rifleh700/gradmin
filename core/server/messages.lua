
local DEBUG_PREFIX = "INFO: GRADMIN: "
local CONSOLE_PREFIX = "GRADMIN: "
local PUBLIC_PREFIX = "[Admin] "
local ADMIN_PREFIX = "[gradmin] "
local SECURITY_PREFIX = "SECURITY: "


cMessages = {}

local function formatMessage(message, color)
	
	local hexColor = rgb2hexs(table.unpack(color))
	message = hexColor..utf8.gsub(message, "[^%s]*#%x%x%x%x%x%x[^%s]+", "#FFFFFF%1"..hexColor)
	
	return message
end

local function formatSecurityMessage(message, ...)
	
	local data = table.pack(...)

	local i = 0
	message = utf8.gsub(message, "%$v",
		function()
			i = i + 1
			return data[i] ~= nil and inspect(data[i]) or NIL_TEXT
		end
	)

	return message
end

function cMessages.outputPublic(message, element, color)
	if not scheck("s,?u:element:player|u:element:root,?t") then return false end
	
	color = color or COLORS.white
	message = formatMessage(PUBLIC_PREFIX..message, color)

	local r, g, b = table.unpack(color)
	return outputChatBox(message, element, r, g, b, true)
end

function cMessages.outputAdmin(message, element, color)
	if not scheck("s,u:element:player|u:element:console,?t") then return false end

	message = ADMIN_PREFIX..message

	if element == console then return outputServerLog(stripColorCodes(message)) end

	color = color or COLORS.white
	message = formatMessage(message, color)

	local r, g, b = table.unpack(color)
	return outputChatBox(message, element, r, g, b, true)
end

function cMessages.outputConsole(message)
	if not scheck("s") then return false end

	return outputServerLog(CONSOLE_PREFIX..message)
end

function cMessages.outputDebug(message, color)
	if not scheck("s,?t") then return false end

	return outputDebugString(DEBUG_PREFIX..message, 4, table.unpack(color or COLORS.white))
end

function cMessages.outputSecurity(message, ...)
	if not scheck("s") then return false end

	message = SECURITY_PREFIX..formatSecurityMessage(message, ...)
	cMessages.outputDebug(message, COLORS.purple)
	return true
end