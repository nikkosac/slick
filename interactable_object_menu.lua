---@class InteractableObjectMenuOptions
---@field boxSize? number
---@field spacing? number
---@field marginLeft? number
---@field marginBottom? number
---@field marginTop? number
---@field previewScale? number
---@field cornerRadius? number

---@class InteractableObjectMenu
---@field objects InteractableObject[]
---@field boxSize number
---@field spacing number
---@field marginLeft number
---@field marginBottom number
---@field marginTop number
---@field previewScale number
---@field cornerRadius number
local InteractableObjectMenu = {}
InteractableObjectMenu.__index = InteractableObjectMenu

---@param objects InteractableObject[]|nil
---@param options InteractableObjectMenuOptions|nil
---@return InteractableObjectMenu
function InteractableObjectMenu.new(objects, options)
	local settings = options or {}
	local self = setmetatable({}, InteractableObjectMenu)
	self.objects = objects or {}
	self.boxSize = settings.boxSize or 84
	self.spacing = settings.spacing or 24
	self.marginLeft = settings.marginLeft or 16
	self.marginBottom = settings.marginBottom or 16
	self.marginTop = settings.marginTop or 16
	self.previewScale = settings.previewScale or 0.35
	self.cornerRadius = settings.cornerRadius or 6
	return self
end

---@return number|nil, number|nil, number|nil, number|nil
function InteractableObjectMenu:getBounds()
	local count = #self.objects
	if count == 0 then
		return nil
	end
	local columns = math.min(2, count)
	local rows = math.ceil(count / columns)
	local boxSize = self.boxSize
	local spacing = self.spacing
	local width = (columns * boxSize) + ((columns - 1) * spacing)
	local height = (rows * boxSize) + ((rows - 1) * spacing)
	local gridWidth = love.graphics.getWidth() * 12 / 16
	local panelWidth = love.graphics.getWidth() - gridWidth
	local x = gridWidth + math.max(0, (panelWidth - width) / 2)
	local y = self.marginTop
	return x, y, width, height
end

---@param x number
---@param y number
---@return boolean
function InteractableObjectMenu:containsPoint(x, y)
	local boundsX, boundsY, width, height = self:getBounds()
	if boundsX == nil then
		return false
	end
	return x >= boundsX and x <= boundsX + width
		and y >= boundsY and y <= boundsY + height
end

---@param x number
---@param y number
---@return InteractableObject|nil
function InteractableObjectMenu:getObjectAtPoint(x, y)
	local count = #self.objects
	if count == 0 then
		return nil
	end
	local columns = math.min(2, count)
	local rows = math.ceil(count / columns)
	local boxSize = self.boxSize
	local spacing = self.spacing
	local gridWidth = love.graphics.getWidth() * 12 / 16
	local panelWidth = love.graphics.getWidth() - gridWidth
	local startX = gridWidth + math.max(0, (panelWidth - ((columns * boxSize) + ((columns - 1) * spacing))) / 2)
	local startY = self.marginTop
	local width = (columns * boxSize) + ((columns - 1) * spacing)
	local height = (rows * boxSize) + ((rows - 1) * spacing)
	if x < startX or x > startX + width or y < startY or y > startY + height then
		return nil
	end
	local stepX = boxSize + spacing
	local stepY = boxSize + spacing
	local columnIndex = math.floor((x - startX) / stepX) + 1
	local rowIndex = math.floor((y - startY) / stepY) + 1
	if columnIndex < 1 or columnIndex > columns or rowIndex < 1 or rowIndex > rows then
		return nil
	end
	local boxX = startX + (columnIndex - 1) * stepX
	local boxY = startY + (rowIndex - 1) * stepY
	if x > boxX + boxSize or y > boxY + boxSize then
		return nil
	end
	local index = (rowIndex - 1) * columns + columnIndex
	if index > count then
		return nil
	end
	return self.objects[index]
end

---@param activeObject InteractableObject|nil
function InteractableObjectMenu:draw(activeObject)
	local count = #self.objects
	if count == 0 then
		return
	end
	local columns = math.min(2, count)
	local boxSize = self.boxSize
	local spacing = self.spacing
	local gridWidth = love.graphics.getWidth() * 12 / 16
	local panelWidth = love.graphics.getWidth() - gridWidth
	local startX = gridWidth + math.max(0, (panelWidth - ((columns * boxSize) + ((columns - 1) * spacing))) / 2)
	local startY = self.marginTop
	local radius = self.cornerRadius

	for index, object in ipairs(self.objects) do
		local row = math.floor((index - 1) / columns)
		local column = (index - 1) % columns
		local boxX = startX + column * (boxSize + spacing)
		local boxY = startY + row * (boxSize + spacing)
		local isActive = object == activeObject
		love.graphics.setColor(0.06, 0.08, 0.12, 0.6)
		love.graphics.rectangle("fill", boxX, boxY, boxSize, boxSize, radius, radius)
		if isActive then
			love.graphics.setColor(1, 0.9, 0.2, 1)
			love.graphics.setLineWidth(3)
		else
			love.graphics.setColor(0.2, 0.22, 0.28, 0.9)
			love.graphics.setLineWidth(1)
		end
		love.graphics.rectangle("line", boxX, boxY, boxSize, boxSize, radius, radius)
		if object and object.drawMenu then
			local originalScale = object.scale or 1
			local originalOffset = object.timePickOffsetX
			object.scale = originalScale * self.previewScale
			if originalOffset ~= nil then
				object.timePickOffsetX = originalOffset * self.previewScale
			end
			object:drawMenu(boxX + boxSize / 2, boxY + boxSize / 2)
			object.scale = originalScale
			if originalOffset ~= nil then
				object.timePickOffsetX = originalOffset
			end
		end
	end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1, 1)
end

return InteractableObjectMenu
