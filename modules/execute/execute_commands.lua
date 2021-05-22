
cCommands.add("execute",
	function(admin, code)
		local func, errorMsg = loadstring(code)
		if errorMsg then return false, "error: "..errorMsg end

		setfenv(func, setmetatable({}, {__index = _MTA}))
		
		local results = table.pack(pcall(func))
		if not results[1] then return false, "error: "..results[2] end

		for i = 2, results.n do
			results[i-1] = inspect(results[i])
		end
		results[results.n] = nil
		results.n = nil

		return true, "code executed (server) with result: "..table.concat(results, ", ")
	end,
	"lua-code:s-", "execute Lua code", COLORS.aqua
)