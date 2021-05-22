
local styles = {
	[4] = "Default",
	[5] = "Boxing",
	[6] = "Kung Fu",
	[7] = "Knee-head",
	[15] = "Grab kick",
	[16] = "Elbows"
}

function getValidFightingStyles()

	local list = {}
	for style in pairs(styles) do
		list[#list + 1] = style
	end
	table.sort(list)
	
	return list
end

function isValidFightingStyle(style)
	if not scheck("n") then return false end

	return styles[style] and true or false
end

function getFightingStyleName(style)
	if not scheck("n") then return false end
	if not styles[style] then return warn("invalid fighting style", 2) and false end

	return styles[style]
end

function getFightingStyleFromPartialName(partialName)
	if not scheck("s") then return false end
	
	partialName = utf8.lower(partialName)
	for style, name in pairs(styles) do
		if utf8.find(utf8.lower(name), partialName, 1, true) then return style end
	end
	return nil
end