
cCommands.add("aclcreate",
	function(admin, aclName)
		if aclGet(aclName) then return false, "ACL '"..aclName.."' is already exist" end
		
		local acl = aclCreate(aclName)
		if not acl then return false end

		aclSave()

		triggerEvent("gra.onAclCreate", root, acl)

		return true, "ACL entry '"..aclName.."' been successfully created"
	end,
	"acl-name:s", "create new ACL entry in the Access Control List", COLORS.acl
)

cCommands.add("acldestroy",
	function(admin, aclName)
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		
		if not aclDestroy(acl) then return false end

		aclSave()
		triggerEvent("gra.onAclDestroy", root, acl)

		return true, "ACL entry '"..aclName.."' been successfully destroyed"
	end,
	"acl-name:s", "destroy ACL entry in the Access Control List", COLORS.acl
)

cCommands.add("aclcreategroup",
	function(admin, groupName)
		if aclGetGroup(groupName) then return false, "ACL group '"..groupName.."' is already exist" end
		
		local group = aclCreateGroup(groupName)
		if not group then return false end

		aclSave()
		triggerEvent("gra.onAclGroupCreate", root, group)

		return true, "ACL group '"..groupName.."' been successfully created"
	end,
	"aclgroup-name:s", "create new group in the Access Control List", COLORS.acl
)

cCommands.add("acldestroygroup",
	function(admin, groupName)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		
		if not aclDestroyGroup(group) then return false end

		aclSave()
		triggerEvent("gra.onAclGroupDestroy", root, group)

		return true, "ACL group '"..groupName.."' been successfully destroyed"
	end,
	"aclgroup-name:s", "destroy group in the Access Control List", COLORS.acl
)

cCommands.add("aclgroupaddacl",
	function(admin, groupName, aclName)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		if aclInGroup(acl, group) then return false, "ACL '"..aclName.."' is already in group '"..groupName.."'" end
		
		if not aclGroupAddACL(group, acl) then return false end

		aclSave()
		triggerEvent("gra.onAclGroupACLAdd", root, group, acl)

		return true, "ACL entry '"..aclName.."' has been successfully added to group '"..groupName.."'"
	end,
	"aclgroup-name:s,acl-name:s", "add ACL entry to group in the Access Control List", COLORS.acl
)

cCommands.add("aclgroupremoveacl",
	function(admin, groupName, aclName)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		if not aclInGroup(acl, group) then return false, "ACL '"..aclName.."' is not in group '"..groupName.."'" end
		
		if not aclGroupRemoveACL(group, acl) then return false end

		aclSave()
		triggerEvent("gra.onAclGroupACLRemove", root, group, acl)

		return true, "ACL entry '"..aclName.."' has been successfully removed from group '"..groupName.."'"
	end,
	"aclgroup-name:s,acl-name:s", "remove ACL entry from group in the Access Control List", COLORS.acl
)

cCommands.add("aclgroupaddobject",
	function(admin, groupName, object)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		if isObjectInACLGroup(object, group) then return false, "object '"..object.."' is already in group '"..groupName.."'" end
		
		if not aclGroupAddObject(group, object) then return false end

		aclSave()
		triggerEvent("gra.onAclGroupObjectAdd", root, group, object)

		return true, "object '"..object.."' has been successfully added to ACL group '"..groupName.."'"
	end,
	"aclgroup-name:s,object-name:s", "add object to group in the Access Control List", COLORS.acl
)

cCommands.add("aclgroupremoveobject",
	function(admin, groupName, object)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		if not isObjectInACLGroup(object, group) then return false, "object '"..object.."' is not in group '"..groupName.."'" end
		
		if not aclGroupRemoveObject(group, object) then return false end

		aclSave()
		triggerEvent("gra.onAclGroupObjectRemove", root, group, object)

		return true, "object '"..object.."' has been successfully removed from ACL group '"..groupName.."'"
	end,
	"aclgroup-name:s,object-name:s", "remove object from group in the Access Control List", COLORS.acl
)

cCommands.add("aclsetright",
	function(admin, aclName, right, access)
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		
		access = access or false
		if not aclSetRight(acl, right, access) then return false end

		aclSave()
		triggerEvent("gra.onAclRightChange", root, acl, right, access)

		return true, "ACL entry '"..aclName.."' right '"..right.."' set to '"..tostring(access).."'"
	end,
	"acl-name:s,right-name:s,[access(yes/no):b", "change or add the right in the ACL entry in the Access Control List", COLORS.acl
)

cCommands.add("aclremoveright",
	function(admin, aclName, right)
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		if aclGetRight(acl, right) == nil then return false, "right '"..right.."' does not exist in ACL '"..aclName.."'" end
		
		if not aclRemoveRight(acl, right) then return false end
		
		aclSave()
		triggerEvent("gra.onAclRightRemove", root, acl, right)

		return true, "right '"..right.."' has been successfully removed from ACL entry '"..aclName.."'"
	end,
	"acl-name:s,right-name:s", "remove right from ACL entry in the Access Control List", COLORS.acl
)