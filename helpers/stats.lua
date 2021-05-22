
local path = "conf/stats.xml"
local statsData = {}

local function loadData()
	local fileNode = xmlLoadFile(path, true)
	if not fileNode then return warn("skins conf file not found", 2) and false end 

	local fileData = xmlNodeGetData(fileNode)
	xmlUnloadFile(fileNode)

	for ig, groupData in ipairs(fileData.children) do
		for is, statData in ipairs(groupData.children) do
			local id = tonumber(statData.attributes.id)
			statsData[id] = {
				name = statData.attributes.name,
				shortname = statData.attributes.shortname,
				group = groupData.attributes.name
			}
		end
	end
	return true
end
loadData()

function isValidPedStat(id)
	if not scheck("n") then return false end

	return statsData[id] and true or false
end

function getValidPedStats()

	local stats = {}
	for id in pairs(statsData) do
		stats[#stats + 1] = id
	end
	table.sort(stats)

	return stats
end

function getValidPedStatsByGroup(group)
	if not scheck("s") then return false end

	group = utf8.lower(group)

	local stats = {}
	for id, data in pairs(statsData) do
		if utf8.lower(data.group) == group then stats[#stats + 1] = id end
	end
	table.sort(stats)
	
	return stats
end

function getPedStatName(id)
	if not scheck("n") then return false end
	if not statsData[id] then return warn("invalid ped stat", 2) and false end

	return statsData[id].name
end

function getPedStatShortName(id)
	if not scheck("n") then return false end
	if not statsData[id] then return warn("invalid ped stat", 2) and false end

	return statsData[id].shortname
end

function getPedStatGroup(id)
	if not scheck("n") then return false end
	if not statsData[id] then return warn("invalid ped stat", 2) and false end

	return statsData[id].group
end

function getPedStatFromPartialName(partial)
	if not scheck("s") then return false end

	partial = utf8.lower(partial)
	for id, data in pairs(statsData) do
		if utf8.find(utf8.lower(data.shortname), partial, 1, true) then return id end
	end
	return nil
end