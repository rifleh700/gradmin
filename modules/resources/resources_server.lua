
addEvent("gra.mResources.onACLRequestUpdate", false)

mResources = {}

function mResources.init()
	
	addEventHandler("onResourcePreStart", root, mResources.onStateChanged)
	addEventHandler("onResourceStart", root, mResources.onStateChanged)
	addEventHandler("onResourceStop", root, mResources.onStateChanged)
	--addEventHandler("onResourceLoadStateChange", root, mResources.onStateChanged)

	addEventHandler("onSettingChange", root, mResources.onSettingChange)
	addEventHandler("gra.mResources.onACLRequestUpdate", root, mResources.onACLRequestUpdated)

	cSync.register("Resources.state", "general.resources")
	cSync.register("Resources.data", "general.resources", {heavy = true})
	cSync.register("Resources.settings", "general.resources", {heavy = true})
	cSync.register("Resources.requests", "general.resources", {heavy = true})
	cSync.register("Resources.list", "general.resources", {heavy = true})

	cSync.registerResponder("Resources.list", mResources.sync.list)
	cSync.registerResponder("Resources.data", mResources.sync.data)

	return true
end

cModules.register(mResources)

function mResources.onStateChanged(res, old, new)

	cSync.send(root, "Resources.state", getResourceName(res), getResourceState(res))

end

function mResources.onSettingChange(setting, oldValue, newValue)
	
	local resourceName = getResourceNameFromSetting(setting)
	if not resourceName then return end

	local res = getResourceFromName(resourceName)
	if not res then return end

	cSync.send(root, "Resources.settings", resourceName, getResourceSettingsData(res))
end

function mResources.onACLRequestUpdated(res, right, access)
	cSync.send(root, "Resources.requests", getResourceName(res), getResourceACLRequests(res))
end

mResources.sync = {}

function mResources.sync.list()
	local list = {}
	for i, res in ipairs(getResources()) do
		list[i] = {
			name = getResourceName(res),
			state = getResourceState(res),
			group = getResourceInfo(res, "type") or "misc"
		}
	end
	return list
end

function mResources.sync.data(resourceName)

	local res = getResourceFromName(resourceName)
	if not res then return false end

	local data = getResourceInfo(res)
	data.settings = getResourceSettingsData(res)
	data.requests = getResourceACLRequests(res)

	return data
end