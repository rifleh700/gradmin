
function fileReadAll(file)
	if not scheck("u:element:file") then return false end

	fileSetPos(file, 0)
	local data = fileRead(file, fileGetSize(file))
	fileSetPos(file, 0)

	return data
end

function fileReadLine(file)
	if not scheck("u:element:file") then return false end

	if fileIsEOF(file) then return false end
	
	local line = ""
	local char = ""
	while not (utf8.byte(char) == 10 or fileIsEOF(file)) do
		line = line..char
		char = fileRead(file, 1)
	end

	return line
end

function fileClampByLine(path, lines)
	if not scheck("s,n") then return false end

	if lines < 1 then return false end

	local file = fileOpen(path, true)
	if not file then return false end

	local size = fileGetSize(file)
	local pos = {0}
	while not fileIsEOF(file) do
		if utf8.byte(fileRead(file, 1)) == 10 then table.insert(pos, fileGetPos(file)) end
	end
	fileClose(file)

	if #pos <= lines then return true end

	return fileClamp(path,  size - pos[#pos - lines])
end

function fileClamp(path, bytes)
	if not scheck("s,n") then return false end
	
	local file = fileOpen(path, true)
	if not file then return false end

	local size = fileGetSize(file)
	if size <= bytes then
		fileClose(file)
		return true
	end
	
	fileSetPos(file, size - bytes)
	local data = fileRead(file, bytes)
	fileClose(file)

	if not fileDelete(path) then return false end
	file = fileCreate(path)
	if not file then return false end

	fileWrite(file, data)
	fileFlush(file)
	fileClose(file)

	return true
end

function fileClear(path)
	if not scheck("s") then return false end

	if not fileDelete(path) then return false end
	local file = fileCreate(path)
	if not file then return nil end
	fileClose(file)

	return true
end