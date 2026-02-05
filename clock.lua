---@type InteractableObject
local InteractableObject = require("interactable_object")

---@class ClockImages
---@field clock love.Image
---@field hour love.Image
---@field minute love.Image
---@field seconds love.Image
---@field timePick love.Image

---@class Clock : InteractableObject
---@field images ClockImages
---@field timePickOffsetX number
---@field timePickOut boolean
---@field clockedStopped boolean
---@field timeScale number
---@field timeSeconds number
---@field timeAccumulator number
---@field hour number
---@field minute number
---@field seconds number
local Clock = setmetatable({}, { __index = InteractableObject })
Clock.__index = Clock

---@type number
local CLOCK_BLACK_RADIUS_SCALE = 0.7
---@type number
local CLOCK_YELLOW_RADIUS_SCALE = 0.6

---@param image love.Image
---@param x number
---@param y number
---@param scale number|nil
---@param rotation number|nil
local function drawCentered(image, x, y, scale, rotation)
	local width = image:getWidth()
	local height = image:getHeight()
	local drawScale = scale or 1
	local drawRotation = rotation or 0
	love.graphics.draw(image, x, y, drawRotation, drawScale, drawScale, width / 2, height / 2)
end

---@param image love.Image
---@param x number
---@param y number
---@param scale number|nil
---@param rotation number|nil
---@param originX number|nil
---@param originY number|nil
local function drawPivot(image, x, y, scale, rotation, originX, originY)
	local width = image:getWidth()
	local height = image:getHeight()
	local drawScale = scale or 1
	local drawRotation = rotation or 0
	local ox = (originX or 0.5) * width
	local oy = (originY or 0.5) * height
	love.graphics.draw(image, x, y, drawRotation, drawScale, drawScale, ox, oy)
end

---@param hour number|nil
---@param minute number|nil
---@param seconds number|nil
---@return number, number, number
local function normalizeTime(hour, minute, seconds)
	local h = (hour or 12) % 12
	local m = math.floor(minute or 0) % 60
	local s = math.floor(seconds or 0) % 60
	return h, m, s
end

---@param self Clock
---@param timeSeconds number
local function setTimeFields(self, timeSeconds)
	local remaining = timeSeconds
	self.hour = math.floor(remaining / 3600)
	remaining = remaining % 3600
	self.minute = math.floor(remaining / 60)
	self.seconds = remaining % 60
end

---@param timeSeconds number
---@return number
local function roundTimeDownToSecond(timeSeconds)
	return math.floor(timeSeconds)
end

---@param options InteractableObjectOptions|nil
---@return Clock
function Clock.new(options)
	local self = InteractableObject.new(options)
	setmetatable(self, Clock)
	if Clock.images == nil then
		---@type ClockImages
		Clock.images = {
			clock = love.graphics.newImage("assets/clock/clock.png"),
			hour = love.graphics.newImage("assets/clock/hour.png"),
			minute = love.graphics.newImage("assets/clock/minute.png"),
			seconds = love.graphics.newImage("assets/clock/seconds.png"),
			timePick = love.graphics.newImage("assets/clock/time_pick.png"),
		}
	end
	self.images = Clock.images
	self.timePickOffsetX = 0
	self.timePickOut = false
	self.clockedStopped = false
	self.timeScale = 1
	self.timeSeconds = 0
	self.timeAccumulator = 0
	self.hour = 0
	self.minute = 0
	self.seconds = 0
	self:setTime(12, 0, 0)
	return self
end

---@param hour number|nil
---@param minute number|nil
---@param seconds number|nil
function Clock:setTime(hour, minute, seconds)
	local h, m, s = normalizeTime(hour, minute, seconds)
	self.timeSeconds = (h * 3600) + (m * 60) + s
	self.hour = h
	self.minute = m
	self.seconds = s
end

---@param delta number|nil
function Clock:incrementTimeScale(delta)
	self.timeScale = self.timeScale + (delta or 0)
end

---@param dt number
function Clock:update(dt)
	if self.clockedStopped then
		return
	end
	local scaledDt = dt * self.timeScale
	self.timeAccumulator = self.timeAccumulator + scaledDt
	while self.timeAccumulator >= 1 do
		self.timeAccumulator = self.timeAccumulator - 1
		self.timeSeconds = (self.timeSeconds + 1) % (12 * 60 * 60)
		setTimeFields(self, self.timeSeconds)
	end
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function Clock:onClick(x, y, button, isTouch, presses)
	local drawCenterX = self.drawCenterX or self.x
	local drawCenterY = self.drawCenterY or self.y
	local image = self.images.timePick
	local halfWidth = (image:getWidth() * self.scale) / 2
	local halfHeight = (image:getHeight() * self.scale) / 2
	local centerX = drawCenterX + self.timePickOffsetX
	local centerY = drawCenterY
	if x >= centerX - halfWidth and x <= centerX + halfWidth
		and y >= centerY - halfHeight and y <= centerY + halfHeight then
		if self.timePickOut then
			self.timePickOffsetX = 0
			self.timePickOut = false
			self.clockedStopped = false
		else
			local timePickNudge = 300 * self.scale
			self.timePickOffsetX = self.timePickOffsetX + timePickNudge
			self.timePickOut = true
			self.clockedStopped = true
			self.timeSeconds = roundTimeDownToSecond(self.timeSeconds)
			setTimeFields(self, self.timeSeconds)
		end
	end
end

---@param dx number
---@param dy number
---@param x number
---@param y number
function Clock:onScroll(dx, dy, x, y)
	if not self.timePickOut then
		return
	end
	local drawCenterX = self.drawCenterX or self.x
	local drawCenterY = self.drawCenterY or self.y
	local image = self.images.timePick
	local halfWidth = (image:getWidth() * self.scale) / 2
	local halfHeight = (image:getHeight() * self.scale) / 2
	local centerX = drawCenterX + self.timePickOffsetX
	local centerY = drawCenterY
	if x < centerX - halfWidth or x > centerX + halfWidth
		or y < centerY - halfHeight or y > centerY + halfHeight then
		return
	end
	local minuteDelta = dy
	if minuteDelta == 0 then
		return
	end
	local totalMinutes = (self.hour * 60) + self.minute
	totalMinutes = (totalMinutes + minuteDelta) % (12 * 60)
	self.timeSeconds = (totalMinutes * 60) + self.seconds
	setTimeFields(self, self.timeSeconds)
end

---@param x number
---@param y number
---@return boolean
function Clock:containsPoint(x, y)
	local centerX = self.drawCenterX or self.x
	local centerY = self.drawCenterY or self.y
	local scale = self.scale
	local clockImage = self.images.clock
	local timePickImage = self.images.timePick
	local halfClockW = (clockImage:getWidth() * scale) / 2
	local halfClockH = (clockImage:getHeight() * scale) / 2
	local clockMinX = centerX - halfClockW
	local clockMaxX = centerX + halfClockW
	local clockMinY = centerY - halfClockH
	local clockMaxY = centerY + halfClockH
	local timeCenterX = centerX + self.timePickOffsetX
	local halfTimeW = (timePickImage:getWidth() * scale) / 2
	local halfTimeH = (timePickImage:getHeight() * scale) / 2
	local timeMinX = timeCenterX - halfTimeW
	local timeMaxX = timeCenterX + halfTimeW
	local timeMinY = centerY - halfTimeH
	local timeMaxY = centerY + halfTimeH
	local minX = math.min(clockMinX, timeMinX)
	local maxX = math.max(clockMaxX, timeMaxX)
	local minY = math.min(clockMinY, timeMinY)
	local maxY = math.max(clockMaxY, timeMaxY)
	return x >= minX and x <= maxX and y >= minY and y <= maxY
end

---@param centerX number|nil
---@param centerY number|nil
function Clock:drawActive(centerX, centerY)
	if not InteractableObject.drawActive(self, centerX, centerY) then
		return
	end
	local baseRadius = math.min(self.images.clock:getWidth(), self.images.clock:getHeight()) / 2
	local clockBaseRadius = baseRadius * self.scale
	local clockBlackRadius = clockBaseRadius * CLOCK_BLACK_RADIUS_SCALE
	local clockYellowRadius = clockBaseRadius * CLOCK_YELLOW_RADIUS_SCALE
	local drawCenterX = centerX or self.x
	local drawCenterY = centerY or self.y
	local twoPi = math.pi * 2
	local secondAngle = (self.seconds / 60) * twoPi
	local minuteAngle = ((self.minute + (self.seconds / 60)) / 60) * twoPi
	local hourAngle = ((self.hour + (self.minute / 60) + (self.seconds / 3600)) / 12) * twoPi
	local handPivotX = 0.5
	local handPivotY = 0.49

	drawCentered(self.images.timePick, drawCenterX + self.timePickOffsetX, drawCenterY, self.scale)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.circle("fill", drawCenterX, drawCenterY, clockBlackRadius)
	love.graphics.setColor(1, 0.9, 0.2, 1)
	love.graphics.circle("fill", drawCenterX, drawCenterY, clockYellowRadius)
	love.graphics.setColor(1, 1, 1, 1)

	drawCentered(self.images.clock, drawCenterX, drawCenterY, self.scale)
	drawPivot(self.images.hour, drawCenterX, drawCenterY, self.scale, hourAngle, handPivotX, handPivotY)
	drawPivot(self.images.minute, drawCenterX, drawCenterY, self.scale, minuteAngle, handPivotX, handPivotY)
	drawPivot(self.images.seconds, drawCenterX, drawCenterY, self.scale, secondAngle, handPivotX, handPivotY)
end

---@param centerX number|nil
---@param centerY number|nil
function Clock:drawMenu(centerX, centerY)
	if not InteractableObject.drawMenu(self, centerX, centerY) then
		return
	end
	local baseRadius = math.min(self.images.clock:getWidth(), self.images.clock:getHeight()) / 2
	local clockBaseRadius = baseRadius * self.scale
	local clockBlackRadius = clockBaseRadius * CLOCK_BLACK_RADIUS_SCALE
	local clockYellowRadius = clockBaseRadius * CLOCK_YELLOW_RADIUS_SCALE
	local drawCenterX = centerX or self.x
	local drawCenterY = centerY or self.y
	local twoPi = math.pi * 2
	local menuSeconds = 0
	local menuMinute = 0
	local menuHour = 0
	local secondAngle = (menuSeconds / 60) * twoPi
	local minuteAngle = ((menuMinute + (menuSeconds / 60)) / 60) * twoPi
	local hourAngle = ((menuHour + (menuMinute / 60) + (menuSeconds / 3600)) / 12) * twoPi
	local handPivotX = 0.5
	local handPivotY = 0.49
	local menuTimePickOffsetX = 0

	drawCentered(self.images.timePick, drawCenterX + menuTimePickOffsetX, drawCenterY, self.scale)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.circle("fill", drawCenterX, drawCenterY, clockBlackRadius)
	love.graphics.setColor(1, 0.9, 0.2, 1)
	love.graphics.circle("fill", drawCenterX, drawCenterY, clockYellowRadius)
	love.graphics.setColor(1, 1, 1, 1)

	drawCentered(self.images.clock, drawCenterX, drawCenterY, self.scale)
	drawPivot(self.images.hour, drawCenterX, drawCenterY, self.scale, hourAngle, handPivotX, handPivotY)
	drawPivot(self.images.minute, drawCenterX, drawCenterY, self.scale, minuteAngle, handPivotX, handPivotY)
	drawPivot(self.images.seconds, drawCenterX, drawCenterY, self.scale, secondAngle, handPivotX, handPivotY)
end

return Clock
