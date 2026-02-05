---@class Button
---@field x number
---@field y number
---@field width number
---@field height number
---@field colorR number
---@field colorG number
---@field colorB number
---@field colorA number
---@field text string
---@field onClickFn fun(button: Button, x: number, y: number)|nil
local Button = {}
Button.__index = Button

---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
---@param colorR number
---@param colorG number
---@param colorB number
---@param colorA number|nil
---@param onClickFn fun(button: Button, x: number, y: number)|nil
---@return Button
function Button.new(x, y, width, height, text, colorR, colorG, colorB, colorA, onClickFn)
  local self = setmetatable({}, Button)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.colorR = colorR
  self.colorG = colorG
  self.colorB = colorB
  self.colorA = colorA or 1
  self.text = text
  self.onClickFn = onClickFn
  return self
end

---@param x number
---@param y number
---@return boolean
function Button:containsPoint(x, y)
  return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

---@param x number
---@param y number
function Button:onClick(x, y)
  if self.onClickFn then
    self.onClickFn(self, x, y)
  end
end

function Button:draw()
  love.graphics.setColor(self.colorR, self.colorG, self.colorB, self.colorA)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  love.graphics.setColor(1, 1, 1, 1)
  local font = love.graphics.getFont()
  local textWidth = font:getWidth(self.text)
  local textHeight = font:getHeight()
  local textX = self.x + (self.width - textWidth) / 2
  local textY = self.y + (self.height - textHeight) / 2
  love.graphics.print(self.text, textX, textY)
end

return Button
