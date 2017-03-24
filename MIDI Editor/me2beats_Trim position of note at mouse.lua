-- @description Trim position of note at mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end
notes = r.MIDI_CountEvts(take)
window, segment, details = r.BR_GetMouseCursorContext()
_,_, noteRow = r.BR_GetMouseCursorContext_MIDI()
if noteRow == -1 then bla() return end

mouse_time = r.BR_GetMouseCursorContext_Position()

mouse_ppq_pos = r.MIDI_GetPPQPosFromProjTime(take, mouse_time)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, notes - 1 do
  _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
  if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos and noteRow == pitch then
    r.MIDI_SetNote(take, i, sel, muted, math.floor(mouse_ppq_pos+0.5), end_note, chan, pitch, vel)
    break
  end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Trim position of note at mouse', -1)
