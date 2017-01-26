-- @description Toggle select chord under mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

r = reaper
take = r.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
if take then
  notes = r.MIDI_CountEvts(take)
  window, segment, details = r.BR_GetMouseCursorContext()
  _, noteRow = r.BR_GetMouseCursorContext_MIDI()
  if noteRow ~= -1 then
    r.Undo_BeginBlock(); r.PreventUIRefresh(111)
    mouse_time = r.BR_GetMouseCursorContext_Position()
    mouse_ppq_pos = r.MIDI_GetPPQPosFromProjTime(take, mouse_time)
    x = 1
    for i = 0, notes - 1 do
      retval, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
      if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos then
        if sel == true then selected = 1 else unselected = 1 end
        if selected and unselected then break end
      end
    end
    if selected or unselected then
      for i = 0, notes - 1 do
        retval, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
        if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos then
          if (selected and unselected) or unselected then
            r.MIDI_SetNote(take, i, 1, muted, start_note, end_note, chan, pitch, vel)
          else r.MIDI_SetNote(take, i, 0, muted, start_note, end_note, chan, pitch, vel) end
        end
      end
    end
    r.PreventUIRefresh(-111); r.Undo_EndBlock('select chord under mouse', 0)
  end
end
