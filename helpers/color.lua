
function hsv2rgb(h, s, v)
	check("n[3]")

	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	local switch = i % 6
	if switch == 0 then
		r = v g = t b = p
	elseif switch == 1 then
		r = q g = v b = p
	elseif switch == 2 then
		r = p g = v b = t
	elseif switch == 3 then
		r = p g = q b = v
	elseif switch == 4 then
		r = t g = p b = v
	elseif switch == 5 then
		r = v g = p b = q
	end

	return math.round(r*255), math.round(g*255), math.round(b*255)
end

function rgb2hsv(r, g, b)
	check("byte[3]")

	r, g, b = r/255, g/255, b/255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s
	local v = max
	local d = max - min
	s = max == 0 and 0 or d/max
	if max == min then
		h = 0
	elseif max == r then
		h = (g - b) / d + (g < b and 6 or 0)
	elseif max == g then
		h = (b - r) / d + 2
	elseif max == b then
		h = (r - g) / d + 4
	end
	h = h/6

	return h, s, v
end

function rgb2hexs(r, g, b, a)
	check("byte[3],?byte")

	if a then return string.format("#%.2X%.2X%.2X%.2X", r, g, b, a) end
	return string.format("#%.2X%.2X%.2X", r, g, b)
end

function hexs2rgb(hexs)
	check("s")
	
	return getColorFromString(hexs)
end