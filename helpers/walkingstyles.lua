
local styles = {
	[0] = "Default",
	[54] = "Carl Johnson",
	[55] = "Fat Carl Johnson",
	[56] = "Muscle Carl Johnson",
	[57] = "Carl Johnson (Rocket launcher)",
	[58] = "Fat Carl Johnson (Rocket launcher)",
	[59] = "Muscle Carl Johnson (Rocket launcher)",
	[60] = "Carl Johnson (Armed)",
	[61] = "Fat Carl Johnson (Armed)",
	[62] = "Muscle Carl Johnson (Armed)",
	[63] = "Carl Johnson (Bat)",
	[64] = "Fat Carl Johnson (Bat)",
	[65] = "Muscle Carl Johnson (Bat)",
	[66] = "Carl Johnson (Chainsaw)",
	[67] = "Fat Carl Johnson (Chainsaw)",
	[68] = "Muscle Carl Johnson (Chainsaw)",
	[69] = "Sneaking",
	[70] = "JetPack",
	[118] = "Man",
	[119] = "Shuffle",
	[120] = "Old man",
	[121] = "Gang 1",
	[122] = "Gang 2",
	[123] = "Old fat man",
	[124] = "Fat man",
	[125] = "Jogger",
	[126] = "Drunk man",
	[127] = "Blind man",
	[128] = "SWAT",
	[129] = "Woman",
	[130] = "Shopping",
	[131] = "Busy woman",
	[132] = "Sexy woman",
	[133] = "Pro",
	[134] = "Old woman",
	[135] = "Fat woman",
	[136] = "Jog woman",
	[137] = "Old fat woman",
	[138] = "Skates",
}

function getValidWalkingStyles()
	
	local list = {}
	for style in pairs(styles) do
		table.insert(list, style)
	end
	table.sort(list)

	return list
end

function isValidWalkingStyle(style)
	if not scheck("n") then return false end

	return styles[style] and true or false
end

function getWalkingStyleName(style)
	if not scheck("n") then return false end
	if not styles[style] then return warn("invalid walking style", 2) and false end

	return styles[style]
end

function getWalkingStyleFromPartialName(partialName)
	if not scheck("s") then return false end
	
	partialName = utf8.lower(partialName)
	for style, name in pairs(styles) do
		if utf8.find(utf8.lower(name), partialName, 1, true) then return style end
	end
	return nil
end