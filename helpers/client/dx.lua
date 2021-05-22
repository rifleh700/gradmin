
function dxDrawBorderedText(text, border, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak,postGUI) 

	border = math.max(math.floor(border), 1)
	right = right or left
	bottom = bottom or top
	font = font or "default"

	for bx = -border, border do
        for by = -border, border do
            dxDrawText(text, left + bx, top + by, right + bx, bottom + by, tocolor(0, 0, 0, 255), scale, font, alignX, alignY, clip, wordBreak,postGUI) 
        end 
    end 

    return dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI) 
end 