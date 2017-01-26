-- @description Close last touched floating FX window
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

retval, trnum, itnum, fxnum = r.GetFocusedFX()
tr = r.GetTrack(0,trnum-1)

r.Undo_BeginBlock()

if retval == 1 then
  if trnum == 0 then
    tr = r.GetMasterTrack(0)
    r.TrackFX_Show(tr, fxnum, 2)
  else r.TrackFX_Show(tr, fxnum, 2) end
elseif retval == 2 then
  item = r.GetTrackMediaItem(tr, itnum)
  take = r.GetActiveTake(item)
  r.TakeFX_Show(take, fxnum, 2)
end

r.Undo_EndBlock('Close last touched floating FX window', 2)
