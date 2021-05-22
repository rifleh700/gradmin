
function dbPrepareBatchString(connection, query, rowsParams)
	check("u:element:db-connection,s,t")

	local rows = #rowsParams
	if rows == 0 then return false end
	if rows == 1 then return dbPrepareString(connection, query, table.unpack(rowsParams[1])) end

	local batchQuery = ""
	for i, params in ipairs(rowsParams) do
		batchQuery = batchQuery..dbPrepareString(connection, query, table.unpack(params))..";"
	end

	return batchQuery
end