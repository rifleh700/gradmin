
local PARSE_DATE_FORMAT = {
	{"year", "Y", 1970, 9999},
	{"month", "M", 1, 12},
	{"day", "D", 1, 31},
	{"hour", "h", 0, 23},
	{"min", "m", 0, 59},
	{"sec", "s", 0, 59}
}

function parseDuration(str)
	if not scheck("s") then return false end

	str = str
		:lower()
		:gsub("permanent", "perm")
		:gsub("mseconds?", "ms")
		:gsub("msecs?", "ms")
		:gsub("seconds?", "s")
		:gsub("secs?", "s")
		:gsub("minutes?", "m")
		:gsub("mins?", "m")
		:gsub("hours?", "h")
		:gsub("days?", "d")
		:gsub("weeks?", "w")

	if utf8.match(str, "perm") then return 0 end

	str = utf8.gsub(str, "%s", "")
	if not utf8.match(str, "^%d+[%dsmhdw]*[smhdw]$") then return false end

	local seconds = 0
	local sbyt = {ms = 0.001, s = 1, m = 60, h = 60*60, d = 60*60*24, w = 60*60*24*7}
	for n, t in utf8.gmatch(str, "(%d+)([smhdw]+)") do
		seconds = seconds + tonumber(n) * sbyt[t]
	end
	return seconds
end

function formatDuration(seconds, simple)
	if not scheck("n,?b") then return false end

	if seconds == 0 then return "permanent" end

	seconds = math.round(math.abs(seconds), 3)

	local result = ""
	local ts = { {"day", 60*60*24}, {"hour", 60*60}, {"min", 60}, {"sec", 1}, {"msec", 0.001} }
	for _, data in ipairs(ts) do
		local t = math.floor(seconds/data[2])
		if t > 0 then
			seconds = math.round(seconds % data[2], 3)
			result = result..t.." "..data[1]..(t > 1 and "s" or "").." "
			if simple then break end
		end
	end

	return utf8.trim(result)
end

function parseDate(str)
	if not scheck("s") then return false end

	local current = os.date("*t")

	local date = {}
	local found = false
	for i, data in ipairs(PARSE_DATE_FORMAT) do
		local n = utf8.match(str, data[2].."(%d+)")
		if n then
			date[data[1]] = math.clamp(tonumber(n), data[3], data[4])
			found = true
		else
			date[data[1]] = found and data[3] or current[data[1]]
		end
	end

	return os.time(date)
end