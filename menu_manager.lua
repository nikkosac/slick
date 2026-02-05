---@class MenuManager
---@field panelColorR number
---@field panelColorG number
---@field panelColorB number
---@field panelColorA number
---@field objectManager InteractableObjectManager
---@field tileMenu TileMenu|nil
---@field menuStartX number
---@field menuEndX number
---@field menuStartY number
---@field menuEndY number
---@field selectedTile Vec2
---@field isTileSelected boolean
local MenuManager = {}
MenuManager.__index = MenuManager

---@param objectManager InteractableObjectManager
---@param options table|nil
---@return MenuManager
function MenuManager.new(objectManager, options)
	local settings = options or {}
	local self = setmetatable({}, MenuManager)
	self.objectManager = objectManager
	self.tileMenu = nil
	self.panelColorR = 0.2
	self.panelColorG = 0.13
	self.panelColorB = 0.07
	self.panelColorA = 1
	self.menuStartX = settings.menuStartX or 0
	self.menuEndX = settings.menuEndX or 1
	self.menuStartY = settings.menuStartY or 0
	self.menuEndY = settings.menuEndY or (2 / 3)
	self.selectedTile = { x = 0, y = 0 }
	self.isTileSelected = false
	return self
end

---@param tileMenu TileMenu
function MenuManager:setTileMenu(tileMenu)
	self.tileMenu = tileMenu
end

---@param x number
---@param y number
function MenuManager:setSelectedTile(x, y)
	self.selectedTile = { x = x, y = y }
	self.isTileSelected = true
end

---@param width number
---@param height number
function MenuManager:applyMenuBounds(width, height)
	local gridWidth = width * 12 / 16
	local panelWidth = width - gridWidth
	if panelWidth <= 0 then
		return
	end
	local panelX = gridWidth
	local panelY = 0
	local startX = panelX + (panelWidth * self.menuStartX)
	local endX = panelX + (panelWidth * self.menuEndX)
	local startY = panelY + (height * self.menuStartY)
	local endY = panelY + (height * self.menuEndY)
	local menuWidth = math.max(0, endX - startX)
	local menuHeight = math.max(0, endY - startY)
	if menuWidth <= 0 or menuHeight <= 0 then
		return
	end
	self.objectManager:setMenuRegion(startX, startY, menuWidth, menuHeight)
end

function MenuManager:draw()
	local width, height = love.graphics.getDimensions()
	local gridWidth = width * 12 / 16
	local panelWidth = width - gridWidth
	if panelWidth <= 0 then
		return
	end
	love.graphics.setColor(self.panelColorR, self.panelColorG, self.panelColorB, self.panelColorA)
	love.graphics.rectangle("fill", gridWidth, 0, panelWidth, height)
	if self.isTileSelected and self.tileMenu then
		self.tileMenu:draw()
	else
		self:applyMenuBounds(width, height)
		self.objectManager:draw()
	end
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function MenuManager:onClick(x, y, button, isTouch, presses)
	if self.isTileSelected and self.tileMenu then
		self.tileMenu:onClick(x, y, button, isTouch, presses)
	else
		self.objectManager:onClick(x, y, button, isTouch, presses)
	end
end

---@param dx number
---@param dy number
---@param x number
---@param y number
function MenuManager:onScroll(dx, dy, x, y)
	if self.isTileSelected and self.tileMenu then
		self.tileMenu:onScroll(dx, dy, x, y)
	else
		self.objectManager:onScroll(dx, dy, x, y)
	end
end

return MenuManager
