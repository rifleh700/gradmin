
local gs = {
	lst = {
		clr = {
			active = {255, 255, 255},
			inactive = {75, 75, 75}
		},
		none = "[   ]"
	}
}

mAcl.gui.expert = {}

function mAcl.gui.expert.init()

	local tab = mAcl.gui.tab
	local tw, th = guiGetSize(tab, false)
	
	-----------------------------

	x, y = GS.mrg2, GS.mrg2
	w, h = tw - GS.mrg2*2, th - GS.mrg2*2 - GS.h - GS.mrg
	local tpnl = guiCreateTabPanel(x, y, w, h, false, tab)
	mAcl.gui.expert.tpnl = tpnl

	mAcl.gui.expert.restoreBtn = guiCreateButton(-x, -y, GS.w2, GS.h, "Restore", false, tab, "command.restoreacl")
	guiSetHorizontalAlign(mAcl.gui.expert.restoreBtn, "right")
	guiSetVerticalAlign(mAcl.gui.expert.restoreBtn, "bottom")
	guiSetAlwaysOnTop(mAcl.gui.expert.restoreBtn, true)
	guiButtonSetHoverTextColor(mAcl.gui.expert.restoreBtn, unpack(GS.clr.orange))

	x = x + GS.w2 + GS.mrg
	mAcl.gui.expert.restoreAdminBtn = guiCreateButton(-x, -y, GS.w3, GS.h, "Restore gradmin", false, tab, "command.restoreadminacl")
	guiSetHorizontalAlign(mAcl.gui.expert.restoreAdminBtn, "right")
	guiSetVerticalAlign(mAcl.gui.expert.restoreAdminBtn, "bottom")
	guiSetAlwaysOnTop(mAcl.gui.expert.restoreAdminBtn, true)
	guiButtonSetHoverTextColor(mAcl.gui.expert.restoreAdminBtn, unpack(COLORS.orange))

	-----------------------------

	mAcl.gui.expert.group = {}
	mAcl.gui.expert.group.tab = guiCreateTab("Groups", tpnl)

	tw, th = guiGetSize(mAcl.gui.expert.group.tab, false)
	x, y = GS.mrg2, GS.mrg2
	w, h = tw - GS.mrg2*2, th - GS.mrg2*2

	mAcl.gui.expert.group.list = guiCreateGridList(x, y, GS.w3, h, false, mAcl.gui.expert.group.tab)
	guiGridListSetSortingEnabled(mAcl.gui.expert.group.list, false)
	guiGridListAddColumn(mAcl.gui.expert.group.list, "Name")
	
	mAcl.gui.expert.group.createBtn = guiGridListAddCreateButton(mAcl.gui.expert.group.list)
	cGuiGuard.setPermission(mAcl.gui.expert.group.createBtn, "command.aclcreategroup")
	mAcl.gui.expert.group.destroyBtn = guiGridListAddDestroyButton(mAcl.gui.expert.group.list)
	cGuiGuard.setPermission(mAcl.gui.expert.group.destroyBtn, "command.acldestroygroup")

	x = x + GS.w3 + GS.mrg2
	mAcl.gui.expert.group.aclList = guiCreateGridList(x, y, GS.w3, h, false, mAcl.gui.expert.group.tab)
	guiGridListSetSortingEnabled(mAcl.gui.expert.group.aclList, false)
	guiGridListAddColumn(mAcl.gui.expert.group.aclList, "ACL")
	
	mAcl.gui.expert.group.addACLBtn = guiGridListAddCreateButton(mAcl.gui.expert.group.aclList)
	cGuiGuard.setPermission(mAcl.gui.expert.group.addACLBtn, "command.aclgroupaddacl")
	mAcl.gui.expert.group.removeACLBtn = guiGridListAddDestroyButton(mAcl.gui.expert.group.aclList)
	cGuiGuard.setPermission(mAcl.gui.expert.group.removeACLBtn, "command.aclgroupremoveacl")

	x = x + GS.w3 + GS.mrg
	w = w - GS.w3*2 - GS.mrg - GS.mrg2*2 - GS.w3
	mAcl.gui.expert.group.objectsList = guiCreateGridList(x, y, GS.w3, h, false, mAcl.gui.expert.group.tab)
	guiGridListSetSortingEnabled(mAcl.gui.expert.group.objectsList, false)
	guiGridListAddColumn(mAcl.gui.expert.group.objectsList, "Object")
	
	mAcl.gui.expert.group.addObjectBtn = guiGridListAddCreateButton(mAcl.gui.expert.group.objectsList)
	cGuiGuard.setPermission(mAcl.gui.expert.group.addObjectBtn, "command.aclgroupaddobject")
	mAcl.gui.expert.group.removeObjectBtn = guiGridListAddDestroyButton(mAcl.gui.expert.group.objectsList)
	cGuiGuard.setPermission(mAcl.gui.expert.group.removeObjectBtn, "command.aclgroupremoveobject")

	-----------------------------
	mAcl.gui.expert.acl = {}
	mAcl.gui.expert.acl.tab = guiCreateTab("ACL", tpnl)

	tw, th = guiGetSize(mAcl.gui.expert.acl.tab, false)
	x, y = GS.mrg2, GS.mrg2
	w, h = tw - GS.mrg2*2, th - GS.mrg2*2

	mAcl.gui.expert.acl.list = guiCreateGridList(x, y, GS.w3, h, false, mAcl.gui.expert.acl.tab)
	guiGridListSetSortingEnabled(mAcl.gui.expert.acl.list, false)
	guiGridListAddColumn(mAcl.gui.expert.acl.list, "Name")
	
	mAcl.gui.expert.acl.createBtn = guiGridListAddCreateButton(mAcl.gui.expert.acl.list)
	cGuiGuard.setPermission(mAcl.gui.expert.acl.createBtn, "command.aclcreate")
	mAcl.gui.expert.acl.destroyBtn = guiGridListAddDestroyButton(mAcl.gui.expert.acl.list)
	cGuiGuard.setPermission(mAcl.gui.expert.acl.destroyBtn, "command.acldestroy")
	
	x = GS.mrg2
	w = w - GS.w3 - GS.mrg2

	local chkw = 120
	mAcl.gui.expert.acl.showPublicContainer = guiCreateContainer(-x, y, chkw, GS.h, false, mAcl.gui.expert.acl.tab)
	guiSetHorizontalAlign(mAcl.gui.expert.acl.showPublicContainer, "right")
	mAcl.gui.expert.acl.showPublicChk = guiCreateCheckBox(0, 0, 1, 1, "Show public rights", false, true, mAcl.gui.expert.acl.showPublicContainer)
	
	x = x + GS.mrg2 + GS.w3
	mAcl.gui.expert.acl.rightViewEdit, mAcl.gui.expert.acl.rightViewlist =
		guiCreateAdvancedComboBox(x, y, GS.w2, GS.h, "", false, mAcl.gui.expert.acl.tab)
	guiGridListAddRow(mAcl.gui.expert.acl.rightViewlist, "all")
	guiGridListAddRow(mAcl.gui.expert.acl.rightViewlist, "general")
	guiGridListAddRow(mAcl.gui.expert.acl.rightViewlist, "function")
	guiGridListAddRow(mAcl.gui.expert.acl.rightViewlist, "command")
	guiGridListAddRow(mAcl.gui.expert.acl.rightViewlist, "resource")
	guiGridListAdjustHeight(mAcl.gui.expert.acl.rightViewlist)
	guiGridListSetSelectedItem(mAcl.gui.expert.acl.rightViewlist, 0)

	x = x + GS.w2 + GS.mrg
	mAcl.gui.expert.acl.rightSrch = guiCreateSearchEdit(x, y, w - GS.mrg*2 - GS.w2 - chkw, GS.h, "", false, mAcl.gui.expert.acl.tab)
	
	x = GS.mrg2 * 2 + GS.w3
	y = y + GS.h + GS.mrg
	h = h - GS.h - GS.mrg
	mAcl.gui.expert.acl.rightsList = guiCreateGridList(x, y, w, h, false, mAcl.gui.expert.acl.tab)
	guiGridListSetSortingEnabled(mAcl.gui.expert.acl.rightsList, false)
	mAcl.gui.expert.acl.rightsNameClm = guiGridListAddColumn(mAcl.gui.expert.acl.rightsList, "Right", 0.45)
	mAcl.gui.expert.acl.rightsAccessClm = guiGridListAddColumn(mAcl.gui.expert.acl.rightsList, "Access", 0.15)
	mAcl.gui.expert.acl.rightsPublicClm = mAcl.gui.expert.acl.rightsAccessClm + 1

	mAcl.gui.expert.acl.addRightBtn = guiGridListAddCreateButton(mAcl.gui.expert.acl.rightsList)
	cGuiGuard.setPermission(mAcl.gui.expert.acl.addRightBtn, "command.aclsetright")
	mAcl.gui.expert.acl.removeRightBtn = guiGridListAddDestroyButton(mAcl.gui.expert.acl.rightsList)
	cGuiGuard.setPermission(mAcl.gui.expert.acl.removeRightBtn, "command.aclremoveright")

	-----------------------------

	mAcl.gui.expert.matrix = {}
	mAcl.gui.expert.matrix.tab = guiCreateTab("Access matrix", tpnl)

	tw, th = guiGetSize(mAcl.gui.expert.acl.tab, false)
	x, y = GS.mrg2, GS.mrg2
	w, h = tw - GS.mrg2*2, th - GS.mrg2*2

	chkw = 120
	mAcl.gui.expert.matrix.showAutoChk = guiCreateCheckBox(-x, y, chkw, GS.h, "Show auto ACL", false, false, mAcl.gui.expert.matrix.tab)
	guiSetHorizontalAlign(mAcl.gui.expert.matrix.showAutoChk, "right")

	mAcl.gui.expert.matrix.viewEdit, mAcl.gui.expert.matrix.viewList =
		guiCreateAdvancedComboBox(x, y, GS.w2, GS.h, "", false, mAcl.gui.expert.matrix.tab)
	mAcl.gui.expert.matrix.srch = guiCreateSearchEdit(x + GS.mrg + GS.w2, y, w - GS.w2 - GS.mrg*2 - chkw, GS.h, "", false, mAcl.gui.expert.matrix.tab)
	guiGridListAddRow(mAcl.gui.expert.matrix.viewList, "all")
	guiGridListAddRow(mAcl.gui.expert.matrix.viewList, "general")
	guiGridListAddRow(mAcl.gui.expert.matrix.viewList, "function")
	guiGridListAddRow(mAcl.gui.expert.matrix.viewList, "command")
	guiGridListAddRow(mAcl.gui.expert.matrix.viewList, "resource")
	guiGridListAdjustHeight(mAcl.gui.expert.matrix.viewList)
	guiGridListSetSelectedItem(mAcl.gui.expert.matrix.viewList, 0)
	y = y + GS.h + GS.mrg

	mAcl.gui.expert.matrix.list = guiCreateGridList(x, y, w, h - GS.mrg - GS.h, false, mAcl.gui.expert.matrix.tab)
	guiGridListAddColumn(mAcl.gui.expert.matrix.list, "Right", 0.2)
	guiGridListSetSelectionMode(mAcl.gui.expert.matrix.list, 2)
	guiGridListSetSortingEnabled(mAcl.gui.expert.matrix.list, false)

	mAcl.gui.expert.matrix.removeRightBtn = guiGridListAddDestroyButton(mAcl.gui.expert.matrix.list)
	cGuiGuard.setPermission(mAcl.gui.expert.matrix.removeRightBtn, "command.aclremoveright")
	
	-----------------------------

	addEventHandler("onClientGUILeftClick", tab, mAcl.gui.expert.onLeftClick)
	addEventHandler("onClientGUIGridListItemSelected", tab, mAcl.gui.expert.onListItemSelected)
	
	addEventHandler("onClientGUIDoubleLeftClick", tab, mAcl.gui.expert.onListDoubleClick)
	addEventHandler("onClientGUIGridListItemEnterKey", tab, mAcl.gui.expert.onListDoubleClick)
	addEventHandler("onClientGUIRightClick", tab, mAcl.gui.expert.onListRightClick)
	addEventHandler("onClientGUIGridListItemDeleteKey", tab, mAcl.gui.expert.onListRightClick)

	addEventHandler("onClientGUIChanged", mAcl.gui.expert.matrix.srch, function() mAcl.gui.expert.refreshMatrix() end, false)
	addEventHandler("onClientGUIGridListItemSelected", mAcl.gui.expert.matrix.viewList, function() mAcl.gui.expert.refreshMatrix() end, false)
	
	addEventHandler("onClientGUIChanged", mAcl.gui.expert.acl.rightSrch, function() mAcl.gui.expert.refreshACL() end, false)
	addEventHandler("onClientGUIGridListItemSelected", mAcl.gui.expert.acl.rightViewlist, function() mAcl.gui.expert.refreshACL() end, false)

	return true
end

function mAcl.gui.expert.onLeftClick()

	if source == mAcl.gui.expert.restoreAdminBtn then
		if not guiShowMessageDialog("Admin panel rights will be restored. Continue?", "Restore rights", MD_YES_NO, MD_QUESTION ) then return end
		cCommands.execute("restoreadminacl")

	elseif source == mAcl.gui.expert.restoreBtn then
		if not guiShowMessageDialog("Server default rights and admin panel rights will be restored. Added objects, custom groups and rights will NOT be changed, except 'Everyone' group. Continue?", "Restore rights", MD_YES_NO, MD_QUESTION ) then return end
		cCommands.execute("restoreacl")

	elseif source == mAcl.gui.expert.group.createBtn then
		local group = guiShowInputDialog("Add group", "Enter the group name", nil, guiGetInputNotEmptyParser())
		if not group then return end
		cCommands.execute("aclcreategroup", group)

	elseif source == mAcl.gui.expert.group.destroyBtn then
		local group = mAcl.gui.expert.getSelectedGroup()
		if not group then return guiShowMessageDialog("No group selected!", nil, MD_OK, MD_ERROR) end
		if not guiShowMessageDialog("Group '"..group.."' will be destroyed! Are you sure?", "Destroy group", MD_YES_NO, MD_WARNING) then return end
		if group == "Everyone" then
			if not guiShowMessageDialog("Warning! Highly recommended do not delete group 'Everyone'. Delete it only, if you know what you are doing. Continue?", "Destroy group", MD_YES_NO, MD_WARNING) then return end
		end
		cCommands.execute("acldestroygroup", group)
	
	elseif source == mAcl.gui.expert.group.addObjectBtn then
		local group = mAcl.gui.expert.getSelectedGroup()
		if not group then return guiShowMessageDialog("No group selected!", nil, MD_OK, MD_ERROR) end
		local object = guiShowInputDialog("Add object", "Enter the object name", nil, guiGetInputNotEmptyParser())
		if not object then return end
		cCommands.execute("aclgroupaddobject", group, object)

	elseif source == mAcl.gui.expert.group.removeObjectBtn then
		local group = mAcl.gui.expert.getSelectedGroup()
		if not group then return guiShowMessageDialog("No group selected!", nil, MD_OK, MD_ERROR) end
		local object = mAcl.gui.expert.getGroupSelectedObject()
		if not object then return guiShowMessageDialog("No object selected!", nil, MD_OK, MD_ERROR) end
		if not guiShowMessageDialog("Object '"..object.."' will be removed from group '"..group.."'. Continue?", "Remove object", MD_YES_NO, MD_QUESTION ) then return end
		if group == "Everyone" then
			if not guiShowMessageDialog("Warning! Highly recommended do not remove any objects from 'Everyone' group. Delete it only, if you know what you are doing. Continue?", "Remove object", MD_YES_NO, MD_WARNING) then return end
		end
		cCommands.execute("aclgroupremoveobject", group, object)

	elseif source == mAcl.gui.expert.group.addACLBtn then
		local group = mAcl.gui.expert.getSelectedGroup()
		if not group then return guiShowMessageDialog("No group selected!", nil, MD_OK, MD_ERROR) end
		local acl = guiShowInputDialog("Add ACL", "Enter the ACL name", nil, guiGetInputNotEmptyParser())
		if not acl then return end
		cCommands.execute("aclgroupaddacl", group, acl)

	elseif source == mAcl.gui.expert.group.removeACLBtn then
		local group = mAcl.gui.expert.getSelectedGroup()
		if not group then return guiShowMessageDialog("No group selected!", nil, MD_OK, MD_ERROR) end
		local acl = mAcl.gui.expert.getGroupSelectedACL()
		if not acl then return guiShowMessageDialog("No ACL selected!", nil, MD_OK, MD_ERROR) end
		if not guiShowMessageDialog("ACL '"..acl.."' will be removed from group '"..group.."'. Continue?", "Remove ACL", MD_YES_NO, MD_QUESTION ) then return end
		if group == "Everyone" then
			if not guiShowMessageDialog("Warning! Highly recommended do not remove any ACL from 'Everyone' group. Delete it only, if you know what you are doing. Continue?", "Remove ACL", MD_YES_NO, MD_WARNING) then return end
		end
		cCommands.execute("aclgroupremoveacl", group, acl)


	--------------- ACL -------------------
	
	elseif source == mAcl.gui.expert.acl.createBtn then
		local acl = guiShowInputDialog("Add ACL", "Enter the ACL name", nil, guiGetInputNotEmptyParser())
		if not acl then return end
		cCommands.execute("aclcreate", acl)

	elseif source == mAcl.gui.expert.acl.destroyBtn then
		local acl = mAcl.gui.expert.getSelectedACL()
		if not acl then return guiShowMessageDialog("No ACL selected!", nil, MD_OK, MD_ERROR) end
		if not guiShowMessageDialog("ACL '"..acl.."' will be destroyed! Are you sure?", "Destroy ACL", MD_YES_NO, MD_WARNING) then return end
		if acl == "Default" then
			if not guiShowMessageDialog("Warning! Highly recommended do not delete ACL 'Default'. Delete it only, if you know what you are doing. Continue?", "Destroy ACL", MD_YES_NO, MD_WARNING) then return end
		end
		cCommands.execute("acldestroy", acl)

	elseif source == mAcl.gui.expert.acl.addRightBtn then
		local right = guiShowInputDialog("Add right", "Enter the right name", nil, guiGetInputNotEmptyParser())
		if not right then return end

		local acl = mAcl.gui.expert.getSelectedACL()

		if mAcl.data.acls.rights[acl].access[right] ~= nil then return guiShowMessageDialog("Right '"..right.."' is already added!", nil, MD_OK, MD_ERROR) end
		cCommands.execute("aclsetright", acl, right, false)

	elseif source == mAcl.gui.expert.acl.removeRightBtn then
		local acl = mAcl.gui.expert.getSelectedACL()
		local right = mAcl.gui.expert.getACLSelectedRight()
		
		if not guiShowMessageDialog("Right '"..right.."' will be removed from ACL '"..acl.."'. Continue?", "Remove right", MD_YES_NO, MD_QUESTION ) then return end
		if acl == "Default" then
			if not guiShowMessageDialog("Warning! Highly recommended do not remove any rights from 'Default' ACL entry. Delete it only, if you know what you are doing. Continue?", "Remove right", MD_YES_NO, MD_WARNING) then return end
		end
		cCommands.execute("aclremoveright", acl, right)

	elseif source == mAcl.gui.expert.acl.showPublicChk then
		mAcl.gui.expert.refreshACL()

	--------------- MATRIX -------------------

	elseif source == mAcl.gui.expert.matrix.showAutoChk then
		mAcl.gui.expert.refreshMatrix()

	elseif source == mAcl.gui.expert.matrix.removeRightBtn then
		local acl, right, access = mAcl.gui.expert.getMatrixSelectedACLRight()
		if not acl then return end

		if access == nil then return end
		
		if not guiShowMessageDialog("Right '"..right.."' will be removed from ACL '"..acl.."'. Continue?", "Remove right", MD_YES_NO, MD_QUESTION ) then return end
		if acl == "Default" then
			if not guiShowMessageDialog("Warning! Highly recommended do not remove any rights from 'Default' ACL entry. Delete it only, if you know what you are doing. Continue?", "Remove right", MD_YES_NO, MD_WARNING) then return end
		end
		cCommands.execute("aclremoveright", acl, right)

	end
end

function mAcl.gui.expert.onListDoubleClick()

	if source == mAcl.gui.expert.acl.rightsList then
		local acl = mAcl.gui.expert.getSelectedACL()
		if not acl then return end

		local right, access = mAcl.gui.expert.getACLSelectedRight()
		if not right then return end

		access = not access
		if not guiShowMessageDialog("Set right '"..right.."' to '"..tostring(access).."'?", "Change right", MD_YES_NO, MD_QUESTION ) then return end
		if acl == "Default" then
			if not guiShowMessageDialog("Warning! Highly recommended do not change any rights in 'Default' ACL entry. Change it only, if you know what you are doing. Continue?", "Change right", MD_YES_NO, MD_WARNING) then return end
		end
		cCommands.execute("aclsetright", acl, right, access)

	elseif source == mAcl.gui.expert.matrix.list then
		local acl, right, access = mAcl.gui.expert.getMatrixSelectedACLRight()
		if not acl then return end

		if access == nil then
			access = false
		else
			access = not access
		end

		if not guiShowMessageDialog("Set '"..acl.."' ACL right '"..right.."' to '"..tostring(access).."'?", "Change right", MD_YES_NO, MD_QUESTION ) then return end
		if acl == "Default" then
			if not guiShowMessageDialog("Warning! Highly recommended do not change any rights in 'Default' ACL entry. Change it only, if you know what you are doing. Continue?", "Change right", MD_YES_NO, MD_WARNING) then return end
		end
		cCommands.execute("aclsetright", acl, right, access)

	end
end

function mAcl.gui.expert.onListItemSelected(row)

	if source == mAcl.gui.expert.acl.list then
		mAcl.gui.expert.refreshACL()
	
	elseif source == mAcl.gui.expert.group.list then
		mAcl.gui.expert.refreshGroup()

	elseif source == mAcl.gui.expert.group.aclList then
		guiSetEnabled(mAcl.gui.expert.group.removeACLBtn, row ~= -1)

	elseif source == mAcl.gui.expert.group.objectsList then
		guiSetEnabled(mAcl.gui.expert.group.removeObjectBtn, row ~= -1)

	elseif source == mAcl.gui.expert.acl.rightsList then
		local enabled = row ~= -1 and guiGridListGetItemData(mAcl.gui.expert.acl.rightsList, row, 2) ~= nil
		guiSetEnabled(mAcl.gui.expert.acl.removeRightBtn, enabled)

	elseif source == mAcl.gui.expert.matrix.list then
		local acl, right, access = mAcl.gui.expert.getMatrixSelectedACLRight()
		local enabled = acl and right and access ~= nil or false
		guiSetEnabled(mAcl.gui.expert.matrix.removeRightBtn, enabled)

	end
end

function mAcl.gui.expert.onListRightClick()
	
	if source == mAcl.gui.expert.group.list then
		guiClick(mAcl.gui.expert.group.destroyBtn)

	elseif source == mAcl.gui.expert.group.aclList then
		guiClick(mAcl.gui.expert.group.removeACLBtn)

	elseif source == mAcl.gui.expert.group.objectsList then
		guiClick(mAcl.gui.expert.group.removeObjectBtn)

	elseif source == mAcl.gui.expert.acl.list then
		guiClick(mAcl.gui.expert.acl.destroyBtn)

	elseif source == mAcl.gui.expert.acl.rightsList then
		guiClick(mAcl.gui.expert.acl.removeRightBtn)

	elseif source == mAcl.gui.expert.matrix.list then
		guiClick(mAcl.gui.expert.matrix.removeRightBtn)

	end
end

function mAcl.gui.expert.refresh()
	
	mAcl.gui.expert.refreshGroups()
	mAcl.gui.expert.refreshACLs()
	mAcl.gui.expert.refreshMatrix()

	return true
end

---------------------------------------
--------------- GROUP -----------------
---------------------------------------

function mAcl.gui.expert.getSelectedGroup()
	return guiGridListGetSelectedItemText(mAcl.gui.expert.group.list)
end

function mAcl.gui.expert.getGroupSelectedObject()
	return guiGridListGetSelectedItemText(mAcl.gui.expert.group.objectsList)
end

function mAcl.gui.expert.getGroupSelectedACL()
	return guiGridListGetSelectedItemText(mAcl.gui.expert.group.aclList)
end

function mAcl.gui.expert.refreshGroup(group)
	
	local selected = mAcl.gui.expert.getSelectedGroup()
	if group and group ~= selected then return end

	guiSetEnabled(mAcl.gui.expert.group.destroyBtn, false)

	local selectedACL = guiGridListGetSelectedItem(mAcl.gui.expert.group.aclList)
	local selectedObject = guiGridListGetSelectedItem(mAcl.gui.expert.group.objectsList)
	guiGridListClear(mAcl.gui.expert.group.aclList)
	guiGridListClear(mAcl.gui.expert.group.objectsList)
	guiSetEnabled(mAcl.gui.expert.group.aclList, false)
	guiSetEnabled(mAcl.gui.expert.group.objectsList, false)
	guiSetStatusText(mAcl.gui.expert.group.aclList, "N/A")
	guiSetStatusText(mAcl.gui.expert.group.objectsList, "N/A")

	if not selected then return end

	guiSetEnabled(mAcl.gui.expert.group.destroyBtn, true)

	if not mAcl.data.groups.content[selected] then return false end

	guiSetEnabled(mAcl.gui.expert.group.aclList, true)
	guiSetEnabled(mAcl.gui.expert.group.objectsList, true)
	guiSetStatusText(mAcl.gui.expert.group.aclList)
	guiSetStatusText(mAcl.gui.expert.group.objectsList)

	for i, acl in ipairs(mAcl.data.groups.content[selected].acls) do
		guiGridListAddRow(mAcl.gui.expert.group.aclList, acl)
	end
	guiGridListSetSelectedItem(mAcl.gui.expert.group.aclList, selectedACL)

	for i, object in ipairs(mAcl.data.groups.content[selected].objects) do
		guiGridListAddRow(mAcl.gui.expert.group.objectsList, object)
	end
	guiGridListSetSelectedItem(mAcl.gui.expert.group.objectsList, selectedObject)

	return true
end

function mAcl.gui.expert.refreshGroups()

	local selected = guiGridListGetSelectedItem(mAcl.gui.expert.group.list)
	guiGridListClear(mAcl.gui.expert.group.list)

	for i, group in ipairs(mAcl.data.groups.list) do
		guiGridListAddRow(mAcl.gui.expert.group.list, group)
	end
	guiGridListSetSelectedAnyItem(mAcl.gui.expert.group.list, selected)

	mAcl.gui.expert.refreshGroup()

	return true
end

---------------------------------------
--------------- ACL -------------------
---------------------------------------

function mAcl.gui.expert.getSelectedACL()
	return guiGridListGetSelectedItemText(mAcl.gui.expert.acl.list)
end

function mAcl.gui.expert.getACLSelectedRight()

	local right = guiGridListGetSelectedItemData(mAcl.gui.expert.acl.rightsList)
	if not right then return nil end

	local access = guiGridListGetSelectedItemData(mAcl.gui.expert.acl.rightsList, nil, 2)

	return right, access
end

function mAcl.gui.expert.refreshACL(acl)

	local selectedACL = mAcl.gui.expert.getSelectedACL()
	if acl and acl ~= selectedACL then return end

	guiSetEnabled(mAcl.gui.expert.acl.destroyBtn, false)

	local list = mAcl.gui.expert.acl.rightsList
	local selected = guiGridListGetSelectedItem(list)
	guiGridListClear(list)
	guiSetEnabled(list, false)
	guiSetStatusText(list, "N/A")

	guiGridListRemoveColumn(list, mAcl.gui.expert.acl.rightsPublicClm)
	local showPublicRights = guiCheckBoxGetSelected(mAcl.gui.expert.acl.showPublicChk)
	if showPublicRights then guiGridListAddColumn(list, "Public", 0.15) end

	if not selectedACL then return end

	guiSetEnabled(mAcl.gui.expert.acl.destroyBtn, true)

	if not mAcl.data.acls.rights[selectedACL] then return false end
	
	local publicRightsData = mAcl.getPublicRights()
	if not publicRightsData then return end
	
	guiSetEnabled(list, true)
	guiSetStatusText(list)

	local rightsData = mAcl.data.acls.rights[selectedACL]

	local addRights = {}
	if showPublicRights then
		for i, right in ipairs(rightsData.list) do
			if publicRightsData.access[right] == nil then
				table.insert(addRights, {right, rightsData.access[right], nil})
			end
		end
		for i, right in ipairs(publicRightsData.list) do
			table.insert(addRights, {right, rightsData.access[right], publicRightsData.access[right]})
		end
	else
		for i, right in ipairs(rightsData.list) do
			table.insert(addRights, {right, rightsData.access[right]})
		end
	end

	local viewType = guiGetText(mAcl.gui.expert.acl.rightViewEdit)
	if viewType == "all" then viewType = ".*" end
	local search = utf8.lower(guiGetText(mAcl.gui.expert.acl.rightSrch))

	for i, rightData in ipairs(addRights) do
	
		local right = rightData[1]
		
		local cutted = utf8.gsub(right, "^.-%.", "")
		if (utf8.match(right, "^"..viewType)) and
		(utf8.find(utf8.lower(cutted), search, 1, true)) then

			local access = rightData[2]
			local publicAccess = rightData[3]

			local row = guiGridListAddRow(
				list,
				viewType == ".*" and right or cutted,
				access == nil and gs.lst.none or tostring(access),
				publicAccess == nil and gs.lst.none or tostring(publicAccess)
			)
			guiGridListSetItemData(list, row, 1, right)
			guiGridListSetItemData(list, row, 2, access)
		
			guiGridListSetItemColor(list, row, 2, unpack(access and gs.lst.clr.active or gs.lst.clr.inactive))
			guiGridListSetItemColor(list, row, 3, unpack(publicAccess == false and gs.lst.clr.inactive or COLORS.red))
			guiGridListSetItemColor(list, row, 1, unpack((access or publicAccess or showPublicRights and publicAccess == nil) and gs.lst.clr.active or gs.lst.clr.inactive))
		end
	end

	guiGridListSetSelectedItem(list, selected)

	return true
end

function mAcl.gui.expert.refreshPublicRights()
	
	local showPublic = guiCheckBoxGetSelected(mAcl.gui.expert.acl.showPublicChk)
	if mAcl.data.publicRights.list and #mAcl.data.publicRights.list > 0 then
		guiSetEnabled(mAcl.gui.expert.acl.showPublicChk, true)
		guiSetToolTip(mAcl.gui.expert.acl.showPublicContainer)
	else
		guiSetEnabled(mAcl.gui.expert.acl.showPublicChk, false)
		guiCheckBoxSetSelected(mAcl.gui.expert.acl.showPublicChk, false)
		guiSetToolTip(mAcl.gui.expert.acl.showPublicContainer, "(!) No public rights were found. This means that all resources and users have all rigths. Seems like ACL damaged. Use /restoreacl command for restore default rights", unpack(COLORS.red))
	end

	mAcl.gui.expert.refreshACL()

	return true
end

function mAcl.gui.expert.refreshACLs()
	
	local selected = guiGridListGetSelectedItem(mAcl.gui.expert.acl.list)
	guiGridListClear(mAcl.gui.expert.acl.list)

	for i, acl in ipairs(mAcl.data.acls.list) do
		guiGridListAddRow(mAcl.gui.expert.acl.list, acl)
	end
	guiGridListSetSelectedAnyItem(mAcl.gui.expert.acl.list, selected)

	mAcl.gui.expert.refreshACL()

	return true
end

---------------------------------------
--------------- MATRIX ----------------
---------------------------------------

function mAcl.gui.expert.getMatrixSelectedACLRight()

	local item, column = guiGridListGetSelectedItem(mAcl.gui.expert.matrix.list, 1)
	if item == -1 then return nil end
	if column == 1 then return nil end

	local acl = guiGridListGetColumnTitle(mAcl.gui.expert.matrix.list, column)
	local right = guiGridListGetItemData(mAcl.gui.expert.matrix.list, item, 1)
	local access = guiGridListGetItemData(mAcl.gui.expert.matrix.list, item, column)
	
	return acl, right, access
end

function mAcl.gui.expert.refreshMatrix()

	local list = mAcl.gui.expert.matrix.list
	local selectedMatrixRow, selectedMatrixColumn = guiGridListGetSelectedItem(list)
	guiGridListClear(list)
	for i = 2, guiGridListGetColumnCount(list) do
		guiGridListRemoveColumn(list, 2)
	end
	guiSetEnabled(list, false)
	guiSetStatusText(list, "N/A")

	local acls = mAcl.data.acls.list
	for i, acl in ipairs(acls) do
		if not mAcl.data.acls.rights[acl] then return end
	end

	guiSetEnabled(list, true)
	guiSetStatusText(list)

	
	local showAuto = guiCheckBoxGetSelected(mAcl.gui.expert.matrix.showAutoChk)
	local publicRightsData = mAcl.getPublicRights()
	local rightsRows = {}

	for ir, right in ipairs(publicRightsData.list) do
		local row = guiGridListAddRow(list, right)
		guiGridListSetItemData(list, row, 1, right)
		rightsRows[right] = row
	end

	for ia, acl in ipairs(acls) do

		local isAuto = utf8.match(acl, "^autoACL_") and true or false
		if showAuto or (not showAuto) and (not isAuto) then

			local column = guiGridListAddColumn(list, acl, 0.06)
			for ir, right in ipairs(mAcl.data.acls.rights[acl].list) do
	
				local row = rightsRows[right]
				if not row then
					row = guiGridListAddRow(list, right)
					guiGridListSetItemData(list, row, 1, right)
					rightsRows[right] = row
				end
	
				local access = mAcl.data.acls.rights[acl].access[right]
				guiGridListSetItemText(list, row, column, tostring(access), false, false)
				guiGridListSetItemData(list, row, column, access)
			end
		end
	end

	local viewType = guiGetText(mAcl.gui.expert.matrix.viewEdit)
	if viewType == "all" then viewType = ".*" end
	local search = utf8.lower(guiGetText(mAcl.gui.expert.matrix.srch))
	
	for row = guiGridListGetRowCount(list) - 1, 0, -1 do
		local right = guiGridListGetItemData(list, row, 1)
		local cutted = utf8.gsub(right, "^.-%.", "")
		if utf8.match(right, "^"..viewType) and
		utf8.find(utf8.lower(cutted), search, 1, true) then
			guiGridListSetItemText(list, row, 1, viewType == ".*" and right or cutted, false, false)
		else
			guiGridListRemoveRow(list, row)
		end
	end

	for i = 0, guiGridListGetRowCount(list) do
		for j = 2, guiGridListGetColumnCount(list) do
			local access = guiGridListGetItemData(list, i, j)
			if not access then
				if access == nil then
					guiGridListSetItemText(list, i, j, gs.lst.none, false, false)
				end
				guiGridListSetItemColor(list, i, j, unpack(gs.lst.clr.inactive))
			else
				guiGridListSetItemColor(list, i, j, unpack(gs.lst.clr.active))
			end
		end
	end

	guiGridListSetSelectedItem(list, selectedMatrixRow, selectedMatrixColumn)
	
	return true
end