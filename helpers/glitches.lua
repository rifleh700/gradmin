
local glitchesData = {
	{"quickreload", "Quick reload"},
	{"fastmove", "Fast move"},
	{"fastfire", "Fast fire"},
	{"crouchbug", "Crouch bug"},
	{"highcloserangedamage", "High close range damage"},
	{"hitanim", "Hit anim"},
	{"fastsprint", "Fast sprint"},
	{"baddrivebyhitbox", "Bad driveby hit box"},
	{"quickstand", "Quick stand"},
	{"kickoutofvehicle_onmodelreplace", "Kick out of vehicle on model replace"},
}

function getValidGlitches()
	local list = {}
	for i, data in ipairs(glitchesData) do
		table.insert(list, data[1])
	end
	return list
end

function isValidGlitch(glitch)
	if not scheck("s") then return false end

	for i, data in ipairs(glitchesData) do
		if data[1] == glitch then return true end
	end
	return false
end

function getGlitchName(glitch)
	if not scheck("s") then return false end

	for i, data in ipairs(glitchesData) do
		if data[1] == glitch then return data[2] end
	end

	return warn("invalid glitch", 2) and false
end

function getGlitchFromPartialName(partialName)
	if not scheck("s") then return false end

	partialName = utf8.lower(partialName)
	for i, data in ipairs(glitchesData) do
		if utf8.find(utf8.lower(data[2]), partialName, 1, true) then return data[1] end
	end
	return nil
end