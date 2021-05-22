
function coroutine.sleep(ms)
	check("n")
	if ms < 0 then error("negative interval", 2) end

	local c = coroutine.running()
	if not c then error("invalid thread", 2) end

	setTimer(
		function()
			if coroutine.status(c) ~= "suspended" then return end
			coroutine.resume(c)
		end, ms, 1
	)

	return coroutine.yield()
end