
function getResourceSetting(resource, setting)
	if not scheck("?u:resource-data,s") then return false end

	resource = resource or getThisResource()

	local resourceName = getResourceName(resource)
	local types = {"boolean", "number", "string", "table"}
	local value = get(resourceName.."."..setting)

	if not table.index(types, type(value)) then return nil end

	return value
end

function getResourceSettingsData(resource)
	if not scheck("?u:resource-data") then return false end

	if not resource then resource = getThisResource() end

	local resourceName = getResourceName(resource)
	local rawsettings = get("*"..resourceName..".")

	if not rawsettings then return {} end

	local settings = {}
	local types = {"boolean", "number", "string", "table"}
	for rawname, value in pairs(rawsettings) do
		if table.index(types, type(value)) then
			rawname = utf8.gsub(rawname, "[%*%#%@](.*)", "%1")
			local name = utf8.gsub(rawname, resourceName.."%.(.*)", "%1")

			if settings[name] == nil then settings[name] = {} end
			if rawname == name then
				settings[name].default = value
			else
				settings[name].current = value
			end
		end
	end

	local result = {}
	for name, value in pairs(settings) do
		if value.default ~= nil then
			local data = {}
			data.default = value.default
			data.current = value.default
			if value.current ~= nil then
				data.current = value.current
			end
			data.friendlyname	= get(resourceName.."."..name..".friendlyname")
			data.group			= get(resourceName.."."..name..".group")
			data.accept			= get(resourceName.."."..name..".accept")
			data.examples		= get(resourceName.."."..name..".examples")
			data.desc			= get(resourceName.."."..name..".desc")
			result[name] = data
		end
	end

	return result
end

function getResourceNameFromSetting(setting)
	if not scheck("s") then return false end
	
	return utf8.match(setting, "^[%*%#%@]?(.+)%..+")
end

local defaultInfoAttributes = {
	"name",
	"type",
	"author",
	"version",
	"description"
}

local _getResourceInfo = getResourceInfo

function getResourceInfo(resource, attribute)
	if not scheck("?u:resource-data,?s") then return false end

	if not resource then resource = getThisResource() end
	if not attribute then
		local info = {}
		for i, attribute in ipairs(defaultInfoAttributes) do
			info[attribute] = _getResourceInfo(resource, attribute) or nil
		end
		return info
	end

	return _getResourceInfo(resource, attribute)
end