
local SCRIPTS_PATH = DATA_PATH.."execute/scripts/"
local SCRIPTS_LIST_PATH = DATA_PATH.."execute/scripts.xml"

mExecute = {}

function mExecute.init()
	
	mExecute.gui.init()
	
	return true
end

function mExecute.term()

	mExecute.gui.term()

	return true
end

cModules.register(mExecute, "general.execute")

function mExecute.execute(code)
	
	local func, errorMsg = loadstring(code)
	if errorMsg then return cMessages.outputAdmin("error: "..errorMsg, COLORS.red) and false end

	setfenv(func, setmetatable({}, {__index = _D}))

	local results = table.pack(pcall(func))
	if not results[1] then return cMessages.outputAdmin("error: "..results[2], COLORS.red) and false end

	for i = 2, results.n do
		results[i-1] = inspect(results[i])
	end
	results[results.n] = nil
	results.n = nil

	cMessages.outputAdmin("code executed (client) with result: "..table.concat(results, ", "), COLORS.green)
	
	return true
end

function mExecute.getScriptsList()
	
	local listFile = xmlLoadFile(SCRIPTS_LIST_PATH, true)
	if not listFile then return {} end

	local list = {}
	for i, data in ipairs(xmlNodeGetData(listFile).children) do
		list[i] = data.attributes.name
	end
	xmlUnloadFile(listFile)

	return list
end

function mExecute.isScriptExists(name)
	
	return fileExists(SCRIPTS_PATH..name..".lua")
end

function mExecute.saveScript(name, data)
	
	local path = SCRIPTS_PATH..name..".lua"
	if fileExists(path) then fileDelete(path) end

	local file = fileCreate(path)
	if not file then return false end

	fileWrite(file, data)
	fileFlush(file)
	fileClose(file)

	local listFile = xmlLoadFile(SCRIPTS_LIST_PATH) or xmlCreateFile(SCRIPTS_LIST_PATH, "scripts")
	if not listFile then return false end

	local scriptNode = xmlFindChildByAttribute(listFile, "script", "name", name)
	if not scriptNode then
		scriptNode = xmlCreateChild(listFile, "script")
		xmlNodeSetAttribute(scriptNode, "name", name)
	end

	xmlSaveFile(listFile)
	xmlUnloadFile(listFile)

	return true
end

function mExecute.deleteScript(name)
	
	local path = SCRIPTS_PATH..name..".lua"
	if not fileExists(path) then return false end
	if not fileDelete(path) then return false end

	local listFile = xmlLoadFile(SCRIPTS_LIST_PATH)
	if not listFile then return true end

	local scriptNode = xmlFindChildByAttribute(listFile, "script", "name", name)
	if scriptNode then
		xmlDestroyNode(scriptNode)
		xmlSaveFile(listFile)
	end

	xmlUnloadFile(listFile)

	return true
end

function mExecute.loadScript(name)
	
	local path = SCRIPTS_PATH..name..".lua"
	if not fileExists(path) then return false end

	local file = fileOpen(path, true)
	if not file then return false end

	local data = fileReadAll(file)
	fileClose(file)

	return data
end