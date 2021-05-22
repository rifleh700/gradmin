
local path = "conf/weathers.xml"
local weathersData = {}

local function loadData()
	local fileNode = xmlLoadFile(path, true)
	if not fileNode then return warn("weathers conf file not found", 2) and false end 

	local fileData = xmlNodeGetData(fileNode)
	xmlUnloadFile(fileNode)

	for i, weatherData in ipairs(fileData.children) do
		local id = tonumber(weatherData.attributes.id)
		weathersData[id] = weatherData.attributes.name
	end
	return true
end
loadData()

function getValidWeathers()
	
	local weathers = {}
	for i = 0, 255 do
		weathers[i+1] = i
	end
	return weathers
end

function isValidWeather(id)
	if not scheck("n") then return false end

	if math.floor(id) ~= id then return false end

	return id >= 0 and id <= 255 
end

function getWeatherName(id)
	if not scheck("n") then return false end
	if not isValidWeather(id) then return warn("invalid weather", 2) and false end

	return weathersData[id] or "Unknown"
end

function getWeatherFromPartialName(partialName)
	if not scheck("s") then return false end
	
	partialName = utf8.lower(partialName)
	for id, name in pairs(weathersData) do
		if utf8.find(utf8.lower(name), partialName, 1, true) then return id end
	end
	return nil
end

