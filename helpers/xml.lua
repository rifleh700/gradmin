
function xmlNodeGetData(node)
	if not scheck("u:xml-node") then return false end

	local data = {}
	data.name = xmlNodeGetName(node)
	data.value = xmlNodeGetValue(node)
	data.attributes = xmlNodeGetAttributes(node)
	data.children = {}

	local children = xmlNodeGetChildren(node)
	if #children == 0 then return data end

	for i, childNode in ipairs(children) do
		data.children[i] = xmlNodeGetData(childNode)
	end
	
	return data
end

function xmlFindChildByAttribute(node, name, attribute, value)
	if not scheck("u:xml-node,s[3]") then return false end
	
	for i, child in ipairs(xmlNodeGetChildren(node)) do
		if xmlNodeGetName(child) == name and xmlNodeGetAttribute(child, attribute) == value then return child end
	end
	return nil
end