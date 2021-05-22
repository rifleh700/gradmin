
function enum(args, prefix)
	check("t,?s")
	
	for i, targ in ipairs(args) do
		if prefix then
			_G[targ] = prefix..i
		else
			_G[targ] = i
		end
	end
end