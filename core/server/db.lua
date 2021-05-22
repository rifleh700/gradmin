
local PATH = "main.db"
local OPTIONS = "batch=1;autoreconnect=1;tag=gradmin;multi_statements=1;"
local TIMEOUT = 2 * 10^3

local connection = nil

cDB = {}

function cDB.init()

	connection = dbConnect("sqlite", PATH, nil, nil, OPTIONS)
	if not connection then return error("db initialization failed", 2) end

	dbExec(connection, "VACUUM")

	return true
end

cDB.init()

function cDB.prepare(query, ...)
	if not scheck("s") then return false end

	return dbPrepareString(connection, query, ...)
end

function cDB.prepareBatch(query, t)
	if not scheck("s,t") then return false end

	return dbPrepareBatchString(connection, query, t)
end

function cDB.query(query, ...)
	if not scheck("s") then return false end

	return dbPoll(dbQuery(connection, query, ...), TIMEOUT)
end

function cDB.exec(query, ...)
	if not scheck("s") then return false end

	return dbExec(connection, query, ...)
end
