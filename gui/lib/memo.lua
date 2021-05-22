
local Memo = {}

function Memo.onChanged()
	
	if utf8.sub(guiGetText(this), -2, -2) ~= "\n" then return end
	
	triggerEvent("onClientGUIAccepted", this, this)

end

local _guiCreateMemo = guiCreateMemo
function guiCreateMemo(x, y, width, height, text, relative, parent)
	if not scheck("n[4],s,b,?u:element:gui") then return false end
	
	local memo = _guiCreateMemo(x, y, width, height, text, relative, parent)
	if not memo then return memo end

	addEventHandler("onClientGUIChanged", memo, Memo.onChanged, false)

	return memo
end

function guiMemoSetWordWrap(memo, state)
	if not scheck("u:element:gui-memo,b") then return false end

	return guiSetBooleanProperty(memo, "WordWrap", state)
end

function guiMemoGetCaratIndex(memo)
	if not scheck("u:element:gui-memo") then return false end

	return guiGetNumericProperty(memo, "CaratIndex")
end

function guiMemoSetCaratIndex(memo, index)
	if not scheck("u:element:gui-memo,n") then return false end

	return guiSetNumericProperty(memo, "CaratIndex", index)
end