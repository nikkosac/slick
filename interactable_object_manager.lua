---@type InteractableObjectMenu
local InteractableObjectMenu = require("interactable_object_menu")

---@class InteractableObjectManager
---@field objects InteractableObject[]
---@field activeObject InteractableObject|nil
---@field menu InteractableObjectMenu|nil
local InteractableObjectManager = {}
InteractableObjectManager.__index = InteractableObjectManager

---@return InteractableObjectManager
function InteractableObjectManager.new()
	local self = setmetatable({}, InteractableObjectManager)
	self.objects = {}
	self.activeObject = nil
	self.menu = InteractableObjectMenu.new(self.objects)
	return self
end

---@param object InteractableObject
function InteractableObjectManager:add(object)
	table.insert(self.objects, object)
	if #self.objects == 1 then
		self.activeObject = object
	end
end

---@param object InteractableObject|nil
---@return boolean
function InteractableObjectManager:setActive(object)
	if object == nil then
		self.activeObject = nil
		return true
	end
	for _, entry in ipairs(self.objects) do
		if entry == object then
			self.activeObject = object
			return true
		end
	end
	return false
end

---@return InteractableObject|nil
function InteractableObjectManager:getActive()
	return self.activeObject
end

---@param dt number
function InteractableObjectManager:updateAll(dt)
	for _, object in ipairs(self.objects) do
		object:update(dt)
	end
end

---@param centerX number|nil
---@param centerY number|nil
function InteractableObjectManager:drawActive(centerX, centerY)
	if self.activeObject == nil then
		if #self.objects == 1 then
			self.activeObject = self.objects[1]
		else
			return
		end
	end
	self.activeObject:drawActive(centerX, centerY)
end

function InteractableObjectManager:drawMenu()
	if self.menu == nil then
		return
	end
	self.menu:draw(self.activeObject)
end

function InteractableObjectManager:draw()
	self:drawMenu()
	local screenWidth = love.graphics.getWidth()
	local screenHeight = love.graphics.getHeight()
	local gridWidth = screenWidth * 12 / 16
	local panelWidth = screenWidth - gridWidth
	local centerX = gridWidth + (panelWidth / 2)
	local centerY = screenHeight * 0.78
	if self.menu then
		local _, menuY, _, menuHeight = self.menu:getBounds()
		if menuY ~= nil then
			local spacing = self.menu.spacing or 0
			local remaining = screenHeight - (menuY + menuHeight + spacing)
			if remaining > 0 then
				centerY = menuY + menuHeight + spacing + (remaining / 2)
			else
				centerY = menuY + menuHeight + spacing
			end
		end
	end
	self:drawActive(centerX, centerY)
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function InteractableObjectManager:onClick(x, y, button, isTouch, presses)
	if self.menu and self.menu:containsPoint(x, y) then
		local selected = self.menu:getObjectAtPoint(x, y)
		if selected then
			self:setActive(selected)
		end
		return
	end
	local active = self.activeObject
	if active == nil then
		if #self.objects == 1 then
			active = self.objects[1]
			self.activeObject = active
		else
			return
		end
	end
	if active.containsPoint and active:containsPoint(x, y) then
		active:onClick(x, y, button, isTouch, presses)
	end
end

---@param dx number
---@param dy number
---@param x number
---@param y number
function InteractableObjectManager:onScroll(dx, dy, x, y)
	local active = self.activeObject
	if active == nil then
		if #self.objects == 1 then
			active = self.objects[1]
			self.activeObject = active
		else
			return
		end
	end
	active:onScroll(dx, dy, x, y)
end

return InteractableObjectManager
