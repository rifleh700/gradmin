
cCommands.addHardCoded("start",
	function(admin, resourceName)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource '"..resourceName.."' could not be found" end
		if getResourceState(resource) == "running" then return false, "resource '"..resourceName.."' is already running" end
		if not startResource(resource, true) then return false end
		return true, "resource '"..resourceName.."' started"
	end
)

cCommands.addHardCoded("restart",
	function(admin, resourceName)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource '"..resourceName.."' could not be found" end
		if getResourceState(resource) ~= "running" then return false, "resource '"..resourceName.."' is not running" end
		if not restartResource(resource) then return false end
		return true, "resource '"..resourceName.."' restarted successfully"
	end
)

cCommands.addHardCoded("stop",
	function(admin, resourceName)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource '"..resourceName.."' could not be found" end
		if getResourceState(resource) ~= "running" then return false, "resource '"..resourceName.."' is not running" end
		if not stopResource(resource) then return false end
		return true, "resource '"..resourceName.."' stopped"
	end
)

cCommands.addHardCoded("refresh",
	function(admin, resourceName)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource '"..resourceName.."' could not be found" end
		if not refreshResources(false, resource) then return false end
		if getResourceState(resource) == "failed to load" then
			return false, "loading of resource '"..resourceName.."' failed: "..getResourceLoadFailureReason(resource)
		end 
		return true, "resource '"..resourceName.."' successfully loaded"
	end
)

cCommands.addHardCoded("aclrequest",
	function(admin, resourceName, right, access)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource '"..resourceName.."' could not be found" end

		local who = getPlayerName(admin)..("("..getPlayerAccountName(admin)..")" or "")
		if not updateResourceACLRequest(resource, right, access, who)  then return false end
		triggerEvent("gra.mResources.onACLRequestUpdate", root, resource, right, access, who)

		return true, string.format("%s %s changed to %s", resourceName, right, access and "allow" or "deny")
	end
)

cCommands.add("setsetting",
	function(admin, resourceName, setting, value)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource '"..resourceName.."' not found" end
		
		if type(value) == "string" then 
			value = utf8.totype(value)
		end

		if not set("*"..resourceName..".".. setting, value) then return false end
		
		return true, "resource '"..resourceName.."' setting '"..setting.."' has been set to "..toJSON(value)
	end,
	"resource-name:s,setting:s,value:s", "set resource setting"
)