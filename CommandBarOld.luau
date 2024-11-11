-- // Services \\
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- // Module Init \\
local CommandBar = {}

-- // Variables \\
local CommandBarInstance
local Fields = {}
local currentField = 1
local OffSetX = 10

local isActive = false
local isHoldingControl = false
local isHoldingShift = false

local charSize = 21
local padding = 10
local extraOffset = 14

local FIELD_TYPES = {
	Command = {name = "Command", maxSize = charSize*8 -extraOffset},
	Text = {name = "Text", maxSize = charSize*10 -extraOffset},
	Number = {name = "Number", maxSize = charSize*4 -extraOffset},
	Player = {name = "Player", maxSize = charSize*9 -extraOffset},
	Decision = {name = "Decision", maxSize = charSize*5 -extraOffset} -- dropdown
}

-- // Functions \\
CommandBar.UpdateCommandBarInstance = function(newCommandBarInstance: Instance)
	CommandBarInstance = newCommandBarInstance.Bar
end

CommandBar.ChangeDescription = function(newText: string)
	CommandBarInstance.Description.TextLabel.Text = newText
end

CommandBar.AddField = function(fieldType: string)
	local newFieldInstance = ReplicatedStorage.FieldHolder:Clone()
	newFieldInstance.Position = UDim2.new(0, OffSetX, 0, 0)
	newFieldInstance.Name = fieldType.."FieldHolder"
	
	if fieldType == FIELD_TYPES.Command["name"] then
		newFieldInstance.Size = UDim2.new(0, charSize*3 +extraOffset, 1, 0)
		newFieldInstance.TextLabel.Text = "cmd"
		
	elseif fieldType == FIELD_TYPES.Text["name"] then
		newFieldInstance.Size = UDim2.new(0, charSize*5 +extraOffset, 1, 0)
		newFieldInstance.TextLabel.Text = "text"
		
	elseif fieldType == FIELD_TYPES.Number["name"] then
		newFieldInstance.Size = UDim2.new(0, charSize*2 +extraOffset, 1, 0)
		newFieldInstance.TextLabel.Text = "num"
		
	elseif fieldType == FIELD_TYPES.Player["name"] then
		newFieldInstance.Size = UDim2.new(0, charSize*6 +extraOffset, 1, 0) -- !!replace 200 with size of smallest text available [Udim.new() + amountOfChars * 5]
		newFieldInstance.TextLabel.Text = "player"
	elseif fieldType == FIELD_TYPES.Decision["name"] then
		newFieldInstance.Size = UDim2.new(0, charSize*5 +extraOffset, 0, 0) -- !!replace 150 with size of smallest text available
		newFieldInstance.TextLabel.Text = "?"
	end
	
	OffSetX += newFieldInstance.Size.X.Offset + padding
	
	local newField = {
		Instance = newFieldInstance,
		value = "",
		fieldType = fieldType,
		originalSize = newFieldInstance.Size,
		originalPosition = newFieldInstance.Position,
		OffSetX = OffSetX
	}
	table.insert(Fields, newField)
	newFieldInstance.Parent = CommandBarInstance
end

CommandBar.UpdateFieldPositions = function() -- ChatGPT cuz I gave up (4 hours)
	local cumulativeOffset = 10 -- Reset initial offset

	for index, field in Fields do
		field.Instance.Position = UDim2.new(0, cumulativeOffset, 0, 0)
		field.OffSetX = cumulativeOffset

		cumulativeOffset += field.Instance.Size.X.Offset + padding -- Add size and padding for next field
	end
end

CommandBar.UpdateFieldSize = function(fieldNumber: number, amount: number)
	Fields[fieldNumber].Instance.Size += UDim2.new(0, amount, 0, 0)
	Fields[fieldNumber].OffSetX += amount
	CommandBar.UpdateFieldPositions()
end

--currentField, Fields[currentField].Instance.Size.X.Offset + charSize

CommandBar.Focus = function(fieldNumber: number)
	if Fields[fieldNumber] then 
		CommandBar.ChangeActiveField(fieldNumber)
	end
end

CommandBar.ChangeActiveField = function(fieldNumber: number)
	if Fields[fieldNumber] then
		for index, field in Fields do
			field.Instance.Field.UIStroke.Color = Color3.fromRGB(0, 0, 0) -- make old field black
		end
		--Fields[currentField].Instance.Field.UIStroke.Color = Color3.fromRGB(0, 0, 0) -- make old field black
		Fields[fieldNumber].Instance.Field.UIStroke.Color = Color3.fromRGB(255, 255, 255) -- make new field white
		currentField = fieldNumber
	end
end

CommandBar.Show = function()
	CommandBarInstance.Parent.Enabled = true
end
CommandBar.Hide = function()
	CommandBarInstance.Parent.Enabled = false
end
CommandBar.Toggle = function()
	CommandBarInstance.Parent.Enabled = not CommandBarInstance.Parent.Enabled
end

CommandBar.Clear = function()
	for _, field in Fields do
		field.Instance:Destroy()
		table.clear(field)
		field = nil
	end
	table.clear(Fields)
	OffSetX = 10
	CommandBar.AddField("Command")
end

local keybinds = {
	[Enum.KeyCode.C] = function()
		if isActive then --active
			if isHoldingControl then
				CommandBar.Hide()
				isActive = false
			else
				CommandBar.AddCharToText("C")
			end
		else -- not active
			if isHoldingControl then
				CommandBar.Clear()
				currentField = 1
			end
			CommandBar.Show()
			CommandBar.ChangeActiveField(currentField)
			isActive = true
		end
	end,
	[Enum.KeyCode.Left] = function()
		if isHoldingControl then
			-- !! move chars
		else
			if currentField == 1 then -- if it's the first field 
				local lastField
				for index, field in Fields do
					lastField = index
				end
				currentField = lastField
			else
				currentField -= 1
			end
			CommandBar.Focus(currentField)
			CommandBar.ChangeActiveField(currentField)
		end
	end,
	[Enum.KeyCode.Right] = function()
		if isHoldingControl then
			-- !! move chars
		else 
			if Fields[currentField + 1] == nil then -- if it's the last field
				currentField = 1
			else
				currentField += 1
			end
			--CommandBar.Focus(currentField)
			CommandBar.ChangeActiveField(currentField)
		end
	end,
	[Enum.KeyCode.Tab] = function()
		-- !! autocomplete
	end,
	[Enum.KeyCode.LeftControl] = function()
		isHoldingControl = false
	end,
	[Enum.KeyCode.Return] = function()
		-- !! execute
	end,
	[Enum.KeyCode.Backspace] = function()
		if isHoldingControl then
			Fields[currentField].value = ""
			Fields[currentField].Instance.Field.TextFrame.TextLabel.Text = ""
			Fields[currentField].Instance.Field.TextFrame.TextLabel.Size = UDim2.new(0, 0, 1, 0)
			Fields[currentField].Instance.Field.TextFrame.TextLabel.Position = UDim2.new(0, 0, 0, 0)
			Fields[currentField].Instance.Size = Fields[currentField].originalSize
			CommandBar.UpdateFieldPositions()
		else
			local newText = string.sub(Fields[currentField].value, 1, string.len(Fields[currentField].value) - 1)
			Fields[currentField].value = newText
			Fields[currentField].Instance.Field.TextFrame.TextLabel.Text = newText
			Fields[currentField].Instance.Field.TextFrame.TextLabel.Size += UDim2.new(0, -21, 0, 0)
		end
		
		local fieldType = Fields[currentField].fieldType
		local TextBoundsX = Fields[currentField].Instance.Field.TextFrame.TextLabel.TextBounds.X
		
		if TextBoundsX < FIELD_TYPES[fieldType]["maxSize"] then -- textbounds < fieldsize
			if TextBoundsX < Fields[currentField].Instance.Size.X.Offset then -- textbounds > fieldsize
				
				if Fields[currentField].Instance.Size.X.Offset > Fields[currentField].originalSize.X.Offset then -- i have no idea why this works
					CommandBar.UpdateFieldSize(currentField, -charSize)
				end
			end
		end
		
		if Fields[currentField].Instance.Field.TextFrame.TextLabel.Position.X.Offset < 0 then
			CommandBar.MoveFieldText(currentField, charSize)
		end
	end,
	[Enum.KeyCode.LeftShift] = function()
		isHoldingShift = false
	end,
}

CommandBar.InputBegan = function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftControl then
			isHoldingControl = true
		elseif input.KeyCode == Enum.KeyCode.LeftShift then
			isHoldingShift = true
		end
	end
end

CommandBar.MoveFieldText = function(fieldNumber: number, amount: number)
	local TextLabel = Fields[fieldNumber].Instance.Field.TextFrame.TextLabel
	TextLabel.Position += UDim2.new(0, amount, 0, 0)
end

CommandBar.AddCharToText = function(char: string)
	local fieldType = Fields[currentField].fieldType
	
	if fieldType == FIELD_TYPES.Command["name"] then
		-- allow anything
	elseif fieldType == FIELD_TYPES.Text["name"] then
		-- allow anything

	elseif fieldType == FIELD_TYPES.Number["name"] then
		if tonumber(char) == nil then
			task.spawn(function()
				Fields[currentField].Instance.Field.UIStroke.Color = Color3.fromRGB(255, 0, 0)
				task.wait(0.2)
				Fields[currentField].Instance.Field.UIStroke.Color = Color3.fromRGB(0, 0, 0)
			end)
			return
		end

	elseif fieldType == FIELD_TYPES.Player["name"] then
		-- allow anything !! remove special characters
	elseif fieldType == FIELD_TYPES.Decision["name"] then
		-- allow anything
	end
	
	local TextBoundsX = Fields[currentField].Instance.Field.TextFrame.TextLabel.TextBounds.X
	Fields[currentField].Instance.Field.TextFrame.TextLabel.Size += UDim2.new(0, 21, 0, 0)
	
	if not isHoldingShift then
		char = char:lower()
	end
	local newText = Fields[currentField].value..char
	Fields[currentField].value = newText
	Fields[currentField].Instance.Field.TextFrame.TextLabel.Text = newText
	
	if TextBoundsX < FIELD_TYPES[fieldType]["maxSize"] then -- can extend
		if TextBoundsX > Fields[currentField].Instance.Size.X.Offset - padding * 2 then -- textbounds > fieldsize
			CommandBar.UpdateFieldSize(currentField, charSize)
		end
	else
		CommandBar.MoveFieldText(currentField, -charSize)
	end
end

CommandBar.InputEnded = function(input, gameProcessed)
	if input.KeyCode and keybinds[input.KeyCode] then
		keybinds[input.KeyCode]()
	elseif isActive and input.UserInputType == Enum.UserInputType.Keyboard then
		local char = UserInputService:GetStringForKeyCode(input.KeyCode)
		CommandBar.AddCharToText(char)
	end
end

return CommandBar
