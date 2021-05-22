
addEvent("onClientGUIEnabled", false)
addEvent("onClientGUIDisabled", false)
addEvent("onClientGUIShow", false)
addEvent("onClientGUIHide", false)
addEvent("onClientGUILeftClick", false)
addEvent("onClientGUIRightClick", false)
addEvent("onClientGUIMiddleClick", false)
addEvent("onClientGUIDoubleLeftClick", false)
addEvent("onClientGUIRender", false)

local _guiSetEnabled = guiSetEnabled
function guiSetEnabled(element, state)
	if not scheck("u:element:gui,b") then return false end
	if guiGetBooleanProperty(element, "Disabled") == not state then return false end

	local set = _guiSetEnabled(element, state)
	if not set then return set end 
	
	triggerEvent(state and "onClientGUIEnabled" or "onClientGUIDisabled", element)

	return true
end

local _guiSetVisible = guiSetVisible
function guiSetVisible(element, state, ...)
	if not scheck("u:element:gui,b") then return false end

	local set = _guiSetVisible(element, state, ...)
	if not set then return set end

	triggerEvent(state and "onClientGUIShow" or "onClientGUIHide", element)

	return true
end

addEventHandler("onClientGUIClick", guiRoot,
	function(button, state, absoluteX, absoluteY)

		if button == "left" then
			triggerEvent("onClientGUILeftClick", source, absoluteX, absoluteY)

		elseif button == "right" then
			triggerEvent("onClientGUIRightClick", source, absoluteX, absoluteY)

		elseif button == "middle" then
			triggerEvent("onClientGUIMiddleClick", source, absoluteX, absoluteY)
			
		end
	end
)

addEventHandler("onClientGUIDoubleClick", guiRoot,
	function(button, state, absoluteX, absoluteY)
		if button ~= "left" then return end
		if state ~= "up" then return end

		triggerEvent("onClientGUIDoubleLeftClick", source, absoluteX, absoluteY)

	end
)

local render = false
addEventHandler("onClientRender", root,
	function()
		render = not render
		if not render then return end
		
		for i, element in ipairs(getElementChildren(guiRoot)) do
			if guiGetVisible(element) then triggerEvent("onClientGUIRender", element) end
		end
		
	end
)