-- // Services \\
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- // Variables \\
local LocalPlayer = Players.LocalPlayer
local CommandBarInstance = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("CommandBar")
local CommandBar = require(ReplicatedStorage.CommandBar)
local Commands = require(ReplicatedStorage.Commands)

-- // Script \\
CommandBar.UpdateCommandBarInstance(CommandBarInstance)
task.wait(1)
CommandBar.AddField("Command")
CommandBar.AddField("Text")
CommandBar.AddField("Number")
CommandBar.AddField("Player")
CommandBar.AddField("Decision")
CommandBar.Focus()

CommandBar.UpdateFieldSize(2, 250)
task.wait(0.5)
CommandBar.UpdateFieldSize(2, 80)

print(Commands.Commands)
