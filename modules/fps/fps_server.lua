
addEvent("gra.mFPS.sync", true)

mFps = {}

mFps.players = {}

function mFps.init()
	
	addEventHandler("onPlayerQuit", root, mFps.onPlayerQuit)
	addEventHandler("gra.mFPS.sync", resourceRoot, mFps.sync)

	return true
end

addEventHandler("onResourceStart", resourceRoot, mFps.init)

function mFps.onPlayerQuit()
	
	mFps.players[source] = nil

end

function mFps.sync(fps)
	if not isElement(source) then return end
	
	mFps.players[source] = fps
	triggerLatentClientEvent("gra.mFPS.sync", resourceRoot, source, fps)

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