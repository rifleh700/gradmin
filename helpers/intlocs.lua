
local path = "conf/interiors.xml"
local locationsData = {}

local function loadData()
	local fileNode = xmlLoadFile(path, true)
	if not fileNode then return warn("interior locations conf file not found", 2) and false end 

	local fileData = xmlNodeGetData(fileNode)
	xmlUnloadFile(fileNode)

	for ig, groupData in ipairs(fileData.children) do
		for il, locationData in ipairs(groupData.children) do
			local data = {
				name = locationData.attributes.name,
				group = groupData.attributes.group,
				int = tonumber(locationData.attributes.interior),
				pos = {
					tonumber(locationData.attributes.posX),
					tonumber(locationData.attributes.posY),
					tonumber(locationData.attributes.posZ)
				},
				rot = tonumber(locationData.attributes.rot or 0)
			}
			table.insert(locationsData, data)
		end
	end
	return true
end
loadData()


function isValidInteriorLocation(id)
	if not scheck("n") then return false end

	return locationsData[id] and true or false
end

function getValidInteriorLocations()
	local locations = {}
	for id = 1, #locationsData do table.insert(locations, id) end
	return locations
end

function getValidInteriorLocationGroups()
	local groups = {}
	for id, data in ipairs(locationsData) do
		if not table.index(groups, data.group) then table.insert(groups, data.group) end
	end
	return table.sort(groups)
end

function getInteriorLocationName(id)
	if not scheck("n") then return false end
	if not locationsData[id] then return warn("invalid interior location", 2) and false end

	return locationsData[id].name
end

function getInteriorLocationGroup(id)
	if not scheck("n") then return false end
	if not locationsData[id] then return warn("invalid interior location", 2) and false end

	return locationsData[id].group
end

function getInteriorLocationInterior(id)
	if not scheck("n") then return false end
	if not locationsData[id] then return warn("invalid interior location", 2) and false end

	return locationsData[id].int
end

function getInteriorLocationPosition(id)
	if not scheck("n") then return false end
	if not locationsData[id] then return warn("invalid interior location", 2) and false end

	local x, y, z = unpack(locationsData[id].pos)
	return x, y, z, locationsData[id].rot 
end

function getInteriorLocationsByGroup(group)
	local locations = {}
	for id, data in ipairs(locationsData) do
		if data.group == group then table.insert(locations, id) end
	end
	return locations
end

function getInteriorLocationFromPartialName(partial)
	if not scheck("s") then return false end

	partial = utf8.lower(partial)
	for id, data in ipairs(locationsData) do
		if utf8.find(utf8.lower(data.name), partial, 1, true) then return id end
	end
	return nil
end