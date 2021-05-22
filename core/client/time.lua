
addEvent("gra.cTime.sync", true, true)

local syncedServerTimestamp = nil
local syncedClock = nil

cTime = {}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		triggerServerEvent("gra.cTime.sync", localPlayer)
	end
)

addEventHandler("gra.cTime.sync", localPlayer,
	function(timestamp)
		syncedServerTimestamp = timestamp
		syncedClock = os.clock()
	end
)

function cTime.get()

	return syncedServerTimestamp + math.floor(os.clock() - syncedClock)
end