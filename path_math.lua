---@class PathMath
local pathMath = {}

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
