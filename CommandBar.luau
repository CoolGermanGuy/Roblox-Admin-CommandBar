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

local FIELD_TYPES = {
	Command = {name = "Command", maxSize = 21*8 -14},
	Text = {name = "Text", maxSize = 21*10 -14},
	Number = {name = "Number", maxSize = 21*4 -14},
	Player = {name = "Player", maxSize = 21*9 -14},
	Decision = {name = "Decision", maxSize = 21*5 -14} -- dropdown
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
		newFieldInstance.Size = UDim2.new(0, 21*3 +14, 1, 0)
		newFieldInstance.TextLabel.Text = "cmd"
		
	elseif fieldType == FIELD_TYPES.Text["name"] then
		newFieldInstance.Size = UDim2.new(0, 21*5 -14, 1, 0)
		newFieldInstance.TextLabel.Text = "text"
		
	elseif fieldType == FIELD_TYPES.Number["name"] then
		newFieldInstance.Size = UDim2.new(0, 21*2 -14, 1, 0)
		newFieldInstance.TextLabel.Text = "num"
		
	elseif fieldType == FIELD_TYPES.Player["name"] then
		newFieldInstance.Size = UDim2.new(0, 21*6 -14, 1, 0) -- !!replace 200 with size of smallest text available [Udim.new() + amountOfChars * 5]
		newFieldInstance.TextLabel.Text = "player"
	elseif fieldType == FIELD_TYPES.Decision["name"] then
		newFieldInstance.Size = UDim2.new(0, 21*5 -14, 0, 0) -- !!replace 150 with size of smallest text available
		newFieldInstance.TextLabel.Text = "?"
	end
	
	OffSetX += newFieldInstance.Size.X.Offset + 15
	
	local newField = {
		Instance = newFieldInstance,
		value = "",
		fieldType = fieldType,
		originalSize = newFieldInstance.Size
	}
	
	table.insert(Fields, newField)
	newFieldInstance.Parent = CommandBarInstance
end

CommandBar.UpdateOffSetX = function()
	OffSetX = 10
	for index, field in Fields do
		OffSetX += field.Instance.Size.X.Offset + 15
		if Fields[index + 1] then
			Fields[index + 1].Position = UDim2.new(0, OffSetX, 0, 0)
		end
	end
end

CommandBar.UpdateFieldSize = function(fieldNumber: number, newSize)
	Fields[fieldNumber].Instance.Size = UDim2.new(0, newSize, 1, 0)
	CommandBar.UpdateOffSetX()
end

CommandBar.Focus = function(fieldNumber: number)
	if Fields[fieldNumber] then 
		CommandBar.ChangeActiveField(fieldNumber)
	end
end

CommandBar.ChangeActiveField = function(fieldNumber: number)
	if Fields[fieldNumber] then
		Fields[currentField].Instance.Field.UIStroke.Color = Color3.fromRGB(0, 0, 0) -- make old field black
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
				CommandBar.AddField("Command")
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
			CommandBar.Focus(currentField - 1)
			CommandBar.ChangeActiveField(currentField - 1)
		end
	end,
	[Enum.KeyCode.Right] = function()
		if isHoldingControl then
			-- !! move chars
		else
			CommandBar.Focus(currentField + 1)
			CommandBar.ChangeActiveField(currentField + 1)
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
		local newText = string.sub(Fields[currentField].value, 1, string.len(Fields[currentField].value) - 1)
		Fields[currentField].value = newText
		Fields[currentField].Instance.Field.TextFrame.TextLabel.Text = newText
		
		local fieldType = Fields[currentField].fieldType
		local TextBoundsX = Fields[currentField].Instance.Field.TextFrame.TextLabel.TextBounds.X
		
		if TextBoundsX < FIELD_TYPES[fieldType]["maxSize"] then -- textbounds < fieldsize
			if TextBoundsX < Fields[currentField].Instance.Size.X.Offset then -- textbounds > fieldsize
				if TextBoundsX > Fields[currentField].originalSize.X.Offset - 28 then -- i have no idea why this works
					--Fields[currentField].Instance.Size += UDim2.new(0, -21, 0, 0)
					CommandBar.UpdateFieldSize(currentField, Fields[currentField].Instance.Size.X.Offset - 21)
				end
			end
		else -- cant extend

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

CommandBar.AddCharToText = function(char: string)
	local fieldType = Fields[currentField].fieldType
	local TextBoundsX = Fields[currentField].Instance.Field.TextFrame.TextLabel.TextBounds.X
	
	if not isHoldingShift then
		char = char:lower()
	end
	local newText = Fields[currentField].value..char
	Fields[currentField].value = newText
	Fields[currentField].Instance.Field.TextFrame.TextLabel.Text = newText
	
	if TextBoundsX < FIELD_TYPES[fieldType]["maxSize"] then -- can extend
		if TextBoundsX > Fields[currentField].Instance.Size.X.Offset - 28 then -- textbounds > fieldsize
			--Fields[currentField].Instance.Size += UDim2.new(0, 21, 0, 0)
			CommandBar.UpdateFieldSize(currentField, Fields[currentField].Instance.Size.X.Offset + 21)
		end
	else -- cant extend
		
	end
end

CommandBar.InputEnded = function(input, gameProcessed)
	if input.KeyCode and keybinds[input.KeyCode] then
		keybinds[input.KeyCode]()
	elseif isActive then
		local char = UserInputService:GetStringForKeyCode(input.KeyCode)
		CommandBar.AddCharToText(char)
	end
end

return CommandBar
