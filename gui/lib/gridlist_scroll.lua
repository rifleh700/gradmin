
local ARROW_PRESSED_DELAY = 500

local arrowPressedTicks = nil
local arrowHorizontal = false
local pressedArrowVector = 0

local GridListScroll = {}

function GridListScroll.scroll()

	local list = guiGetFocusedGridList()
	if not list then return false end

	local rows = guiGridListGetRowCount(list)
	if rows == 0 then return end

	local columns = guiGridListGetColumnCount(list)
	if columns == 0 then return end
	
	local row, column = guiGridListGetSelectedItem(list)
	if arrowHorizontal then
		column = math.clamp(column + pressedArrowVector, 1, columns)
	else
		row = math.clamp(row + pressedArrowVector, 0, rows - 1)
	end
	guiGridListSetSelectedItem(list, row, column)

end

addEventHandler("onClientKey", root,
	function(key, press)
		if not (key == "arrow_d" or key == "arrow_u" or key == "arrow_l" or key == "arrow_r") then return end
		if not press then arrowPressedTicks = nil return end

		local list = guiGetFocusedGridList()
		if not list then return end
		if not guiGetVisible(list) or not guiGetEnabled(list) then return end
		
		pressedArrowVector = (key == "arrow_d" or key == "arrow_r") and 1 or -1
		arrowHorizontal = key == "arrow_l" or key == "arrow_r"
		arrowPressedTicks = getTickCount()
		GridListScroll.scroll()
	end
)

addEventHandler("onClientRender", root,
	function()
		if not arrowPressedTicks then return end
		if getTickCount() - arrowPressedTicks > ARROW_PRESSED_DELAY then GridListScroll.scroll() end
	end
)