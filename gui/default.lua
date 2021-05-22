
local function hide(element)
	
	guiSetVisible(element, false)
	guiSetEnabled(element, false)
	guiMoveToBack(element)

	return element
end

GUI_DEFAULT_BUTTON = hide(guiCreateButton(0, 0, 0, 0, "", false))
GUI_DEFAULT_CHECKBOX = hide(guiCreateCheckBox(0, 0, 0, 0, "", false, false))
GUI_DEFAULT_COMBOBOX = hide(guiCreateComboBox(0, 0, 0, 0, "", false))
GUI_DEFAULT_EDIT = hide(guiCreateEdit(0, 0, 0, 0, "", false))
GUI_DEFAULT_MEMO = hide(guiCreateMemo(0, 0, 0, 0, "", false))
GUI_DEFAULT_PROGRESSBAR = hide(guiCreateProgressBar(0, 0, 0, 0, false))
GUI_DEFAULT_RADIOBUTTON = hide(guiCreateRadioButton(0, 0, 0, 0, "", false))
GUI_DEFAULT_SCROLLBAR = hide(guiCreateScrollBar(0, 0, 0, 0, false, false))
GUI_DEFAULT_SCROLLPANE = hide(guiCreateScrollPane(0, 0, 0, 0, false))
GUI_DEFAULT_STATICIMAGE = hide(guiCreateStaticImage(0, 0, 0, 0, GUI_WHITE_IMAGE_PATH, false))
GUI_DEFAULT_LABEL = hide(guiCreateLabel(0, 0, 0, 0, "", false))
GUI_DEFAULT_WINDOW = hide(guiCreateWindow(0, 0, 0, 0, "", false))

GUI_DEFAULT_GRIDLIST = hide(guiCreateGridList(0, 0, 0, 0, false))
guiGridListAddColumn(GUI_DEFAULT_GRIDLIST, "", 0)
guiGridListAddRow(GUI_DEFAULT_GRIDLIST, "")

GUI_DEFAULT_TABPANEL = hide(guiCreateTabPanel(0, 0, 0, 0, false))
GUI_DEFAULT_TAB = hide(guiCreateTab("", GUI_DEFAULT_TABPANEL))

------------------------------------------------------------------

GUI_DEFAULT_HORIZONTALSEPARATOR = hide(guiCreateHorizontalSeparator(0, 0, 0, false))
GUI_DEFAULT_VERTICALSEPARATOR = hide(guiCreateVerticalSeparator(0, 0, 0, false))