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
---@field buttons Button[]
local TileMenu = {}
TileMenu.__index = TileMenu

---@type Button
local Button = require("button")
---@type Tower
local Tower = require("tower")

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
  self.buttons = {}
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

function TileMenu:updateButtons()
  local x, y, width, height = self:getBounds()
  if x == nil then
    self.buttons = {}
    return
  end
  local buttonWidth = 50
  local buttonHeight = 70
  local offsetX = 10
  local offsetY = 10
  local exitX = x + offsetX
  local exitY = y + offsetY
  local addX = x + width - offsetX - buttonWidth
  local addY = y + offsetY
  local exitButton = Button.new(exitX, exitY, buttonWidth, buttonHeight, "Exit", 1, 0, 0, 1, function()
    self.state.isTileSelected = false
  end)
  local addButton = Button.new(addX, addY, buttonWidth, buttonHeight, "Add Tower", 1, 0.5, 0, 1, function()
    local selected = self.state.selectedTile
    self.state:addTower(Tower.new({ pos = { x = selected.x, y = selected.y }, range = 3, cooldown = 0.75 }))
    self.state.isTileSelected = false
  end)
  self.buttons = { exitButton, addButton }
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
  self:updateButtons()
  for _, button in ipairs(self.buttons) do
    button:draw()
  end
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function TileMenu:onClick(x, y, button, isTouch, presses)
  local boundsX, boundsY, boundsWidth, boundsHeight = self:getBounds()
  if boundsX == nil then
    return
  end
  if x < boundsX or x > boundsX + boundsWidth or y < boundsY or y > boundsY + boundsHeight then
    return
  end
  for _, entry in ipairs(self.buttons) do
    if entry:containsPoint(x, y) then
      entry:onClick(x, y)
      return
    end
  end
end

---@param dx number
---@param dy number
---@param x number
---@param y number
function TileMenu:onScroll(dx, dy, x, y)
  -- reserved for future tile menu actions
end

return TileMenu
