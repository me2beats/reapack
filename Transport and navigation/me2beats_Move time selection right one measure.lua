-- @description Move time selection right one measure
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

ts_start, ts_end = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

if ts_start == ts_end then bla() return end

for i = 0, 10000 do
  msr = r.TimeMap_GetMeasureInfo(0, i)
  if msr >= ts_end then next_msr = msr; msr = r.TimeMap_GetMeasureInfo(0, i-1) break end
end

r.Undo_BeginBlock()

r.GetSet_LoopTimeRange(1, 1, next_msr-msr+ts_start, next_msr-msr+ts_end, 0)

r.Undo_EndBlock('Move time selection right one measure', -1)
