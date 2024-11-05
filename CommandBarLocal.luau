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
CommandBar.AddField("Number")
CommandBar.AddField("Player")
CommandBar.AddField("Decision")
CommandBar.Focus()

CommandBar.UpdateFieldSize(2, 250)
task.wait(0.5)
CommandBar.UpdateFieldSize(2, 80)

print(Commands.Commands)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftControl then
			isHoldingControl = true
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftControl then
			isHoldingControl = false
		elseif input.KeyCode == Enum.KeyCode.C then
			if isHoldingControl then
				CommandBar.Clear()
				CommandBar.AddField("Command")
			end
			CommandBar.Toggle()
			CommandBar.Focus()
		end
	end
end)
