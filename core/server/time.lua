
addEvent("gra.cTime.sync", true, true)

addEventHandler("gra.cTime.sync", root,
	function()
		triggerClientEvent(client, "gra.cTime.sync", client, getRealTime().timestamp)
	end
)