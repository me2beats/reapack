-- @description Add fx by name to selected track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

track = reaper.GetSelectedTrack(0,0)
if track then
  reaper.Undo_BeginBlock()
  retval, fx_name = reaper.GetUserInputs("Add FX to track by name", 1, "FX name:", "")
  reaper.TrackFX_AddByName(track, fx_name, 0, -1)
  reaper.Undo_EndBlock('add fx by name to sel track', -1)
else reaper.defer(nothing) end
