
mResources = {}

function mResources.init()

	mResources.list = {}
	mResources.data = {}
	
	cSync.addHandler("Resources.state", mResources.sync.state)
	cSync.addHandler("Resources.data", mResources.sync.data)
	cSync.addHandler("Resources.settings", mResources.sync.settings)
	cSync.addHandler("Resources.requests", mResources.sync.requests)
	cSync.addHandler("Resources.list", mResources.sync.list)

	mResources.gui.init()
	
	cSync.request("Resources.list")

	return true
end

function mResources.term()

	cSync.removeHandler("Resources.state", mResources.sync.state)
	cSync.removeHandler("Resources.data", mResources.sync.data)
	cSync.removeHandler("Resources.settings", mResources.sync.settings)
	cSync.removeHandler("Resources.requests", mResources.sync.requests)
	cSync.removeHandler("Resources.list", mResources.sync.list)

	mResources.gui.term()

	return true
end

cModules.register(mResources, "general.resources")

mResources.sync = {}

function mResources.sync.state(resourceName, state)

	for i, data in ipairs(mResources.list) do
		if data.name == resourceName then
			data.state = state
			break
		end
	end
	mResources.gui.refreshResourceState(resourceName)
	mResources.gui.refreshResource(resourceName)

end

function mResources.sync.data(resourceName, data)

	mResources.data[resourceName] = data
	mResources.gui.refreshResource(resourceName)

end

function mResources.sync.settings(resourceName, settings)

	mResources.data[resourceName].settings = settings
	mResources.gui.refreshResource(resourceName)

end

function mResources.sync.requests(resourceName, requests)
	
	mResources.data[resourceName].requests = requests
	mResources.gui.refreshResource(resourceName)

end

function mResources.sync.list(list)

	mResources.list = list
	mResources.gui.refresh()

end

function mResources.request(resourceName)

	return cSync.request("Resources.data", resourceName)
end

function mResources.refresh()

	mResources.list = {}
	mResources.data = {}
	mResources.gui.refresh()
	return cSync.request("Resources.list")
end

function mResources.getState(resourceName)

	for i, data in ipairs(mResources.list) do
		if data.name == resourceName then return data.state end
	end
	return false
end