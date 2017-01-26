-- @description Remove focused track fx
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

retval, trnum, _, fx = reaper.GetFocusedFX()
if retval == 1 then
  script_title = 'Remove focused track fx'
  reaper.Undo_BeginBlock()
  tr = reaper.GetTrack(0,trnum-1)
  reaper.SNM_MoveOrRemoveTrackFX(tr, fx, 0)
  reaper.Undo_EndBlock(script_title, -1)
else
  reaper.defer(nothing)
end
