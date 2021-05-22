
local validVehicleModels = {}
local invalidVehicleModels = {435, 449, 450, 537, 538, 569, 570, 584, 590, 591, 606, 607, 608}
for model = 400, 609 do
	if not table.index(invalidVehicleModels, model) then
		table.insert(validVehicleModels, model)
	end
end

local compatibleVehiclePaintjobs = {
	[483] = {0},		-- camper
	[534] = {0,1,2},	-- remington
	[535] = {0,1,2},	-- slamvan
	[536] = {0,1,2},	-- blade
	[558] = {0,1,2},	-- uranus
	[559] = {0,1,2},	-- jester
	[560] = {0,1,2},	-- sultan
	[561] = {0,1,2},	-- stratum
	[562] = {0,1,2},	-- elegy
	[565] = {0,1,2},	-- flash
	[567] = {0,1,2},	-- savanna
	[575] = {0,1},		-- broadway
	[576] = {0,1,2}		-- tornado
}

function getValidVehicleModels()	
	return table.copy(validVehicleModels)
end

function isValidVehicleModel(model)
	if not scheck("n") then return false end

	return table.index(validVehicleModels, model) and true or false
end

function getVehicleModelFromPartialName(partialName)
	if not scheck("s") then return false end

	local model = getVehicleModelFromName(partialName)
	if model then return model end

	partialName = utf8.lower(partialName)
	for i, model in ipairs(validVehicleModels) do
		if utf8.find(utf8.lower(getVehicleNameFromModel(model)), partialName, 1, true) then return model end
	end
	return nil
end

function getVehicleCompatiblePaintjobs(model)
	if not scheck("n|u:element:vehicle") then return false end
	if type(model) == "number" and not isValidVehicleModel(model) then return warn("invalid vehicle model", 2) and false end
	
	if type(model) == "userdata" then model = getElementModel(model) end

	return compatibleVehiclePaintjobs[model] or {}
end

function isVehicleUpgradeCompatible(model, upgrade)
	if not scheck("n|u:element:vehicle,n") then return false end
	if type(model) == "number" and not isValidVehicleModel(model) then return warn("invalid vehicle model", 2) and false end
	
	if type(model) == "userdata" then model = getElementModel(model) end

	return table.index(getVehicleCompatibleUpgrades(model), upgrade) and true or false
end

function getVehicleOneColor(vehicle, number)
	if not scheck("u:element:vehicle,n") then return false end
	if not (number >= 1 and number <= 4) then return warn("invalid vehicle color number", 2) and false end
	
	local colors = {getVehicleColor(vehicle, true)}
	return colors[(number-1)*3+1], colors[(number-1)*3+2], colors[(number-1)*3+3]
end

function setVehicleOneColor(vehicle, number, r, g, b)
	if not scheck("u:element:vehicle,n[4]") then return false end
	if not (number >= 1 and number <= 4) then return warn("invalid vehicle color number", 2) and false end
	
	local colors = {getVehicleColor(vehicle, true)}
	colors[(number-1)*3+1] = r
	colors[(number-1)*3+2] = g
	colors[(number-1)*3+3] = b
	
	return setVehicleColor(vehicle, unpack(colors))
end

function getVehicleFreePassengerSeat(vehicle)
	if not scheck("u:element:vehicle") then return false end
	
	local lastSeat = getVehicleMaxPassengers(vehicle)
	if lastSeat == 0 then return nil end

	local seatsState = {}
	for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
		seatsState[seat] = true
	end
	for seat = 1, lastSeat do
		if not seatsState[seat] then return seat end
	end
	return nil
end

function getVehicleOneOccupant(vehicle)
	if not scheck("u:element:vehicle") then return false end
	
	for i = 0, getVehicleMaxPassengers(vehicle) do
		local occupant = getVehicleOccupant(vehicle, i)
		if occupant then return occupant end
	end
	return nil
end