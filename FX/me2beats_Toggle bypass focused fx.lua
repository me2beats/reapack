-- @description Toggle bypass focused fx
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

retval, trnum, itnum, fxnum = reaper.GetFocusedFX()
if retval == 1 then
  reaper.Undo_BeginBlock()
  tr = reaper.GetTrack(0,trnum-1)
  fx_enabled = reaper.TrackFX_GetEnabled(tr, fxnum)
  if fx_enabled == true then
    reaper.TrackFX_SetEnabled(tr, fxnum, false)
  elseif fx_enabled == false then 
    reaper.TrackFX_SetEnabled(tr, fxnum, true)
  end
  reaper.Undo_EndBlock('toggle bypass focused fx', -1)
elseif retval == 2 then
  reaper.MB("it's a take fx. my programmer will fix this later", 'oops', 0)
else reaper.defer(nothing) end
