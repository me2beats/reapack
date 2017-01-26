-- @description Set preset
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing()
end

items = reaper.CountSelectedMediaItems(0)
retval, preset = reaper.GetUserInputs("Set Preset", 1, "Set Preset:", "")
if retval == true then 

  retval, trnum, _, fxnum = reaper.GetFocusedFX()
  if retval == 1 then
  
    script_title = 'Set Preset'
    reaper.Undo_BeginBlock()
  
    tr = reaper.GetTrack(0,trnum-1)  
    reaper.TrackFX_SetPreset(tr, fxnum, preset)
    
    reaper.Undo_EndBlock(script_title, -1)
  end
else
  reaper.defer(nothing)
end
