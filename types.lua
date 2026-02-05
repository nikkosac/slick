---@meta

---@class Vec2
---@field x number
---@field y number

---@alias Path Vec2[]

---@class Grid
---@field numCellsX integer
---@field numCellsY integer
---@field cellWidth number
---@field cellHeight number

---@class GameState
---@field width number
---@field height number
---@field grid Grid
---@field path Path
---@field towers Tower[]
---@field mobs Mob[]

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

---@class InteractableObjectOptions
---@field x? number
---@field y? number
---@field scale? number

---@class InteractableObject
---@field x number
---@field y number
---@field drawCenterX number
---@field drawCenterY number
---@field scale number

---@class InteractableObjectMenuOptions
---@field boxSize? number
---@field spacing? number
---@field marginLeft? number
---@field marginBottom? number
---@field marginTop? number
---@field previewScale? number
---@field cornerRadius? number

---@class InteractableObjectMenu
---@field objects InteractableObject[]
---@field boxSize number
---@field spacing number
---@field marginLeft number
---@field marginBottom number
---@field marginTop number
---@field previewScale number
---@field cornerRadius number

---@class InteractableObjectManager
---@field objects InteractableObject[]
---@field activeObject InteractableObject|nil
---@field menu InteractableObjectMenu|nil

---@class ClockImages
---@field clock love.Image
---@field hour love.Image
---@field minute love.Image
---@field seconds love.Image
---@field timePick love.Image

---@class Clock : InteractableObject
---@field images ClockImages
---@field timePickOffsetX number
---@field timePickOut boolean
---@field clockedStopped boolean
---@field timeScale number
---@field timeSeconds number
---@field timeAccumulator number
---@field hour number
---@field minute number
---@field seconds number
