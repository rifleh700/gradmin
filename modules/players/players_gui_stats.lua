
mPlayers.gui.Stats = {}

mPlayers.gui.Stats.player = nil

function mPlayers.gui.Stats.init()

	mPlayers.gui.Stats.window = guiCreateWindow(nil, nil, nil, nil, "Player stats")
	
	local mainVlo = guiCreateVerticalLayout(nil, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, mPlayers.gui.Stats.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")
	local mainHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainHlo)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")
	mPlayers.gui.Stats.statLbls = {}
	for i, id in ipairs(getValidPedStatsByGroup("weapon")) do
		_, mPlayers.gui.Stats.statLbls[id] = 
			guiCreateKeyValueLabels(nil, nil, nil, nil, nil, getPedStatShortName(id)..":", nil, nil, vlo)
		guiLabelSetClickableStyle(mPlayers.gui.Stats.statLbls[id], true)
		guiSetData(mPlayers.gui.Stats.statLbls[id], "stat", id)
	end
	guiCreateHorizontalSeparator(nil, nil, nil, nil, vlo)
	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	local lbl = guiCreateLabel(nil, nil, nil, nil, "All:", nil, hlo)
	guiLabelSetHorizontalAlign(lbl, "right")
	mPlayers.gui.Stats.weaponZeroBtn = guiCreateButton(nil, nil, GS.w, nil, "Zero", nil, hlo, "command.setplayerweaponstats")
	mPlayers.gui.Stats.weaponFullBtn = guiCreateButton(nil, nil, GS.w, nil, "Full", nil, hlo, "command.setplayerweaponstats")

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainHlo)

	for i, id in ipairs(getValidPedStatsByGroup("body")) do
		_, mPlayers.gui.Stats.statLbls[id] = 
			guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, getPedStatShortName(id)..":", nil, nil, vlo)
		guiLabelSetClickableStyle(mPlayers.gui.Stats.statLbls[id], true)
		guiSetData(mPlayers.gui.Stats.statLbls[id], "stat", id)
	end

	guiCreateHorizontalSeparator(nil, nil, nil, nil, vlo)

	for i, id in ipairs(getValidPedStatsByGroup("driving")) do
		_, mPlayers.gui.Stats.statLbls[id] = 
			guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, getPedStatShortName(id)..":", nil, nil, vlo)
		guiLabelSetClickableStyle(mPlayers.gui.Stats.statLbls[id], true)
		guiSetData(mPlayers.gui.Stats.statLbls[id], "stat", id)
	end

	guiCreateHorizontalSeparator(nil, nil, nil, nil, vlo)

	local fightingVlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, vlo)
	guiVerticalLayoutSetHorizontalAlign(fightingVlo, "right")
	mPlayers.gui.Stats.fightingLbl, mPlayers.gui.Stats.fightingVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Fighting:", nil, false, fightingVlo)
	mPlayers.gui.Stats.fightingBtn = guiCreateButton(nil, nil, GS.w3, nil, "Set", false, fightingVlo, "command.setplayerfighting")
	mPlayers.gui.Stats.fightingList = guiButtonAddComboBox(mPlayers.gui.Stats.fightingBtn)
	for i, id in ipairs(getValidFightingStyles()) do
		local row = guiGridListAddRow(mPlayers.gui.Stats.fightingList, getFightingStyleName(id))
		guiGridListSetItemData(mPlayers.gui.Stats.fightingList, row, 1, id)
	end
	guiGridListSetSelectedItem(mPlayers.gui.Stats.fightingList, 0)
	guiGridListAdjustHeight(mPlayers.gui.Stats.fightingList, 10)

	local walkingVlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, vlo)
	guiVerticalLayoutSetHorizontalAlign(walkingVlo, "right")
	mPlayers.gui.Stats.walkingLbl, mPlayers.gui.Stats.walkingVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Walking:", nil, false, walkingVlo)
	mPlayers.gui.Stats.walkingBtn = guiCreateButton(nil, nil, GS.w3, nil, "Set", false, walkingVlo, "command.setplayerwalking")
	mPlayers.gui.Stats.walkingList = guiButtonAddComboBox(mPlayers.gui.Stats.walkingBtn)
	for i, id in ipairs(getValidWalkingStyles()) do
		local row = guiGridListAddRow(mPlayers.gui.Stats.walkingList, getWalkingStyleName(id))
		guiGridListSetItemData(mPlayers.gui.Stats.walkingList, row, 1, id)
	end
	guiGridListSetSelectedItem(mPlayers.gui.Stats.walkingList, 0)
	guiGridListAdjustHeight(mPlayers.gui.Stats.walkingList, 10)
	guiGridListSetAutoSearchEdit(mPlayers.gui.Stats.walkingList, guiGridListCreateSearchEdit(mPlayers.gui.Stats.walkingList))

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	mPlayers.gui.Stats.okBtn = guiCreateButton(nil, nil, nil, nil, "Ok", nil, hlo)
	
	guiRebuildLayouts(mPlayers.gui.Stats.window)

	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(mPlayers.gui.Stats.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)
	guiCenter(mPlayers.gui.Stats.window)

	----------------------------------------------

	addEventHandler("onClientPlayerQuit", root, mPlayers.gui.Stats.onQuit)
	addEventHandler("onClientGUIRender", mPlayers.gui.Stats.window, mPlayers.gui.Stats.refresh, false)
	addEventHandler("onClientGUILeftClick", mPlayers.gui.Stats.window, mPlayers.gui.Stats.onClick)

	return true
end

function mPlayers.gui.Stats.term()

	removeEventHandler("onClientPlayerQuit", root, mPlayers.gui.Stats.onQuit)

	destroyElement(mPlayers.gui.Stats.window)

	return true
end

function mPlayers.gui.Stats.show(player)

	mPlayers.gui.Stats.player = player
	guiSetText(mPlayers.gui.Stats.window, getPlayerName(player, true).."'s stats")
	mPlayers.gui.Stats.refresh()
	
	return guiSetVisible(mPlayers.gui.Stats.window, true, true)
end

function mPlayers.gui.Stats.hide()
	
	return guiSetVisible(mPlayers.gui.Stats.window, false)
end

function mPlayers.gui.Stats.onQuit()
	
	if source ~= mPlayers.gui.Stats.player then return end
	if not guiGetVisible(mPlayers.gui.Stats.window) then return end

	mPlayers.gui.Stats.hide()
	guiShowMessageDialog("Player leave the game", nil, MD_OK, MD_INFO)

end

function mPlayers.gui.Stats.onClick()

	if source == mPlayers.gui.Stats.okBtn then
		return mPlayers.gui.Stats.hide()

	elseif source == mPlayers.gui.Stats.fightingBtn then
		return cCommands.execute("setplayerfighting", mPlayers.gui.Stats.player, guiGridListGetSelectedItemData(mPlayers.gui.Stats.fightingList))

	elseif source == mPlayers.gui.Stats.walkingBtn then
		return cCommands.execute("setplayerwalking", mPlayers.gui.Stats.player, guiGridListGetSelectedItemData(mPlayers.gui.Stats.walkingList))
	
	elseif source == mPlayers.gui.Stats.weaponZeroBtn then
		return cCommands.execute("setplayerweaponstats",  mPlayers.gui.Stats.player, 0)

	elseif source == mPlayers.gui.Stats.weaponFullBtn then
		return cCommands.execute("setplayerweaponstats",  mPlayers.gui.Stats.player, 1000)

	end

	local id = guiGetData(source, "stat")
	if not id then return end

	local value = guiShowInputDialog("Set health", "Enter the health value", guiGetText(source), guiGetInputNumericParser(true, 0, 1000), false, guiGetInputNumericMatcher(true, 0, 1000))
	if not value then return end

	cCommands.execute("setplayerstat",  mPlayers.gui.Stats.player, id, value)

end

function mPlayers.gui.Stats.refresh()

	for stat, label in pairs(mPlayers.gui.Stats.statLbls) do
		guiSetText(label, getPedStat(mPlayers.gui.Stats.player, stat))
	end

	local fighting = getPedFightingStyle(mPlayers.gui.Stats.player)
	guiSetText(mPlayers.gui.Stats.fightingVLbl, formatNameID(getFightingStyleName(fighting), fighting))

	local walking = getPedWalkingStyle(mPlayers.gui.Stats.player)
	guiSetText(mPlayers.gui.Stats.walkingVLbl, formatNameID(getWalkingStyleName(walking), walking))	

	return true
end