local InteractableObject = {}
InteractableObject.__index = InteractableObject

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

function InteractableObject:update(dt)
	-- default no-op
end

function InteractableObject:onClick(x, y, button, isTouch, presses)
	-- default no-op
end

function InteractableObject:onScroll(dx, dy, x, y)
	-- default no-op
end

function InteractableObject:draw(centerX, centerY)
	self.drawCenterX = centerX or self.x
	self.drawCenterY = centerY or self.y
	return true
end

return InteractableObject
