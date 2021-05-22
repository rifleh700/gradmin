
local DEFAULT_VERTICAL_STEP_SIZE = 0.05
local SCROLL_SPEED = 5

addEvent("onClientGUIScrollPaneVerticalScroll", false)

local ScrollPane = {}

function ScrollPane.onRender()
	if not guiGetEnabled(this) then return end

	local oldPosition = guiGetInternalData(this, "verticalScroll")
	local newPosition = guiScrollPaneGetVerticalScrollPosition(this)
	if oldPosition == newPosition then return false end
	
	guiSetInternalData(this, "verticalScroll", newPosition)
	triggerEvent("onClientGUIScrollPaneVerticalScroll", this)

end

function ScrollPane.onMouseWheel(vector)

	if this == source then return end
	if not guiIsGrandParentFor(this, source) then return end

	local height = guiGetHeight(this, false)
	local position = (guiScrollPaneGetVerticalScrollPosition(this)/100 * height - SCROLL_SPEED * vector)/height * 100
	guiScrollPaneSetVerticalScrollPosition(this, position)

end

local _guiCreateScrollPane = guiCreateScrollPane
function guiCreateScrollPane(x, y, width, height, relative, parent)
	if not scheck("n[4],b,?u:element:gui") then return false end

	local pane = _guiCreateScrollPane(x, y, width, height, relative, parent)
	if not pane then return pane end

	guiSetProperty(pane, "VertStepSize", tostring(DEFAULT_VERTICAL_STEP_SIZE))

	addEventHandler("onClientMouseWheel", pane, ScrollPane.onMouseWheel)
	addEventHandler("onClientGUIRender", pane, ScrollPane.onRender)

	return pane
end