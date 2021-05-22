
mEnv = {}

function mEnv.init()

	mEnv.data = {}

	mEnv.gui.init()
	
	cSync.addHandler("Env.data", mEnv.sync.data)
	cSync.addHandler("Env.list", mEnv.sync.list)

	return true
end

function mEnv.term()
	
	cSync.removeHandler("Env.data", mEnv.sync.data)
	cSync.removeHandler("Env.list", mEnv.sync.list)
	
	mEnv.gui.term()
	
	return true
end

cModules.register(mEnv, "general.environment")

mEnv.sync = {}

function mEnv.sync.data(setting, data)
	mEnv.data[setting] = data
	mEnv.gui.refresh()
end

function mEnv.sync.list(data)
	mEnv.data = data
	mEnv.gui.refresh()
end
