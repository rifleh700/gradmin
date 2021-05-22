
function guiMemoSetParser(memo, parser)
	if not scheck("u:element:gui-memo,?f") then return false end

	return guiSetInternalData(memo, "parser", parser)
end

function guiMemoGetParser(memo)
	if not scheck("u:element:gui-memo") then return false end

	return guiGetInternalData(memo, "parser")
end

function guiMemoGetParsedValue(memo)
	if not scheck("u:element:gui-memo") then return false end
	
	local text = guiGetText(memo)
	local parser = guiGetInternalData(memo, "parser")
	if not parser then return text end

	return parser(text)
end