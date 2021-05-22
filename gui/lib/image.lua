
-- NEEDED
local _guiStaticImageLoadImage = guiStaticImageLoadImage
function guiStaticImageLoadImage(image, path)
	if not scheck("u:element:gui-staticimage,s") then return false end

	local propagation = isElementCallPropagationEnabled(image)
	setElementCallPropagationEnabled(image, false)

	local result = _guiStaticImageLoadImage(image, path)

	setElementCallPropagationEnabled(image, propagation)

	return result
end

function guiStaticImageGetColor(image)
	if not scheck("u:element:gui-staticimage") then return false end

	return guiGetColorsProperty(image, "ImageColours")
end

function guiStaticImageSetColor(image, r, g, b, a)
	if not scheck("u:element:gui-staticimage,n[3],?n") then return false end

	return guiSetColorsProperty(image, "ImageColours", r, g, b, a)
end

function guiStaticImageSetSizeNative(image)
	if not scheck("u:element:gui-staticimage") then return false end

	local w, h = guiStaticImageGetNativeSize(image)
	guiSetMaxSize(image, w, h, false)

	return guiSetSize(image, w, h, false)
end

function guiStaticImageSetStretched(image, state)
	if not scheck("u:element:gui-staticimage,b") then return false end

	guiSetProperty(image, "HorzFormatting", state and "HorzStretched" or "LeftAligned")
	guiSetProperty(image, "VertFormatting", state and "VertStretched" or "TopAligned")

	return true
end

function guiStaticImageScale(image, maxw, maxh)
	if not scheck("u:element:gui-staticimage,n[2]") then return false end
	
	local w, h = guiStaticImageGetNativeSize(image)
	if w > maxw then
		h = h * (maxw/w)
		w = maxw
	end
	if h > maxh then
		w = w * (maxh/h)
		h = maxh
	end

	return guiSetSize(image, w, h, false)
end

function guiStaticImageAdjustMaxSize(image)
	if not scheck("u:element:gui-staticimage") then return false end

	local nw, nh = guiStaticImageGetNativeSize(image)

	return guiSetMaxSize(image, nw, nh, false)
end