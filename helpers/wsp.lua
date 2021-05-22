
local wspsData = {
	{nid = "hovercars", name = "Hover Cars"},
	{nid = "aircars", name = "Air Cars"},
	{nid = "extrabunny", name = "Extra Bunny"},
	{nid = "extrajump", name = "Extra Jump"},
	{nid = "randomfoliage", name = "Random Foliage", default = true},
	{nid = "snipermoon", name = "Sniper Moon"},
	{nid = "extraairresistance", name = "Extra Air Resistance", default = true},
	{nid = "underworldwarp", name = "Under World Warp", default = true},
}

function getValidWorldSpecialProperties()
	local list = {}
	for i, data in ipairs(wspsData) do
		table.insert(list, data.nid)
	end
	return list
end

function isValidWorldSpecialProperty(property)
	if not scheck("s") then return false end

	for i, data in ipairs(wspsData) do
		if data.nid == property then return true end
	end
	return false
end

function getWorldSpecialPropertyName(property)
	if not scheck("s") then return false end

	for i, data in ipairs(wspsData) do
		if data.nid == property then return data.name end
	end

	return warn("invalid world special property", 2) and false
end

function getWorldSpecialPropertyDefault(property)
	if not scheck("s") then return false end

	for i, data in ipairs(wspsData) do
		if data.nid == property then return data.default == true end
	end

	return warn("invalid world special property", 2) and false
end