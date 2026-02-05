---@type CellMath
local cellMath = require("cell_math")

---@class Tower
---@field pos Vec2
---@field range number
---@field cooldown number
---@field remainingCooldown number
---@field bullets Bullet[]
---@field turretDir Vec2
local Tower = {}
Tower.__index = Tower

---@param config TowerConfig
---@return Tower
function Tower.new(config)
  return setmetatable({
    pos = { x = config.pos.x, y = config.pos.y },
    range = config.range,
    cooldown = config.cooldown,
    remainingCooldown = 0,
    bullets = {},
    turretDir = { x = 1, y = 0 },
  }, Tower)
end

---@param self Tower
---@param dt number
---@param mobs Mob[]
---@param path Path
function Tower:update(dt, mobs, path)
  -- Update cooldown
  self.remainingCooldown = math.max(0, self.remainingCooldown - dt)

  -- Find leading mob within range (largest t)
  local rangeSq = self.range * self.range
  local target
  local targetDx, targetDy, targetDistSq
  for _, mob in ipairs(mobs) do
    local mx, my = mob:getPosition(path)
    local dx = mx - self.pos.x
    local dy = my - self.pos.y
    local distSq = dx * dx + dy * dy
    if distSq <= rangeSq and (not target or mob.t > target.t) then
      target = mob
      targetDx, targetDy, targetDistSq = dx, dy, distSq
    end
  end

  -- Point turret at leading mob within range
  local dirX, dirY
  if target and targetDistSq > 0 then
    local dist = math.sqrt(targetDistSq)
    dirX, dirY = targetDx / dist, targetDy / dist
    self.turretDir = { x = dirX, y = dirY }
  end

  -- Fire at leading mob within range
  if self.remainingCooldown <= 0 and target and targetDistSq > 0 then
    local bullet = {
      pos = { x = self.pos.x, y = self.pos.y },
      dir = { x = dirX, y = dirY },
      speed = 20, -- cells per second
      radius = 0.12, -- cells
      damage = 2,
    }
    self:addBullet(bullet)
    self.remainingCooldown = self.cooldown
  end

  -- Reverse iterate to allow removal of bullets
  for i = #self.bullets, 1, -1 do
    local b = self.bullets[i]
    b.pos.x = b.pos.x + b.dir.x * b.speed * dt
    b.pos.y = b.pos.y + b.dir.y * b.speed * dt

    local hit = false
    for _, mob in ipairs(mobs) do
      local mx, my = mob:getPosition(path)
      local dx = b.pos.x - mx
      local dy = b.pos.y - my
      local radius = b.radius + mob.radius
      if dx * dx + dy * dy <= radius * radius then
        mob.health = mob.health - b.damage
        table.remove(self.bullets, i)
        hit = true
        break
      end
    end

    -- Remove bullets that are out of range
    if not hit then
      local dx = b.pos.x - self.pos.x
      local dy = b.pos.y - self.pos.y
      local distSq = dx * dx + dy * dy
      if distSq > rangeSq then
        table.remove(self.bullets, i)
      end
    end
  end
end

---@param self Tower
---@param grid Grid
function Tower:draw(grid)
  local cellSize = grid.cellSize
  local radiusCells = 0.35
  local radius = radiusCells * cellSize
  local rangeRadius = self.range * cellSize
  local cx, cy = cellMath.cellCenter(self.pos.x, self.pos.y, grid)

  -- Draw tower
  love.graphics.setColor(0, 1, 0)
  love.graphics.circle("fill", cx, cy, radius)
  -- Draw turret barrel
  local barrelLength = radius * 1.4
  local tx = cx + self.turretDir.x * barrelLength
  local ty = cy + self.turretDir.y * barrelLength
  love.graphics.setColor(0, 0.2, 0)
  love.graphics.setLineWidth(math.max(1, radius * 0.25))
  love.graphics.line(cx, cy, tx, ty)
  -- Draw range outline
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0, 1, 1)
  love.graphics.circle("line", cx, cy, rangeRadius)
  -- Draw bullets
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 1, 0)
  for _, b in ipairs(self.bullets) do
    local bx, by = cellMath.cellCenter(b.pos.x, b.pos.y, grid)
    love.graphics.circle("fill", bx, by, b.radius * cellSize)
  end

  -- Draw cooldown overlay
  if self.remainingCooldown > 0 then
    local cooldownRatio = self.remainingCooldown / self.cooldown
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.arc("fill", cx, cy, radius, -math.pi / 2, -math.pi / 2 + cooldownRatio * 2 * math.pi)
  end
end

---@param self Tower
---@param b Bullet
function Tower:addBullet(b)
  self.bullets[#self.bullets + 1] = b
end

return Tower
