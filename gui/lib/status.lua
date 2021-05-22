
local StatusText = {}

StatusText.labels = {}

function StatusText.init(element)
	
	local label = guiCreateLabel(0, 0, 1, 1, "", true, element)
	guiSetEnabled(label, false)
	guiSetVisible(label, false)
	guiLabelSetHorizontalAlign(label, "center")
	guiLabelSetVerticalAlign(label, "center")

	StatusText.labels[element] = label

	return true
end

function StatusText.set(element, text, r, g, b)
	
	local label = StatusText.labels[element]
	if not label then StatusText.init(element) end

	label = StatusText.labels[element]
	guiSetText(label, text)
	guiLabelSetColor(label, r, g, b)

	return true
end

function guiSetStatusText(element, text, r, g, b)
	if not scheck("u:element:gui,?s,?byte[3]") then return false end

	if not text then text = "" end
	if not r then
		if getElementType(element) == "gui-memo" then
			r, g, b = 0, 0, 0
		else
			r, g, b = 255, 255, 255
		end
	end

	return StatusText.set(element, text, r, g, b)
end