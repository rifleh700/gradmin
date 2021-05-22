
local FIND_REPORTS_LIMIT = 50

local mReports = {}

mReports.fresh = 0

function mReports.init()
	
	mReports.fresh = getNotAcceptedReportsCount()

	addEventHandler("gra.mReport.onReport", root, mReports.onReport)
	addEventHandler("gra.mReport.onAccept", root, mReports.onAccept)

	cSync.register("Reports.fresh", "general.reports")
	cSync.register("Reports.next", "general.reports", {heavy = true})
	cSync.register("Reports.accept", "general.reports")
	cSync.register("Reports.report", "general.reports")
	cSync.register("Reports.screenshots", "general.reports", {heavy = true})

	cSync.registerResponder("Reports.fresh", function() return mReports.fresh end)
	cSync.registerResponder("Reports.next", findReports)
	cSync.registerResponder("Reports.screenshots", getReportScreenshots)

	return true
end

cModules.register(mReports)

function mReports.onReport(data)

	mReports.fresh = mReports.fresh + 1
	cSync.send(root, "Reports.fresh", mReports.fresh)
	cSync.send(root, "Reports.report", data)

end

function mReports.onAccept(id, admin)

	mReports.fresh = mReports.fresh - 1
	cSync.send(root, "Reports.fresh", mReports.fresh)
	cSync.send(root, "Reports.accept", id, admin)

end