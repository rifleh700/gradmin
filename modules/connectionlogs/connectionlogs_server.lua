
local FIND_LOGS_LIMIT = 50

local mConnectionLogs = {}

function mConnectionLogs.init()

	cDB.exec([[
		CREATE TABLE IF NOT EXISTS connection_logs (
    		id            INTEGER PRIMARY KEY AUTOINCREMENT,
    		timestamp     INTEGER NOT NULL,
    		action        TEXT    NOT NULL,
    		serial        TEXT    NOT NULL,
    		ip            TEXT    NOT NULL,
    		name          TEXT    NOT NULL,
    		plain_name    TEXT    NOT NULL,
    		account       TEXT,
    		data          TEXT
		)
	]])

	addEventHandler("onPlayerJoin", root, mConnectionLogs.onJoin, true, "low")
	addEventHandler("onPlayerLogin", root, mConnectionLogs.onLogin, true, "low")
	addEventHandler("onPlayerChangeNick", root, mConnectionLogs.onChangeNick, true, "low")
	addEventHandler("onPlayerLogout", root, mConnectionLogs.onLogout, true, "low")
	addEventHandler("onPlayerQuit", root, mConnectionLogs.onQuit, true, "low")

	cSync.register("ConnectionLogs.next", "general.connections", {heavy = true})
	
	cSync.registerResponder("ConnectionLogs.next", mConnectionLogs.sync.next)

	return true
end

cModules.register(mConnectionLogs)

function mConnectionLogs.output(player, action, data)
	if not scheck("u:element:player,s,?t") then return false end
	
	return cDB.exec(
		[[
		INSERT INTO connection_logs (
			timestamp, action,
			serial, ip,
			name, plain_name,
			account, data
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
		]],
		getRealTime().timestamp, action,
		getPlayerSerial(player), getPlayerIP(player),
		getPlayerName(player), getPlayerName(player, true),
		getPlayerAccountName(player) or nil, data and toJSON(data) or nil
	)
end

function mConnectionLogs.onJoin()
	mConnectionLogs.output(source, "join")
end

function mConnectionLogs.onLogin(previous, current)
	mConnectionLogs.output(source, "login", {previous = getAccountName(previous), current = getAccountName(current)})
end

function mConnectionLogs.onChangeNick(previous, current, byUser)
	mConnectionLogs.output(source, "changenick", {previous = previous, current = current, byUser = tostring(byUser)})
end

function mConnectionLogs.onLogout(previous, current)
	mConnectionLogs.output(source, "logout", {previous = getAccountName(previous), current = getAccountName(current)})
end

function mConnectionLogs.onQuit(qtype)
	mConnectionLogs.output(source, "quit", {type = utf8.lower(qtype)})
end

mConnectionLogs.sync = {}

function mConnectionLogs.sync.next(filter, lastID)
	if not scheck("?t,?n") then return false end

	filter = filter or {}

	local query = cDB.prepare("SELECT * FROM connection_logs WHERE id > ?", lastID or 0)
	if filter.since then query = query..cDB.prepare(" AND timestamp > ?", filter.since) end
	if filter.before then query = query..cDB.prepare(" AND timestamp < ?", filter.before) end
	if filter.action then query = query..cDB.prepare(" AND action LIKE ?", "%"..filter.action.."%") end
	if filter.serial then query = query..cDB.prepare(" AND serial LIKE ?", "%"..filter.serial.."%") end
	if filter.account then query = query..cDB.prepare(" AND account LIKE ?", "%"..filter.account.."%") end
	if filter.account == false then query = query..cDB.prepare(" AND account IS NULL") end
	if filter.name then query = query..cDB.prepare(" AND plain_name LIKE ?", "%"..filter.name.."%") end
	query = query..cDB.prepare(" LIMIT ?", FIND_LOGS_LIMIT)

	local result = cDB.query(query)
	if not result then return result end

	for i, row in ipairs(result) do
		row.data = row.data and fromJSON(row.data) or nil
	end

	return result
end