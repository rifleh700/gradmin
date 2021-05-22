
local BANDWIDTH = 50 * 10^3

mReport = {}

function mReport.init()
	
	mReport.gui.init()

	addCommandHandler("report", mReport.onCommand)

	return true
end

addEventHandler("onClientResourceStart", resourceRoot, mReport.init)

function mReport.onCommand(command, ...)

	mReport.gui.show(table.concat({...}, " "))

end

function mReport.getScreenshotsLimit()
	
	local value = cGlobalSettings.get("reportscreenshots")
	if not value then return 0 end

	value = tonumber(value)
	if not value then return 0 end

	return math.max(value, 0)
end

function mReport.send(message, screenshots)
	
	local screenshotsData = {}
	for i, id in ipairs(screenshots) do
		screenshotsData[i] = mScreenshotSaver.read(id)
	end

	return triggerLatentServerEvent("gra.mReport.report", BANDWIDTH, localPlayer, message, screenshotsData) and true or false
end