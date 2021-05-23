
cElementsData = {}

local elementsData = {}

function cElementsData.set(element, key, value)
	if not scheck("u:element,s") then return false end

	local data = elementsData[element]
	if not data then
		data = {}
		elementsData[element] = data
	end	

	if data[key] == value then return false end
	
	data[key] = value

	return true
end

function cElementsData.merge(element, map)
	if not scheck("u:element,t") then return false end

	if table.empty(map) then return false end

	local data = elementsData[element]
	if not data then
		data = {}
		elementsData[element] = data
	end

	for k, v in pairs(map) do
		data[k] = v
	end 

	return true
end

function cElementsData.get(element, key)
	if not scheck("u:element,s") then return false end

	local data = elementsData[element]
	if not data then return nil end

	return data[key]
end

addEventHandler("onElementDestroy", root,
	function()
		elementsData[source] = nil
	end,
	true,
	"low"
)

addEventHandler("onPlayerQuit", root,
	function()
		elementsData[source] = nil
	end,
	true,
	"low"
)