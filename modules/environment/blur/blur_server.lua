
addEvent("onBlurChange", false)

local DEFAULT_BLUR = 36

local serverBlur = false

addEventHandler("gra.onPlayerReady", root,
	function()
		if not serverBlur then return end

		setPlayerBlurLevel(source, serverBlur)
	
	end
)

function setBlurLevel(blur)
	if not scheck("byte") then return false end
	if blur == serverBlur then return false end

	serverBlur = blur
	for i, player in ipairs(getElementsByType("player")) do
		setPlayerBlurLevel(player, blur)
	end
	triggerEvent("onBlurChange", root, blur)
	
	return true
end

function resetBlurLevel()
	if serverBlur == false then return false end

	serverBlur = false
	for i, player in ipairs(getElementsByType("player")) do
		setPlayerBlurLevel(player, DEFAULT_BLUR)
	end
	triggerEvent("onBlurChange", root, false)

	return true
end

function getBlurLevel()
	
	return serverBlur
end