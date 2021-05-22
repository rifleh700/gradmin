
local REQUEST_URL = "https://ip2c.org/"
local UNKNOWN_ISO = "ZZ"
local UNKNOWN_NAME = "Unknown"

addEvent("onIPCountryDetect", false)
addEvent("onPlayerCountryDetect", false)

mIP2C = {}

mIP2C.playerCountries = {}

function mIP2C.init()
	
	addEventHandler("onPlayerJoin", root, mIP2C.onPlayerJoin)
	addEventHandler("onPlayerQuit", root, mIP2C.onPlayerQuit)

	for i, player in ipairs(getElementsByType("player")) do
		mIP2C.requestPlayerCountry(player)
	end

	return true
end

cModules.register(mIP2C)

function mIP2C.parse(response)
		
	local result, iso, iso3, name = table.unpack(utf8.split(response, ";"))
	if result ~= "1" then return UNKNOWN_ISO, UNKNOWN_NAME end
	
	return iso, name
end

function mIP2C.ipCallback(response, info, ip, tag)
	if not info.success then return end

	local iso, name = mIP2C.parse(response)
	triggerEvent("onIPCountryDetect", root, ip, iso, name, tag)

end

function mIP2C.playerCallback(response, info, player)
	if not info.success then return end
	if not isElement(player) then return end

	local iso, name = mIP2C.parse(response)
	mIP2C.playerCountries[player] = {iso, name}
	triggerEvent("onPlayerCountryDetect", player, iso, name)

end

function mIP2C.requestPlayerCountry(player)
	
	fetchRemote(REQUEST_URL..getPlayerIP(player), {}, mIP2C.playerCallback, {player})

end

function mIP2C.onPlayerJoin()
	
	mIP2C.requestPlayerCountry(source)

end

function mIP2C.onPlayerQuit()
	
	mIP2C.playerCountries[source] = nil

end

function requestIPCountry(ip, tag)
	if not scheck("s") then return false end
	if not isValidIP(ip) then return warn("invalid IP", 2) and false end

	return fetchRemote(REQUEST_URL..ip, {}, mIP2C.ipCallback, {ip, tag})
end

function getPlayerCountry(player)
	if not scheck("u:element:player") then return false end

	local data = mIP2C.playerCountries[player]
	if not data then return nil end

	return data[1], data[2]
end