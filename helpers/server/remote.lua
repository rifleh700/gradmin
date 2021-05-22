
remote = {}

local threads = {}
local results = {}

local function callback(responseData, error, cid)
	results[cid] = responseData
	coroutine.resume(threads[cid])
end

function remote.fetch(url, options)
	if not scheck("s,?t") then return false end
	
	local c = coroutine.running()
	local cid = address(c)
	
	local fetch = fetchRemote(url, options or {}, callback, {cid})
	if not fetch then return false end

	threads[cid] = c
	coroutine.yield()

	local result = results[cid]
	threads[cid] = nil
	results[cid] = nil

	if result == "ERROR" then return false end
	
	return result
end
