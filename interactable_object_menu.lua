---@class InteractableObjectMenuOptions
---@field boxSize? number
---@field spacing? number
---@field marginLeft? number
---@field marginBottom? number
---@field previewScale? number
---@field cornerRadius? number

---@class InteractableObjectMenu
---@field objects InteractableObject[]
---@field boxSize number
---@field spacing number
---@field marginLeft number
---@field marginBottom number
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
	local boxSize = self.boxSize
	local spacing = self.spacing
	local width = (count * boxSize) + ((count - 1) * spacing)
	local height = boxSize
	local x = self.marginLeft
	local y = love.graphics.getHeight() - self.marginBottom - boxSize
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
	local boxSize = self.boxSize
	local spacing = self.spacing
	local startX = self.marginLeft
	local startY = love.graphics.getHeight() - self.marginBottom - boxSize
	if x < startX or y < startY or y > startY + boxSize then
		return nil
	end
	local step = boxSize + spacing
	local index = math.floor((x - startX) / step) + 1
	if index < 1 or index > count then
		return nil
	end
	local boxX = startX + (index - 1) * step
	if x > boxX + boxSize then
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
	local boxSize = self.boxSize
	local spacing = self.spacing
	local startX = self.marginLeft
	local startY = love.graphics.getHeight() - self.marginBottom - boxSize
	local radius = self.cornerRadius

	for index, object in ipairs(self.objects) do
		local boxX = startX + (index - 1) * (boxSize + spacing)
		local boxY = startY
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
		if object and object.draw then
			local originalScale = object.scale or 1
			local originalOffset = object.timePickOffsetX
			object.scale = originalScale * self.previewScale
			if originalOffset ~= nil then
				object.timePickOffsetX = originalOffset * self.previewScale
			end
			object:draw(boxX + boxSize / 2, boxY + boxSize / 2)
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
