
local SCREENSHOTS_PATH = DATA_PATH.."reports/screenshots/"
local FIND_REPORTS_LIMIT = 50

addEvent("gra.mReport.report", true)

addEvent("gra.mReport.onReport", false)
addEvent("gra.mReport.onRemove", false)
addEvent("gra.mReport.onAccept", false)

mReport = {}

function mReport.init()
	
	cDB.exec([[
		CREATE TABLE IF NOT EXISTS reports (
    		id          INTEGER PRIMARY KEY AUTOINCREMENT,
    		time        INTEGER NOT NULL,
    		serial      TEXT    NOT NULL,
    		account     TEXT,
    		name        TEXT    NOT NULL,
    		plain_name  TEXT    NOT NULL,
    		message     TEXT    NOT NULL,
    		screenshots INTEGER NOT NULL,
    		admin       TEXT
		)
	]])

	addEventHandler("gra.mReport.report", root, mReport.report)

	return true
end

cModules.register(mReport)

function mReport.report(message, screenshots)
	local client = client
	if not client then return cMessages.outputSecurity("REPORTS: client not found") and false end
	if source ~= client then return cMessages.outputSecurity("REPORTS: source $v element is not equal client $v", source, client) and false end
		
	local data = mReport.add(client, message, screenshots or {})
	if not data then return end
	
	triggerEvent("gra.mReport.onReport", client, data)

end

function mReport.getScreenshotPath(id, number)
	
	return SCREENSHOTS_PATH..id.."_"..number..".jpg"
end

function mReport.saveScreenshots(id, screenshots)
	if #screenshots == 0 then return false end

	for number, screenshot in ipairs(screenshots) do
		local path = mReport.getScreenshotPath(id, number)
		if fileExists(path) then fileDelete(path) end

		local file = fileCreate(path)
		if file then
			fileWrite(file, screenshot)
			fileFlush(file)
			fileClose(file)
		end
	end

	return true
end

function mReport.add(client, message, screenshots)
	
	local data = {
		time = getRealTime().timestamp,
		serial = getPlayerSerial(client),
		account = getPlayerAccountName(client),
		name = getPlayerName(client),
		message = message,
		screenshots = #screenshots
	}

	local result, _, id = cDB.query(
		[[
		INSERT INTO reports (
			time, serial, account, name, plain_name, message, screenshots
		) VALUES (?,?,?,?,?,?,?)
		]],
		data.time,
		data.serial, data.account, data.name, stripColorCodes(data.name),
		data.message, data.screenshots
	)

	if not result and id then return false end

	data.id = id
	mReport.saveScreenshots(id, screenshots)

	return data
end

function mReport.removeScreenshots(id)
	
	local result = cDB.query("SELECT screenshots FROM reports WHERE id = ?", id)
	if #result < 1 then return false end

	local screenshots = result[1].screenshots
	if screenshots < 1 then return true end

	for number = 1, screenshots do
		local path = mReport.getScreenshotPath(id, number)
		if fileExists(path) then fileDelete(path) end
	end
	return true
end

function mReport.remove(id)
	
	mReport.removeScreenshots(id)
	local result, rows = cDB.query("DELETE FROM reports WHERE id = ?", id)

	return rows > 0
end

function mReport.getScreenshots(id)
	
	local result = cDB.query("SELECT screenshots FROM reports WHERE id = ?", id)
	if #result < 1 then return false end

	local screenshots = result[1].screenshots
	if screenshots < 1 then return {} end

	local data = {}
	for number = 1, screenshots do
		local path = mReport.getScreenshotPath(id, number)
		if fileExists(path) then 
			local file = fileOpen(path, true)
			data[number] = fileReadAll(file)
			fileClose(file)
		end
	end

	return data
end

------------------------------------------------------------------------------
------------------------------  API  -----------------------------------------
------------------------------------------------------------------------------

function isReport(id)
	if not scheck("n") then return false end

	local result = cDB.query("SELECT id FROM reports WHERE id = ? LIMIT 1", id)
	if not result then return false end
	if #result < 1 then return false end

	return true
end

function findReports(filter, lastID)
	if not scheck("?t,?n") then return false end

	filter = filter or {}

	local query = cDB.prepare("SELECT * FROM reports WHERE TRUE")
	if lastID then query = query..cDB.prepare(" AND id < ?", lastID) end
	if filter.since then query = query..cDB.prepare(" AND time > ?", filter.since) end
	if filter.before then query = query..cDB.prepare(" AND time < ?", filter.before) end
	if filter.serial then query = query..cDB.prepare(" AND serial LIKE ?", "%"..filter.serial.."%") end
	if filter.account then query = query..cDB.prepare(" AND account LIKE ?", "%"..filter.account.."%") end
	if filter.name then query = query..cDB.prepare(" AND plain_name LIKE ?", "%"..filter.name.."%") end
	if filter.message then query = query..cDB.prepare(" AND message LIKE ?", "%"..filter.message.."%") end
	if filter.admin then query = query..cDB.prepare(" AND admin LIKE ?", "%"..filter.admin.."%") end
	if filter.admin == false then query = query..cDB.prepare(" AND admin IS NULL") end
	query = query..cDB.prepare(" ORDER BY id DESC LIMIT ?", FIND_REPORTS_LIMIT)
	
	local result = cDB.query(query)
	return result
end

function getReportScreenshots(id)
	if not scheck("n") then return false end
	
	return mReport.getScreenshots(id)
end

function acceptReport(id, admin)
	if not scheck("n,s") then return false end

	local result, rows = cDB.query("UPDATE reports SET admin = ? WHERE id = ? AND admin IS NULL", admin, id)
	if not result then return false end
	if rows < 1 then return false end 

	triggerEvent("gra.mReport.onAccept", root, id, admin)

	return true
end

function getNotAcceptedReportsCount()
	
	local result = cDB.query("SELECT COUNT(*) AS count FROM reports WHERE admin IS NULL")
	if not result then return false end 

	return result[1].count
end

function removeReport(id)
	if not scheck("n") then return false end

	if not mReport.remove(id) then return false end

	triggerEvent("gra.mReport.onRemove", root, id)

	return true
end