
local SYNC_INTERVAL = 3 * 10^3

addEvent("gra.mFPS.sync", true)

mFps = {}

mFps.players = {}

function mFps.init()

	setTimer(mFps.send, SYNC_INTERVAL, 0)

	addEventHandler("onClientPreRender", root, mFps.onPreRender)
	addEventHandler("onClientPlayerQuit", root, mFps.onPlayerQuit)
	addEventHandler("gra.mFPS.sync", resourceRoot, mFps.sync)

	return true
end

addEventHandler("onClientResourceStart", resourceRoot, mFps.init)

function mFps.send()
	if not mFps.players[localPlayer] then return end

	return triggerLatentServerEvent("gra.mFPS.sync", localPlayer, mFps.players[localPlayer]) and true or false
end

function mFps.onPreRender(msSinceLastFrame)

	mFps.players[localPlayer] = math.floor((1 / msSinceLastFrame) * 1000)

end

function mFps.onPlayerQuit()
	
	mFps.players[source] = nil

end

function mFps.sync(player, fps)
	if not isElement(player) then return end
	if player == localPlayer then return end

	mFps.players[player] = fps

end

function mFps.get(player)
	if not scheck("u:element:player") then return false end

	return mFps.players[player]
end

---------------  API  ---------------

function getPlayerFPS(player)
	if not scheck("u:element:player") then return false end
	
	return mFps.get(player)
end