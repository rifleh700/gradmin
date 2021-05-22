
function crc32(...)

	local data = ""
	for i = 1, select("#", ...) do
		data = data..tostring(select(i, ...))
	end 

	local crc = 0xFFFFFFFF
	local byte = 0
	local mask = 0

	for i = 1, #data do
		byte = utf8.byte(data, i)
		crc  = bitXor(crc, byte)
		for j = 1, 8 do
			mask = bitAnd(crc, 1) * (-1)
			crc  = bitXor(bitRShift(crc, 1), bitAnd(0xEDB88320, mask))
		end
	end
	crc = bitNot(crc)

	return string.format("%08X", crc)
end