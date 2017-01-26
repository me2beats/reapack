-- @description Set random user preset
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
  filename = r.TrackFX_GetUserPresetFilename(tr, fxnum, '')
  os = r.GetOS()
  if os == 'Win32' or 'Win64' then filename_ok = filename:gsub([[\]], [[\\]])
  else filename_ok = filename end
  file = io.open(filename_ok, "r")
  if file then
    x = file:read('*a')
    file:close()
    user_presets = tonumber(x:match("NbPresets=(%d*)"))
    if user_presets > 0 then
      random = math.random(user_presets)
      r.TrackFX_SetPresetByIndex(tr, fxnum, random)
    end
  end
end

