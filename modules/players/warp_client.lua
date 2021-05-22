
local DEFAULT_Z = 50

addEvent("gra.mPlayers.onWarpedToUndefinedZ", true)

addEventHandler("gra.mPlayers.onWarpedToUndefinedZ", localPlayer,
	function(element, x, y)
		
		local frozen = isElementFrozen(element)
		setElementFrozen(element, true)
		setElementPosition(element, x, y, DEFAULT_Z)

		while isElementWaitingForGroundToLoad(element) do
			coroutine.sleep(50)
		end

		local centreToBase = getElementDistanceFromCentreOfMassToBaseOfModel(element)
		local hit, hitX, hitY, hitZ = processLineOfSight(
			x, y, 3000, x, y, -3000,
			true,
			true,
			false,
			true,
			true,
			false,
			false,
			false,
			element
		)

		setElementPosition(element, x, y, (hit and hitZ or DEFAULT_Z) + centreToBase + 1)
		setElementFrozen(element, frozen)
		
	end,
	false
)