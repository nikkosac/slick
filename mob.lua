local pathMath = require("path_math")
---@type CellMath
local cellMath = require("cell_math")

---@class Mob
---@field radius number
---@field speed number
---@field health number
---@field maxHealth number
---@field damage number
---@field t number
local Mob = {}
Mob.__index = Mob

---@param config MobConfig
---@return Mob
function Mob.new(config)
  return setmetatable({
    radius = config.radius,
    speed = config.speed,
    health = config.health,
    maxHealth = config.health,
    damage = config.damage or 1,
    t = 0,
  }, Mob)
end

---@param self Mob
---@param dt number
function Mob:update(dt)
  self.t = self.t + self.speed * dt

  -- Clamp t and health
  self.t = math.min(self.t, 1)
  self.health = math.min(self.maxHealth, math.max(self.health, 0))
end

---@param self Mob
---@param path Path
---@return number x, number y
function Mob:getPosition(path)
  return pathMath.interpolatedPosition(path, self.t)
end

---@param self Mob
---@param path Path
---@param grid Grid
function Mob:draw(path, grid)
  local cellSize = grid.cellSize
  local radius = self.radius * cellSize
  love.graphics.setColor(1, 0, 0)
  local x, y = pathMath.interpolatedPosition(path, self.t)
  local cx, cy = cellMath.cellCenter(x, y, grid)
  love.graphics.circle("fill", cx, cy, radius)

  local healthRatio = 0
  if self.maxHealth > 0 then
    healthRatio = self.health / self.maxHealth
  end
  local missingRatio = 1 - healthRatio
  if missingRatio > 0 then
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.5, 0, 0, 0.8)
    love.graphics.arc("fill", cx, cy, radius, -math.pi / 2, -math.pi / 2 + missingRatio * 2 * math.pi)
  end
end

return Mob
