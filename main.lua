---@type Clock
local Clock = require("clock")
---@type InteractableObjectManager
local InteractableObjectManager = require("interactable_object_manager")

function love.load()
	love.graphics.setBackgroundColor(0.05, 0.08, 0.2, 1)
	---@type InteractableObjectManager
	objectManager = InteractableObjectManager.new()
	---@type number
	local centerX = love.graphics.getWidth() / 2
	---@type number
	local centerY = love.graphics.getHeight() / 2
	---@type Clock[]
	clocks = {
		Clock.new({ x = centerX, y = centerY, scale = 0.1 }),
		Clock.new({ x = centerX, y = centerY, scale = 0.1 }),
		Clock.new({ x = centerX, y = centerY, scale = 0.1 }),
		Clock.new({ x = centerX, y = centerY, scale = 0.1 }),
	}
	clocks[1]:setTime(1, 0, 0)
	clocks[2]:setTime(4, 30, 0)
	clocks[3]:setTime(9, 15, 0)
	clocks[4]:setTime(11, 45, 0)
	for _, clock in ipairs(clocks) do
		objectManager:add(clock)
	end
end

---@param dt number
function love.update(dt)
	objectManager:updateAll(dt)
end

---@param key string
function love.keypressed(key)
	---@type InteractableObject|nil
	local active = objectManager:getActive()
	if active == nil then
		return
	end
	if key == "f" and active.setTime then
		active:setTime(3, 24, 0)
	elseif key == "q" and active.incrementTimeScale then
		active:incrementTimeScale(-1)
	elseif key == "w" and active.incrementTimeScale then
		active:incrementTimeScale(1)
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(objectManager:getClickMessage(), 20, 20)
	objectManager:draw()
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function love.mousepressed(x, y, button, isTouch, presses)
	objectManager:onClick(x, y, button, isTouch, presses)
end

---@param dx number
---@param dy number
function love.wheelmoved(dx, dy)
---@type number, number
	local mouseX, mouseY = love.mouse.getPosition()
	objectManager:onScroll(dx, dy, mouseX, mouseY)
end
