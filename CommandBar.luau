-- // Services \\
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Module Init \\
local CommandBar = {}

-- // Variables \\
local CommandBarInstance
CommandBar.Fields = {}
CommandBar.OffSetX = 10

local FIELD_TYPES = {
	Command = "Command",
	Text = "Text",
	Number = "Number",
	Player = "Player",
	Decision = "Decision" -- dropdown
}

-- // Functions \\
CommandBar.UpdateCommandBarInstance = function(newCommandBarInstance: Instance)
	CommandBarInstance = newCommandBarInstance.Bar
end

CommandBar.ChangeDescription = function(newText: string)
	CommandBarInstance.Description.TextLabel.Text = newText
end

CommandBar.AddField = function(fieldType: string)
	local newField = ReplicatedStorage.FieldHolder:Clone()
	newField.Position = UDim2.new(0, CommandBar.OffSetX, 0, 0)
	newField.Name = fieldType.."FieldHolder"
	
	if fieldType == FIELD_TYPES.Command then
		newField.Size = UDim2.new(0, 70, 1, 0)
		newField.TextLabel.Text = "cmd"
		
	elseif fieldType == FIELD_TYPES.Text then
		newField.Size = UDim2.new(0, 200, 1, 0)
		newField.TextLabel.Text = "text"
		
	elseif fieldType == FIELD_TYPES.Number then
		newField.Size = UDim2.new(0, 70, 1, 0)
		newField.TextLabel.Text = "num"
		
	elseif fieldType == FIELD_TYPES.Player then
		newField.Size = UDim2.new(0, 200, 1, 0) -- !!replace 200 with size of smallest text available [Udim.new() + amountOfChars * 5]
		newField.TextLabel.Text = "player"
	elseif fieldType == FIELD_TYPES.Decision then
		newField.Size = UDim2.new(0, 150, 0, 0) -- !!replace 150 with size of smallest text available
		newField.TextLabel.Text = "?"
	end
	
	CommandBar.OffSetX += newField.Size.X.Offset + 15
	
	table.insert(CommandBar.Fields, newField)
	newField.Parent = CommandBarInstance
end

CommandBar.UpdateOffSetX = function()
	CommandBar.OffSetX = 10
	for index, field in CommandBar.Fields do
		CommandBar.OffSetX += field.Size.X.Offset + 15
		if CommandBar.Fields[index + 1] then
			CommandBar.Fields[index + 1].Position = UDim2.new(0, CommandBar.OffSetX, 0, 0)
		end
	end
end

CommandBar.UpdateFieldSize = function(fieldNumber: number, newSize)
	CommandBar.Fields[fieldNumber].Size = UDim2.new(0, newSize, 1, 0)
	CommandBar.UpdateOffSetX()
end

CommandBar.Focus = function()
	CommandBarInstance.CommandFieldHolder.Field.TextBox:CaptureFocus()
end

return CommandBar
