
local CATALOG = DATA_PATH.."screenshots/"
local POSTFIX = ".jpg"
local QUALITY = 80
local IGNORE_FILE_SIZE = 1 * 10^3 * 10^3 -- 1 MB
local LIMIT = 100
local TAKE_FRAMES_INTERVAL = 2

mScreenshotSaver = {}

mScreenshotSaver.frame = 0
mScreenshotSaver.takenFrame = 0

function mScreenshotSaver.init()
	
	mScreenshotSaver.removeUnwanted()

	addEventHandler("onClientRender", root, mScreenshotSaver.onRender)
	addEventHandler("onClientKey", root, mScreenshotSaver.onKey)

	return true
end

addEventHandler("onClientResourceStart", resourceRoot, mScreenshotSaver.init)

function mScreenshotSaver.onRender()
	
	mScreenshotSaver.frame = mScreenshotSaver.frame + 1

end

function mScreenshotSaver.onKey(button, press)
	if not press then return end
	if button ~= getKeyBoundToCommand("screenshot") then return end
	if not mScreenshotSaver.isEnabled() then return end
	if mScreenshotSaver.frame - mScreenshotSaver.takenFrame - 1 < TAKE_FRAMES_INTERVAL then return end

	mScreenshotSaver.takenFrame = mScreenshotSaver.frame

	local data = mScreenshot.take(QUALITY)
	if data then mScreenshotSaver.save(data) end

end

function mScreenshotSaver.isEnabled()

	local value = cGlobalSettings.get("reportscreenshots")
	if not value then return true end

	value = tonumber(value)
	if not value then return true end

	return value > 0
end

function mScreenshotSaver.getLastID()
	
	local setting = cSettings.get("screenshots")
	if not setting then return nil end

	setting = tonumber(setting)
	if not setting then return nil end

	return setting
end

function mScreenshotSaver.save(data)

	local id = (mScreenshotSaver.getLastID() or 0) + 1
	local path = CATALOG..id..POSTFIX
	if fileExists(path) then fileDelete(path) end

	local file = fileCreate(path)
	if not file then return false end

	fileWrite(file, data)
	fileFlush(file)
	fileClose(file)

	cSettings.set("screenshots", id)

	return id
end

function mScreenshotSaver.removeUnwanted()
	
	local ids = mScreenshotSaver.getValidIDs()
	while #ids > LIMIT do
		local id = table.remove(ids, 1)
		fileDelete(CATALOG..id..POSTFIX)
	end

	return true
end

function mScreenshotSaver.getValidIDs(limit)
	if not scheck("?n") then return false end

	local lastID = mScreenshotSaver.getLastID()
	if not lastID then return {} end

	local list = {} 
	for id = lastID, 1, -1 do
		if fileExists(CATALOG..id..POSTFIX) then
			list[#list + 1] = id
		end
		if limit and #list >= limit then break end
	end
	return list
end

function mScreenshotSaver.getPath(id)
	if not scheck("n") then return false end

	local path = CATALOG..id..POSTFIX
	if not fileExists(path) then return false end
	
	return path
end

function mScreenshotSaver.read(id)

	local path = CATALOG..id..POSTFIX
	if not fileExists(path) then return false end

	local file = fileOpen(path, true)
	if not file then return false end

	local size = fileGetSize(file)
	if size > IGNORE_FILE_SIZE then return fileClose(file) and false end

	local data = fileRead(file, size)
	fileClose(file)

	return data
end