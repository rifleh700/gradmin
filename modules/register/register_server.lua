
addCommandHandler("register",
	function(player, command, username, password)
		if getElementType(player) ~= "player" then return end

		if not username or not password then
			outputChatBox("register: Syntax is 'register <nick> <password>'", player, unpack(COLORS.acl))
			return
		end

		if utf8.len(password) < 4 then
			outputChatBox("register: Password should be at least 4 characters long", player, unpack(COLORS.acl))
			return
		end

		if not addAccount(username, password) then
			if getAccount(username) then
				outputChatBox("register: Account with this name already exists", player, unpack(COLORS.acl))
			else
				outputChatBox("register: Unknown error", player, unpack(COLORS.red))
			end
			return
		end

		outputChatBox("register: You have successfully registered", player, unpack(COLORS.acl))
		cMessages.outputConsole("REGISTER: "..getPlayerName(player).." registered account '"..username.."' (IP: "..getPlayerIP(player).."  Serial: "..getPlayerSerial(player)..")")
	end
)