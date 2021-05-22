
local RESOURCE_ACLS_PATH = "@conf/acl.xml"
local SERVER_ACL_PATH = "@conf/acl_global.xml"

cAcl = {}

function cAcl.init()

	return cAcl.install()
end

-- compare resource 'Default' ACL entry and server 'Default' ACL entry
-- setup only rights, which not found inside server 'Default' ACL entry
-- setup rights only for resource ACL entries, if it found in server
function cAcl.install()
	
	local fileNode = xmlLoadFile(RESOURCE_ACLS_PATH, true)
	if not fileNode then return cMessages.outputDebug("ACL: default admin ACL conf file not found, please reinstall the resource", COLORS.yellow) and false end

	local fileData = xmlNodeGetData(fileNode)
	xmlUnloadFile(fileNode)

	-- get gradmin ACLs rights
	local adminACLs = {}
	local adminDefaultRights = {}
	for i, aclData in ipairs(fileData.children) do
		adminACLs[aclData.attributes.name] = {}
		for i, rightData in ipairs(aclData.children) do
			adminACLs[aclData.attributes.name][rightData.attributes.name] = rightData.attributes.access == "true"
			if aclData.attributes.name == "Default" then
				table.insert(adminDefaultRights, rightData.attributes.name)
			end
		end
	end

	if not adminACLs["Default"] then return cMessages.outputDebug("ACL: couldn't find 'Default' ACL, please reinstall the resource", COLORS.yellow) and false end
	
	local defaultACL = aclGet("Default")
	if not defaultACL then return cMessages.outputDebug("ACL: couldn't find server 'Default' ACL, please use 'restoreacl' command or reinstall server ACL config", COLORS.yellow) and false end

	-- setup only rights, which not found inside server 'Default' ACL entry
	local setupRights = {}
	for i, right in ipairs(adminDefaultRights) do
		if not aclRightExists(defaultACL, right) then
			table.insert(setupRights, right)
		end
	end
	if #setupRights == 0 then return true end

	-- setup rights for every founded admin ACL entry 
	for aclName, aclRights in pairs(adminACLs) do
		local acl = aclGet(aclName)
		if acl then
			local updated = 0
			for i, right in ipairs(setupRights) do
				if aclRights[right] ~= nil and not aclRightExists(acl, right) then
					aclSetRight(acl, right, aclRights[right])
					updated = updated + 1
				end
			end
			if updated > 0 then
				cMessages.outputDebug("ACL: updated "..updated.." rights in ACL '"..aclName.."'")
			end
		end
	end

	aclSave()

	return true
end

-- setup all rights, like resource ACL config
-- create resorce ACL entries if it doesn't exist
-- it does not touch other rights and other ACL entries
function cAcl.restoreGradmin()
	
	local fileNode = xmlLoadFile(RESOURCE_ACLS_PATH, true)
	if not fileNode then return cMessages.outputDebug("ACL: default admin ACL conf file not found, please reinstall the resource", COLORS.yellow) and false end

	local fileData = xmlNodeGetData(fileNode)
	xmlUnloadFile(fileNode)

	-- get gradmin ACLs rights
	local adminACLs = {}
	local adminDefaultRights = {}
	for i, aclData in ipairs(fileData.children) do
		adminACLs[aclData.attributes.name] = {}
		for i, rightData in ipairs(aclData.children) do
			adminACLs[aclData.attributes.name][rightData.attributes.name] = rightData.attributes.access == "true"
			if aclData.attributes.name == "Default" then
				table.insert(adminDefaultRights, rightData.attributes.name)
			end
		end
	end

	if not adminACLs["Default"] then return cMessages.outputDebug("ACL: couldn't find 'Default' ACL, please reinstall the resource", COLORS.yellow) and false end

	-- set all rights like resource ACL config
	for aclName, aclRights in pairs(adminACLs) do
		local acl = aclGet(aclName) or aclCreate(aclName)
		for ir, right in ipairs(adminDefaultRights) do
			local access = aclGetRight(acl, right)
			if not aclRightExists(acl, right) then
				access = nil
			end

			if access ~= aclRights[right] then
				if aclRights[right] == nil then
					aclRemoveRight(acl, right)
				else
					aclSetRight(acl, right, aclRights[right])
				end
			end
		end
	end

	aclSave()

	cMessages.outputDebug("ACL: admin panel rights successfully restored", COLORS.green)

	return true
end

function cAcl.restoreServer()

	local fileNode = xmlLoadFile(SERVER_ACL_PATH, true)
	if not fileNode then return cMessages.outputDebug("ACL: default server ACL conf file not found, please reinstall the resource", COLORS.yellow) and false end

	local fileData = xmlNodeGetData(fileNode)
	xmlUnloadFile(fileNode)

	-- get deault server ACL config
	local fileACLs = {}
	local fileDefaultACL = nil
	local fileGroups = {}
	for i, childData in ipairs(fileData.children) do
		if childData.name == "acl" then
			local data = {}
			data.name = childData.attributes.name
			data.rights = {}
			for i, rightData in ipairs(childData.children) do
				table.insert(data.rights, {
					name = rightData.attributes.name,
					access = rightData.attributes.access == "true"
				})
			end
			table.insert(fileACLs, data)
			if data.name == "Default" then
				fileDefaultACL = data
			end

		elseif childData.name == "group" then
			local data = {}
			data.name = childData.attributes.name
			data.acls = {}
			data.objects = {}
			for i, groupChildData in ipairs(childData.children) do
				if groupChildData.name == "acl" then
					table.insert(data.acls, groupChildData.attributes.name)
				elseif groupChildData.name == "object" then
					table.insert(data.objects, groupChildData.attributes.name)
				end
			end
			table.insert(fileGroups, data)
		end
	end

	if not fileDefaultACL then return cMessages.outputDebug("ACL: couldn't find 'Default' ACL in default server ACL! Please reinstall the resource", COLORS.yellow) and false end

	-- temporary ACL entry and group for this resource only
	local tempAdminGroup = aclGetGroup("temp_Admin") or aclCreateGroup("temp_Admin")
	local tempAdminACL = aclGet("temp_Admin") or aclCreate("temp_Admin")
	aclSetRight(tempAdminACL, "function.aclReload", true)
	aclSetRight(tempAdminACL, "function.aclSave", true)
	aclSetRight(tempAdminACL, "function.aclCreate", true)
	aclSetRight(tempAdminACL, "function.aclDestroy", true)
	aclSetRight(tempAdminACL, "function.aclSetRight", true)
	aclSetRight(tempAdminACL, "function.aclRemoveRight", true)
	aclSetRight(tempAdminACL, "function.aclCreateGroup", true)
	aclSetRight(tempAdminACL, "function.aclDestroyGroup", true)
	aclSetRight(tempAdminACL, "function.aclGroupAddACL", true)
	aclSetRight(tempAdminACL, "function.aclGroupRemoveACL", true)
	aclSetRight(tempAdminACL, "function.aclGroupAddObject", true)
	aclSetRight(tempAdminACL, "function.aclGroupRemoveObject", true)
	aclGroupAddACL(tempAdminGroup, tempAdminACL)
	aclGroupAddObject(tempAdminGroup, "resource."..getResourceName(getThisResource()))

	-- get or create server ACL entry by file entries
	-- remove all server ACL entry rights which founded inside file 'Default' ACL entry
	-- set server ACL entry rights(which founded inside file ACL entry) like file ACL entry rights
	for i, aclData in ipairs(fileACLs) do
		local acl = aclGet(aclData.name) or aclCreate(aclData.name)
		for ir, rightData in ipairs(fileDefaultACL.rights) do
			if rightData.access then
				aclSetRight(acl, true)
			else
				aclRemoveRight(acl, rightData.name)
			end
		end
		for ir, rightData in ipairs(aclData.rights) do
			aclSetRight(acl, rightData.name, rightData.access)
		end
	end

	-- get or create server group by file groups
	-- remove from group "user.*" and "resource.*"
	-- remove from group all file ACL entries
	-- add to group file group ACL entries
	-- add to group file group objects
	for i, groupData in ipairs(fileGroups) do
		local group = aclGetGroup(groupData.name) or aclCreateGroup(groupData.name)
		aclGroupRemoveObject(group, "user.*")
		aclGroupRemoveObject(group, "resource.*")

		for ia, aclData in ipairs(fileACLs) do
			aclGroupRemoveACL(group, aclGet(aclData.name))
		end
		for ia, aclName in ipairs(groupData.acls) do
			aclGroupAddACL(group, aclGet(aclName))
		end
		for iobj, object in ipairs(groupData.objects) do
			aclGroupAddObject(group, object)
		end
	end

	-- destroy temporary group and ACL entry
	aclDestroyGroup(tempAdminGroup)
	aclDestroy(tempAdminACL)
	
	aclSave()

	cMessages.outputDebug("ACL: server ACL successfully restored", COLORS.green)
	
	return true
end

cCommands.add("restoreadminacl",
	function(admin)
		
		if not cAcl.restoreGradmin() then return false end

		triggerEvent("gra.onAclChange", root)
		
		return true, "admin panel ACL successfully restored"
	end,
	"", "restore gradmin resource ACL", COLORS.acl
)

cCommands.add("restoreacl",
	function(admin)
		
		local s = cAcl.restoreServer()
		local g = cAcl.restoreGradmin()

		if s or g then triggerEvent("gra.onAclChange", root) end
		if not (s and g) then return false end

		return true, "server global ACL successfully restored"
	end,
	"", "restore server global ACL", COLORS.acl
)

cCommands.add("saveacl",
	function(admin)
		
		if not aclSave() then return false end
		
		return true, "server ACL file successfully saved"
	end,
	"", "save server ACL file", COLORS.acl
)

cCommands.addHardCoded("reloadacl",
	function(admin)
		
		if not aclReload() then return false end

		triggerEvent("gra.onAclChange", root)

		return true, "server ACL successfully reloaded"
	end,
	COLORS.acl
)