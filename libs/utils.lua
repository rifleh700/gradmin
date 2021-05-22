
function address(val)
	check("t|u|f|th")

	return utf8.match(tostring(val), "^.+:%s(%x+)$")
end

function toboolean(v)
	check("b|s")

	if v == false or v == true then return v end
	if v == "true" then return true end
	if v == "false" then return false end

	return nil
end

function tonil(v)
	check("?s")

	if v == nil then return nil end

	return v == "nil" and nil or false
end