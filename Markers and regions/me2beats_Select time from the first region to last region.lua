-- @description Select time from the first region to last region
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

_, _, regions = r.CountProjectMarkers(0)

x_min = 100000
y_max = 0

for i = 0, regions-1 do
  _, _, x, y = r.EnumProjectMarkers3(0,i)
  if x < x_min then x_min = x end
  if y > y_max then y_max = y end
end

r.Undo_BeginBlock()
r.GetSet_LoopTimeRange(1, 1, x_min, y_max, 0)
r.Undo_EndBlock('select time from the first region to last region', -1)
