
addEvent("gra.mFps.sync", true)

mFps = {}

function mFps.init()
	
	addEventHandler("gra.mFps.sync", root, mFps.sync)

	return true
end

addEventHandler("onResourceStart", resourceRoot, mFps.init)

function mFps.sync(fps)
	if not isElement(source) then return end
	
	cElementsData.set(source, "mFps.fps", fps)
	triggerLatentClientEvent("gra.mFps.sync", source, fps)

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