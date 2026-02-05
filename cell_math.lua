---@class CellMath
local cellMath = {}

---@param x number
---@param y number
---@param grid Grid
---@return number cx
---@return number cy
function cellMath.cellCenter(x, y, grid)
  return x * grid.cellSize + grid.cellSize / 2, y * grid.cellSize + grid.cellSize / 2
end

return cellMath
