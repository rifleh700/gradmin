
cCommands = {}

function cCommands.execute(command, ...)
	if not scheck("s") then return false end
	
	return triggerServerEvent("gra.cCommands.execute", localPlayer, command, ...)
end