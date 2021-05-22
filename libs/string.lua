
function utf8.literalize(s)
	check("s")

	return utf8.gsub(s, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
end

local _rep = string.rep
function string.rep(s, n, sep)
	check("s,n,?s")

	return
		n < 1 and "" or
		n < 2 and s or
		_rep(s..(sep or ""), n - 1)..s
end

function utf8.split(s, sep, limit, plain)
	check("s,?s,?n,?b")

	if limit and limit < 1 then return {} end
	if s == "" then return {""} end

	sep = sep or ""
	sep = plain and utf8.literalize(sep) or sep

	local t = {}
	local i = 1
	for v in utf8.gmatch(s, sep == "" and "." or "([^"..sep.."]+)") do
        t[i] = v
        if limit and i == limit then break end
    	i = i + 1
    end

	return t
end

function utf8.trim(s)
	check("s")

	s = utf8.gsub(s, "^%s*(.-)%s*$", "%1")
	return s
end

function utf8.upperf(s)
	check("s")

	s = utf8.gsub(s, "^%l", utf8.upper)
	return s
end

local _find = utf8.find
function utf8.find(s, pattern, init, plain, soft)
	check("s[2],?n,?b[2]")
	
	if soft then
		s = utf8.lower(utf8.trim(s))
		pattern = utf8.lower(utf8.trim(pattern))
	end

	return _find(s, pattern, init, plain)
end

function utf8.insert(str1, str2, pos)
	check("s[2],?n")

	pos = pos or (#str1 + 1)

    return utf8.sub(str1, 0, pos - 1)..str2..utf8.sub(str1, pos)
end

-- https://gist.github.com/Badgerati/3261142
function utf8.levenshtein(str1, str2)
	check("s[2]")
	
	if str1 == str2 then return 0 end

	local len1 = utf8.len(str1)
	local len2 = utf8.len(str2)
	if len1 == 0 then return len2 end
	if len2 == 0 then return len1 end

	local matrix = {}
	for i = 0, len1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2 do
		matrix[0][j] = j
	end
	
	local cost = 0
	for i = 1, len1 do
		for j = 1, len2 do
			if str1:byte(i) == str2:byte(j) then
				cost = 0
			else
				cost = 1
			end
			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end
	
	return matrix[len1][len2]
end

function utf8.totype(s)
	check("s")

	local value = tonil(s)
	if value ~= false then return value end

	value = toboolean(s)
	if value ~= nil then return value end

	value = tonumber(s)
	if value then return value end

	return s
end

local charset = utf8.split("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
function utf8.random(length)
	check("n")

	length = math.floor(length)
	if length < 1 then return "" end

	local str = ""
	for i = 1, length do
		str = str..charset[math.random(#charset)]
	end
	return str
end