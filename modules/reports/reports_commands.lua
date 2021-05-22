
cCommands.add("acceptreport",
	function(admin, id)
		if not isReport(id) then return false, "invalid reportID" end
		
		if not acceptReport(id, getPlayerAccountName(admin) or "") then
			return false, "report is already accepted"
		end
	   
		return true,
			"report has been accepted"
	end,
	"reportID:s", "accept report"
)