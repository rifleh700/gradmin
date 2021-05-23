
local BAD_PING = 400
local BAD_FPS = 10
local PED_TEXT = "[ped]"

mPlayers.gui = {}

function mPlayers.gui.init()

	local tab = cGUI.addTab("Players")
	mPlayers.gui.tab = tab

	local mainHlo = guiCreateHorizontalLayout(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, GS.mrg2, false, tab)
	guiSetRawSize(mainHlo, 1, 1, true)
	guiVerticalLayoutSetSizeFixed(mainHlo, true)

	mPlayers.gui.list = guiCreateGridList(nil, nil, nil, nil, nil, mainHlo)
	guiSetHeight(mPlayers.gui.list, 1, true)
	guiGridListSetAutoSearchEdit(mPlayers.gui.list, guiGridListCreateSearchEdit(mPlayers.gui.list))
	guiGridListSetContentPlayers(mPlayers.gui.list)

	local infoVlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainHlo)
	guiVerticalLayoutSetHorizontalAlign(infoVlo, "right")
	mPlayers.gui.playerLayout = infoVlo

	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)
	mPlayers.gui.nameLbl, mPlayers.gui.nameVLbl =
		guiCreateKeyValueLabels(0, 0, nil, GS.w3, GS.h, "Name:", nil, false, hlo)
	mPlayers.gui.setNameBtn = guiCreateButton(nil, nil, nil, nil, "Set name", false, hlo, "command.setplayername")
	mPlayers.gui.kickBtn = guiCreateButton(nil, nil, nil, nil, "Kick", false, hlo, "command.kick")
	mPlayers.gui.banBtn = guiCreateButton(nil, nil, nil, nil, "Ban", false, hlo, "command.ban")
	guiButtonSetHoverTextColor(mPlayers.gui.banBtn, unpack(GS.clr.red))
	
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)
	mPlayers.gui.serialLbl, mPlayers.gui.serialVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Serial:", nil, false, hlo)
	mPlayers.gui.versionLbl, mPlayers.gui.versionVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Version:", nil, false, hlo)
	mPlayers.gui.shoutBtn = guiCreateButton(nil, nil, nil, nil, "Shout!", false, hlo, "command.shout")
	mPlayers.gui.muteBtn = guiCreateButton(nil, nil, nil, nil, "Mute", false, hlo, "command.mute")

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)
	mPlayers.gui.ipLbl, mPlayers.gui.ipVLbl = 
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "IP:", nil, false, hlo)
	mPlayers.gui.countryLbl, mPlayers.gui.countryVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Country:", nil, false, hlo)
	mPlayers.gui.flagImg = guiCreateStaticImage(guiFontGetTextExtent("AAA"), 0, 0, 0, GUI_EMPTY_IMAGE_PATH, false, mPlayers.gui.countryVLbl)
	guiSetClippedByParent(mPlayers.gui.flagImg, false)
	guiSetVerticalAlign(mPlayers.gui.flagImg, "center")
	guiSetVisible(mPlayers.gui.flagImg, false)
	mPlayers.gui.freezeBtn = guiCreateButton(nil, nil, nil, nil, "Freeze", false, hlo, "command.freeze")
	mPlayers.gui.killBtn = guiCreateButton(nil, nil, nil, nil, "Kill", false, hlo, "command.killplayer")

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)
	mPlayers.gui.pingLbl, mPlayers.gui.pingVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Ping:", nil, false, hlo)
	mPlayers.gui.fpsLbl, mPlayers.gui.fpsVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "FPS:", nil, false, hlo)
	mPlayers.gui.spectateBtn = guiCreateButton(nil, nil, nil, nil, "Spectate", false, hlo, "command.spectate")
	mPlayers.gui.warpMeBtn = guiCreateButton(nil, nil, nil, nil, "Warp me", false, hlo, "command.warpplayertoplayer")
	
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)
	mPlayers.gui.accountLbl, mPlayers.gui.accountVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Account:", nil, false, hlo)

	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")
	mPlayers.gui.groupsLbl, mPlayers.gui.groupsVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Groups:", nil, false, vlo)
	mPlayers.gui.setGroupBtn = guiCreateButton(nil, nil, GS.w3, nil, "Set", false, vlo, "command.setplayeraclgroup")
	guiButtonSetHoverTextColor(mPlayers.gui.setGroupBtn, table.unpack(GS.clr.orange))
	mPlayers.gui.setGroupList = guiButtonAddComboBox(mPlayers.gui.setGroupBtn)
	guiGridListAddRow(mPlayers.gui.setGroupList, NIL_TEXT)
	guiGridListSetSelectedItem(mPlayers.gui.setGroupList, 0)

	guiCreateHorizontalSeparator(0, 0, 1, true, infoVlo)

	----------------------------------------------

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, false, infoVlo)
	mPlayers.gui.healthLbl, mPlayers.gui.healthVLbl = 
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Health:", nil, false, hlo)
	guiLabelSetClickableStyle(mPlayers.gui.healthVLbl, true)
	mPlayers.gui.armourLbl, mPlayers.gui.armourVLbl = 
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Armour:", nil, false, hlo)
	guiLabelSetClickableStyle(mPlayers.gui.armourVLbl, true)
	mPlayers.gui.healBtn = guiCreateButton(nil, nil, nil, nil, "Heal", false, hlo, "command.healplayer")
	mPlayers.gui.statsBtn = guiCreateButton(nil, nil, nil, nil, "Stats...", false, hlo, "command.setplayerstat")
	
	clmHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, false, infoVlo)
	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, clmHlo)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")
	mPlayers.gui.teamLbl, mPlayers.gui.teamVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Team:", nil, false, vlo)
	mPlayers.gui.teamBtn = guiCreateButton(0, 0, GS.w3, GS.h, "Set", false, vlo, "command.setplayerteam")
	mPlayers.gui.teamList = guiButtonAddComboBox(mPlayers.gui.teamBtn)
	mPlayers.gui.refreshTeams()
	addEventHandler("onClientGUIShow", mPlayers.gui.teamList, mPlayers.gui.refreshTeams, false)

	mPlayers.gui.skinLbl, mPlayers.gui.skinVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Skin:", nil, false, vlo)
	mPlayers.gui.skinBtn = guiCreateButton(0, 0, GS.w3, GS.h, "Set", false, vlo, "command.setplayerskin")
	mPlayers.gui.skinList = guiButtonAddComboBox(mPlayers.gui.skinBtn)	
	guiGridListAdjustHeight(mPlayers.gui.skinList, 12)
	for i, id in ipairs(getValidPedModels()) do
		local row = guiGridListAddRow(mPlayers.gui.skinList, getPedModelName(id))
		guiGridListSetItemData(mPlayers.gui.skinList, row, 1, id)
	end
	guiGridListSetAutoSearchEdit(mPlayers.gui.skinList, guiGridListCreateSearchEdit(mPlayers.gui.skinList))
	
	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, clmHlo)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")
	mPlayers.gui.weaponLbl, mPlayers.gui.weaponVLbl =
		guiCreateKeyValueLabels(0, 0, nil, GS.w3, nil, "Weapon:", nil, false, vlo)
	mPlayers.gui.giveWeaponBtn = guiCreateButton(0, 0, GS.w3, GS.h, "Give", false, vlo, "command.giveplayerweapon")
	mPlayers.gui.giveWeaponList = guiButtonAddComboBox(mPlayers.gui.giveWeaponBtn)	
	guiGridListAdjustHeight(mPlayers.gui.giveWeaponList, 12)
	for i, id in ipairs(getValidWeaponIDs()) do
		local row = guiGridListAddRow(mPlayers.gui.giveWeaponList, getWeaponNameFromID(id))
		guiGridListSetItemData(mPlayers.gui.giveWeaponList, row, 1, id)
	end
	guiGridListSetAutoSearchEdit(mPlayers.gui.giveWeaponList, guiGridListCreateSearchEdit(mPlayers.gui.giveWeaponList))
	mPlayers.gui.ammo = cSettings.get("ammo") or 30
	guiSetToolTip(mPlayers.gui.giveWeaponBtn, "Right click to set ammo")
	mPlayers.gui.takeWeaponBtn = guiCreateButton(x, y, GS.w3, GS.h, "Take", false, vlo, "command.takeplayerweapon")
	mPlayers.gui.takeWeaponList = guiButtonAddComboBox(mPlayers.gui.takeWeaponBtn)
	guiGridListAdjustHeight(mPlayers.gui.takeWeaponList, 12)
	guiGridListAddRow(mPlayers.gui.takeWeaponList, "All")
	guiGridListSetItemData(mPlayers.gui.takeWeaponList, 0, 1, -1)
	for i, id in ipairs(getValidWeaponIDs()) do
		local row = guiGridListAddRow(mPlayers.gui.takeWeaponList, getWeaponNameFromID(id))
		guiGridListSetItemData(mPlayers.gui.takeWeaponList, row, 1, id)
	end
	guiGridListSetAutoSearchEdit(mPlayers.gui.takeWeaponList, guiGridListCreateSearchEdit(mPlayers.gui.takeWeaponList))
	mPlayers.gui.jetPackBtn = guiCreateButton(nil, nil, GS.w3, nil, "Give JetPack", false, vlo, "command.giveplayerjetpack")

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)
	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	mPlayers.gui.areaLbl, mPlayers.gui.areaVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w21, nil, "Area:", nil, nil, vlo)
	mPlayers.gui.interiorLbl, mPlayers.gui.interiorVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Interior:", nil, nil, vlo)
	guiLabelSetClickableStyle(mPlayers.gui.interiorVLbl, true)
	mPlayers.gui.dimensionLbl, mPlayers.gui.dimensionVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, nil, nil, "Dimension:", nil, nil, vlo)
	guiLabelSetClickableStyle(mPlayers.gui.dimensionVLbl, true)

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	mPlayers.gui.posXLbl, mPlayers.gui.posXVLbl =
		guiCreateKeyValueLabels(nil, nil, GS.w, nil, nil, "X:", nil, nil, vlo)
	mPlayers.gui.posYLbl, mPlayers.gui.posYVLbl =
		guiCreateKeyValueLabels(nil, nil, GS.w, nil, nil, "Y:", nil, nil, vlo)
	mPlayers.gui.posZLbl, mPlayers.gui.posZVLbl =
		guiCreateKeyValueLabels(nil, nil, GS.w, nil, nil, "Z:", nil, nil, vlo)

	local posVlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	guiVerticalLayoutSetHorizontalAlign(posVlo, "right")
	mPlayers.gui.warpToMapBtn = guiCreateButton(0, 0, GS.w3, nil, "Warp to map...", false, posVlo, "command.warpplayertopoint")
	
	mPlayers.gui.warpToPlayerBtn = guiCreateButton(0, 0, GS.w3, nil, "Warp to", false, posVlo, "command.warpplayertoplayer")
	mPlayers.gui.warpToPlayerList = guiButtonAddComboBox(mPlayers.gui.warpToPlayerBtn)
	guiGridListSetContentPlayers(mPlayers.gui.warpToPlayerList)
	guiGridListSetAutoSearchEdit(mPlayers.gui.warpToPlayerList, guiGridListCreateSearchEdit(mPlayers.gui.warpToPlayerList))
	guiGridListSetSelectedItem(mPlayers.gui.warpToPlayerList, 0)
	guiGridListAdjustHeight(mPlayers.gui.warpToPlayerList, 15)

	mPlayers.gui.warpToInteriorBtn = guiCreateButton(x, y, GS.w3, nil, "Warp to", false, posVlo, "command.warpplayertointerior")
	guiSetProperty(mPlayers.gui.warpToInteriorBtn, "WordWrap", "True")
	mPlayers.gui.warpToInteriorList = guiButtonAddComboBox(mPlayers.gui.warpToInteriorBtn)
	guiGridListAdjustHeight(mPlayers.gui.warpToInteriorList, 10)
	for i, id in ipairs(getValidInteriorLocations()) do
		local row = guiGridListAddRow(mPlayers.gui.warpToInteriorList, getInteriorLocationName(id))
		guiGridListSetItemData(mPlayers.gui.warpToInteriorList, row, 1, id)
	end
	guiGridListSetAutoSearchEdit(mPlayers.gui.warpToInteriorList, guiGridListCreateSearchEdit(mPlayers.gui.warpToInteriorList))
	
	guiCreateHorizontalSeparator(0, 0, 1, true, infoVlo)

	----------------------------------------------

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)
	
	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")
	mPlayers.gui.vehicleLbl, mPlayers.gui.vehicleVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Vehicle:", nil, nil, vlo)

	mPlayers.gui.giveVehicleBtn, mPlayers.gui.giveVehicleList =
		guiCreateComboBoxButton(nil, nil, GS.w3, nil, "Give", false, vlo, "command.giveplayervehicle")
	guiGridListAdjustHeight(mPlayers.gui.giveVehicleList, 10)
	local sortedVehicleIDs = {}
	for i, id in ipairs(getValidVehicleModels()) do
		table.insert(sortedVehicleIDs, {id, getVehicleNameFromModel(id)})
	end
	table.sort(sortedVehicleIDs, function(a, b) return a[2] < b[2] end)
	for i, data in ipairs(sortedVehicleIDs) do
		local row = guiGridListAddRow(mPlayers.gui.giveVehicleList, data[2])
		guiGridListSetItemData(mPlayers.gui.giveVehicleList, row, 1, data[1])
	end
	guiGridListSetAutoSearchEdit(mPlayers.gui.giveVehicleList, guiGridListCreateSearchEdit(mPlayers.gui.giveVehicleList))

	mPlayers.gui.setVehicleBtn, mPlayers.gui.setVehicleList =
		guiCreateComboBoxButton(nil, nil, GS.w3, nil, "Set", false, vlo, "command.setplayervehicle")
	guiGridListAdjustHeight(mPlayers.gui.setVehicleList, 10)
	local sortedVehicleIDs = {}
	for i, id in ipairs(getValidVehicleModels()) do
		table.insert(sortedVehicleIDs, {id, getVehicleNameFromModel(id)})
	end
	table.sort(sortedVehicleIDs, function(a, b) return a[2] < b[2] end)
	for i, data in ipairs(sortedVehicleIDs) do
		local row = guiGridListAddRow(mPlayers.gui.setVehicleList, data[2])
		guiGridListSetItemData(mPlayers.gui.setVehicleList, row, 1, data[1])
	end
	guiGridListSetAutoSearchEdit(mPlayers.gui.setVehicleList, guiGridListCreateSearchEdit(mPlayers.gui.setVehicleList))


	vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	guiVerticalLayoutSetHorizontalAlign(vlo, "right")
	mPlayers.gui.vehicleHealthLbl, mPlayers.gui.vehicleHealthVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w3, nil, "Health:", nil, nil, vlo)
	guiLabelSetClickableStyle(mPlayers.gui.vehicleHealthVLbl, true)
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mPlayers.gui.fixVehicleBtn = guiCreateButton(nil, nil, nil, nil, "Fix", nil, hlo, "command.repairplayervehicle")
	mPlayers.gui.blowVehicleBtn = guiCreateButton(nil, nil, nil, nil, "Blow", nil, hlo, "command.blowplayervehicle")	
	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mPlayers.gui.ejectBtn = guiCreateButton(nil, nil, nil, nil, "Eject", false, hlo, "command.ejectplayer")
	mPlayers.gui.destroyVehicleBtn = guiCreateButton(nil, nil, nil, nil, "Destroy", false, hlo, "command.destroyplayervehicle")

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, infoVlo)
	mPlayers.gui.vehicleDriverLbl, mPlayers.gui.vehicleDriverVLbl =
		guiCreateKeyValueLabels(nil, nil, nil, GS.w4, nil, "Driver:", nil, nil, hlo)
	mPlayers.gui.customizeVehicleBtn = guiCreateButton(nil, nil, nil, nil, "Customize...", false, hlo, "command.addplayerupgrades")
	

	guiRebuildLayouts(tab)
	---------------------------------	

	addEventHandler("onClientGUIGridListItemSelected", mPlayers.gui.list, mPlayers.gui.onSelected)
	addEventHandler("onClientGUILeftClick", mPlayers.gui.tab, mPlayers.gui.onLeftClick)
	addEventHandler("onClientGUIRightClick", mPlayers.gui.tab, mPlayers.gui.onRightClick)
	
	addEventHandler("gra.cGUI.onRefresh", mPlayers.gui.tab, mPlayers.gui.onRefresh)

	---------------------------------

	mPlayers.gui.Ban.init()
	mPlayers.gui.Mute.init()
	mPlayers.gui.Stats.init()
	mPlayers.gui.Upgrades.init()
	
	return true
end

function mPlayers.gui.term()

	mPlayers.gui.Upgrades.term()
	mPlayers.gui.Stats.term()
	mPlayers.gui.Mute.term()
	mPlayers.gui.Ban.term()

	mPlayers.Spectator.disable()

	destroyElement(mPlayers.gui.tab)

	return true
end

function mPlayers.gui.onRefresh()
	local player = mPlayers.gui.getSelected()
	if not player then return end

	local data = mPlayers.data[player]
	if not data then return end

	guiSetText(mPlayers.gui.nameVLbl, getPlayerName(player, false))
	guiSetText(mPlayers.gui.freezeBtn, isElementFrozen(player) and "Unfreeze" or "Freeze")
	guiSetText(mPlayers.gui.healthVLbl, isPedDead(player) and "Dead" or math.ceil(getElementHealth(player)))
	guiSetText(mPlayers.gui.armourVLbl, math.ceil(getPedArmor(player)))
	
	local skin = getElementModel(player)
	guiSetText(mPlayers.gui.skinVLbl, formatNameID(getPedModelName(skin), skin))

	local team = getPlayerTeam(player)
	guiSetText(mPlayers.gui.teamVLbl, team and getTeamName(team))

	local ping = getPlayerPing(player)
	local fps = mFps.get(player)
	guiSetText(mPlayers.gui.pingVLbl, ping)
	guiSetText(mPlayers.gui.fpsVLbl, fps)
	guiLabelSetColor(mPlayers.gui.pingVLbl, unpack(ping >= BAD_PING and GS.clr.red or GS.clr.white))
	guiLabelSetColor(mPlayers.gui.fpsVLbl, unpack(fps and fps <= BAD_FPS and GS.clr.red or GS.clr.white))

	guiSetText(mPlayers.gui.dimensionVLbl, getElementDimension(player))
	guiSetText(mPlayers.gui.interiorVLbl, getElementInterior(player))
	guiSetText(mPlayers.gui.jetPackBtn, doesPedHaveJetPack(player) and "Remove JetPack" or "Give JetPack")

	local weapon = getPedWeapon(player)
	guiSetText(mPlayers.gui.weaponVLbl, weapon and formatNameID(getWeaponNameFromID(weapon), weapon))

	local x, y, z = getElementPosition(player)
	local area = getZoneName(x, y, z, false)
	local city = getZoneName(x, y, z, true)
	guiSetText(mPlayers.gui.areaVLbl, string.format("%s (%s)", area, city))
	guiSetText(mPlayers.gui.posXVLbl, math.round(x, 3))
	guiSetText(mPlayers.gui.posYVLbl, math.round(y, 3))
	guiSetText(mPlayers.gui.posZVLbl, math.round(z, 3))

	local vehicle = getPedOccupiedVehicle(player)
	guiSetText(mPlayers.gui.vehicleVLbl, vehicle and formatNameID(getVehicleName(vehicle), getElementModel(vehicle)))
	guiSetText(mPlayers.gui.vehicleHealthVLbl, vehicle and math.ceil(getElementHealth(vehicle)))
	
	local driver = vehicle and getVehicleOccupant(vehicle)
	guiSetText(mPlayers.gui.vehicleDriverVLbl, driver and (getElementType(driver) == "ped" and PED_TEXT or getPlayerName(driver, true)))
	guiSetEnabled(mPlayers.gui.vehicleDriverVLbl, driver and true or false)


	guiSetEnabled(mPlayers.gui.setVehicleBtn, vehicle and true or false)
	guiSetEnabled(mPlayers.gui.vehicleHealthVLbl, vehicle and true or false)
	guiSetEnabled(mPlayers.gui.fixVehicleBtn, vehicle and true or false)
	guiSetEnabled(mPlayers.gui.blowVehicleBtn, vehicle and true or false)
	guiSetEnabled(mPlayers.gui.ejectBtn, vehicle and true or false)
	guiSetEnabled(mPlayers.gui.destroyVehicleBtn, vehicle and true or false)
	guiSetEnabled(mPlayers.gui.customizeVehicleBtn, vehicle and true or false)

end

function mPlayers.gui.onSelected()
	
	mPlayers.gui.refreshPlayer()

end

function mPlayers.gui.onLeftClick()

	local player = mPlayers.gui.getSelected()
	if not player then return end

	local name = getPlayerName(player, true)
	local playerData = mPlayers.data[player]

	if source == mPlayers.gui.setNameBtn then
		local name = guiShowInputDialog("Set name", "Enter new name for "..name, getPlayerName(player), guiGetInputNotEmptyParser())
		if not name then return end
		cCommands.execute("setplayername", player, name)

	elseif source == mPlayers.gui.kickBtn then
		local reason = guiShowInputDialog("Kick player "..name, "Enter the kick reason", nil, guiGetInputNotEmptyParser(), true)
		if reason == false then return end
		
		return cCommands.execute("kick", player, reason)

	elseif source == mPlayers.gui.banBtn then
		return mPlayers.gui.Ban.show(player, playerData.serial, playerData.ip)

	elseif source == mPlayers.gui.shoutBtn then
		local text = guiShowInputDialog("Shout", "Enter text to be shown on player's screen", nil, guiGetInputNotEmptyParser())
		if not text then return end
		cCommands.execute("shout", player, text)

	elseif source == mPlayers.gui.muteBtn then
		if playerData.mute then
			local reason = guiShowInputDialog("Unmute player "..name, "Enter the unmute reason", nil, guiGetInputNotEmptyParser(), true)
			if reason == false then return end
			return cCommands.execute("unmute", player, reason)

		else
			return mPlayers.gui.Mute.show(player, playerData.serial)

		end
	  
	elseif source == mPlayers.gui.freezeBtn then
		cCommands.execute(isElementFrozen(player) and "unfreeze" or "freeze", player)

	elseif source == mPlayers.gui.killBtn then
		local reason = guiShowInputDialog("Kill player "..name, "Enter the kill reason", nil, guiGetInputNotEmptyParser(), true)
		if reason == false then return end

		return cCommands.execute("killplayer", player, reason)

	elseif source == mPlayers.gui.spectateBtn then
		mPlayers.Spectator.switch()
		
	elseif source == mPlayers.gui.warpMeBtn then
		cCommands.execute("warpplayertoplayer", localPlayer, player)

	elseif source == mPlayers.gui.setGroupBtn then
		local group = guiGridListGetSelectedItemText(mPlayers.gui.setGroupList)
		if group == NIL_TEXT then
			if not guiShowMessageDialog("Player admin rights will be revoked. Continue?", "Set player admin group", MD_YES_NO, MD_WARNING) then return end
			cCommands.execute("resetplayeraclgroup", player)
		else
			if not guiShowMessageDialog("Player admin rights will be set to '"..group.."' group. Continue?", "Set player admin group", MD_YES_NO, MD_WARNING) then return end
			cCommands.execute("setplayeraclgroup", player, group)
		end

	elseif source == mPlayers.gui.healthVLbl then
		local health = guiShowInputDialog("Set health", "Enter the health value (0 - 200)", "200", guiGetInputNumericParser(false, 0, 200), true, guiGetInputNumericMatcher(false, 0, 200, 200))
		if health == false then return end

		cCommands.execute("setplayerhealth", player, health)

	elseif source == mPlayers.gui.armourVLbl then
		local armour = guiShowInputDialog("Set armour", "Enter the armour value (0 - 100)", "100", guiGetInputNumericParser(false, 0, 100), true, guiGetInputNumericMatcher(false, 0, 100, 100))
		if armour == false then return end

		cCommands.execute("setplayerarmour", player, armour)

	elseif source == mPlayers.gui.healBtn then
		cCommands.execute("healplayer", player)

	elseif source == mPlayers.gui.statsBtn then
		mPlayers.gui.Stats.show(player)

	elseif source == mPlayers.gui.teamBtn then
		local row = guiGridListGetSelectedItem(mPlayers.gui.teamList)
		if row == 0 then return cCommands.execute("setplayerteam", player) end

		local team = getTeamFromName(guiGridListGetItemText(mPlayers.gui.teamList, row))
		if not team then
			mPlayers.gui.refreshTeams()
			return guiShowMessageDialog("Team doesn't exist. List was updated", "Set player team", MD_OK, MD_ERROR)
		end

		return cCommands.execute("setplayerteam", player, team)

	elseif source == mPlayers.gui.giveWeaponBtn then
		cCommands.execute("giveplayerweapon", player, guiGridListGetSelectedItemData(mPlayers.gui.giveWeaponList), mPlayers.gui.ammo)

	elseif source == mPlayers.gui.takeWeaponBtn then
		local selected = guiGridListGetSelectedItemData(mPlayers.gui.takeWeaponList)
		if selected == -1 then
			cCommands.execute("takeplayerallweapon", player)
		else
			cCommands.execute("takeplayerweapon", player, selected)
		end

	elseif source == mPlayers.gui.jetPackBtn then
		cCommands.execute(doesPedHaveJetPack(player) and "removeplayerjetpack" or "giveplayerjetpack", player)

	elseif source == mPlayers.gui.skinBtn then
		cCommands.execute("setplayerskin", player, guiGridListGetSelectedItemData(mPlayers.gui.skinList))

	elseif source == mPlayers.gui.interiorVLbl then
		local interior = guiShowInputDialog("Set interior", "Enter interior ID between 0 and 255", getElementInterior(player), guiGetInputNumericParser(true, 0, 255), false, guiGetInputNumericMatcher(true, 0, 255, getElementInterior(player)))
		if not interior then return end

		cCommands.execute("setplayerinterior", player, interior)
	
	elseif source == mPlayers.gui.dimensionVLbl then
		local dimension = guiShowInputDialog("Set dimension", "Enter dimension ID between 0 and 65535", getElementDimension(player), guiGetInputNumericParser(true, 0, 65535), false, guiGetInputNumericMatcher(true, 0, 65535, getElementDimension(player)))
		if not dimension then return end

		cCommands.execute("setplayerdimension", player, dimension)
		
	elseif source == mPlayers.gui.warpToMapBtn then
		local px, py, pz = getElementPosition(player)
		local x, y, z = guiShowMapDialog(px, py, pz, true)
		if not x then return end

		cCommands.execute("warpplayertopoint", player, x, y, z)

	elseif source == mPlayers.gui.warpToPlayerBtn then
		cCommands.execute("warpplayertoplayer", player, guiGridListGetSelectedItemData(mPlayers.gui.warpToPlayerList))

	elseif source == mPlayers.gui.warpToInteriorBtn then
		cCommands.execute("warpplayertointerior", player, guiGridListGetSelectedItemData(mPlayers.gui.warpToInteriorList))

	elseif source == mPlayers.gui.giveVehicleBtn then
		cCommands.execute("giveplayervehicle", player, guiGridListGetSelectedItemData(mPlayers.gui.giveVehicleList))

	elseif source == mPlayers.gui.setVehicleBtn then
		cCommands.execute("setplayervehicle", player, guiGridListGetSelectedItemData(mPlayers.gui.setVehicleList))

	elseif source == mPlayers.gui.customizeVehicleBtn then
		mPlayers.gui.Upgrades.show(player)

	elseif source == mPlayers.gui.vehicleHealthVLbl then
		local health = guiShowInputDialog("Set vehicle health", "Enter the health value (0 - 1000)", "1000", guiGetInputNumericParser(false, 0, 1000), true, guiGetInputNumericMatcher(false, 0, 1000))
		if health == false then return end
		
		cCommands.execute("setplayervehiclehealth", player, health)

	elseif source == mPlayers.gui.fixVehicleBtn then
		cCommands.execute("repairplayervehicle", player)

	elseif source == mPlayers.gui.blowVehicleBtn then
		cCommands.execute("blowplayervehicle", player)

	elseif source == mPlayers.gui.ejectBtn then
		cCommands.execute("ejectplayer", player)

	elseif source == mPlayers.gui.destroyVehicleBtn then
		cCommands.execute("destroyplayervehicle", player)

	elseif source == mPlayers.gui.vehicleDriverVLbl then
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return end

		local driver = getVehicleOccupant(vehicle)
		if not driver or driver == player then return end

		mPlayers.gui.setSelected(driver)

	end
end

function mPlayers.gui.onRightClick(key)

	if source == mPlayers.gui.giveWeaponBtn then
		local ammo = guiShowInputDialog("Weapon ammo", "Enter ammo value", mPlayers.gui.ammo, guiGetInputNumericParser(true, 1, 1048576), false, guiGetInputNumericMatcher(true, 1))
		if not ammo then return end

		mPlayers.gui.ammo = ammo
	
	end
end

function mPlayers.gui.setFlag(country)

	if not guiStaticImageLoadImage(mPlayers.gui.flagImg, mIP2C.getCountryFlagImagePath(country)) then
		return false
	end

	guiStaticImageSetSizeNative(mPlayers.gui.flagImg)
	guiSetVisible(mPlayers.gui.flagImg, true)

	return true
end

function mPlayers.gui.getSelected()
	return guiGridListGetSelectedItemData(mPlayers.gui.list)
end

function mPlayers.gui.setSelected(player)
	
	local row = guiGridListGetItemByData(mPlayers.gui.list, player)
	if not row then return false end

	return guiGridListSetSelectedItem(mPlayers.gui.list, row)
end

function mPlayers.gui.refreshGroups()
	local selected = guiGridListGetSelectedItemText(mPlayers.gui.setGroupList)
	guiGridListClear(mPlayers.gui.setGroupList)
	guiGridListAddRow(mPlayers.gui.setGroupList, NIL_TEXT)
	guiGridListSetSelectedItem(mPlayers.gui.setGroupList, 0)
	for i, group in ipairs(mPlayers.aclGroups) do
		guiGridListAddRow(mPlayers.gui.setGroupList, group)
		if selected == group then
			guiGridListSetSelectedItem(mPlayers.gui.setGroupList, i)
		end
	end
	guiGridListAdjustHeight(mPlayers.gui.setGroupList)
	return true
end

function mPlayers.gui.refreshTeams()
	
	local selected = guiGridListGetSelectedItem(mPlayers.gui.teamList)
	guiGridListClear(mPlayers.gui.teamList)
	guiGridListAddRow(mPlayers.gui.teamList, NIL_TEXT)
	for i, team in ipairs(getElementsByType("team")) do
		guiGridListAddRow(mPlayers.gui.teamList, getTeamName(team))
	end
	guiGridListSetSelectedAnyItem(mPlayers.gui.teamList, selected)
	guiGridListAdjustHeight(mPlayers.gui.teamList, math.min(10, guiGridListGetRowCount(mPlayers.gui.teamList)))

	return true
end

function mPlayers.gui.refreshPlayer(player)

	local selected = mPlayers.gui.getSelected()
	if not player then player = selected end

	if not player then
		guiSetVisible(mPlayers.gui.flagImg, false)
		guiSetEnabled(mPlayers.gui.playerLayout, false)

		guiSetText(mPlayers.gui.nameVLbl)
		guiSetText(mPlayers.gui.ipVLbl)
		guiSetText(mPlayers.gui.serialVLbl)
		guiSetText(mPlayers.gui.versionVLbl)
		guiSetText(mPlayers.gui.accountVLbl)
		guiSetText(mPlayers.gui.countryVLbl)
		guiSetVisible(mPlayers.gui.flagImg, false)
		guiSetText(mPlayers.gui.groupsVLbl)
		guiSetText(mPlayers.gui.healthVLbl)
		guiSetText(mPlayers.gui.armourVLbl)
		guiSetText(mPlayers.gui.skinVLbl)
		guiSetText(mPlayers.gui.teamVLbl)
		guiSetText(mPlayers.gui.pingVLbl)
		guiSetText(mPlayers.gui.fpsVLbl)
		guiSetText(mPlayers.gui.dimensionVLbl)
		guiSetText(mPlayers.gui.interiorVLbl)
		guiSetText(mPlayers.gui.weaponVLbl)
		guiSetText(mPlayers.gui.areaVLbl)
		guiSetText(mPlayers.gui.posXVLbl)
		guiSetText(mPlayers.gui.posYVLbl)
		guiSetText(mPlayers.gui.posZVLbl)
		guiSetText(mPlayers.gui.vehicleVLbl)
		guiSetText(mPlayers.gui.vehicleHealthVLbl)
		guiSetText(mPlayers.gui.vehicleDriverVLbl)

		return true
	end

	if player and player ~= selected then return true end

	local data = mPlayers.data[player]
	guiSetText(mPlayers.gui.ipVLbl, data.ip)
	guiSetText(mPlayers.gui.versionVLbl, data.version)
	guiSetText(mPlayers.gui.serialVLbl, data.serial)
	guiSetText(mPlayers.gui.countryVLbl, data.country)
	mPlayers.gui.setFlag(data.country)

	guiSetToolTip(mPlayers.gui.countryVLbl, data.countryname)
	guiSetToolTip(mPlayers.gui.flagImg, data.countryname)

	guiSetText(mPlayers.gui.accountVLbl, data.account)
	guiSetEnabled(mPlayers.gui.accountVLbl, data.account and true or false)

	guiSetText(mPlayers.gui.groupsVLbl, data.groups and table.concat(data.groups, ","))
	guiSetText(mPlayers.gui.nameVLbl, getPlayerName(player))

	guiSetEnabled(mPlayers.gui.setGroupBtn, data.account and true or false)
	
	guiSetText(mPlayers.gui.muteBtn, data.mute and "Unmute" or "Mute")

	guiSetEnabled(mPlayers.gui.playerLayout, true)

	mPlayers.gui.onRefresh()

end