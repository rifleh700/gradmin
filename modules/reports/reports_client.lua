
local SCREENSHOTS_PATH = DATA_PATH.."reports/screenshots/"
local NEW_REPORT_MESSAGE_COLOR = COLORS.orange
local NEW_REPORT_MESSAGE_MAX_LENGTH = 20
local NEW_REPORT_SOUND_SFX = {"genrl", 52, 17}

mReports = {}

function mReports.init()

	mReports.fresh = 0
	mReports.reports = {}
	mReports.filter = nil
	mReports.full = false
	mReports.screenshots = {}
	mReports.requested = {}
	
	addEventHandler("onClientResourceStop", resourceRoot, mReports.removeScreenshots)
	
	cSync.addHandler("Reports.fresh", mReports.sync.fresh)
	cSync.addHandler("Reports.next", mReports.sync.next)
	cSync.addHandler("Reports.report", mReports.sync.report)
	cSync.addHandler("Reports.accept", mReports.sync.accept)
	cSync.addHandler("Reports.screenshots", mReports.sync.screenshots)
	
	mReports.gui.init()

	cSync.request("Reports.fresh")
	cSync.request("Reports.next", filter, nil)

	return true
end

function mReports.term()

	mReports.gui.term()
	mReports.removeScreenshots()

	cSync.removeHandler("Reports.fresh", mReports.sync.fresh)
	cSync.removeHandler("Reports.next", mReports.sync.next)
	cSync.removeHandler("Reports.report", mReports.sync.report)
	cSync.removeHandler("Reports.accept", mReports.sync.accept)
	cSync.removeHandler("Reports.screenshots", mReports.sync.screenshots)

	removeEventHandler("onClientResourceStop", resourceRoot, mReports.removeScreenshots)

	return true
end

cModules.register(mReports, "general.reports")

function mReports.getData(id)
	
	for i, data in ipairs(mReports.reports) do
		if data.id == id then return data end
	end
	return nil
end

function mReports.request(filter)
	if not cSync.request("Reports.next", filter, nil) then return false end

	mReports.reports = {}
	mReports.filter = filter
	mReports.full = false
	mReports.gui.refresh()
	
	return true
end

function mReports.requestNext()
	if mReports.full then return false end
	if not cSync.request("Reports.next", mReports.filter, mReports.reports[#mReports.reports].id) then return false end
	
	return true
end

function mReports.requestScreenshots(id)
	if mReports.screenshots[id] then return false end
	if not cSync.request("Reports.screenshots", id) then return false end
	
	mReports.requested[id] = true
	mReports.gui.refreshReport(id)

	return true
end

function mReports.getScreenshotPath(id, number)
	
	return SCREENSHOTS_PATH..id.."_"..number..".jpg"
end

function mReports.saveScreenshots(id, screenshots)

	for number, data in ipairs(screenshots) do
		local path = mReports.getScreenshotPath(id, number)
		if fileExists(path) then fileDelete(path) end
	
		local file = fileCreate(path)
		if file then
			fileWrite(file, data)
			fileFlush(file)
			fileClose(file)
		end
	end

	mReports.screenshots[id] = #screenshots

	return true
end

function mReports.removeScreenshots()

	for id, screenshots in pairs(mReports.screenshots) do
		for number = 1, screenshots do
			local path = mReports.getScreenshotPath(id, number)
			if fileExists(path) then fileDelete(path) end
		end
	end

	mReports.screenshots = {}

	return true
end

mReports.sync = {}

function mReports.sync.fresh(fresh)
	
	mReports.fresh = fresh
	mReports.gui.refreshFresh(fresh)

end

function mReports.sync.next(filter, lastID, reports)
	if not table.equal(filter, mReports.filter) then return end

	local size = #mReports.reports
	if size > 0 and mReports.reports[size].id ~= lastID then return end

	if #reports == 0 then
		mReports.full = true
		return
	end

	for i, data in ipairs(reports) do
		mReports.reports[size + i] = data
	end
	mReports.gui.refresh()

end

function mReports.sync.accept(id, admin)

	for i, data in ipairs(mReports.reports) do
		if data.id == id then
			data.admin = admin
			mReports.gui.refreshReport(id)
			break
		end
	end

end

function mReports.sync.filter(data)

	local filter = mReports.filter
	if not filter then return true end

	if filter.since and data.time < filter.since then return false end
	if filter.before and data.time > filter.before then return false end
	if filter.serial and not utf8.find(data.serial, filter.serial, nil, true, true) then return false end
	if filter.serial and not utf8.find(data.serial, filter.serial, nil, true, true) then return false end
	if filter.admin and (not data.admin or (not utf8.find(data.admin, filter.admin, nil, true, true))) then return false end
	if filter.name and (not data.name or (not utf8.find(stripColorCodes(data.name), filter.name, nil, true, true))) then return false end

	return true
end

function mReports.sync.report(data)

	if mReports.sync.filter(data) then
		table.insert(mReports.reports, 1, data)
		mReports.gui.refresh()
	end

	playSFX(table.unpack(NEW_REPORT_SOUND_SFX))
	cMessages.outputAdmin(
		string.format("new report from %s: %s...", data.name, utf8.sub(data.message, 1, NEW_REPORT_MESSAGE_MAX_LENGTH)),
		NEW_REPORT_MESSAGE_COLOR
	)

end

function mReports.sync.screenshots(id, screenshots)

	mReports.saveScreenshots(id, screenshots)
	mReports.gui.refreshReport(id)

end