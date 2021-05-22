
local DATE_FORMAT = "%d/%m/%Y  %H:%M:%S"

mAdmChat.gui = {}

function mAdmChat.gui.init()

	local tab = cGUI.addTab("Chat")
	mAdmChat.gui.tab = tab

	local mainHlo = guiCreateHorizontalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, GS.mrg, false, tab)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiHorizontalLayoutSetSizeFixed(mainHlo, true)

	local memoVlo = guiCreateVerticalLayout(nil, nil, -GS.w3 - GS.mrg, 0, nil, false, mainHlo)
	guiSetRawSize(memoVlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(memoVlo, true)

	mAdmChat.gui.historyMemo = guiCreateMemo(nil, nil, 0, -GS.h3 - GS.mrg, "", false, memoVlo)
	guiSetRawSize(mAdmChat.gui.historyMemo, 1, 1, true)
	guiSetProperty(mAdmChat.gui.historyMemo, "ReadOnly", "true")
	guiMemoSetVerticalScrollPosition(mAdmChat.gui.historyMemo, 100)

	mAdmChat.gui.sayMemo = guiCreateMemo(nil, nil, 0, GS.h3, "", false, memoVlo)
	guiSetRawWidth(mAdmChat.gui.sayMemo, 1, true)
	guiMemoSetParser(mAdmChat.gui.sayMemo, guiGetInputNotEmptyParser())

	mAdmChat.gui.membersList = guiCreateGridList(nil, nil, GS.w3, 0, false, mainHlo)
	guiSetHeight(mAdmChat.gui.membersList, 1, true)
	guiGridListAddColumn(mAdmChat.gui.membersList, "Member")

	guiRebuildLayouts(tab)

	----------------------------------
	
	addEventHandler("onClientGUIAccepted", mAdmChat.gui.sayMemo, mAdmChat.gui.onAccepted, false)

	addEventHandler("gra.cGUI.onRefresh", mAdmChat.gui.tab, mAdmChat.gui.onRefresh)
	
	----------------------------------

	return true
end

function mAdmChat.gui.term()

	destroyElement(mAdmChat.gui.tab)

	return true
end

function mAdmChat.gui.onAccepted()

	guiFocus(source)

	local message = guiMemoGetParsedValue(mAdmChat.gui.sayMemo)
	if not message then return end

	guiSetText(mAdmChat.gui.sayMemo, "")
	cCommands.execute("admsay", message)

end

function mAdmChat.gui.onRefresh()
	if guiMemoGetVerticalScrollPosition(mAdmChat.gui.historyMemo) > 1 then return end
	
	mAdmChat.requestHistory()

end

function mAdmChat.gui.getMessageString(data)
	
	return string.format(
		"[%s] %s: %s",
		os.date(DATE_FORMAT, data.timestamp),
		stripColorCodes(data.name),
		data.message
	)
end

function mAdmChat.gui.refreshHistory(new)
	
	local caret = 0
	local text = ""
	for i, data in ipairs(table.reverse(table.copy(mAdmChat.history))) do
		text = text.."\n"..mAdmChat.gui.getMessageString(data)
		if i == new then caret = utf8.len(text) end
	end

	guiSetText(mAdmChat.gui.historyMemo, text)
	guiMemoSetVerticalScrollPosition(mAdmChat.gui.historyMemo, 100)
	guiMemoSetCaratIndex(mAdmChat.gui.historyMemo, caret)
	
	return true
end

function mAdmChat.gui.output(data)

	local scroll = guiMemoGetVerticalScrollPosition(mAdmChat.gui.historyMemo)
	local oldText = guiGetText(mAdmChat.gui.historyMemo)
	local newText = oldText..mAdmChat.gui.getMessageString(data).."\n"
	
	guiSetText(mAdmChat.gui.historyMemo, newText)

	if scroll > 99 then
		guiMemoSetVerticalScrollPosition(mAdmChat.gui.historyMemo, 100)
		guiMemoSetCaratIndex(mAdmChat.gui.historyMemo, utf8.len(newText))
	end

end

function mAdmChat.gui.refreshMembers()

	guiGridListClear(mAdmChat.gui.membersList)
	
	for i, admin in ipairs(mAdmChat.members) do
		guiGridListAddRow(mAdmChat.gui.membersList, getPlayerName(admin, true))
	end

end