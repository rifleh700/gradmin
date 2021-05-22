
cCommands.add("createteam",
	function(admin, name, r, g, b)
		if getTeamFromName(name) then return false, "team '"..name.."' is already exists" end
		
		if not createTeam(name, r, g, b) then return false end
		
		return true,
			"team '"..name.."' successfully created"
	end,
	"name:s,[R:byte,G:byte,B:byte", "create new team"
)

cCommands.add("destroyteam",
	function(admin, team)
		
		local name = getTeamName(team)
		if not destroyElement(team) then return false end
		
		return true,
			"team '"..name.."' successfully destroyed" 
	end,
	"team-name:T", "destroy team"
)

