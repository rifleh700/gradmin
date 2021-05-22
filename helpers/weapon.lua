
local validWeaponIDs = {
	1, 2, 3, 4, 5, 6, 7, 8, 9,
	22, 23, 24,
	25, 26, 27,
	28, 29, 32,
	30, 31,
	33, 34,
	35, 36, 37, 38,
	16, 17, 18, 39,
	41, 42, 43,
	10, 11, 12, 14, 15,
	44, 45, 46
}

function getValidWeaponIDs()
	return table.copy(validWeaponIDs)
end

function isValidWeaponID(id)
	if not scheck("n") then return false end

	return table.index(validWeaponIDs, id) and true or false
end

function getWeaponIDFromPartialName(partialName)
	if not scheck("s") then return false end
	
	local id = getWeaponIDFromName(partialName)
	if id then return id end

	partialName = utf8.lower(partialName)
	for i, id in ipairs(validWeaponIDs) do
		if utf8.find(utf8.lower(getWeaponNameFromID(id)), partialName, 1, true) then return id end
	end
	return nil
end