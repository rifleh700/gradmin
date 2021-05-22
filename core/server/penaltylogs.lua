
local FIND_LOGS_LIMIT = 50

cPenaltyLogs = {}

function cPenaltyLogs.init()
	
	cDB.query([[
		CREATE TABLE IF NOT EXISTS penalty_logs (
			id            INTEGER PRIMARY KEY AUTOINCREMENT,
			timestamp     INTEGER NOT NULL,
			action        TEXT    NOT NULL,
			admin_account TEXT    NOT NULL,
			serial        TEXT    NOT NULL,
			data          TEXT
		)
	]])

	return true
end

cPenaltyLogs.init()

function cPenaltyLogs.output(admin, action, serial, data)
	if not scheck("u:element:player|u:element:console|u:element:root,s,s,?t") then return false end
	
	return cDB.exec(
		[[
		INSERT INTO penalty_logs (
			timestamp, action, admin_account, serial, data
		) VALUES (?,?,?,?,?)
		]],
		getRealTime().timestamp,
		action,
		getPlayerAccountName(admin),
		serial,
		data and toJSON(data) or nil
	)
end

function cPenaltyLogs.find(filter, lastID)
	if not scheck("?t,?n") then return false end

	filter = filter or {}

	local query = cDB.prepare("SELECT * FROM penalty_logs WHERE id > ?", lastID or 0)
	if filter.since then query = query..cDB.prepare(" AND timestamp > ?", filter.since) end
	if filter.before then query = query..cDB.prepare(" AND timestamp < ?", filter.before) end
	if filter.admin then query = query..cDB.prepare(" AND admin_account LIKE ?", "%"..filter.admin.."%") end
	if filter.action then query = query..cDB.prepare(" AND action = ?", filter.action) end
	if filter.serial then query = query..cDB.prepare(" AND serial LIKE ?", "%"..filter.serial.."%") end
	query = query..cDB.prepare(" LIMIT ?", FIND_LOGS_LIMIT)
	
	local result = cDB.query(query)
	if not result then return result end

	for i, row in ipairs(result) do
		row.data = row.data and fromJSON(row.data) or nil
	end

	return result
end