
mAcl.gui = {}

function mAcl.gui.init()

	local tab = cGUI.addTab("Rights")
	mAcl.gui.tab = tab

	local tw, th = guiGetSize(tab, false)
	local x, y = GS.mrg2, GS.mrg2
	local w, h = tw - GS.mrg2*2, th - GS.mrg2*2
	
	mAcl.gui.expertChk = guiCreateCheckBox(-x, y, 100, GS.h, "Expert mode", true, false, tab)
	guiSetEnabled(mAcl.gui.expertChk, false)
	guiSetHorizontalAlign(mAcl.gui.expertChk, "right")
	guiSetAlwaysOnTop(mAcl.gui.expertChk, true)

	x = x + 100 + GS.mrg2
	mAcl.gui.refreshBtn = guiCreateButton(-x, y, GS.w2, GS.h, "Refresh", false, tab)
	guiSetHorizontalAlign(mAcl.gui.refreshBtn, "right")
	guiSetAlwaysOnTop(mAcl.gui.refreshBtn, true)
	
	-----------------------------

	mAcl.gui.expert.init()
	mAcl.gui.simple.init()

	addEventHandler("onClientGUILeftClick", tab, mAcl.gui.onLeftClick)

	mAcl.gui.switchExpertMode()
	
	return true
end

function mAcl.gui.term()
	
	destroyElement(mAcl.gui.tab)

	return true
end

function mAcl.gui.onLeftClick()

	if source == mAcl.gui.expertChk then
		mAcl.gui.switchExpertMode()

	elseif source == mAcl.gui.refreshBtn then
		mAcl.requestFull()

	end
end

function mAcl.gui.switchExpertMode()
	
	local expert = guiCheckBoxGetSelected(mAcl.gui.expertChk)
	
	guiSetVisible(mAcl.gui.expert.tpnl, expert)
	guiSetVisible(mAcl.gui.expert.restoreBtn, expert)
	guiSetVisible(mAcl.gui.expert.restoreAdminBtn, expert)

	guiSetVisible(mAcl.gui.simple.tpnl, not expert)

	return true
end

function mAcl.gui.refresh()
	
	mAcl.gui.expert.refresh()
	mAcl.gui.simple.refresh()

	return true
end