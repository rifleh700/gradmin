
function math.clamp(x, min, max)
	check("n,?n[2]")

	return min and x < min and min or max and x > max and max or x
end

function math.round(x, decimals)
	check("n,?n")

	local mult = 10^(decimals or 0)
	x = x * mult

    return (x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5))/mult
end