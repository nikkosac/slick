---@meta

---@class Vec2
---@field x number
---@field y number

---@alias Path Vec2[]

---@class Grid
---@field numCellsX integer
---@field numCellsY integer
---@field cellSize number

---@class Bullet
---@field pos Vec2
---@field dir Vec2
---@field speed number
---@field radius number
---@field damage number

---@class TowerConfig
---@field pos Vec2
---@field range number
---@field cooldown number

---@class MobConfig
---@field radius number
---@field speed number
---@field health number
