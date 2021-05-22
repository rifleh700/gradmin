
local CHAT_PREFIX = "(admin) "
local CHAT_COLOR = COLORS.orange
local CHATBOX_LIMIT = 95

mAdmChat = {}

function mAdmChat.init()

	mAdmChat.members = {}
	mAdmChat.history = {}
	mAdmChat.full = false

	cSync.addHandler("AdmChat.members", mAdmChat.sync.members)
	cSync.addHandler("AdmChat.message", mAdmChat.sync.message)
	cSync.addHandler("AdmChat.history", mAdmChat.sync.history)

	addEventHandler("onClientPlayerQuit", root, mAdmChat.onPlayerQuit)

	mAdmChat.gui.init()

	cSync.request("AdmChat.members")
	cSync.request("AdmChat.history", nil)
	
	return true
end

function mAdmChat.term()

	cSync.removeHandler("AdmChat.members", mAdmChat.sync.members)
	cSync.removeHandler("AdmChat.history", mAdmChat.sync.history)
	cSync.removeHandler("AdmChat.message", mAdmChat.sync.message)

	removeEventHandler("onClientPlayerQuit", root, mAdmChat.onPlayerQuit)

	mAdmChat.gui.term()

	return true
end

cModules.register(mAdmChat, "general.adminchat")

function mAdmChat.onPlayerQuit()

	table.removevalue(mAdmChat.members, source)
	mAdmChat.gui.refreshMembers()

end

function mAdmChat.requestHistory()
	if mAdmChat.full then return false end

	local lastID = mAdmChat.history[#mAdmChat.history].id
	if not cSync.request("AdmChat.history", lastID) then return false end
	
	return true
end

mAdmChat.sync = {}

function mAdmChat.sync.members(members)

	mAdmChat.members = members
	mAdmChat.gui.refreshMembers()

end

function mAdmChat.sync.history(lastID, messages)

	local size = #mAdmChat.history
	if size > 0 and mAdmChat.history[size].id ~= lastID then return end

	if #messages == 0 then
		mAdmChat.full = true
		return
	end

	for i, data in ipairs(messages) do
		mAdmChat.history[size + i] = data
	end
	mAdmChat.gui.refreshHistory(#messages)

end

function mAdmChat.sync.message(player, data)

	outputChatBox(
		string.format("%s%s%s: %s%s",
			rgb2hexs(table.unpack(CHAT_COLOR)),
			CHAT_PREFIX,
			"#FFFFFF"..data.name,
			rgb2hexs(table.unpack(CHAT_COLOR)),
			#data.message > CHATBOX_LIMIT and utf8.sub(data.message, 1, CHATBOX_LIMIT).."..." or data.message
		),
		255, 255, 255,
		true
	)

	if player ~= localPlayer then playSoundFrontEnd(13) end
	
	table.insert(mAdmChat.history, 1, data)
	mAdmChat.gui.output(data)

end