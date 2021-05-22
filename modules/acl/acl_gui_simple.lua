
mAcl.gui.simple = {}

function mAcl.gui.simple.init()

	local tab = mAcl.gui.tab
	local tw, th = guiGetSize(tab, false)
	
	-----------------------------

	x, y = GS.mrg2, GS.mrg2
	w, h = tw - GS.mrg2*2, th - GS.mrg2*2
	local tpnl = guiCreateTabPanel(x, y, w, h, false, tab)
	mAcl.gui.simple.tpnl = tpnl
	
	-----------------------------

	mAcl.gui.simple.group = {}
	mAcl.gui.simple.group.tab = guiCreateTab("Groups", tpnl)

	return true
end

function mAcl.gui.simple.refresh()
	
	return true
end