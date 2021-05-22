
local SHOW_DELAY = 0.5 * 10^3

local gs = {}
gs.w = 240
gs.pdn = 5
gs.clr = {}
gs.clr.bg = COLORS.black
gs.clr.text = COLORS.yellow

local ToolTip = {}

ToolTip.gui = {}
ToolTip.element = nil
ToolTip.timer = nil

function ToolTip.onRender()
	if not ToolTip.element then return end
	if isCursorShowing() and guiGetVisible(ToolTip.element) then return end

	ToolTip.element = nil
	guiSetVisible(ToolTip.gui.container, false)

end

function ToolTip.init()
	
	ToolTip.gui.container = guiCreateStaticImage(0, 0, 200, 200, GUI_WHITE_IMAGE_PATH, false)
	guiStaticImageSetColor(ToolTip.gui.container, unpack(gs.clr.bg))
	guiSetAlpha(ToolTip.gui.container, 0.8)
	guiSetAlwaysOnTop(ToolTip.gui.container, true)
	guiSetVisible(ToolTip.gui.container, false)
	guiSetEnabled(ToolTip.gui.container, false)

	ToolTip.gui.label = guiCreateLabel(0, 0, 0, 0, "", false, ToolTip.gui.container)
	guiLabelSetHorizontalAlign(ToolTip.gui.label, "left", true)

	addEventHandler("onClientGUIRender", ToolTip.gui.container, ToolTip.onRender, false)

	return true
end

ToolTip.init()

function ToolTip.show()
	if not ToolTip.element then return end
	if not isCursorShowing() then return end
	if guiGetVisible(ToolTip.gui.container) then return end

	local text = guiGetCustomProperty(ToolTip.element, "tooltip")
	if not text then return end

	local color = guiGetCustomProperty(ToolTip.element, "tooltipTextColour")
	if not color then color = gs.clr.text end

	guiSetText(ToolTip.gui.label, text)
	guiLabelSetColor(ToolTip.gui.label, unpack(color))

	local w, h = guiGetTextSize(ToolTip.gui.label, gs.w)
	guiSetSize(ToolTip.gui.container, w + gs.pdn*2, h + (gs.pdn-2)*2, false)
	guiSetPosition(ToolTip.gui.label, gs.pdn, (gs.pdn-2), false)
	guiSetSize(ToolTip.gui.label, w, h, false)

	local cx, cy = getCursorAbsolutePosition()
	guiSetPosition(ToolTip.gui.container, cx + 1, cy + 14, false)
	guiSetVisible(ToolTip.gui.container, true, true)

	return true
end

addEventHandler("onClientMouseEnter", guiRoot,
	function()
		if not guiGetCustomProperty(source, "tooltip") then return end

		ToolTip.element = source
	end
)

addEventHandler("onClientMouseLeave", guiRoot,
	function()
		if ToolTip.element ~= source then return end

		ToolTip.element = nil
	end
)

addEventHandler("onClientMouseMove", guiRoot,
	function()
		if guiGetVisible(ToolTip.gui.container) then guiSetVisible(ToolTip.gui.container, false) end

		if ToolTip.element ~= source then return end
		if ToolTip.timer and isTimer(ToolTip.timer) then return resetTimer(ToolTip.timer) end

		ToolTip.timer = setTimer(ToolTip.show, SHOW_DELAY, 1)
	end
)

addEventHandler("onClientElementDestroy", guiRoot,
	function()
		if source ~= ToolTip.element then return end

		ToolTip.element = nil
		guiSetVisible(ToolTip.gui.container, false)
	end
)

addEventHandler("onClientGUIClick", guiRoot,
	function()
		guiSetVisible(ToolTip.gui.container, false)
	end
)

function guiSetToolTip(element, text, r, g, b)
	if not scheck("u:element:gui,?s,?byte[3]") then return false end
	
	if r and g and b then
		guiSetCustomProperty(element, "tooltipTextColour", {r, g, b})
	else
		guiSetCustomProperty(element, "tooltipTextColour")
	end

	return guiSetCustomProperty(element, "tooltip", text)
end