
local fontSizeAccessLabel = guiCreateLabel(0, 0, 0, 0, "", false)
guiSetVisible(fontSizeAccessLabel, false)
guiSetEnabled(fontSizeAccessLabel, false)
local _guiSetText = guiSetText
local _guiSetFont = guiSetFont

function guiFontGetHeight(font)
	if not scheck("?s|u:element:gui-font") then return false end

	if not font then font = "default-normal" end

	guiSetFont(fontSizeAccessLabel, font)

	return guiLabelGetFontHeight(fontSizeAccessLabel)
end

function guiFontGetTextExtent(text, font)
	if not scheck("s,?s|u:element:gui-font") then return false end

	font = font or "default-normal"

	_guiSetFont(fontSizeAccessLabel, font)
	_guiSetText(fontSizeAccessLabel, text)

	return guiLabelGetTextExtent(fontSizeAccessLabel)
end

function guiFontGetTextSize(text, font, maxWidth)
	if not scheck("s,?s|u:element:gui-font,?n") then return false end

	font = font or "default-normal"

	local textExtent = guiFontGetTextExtent(text, font)
	local fontHeight = guiFontGetHeight(font)

	if (not maxWidth) or maxWidth >= textExtent then return textExtent, fontHeight end

	local lineCount = 0
	local lineExtent = 0
	local longestLineExtent = 0

	for il, line in ipairs(utf8.split(text, "\n")) do
	
		lineCount = lineCount + 1
		lineExtent = 0

		for iw, word in ipairs(utf8.split(line, "%s")) do

			local wordExtent = guiFontGetTextExtent((iw == 1 and "" or " ")..word, font)
	
			if lineExtent + wordExtent > maxWidth then
				lineCount = lineCount + 1
				lineExtent = guiFontGetTextExtent(word, font)
	
			else
				lineExtent = lineExtent + wordExtent
	
			end
	
			if lineExtent > longestLineExtent then
				longestLineExtent = lineExtent
			end
		end
	end

	return longestLineExtent, lineCount * fontHeight
end

function guiFontClipText(text, font, maxWidth)
	if not scheck("s,?s|u:element:gui-font,n") then return false end

	font = font or "default-normal"

	local textExtent = guiFontGetTextExtent(text, font)
	if maxWidth >= textExtent then return text end

	local clippedText = ""
	local clippedExtent = 0

	for i, symbol in ipairs(utf8.split(text, "")) do
		if guiFontGetTextExtent(clippedText..symbol, font) > maxWidth then break end
		clippedText = clippedText..symbol
	end

	return clippedText
end
