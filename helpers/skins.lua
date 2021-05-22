
local path = "conf/skins.xml"
local skinsData = {}

local function loadData()
	local fileNode = xmlLoadFile(path, true)
	if not fileNode then return warn("skins conf file not found", 2) and false end 

	local fileData = xmlNodeGetData(fileNode)
	xmlUnloadFile(fileNode)

	for i, skinData in ipairs(fileData.children) do
		local model = tonumber(skinData.attributes.model)
		skinsData[model] = {
			name = skinData.attributes.name,
			groups = split(skinData.attributes.groups, ","),
			walking = tonumber(skinData.attributes.walking)
		}
	end
	return true
end
loadData()

function isValidPedModel(model)
	if not scheck("n") then return false end

	return skinsData[model] and true or false
end

function getPedModelName(model)
	if not scheck("n") then return false end
	if not skinsData[model] then return warn("invalid ped model", 2) and false end

	return skinsData[model].name
end

function getPedModelFromPartialName(partialName)
	if not scheck("s") then return false end

	partialName = utf8.lower(partialName)
	for model, data in pairs(skinsData) do
		if utf8.find(utf8.lower(data.name), partialName, 1, true) then return model end
	end
	return nil
end

function getPedModelGroups(model)
	if not scheck("n") then return false end
	if not skinsData[model] then return warn("invalid ped model", 2) and false end

	return skinsData[model].groups
end

function getPedModelWalkingStyle(model)
	if not scheck("n") then return false end
	if not skinsData[model] then return warn("invalid ped model", 2) and false end
	
	return skinsData[model].walking
end