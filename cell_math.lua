---@class CellMath
local cellMath = {}

---@param x number
---@param y number
---@param grid Grid
---@return number cx
---@return number cy
function cellMath.cellCenter(x, y, grid)
  return x * grid.cellWidth + grid.cellWidth / 2, y * grid.cellHeight + grid.cellHeight / 2
end

return cellMath
