
function formatGameTime(hours, minutes)
	if not scheck("n[2]") then return false end

	return string.format("%02d:%02d", hours, minutes)
end

function formatColor(r, g, b)
	if not scheck("?n[3]") then return false end

	return string.format("(%d, %d, %d)", r or 0, g or 0, b or 0)
end

function formatPosition(x, y, z)
	if not scheck("n[2],?n") then return false end

	return string.format(z and "(%.1f; %.1f; %.1f)" or "(%.1f; %.1f)", x, y, z)
end

function parseGameTime(str)
	if not scheck("s") then return false end
	if not utf8.match(str, "^%d*:?%d*$") then return false end

	local h, m = utf8.match(str, "^(%d*):?(%d*)$")
	if h == "" then h = nil end
	if m == "" then m = nil end

	h = h and tonumber(h)
	m = m and tonumber(m)

	return h, m
end

function formatNameID(name, id)
	if not scheck("s,?n|s") then return false end

	if not id then return name end

	return string.format("(%s) %s", tostring(id), name)
end

function isValidAccountPassword(s)
	if not scheck("s") then return false end

	local len = utf8.len(s)
	return len >= 1 and len <= 30 and s ~= "*****" 
end

local _getPlayerName = getPlayerName
function getPlayerName(player, strip, bleach)
	if not scheck("u:element:player|u:element:console|u:element:root,?b,?b") then return false end

	local name = (player == root or player == console) and "Console" or _getPlayerName(player)

	return (bleach and "#FFFFFF" or "")..(strip and stripColorCodes(name) or name)
end

function getPlayerFromPartialName(partialName)
	if not scheck("s") then return false end

	if partialName == "" then return false end

	local player = getPlayerFromName(partialName)
	if player then return player end

	partialName = stripColorCodes(partialName)
	local ignoreCasePartialName = utf8.lower(partialName)

	for i, p in ipairs(getElementsByType("player")) do
		local playerName = stripColorCodes(getPlayerName(p))
		if playerName == partialName then return p end
		if utf8.find(playerName, partialName, 1, true) then return p end

		local ignoreCasePlayerName = utf8.lower(playerName)
		if ignoreCasePlayerName == ignoreCasePartialName then return p end
		if utf8.find(ignoreCasePlayerName, ignoreCasePartialName, 1, true) then return p end
	end
	return nil
end

function getPlayersByPartialName(partialName)
	if not scheck("s") then return false end

	if partialName == "" then return false end

	local players = {}
	partialName = utf8.lower(stripColorCodes(partialName))
	for i, p in ipairs(getElementsByType("player")) do
		local playerName = utf8.lower(stripColorCodes(getPlayerName(p)))
		if utf8.find(playerName, partialName, 1, true) then
			players[#players + 1] = p
		end
	end
	return players
end

function getPositionFromElementOffset(element, offX, offY, offZ)
	if not scheck("u:element,n[3]") then return false end
	
	local m = getElementMatrix(element, false)
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z
end