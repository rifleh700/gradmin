
cCommands.add("admsay",
	function(admin, message)
		
		if not mAdmChat.output(admin, message) then return false end
		
		return true
	end,
	"message:s-", "output message to admin chat"
)