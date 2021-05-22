
local FORMAT = "jpeg"
local DEFAULT_QUALITY = 80

local screenSource = nil
local screenSourcePixels = false
local actual = false
local queue = {}

mScreenshot = {}

function mScreenshot.init()
	
	addEventHandler("onClientPreRender", root, mScreenshot.onPreRender)
	addEventHandler("onClientRender", root, mScreenshot.onRender)

	return true
end

addEventHandler("onClientResourceStart", resourceRoot, mScreenshot.init)

function mScreenshot.getPixels()

	if not screenSource then screenSource = dxCreateScreenSource(GUI_SCREEN_WIDTH, GUI_SCREEN_HEIGHT) end
	if not screenSource then return false end
	if not dxUpdateScreenSource(screenSource, true) then return false end
	
	return dxGetTexturePixels(screenSource)	
end

function mScreenshot.onPreRender()

	actual = false

	if #queue == 0 then return end

	screenSourcePixels = mScreenshot.getPixels()
	actual = true

end

function mScreenshot.onRender()

	if not actual then return end
	if #queue == 0 then return end

	for i, c in ipairs(queue) do
		coroutine.resume(c)
	end
	queue = {}
		
end

function mScreenshot.take(quality)
	if not scheck("?n") then return false end
	
	quality = quality and math.clamp(quality, 1, 100) or DEFAULT_QUALITY
	
	if not actual then
		table.insert(queue, coroutine.running())
		coroutine.yield()
		coroutine.sleep(0)
	end

	return dxConvertPixels(screenSourcePixels, FORMAT, quality)
end