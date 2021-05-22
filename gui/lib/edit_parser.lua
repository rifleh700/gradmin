
function guiEditSetParser(edit, parser)
	if not scheck("u:element:gui-edit,?f") then return false end

	return guiSetInternalData(edit, "parser", parser)
end

function guiEditGetParser(edit)
	if not scheck("u:element:gui-edit") then return false end

	return guiGetInternalData(edit, "parser")
end

function guiEditGetParsedValue(edit)
	if not scheck("u:element:gui-edit") then return false end
	
	local text = guiGetText(edit)
	local parser = guiGetInternalData(edit, "parser")
	if not parser then return text end

	return parser(text)
end