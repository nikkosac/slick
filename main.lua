---@type CellMath
local cellMath = require("cell_math")
---@type Tower
local Tower = require("tower")
---@type Mob
local Mob = require("mob")
---@type Clock
local Clock = require("clock")
---@type InteractableObjectManager
local InteractableObjectManager = require("interactable_object_manager")

---@type GameState
local state = {
	width = 0,
	height = 0,
	grid = {
		numCellsX = 0,
		numCellsY = 0,
		cellSize = 0,
	},
	path = {},
	towers = {},
	mobs = {},
}

---@type InteractableObjectManager
local objectManager
---@type Clock[]
local clocks

function love.load()
	love.graphics.setBackgroundColor(0.2, 0.13, 0.07, 1)
	---@type integer
	local numCellsY = 20
	---@type number
	state.width, state.height = love.graphics.getDimensions()
	local gridWidth = state.width * 12 / 16
	local gridHeight = state.height
	local gridAspect = gridWidth / gridHeight
	---@type integer
	local numCellsX = math.floor((numCellsY * gridAspect) + 0.5)
	---@type number
	local cellSize = math.min(gridWidth / numCellsX, gridHeight / numCellsY)
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

	state.towers = {
		Tower.new({ pos = { x = 10, y = 5 }, range = 4, cooldown = 0.75 }),
		Tower.new({ pos = { x = 15, y = 5 }, range = 4, cooldown = 0.75 }),
		Tower.new({ pos = { x = 4, y = 12 }, range = 2, cooldown = 0.75 }),
		Tower.new({ pos = { x = 12, y = 14 }, range = 3, cooldown = 0.75 }),
		Tower.new({ pos = { x = 10, y = 14 }, range = 3, cooldown = 0.75 }),
		Tower.new({ pos = { x = 11, y = 16 }, range = 3, cooldown = 0.75 }),
		Tower.new({ pos = { x = 9, y = 16 }, range = 3, cooldown = 0.75 }),
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

	objectManager = InteractableObjectManager.new()
	---@type number
	local centerX = gridWidth / 2
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
	local mobs = state.mobs
	local towers = state.towers
	local path = state.path

	for _, tower in ipairs(towers) do
		tower:update(dt, mobs, path)
	end

	for i, mob in ipairs(mobs) do
		mob:update(dt)
		if mob.t >= 1 or mob.health <= 0 then
			table.remove(mobs, i)
		end
	end

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
	local grid = state.grid
	local path = state.path
	local towers = state.towers
	local mobs = state.mobs
	local cellSize = grid.cellSize
	local width = state.width
	local height = state.height
	local gridWidth = width * 12 / 16
	-- Grid background
	love.graphics.setColor(0.05, 0.08, 0.2, 1)
	love.graphics.rectangle("fill", 0, 0, gridWidth, height)
	-- Panel background
	love.graphics.setColor(0.2, 0.13, 0.07, 1)
	love.graphics.rectangle("fill", gridWidth, 0, width - gridWidth, height)
	-- Grid lines
	love.graphics.setLineWidth(1)
	love.graphics.setColor(0.5, 0.5, 0.5)
	for x = 0, grid.numCellsX - 1 do
		for y = 0, grid.numCellsY - 1 do
			love.graphics.rectangle("line", x * cellSize, y * cellSize, cellSize, cellSize)
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

	-- Towers
	for _, tower in ipairs(towers) do
		tower:draw(grid)
	end

	-- Mobs
	for _, mob in ipairs(mobs) do
		mob:draw(path, grid)
	end

	-- UI overlay
	love.graphics.setColor(1, 1, 1, 1)
	objectManager:draw()

	-- Outline
	love.graphics.setLineWidth(2)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, width, height)
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function love.mousepressed(x, y, button, isTouch, presses)
	objectManager:onClick(x, y, button, isTouch, presses)
end

---@param dx number
---@param dy number
function love.wheelmoved(dx, dy)
	---@type number, number
	local mouseX, mouseY = love.mouse.getPosition()
	objectManager:onScroll(dx, dy, mouseX, mouseY)
end
