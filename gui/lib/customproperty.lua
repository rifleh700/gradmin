
local properties = {}

function guiSetCustomProperty(element, key, value)
	if not scheck("u:element:gui,s") then return false end

	local elementProperties = properties[element] or {}
	if elementProperties[key] == value then return false end

	elementProperties[key] = value
	properties[element] = elementProperties

	return true
end

function guiGetCustomProperty(element, key)
	if not scheck("u:element:gui,s") then return false end
	
	if not properties[element] then return nil end
	return properties[element][key]
end

addEventHandler("onClientElementDestroy", guiRoot,
	function()
		properties[source] = nil
	end,
	true,
	"low"
)