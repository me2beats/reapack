-- @description Add marker with offset
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

offs = -5
_, markers = reaper.CountProjectMarkers(0)
pos = reaper.GetCursorPosition()
if pos > -offs then
  old_marker = reaper.GetLastMarkerAndCurRegion(0, pos+offs)
  _, is_region, old_marker_pos =  reaper.EnumProjectMarkers(old_marker)
  if old_marker_pos ~= pos+offs or old_marker_pos == nil then
    reaper.Undo_BeginBlock()
    reaper.AddProjectMarker(0, false, pos+offs, 0, '', markers+1)
    reaper.Undo_EndBlock('Add marker with offset', -1)
  end
end
