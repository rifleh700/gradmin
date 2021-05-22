
sourceGUIFocus = nil

addEventHandler("onClientGUIFocus", guiRoot,
	function()
		sourceGUIFocus = source
		guiSetInternalData(source, "focus", true)
	end
)

addEventHandler("onClientGUIBlur", guiRoot,
	function()
		guiSetInternalData(source, "focus", false)
	end
)

function guiGetFocused()

	return sourceGUIFocus
end

function guiGetFocus(element)
	if not scheck("u:element:gui") then return false end

	return guiGetInternalData(element, "focus") or false
end