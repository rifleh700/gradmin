
local _toJSON = toJSON
function toJSON(value, ...)

	if value == nil then return "[ nil ]" end
	
	return _toJSON(value, ...)
end

local _fromJSON = fromJSON
function fromJSON(s)
	if not scheck("s") then return false end

	if s == "[  ]" then return end
	if s == "[ nil ]" then return nil end

	return _fromJSON(s)
end

function stripColorCodes(str)
	if not scheck("s") then return false end

	str = utf8.gsub(str, "#%x%x%x%x%x%x", "")
	return str
end

function isInsideArea(x, y, minX, minY, maxX, maxY)
	if not scheck("n[6]") then return false end

	if x < minX or x > maxX or
	y < minY or y > maxY then
		return false
	end
	return true
end

function isInsideRectangle(x, y, rx, ry, width, height)
	if not scheck("n[6]") then return false end
	
	return isInsideArea(x, y, rx, ry, rx + width, ry + height)
end