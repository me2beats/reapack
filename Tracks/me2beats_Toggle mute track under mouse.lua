-- @description Toggle mute track under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

track = reaper.BR_TrackAtMouseCursor()
if track then
  reaper.Undo_BeginBlock()
  if reaper.GetMediaTrackInfo_Value(track, 'B_MUTE') == 1 then
    reaper.SetMediaTrackInfo_Value(track, 'B_MUTE', 0)
  else
    reaper.SetMediaTrackInfo_Value(track, 'B_MUTE', 1)
  end
  reaper.Undo_EndBlock('toggle mute track under mouse', -1)
else reaper.defer(nothing) end
