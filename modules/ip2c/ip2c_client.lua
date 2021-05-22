
local FLAGS_PATH = "modules/ip2c/flags/"

mIP2C = {}

function mIP2C.getCountryFlagImagePath(iso)
	if not scheck("?s") then return false end

	return FLAGS_PATH..(iso or "_unknown")..".png"
end

