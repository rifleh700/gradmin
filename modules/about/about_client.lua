
mAbout = {}

function mAbout.init()

	mAbout.gui.init()

	return true
end

function mAbout.term()

	mAbout.gui.term()

	return true
end

cModules.register(mAbout, GENERAL_PERMISSION)