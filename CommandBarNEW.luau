-- // Services \\
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- // Module Init \\
local CommandBar = {}

-- // Variables \\
local CommandBarInstance
local Fields = {}

local activeField = 1
local globalOffSetX = 10

local isActive = false
local isHoldingShift = false
local isHoldingSuper = false
local isHoldingUltimateCombo = false -- Ctrl + Shift

-- !! do theming later
local charSize = 21
local padding = 10
local extraOffset = 14

-- !! do configs later
local config = {
	keyBindings = {
		["Activate"] = Enum.KeyCode.C,
		["Left"] = Enum.KeyCode.Left,
		["Right"] = Enum.KeyCode.Right,
		["Autocomplete"] = Enum.KeyCode.Tab,
		["Delete"] = Enum.KeyCode.Backspace,
		["Super"] = Enum.KeyCode.LeftControl
	}
}

local FIELD_TYPES = {
	["Command"] = {
		["defaultSize"] = 3,
		["maxSize"] = 8,
		["displayName"] = "cmd",
		["typeCheck"] = function(character: string)
			-- ??
			return true
		end,
	},
	["Text"] = {
		["defaultSize"] = 5,
		["maxSize"] = 10,
		["displayName"] = "text",
		["typeCheck"] = function(character: string)
			return true
		end,
	},
	["Number"] = {
		["defaultSize"] = 2,
		["maxSize"] = 4,
		["displayName"] = "num",
		["typeCheck"] = function(character: string)
			return tonumber(character) ~= nil
		end,
	},
	["Player"] = {
		["defaultSize"] = 6,
		["maxSize"] = 9,
		["displayName"] = "player",
		["typeCheck"] = function(character: string)
			-- !! special characters
			return true
		end,
	},
	["Decision"] = {
		["defaultSize"] = 1,
		["maxSize"] = 5,
		["displayName"] = "?",
		["typeCheck"] = function(character: string)
			return true
		end,
	}
}


-- // Functions \\
CommandBar.SetCommandBarInstance = function(newInstance: Instance)
	CommandBarInstance = newInstance.Bar
end

CommandBar.AddField = function(fieldType: string)
	local newFieldInstance = ReplicatedStorage.FieldHolder:Clone()
	newFieldInstance.Position = UDim2.new(0, globalOffSetX, 0, 0)
	newFieldInstance.Name = fieldType.."FieldHolder"
	
	newFieldInstance.Size = UDim2.new(0, FIELD_TYPES[fieldType]["defaultSize"] * charSize + extraOffset, 1, 0)
	newFieldInstance.TextLabel.Text = FIELD_TYPES[fieldType]["displayName"]
	
	globalOffSetX += newFieldInstance.Size.X.Offset +  padding
	
	local newFieldInfo = {
		Instance = newFieldInstance,
		Value = "",
		fieldType = fieldType,
		OffSetX = globalOffSetX,
		-- !! originalSize
		-- !! originalPosition
		FieldSizeX = FIELD_TYPES[fieldType]["defaultSize"],
		TextSizeX = 0,
		TextPositionX = 0
	}
	
	table.insert(Fields, newFieldInfo)
	newFieldInstance.Parent = CommandBarInstance
end

CommandBar.Show = function()
	CommandBarInstance.Parent.Enabled = true
	isActive = true
end
CommandBar.Hide = function()
	CommandBarInstance.Parent.Enabled = false
	isActive = false
end
CommandBar.Toggle = function()
	CommandBarInstance.Parent.Enabled = not CommandBarInstance.Parent.Enabled
	isActive = not isActive
end

CommandBar.Clear = function()
	for _, field in Fields do
		field.Instance:Destroy()
		table.clear(field)
		field = nil
	end
	table.clear(Fields)
	globalOffSetX = 10
	CommandBar.AddField("Command")
end

CommandBar.SetActiveField = function(fieldNumber: number)
	if Fields[fieldNumber] then -- if it exists
		for _, field in Fields do -- for each field
			field.Instance.Field.UIStroke.Color = Color3.fromRGB(0, 0, 0) -- make it black
		end
	end
	Fields[fieldNumber].Instance.Field.UIStroke.Color = Color3.fromRGB(255, 255, 255) -- make the new active field white
	activeField = fieldNumber
end

CommandBar.UpdateFieldSize = function(fieldNumber: number, amount: number)
	local currentField = Fields[fieldNumber]
	currentField.FieldSizeX += amount
	currentField.Instance.Size += UDim2.new(0, amount * charSize, 0, 0)
	currentField.OffSetX += amount * charSize
	CommandBar.UpdateFieldPositions()
end

CommandBar.UpdateFieldPositions = function()
	local cumulativeOffsetX = 10
	
	for _, field in Fields do
		field.Instance.Position = UDim2.new(0, cumulativeOffsetX, 0, 0)
		field.OffSetX = cumulativeOffsetX
		
		cumulativeOffsetX += (field.FieldSizeX * charSize) + padding + extraOffset
	end
end

CommandBar.AddCharacterToText = function(fieldNumber: number, character: string)
	local currentField = Fields[fieldNumber]
	local fieldType = currentField.fieldType
	
	if FIELD_TYPES[fieldType]["typeCheck"](character) == false then -- if the character is NOT allowed in the field type
		task.spawn(function()
			Fields[fieldNumber].Instance.Field.UIStroke.Color = Color3.fromRGB(255, 0, 0) -- make it red
			task.wait(0.2)
			Fields[fieldNumber].Instance.Field.UIStroke.Color = Color3.fromRGB(0, 0, 0) -- make it normal again
		end)
		return -- end function / NOT add character to text
	end
	
	-- only reaches this point when the character IS allowed
	local FieldSizeX = currentField.FieldSizeX
	local TextLabel = currentField.Instance.Field.TextFrame.TextLabel -- the pseudo textbox
	
	TextLabel.Size += UDim2.new(0, charSize, 0, 0)
	
	if not isHoldingShift then -- if not holding shift
		character = character:lower() -- make the character lowercase because default is capital
	end
	
	local newText = currentField.Value..character -- add the character to the field's value
	currentField.Value = newText
	TextLabel.Text = newText
	currentField.TextSizeX += 1
	
	local TextSizeX = currentField.TextSizeX
	if TextSizeX < FIELD_TYPES[fieldType]["maxSize"] then -- if it CAN extend the field size
		if TextSizeX > FieldSizeX then -- if the size of the text is greater than the size of the field
			CommandBar.UpdateFieldSize(fieldNumber, 1)
		end
	else -- if max size has been reached
		CommandBar.MoveFieldText(fieldNumber, -1)
	end
end

CommandBar.DeleteCharacterFromText = function(fieldNumber: number, position: number)
	local currentField = Fields[fieldNumber]
	local newText = string.sub(currentField.Value, position - 1, position)
	
	currentField.Value = newText
	currentField.Instance.Field.TextFrame.TextLabel.Text = newText
	currentField.Instance.Field.TextFrame.TextLabel.Size += UDim2.new(0, -charSize, 0, 0)
	
	currentField.TextPositionX += -1
	currentField.TextSizeX += -1
	
	local TextSizeX = currentField.TextSizeX
	local FieldSizeX = currentField.FieldSizeX
	local fieldType = currentField.fieldType
	
	-- !!RESUME
	-- !!FIX
	
	if TextSizeX < FIELD_TYPES[fieldType]["maxSize"] then
		if TextSizeX < FieldSizeX then
			if FieldSizeX > FIELD_TYPES[fieldType]["defaultSize"] then
				CommandBar.UpdateFieldSize(fieldNumber, 1)
			end
		end
	end
	
	if currentField.TextPositionX < 0 then
		CommandBar.MoveFieldText(fieldNumber, 1)
	end
end

CommandBar.ClearFieldText = function(fieldNumber: number)
	local currentField = Fields[fieldNumber]
	currentField.Value = ""
	local TextLabel = currentField.Instance.Field.TextFrame.TextLabel
	TextLabel.Text = ""
	TextLabel.Size = UDim2.new(0, 0, 1, 0)
	TextLabel.Position = UDim2.new(0, 0, 0, 0)
	currentField.TextPositionX = 0
	currentField.Instance.Size = UDim2.new(0, FIELD_TYPES[currentField.fieldType]["defaultSize"] * charSize + extraOffset, 1, 0)
	CommandBar.UpdateFieldPositions()
end

CommandBar.MoveFieldText = function(fieldNumber: number, amount: number)
	Fields[fieldNumber].TextPositionX += amount
	Fields[fieldNumber].Instance.Field.TextFrame.TextLabel.Position = UDim2.new(0, Fields[fieldNumber].TextPositionX * charSize, 0, 0)
end

local keyActions = {
	[config.keyBindings.Activate] = function()
		if isActive == false then -- if it's NOT on the screen
			if isHoldingSuper then -- if holding special key
				CommandBar.Clear()
				activeField = 1
			end
			-- if not holding super / do anyways
			CommandBar.Show()
			CommandBar.SetActiveField(activeField)
		else -- if it's ON the screen
			if isHoldingSuper then -- if holding special key
				CommandBar.Hide()
			else
				CommandBar.AddCharacterToText(activeField, UserInputService:GetStringForKeyCode(config.keyBindings.Activate))
			end
		end
	end,
	[config.keyBindings.Delete] = function()
		if isHoldingSuper then
			CommandBar.ClearFieldText(activeField)
		else
			CommandBar.DeleteCharacterFromText(activeField, string.len(Fields[activeField].Value) - 1) -- !!UPDATE: char position
		end
	end,
}

CommandBar.InputBegan = function(key: Enum.KeyCode)
	if key == Enum.UserInputType.Keyboard then
		if key == config.keyBindings.Super then
			isHoldingSuper = true
		end
		if key == Enum.KeyCode.LeftShift then
			isHoldingShift = true
		end
	end
end
CommandBar.InputEnded = function(key: Enum.KeyCode)
	if keyActions[key] then -- if an action exists
		keyActions[key]()
	elseif isActive then -- if an action does NOT exist and user is typing
		local character = UserInputService:GetStringForKeyCode(key)
		CommandBar.AddCharacterToText(activeField, character)
	end
end

return CommandBar
