
local HEADER_FONT_PATH = GUI_FONTS_PATH.."DejaVuSansMono-Bold.ttf"
local NAME_FONT_SIZE = 48
local VERSION_FONT_SIZE = 16

local gs = {}
gs.mrgT = -60
gs.name = {}
gs.name.font = guiCreateFont(HEADER_FONT_PATH, NAME_FONT_SIZE)
gs.version = {}
gs.version.font = guiCreateFont(HEADER_FONT_PATH, VERSION_FONT_SIZE)

mAbout.gui = {}

function mAbout.gui.init()

	local tab = cGUI.addTab("About")
	mAbout.gui.tab = tab
	
	local container = guiCreateContainer(GS.mrg2, GS.mrg2, -GS.mrg2*2, -GS.mrg2*2, false, tab)
	guiSetRawSize(container, 1, 1, true)

	local vlo = guiCreateVerticalLayout(nil, gs.mrgT, nil, nil, nil, false, container)

	local titleHlo = guiCreateHorizontalLayout(nil, nil, nil, nil, nil, true, vlo)
	guiHorizontalLayoutSetVerticalAlign(titleHlo, "bottom")
	
	local lblh = guiFontGetHeight(gs.name.font) + 20
	mAbout.gui.nameLbl = guiCreateLabel(nil, nil, nil, lblh, "gradmin", false, titleHlo)
	guiSetFont(mAbout.gui.nameLbl, gs.name.font)
	guiLabelAdjustWidth(mAbout.gui.nameLbl)
	guiLabelSetColor(mAbout.gui.nameLbl, table.unpack(GS.clr.aqua))
	guiLabelSetVerticalAlign(mAbout.gui.nameLbl, "bottom")

	guiCreateHorizontalSeparator(nil, nil, 1, true, vlo)

	mAbout.gui.versionLbl = guiCreateLabel(nil, nil, nil, lblh, VERSION, false, titleHlo)
	guiSetFont(mAbout.gui.versionLbl, gs.version.font)
	guiLabelAdjustWidth(mAbout.gui.versionLbl)
	guiLabelSetVerticalAlign(mAbout.gui.versionLbl, "bottom")

	mAbout.gui.authorLbl = guiCreateLabel(nil, nil, GS.w32, nil, "author: rifleh700", false, vlo)
	mAbout.gui.githubLbl = guiCreateLabel(nil, nil, GS.w32, nil, "https://github.com/rifleh700/gradmin", false, vlo)
	mAbout.gui.licenseLbl = guiCreateLabel(nil, nil, GS.w32, nil, "MIT License", false, vlo)

	guiRebuildLayouts(tab)
	guiSetHorizontalAlign(vlo, "center")
	guiSetVerticalAlign(vlo, "center")
	
	return true
end

function mAbout.gui.term()

	destroyElement(mAbout.gui.tab)

	return true
end
