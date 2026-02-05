---@class GameState
---@field width number
---@field height number
---@field grid Grid
---@field path Path
---@field towers Tower[]
---@field mobs Mob[]
---@field castle Castle|nil
---@field cellSize number
---@field gridWidth number
---@field gridColorR number
---@field gridColorG number
---@field gridColorB number
---@field gridColorA number
---@field selectedTile Vec2
---@field isTileSelected boolean
local GameState = {}
GameState.__index = GameState

---@type CellMath
local cellMath = require("cell_math")

---@param config { path: Path }
---@return GameState
function GameState.new(config)
  local self = setmetatable({}, GameState)
  self.width = 0
  self.height = 0
  self.grid = {
    numCellsX = 0,
    numCellsY = 0,
    cellSize = 0,
  }
  self.path = config.path
  self.towers = {}
  self.mobs = {}
  local castleHealth = 100
  local castleSize = 1
  self.castle = nil
  if #self.path > 0 then
    local endNode = self.path[#self.path]
    self.castle = {
      pos = { x = endNode.x, y = endNode.y },
      size = castleSize,
      health = castleHealth,
      maxHealth = castleHealth,
    }
  end
  self.cellSize = 0
  self.gridWidth = 0
  self.gridColorR = 0.05
  self.gridColorG = 0.08
  self.gridColorB = 0.2
  self.gridColorA = 1
  self.selectedTile = { x = 0, y = 0 }
  self.isTileSelected = false
  return self
end

---@param tower Tower
function GameState:addTower(tower)
  for _, existing in ipairs(self.towers) do
    if existing.pos and tower.pos and existing.pos.x == tower.pos.x and existing.pos.y == tower.pos.y then
      return
    end
  end
  table.insert(self.towers, tower)
end

---@param mob Mob
function GameState:addMob(mob)
  table.insert(self.mobs, mob)
end

---@param dt number
function GameState:update(dt)
  local mobs = self.mobs
  local towers = self.towers
  local path = self.path
  local castle = self.castle

  for _, tower in ipairs(towers) do
    tower:update(dt, mobs, path)
  end

  for i = #mobs, 1, -1 do
    local mob = mobs[i]
    mob:update(dt)
    if mob.health <= 0 then
      table.remove(mobs, i)
    elseif mob.t >= 1 then
      if castle then
        castle.health = math.max(0, castle.health - mob.damage)
      end
      table.remove(mobs, i)
    end
  end
end

function GameState:draw()
  local grid = self.grid
  local path = self.path
  local towers = self.towers
  local mobs = self.mobs
  local castle = self.castle
  local cellSize = grid.cellSize
  local height = self.height
  local gridWidth = self.gridWidth
  -- Grid background
  love.graphics.setColor(self.gridColorR, self.gridColorG, self.gridColorB, self.gridColorA)
  love.graphics.rectangle("fill", 0, 0, gridWidth, height)
  -- Grid lines
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0.5, 0.5, 0.5)
  for x = 0, grid.numCellsX - 1 do
    for y = 0, grid.numCellsY - 1 do
      love.graphics.rectangle("line", x * cellSize, y * cellSize, cellSize, cellSize)
    end
  end
  if self.isTileSelected then
    local tileX = self.selectedTile.x
    local tileY = self.selectedTile.y
    if tileX >= 0 and tileX < grid.numCellsX and tileY >= 0 and tileY < grid.numCellsY then
      love.graphics.setLineWidth(3)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle("line", tileX * cellSize, tileY * cellSize, cellSize, cellSize)
      love.graphics.setLineWidth(1)
    end
  end

  -- Path
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 1, 0)
  for i = 1, #path - 1 do
    local x1, y1 = cellMath.cellCenter(path[i].x, path[i].y, grid)
    local x2, y2 = cellMath.cellCenter(path[i + 1].x, path[i + 1].y, grid)
    love.graphics.line(x1, y1, x2, y2)
  end

  -- Castle
  if castle then
    local size = castle.size * cellSize
    local cx, cy = cellMath.cellCenter(castle.pos.x, castle.pos.y, grid)
    local x = cx - size / 2
    local y = cy - size / 2
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", x, y, size, size)

    local healthRatio = 0
    if castle.maxHealth > 0 then
      healthRatio = math.max(0, math.min(castle.health / castle.maxHealth, 1))
    end
    local missingRatio = 1 - healthRatio
    if missingRatio > 0 then
      local damageHeight = size * missingRatio
      love.graphics.setLineWidth(1)
      love.graphics.setColor(0, 0.2, 0, 0.8)
      love.graphics.rectangle("fill", x, y, size, damageHeight)
    end

    love.graphics.setLineWidth(2)
    love.graphics.setColor(0, 0.2, 0)
    love.graphics.rectangle("line", x, y, size, size)
    love.graphics.setLineWidth(1)
  end

  -- Towers
  for _, tower in ipairs(towers) do
    tower:draw(grid)
  end

  -- Mobs
  for _, mob in ipairs(mobs) do
    mob:draw(path, grid)
  end
end

return GameState
