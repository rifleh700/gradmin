
function guiToCEGUIColor(r, g, b, a)
	if not scheck("n[3],?n") then return false end

	return string.format("%.2X%.2X%.2X%.2X", a or 255, r, g, b)
end

function guiFromCEGUIColor(hex)
	if not scheck("s") then return false end
	
	local a = tonumber("0x"..utf8.sub(hex, 1, 2))
	local r, g, b = hexs2rgb("#"..utf8.sub(hex, 3, 8))

    return r, g, b, a
end

function guiSetBooleanProperty(element, property, state)
	if not scheck("u:element:gui,s,b") then return false end

	return guiSetProperty(element, property, state and "True" or "False")
end

function guiGetBooleanProperty(element, property)
	if not scheck("u:element:gui,s") then return false end

	return guiGetProperty(element, property) == "True"
end

function guiSetNumericProperty(element, property, value)
	if not scheck("u:element:gui,s,n") then return false end

	return guiSetProperty(element, property, tostring(value))
end

function guiGetNumericProperty(element, property)
	if not scheck("u:element:gui,s") then return false end

	return tonumber(guiGetProperty(element, property))
end

function guiSetTableProperty(element, property, value)
	if not scheck("u:element:gui,s,t") then return false end

	value = toJSON(value)
		:gsub("^%[", "")
		:gsub("%]$", "")
		:gsub("%[", "{")
		:gsub("%]", "}")
		:gsub("%s", "")

	return guiSetProperty(element, property, value)
end

function guiGetTableProperty(element, property)
	if not scheck("u:element:gui,s") then return false end

	local value = guiGetProperty(element, property)
		:gsub("{", "[")
		:gsub("}","]")

	value = fromJSON("["..value.."]")

	return value
end

function guiSetColorProperty(element, property, r, g, b, a)
	if not scheck("u:element:gui,s,n[3],?n") then return false end

	return guiSetProperty(element, property, guiToCEGUIColor(r, g, b, a))
end

function guiGetColorProperty(element, property)
	if not scheck("u:element:gui,s") then return false end
	
	return guiFromCEGUIColor(guiGetProperty(element, property))
end

function guiSetColorsProperty(element, property, r, g, b, a)
	if not scheck("u:element:gui,s,n[3],?n") then return false end

	if not a then a = 255 end
	local hex = guiToCEGUIColor(r, g, b, a)

	return guiSetProperty(element, property, "tl:"..hex.." tr:"..hex.." bl:"..hex.." br:"..hex)
end

function guiGetColorsProperty(element, property)
	if not scheck("u:element:gui,s") then return false end

	local property = guiGetProperty(element, property)
	local hex = utf8.match(property, "tl:(%x+)")

	return guiFromCEGUIColor(hex)
end

local ceguiAlignmentProperties = {
	["top"] = "Top",
	["center"] = "Centre",
	["bottom"] = "Bottom",
	["left"] = "Left",
	["right"] = "Right"
}

function guiSetAlignmentProperty(element, property, alignment)
	if not scheck("u:element:gui,s[2]") then return false end
	if not ceguiAlignmentProperties[alignment] then return false end

	return guiSetProperty(element, property, ceguiAlignmentProperties[alignment])
end

function guiGetAlignmentProperty(element, property)
	if not scheck("u:element:gui,s") then return false end

	local value = guiGetProperty(element, property)
	local alignment = table.key(ceguiAlignmentProperties, property)
	if not alignment then return false end

	return alignment
end