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
---@field spawnTime number
---@field spawnRemaining number
---@field spawned boolean
local Mob = {}
Mob.__index = Mob

---@param config MobConfig
---@return Mob
function Mob.new(config)
  local spawnTime = config.spawnTime or 0
  return setmetatable({
    radius = config.radius,
    speed = config.speed,
    health = config.health,
    maxHealth = config.health,
    damage = config.damage or 1,
    t = 0,
    spawnTime = spawnTime,
    spawnRemaining = spawnTime,
    spawned = spawnTime <= 0,
  }, Mob)
end

---@param self Mob
---@param dt number
function Mob:update(dt)
  local movementDt = dt
  if not self.spawned then
    local remaining = self.spawnRemaining - dt
    if remaining > 0 then
      self.spawnRemaining = remaining
      movementDt = 0
    else
      self.spawnRemaining = 0
      self.spawned = true
      movementDt = -remaining
    end
  end

  if movementDt > 0 then
    self.t = self.t + self.speed * movementDt
  end

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
  if not self.spawned then
    return
  end
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
