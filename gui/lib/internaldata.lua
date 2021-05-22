
local data = {}

function guiSetInternalData(element, key, value)
	if not scheck("u:element:gui,s") then return false end

	if not data[element] then data[element] = {} end
	data[element][key] = value

	return true
end

function guiGetInternalData(element, key)
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