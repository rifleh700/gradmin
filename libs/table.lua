
function table.unpack(t)
	check("t")

	return unpack(t, nil, t.n)
end

function table.pack(...)
	return {n = select("#", ...), ...}
end

function table.index(t, v)
	check("t,!")

	local size = #t
	if size == 0 then return nil end

	for i = 1, size do
		if t[i] == v then return i end
	end
	return nil
end

function table.key(t, v)
	check("t,!")

	for k, tv in pairs(t) do
		if tv == v then return k end
	end
	return nil
end

function table.reverse(t)
	check("t")

	for i = 1, math.floor(#t / 2) do
		t[i], t[#t - i + 1] = t[#t - i + 1], t[i]
	end
	return t
end

function table.removevalue(t, v)
	check("t")

	if v == nil then return false end

	local size = #t
	if size == 0 then return nil end

	for i = 1, size do
		if t[i] == v then return table.remove(t, i) end
	end
	return false
end

function table.equal(t1, t2)
	if type(t1) ~= type(t2) then return false end
	if type(t1) ~= "table" then return t1 == t2 end

	for k, v in pairs(t1) do
		if not table.equal(v, t2[k]) then return false end
	end
	for k, v in pairs(t2) do
		if not table.equal(v, t1[k]) then return false end
	end

	return true
end

function table.copy(t)
	check("t")

	local result = {}
	for k, v in pairs(t) do
		result[k] = v
	end
	return result
end
 
function table.copydeep(t)
	if type(t) ~= "table" then return t end

	local result = {}
	for k, v in pairs(t) do
		result[k] = table.copydeep(v)
	end
	return result
end

function table.merge(t, t2)
	check("t[2]")

	for k, v in pairs(t2) do
		t[k] = v
	end
	return t
end

function table.size(t)
	check("t")

	local size = 0
	for _ in pairs(t) do
		size = size + 1
	end
	return size
end