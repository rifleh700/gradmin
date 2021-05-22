
addEvent("onClientGUIGridListItemDeleteKey", false)
addEvent("onClientGUIGridListItemEnterKey", false)

addEventHandler("onClientKey", root,
	function(key, press)
		local list = guiGetFocusedGridList()
		if not list then return end
		if not press then return end
		if not (key == "delete" or key == "enter") then return end

		local row, column = guiGridListGetSelectedItem(list)
		if row == -1 or column == 0 then return end

		triggerEvent(
			key == "delete" and "onClientGUIGridListItemDeleteKey" or "onClientGUIGridListItemEnterKey",
			list, row, column
		)
	end
)