
local CAMERA_TURN_SPEED = 2
local CAMERA_ZOOM_SPEED = 0.4
local CAMERA_RADIUS_MIN = 2
local CAMERA_RADIUS_MAX = 30

local TEXT_FONT = "default-bold"
local TEXT_SIZE = 1 + 1/9*5
local TEXT_BORDER = 2

local NAME_TEXT_Y = 20

local camera = getCamera()

mPlayers.Spectator = {}

mPlayers.Spectator.enabled = false
mPlayers.Spectator.player = nil
mPlayers.Spectator.camRot = {0, math.pi/2}
mPlayers.Spectator.radius = 10
mPlayers.Spectator.interior = 0

function mPlayers.Spectator.enable()
	if mPlayers.Spectator.enabled then return false end

	mPlayers.Spectator.interior = getElementInterior(localPlayer)
	mPlayers.Spectator.enabled = true
	setElementFrozen(localPlayer, true)
	toggleAllControls(false, true, false)
	
	bindKey("arrow_l", "down", mPlayers.Spectator.switchPlayer, -1)
    bindKey("arrow_r", "down", mPlayers.Spectator.switchPlayer, 1)
    bindKey("mouse_wheel_up", "down", mPlayers.Spectator.zoom, -1)
    bindKey("mouse_wheel_down", "down", mPlayers.Spectator.zoom, 1)
   
    addEventHandler("onClientCursorMove", root, mPlayers.Spectator.onCursorMove)
    addEventHandler("onClientRender", root, mPlayers.Spectator.onRender)

    guiButtonSetGlowStyle(mPlayers.gui.spectateBtn)

	return true
end

function mPlayers.Spectator.disable()
	if not mPlayers.Spectator.enabled then return false end	

	mPlayers.Spectator.enabled = false
	
    removeEventHandler("onClientCursorMove", root, mPlayers.Spectator.onCursorMove)
    removeEventHandler("onClientRender", root, mPlayers.Spectator.onRender)

	unbindKey("arrow_l", "down", mPlayers.Spectator.switchPlayer)
    unbindKey("arrow_r", "down", mPlayers.Spectator.switchPlayer)
    unbindKey("mouse_wheel_up", "down", mPlayers.Spectator.zoom)
    unbindKey("mouse_wheel_down", "down", mPlayers.Spectator.zoom)

    setElementInterior(localPlayer, mPlayers.Spectator.interior)
	setElementInterior(camera, getElementInterior(localPlayer))
	setElementDimension(camera, getElementDimension(localPlayer))
	setCameraTarget(localPlayer)
	setElementFrozen(localPlayer, false)
	toggleAllControls(true, true, false)

	guiButtonSetStyle(mPlayers.gui.spectateBtn)

	return true
end

function mPlayers.Spectator.switch()
	
	return mPlayers.Spectator.disable() or mPlayers.Spectator.enable()
end

function mPlayers.Spectator.isEnabled()
	
	return mPlayers.Spectator.enabled
end

function mPlayers.Spectator.switchPlayer(_, _, factor)
	if isCursorShowing() then return end
	if isMTAWindowActive() then return end

	local rows = guiGridListGetRowCount(mPlayers.gui.list)
	local selected = guiGridListGetSelectedItem(mPlayers.gui.list)
	local row = (math.max(selected + factor, -1)) % rows

	guiGridListSetSelectedItem(mPlayers.gui.list, row)

end

function mPlayers.Spectator.onCursorMove(cx, cy)
	if isCursorShowing() then return end
	if isMTAWindowActive() then return end

	mPlayers.Spectator.camRot[1] = mPlayers.Spectator.camRot[1] - (cx - 0.5) * CAMERA_TURN_SPEED
	mPlayers.Spectator.camRot[2] = math.clamp(mPlayers.Spectator.camRot[2] - (cy - 0.5) * CAMERA_TURN_SPEED, 0.05, math.pi - 0.05)

end

function mPlayers.Spectator.zoom(_, _, factor)
	if isCursorShowing() then return end
	if isMTAWindowActive() then return end

	mPlayers.Spectator.radius = math.clamp(mPlayers.Spectator.radius + factor * CAMERA_ZOOM_SPEED, CAMERA_RADIUS_MIN, CAMERA_RADIUS_MAX)
    
end

function mPlayers.Spectator.drawInfo()
	
	dxDrawBorderedText(
		mPlayers.Spectator.player and "spectating: "..getPlayerName(mPlayers.Spectator.player, true) or "nobody else to spectate",
		TEXT_BORDER, 0, NAME_TEXT_Y, GUI_SCREEN_WIDTH, nil, nil, TEXT_SIZE, TEXT_FONT,
		"center", "top",
		false, false, false, false, true
	)

	return true
end

function mPlayers.Spectator.updateCamera()
	
	local player = mPlayers.Spectator.player or localPlayer

	local interior = player == localPlayer and mPlayers.Spectator.interior or getElementInterior(player)
	setElementInterior(localPlayer, interior)
	setElementInterior(camera, interior)
	setElementDimension(camera, getElementDimension(player))
	
	local x, y, z = getElementPosition(player)
    local cx = x + mPlayers.Spectator.radius * math.cos(mPlayers.Spectator.camRot[1]) * math.sin(mPlayers.Spectator.camRot[2])
    local cy = y + mPlayers.Spectator.radius * math.sin(mPlayers.Spectator.camRot[1]) * math.sin(mPlayers.Spectator.camRot[2])
    local cz = z + mPlayers.Spectator.radius * math.cos(mPlayers.Spectator.camRot[2])
    setCameraMatrix(cx, cy, cz, x, y, z)

    return true
end

function mPlayers.Spectator.onRender()
	
	mPlayers.Spectator.player = mPlayers.gui.getSelected()

	mPlayers.Spectator.drawInfo()
	mPlayers.Spectator.updateCamera()

end