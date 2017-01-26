-- @description Rename current FX preset (of focused FX)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

reaper.Undo_BeginBlock()
  
retval, trnum, _, fxnum = reaper.GetFocusedFX()
if retval == 1 then
  tr = reaper.GetTrack(0,trnum-1)  
  filename = reaper.TrackFX_GetUserPresetFilename(tr, fxnum, '')
  _, old_name = reaper.TrackFX_GetPreset(tr, fxnum, '')
  
  os = reaper.GetOS()
  if os == 'Win32' or 'Win64' then
    filename_ok = string.gsub (filename, [[\]], [[\\]])
  else
    filename_ok = filename
  end

  file = io.open(filename_ok, "r")
  if file ~= nil then
    x = file:read('*a')
    file:close()

    presets = tonumber(x:match("NbPresets=(%d*)"))
    preset_index = reaper.TrackFX_GetPresetIndex(tr, fxnum)
    if presets > preset_index then
    
      retval, new_name = reaper.GetUserInputs("Rename current FX preset", 1, "Rename preset:", "")
      if retval == true then 
    
        file_new = io.open(filename_ok, "w")
        a = string.gsub (x, 'Name='..old_name..'\n', 'Name='..new_name..'\n', 1)
        file_new:write(a)
        file_new:close()
        
        reaper.TrackFX_SetPreset(tr, fxnum, new_name)
      end
    else
      reaper.MB("Can't rename built-in presets",'Rename current FX preset',0)
    end
  else
    reaper.MB('The preset file does not exist','Rename current FX preset',0)
  end
end

reaper.Undo_EndBlock('', 2)
