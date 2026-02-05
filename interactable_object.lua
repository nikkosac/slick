---@class InteractableObjectOptions
---@field x? number
---@field y? number
---@field scale? number

---@class InteractableObject
---@field x number
---@field y number
---@field drawCenterX number
---@field drawCenterY number
---@field scale number
local InteractableObject = {}
InteractableObject.__index = InteractableObject

---@param options InteractableObjectOptions|nil
---@return InteractableObject
function InteractableObject.new(options)
	local settings = options or {}
	local self = setmetatable({}, InteractableObject)
	self.x = settings.x or 0
	self.y = settings.y or 0
	self.drawCenterX = self.x
	self.drawCenterY = self.y
	self.scale = settings.scale or 1
	return self
end

---@param dt number
function InteractableObject:update(dt)
	-- default no-op
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function InteractableObject:onClick(x, y, button, isTouch, presses)
	-- default no-op
end

---@param dx number
---@param dy number
---@param x number
---@param y number
function InteractableObject:onScroll(dx, dy, x, y)
	-- default no-op
end

---@param centerX number|nil
---@param centerY number|nil
---@return boolean
function InteractableObject:drawActive(centerX, centerY)
	self.drawCenterX = centerX or self.x
	self.drawCenterY = centerY or self.y
	return true
end

---@param centerX number|nil
---@param centerY number|nil
---@return boolean
function InteractableObject:drawMenu(centerX, centerY)
	self.drawCenterX = centerX or self.x
	self.drawCenterY = centerY or self.y
	return true
end

return InteractableObject
