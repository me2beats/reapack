-- @description Delete track under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

track = reaper.BR_TrackAtMouseCursor()
if track then
  reaper.Undo_BeginBlock()
  reaper.DeleteTrack(track)
  reaper.Undo_EndBlock('remove item under mouse', -1)
else reaper.defer(nothing) end
