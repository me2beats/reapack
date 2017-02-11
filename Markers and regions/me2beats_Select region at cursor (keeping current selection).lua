-- @description Select region at cursor (keeping current selection)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

markeridx, regionidx = r.GetLastMarkerAndCurRegion(0, r.GetCursorPosition())
if not regionidx then return end

ts_x, ts_y = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

r.Undo_BeginBlock()
_, _, x, y = r.EnumProjectMarkers3(0,regionidx)

if ts_x == ts_y then
  r.GetSet_LoopTimeRange(1, 1, x, y, 0)
else
  r.GetSet_LoopTimeRange(1, 1, math.min(x,ts_x), math.max(y,ts_y), 0)
end

r.Undo_EndBlock("Select region at edit cursor", -1)
