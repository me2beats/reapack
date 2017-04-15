-- @description Adjust value for event under mouse (mousewheel)
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init

function nothing() end
reaper.defer(nothing)

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
if take then
  _,notes, ccs = reaper.MIDI_CountEvts(take)
  window, segment, details = reaper.BR_GetMouseCursorContext()
  _, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()
  if noteRow ~= -1 then
    
    mouse_time = reaper.BR_GetMouseCursorContext_Position()
    mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_time)

    -- IS THERE NOTE UNDER MOUSE ?
    for i = 0, notes - 1 do
      _, _, _, start_note, end_note, _, pitch, vel = reaper.MIDI_GetNote(take, i)
      if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos and noteRow == pitch then
        _,_,_,_,_,_,val = reaper.get_action_context()
        if val > 0 then
          if vel ~= 127 then
            reaper.MIDI_SetNote(take, i, nil, nil, nil, nil, nil, nil, vel+1, 0)
          end
        else
          if vel ~= 1 then
            reaper.MIDI_SetNote(take, i, nil, nil, nil, nil, nil, nil, vel-1, 0)
          end
        end
      break end
    end  
  end
end
