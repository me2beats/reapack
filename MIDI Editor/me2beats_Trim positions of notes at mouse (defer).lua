-- @description Trim positions of notes at mouse (defer)
-- @version 1.1
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function main()

  take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
  if not take then goto cnt end
    _,notes = r.MIDI_CountEvts(take)
    window, segment, details = r.BR_GetMouseCursorContext()
    _,_, noteRow = r.BR_GetMouseCursorContext_MIDI()
    if noteRow == -1 then goto cnt end

  do
    local mouse_time = r.BR_GetMouseCursorContext_Position()
    mouse_ppq_pos = r.MIDI_GetPPQPosFromProjTime(take, mouse_time)
  end
  note = nil
  for i = 0, notes - 1 do
    _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
    if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos and noteRow == pitch then
      note = i
      break
    end
  end


  if note and (not last_note or (last_note ~= note or (last_note == note and last_mouse_ppq_pos ~= mouse_ppq_pos))) then

    r.Undo_BeginBlock()
--      r.MIDI_SetNote(take, note, sel, muted, math.floor(mouse_ppq_pos+0.5), end_note, chan, pitch, vel)
    r.MIDI_SetNote(take, note, sel, muted, math.floor(mouse_ppq_pos+1), end_note, chan, pitch, vel)
    r.Undo_EndBlock('Trim positions of notes at mouse', -1)
  end

  last_note = note
  last_mouse_ppq_pos = mouse_ppq_pos
  
  ::cnt::
  
  r.defer(main)
end


function SetButtonON()
  r.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  r.RefreshToolbar2( sec, cmd )
  main()
end

-----------------------------------------------

function SetButtonOFF()
  r.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  r.RefreshToolbar2( sec, cmd )
end

-----------------------------------------------

_, _, sec, cmd = r.get_action_context()
SetButtonON()
r.atexit(SetButtonOFF)

