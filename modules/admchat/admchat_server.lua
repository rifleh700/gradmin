
local FIND_MESSAGES_LIMIT = 20
local CONSOLE_PREFIX = "ADMINSAY: "

mAdmChat = {}

function mAdmChat.init()

	cDB.exec([[
		CREATE TABLE IF NOT EXISTS admchat_messages (
    		id            INTEGER PRIMARY KEY AUTOINCREMENT,
    		timestamp     INTEGER NOT NULL,
    		account       TEXT,
    		name          TEXT    NOT NULL,
    		message       TEXT    NOT NULL
		)
	]])
	
	addEventHandler("gra.cSessions.onPlayerUpdate", root, mAdmChat.onPlayerSessionUpdate)

	cSync.register("AdmChat.members", "general.adminchat")
	cSync.register("AdmChat.message", "general.adminchat")
	cSync.register("AdmChat.history", "general.adminchat")

	cSync.registerResponder("AdmChat.members", mAdmChat.sync.members)
	cSync.registerResponder("AdmChat.history", mAdmChat.sync.hystory)

end

cModules.register(mAdmChat)

function mAdmChat.onPlayerSessionUpdate(isAdmin)

	cSync.callResponder(root, "AdmChat.members")

end

function mAdmChat.outputHistory(timestamp, accountName, name, message)

	local result, _, id = cDB.query(
		[[
		INSERT INTO admchat_messages (timestamp, account, name, message)
		VALUES (?, ?, ?, ?)
		]],
		timestamp, accountName, name, message
	)

	if not result then return result end

	return id
end

function mAdmChat.output(player, message)

	if player == console then player = root end

	local timestamp = getRealTime().timestamp
	local name = getPlayerName(player)

	local id = mAdmChat.outputHistory(timestamp, getPlayerAccountName(player), name, message)
	if not id then return false end

	cMessages.outputConsole(CONSOLE_PREFIX..stripColorCodes(name)..": "..message)

	local data = {
		id = id,
		timestamp = timestamp,
		name = name,
		message = message
	}

	cSync.send(root, "AdmChat.message", player, data)

	return true
end

mAdmChat.sync = {}

function mAdmChat.sync.members() 

	return cSessions.getAdmins("general.adminchat")
end

function mAdmChat.sync.hystory(lastID)
	if not scheck("?n") then return false end

	local query = cDB.prepare("SELECT * FROM admchat_messages WHERE TRUE")
	if lastID then query = query..cDB.prepare(" AND id < ?", lastID) end
	query = query..cDB.prepare(" ORDER BY id DESC LIMIT ?", FIND_MESSAGES_LIMIT)

	local result = cDB.query(query)
	return result 
end