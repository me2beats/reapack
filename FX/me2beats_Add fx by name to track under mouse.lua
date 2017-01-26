-- @description Add fx by name to track under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

track = reaper.BR_TrackAtMouseCursor()
if track then
  reaper.Undo_BeginBlock()
  retval, fx_name = reaper.GetUserInputs("Add FX to track by name", 1, "FX name:", "")
  reaper.TrackFX_AddByName(track, fx_name, 0, -1)
  reaper.Undo_EndBlock('add fx by name to track under mouse', -1)
else reaper.defer(nothing) end
