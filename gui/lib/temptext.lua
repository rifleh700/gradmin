
local DEFAULT_INTERVAL = 1 * 10^3

local TempText = {}

function TempText.reset(element, text)
	if not isElement(element) then return end
	if guiGetText(element) ~= text then return end

	guiSetText(element, guiGetInternalData(element, "tempText.original"))
	guiSetInternalData(element, "tempText.original", nil)
	guiSetInternalData(element, "tempText.timer", nil)

end

function guiSetTempText(element, text, interval)
	if not scheck("u:element:gui,s,?n") then return false end
	if interval and interval < 1 then return warn("invalid interval", 2) and false end

	if not text then text = "" end
	if not interval then interval = DEFAULT_INTERVAL end
	
	guiSetInternalData(element, "tempText.original", guiGetInternalData(element, "tempText.original") or guiGetText(element))
	guiSetText(element, text)
	
	local timer = guiGetInternalData(element, "tempText.timer")
	if timer and isTimer(timer) then killTimer(timer) end

	timer = setTimer(TempText.reset, interval, 1, element, text)
	guiSetInternalData(element, "tempText.timer", timer)

	return true
end