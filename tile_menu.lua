---@class TileMenu
---@field minX number
---@field maxX number
---@field minY number
---@field maxY number
---@field bgColorR number
---@field bgColorG number
---@field bgColorB number
---@field bgColorA number
---@field menuManager MenuManager
---@field state GameState
local TileMenu = {}
TileMenu.__index = TileMenu

---@param menuManager MenuManager
---@param state GameState
---@param minX number
---@param maxX number
---@param minY number
---@param maxY number
---@return TileMenu
function TileMenu.new(menuManager, state, minX, maxX, minY, maxY)
	local self = setmetatable({}, TileMenu)
	self.minX = minX
	self.maxX = maxX
	self.minY = minY
	self.maxY = maxY
	self.bgColorR = 0.05
	self.bgColorG = 0.08
	self.bgColorB = 0.2
	self.bgColorA = 1
	self.menuManager = menuManager
	self.state = state
	return self
end

---@param minX number
---@param maxX number
---@param minY number
---@param maxY number
function TileMenu:setBounds(minX, maxX, minY, maxY)
	self.minX = minX
	self.maxX = maxX
	self.minY = minY
	self.maxY = maxY
end

---@return number|nil, number|nil, number|nil, number|nil
function TileMenu:getBounds()
	local width, height = love.graphics.getDimensions()
	local startX = width * self.minX
	local endX = width * self.maxX
	local startY = height * self.minY
	local endY = height * self.maxY
	local drawWidth = endX - startX
	local drawHeight = endY - startY
	if drawWidth <= 0 or drawHeight <= 0 then
		return nil
	end
	return startX, startY, drawWidth, drawHeight
end

function TileMenu:draw()
	local x, y, width, height = self:getBounds()
	if x == nil then
		return
	end
	love.graphics.setColor(self.bgColorR, self.bgColorG, self.bgColorB, self.bgColorA)
	love.graphics.rectangle("fill", x, y, width, height)
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function TileMenu:onClick(x, y, button, isTouch, presses)
	self.menuManager.isTileSelected = false
end

---@param dx number
---@param dy number
---@param x number
---@param y number
function TileMenu:onScroll(dx, dy, x, y)
	-- reserved for future tile menu actions
end

return TileMenu
