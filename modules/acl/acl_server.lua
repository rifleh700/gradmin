
local mAcl = {}

function mAcl.init()

	addEventHandler("gra.onAclCreate", root, mAcl.onAclCreate)
	addEventHandler("gra.onAclDestroy", root, mAcl.onAclDestroy)
	addEventHandler("gra.onAclGroupCreate", root, mAcl.onGroupCreate)
	addEventHandler("gra.onAclGroupDestroy", root, mAcl.onGroupDestroy)
	addEventHandler("gra.onAclRightChange", root, mAcl.onAclChange)
	addEventHandler("gra.onAclRightRemove", root, mAcl.onAclChange)
	addEventHandler("gra.onAclGroupACLAdd", root, mAcl.onGroupChange)
	addEventHandler("gra.onAclGroupACLRemove", root, mAcl.onGroupChange)
	addEventHandler("gra.onAclGroupObjectAdd", root, mAcl.onGroupChange)
	addEventHandler("gra.onAclGroupObjectRemove", root, mAcl.onGroupChange)
	addEventHandler("gra.onAclChange", root, mAcl.onChange)

	cSync.register("Acl.aclList", "general.acl")
	cSync.register("Acl.groupList", "general.acl")
	cSync.register("Acl.acl", "general.acl", {heavy = true})
	cSync.register("Acl.group", "general.acl", {heavy = true})
	cSync.register("Acl.full", "general.acl", {heavy = true})

	cSync.registerResponder("Acl.aclList", mAcl.sync.aclList)
	cSync.registerResponder("Acl.groupList", mAcl.sync.groupList)
	cSync.registerResponder("Acl.acl", mAcl.sync.acl)
	cSync.registerResponder("Acl.group", mAcl.sync.group)
	cSync.registerResponder("Acl.full", mAcl.sync.full)

	return true
end

cModules.register(mAcl)

function mAcl.onAclCreate(acl)

	cSync.callResponder(root, "Acl.acl", aclGetName(acl))
	cSync.callResponder(root, "Acl.aclList")

end

function mAcl.onAclDestroy()
	
	cSync.callResponder(root, "Acl.aclList")

end

function mAcl.onGroupCreate(group)
	
	cSync.callResponder(root, "Acl.group", aclGroupGetName(group))
	cSync.callResponder(root, "Acl.groupList")
	
end

function mAcl.onGroupDestroy()
	
	cSync.callResponder(root, "Acl.groupList")
	
end

function mAcl.onAclChange(acl)
	
	cSync.callResponder(root, "Acl.acl", aclGetName(acl))
	
end

function mAcl.onGroupChange(group)
	
	cSync.callResponder(root, "Acl.group", aclGroupGetName(group))
	
end

function mAcl.onChange()
	
	cSync.callResponder(root, "Acl.full")

end

mAcl.sync = {}

function mAcl.sync.aclList()

	local acls = {}
	for i, acl in ipairs(aclList()) do
		acls[i] = aclGetName(acl)
	end
	
	return acls
end

function mAcl.sync.groupList()

	local groups = {}
	for i, group in ipairs(aclGroupList()) do
		groups[i] = aclGroupGetName(group)
	end

	return groups
end

function mAcl.sync.acl(aclName)

	local acl = aclGet(aclName)
	local data = {}
	data.list = {}
	data.access = {}
	for i, right in ipairs(aclListRights(acl)) do
		data.list[i] = right
		data.access[right] = aclGetRight(acl, right)
	end

	return data
end

function mAcl.sync.group(groupName)

	local group = aclGetGroup(groupName)
	local data = {}
	data.acls = {}
	for i, acl in ipairs(aclGroupListACL(group)) do
		data.acls[i] = aclGetName(acl)
	end
	data.objects = {}
	for i, object in ipairs(aclGroupListObjects(group)) do
		data.objects[i] = object
	end

	return data
end

function mAcl.sync.full()
	
	local data = {}

	local groupsList = {}
	local groupsContent = {}
	
	for ig, group in ipairs(aclGroupList()) do
		
		local groupName = aclGroupGetName(group)
		local groupContent = {}

		groupContent.acls = {}
		for ia, acl in ipairs(aclGroupListACL(group)) do
			groupContent.acls[ia] = aclGetName(acl)
		end
		groupContent.objects = aclGroupListObjects(group)

		groupsList[ig] = groupName
		groupsContent[groupName] = groupContent
	end

	data.groups = {}
	data.groups.list = groupsList
	data.groups.content = groupsContent

	local aclsList = {}
	local aclsRightsData = {}

	for ia, acl in ipairs(aclList()) do
		
		local aclName = aclGetName(acl)
		local aclRightsData = {}
		
		aclRightsData.list = aclListRights(acl)
		aclRightsData.access = {}
		for ir, right in ipairs(aclRightsData.list) do
			aclRightsData.access[right] = aclGetRight(acl, right)
		end

		aclsList[ia] = aclName
		aclsRightsData[aclName] = aclRightsData
	end

	data.acls = {}
	data.acls.list = aclsList
	data.acls.rights = aclsRightsData

	return data
end