---@class PathMath
local pathMath = {}

---@param value number
---@return number
local function sign(value)
  if value > 0 then
    return 1
  elseif value < 0 then
    return -1
  end
  return 0
end

---@param cellX number
---@param cellY number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return boolean
local function isTileOnSegment(cellX, cellY, x1, y1, x2, y2)
  if x1 == x2 then
    local minY = math.min(y1, y2)
    local maxY = math.max(y1, y2)
    return cellX == x1 and cellY >= minY and cellY <= maxY
  end
  if y1 == y2 then
    local minX = math.min(x1, x2)
    local maxX = math.max(x1, x2)
    return cellY == y1 and cellX >= minX and cellX <= maxX
  end
  local dx = x2 - x1
  local dy = y2 - y1
  local stepX = sign(dx)
  local stepY = sign(dy)
  local steps = math.max(math.abs(dx), math.abs(dy))
  local x = x1
  local y = y1
  for _ = 0, steps do
    if cellX == x and cellY == y then
      return true
    end
    x = x + stepX
    y = y + stepY
  end
  return false
end

---@param path Path
---@param cellX number
---@param cellY number
---@return boolean
function pathMath.isTileOnPath(path, cellX, cellY)
  for i = 1, #path - 1 do
    local startNode = path[i]
    local endNode = path[i + 1]
    if isTileOnSegment(cellX, cellY, startNode.x, startNode.y, endNode.x, endNode.y) then
      return true
    end
  end
  return false
end

---@param path Path
---@param t number
---@return number x
---@return number y
function pathMath.interpolatedPosition(path, t)
  local n = #path
  if n == 0 then
    return 0, 0
  elseif n == 1 then
    return path[1].x, path[1].y
  end

  if t <= 0 then
    return path[1].x, path[1].y
  elseif t >= 1 then
    return path[n].x, path[n].y
  end

  -- Pass 1: total length
  local totalLength = 0
  for i = 1, n - 1 do
    local dx = path[i + 1].x - path[i].x
    local dy = path[i + 1].y - path[i].y
    totalLength = totalLength + math.sqrt(dx * dx + dy * dy)
  end

  if totalLength == 0 then
    -- all points identical (or all segments zero)
    return path[1].x, path[1].y
  end

  local target = t * totalLength

  -- Pass 2: walk segments until target distance
  local acc = 0
  for i = 1, n - 1 do
    local x1, y1 = path[i].x, path[i].y
    local x2, y2 = path[i + 1].x, path[i + 1].y
    local dx, dy = x2 - x1, y2 - y1
    local segLen = math.sqrt(dx * dx + dy * dy)

    if segLen > 0 then
      if acc + segLen >= target then
        local segT = (target - acc) / segLen
        return x1 + segT * dx, y1 + segT * dy
      end
      acc = acc + segLen
    end
  end

  return path[n].x, path[n].y
end

return pathMath
