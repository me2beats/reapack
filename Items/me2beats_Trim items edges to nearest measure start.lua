-- @description Trim items edges to nearest measure start
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()

local items_t = {}
local min = math.huge
for i = 0,items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  local it_end = it_start+r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  min = math.min(min,it_start)
  items_t[#items_t+1] = {item,it_start,it_end}
end

for i = 0,1000 do msr = r.TimeMap_GetMeasureInfo(0, i) if msr >= min then iter = i break end end

function nearest_to_x(x,x1,x2)
  local y,z = math.max(x,x1)-math.min(x,x1), math.max(x,x2)-math.min(x,x2)
  if y<z then return x1 elseif y>z then return x2 else return math.min(x1,x2) end
end

r.Undo_BeginBlock()

for j = 1, #items_t do
  local item, it_start, it_end = items_t[j][1],items_t[j][2],items_t[j][3]

  for i = iter,1000 do
    local msr = r.TimeMap_GetMeasureInfo(0, i)
    if msr >= it_start then
      startTime = nearest_to_x(it_start,msr,r.TimeMap_GetMeasureInfo(0, i-1))
    break end
  end

  for i = iter,1000 do
    local msr = r.TimeMap_GetMeasureInfo(0, i)
    if msr >= it_end then
      endTime = nearest_to_x(it_end,msr,r.TimeMap_GetMeasureInfo(0, i-1))
    break end
  end

  r.BR_SetItemEdges(item, startTime, endTime)
end

r.Undo_EndBlock('Trim items edges to nearest measure start', -1)

