
local data = {}

function guiSetData(element, key, value)
	if not scheck("u:element:gui,s") then return false end

	local elementData = data[element] or {}
	if elementData[key] == value then return false end

	elementData[key] = value
	data[element] = elementData

	return true
end

function guiGetData(element, key)
	if not scheck("u:element:gui,s") then return false end
	
	if not data[element] then return nil end
	return data[element][key]
end

addEventHandler("onClientElementDestroy", guiRoot,
	function()
		data[source] = nil
	end,
	true,
	"low"
)