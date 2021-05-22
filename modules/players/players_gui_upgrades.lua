
mPlayers.gui.Upgrades = {}

mPlayers.gui.Upgrades.player = nil

function mPlayers.gui.Upgrades.init()

	mPlayers.gui.Upgrades.window = guiCreateWindow(nil, nil, nil, nil, "Player's vehicle upgrades")
	
	local mainVlo = guiCreateVerticalLayout(nil, GS.mrg2 + GS.mrgT, nil, nil, GS.mrg3, false, mPlayers.gui.Upgrades.window)
	guiVerticalLayoutSetHorizontalAlign(mainVlo, "center")
	local mainHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainHlo)
	mPlayers.gui.Upgrades.slotsElements = {}
	for i, slot in ipairs(getValidVehicleUpgradeSlots()) do
		mPlayers.gui.Upgrades.slotsElements[slot] = {}
		local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
		mPlayers.gui.Upgrades.slotsElements[slot].layout = hlo
		_, mPlayers.gui.Upgrades.slotsElements[slot].lbl = 
			guiCreateKeyValueLabels(nil, nil, nil, GS.w21, nil, getVehicleUpgradeSlotName(slot)..":", nil, nil, hlo)
		mPlayers.gui.Upgrades.slotsElements[slot].btn = guiCreateButton(nil, nil, GS.w21, nil, "", nil, hlo, "command.addplayerupgrades")
		mPlayers.gui.Upgrades.slotsElements[slot].list = guiButtonAddComboBox(mPlayers.gui.Upgrades.slotsElements[slot].btn)
		guiSetData(mPlayers.gui.Upgrades.slotsElements[slot].btn, "slot", slot)
		addEventHandler("onClientGUILeftClick", mPlayers.gui.Upgrades.slotsElements[slot].btn, mPlayers.gui.Upgrades.onClickUpgrade, false)
	end

	guiCreateHorizontalSeparator(nil, nil, nil, nil, vlo)
	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	local lbl = guiCreateLabel(nil, nil, nil, nil, "All:", nil, hlo)
	guiLabelSetHorizontalAlign(lbl, "right")
	mPlayers.gui.Upgrades.randomBtn = guiCreateButton(nil, nil, nil, nil, "Random", nil, hlo, "command.addplayerupgrades")
	mPlayers.gui.Upgrades.removeAllBtn = guiCreateButton(nil, nil, nil, nil, "Remove all", nil, hlo, "command.removeplayerupgrades")

	local vlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, mainHlo)
	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mPlayers.gui.Upgrades.paintJobLayout = hlo
	_, mPlayers.gui.Upgrades.paintJobVLbl = 
		guiCreateKeyValueLabels(nil, nil, nil, GS.w, nil, "Paint job:", nil, nil, hlo)
	mPlayers.gui.Upgrades.paintJobBtn = guiCreateButton(nil, nil, nil, nil, "", nil, hlo, "command.setplayerpaintjob")
	mPlayers.gui.Upgrades.paintJobList = guiButtonAddComboBox(mPlayers.gui.Upgrades.paintJobBtn)

	local hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, vlo)
	mPlayers.gui.Upgrades.colorsLbl = guiCreateLabel(nil, nil, nil, nil, "Colors:", nil, hlo)
	guiLabelSetHorizontalAlign(mPlayers.gui.Upgrades.colorsLbl, "right")
	local colorsVlo = guiCreateVerticalLayout(nil, nil, nil, nil, nil, nil, hlo)
	mPlayers.gui.Upgrades.colorsPickers = {}
	for i = 1, 4 do
		mPlayers.gui.Upgrades.colorsPickers[i] = guiCreateColorPicker(nil, nil, GS.w21, nil, nil, nil, nil, false, colorsVlo, "command.setplayervehiclecolor")
		guiSetData(mPlayers.gui.Upgrades.colorsPickers[i], "number", i)
	end
	
	_, mPlayers.gui.Upgrades.lightColorPicker = guiCreateKeyValueColorPicker(nil, nil, nil, GS.w21, nil, "Light color:", nil, nil, nil, false, vlo)

	hlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, nil, mainVlo)
	mPlayers.gui.Upgrades.okBtn = guiCreateButton(nil, nil, nil, nil, "Ok", nil, hlo)
	
	guiRebuildLayouts(mPlayers.gui.Upgrades.window)

	local w, h = guiGetSize(mainVlo, false)
	guiSetSize(mPlayers.gui.Upgrades.window, w + GS.mrg2*2, h + GS.mrg2*2 + GS.mrgT, false)
	guiCenter(mPlayers.gui.Upgrades.window)

	--------------------------------------------

	addEventHandler("onClientGUIRender", mPlayers.gui.Upgrades.window, mPlayers.gui.Upgrades.onRefresh, false)
	addEventHandler("onClientGUILeftClick", mPlayers.gui.Upgrades.window, mPlayers.gui.Upgrades.onClick)
	addEventHandler("onClientGUIColorPickerAccepted", mPlayers.gui.Upgrades.window, mPlayers.gui.Upgrades.onColorAccepted)

	return true
end

function mPlayers.gui.Upgrades.term()

	destroyElement(mPlayers.gui.Upgrades.window)

	return true
end

function mPlayers.gui.Upgrades.show(player)

	local vehicle = getPedOccupiedVehicle(player)
	if not vehicle then return false end

	mPlayers.gui.Upgrades.vehicle = vehicle
	mPlayers.gui.Upgrades.player = player
	guiSetText(mPlayers.gui.Upgrades.window, getPlayerName(player, true).."'s vehicle upgrades")
	mPlayers.gui.Upgrades.prepare()
	mPlayers.gui.Upgrades.refresh()
	
	return guiSetVisible(mPlayers.gui.Upgrades.window, true, true)
end

function mPlayers.gui.Upgrades.hide()
	
	return guiSetVisible(mPlayers.gui.Upgrades.window, false)
end

function mPlayers.gui.Upgrades.onRefresh()
	if not guiGetVisible(mPlayers.gui.Upgrades.window) then return end
	if not mPlayers.gui.Upgrades.player then return end

	if not isElement(mPlayers.gui.Upgrades.player) then
		mPlayers.gui.Upgrades.hide()
		guiShowMessageDialog("Player leave the game", nil, MD_OK, MD_INFO)
		return true
	end

	if getPedOccupiedVehicle(mPlayers.gui.Upgrades.player) ~= mPlayers.gui.Upgrades.vehicle then
		mPlayers.gui.Upgrades.hide()
		guiShowMessageDialog("Player leave the current vehicle", nil, MD_OK, MD_INFO)
		return true
	end

	mPlayers.gui.Upgrades.refresh()

end

function mPlayers.gui.Upgrades.onClick()

	if source == mPlayers.gui.Upgrades.okBtn then
		return mPlayers.gui.Upgrades.hide()

	elseif source == mPlayers.gui.Upgrades.removeAllBtn then
		local upgrades = getVehicleUpgrades(mPlayers.gui.Upgrades.vehicle)
		if #upgrades == 0 then return guiShowMessageDialog("Vehicle doesn't have upgrades", nil, MD_OK, MD_ERROR) end

		cCommands.execute("removeplayerupgrades", mPlayers.gui.Upgrades.player)

	elseif source == mPlayers.gui.Upgrades.randomBtn then
		cCommands.execute("addplayerupgrades", mPlayers.gui.Upgrades.player, mPlayers.gui.Upgrades.getRandomUpgrades())

	elseif source == mPlayers.gui.Upgrades.paintJobBtn then
		local paintjob = guiGridListGetSelectedItemData(mPlayers.gui.Upgrades.paintJobList)
		if getVehiclePaintjob(mPlayers.gui.Upgrades.vehicle) == paintjob then
			return guiShowMessageDialog("Vehicle paintjob is already "..(paintjob == 3 and NIL_TEXT or paintjob), nil, MD_OK, MD_ERROR)
		end
		cCommands.execute("setplayerpaintjob", mPlayers.gui.Upgrades.player, paintjob)
	
	end

end

function mPlayers.gui.Upgrades.onClickUpgrade()
	
	local slot = guiGetData(source, "slot")
	local upgrade = guiGridListGetSelectedItemData(mPlayers.gui.Upgrades.slotsElements[slot].list)
	if upgrade == 0 then
		local current = getVehicleUpgradeOnSlot(mPlayers.gui.Upgrades.vehicle, slot)
		return cCommands.execute("removeplayerupgrades", mPlayers.gui.Upgrades.player, current == 0 and nil or {current})
	end
	return cCommands.execute("addplayerupgrades", mPlayers.gui.Upgrades.player, {upgrade})

end

function mPlayers.gui.Upgrades.onColorAccepted(r, g, b)

	if source == mPlayers.gui.Upgrades.lightColorPicker then
		return cCommands.execute("setplayervehiclelightcolor", mPlayers.gui.Upgrades.player, r, g, b)

	end

	local number = guiGetData(source, "number")
	if not number then return end

	cCommands.execute("setplayervehiclecolor", mPlayers.gui.Upgrades.player, number, r, g, b)

end

function mPlayers.gui.Upgrades.getRandomUpgrades()

	local upgrades = {}
	for i, slot in ipairs(getValidVehicleUpgradeSlots()) do
		if slot == 8 then
			upgrades[#upgrades + 1] = 1010  -- nitro x10
		else
			local slotUpgrades = getVehicleCompatibleUpgrades(mPlayers.gui.Upgrades.vehicle, slot)
			if #slotUpgrades > 0 then
				upgrades[#upgrades + 1] = slotUpgrades[math.random(#slotUpgrades)]
			end
		end
	end

	return upgrades
end

function mPlayers.gui.Upgrades.prepare()

	for slot, slotGUI in pairs(mPlayers.gui.Upgrades.slotsElements) do
		guiGridListClear(slotGUI.list)
		guiGridListAddRow(slotGUI.list, "None")
		guiGridListSetItemData(slotGUI.list, 0, 1, 0)
		guiGridListSetSelectedItem(slotGUI.list, 0)

		local upgrades = getVehicleCompatibleUpgrades(mPlayers.gui.Upgrades.vehicle, slot)
		if #upgrades == 0 then
			guiSetEnabled(slotGUI.layout, false)
			guiSetText(slotGUI.lbl, "Incompatible")
		else
			for i, upgrade in ipairs(upgrades) do
				guiGridListAddRow(slotGUI.list, getVehicleUpgradeName(upgrade))
				guiGridListSetItemData(slotGUI.list, i, 1, upgrade)
			end
			guiSetEnabled(slotGUI.layout, true)
		end
		guiGridListAdjustHeight(slotGUI.list, math.min(#upgrades + 1, 10))
	end

	guiGridListClear(mPlayers.gui.Upgrades.paintJobList)
	guiGridListAddRow(mPlayers.gui.Upgrades.paintJobList, "None")
	guiGridListSetItemData(mPlayers.gui.Upgrades.paintJobList, 0, 1, 3)
	guiGridListSetSelectedItem(mPlayers.gui.Upgrades.paintJobList, 0)

	local paintjobs = getVehicleCompatiblePaintjobs(mPlayers.gui.Upgrades.vehicle)
	if #paintjobs == 0 then
		guiSetEnabled(mPlayers.gui.Upgrades.paintJobLayout, false)
		guiSetText(mPlayers.gui.Upgrades.paintJobVLbl, "Inc.")
	else
		for i, paintjob in ipairs(paintjobs) do
			guiGridListAddRow(mPlayers.gui.Upgrades.paintJobList, tostring(paintjob))
			guiGridListSetItemData(mPlayers.gui.Upgrades.paintJobList, i, 1, paintjob)
		end
		guiSetEnabled(mPlayers.gui.Upgrades.paintJobLayout, true)
	end
	guiGridListAdjustHeight(mPlayers.gui.Upgrades.paintJobList)

end

function mPlayers.gui.Upgrades.refresh()
	
	for slot, slotGUI in pairs(mPlayers.gui.Upgrades.slotsElements) do
		if guiGetEnabled(slotGUI.lbl) then
			local current = getVehicleUpgradeOnSlot(mPlayers.gui.Upgrades.vehicle, slot)
			guiSetText(slotGUI.lbl, current == 0 and NIL_TEXT or getVehicleUpgradeName(current))
		end
	end

	local upgrades = getVehicleUpgrades(mPlayers.gui.Upgrades.vehicle)
	guiSetEnabled(mPlayers.gui.Upgrades.removeAllBtn, #upgrades > 0)

	if guiGetEnabled(mPlayers.gui.Upgrades.paintJobVLbl) then
		local paintjob = getVehiclePaintjob(mPlayers.gui.Upgrades.vehicle)
		guiSetText(mPlayers.gui.Upgrades.paintJobVLbl, paintjob == 3 and NIL_TEXT or (paintjob + 1))
	end

	for number, picker in ipairs(mPlayers.gui.Upgrades.colorsPickers) do
		guiColorPickerSetColor(picker, getVehicleOneColor(mPlayers.gui.Upgrades.vehicle, number))
	end
	guiColorPickerSetColor(mPlayers.gui.Upgrades.lightColorPicker, getVehicleHeadLightColor(mPlayers.gui.Upgrades.vehicle))

	return true
end
