
local path = "conf/upgrades.xml"
local upgradesData = {}

local function loadData()
	local fileNode = xmlLoadFile(path, true)
	if not fileNode then return warn("vehicle upgrades conf file not found", 2) and false end 

	local fileData = xmlNodeGetData(fileNode)
	xmlUnloadFile(fileNode)

	for i, upgradeData in ipairs(fileData.children) do
		local id = tonumber(upgradeData.attributes.id)
		upgradesData[id] = upgradeData.attributes.name
	end
	return true
end
loadData()

function getValidVehicleUpgrades()
	local ids = {}
	for id in pairs(upgradesData) do
		table.insert(ids, id)
	end
	return table.sort(ids)
end

function getValidVehicleUpgradeSlots()
	
	local slots = {}
	for i = 1, 17 do
		slots[i] = i - 1
	end
	return slots
end

function isValidVehicleUpgrade(id)
	if not scheck("n") then return false end

	return upgradesData[id] and true or false
end

function getVehicleUpgradeName(id)
	if not scheck("n") then return false end
	if not upgradesData[id] then return warn("invalid vehicle upgrade", 2) and false end

	return upgradesData[id]
end

function getVehicleUpgradeFullName(id)
	if not scheck("n") then return false end
	if not upgradesData[id] then return warn("invalid vehicle upgrade", 2) and false end
	
	return getVehicleUpgradeSlotName(id).." "..upgradesData[id]
end