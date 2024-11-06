-- // Services \\
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- // Variables \\
local LocalPlayer = Players.LocalPlayer
local CommandBarInstance = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("CommandBar")
local CommandBar = require(ReplicatedStorage.CommandBar)
local Commands = require(ReplicatedStorage.Commands)

local isHoldingControl

-- // Script \\
CommandBar.UpdateCommandBarInstance(CommandBarInstance)
task.wait(1)
CommandBar.AddField("Command")
CommandBar.AddField("Text")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	CommandBar.InputBegan(input, gameProcessed)
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	CommandBar.InputEnded(input, gameProcessed)
end)
