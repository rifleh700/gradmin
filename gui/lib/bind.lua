
local Bind = {}

Bind.elementKeys = {}

function Bind.getElements(key)

	local elements = {}
	for element, keys in pairs(Bind.elementKeys) do
		if table.index(keys, key) then table.insert(elements, element) end
	end
	return elements
end

addEventHandler("onClientElementDestroy", guiRoot,
	function()
		
		Bind.elementKeys[source] = nil
	
	end
)

addEventHandler("onClientKey", root,
	function(button, press)
		if guiGetInputEnabled() then return end
		if not press then return end

		for i, element in ipairs(Bind.getElements(button)) do
			if guiGetFocus(guiGetGreatParent(element)) then guiClick(element) end
		end

	end
)

function guiBindKey(element, key)
	if not scheck("u:element:gui,s") then return false end

	local keys = Bind.elementKeys[element] or {}
	if table.index(keys, key) then return false end

	table.insert(keys, key)
	Bind.elementKeys[element] = keys

	return true
end

function guiGetBoundKeys(element)
	if not scheck("u:element:gui,s") then return false end

	return table.copy(Bind.elementKeys[element] or {})
end
