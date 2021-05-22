
function isValidSerial(serial)
	if not scheck("s") then return false end

	if utf8.len(serial) ~= 32 then return false end
	if not utf8.match(serial, "^%x+$") then return false end
	return true
end

function isValidIPv4(ip)
	if not scheck("s") then return false end

	if not utf8.match(ip, "^%d+%.%d+%.%d+%.%d+$") then return false end
	for chunk in utf8.gmatch(ip, "%d+") do
		if tonumber(chunk) > 255 then return false end
	end
	return true
end

function isValidIPv6(ip)
	if not scheck("s") then return false end

	if not utf8.match(ip, "^%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+$") then return false end
	for chunk in utf8.gmatch(ip, "%x+") do
		if tonumber(chunk, 16) > 65535 then return false end
	end
	return true
end

function isValidIP(ip)
	if not scheck("s") then return false end
	
	return isValidIPv4(ip)
end