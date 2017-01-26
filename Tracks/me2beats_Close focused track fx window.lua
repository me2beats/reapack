-- @description Close focused track fx window
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

retval, trnum, _, fxnum = reaper.GetFocusedFX()
if retval == 1 then
  tr = reaper.GetTrack(0,trnum-1)
  reaper.TrackFX_SetOpen(tr, fxnum, false)
  
  script_title = 'Close focused track fx window'
  reaper.Undo_BeginBlock()
  reaper.Undo_EndBlock(script_title, -1)
else
  reaper.defer(nothing)
end
