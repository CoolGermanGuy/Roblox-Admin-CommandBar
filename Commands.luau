-- // Services \\
local Players = game:GetService("Players")

-- // Module Init \\
local CommandHandler = {}

-- // Variables \\
CommandHandler.Commands = {}
CommandHandler.CommandData = {
	["kill"] = {
		callback = function(args)
			local player = table.unpack(args)
			player.Character.Humanoid.Health = 0
		end,
		permissionLevel = 3,
		description = "Kills a player",
		parameters = {
			required = {
				[1] = {["Player"] = "The player that will die"}
			},
			optional = {
				[1] = {["Text"] = "The message that will be displayed"},
				[2] = {["Decision"] = "The **style** the message will have"}
			}
		},
		aliases = {
			"unalive", 
		}
	},
	["teleport"] = {
		callback = function(args)
			local player = table.unpack(args)
			-- !! add stuff bruh
		end,
		permissionLevel = 2,
		description = "Teleports **you** to **player**",
		parameters = {
			required = {
				[1] = {["Player"] = "The **player** you will teleport to"}
			},
			optional = {
				
			}
		},
		aliases = {
			"tp", "goto"
		}
	},
	["kick"] = {
		callback = function(args)
			local player, message = table.unpack(args)
			if message then
				player:Kick(message)
			else
				player:Kick()
			end
		end,
		permissionLevel = 4,
		description = "**Kicks** the **player** from the experience",
		parameters = {
			required = {
				[1] = {["Player"] = "The **player** you want to kick"}
			},
			optional = {
				[1] = {["Text"] = "The **message** the **player** will have displayed"}
			}
		},
		aliases = {
			"byebye"
		}
	}
}

-- // Commands Init \\
for command, data in CommandHandler.CommandData do
	CommandHandler.Commands[command] = data
	for aliasIndex in data.aliases do
		CommandHandler.Commands[data.aliases[aliasIndex]] = data
	end
end

-- // End \\
return CommandHandler
