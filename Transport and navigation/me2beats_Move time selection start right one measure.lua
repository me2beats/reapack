-- @description Move time selection start right one measure
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

ts_start, ts_end = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

if ts_start == ts_end then bla() return end

for i = 0, 10000 do
  msr = r.TimeMap_GetMeasureInfo(0, i)
  if msr > ts_start then break end
end

if ts_end-msr <=0 then bla() return end

r.Undo_BeginBlock()
r.GetSet_LoopTimeRange(1, 1, msr, ts_end, 0)
r.Undo_EndBlock('Move time selection start right one measure', -1)
