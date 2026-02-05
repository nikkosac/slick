---@type CellMath
local cellMath = require("cell_math")
---@type Tower
local Tower = require("tower")
---@type Mob
local Mob = require("mob")

---@type GameState
local state = {
  width = 0,
  height = 0,
  grid = {
    numCellsX = 0,
    numCellsY = 0,
    cellWidth = 0,
    cellHeight = 0,
  },
  path = {},
  towers = {},
  mobs = {},
}

function love.load()
  ---@type number
  local width, height = love.graphics.getDimensions()
  ---@type integer
  local numCellsX, numCellsY = 20, 20
  local minDim = math.min(width, height)
  ---@type number
  local cellWidth, cellHeight = minDim / numCellsX, minDim / numCellsY

  state.width = width
  state.height = height
  state.grid = {
    numCellsX = numCellsX,
    numCellsY = numCellsY,
    cellWidth = cellWidth,
    cellHeight = cellHeight,
  }

  ---@type Path
  state.path = {
    { x = 0, y = 0 },
    { x = 12, y = 0 },
    { x = 12, y = 10 },
    { x = 3, y = 10 },
    { x = 3, y = 15 },
    { x = 15, y = 15 },
    { x = 15, y = 19 },
    { x = 19, y = 19 },
  }

  local cooldown = 0.75
  state.towers = {
    Tower.new({ pos = { x = 10, y = 5 }, range = 4, cooldown = cooldown }),
    Tower.new({ pos = { x = 15, y = 5 }, range = 4, cooldown = cooldown }),
    Tower.new({ pos = { x = 4, y = 12 }, range = 2, cooldown = cooldown }),
    Tower.new({ pos = { x = 12, y = 14 }, range = 3, cooldown = cooldown }),
    Tower.new({ pos = { x = 10, y = 14 }, range = 3, cooldown = cooldown }),
    Tower.new({ pos = { x = 11, y = 16 }, range = 3, cooldown = cooldown }),
    Tower.new({ pos = { x = 9, y = 16 }, range = 3, cooldown = cooldown }),
  }

  state.mobs = {
    Mob.new({ radius = 0.75, speed = 0.015, health = 200 }),
    Mob.new({ radius = 0.50, speed = 0.02, health = 50 }),
    Mob.new({ radius = 0.50, speed = 0.025, health = 25 }),
    Mob.new({ radius = 0.20, speed = 0.030, health = 1 }),
    Mob.new({ radius = 0.20, speed = 0.031, health = 1 }),
    Mob.new({ radius = 0.20, speed = 0.032, health = 1 }),
    Mob.new({ radius = 0.20, speed = 0.033, health = 1 }),
    Mob.new({ radius = 0.20, speed = 0.034, health = 1 }),
    Mob.new({ radius = 0.20, speed = 0.035, health = 1 }),
    Mob.new({ radius = 0.20, speed = 0.036, health = 1 }),
    Mob.new({ radius = 0.20, speed = 0.037, health = 1 }),
    Mob.new({ radius = 0.20, speed = 0.038, health = 1 }),
  }
end

---@param key string
function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.update()
  local dt = love.timer.getDelta()
  local mobs = state.mobs
  local towers = state.towers
  local path = state.path

  for _, tower in ipairs(towers) do
    tower:update(dt, mobs, path)
  end

  for i, mob in ipairs(mobs) do
    mob:update(dt)
    -- Delete mobs that reached the end of the path or are dead
    if mob.t >= 1 or mob.health <= 0 then
      table.remove(mobs, i)
    end
  end
end

function love.draw()
  local grid = state.grid
  local path = state.path
  local towers = state.towers
  local mobs = state.mobs
  local cellWidth = grid.cellWidth
  local cellHeight = grid.cellHeight
  local width = state.width
  local height = state.height
  -- Grid lines
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0.5, 0.5, 0.5)
  for x = 0, grid.numCellsX - 1 do
    for y = 0, grid.numCellsY - 1 do
      love.graphics.rectangle("line", x * cellWidth, y * cellHeight, cellWidth, cellHeight)
    end
  end

  -- Outline
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("line", 0, 0, width, height)

  -- Path
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 1, 0)
  for i = 1, #path - 1 do
    local x1, y1 = cellMath.cellCenter(path[i].x, path[i].y, grid)
    local x2, y2 = cellMath.cellCenter(path[i + 1].x, path[i + 1].y, grid)
    love.graphics.line(x1, y1, x2, y2)
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
