-- @description Select region at cursor
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

markeridx, regionidx = reaper.GetLastMarkerAndCurRegion(0, reaper.GetCursorPosition())
if regionidx then
  reaper.Undo_BeginBlock()
  _, _, x, y = reaper.EnumProjectMarkers3(0,regionidx)
  reaper.GetSet_LoopTimeRange(1, 1, x, y, 0)
  reaper.Undo_EndBlock("Select region at edit cursor", -1)
end
