
local FILE_PATH = DATA_PATH.."settings.xml"

local file = nil
local cache = {}

local remoteSettings = {
	"silent",
	"anonymous"
}

cSettings = {}

function cSettings.init()
	
	file = xmlLoadFile(FILE_PATH) or xmlCreateFile(FILE_PATH, "settings")
	xmlSaveFile(file)
	
	cache = {}
	local data = xmlNodeGetData(file)
	for i, child in ipairs(data.children) do
		cache[child.attributes.name] = fromJSON(child.attributes.value)
	end

	for i, setting in ipairs(remoteSettings) do
		triggerServerEvent("gra.cPersonalSettings.set", localPlayer, setting, cache[setting])
	end

	return true
end

addEventHandler("onClientResourceStart", resourceRoot, cSettings.init)

function cSettings.get(setting)
	if not scheck("s") then return false end

	return cache[setting]
end

function cSettings.set(setting, value)
	if not scheck("s,?b|n|s|t") then return false end

	cache[setting] = value

	local node = xmlFindChildByAttribute(file, "setting", "name", setting)
	if not node then
		node = xmlCreateChild(file, "setting")
		xmlNodeSetAttribute(node, "name", setting)
	end

	xmlNodeSetAttribute(node, "value", toJSON(value))      
	xmlSaveFile(file)

	if table.index(remoteSettings, setting) then
		triggerServerEvent("gra.cPersonalSettings.set", localPlayer, setting, value)
	end

	return true
end
