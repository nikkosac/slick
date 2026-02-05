---@class GameState
---@field width number
---@field height number
---@field grid Grid
---@field path Path
---@field towers Tower[]
---@field mobs Mob[]
---@field cellSize number
---@field gridWidth number
---@field gridColorR number
---@field gridColorG number
---@field gridColorB number
---@field gridColorA number
local GameState = {}
GameState.__index = GameState

---@type CellMath
local cellMath = require("cell_math")

---@return GameState
function GameState.new()
	local self = setmetatable({}, GameState)
	self.width = 0
	self.height = 0
	self.grid = {
		numCellsX = 0,
		numCellsY = 0,
		cellSize = 0,
	}
	self.path = {}
	self.towers = {}
	self.mobs = {}
	self.cellSize = 0
	self.gridWidth = 0
	self.gridColorR = 0.05
	self.gridColorG = 0.08
	self.gridColorB = 0.2
	self.gridColorA = 1
	return self
end

---@param tower Tower
function GameState:addTower(tower)
	for _, existing in ipairs(self.towers) do
		if existing.pos and tower.pos
			and existing.pos.x == tower.pos.x
			and existing.pos.y == tower.pos.y then
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

	for _, tower in ipairs(towers) do
		tower:update(dt, mobs, path)
	end

	for i, mob in ipairs(mobs) do
		mob:update(dt)
		if mob.t >= 1 or mob.health <= 0 then
			table.remove(mobs, i)
		end
	end
end

function GameState:draw()
	local grid = self.grid
	local path = self.path
	local towers = self.towers
	local mobs = self.mobs
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

return GameState
