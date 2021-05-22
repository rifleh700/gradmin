
local NUMERIC_MATCHER_STRING = "%-?%d*%.?%d?%d?%d?%d?%d?%d?"
local NUMERIC_POSITIVE_MATCHER_STRING = "%d*%.?%d?%d?%d?%d?%d?%d?"
local NUMERIC_INTEGER_MATCHER_STRING = "%-?%d*"
local NUMERIC_INTEGER_POSITIVE_MATCHER_STRING = "%d*"

local InputMatcher = {}

function InputMatcher.getNumericMatcher(integerOnly, min, max, default)

	return 
		function(text, hard)
			
			local matcherString =
				integerOnly and (min and min >= 0 and NUMERIC_INTEGER_POSITIVE_MATCHER_STRING or NUMERIC_INTEGER_MATCHER_STRING) or
				(min and min >= 0 and NUMERIC_POSITIVE_MATCHER_STRING or NUMERIC_MATCHER_STRING)
			text = utf8.match(text, matcherString)
			text = text or ""

			if not hard then return text end

			local number = tonumber(text)
			if not number then return default or "" end
			
			number = math.clamp(number, min, max)

			return tostring(number)
		end
end

function guiGetInputNumericMatcher(integerOnly, min, max, default)
	if not scheck("?b,?n[3]") then return false end

	return InputMatcher.getNumericMatcher(integerOnly, min, max, default)
end