-- @description Move time selection end left one measure
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

ts_start, ts_end = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

if ts_start == ts_end then bla() return end

for i = 0, 10000 do
  msr = r.TimeMap_GetMeasureInfo(0, i)
  if msr >= ts_end then msr = r.TimeMap_GetMeasureInfo(0, i-1) break end
end

if (msr - ts_start) <=0 then bla() return end

r.Undo_BeginBlock()
r.GetSet_LoopTimeRange(1, 1, ts_start, msr, 0)
r.Undo_EndBlock('Move time selection end left one measure', -1)
