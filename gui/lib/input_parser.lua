
local NUMERIC_ROUND = 6

local InputParser = {}

function InputParser.parseNotEmpty(text)
	
	local value = utf8.trim(text)
	if value == "" then return nil end

	return value
end

function InputParser.parseSearch(text)
	
	local value = utf8.lower(utf8.trim(text))
	if value == "" then return nil end

	return value
end

function InputParser.parseMap(text)
	
	text = utf8.trim(text)
	local map = {}
	for k, v in utf8.gmatch(text, "([^%s]-):([^%s]*)") do
		map[k] = v ~= "" and v or false
	end
	return map
end

function InputParser.getNumericParser(integerOnly, min, max)
	
	return
		function(text)

			local value = utf8.trim(text)
			if value == "" then return nil end
		
			value = tonumber(value)
			if not value then return nil end

			value = integerOnly and math.floor(value) or math.round(value, 6)
			value = math.clamp(value, min, max)

			return value
		end
end

function guiGetInputNotEmptyParser()
	
	return InputParser.parseNotEmpty
end

function guiGetInputSearchParser()
	
	return InputParser.parseSearch
end

function guiGetInputMapParser()
	
	return InputParser.parseMap
end

function guiGetInputNumericParser(integerOnly, min, max)
	if not scheck("?b,?n[2]") then return false end
	
	return InputParser.getNumericParser(integerOnly, min, max)
end