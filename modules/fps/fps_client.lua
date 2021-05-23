
local SYNC_INTERVAL = 5 * 10^3

addEvent("gra.mFps.sync", true)

mFps = {}

function mFps.init()

	setTimer(mFps.send, SYNC_INTERVAL, 0)

	addEventHandler("onClientPreRender", root, mFps.onPreRender)
	addEventHandler("gra.mFps.sync", root, mFps.sync)

	return true
end

addEventHandler("onClientResourceStart", resourceRoot, mFps.init)

function mFps.send()
	
	local fps = cElementsData.get(localPlayer, "mFps.fps")
	if not fps then return false end

	return triggerLatentServerEvent("gra.mFps.sync", localPlayer, fps)
end

function mFps.onPreRender(msSinceLastFrame)

	cElementsData.set(localPlayer, "mFps.fps", math.floor((1 / msSinceLastFrame) * 1000))

end

function mFps.sync(fps)
	if not isElement(source) then return end
	if source == localPlayer then return end

	cElementsData.set(source, "mFps.fps", fps)

end

function mFps.get(player)
	if not scheck("u:element:player") then return false end

	return cElementsData.get(player, "mFps.fps")
end

---------------  API  ---------------

function getPlayerFPS(player)
	if not scheck("u:element:player") then return false end
	
	return mFps.get(player)
end