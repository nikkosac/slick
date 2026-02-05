---@type Tower
local Tower = require("tower")
---@type Mob
local Mob = require("mob")
---@type GameState
local GameState = require("state")
---@type MenuManager
local MenuManager = require("menu_manager")
---@type TileMenu
local TileMenu = require("tile_menu")
---@type Clock
local Clock = require("clock")
---@type InteractableObjectManager
local InteractableObjectManager = require("interactable_object_manager")
---@type PathMath
local PathMath = require("path_math")

---@type GameState
local state = GameState.new()

---@type InteractableObjectManager
local objectManager
---@type MenuManager
local menuManager
---@type TileMenu
local tileMenu
---@type Clock[]
local clocks

function love.load()
  love.graphics.setBackgroundColor(0.2, 0.13, 0.07, 1)
  ---@type integer
  local numCellsY = 20
  ---@type number
  state.width, state.height = love.graphics.getDimensions()
  state.gridWidth = state.width * 12 / 16
  local gridHeight = state.height
  local gridAspect = state.gridWidth / gridHeight
  ---@type integer
  local numCellsX = math.floor((numCellsY * gridAspect) + 0.5)
  ---@type number
  local cellSize = math.min(state.gridWidth / numCellsX, gridHeight / numCellsY)
  state.cellSize = cellSize
  state.grid = {
    numCellsX = numCellsX,
    numCellsY = numCellsY,
    cellSize = cellSize,
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

  state.towers = {}
  state:addTower(Tower.new({ pos = { x = 10, y = 5 }, range = 4, cooldown = 0.75 }))
  state:addTower(Tower.new({ pos = { x = 15, y = 5 }, range = 4, cooldown = 0.75 }))
  state:addTower(Tower.new({ pos = { x = 4, y = 12 }, range = 2, cooldown = 0.75 }))
  state:addTower(Tower.new({ pos = { x = 12, y = 14 }, range = 3, cooldown = 0.75 }))
  state:addTower(Tower.new({ pos = { x = 10, y = 14 }, range = 3, cooldown = 0.75 }))
  state:addTower(Tower.new({ pos = { x = 11, y = 16 }, range = 3, cooldown = 0.75 }))
  state:addTower(Tower.new({ pos = { x = 9, y = 16 }, range = 3, cooldown = 0.75 }))

  state.mobs = {}
  state:addMob(Mob.new({ radius = 0.75, speed = 0.015, health = 200 }))
  state:addMob(Mob.new({ radius = 0.50, speed = 0.02, health = 50 }))
  state:addMob(Mob.new({ radius = 0.50, speed = 0.025, health = 25 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.030, health = 1 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.031, health = 1 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.032, health = 1 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.033, health = 1 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.034, health = 1 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.035, health = 1 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.036, health = 1 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.037, health = 1 }))
  state:addMob(Mob.new({ radius = 0.20, speed = 0.038, health = 1 }))

  objectManager = InteractableObjectManager.new()
  menuManager = MenuManager.new(objectManager, state)
  menuManager.menuStartX = 0
  menuManager.menuEndX = 1
  menuManager.menuStartY = 1 / 3
  menuManager.menuEndY = 1
  tileMenu = TileMenu.new(menuManager, state, 12 / 16, 1, 1 / 3, 1)
  menuManager:setTileMenu(tileMenu)
  ---@type number
  local centerX = state.gridWidth / 2
  ---@type number
  local centerY = gridHeight / 2
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
  state:update(dt)
  objectManager:updateAll(dt)
end

---@param key string
function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
    return
  end
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
  local width = state.width
  local height = state.height
  state:draw()
  menuManager:draw()

  -- Outline
  love.graphics.setLineWidth(2)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", 0, 0, width, height)
end

---@param x number
---@param y number
---@return boolean
local function isMenuClick(x, y)
  return x >= state.gridWidth and y >= 0 and y <= state.height
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function love.mousepressed(x, y, button, isTouch, presses)
  if isMenuClick(x, y) then
    menuManager:onClick(x, y, button, isTouch, presses)
  else
    local cellSize = state.grid.cellSize
    local maxGridWidth = state.grid.numCellsX * cellSize
    local maxGridHeight = state.grid.numCellsY * cellSize
    if x < 0 or y < 0 or y > maxGridHeight or x > maxGridWidth then
      return
    end
    local cellX = math.floor(x / cellSize)
    local cellY = math.floor(y / cellSize)
    if PathMath.isTileOnPath(state.path, cellX, cellY) then
      return
    end
    state.selectedTile = { x = cellX, y = cellY }
    state.isTileSelected = true
  end
end

---@param dx number
---@param dy number
function love.wheelmoved(dx, dy)
  ---@type number, number
  local mouseX, mouseY = love.mouse.getPosition()
  menuManager:onScroll(dx, dy, mouseX, mouseY)
end
