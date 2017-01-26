-- @description Toggle solo track under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

track = reaper.BR_TrackAtMouseCursor()
if track then
  reaper.Undo_BeginBlock()
  if reaper.GetMediaTrackInfo_Value(track, 'I_SOLO') == 0 then
    reaper.SetMediaTrackInfo_Value(track, 'I_SOLO', 1)
  else
    reaper.SetMediaTrackInfo_Value(track, 'I_SOLO', 0)
  end
  reaper.Undo_EndBlock('toggle solo track under mouse', -1)
else reaper.defer(nothing) end
