
local validRightTypes = {
	"general",
	"function",
	"resource",
	"command"
}

function aclIsValidRightType(rightType)
	check("s")

	return table.index(validRightTypes, rightType) and true or false
end

function aclIsValidRight(right)
	check("s")

	local rightType = utf8.match(right, "^(%a+)%.%a+")
	if not rightType then return false end

	return table.index(validRightTypes, rightType) and true or false
end

function aclIsAuto(acl)
	check("u:acl")

	return utf8.match(aclGetName(acl), "^autoACL_") and true or false
end

function aclGroupIsAuto(group)
	check("u:acl-group")

	return utf8.match(aclGroupGetName(group), "^autoGroup_") and true or false
end

function aclInGroup(acl, group)
	check("u:acl,u:acl-group")

	for i, groupACL in ipairs(aclGroupListACL(group)) do
		if groupACL == acl then return true end
	end
	return false
end

function aclRightExists(acl, right)
	check("u:acl,s")

	for i, r in ipairs(aclListRights(acl)) do
		if r == right then return true end
	end
	return false
end

function hasGroupPermissionTo(group, permission)
	check("u:acl-group,s")

	for i, acl in ipairs(aclGroupListACL(group)) do
		if aclGetRight(acl, permission) then return true end
	end
	return false
end

function getObjectACLName(object)
	check("u:resource-data|u:element:player|u:element:console")

	if object == console then return "user.Console" end

	if getUserdataType(object) == "resource-data" then
		return "resource."..getResourceName(object)
	else
		return "user."..(getPlayerAccountName(object) or "*")
	end 
end

function getObjectACLGroups(object)
	check("s|u:resource-data|u:element:player|u:element:console")

	if type(object) ~= "string" then object = getObjectACLName(object) end

	local groups = {}
	for i, group in ipairs(aclGroupList()) do
		if isObjectInACLGroup(object, group) then
			groups[#groups + 1] = group 
		end
	end
	return groups
end

function getObjectPermissions(object, allowedType)
	check("s|u:resource-data|u:element:player|u:element:console,?s")
	if allowedType and not table.index(validRightTypes, allowedType) then
		return warn("invalid allowed type", 2) and false
	end

	if type(object) ~= "string" then object = getObjectACLName(object) end

	local permissions = {}
	for gi, group in ipairs(getObjectACLGroups(object)) do
		for ai, acl in ipairs(aclGroupListACL(group)) do
			for ri, right in ipairs(aclListRights(acl, allowedType)) do
				if aclGetRight(acl, right) then
					if not table.index(permissions, right) then table.insert(permissions, right) end
				end
			end
		end
	end
	return permissions
end