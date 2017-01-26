-- @description Set random preset
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

-- focused fx needed
r = reaper
function nothing() end
retval, trnum, _, fxnum = r.GetFocusedFX()
if retval == 1 then
  tr = r.GetTrack(0,trnum-1)
  _, presets = r.TrackFX_GetPresetIndex(tr, fxnum)  
  if presets > 0 then
    random = math.random(presets)
    r.TrackFX_SetPresetByIndex(tr, fxnum, random)
  end
end

