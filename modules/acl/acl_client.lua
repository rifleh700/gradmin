
mAcl = {}

function mAcl.init()

	mAcl.data = {}
	mAcl.data.acls = {}
	mAcl.data.acls.list = {}
	mAcl.data.acls.rights = {}
	mAcl.data.groups = {}
	mAcl.data.groups.list = {}
	mAcl.data.groups.content = {}

	mAcl.gui.init()

	cSync.addHandler("Acl.aclList", mAcl.sync.aclList)
	cSync.addHandler("Acl.groupList", mAcl.sync.groupList)
	cSync.addHandler("Acl.acl", mAcl.sync.acl)
	cSync.addHandler("Acl.group", mAcl.sync.group)
	cSync.addHandler("Acl.full", mAcl.sync.full)

	cSync.request("Acl.full")

	return true
end

function mAcl.term()

	cSync.removeHandler("Acl.aclList", mAcl.sync.aclList)
	cSync.removeHandler("Acl.groupList", mAcl.sync.groupList)
	cSync.removeHandler("Acl.acl", mAcl.sync.acl)
	cSync.removeHandler("Acl.group", mAcl.sync.group)
	cSync.removeHandler("Acl.full", mAcl.sync.full)

	mAcl.gui.term()

	return true
end

cModules.register(mAcl, "general.acl")

mAcl.sync = {}

function mAcl.sync.groupList(groups)
	mAcl.data.groups.list = groups
	mAcl.gui.expert.refreshGroups()
	mAcl.gui.expert.refreshMatrix()
end

function mAcl.sync.aclList(acls)
	mAcl.data.acls.list = acls
	mAcl.gui.expert.refreshACLs()
	mAcl.gui.expert.refreshMatrix()
end

function mAcl.sync.acl(acl, data)
	mAcl.data.acls.rights[acl] = data
	mAcl.gui.expert.refreshACL(acl)
	mAcl.gui.expert.refreshMatrix()
end

function mAcl.sync.group(group, data)
	mAcl.data.groups.content[group] = data
	mAcl.gui.expert.refreshGroup(group)
	mAcl.gui.expert.refreshMatrix()
end

function mAcl.sync.full(data)
	mAcl.data = data
	mAcl.gui.refresh()
end

function mAcl.requestFull()
	if not cSync.request("Acl.full") then return false end

	mAcl.data.acls.list = {}
	mAcl.data.acls.rights = {}
	mAcl.data.groups.list = {}
	mAcl.data.groups.content = {}
	mAcl.gui.refresh()

	return true
end

function mAcl.getPublicRights()

	local publicRightsData = {}
	publicRightsData.list = {}
	publicRightsData.access = {}
	for ig, group in ipairs(mAcl.data.groups.list) do
		if not mAcl.data.groups.content[group] then return false end

		local isPublicGroup = false
		for iobj, object in ipairs(mAcl.data.groups.content[group].objects) do
			if object == "user.*" or object == "resource.*" then
				isPublicGroup = true
				break
			end
		end
		if isPublicGroup then
			for iacl, acl in ipairs(mAcl.data.groups.content[group].acls) do
				if not mAcl.data.acls.rights[acl] then return false end
				
				for ir, right in ipairs(mAcl.data.acls.rights[acl].list) do
					if not table.index(publicRightsData.list, right) then
						table.insert(publicRightsData.list, right)
					end
					publicRightsData.access[right] =
						publicRightsData.access[right] or mAcl.data.acls.rights[acl].access[right]
				end
			end
		end
	end

	return publicRightsData
end