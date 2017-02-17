-- @description Remove focused track fx
-- @version 0.9
-- @author me2beats
-- @changelog
--  + init

function nothing() end

retval, trnum, _, fx = reaper.GetFocusedFX()
if retval == 1 then
  reaper.Undo_BeginBlock()
  tr = reaper.GetTrack(0,trnum-1)
  reaper.SNM_MoveOrRemoveTrackFX(tr, fx, 0)
  reaper.Undo_EndBlock('Remove focused track fx', -1)
else reaper.defer(nothing) end
